module HttpdConfigmapGenerator
  class ActiveDirectory < Base
    REALM_COMMAND        = "/usr/sbin/realm".freeze
    KERBEROS_KEYTAB_FILE = "/etc/krb5.keytab".freeze
    AUTH = {
      :type    => "active-directory",
      :subtype => "active-directory"
    }.freeze

    def required_options
      super.merge(
        :ad_domain   => { :description => "Active Directory Domain"   },
        :ad_user     => { :description => "Active Directory User"     },
        :ad_password => { :description => "Active Directory Password" }
      )
    end

    def optional_options
      super.merge(
        :ad_realm  => { :description => "Active Directory Realm"  },
        :ad_server => { :description => "Active Directory Server" }
      )
    end

    def persistent_files
      %w(
        /etc/krb5.keytab
        /etc/krb5.conf
        /etc/nsswitch.conf
        /etc/openldap/ldap.conf
        /etc/pam.d/fingerprint-auth-ac
        /etc/pam.d/httpd-auth
        /etc/pam.d/password-auth-ac
        /etc/pam.d/postlogin-ac
        /etc/pam.d/smartcard-auth-ac
        /etc/pam.d/system-auth-ac
        /etc/resolv.conf
        /etc/sssd/sssd.conf
        /etc/sysconfig/authconfig
      )
    end

    def configure(opts)
      update_hostname(opts[:host])
      join_ad_realm
      realm_permit_all
      configure_pam
      configure_sssd
      update_kerberos_keytab_permissions
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
    end

    def realm
      @realm ||= opts[:ad_realm] if opts[:ad_realm].present?
      @realm ||= domain
      @realm ||= super
      @realm = @realm.upcase
    end

    def domain
      @domain ||= opts[:ad_domain] if opts[:ad_domain].present?
      @domain ||= super
      @domain
    end

    private

    def configure_sssd
      info_msg("Configuring SSSD Service")
      sssd = Sssd.new(opts)
      sssd.load(SSSD_CONFIG)
      sssd.configure_domain(domain)
      sssd.section("domain/#{domain}")["ad_server"] = opts[:ad_server] if opts[:ad_server].present?
      sssd.section("sssd")["domains"] = domain
      sssd.section("sssd")["default_domain_suffix"] = domain
      sssd.add_service("pam")
      sssd.configure_ifp
      debug_msg("- Creating #{SSSD_CONFIG}")
      sssd.save(SSSD_CONFIG)
    end

    def join_ad_realm
      info_msg("Joining the AD Realm ...")
      debug_msg(" - realm join #{realm} ...")
      command_run!(REALM_COMMAND, :params => ["join", domain, "-U", opts[:ad_user]], :stdin_data => opts[:ad_password])
    end

    def realm_permit_all
      info_msg("Allowing AD Users to Login ...")
      command_run!(REALM_COMMAND, :params => ["permit", "--all"])
    end

    def update_kerberos_keytab_permissions
      info_msg("Updating Kerberos keytab permissions ...")
      FileUtils.chown("apache", "root", KERBEROS_KEYTAB_FILE)
      FileUtils.chmod(0o640, KERBEROS_KEYTAB_FILE)
    end
  end
end
