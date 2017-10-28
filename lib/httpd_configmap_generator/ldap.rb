module HttpdConfigmapGenerator
  class Ldap < Base
    AUTHCONFIG_COMMAND = "/usr/sbin/authconfig".freeze
    LDAP_MODES = %w(ldap ldaps).freeze

    AUTH = {
      :type    => "external",
      :subtype => "ldap"
    }.freeze

    def required_options
      super.merge(
        :cert_file   => { :description => "Cert File" },
        :ldap_host   => { :description => "LDAP Directory Host FQDN" },
        :ldap_mode   => { :description => "ldap | ldaps" },
        :ldap_basedn => { :description => "LDAP Directory Base DN" },
      )
    end

    def optional_options
      super.merge(
        :ldap_group_name         => { :description => "LDAP Directory Group Name",
                                      :default     => "cn" },
        :ldap_group_member       => { :description => "Attribute containing the names of the group's members",
                                      :default     => "member" },
        :ldap_group_object_class => { :description => "The object class of a group entry in LDAP",
                                      :default     => "groupOfNames" },
        :ldap_id_use_start_tls   => { :description => "Connection use tls?",
                                      :default     => true },
        :ldap_port               => { :description => "LDAP Directory Port" },
        :ldap_tls_reqcert        => { :description => "The checks to perform on server certificates.",
                                      :default     => "allow" },
        :ldap_user_gid_number    => { :description => "LDAP attribute corresponding to the user's gid",
                                      :default     => "gidNumber" },
        :ldap_user_name          => { :description => "LDAP Directory User Name",
                                      :default     => "cn"},
        :ldap_user_object_class  => { :description => "Object class of a user entry in LDAP",
                                      :default     => "posixAccount" },
        :ldap_user_uid_number    => { :description => "LDAP attribute corresponding to the user's id",
                                      :default     => "uidNumber" },
        :ldap_user_search_base   => { :description => "The user DN search scope" },
        :ldap_group_search_base  => { :description => "The group DN search scope" },
        :support_non_posix       => { :description => "Suppoert non-posix user records",
                                      :default     => false },
      )
    end

    def persistent_files
      %w(/etc/nsswitch.conf
         /etc/openldap/ldap.conf
         /etc/pam.d/fingerprint-auth-ac
         /etc/pam.d/httpd-auth
         /etc/pam.d/password-auth-ac
         /etc/pam.d/postlogin-ac
         /etc/pam.d/smartcard-auth-ac
         /etc/pam.d/system-auth-ac
         /etc/sssd/sssd.conf
         /etc/sysconfig/authconfig
         /etc/sysconfig/network) + [opts[:cert_file]]
    end

    def configure(opts)
      update_hostname(opts[:host])

      init_search_base
      run_auth_config
      configure_pam
      configure_sssd
      chmod_chown_cert_file
      config_map = ConfigMap.new(opts)
      config_map.generate(AUTH[:type], realm, persistent_files)
      config_map.save(opts[:output])
    rescue => err
      log_command_error(err)
      raise err
    end

    def unconfigure
      return unless configured?
      raise "Unable to unconfigure authentication against LDAP"
    end

    def configured?
      File.exist?(SSSD_CONFIG)
    end

    def domain
      opts[:ldap_basedn].split(",").collect do |p|
        p.split('dc=')[1]
      end.compact.join('.')
    end

    private

    def ldapserver_url
      opts[:ldap_port] ||= opts[:ldap_mode].downcase == "ldaps" ? 636 : 389
      "#{opts[:ldap_mode]}://#{opts[:ldap_host]}:#{opts[:ldap_port]}"
    end

    def init_search_base
      opts[:ldap_user_search_base] = opts[:ldap_basedn] if opts[:ldap_user_search_base]  == ""
      opts[:ldap_group_search_base] = opts[:ldap_basedn] if opts[:ldap_group_search_base] == ""
    end

    def configure_sssd
      info_msg("Configuring SSSD Service")
      sssd = Sssd.new(opts)
      sssd.load(SSSD_CONFIG)

      sssd.configure_domain("default")
      domain_section = sssd.section("domain/default")
      domain_section["ldap_group_member"] = opts[:ldap_group_member]
      domain_section["ldap_group_name"] = opts[:ldap_group_name]
      domain_section["ldap_group_object_class"] = opts[:ldap_group_object_class]
      domain_section["ldap_group_search_base"] = opts[:ldap_group_search_base]
      domain_section["ldap_id_use_start_tls"] = opts[:ldap_id_use_start_tls]
      domain_section["ldap_network_timeout"] = "3"
      domain_section["ldap_pwd_policy"] = "none"
      domain_section["ldap_tls_cacert"] = opts[:cert_file]
      domain_section["ldap_tls_reqcert"] = opts[:ldap_tls_reqcert]
      domain_section["ldap_user_gid_number"] = opts[:ldap_user_gid_number]
      domain_section["ldap_user_name"] = opts[:ldap_user_name]
      domain_section["ldap_user_object_class"] = opts[:ldap_user_object_class]
      domain_section["ldap_user_search_base"] = opts[:ldap_user_search_base]
      domain_section["ldap_user_uid_number"] = opts[:ldap_user_uid_number]
      domain_section.delete("ldap_tls_cacertdir")

      sssd_section = sssd.section("sssd")
      sssd_section["config_file_version"] = "2"
      sssd_section["domains"] = domain
      sssd_section["default_domain_suffix"] = domain
      sssd_section["sbus_timeout"] = "30"
      sssd_section["services"] = "nss, pam, ifp"

      sssd.add_service("pam")

      sssd.configure_ifp

      if opts[:support_non_posix]
        sssd.section("pam")["pam_app_services"] = "httpd-auth"

        debug_msg("- Setting application section to [application/#{domain}]")
        domain_section.key = "application/#{domain}"

        debug_msg("- Adding domain section to [domain/#{domain}]")
        sssd.section("domain/#{domain}")
      else
        debug_msg("- Setting domain section to [domain/#{domain}]")
        domain_section.key = "domain/#{domain}"
      end

      debug_msg("- Creating #{SSSD_CONFIG}")
      sssd.save(SSSD_CONFIG)
    end

    def chmod_chown_cert_file
      FileUtils.chown('root', 'root', opts[:cert_file])
      FileUtils.chmod(0o600, opts[:cert_file])
    end

    def run_auth_config
      params = {
        :ldapserver=        => ldapserver_url,
        :ldapbasedn=        => opts[:ldap_basedn],
        :enablesssd         => nil,
        :enablesssdauth     => nil,
        :enablelocauthorize => nil,
        :enableldap         => nil,
        :enableldapauth     => nil,
        :disableldaptls     => nil,
        :enablerfc2307bis   => nil,
        :enablecachecreds   => nil,
        :update             => nil
      }

      command_run!(AUTHCONFIG_COMMAND, :params => params)
    end

    def validate_options(opts)
      super(opts)
      raise "ldap-mode must be one of #{LDAP_MODES.join(", ")}" unless LDAP_MODES.include?(opts[:ldap_mode].downcase)
      raise "TLS certificate File #{opts[:cert_file]} not found" unless File.exist?(opts[:cert_file])
    end
  end
end
