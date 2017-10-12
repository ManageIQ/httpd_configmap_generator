module HttpdAuthConfig
  class Saml < Base
    MELLON_CREATE_METADATA_COMMAND = "/usr/libexec/mod_auth_mellon/mellon_create_metadata.sh".freeze
    SAML2_CONFIG_DIRECTORY = "/etc/httpd/saml2".freeze
    MIQSP_METADATA_FILE    = "#{SAML2_CONFIG_DIRECTORY}/miqsp-metadata.xml".freeze
    IDP_METADATA_FILE      = "#{SAML2_CONFIG_DIRECTORY}/idp-metadata.xml".freeze
    AUTH = {
      :type    => "saml",
      :subtype => "saml"
    }.freeze

    def required_options
      super
    end

    def optional_options
      super.merge(
        :keycloak_add_metadata => { :description => "Download and add the Keycloak metadata file",
                                    :default     => false },
        :keycloak_server       => { :description => "Keycloak Server Fqdn or IP" },
        :keycloak_realm        => { :description => "Keycloak Realm for this client"}
      )
    end

    def persistent_files
      file_list = %w(
        /etc/httpd/saml2/miqsp-key.key
        /etc/httpd/saml2/miqsp-cert.cert
        /etc/httpd/saml2/miqsp-metadata.xml
      )
      file_list += [IDP_METADATA_FILE] if opts[:keycloak_add_metadata]
      file_list
    end

    def configure(opts)
      update_hostname(opts[:host])
      Dir.mkdir(SAML2_CONFIG_DIRECTORY)
      Dir.chdir(SAML2_CONFIG_DIRECTORY) do
        command_run!(MELLON_CREATE_METADATA_COMMAND,
                     :params => [
                       "https://#{opts[:host]}",
                       "https://#{opts[:host]}/saml2"
                     ])
        rename_mellon_configfiles
        fetch_idp_metadata
      end
      config_map = ConfigMap.new(opts)
      config_map.generate(AUTH[:type], realm, persistent_files)
      config_map.save(opts[:output])
    rescue => err
      log_command_error(err)
      raise err
    end

    def configured?
      File.exist?(MIQSP_METADATA_FILE)
    end

    def unconfigure
      return unless configured?
      FileUtils.rm_rf(SAML2_CONFIG_DIRECTORY) if Dir.exist?(SAML2_CONFIG_DIRECTORY)
    end

    private

    def validate_options(options)
      super(options)
      if options[:keycloak_add_metadata]
        if options[:keycloak_server] == "" || options[:keycloak_realm] == ""
          raise "Must specify both keycloak-server and keycloak-realm for fetching the IdP metadata file"
        end
      end
    end

    def rename_mellon_configfiles
      info_msg("Renaming mellon config files")
      Dir.chdir(SAML2_CONFIG_DIRECTORY) do
        Dir.glob("https_*.*") do |mellon_file|
          miq_saml2_file = nil
          case mellon_file
          when /^https_.*\.key$/
            miq_saml2_file = "miqsp-key.key"
          when /^https_.*\.cert$/
            miq_saml2_file = "miqsp-cert.cert"
          when /^https_.*\.xml$/
            miq_saml2_file = "miqsp-metadata.xml"
          end
          if miq_saml2_file
            debug_msg("- renaming #{mellon_file} to #{miq_saml2_file}")
            File.rename(mellon_file, miq_saml2_file)
          end
        end
      end
    end

    def fetch_idp_metadata
      if opts[:keycloak_add_metadata]
        source_file  = "http://#{opts[:keycloak_server]}:8080"
        source_file += "/auth/realms/#{opts[:keycloak_realm]}/protocol/saml/descriptor"
        fetch_network_file(source_file, IDP_METADATA_FILE)
      end
    end
  end
end
