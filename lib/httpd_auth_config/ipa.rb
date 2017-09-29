module HttpdAuthConfig
  class Ipa < Base
    IPA_INSTALL_COMMAND  = "/usr/sbin/ipa-client-install".freeze
    IPA_GETKEYTAB        = "/usr/sbin/ipa-getkeytab".freeze

    def auth
      {
        :type          => "ipa",
        :configuration => "external"
      }
    end

    def required_options
      super.merge(
        :ipaserver   => { :description => "IPA Server Fqdn"     },
        :ipapassword => { :description => "IPA Server Password" }
      )
    end

    def optional_options
      super.merge(
        :ipaprincipal => { :description => "IPA Server Principal", :default => "admin" },
        :ipadomain    => { :description => "Domain of IPA Server" },
        :iparealm     => { :description => "Realm of IPA Server"  }
      )
    end

    def persistent_files
      %w(
        /etc/http.keytab
        /etc/ipa/ca.crt
        /etc/ipa/default.conf
        /etc/ipa/nssdb/cert8.db
        /etc/ipa/nssdb/key3.db
        /etc/ipa/nssdb/pwdfile.txt
        /etc/ipa/nssdb/secmod.db
        /etc/krb5.conf
        /etc/krb5.keytab
        /etc/nsswitch.conf
        /etc/openldap/ldap.conf
        /etc/pam.d/fingerprint-auth-ac
        /etc/pam.d/httpd-auth
        /etc/pam.d/password-auth-ac
        /etc/pam.d/postlogin-ac
        /etc/pam.d/smartcard-auth-ac
        /etc/pam.d/system-auth-ac
        /etc/pki/ca-trust/source/ipa.p11-kit
        /etc/sssd/sssd.conf
        /etc/sysconfig/authconfig
        /etc/sysconfig/network
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
      unless ENV["AUTH_CONFIG_DIRECTORY"]
        puts "Kerberos Principal: #{service.name}"
        puts "Not running in auth-config container - Skipping #{IPA_INSTALL_COMMAND}"
        return
      end
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
      configure_ipa_http_service
      configure_pam
      configure_sssd
      enable_kerberos_dns_lookups
      generate_configmap(auth[:type], auth[:configuration], realm, persistent_files)
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

    private

    def configure_ipa_http_service
      AwesomeSpawn.run!("/usr/bin/kinit", :params => [:principal], :stdin_data => opts[:password])
      service = Principal.new(:hostname => opts[:host], :realm => realm, :service => "HTTP")
      service.register
      AwesomeSpawn.run!(IPA_GETKEYTAB, :params => {"-s" => opts[:ipaserver], "-k" => HTTP_KEYTAB, "-p" => service.name})
      FileUtils.chown(APACHE_USER, nil, HTTP_KEYTAB)
      FileUtils.chmod(0o600, HTTP_KEYTAB)
    end
  end
end
