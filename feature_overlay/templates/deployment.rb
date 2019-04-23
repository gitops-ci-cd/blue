require_relative 'base'

module Templates
  class Deployment < Base
    def file_name
      'deployment'
    end

    def hash
      {
        'kind' => 'Deployment',
        'apiVersion' => 'apps/v1',
        'metadata' => {
          'name' => service,
          'namespace' => namespace
        },
        'spec' => {
          'selector' => {
            'matchLabels' => {
              'app' => service
            }
          },
          'replicas' => 1,
          'strategy' => {
            'type' => 'RollingUpdate'
          },
          'template' => {
            'metadata' => {
              'labels' => {
                'app' => service
              }
            },
            'spec' => {
              'restartPolicy' => 'Always',
              'containers' => [
                {
                  'resources' => {
                    'requests' => {},
                    'limits' => {
                      'cpu' => '250m',
                      'memory' => '250M'
                    }
                  },
                  'imagePullPolicy' => 'Always',
                  'image' => image,
                  'name' => service,
                  'ports' => [
                    { 'containerPort' => 80 }
                  ]
                }
              ]
            }
          }
        }
      }
    end
  end
end