module HttpdConfigmapGenerator
  class Oidc < Base

    AUTH = {
      :type    => "openid-connect",
      :subtype => "oidc"
    }.freeze

    def required_options
      super.merge(
        :oidc_url           => { :description => "OpenID-Connect Provider URL", 
                                 :short       => "-u" },
        :oidc_client_id     => { :description => "OpenID-Connect Provider Client ID",
                                 :short       => "-i" },
        :oidc_client_secret => { :description => "OpenID-Connect Provider Client Secret",
                                 :short       => "-s" },
      )
    end

    def configure(opts)
      auth_oidc_data = {}
      auth_oidc_data["auth-oidc-provider-metadata-url"] = opts[:oidc_url]
      auth_oidc_data["auth-oidc-client-id"] = opts[:oidc_client_id]
      auth_oidc_data["auth-oidc-client-secret"] = opts[:oidc_client_secret]

      config_map = ConfigMap.new(opts)
      config_map.generate(AUTH[:type], nil, nil, auth_oidc_data )
      config_map.save(opts[:output])
    rescue => err
      log_command_error(err)
      raise err
    end

    def validate_options(opts)
      super(opts)
    end

    def configured?
      false
    end

    def unconfigure
      return unless configured?
    end

  end
end

