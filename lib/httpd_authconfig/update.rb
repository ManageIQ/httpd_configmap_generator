module HttpdAuthConfig
  class Update < Base
    def required_options
      {
        :input => { :description => "Input file",
                    :short       => "-i" }
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
      config_map = read_configmap(opts[:input])
      if opts[:addfile]
        opts[:addfile].each do |addfile|
          info_msg("Adding file #{addfile}")
        end
      end
      save_configmap(config_map, opts[:output])
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
