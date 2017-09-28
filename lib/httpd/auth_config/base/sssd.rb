module Httpd
  module AuthConfig
    class Base
      def configure_sssd
        config = config_file_read(SSSD_CONFIG)
        configure_sssd_domain(config, domain)
        configure_sssd_service(config)
        configure_sssd_ifp(config)
        config_file_write(config, SSSD_CONFIG, timestamp)
      end

      def configure_sssd_domain(config, domain)
        ldap_user_extra_attrs = LDAP_ATTRS.keys.join(", ")
        if config.include?("ldap_user_extra_attrs = ")
          eattern = "[domain/#{Regexp.escape(domain)}](\n.*)+ldap_user_extra_attrs = (.*)"
          config[/#{pattern}/, 2] = ldap_user_extra_attrs
        else
          pattern = "[domain/#{Regexp.escape(domain)}].*(\n)"
          config[/#{pattern}/, 1] = "\nldap_user_extra_attrs = #{ldap_user_extra_attrs}\n"
        end

        pattern = "[domain/#{Regexp.escape(domain)}].*(\n)"
        config[/#{pattern}/, 1] = "\nentry_cache_timeout = 600\n"
      end

      def configure_sssd_service(config)
        services = config.match(/\[sssd\](\n.*)+services = (.*)/)[2]
        services = "#{services}, ifp" unless services.include?("ifp")
        config[/\[sssd\](\n.*)+services = (.*)/, 2] = services
      end

      def configure_sssd_ifp(config)
        user_attributes = LDAP_ATTRS.keys.collect { |k| "+#{k}" }.join(", ")
        ifp_config      = "
  allowed_uids = #{APACHE_USER}, root
  user_attributes = #{user_attributes}
"
        if config.include?("[ifp]")
          if config[/\[ifp\](\n.*)+user_attributes = (.*)/]
            config[/\[ifp\](\n.*)+user_attributes = (.*)/, 2] = user_attributes
          else
            config[/\[ifp\](\n)/, 1] = ifp_config
          end
        else
          config << "\n[ifp]#{ifp_config}\n"
        end
      end
    end
  end
end
