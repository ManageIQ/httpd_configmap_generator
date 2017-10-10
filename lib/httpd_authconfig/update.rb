module HttpdAuthConfig
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
        :addfile => { :description => "Add file to config map",
                      :multi       => true }
      )
    end

    def update(opts)
      validate_options(opts)
      @opts = opts
      config_map = read_configmap(opts[:input])
      configmap_addfiles(config_map, opts[:addfile]) if opts[:addfile].present?
      save_configmap(config_map, opts[:output])
    rescue => err
      log_command_error(err)
      raise err
    end

    private

    def validate_options(options)
      raise "Input configuration map #{options[:input]} does not exist" unless File.exist?(options[:input])
      raise "Must specify at least one file to add via --addfile" if options[:addfile].nil?
    end
  end
end
