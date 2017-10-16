module HttpdConfigmapGenerator
  class Update < Base
    def required_options
      {
        :input  => { :description => "Input config map file",
                     :short       => "-i" },
        :output => { :description => "Output config map file",
                     :short       => "-o" }
      }
    end

    def optional_options
      super.merge(
        :add_file => { :description => "Add file to config map",
                       :short       => "-a",
                       :multi       => true }
      )
    end

    def update(opts)
      validate_options(opts)
      @opts = opts
      config_map = ConfigMap.new(opts)
      config_map.load(opts[:input])
      config_map.add_files(opts[:add_file])
      config_map.save(opts[:output])
    rescue => err
      log_command_error(err)
      raise err
    end

    private

    def validate_options(options)
      raise "Input configuration map #{options[:input]} does not exist" unless File.exist?(options[:input])
      raise "Must specify at least one file to add via --add-file" if options[:add_file].nil?
    end
  end
end
