require 'octokit'
# require 'byebug'

Octokit.configure do |c|
  c.connection_options = {
    request: {
      open_timeout: 5,
      timeout: 5
    }
  }
end

class Creation
  attr_reader :client, :services, :service, :image, :namespace

  def initialize
    @client = Octokit::Client.new(access_token: $opts[:github_token])
    @services = fetch_services
    @service = $opts[:service]
    @namespace = $opts[:namespace]
    @image = "#{$opts[:target_image]}:#{$opts[:tag]}"
    unless services.include? service
      exit_code("Unknown service. Please choose one of [#{services.join(', ')}]", 2) 
    end
    @new_manifests = {}
  end

  def self.perform
    instance = self.new

    # loop over the appropriate services and build yaml files
    instance.services.each do |svc|
      svc == instance.service ? instance.create_primary_manifests : instance.create_supporting_manifests(svc)
    end

    instance.commit_files_to_github
  end

  # identify the services that need to be overlaid
  def fetch_services
    client.contents($opts[:cluster_repo]).select{ |c| c[:type] == 'dir' }.map(&:name)
  end

  def create_primary_manifests
    # we always need a new namespace
    @new_manifests.merge! Templates::Namespace.new(service: service, namespace: namespace).file

    # check each type of file for the service we're updating, and create an overlay
    @new_manifests.merge! Templates::Deployment.new(service: service, namespace: namespace, image: image).file
    @new_manifests.merge! Templates::Service.new(service: service, namespace: namespace).file
    @new_manifests.merge! Templates::Ingress.new(service: service, namespace: namespace).file
  end

  def create_supporting_manifests(svc)
    # for every other service, point the service to the default namespace, and skip the deployment
    deployment = client.contents($opts[:cluster_repo], path: [svc, 'overlays', namespace, 'deployment.yaml'].join('/')) rescue nil
    return if deployment

    @new_manifests.merge! Templates::ServiceExternalName.new(service: svc, namespace: namespace).file
    @new_manifests.merge! Templates::Ingress.new(service: svc, namespace: namespace).file
  end

  def commit_files_to_github
    repo = $opts[:cluster_repo]
    ref = 'heads/master'
    sha_latest_commit = client.ref(repo, ref).object.sha
    
    sha_base_tree = client.commit(repo, sha_latest_commit).commit.tree.sha
    sha_new_tree = client.create_tree(
      repo, 
      @new_manifests.each_with_object([]) do |(file_name, content), o|
        o.push({ 
          path: file_name, 
          mode: '100644', 
          type: 'blob', 
          sha: client.create_blob(repo, Base64.encode64(content), 'base64') 
        })
      end,
      { base_tree: sha_base_tree }
    ).sha
    
    commit_message = "Deploy #{service} into namespace '#{namespace}' with #{image}"
    sha_new_commit = client.create_commit(repo, commit_message, sha_new_tree, sha_latest_commit).sha
    updated_ref = client.update_ref(repo, ref, sha_new_commit)
  end
end