require_relative 'base'

module Templates
  class Namespace < Base
    def file_name
      'namespace'
    end

    def hash
      {
        'kind' => 'Namespace',
        'apiVersion' => 'v1',
        'metadata' => {
          'name' => namespace
        } 
      }
    end
  end
end