require 'yaml'

module Templates
  class Base
    attr_reader :service, :namespace, :image
    
    def initialize(service:, namespace:, image: nil)
      @service = service
      @namespace = namespace
      @image = image
    end

    def directory
      [service, 'overlays', namespace]
    end

    def file
      { path => yaml }
    end

    def path
      "#{directory.push(file_name).join('/')}.yaml"
    end

    def yaml
      hash.to_yaml
    end

    def create_file!
      directory.each_with_object([]) do |d,o|
        o << d
        folder = o.join('/')
        Dir.mkdir folder unless File.exist?(folder)
      end
      File.open(path, "w") { |file| file.write(yaml) }
    end
  end
end