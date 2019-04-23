require_relative 'base'

module Templates
  class ServiceExternalName < Base 
    def file_name
      'service'
    end

    def hash
      {
        'kind' => 'Service',
        'apiVersion' => 'v1',
        'metadata' => {
          'name' => service,
          'namespace' => namespace
        },
        'spec' => {
          'type' => 'ExternalName',
          'externalName' => "#{service}.default.svc.cluster.local"
        }
      }
    end
  end
end