require_relative 'base'

module Templates
  class Service < Base 
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
          'type' => 'NodePort',
          'selector' => {
            'app' => service
          },
          'ports' => [
            { 'port' => 80 }
          ]
        }
      }
    end
  end
end