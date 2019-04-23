require_relative 'base'

module Templates
  class Ingress < Base
    def file_name
      'ingress'
    end

    def hash
      {
        'kind' => 'Ingress',
        'apiVersion' => 'extensions/v1beta1',
        'metadata' => {
          'name' => service,
          'namespace' => namespace,
          'annotations' => {
            'nginx.ingress.kubernetes.io/rewrite-target' => '/'
          }
        },
        'spec' => {
          'rules' => [
            {
              'host' => "#{namespace}.localhost",
              'http' => {
                'paths' => [
                  {
                    'path' => "/#{service}",
                    'backend' => {
                      'serviceName' => service,
                      'servicePort' => 80
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    end
  end
end