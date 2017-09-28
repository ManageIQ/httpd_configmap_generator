require "pathname"

module Httpd
  module AuthConfig
    class Base
      def config_file_read(path)
        File.read(path)
      end

      def config_file_write(config, path, timestamp)
        FileUtils.copy(path, "#{path}.#{timestamp}") if File.exist?(path)
        File.open(path, "w") { |f| f.write(config) }
      end
    end
  end
end
