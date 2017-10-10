module HttpdAuthConfig
  class Saml < Base
    MELLON_CREATE_METADATA_COMMAND = "/usr/libexec/mod_auth_mellon/mellon_create_metadata.sh".freeze
    SAML2_CONFIG_DIRECTORY = "/etc/httpd/saml2".freeze
    MIQSP_METADATA_FILE = "#{SAML2_CONFIG_DIRECTORY}/miqsp-metadata.xml".freeze
    AUTH = {
      :type    => "saml",
      :subtype => "saml"
    }.freeze

    def required_options
      super
    end

    def optional_options
      super.merge(
        :idpserver      => { :description => "SAML Server Fqdn or IP" },
        :idpmetadataurl => { :description => "URL to use for fetching the idp-metadata" },
        :keycloakrealm  => { :description => "Keycloak Realm to use for fetching the idp-metadata"}
      )
    end

    def persistent_files
      %w(
        /etc/httpd/saml2/miqsp-key.key
        /etc/httpd/saml2/miqsp-cert.cert
        /etc/httpd/saml2/miqsp-metadata.xml
      )
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
      end
      config_map = generate_configmap(AUTH[:type], realm, persistent_files)
      save_configmap(config_map, opts[:output])
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
    end
  end
end
