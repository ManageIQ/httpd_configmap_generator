module HttpdAuthConfig
  class Export < Base
    def required_options
      {
        :input  => { :description => "Input config map file",
                     :short       => "-i" },
        :file   => { :description => "Config map file to export",
                     :short       => "-l" },
        :output => { :description => "The output file being exported",
                     :short       => "-o" }
      }
    end

    def export(opts)
      validate_options(opts)
      @opts = opts
      config_map = read_configmap(opts[:input])
      configmap_exportfile(config_map, opts[:file], opts[:output])
    rescue => err
      log_command_error(err)
      raise err
    end

    private

    def validate_options(options)
      raise "Input configuration map #{options[:input]} does not exist" unless File.exist?(options[:input])
    end
  end
end
