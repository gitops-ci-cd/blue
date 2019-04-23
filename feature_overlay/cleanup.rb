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

class Cleanup
  attr_reader :client, :services, :namespace

  def initialize
    @client = Octokit::Client.new(access_token: $opts[:github_token])
    @services = fetch_services
    @namespace = $opts[:namespace]
  end

  def self.perform
    instance = self.new

    instance.delete_files_from_github
  end

  def fetch_services
    client.contents($opts[:cluster_repo]).select{ |c| c[:type] == 'dir' }.map(&:name)
  end

  def delete_files_from_github
    repo = $opts[:cluster_repo]
    ref = 'heads/master'
    sha_latest_commit = client.ref(repo, ref).object.sha
    
    sha_base_tree = client.commit(repo, sha_latest_commit).commit.tree.sha
    base_tree = client.tree(repo, sha_base_tree, recursive: true)
    cleaned_tree = base_tree.tree.reject { |blob| blob.path.include? ['overlays', namespace].join('/') }
    sanitized_tree = cleaned_tree.map { |o| o.to_h.slice(:path, :mode, :type, :sha) }
    sha_new_tree = client.create_tree(repo, sanitized_tree) # TODO: this doesn't work

    

    commit_message = "Cleanup namespace '#{namespace}'"
    sha_new_commit = client.create_commit(repo, commit_message, sha_new_tree, sha_latest_commit).sha
    updated_ref = client.update_ref(repo, ref, sha_new_commit)
  end
end