require "active_support"
require "active_support/core_ext" # for Time.current

module HttpdConfigmapGenerator
  class Base
    def config_file_backup(path)
      if File.exist?(path)
        timestamp = Time.current.strftime(TIMESTAMP_FORMAT)
        FileUtils.copy(path, "#{path}.#{timestamp}")
      end
    end
  end
end
