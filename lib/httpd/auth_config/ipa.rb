module Httpd
  module AuthConfig
    class Ipa < Base
      IPA_INSTALL_COMMAND  = "/usr/sbin/ipa-client-install".freeze
      IPA_GETKEYTAB        = "/usr/sbin/ipa-getkeytab".freeze

      def required_options
        Httpd::AuthConfig.required_options.merge(
          :ipaserver   => { :description => "IPA Server Fqdn"     },
          :ipapassword => { :description => "IPA Server Password" }
        )
      end

      def optional_options
        Httpd::AuthConfig.optional_options.merge(
          :ipaprincipal => { :description => "IPA Server Principal", :default => "admin" },
          :ipadomain    => { :description => "Domain of IPA Server" },
          :iparealm     => { :description => "Realm of IPA Server"  }
        )
      end

      def configure(opts)
        @opts = opts
        unconfigure if configured? && opts[:force]
        if configured?
          puts "#{self.class.name} Already Configured"
          return
        end
        service = Principal.new(:hostname => opts[:host], :realm => realm, :service => "HTTP")
        puts "Kerberos Principal: #{service.name} - Skipping #{IPA_INSTALL_COMMAND}"
        return
        AwesomeSpawn.run!(IPA_INSTALL_COMMAND,
                          :params => [
                            "-N", :force_join, :fixed_primary, :unattended, {
                              :realm=     => realm,
                              :domain=    => domain,
                              :server=    => opts[:ipaserver],
                              :principal= => opts[:principal],
                              :password=  => opts[:password]
                            }
                          ])
        enable_kerberos_dns_lookups
      end

      def configured?
        File.exist?(SSSD_CONFIG)
      end

      def unconfigure
        return unless configured?
        AwesomSpawn.run(IPA_INSTALL_COMMAND, :params => [:uninstall, :unattended])
      end

      def realm
        @realm ||= opts[:iparealm] if opts[:iparealm].present?
        @realm ||= domain
        @realm ||= super
        @realm = @realm.upcase
      end

      def domain
        @domain ||= opts[:ipadomain] if opts[:ipadomain].present?
        @domain ||= domain_from_host(opts[:ipaserver]) if opts[:ipaserver].present?
        @domain ||= super
        @domain
      end
    end
  end
end
