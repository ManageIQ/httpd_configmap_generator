require "socket"               

module HttpdConfigmapGenerator
  class Ipa < Base
    IPA_INSTALL_COMMAND  = "/usr/sbin/ipa-client-install".freeze
    IPA_GETKEYTAB        = "/usr/sbin/ipa-getkeytab".freeze
    AUTH = {
      :type    => "external",
      :subtype => "ipa"
    }.freeze

    def required_options
      super.merge(
        :ipa_server   => { :description => "IPA Server FQDN"     },
        :ipa_password => { :description => "IPA Server Password" }
      )
    end

    def optional_options
      super.merge(
        :ipa_principal => { :description => "IPA Server Principal", :default => "admin" },
        :ipa_domain    => { :description => "Domain of IPA Server" },
        :ipa_realm     => { :description => "Realm of IPA Server" }
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
      opts[:host] = get_canonical_hostname(opts[:host])
      update_hostname(opts[:host])
      command_run!(IPA_INSTALL_COMMAND,
                   :params => [
                     "-N", :force_join, :fixed_primary, :unattended, {
                       :realm=     => realm,
                       :domain=    => domain,
                       :server=    => opts[:ipa_server],
                       :principal= => opts[:ipa_principal],
                       :password=  => opts[:ipa_password]
                     }
                   ])
      configure_ipa_http_service
      configure_pam
      configure_sssd
      enable_kerberos_dns_lookups
      config_map = ConfigMap.new(opts)
      config_map.generate(AUTH[:type], realm, persistent_files)
      config_map.save(opts[:output])
    rescue => err
      log_command_error(err)
      raise err
    end

    def configured?
      File.exist?(SSSD_CONFIG)
    end

    def unconfigure
      return unless configured?
      command_run(IPA_INSTALL_COMMAND, :params => [:uninstall, :unattended])
    end

    def realm
      @realm ||= opts[:ipa_realm] if opts[:ipa_realm].present?
      @realm ||= domain
      @realm ||= super
      @realm = @realm.upcase
    end

    def domain
      @domain ||= opts[:ipa_domain] if opts[:ipa_domain].present?
      @domain ||= domain_from_host(opts[:ipa_server]) if opts[:ipa_server].present?
      @domain ||= super
      @domain
    end

    private

    def configure_sssd
      info_msg("Configuring SSSD Service")
      sssd = Sssd.new(opts)
      sssd.load(SSSD_CONFIG)
      sssd.configure_domain(domain)
      sssd.add_service("pam")
      sssd.configure_ifp
      debug_msg("- Creating #{SSSD_CONFIG}")
      sssd.save(SSSD_CONFIG)
    end

    def configure_ipa_http_service
      info_msg("Configuring IPA HTTP Service")
      command_run!("/usr/bin/kinit", :params => [opts[:ipa_principal]], :stdin_data => opts[:ipa_password])
      service = Principal.new(:hostname => opts[:host], :realm => realm, :service => "HTTP")
      service.register
      debug_msg("- Fetching #{HTTP_KEYTAB}")
      command_run!(IPA_GETKEYTAB, :params => {"-s" => opts[:ipa_server], "-k" => HTTP_KEYTAB, "-p" => service.name})
      FileUtils.chown(APACHE_USER, nil, HTTP_KEYTAB)
      FileUtils.chmod(0o600, HTTP_KEYTAB)
    end

    def get_canonical_hostname(hostname)
      Socket.gethostbyname(hostname)[0]
    rescue SocketError
      hostname
    end
  end
end
