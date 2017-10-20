module HttpdConfigmapGenerator
  class Base
    def config_file_backup(path, timestamp)
      FileUtils.copy(path, "#{path}.#{timestamp}") if File.exist?(path)
    end
  end
end
