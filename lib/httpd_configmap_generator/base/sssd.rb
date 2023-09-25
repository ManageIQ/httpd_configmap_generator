require 'iniparse'

module HttpdConfigmapGenerator
  class Sssd < Base
    attr_accessor :sssd
    attr_accessor :opts

    def initialize(opts = {})
      @opts = opts
      @sssd = nil
    end

    def load(file_path)
      @sssd = IniParse.open(file_path)
    end

    def save(file_path)
      return unless sssd
      config_file_backup(file_path)
      info_msg("Saving SSSD to #{file_path}")
      sssd.save(file_path)
    end

    def configure_domain(domain)
      domain = section("domain/#{domain}")
      domain["ldap_user_extra_attrs"] = LDAP_ATTRS.keys.join(", ")
      domain["entry_cache_timeout"] = 600
    end

    def add_service(service)
      services = section("sssd")["services"]
      services = (services.split(",").map(&:strip) | [service]).join(", ")
      sssd.section("sssd")["services"] = services
      sssd.section(service)
    end

    def configure_ifp
      add_service("ifp")
      ifp = section("ifp")
      ifp["allowed_uids"] = "#{APACHE_USER}, root, manageiq"
      ifp["user_attributes"] = LDAP_ATTRS.keys.collect { |k| "+#{k}" }.join(", ")
    end

    def section(key)
      if key =~ /^domain\/.*$/
        key = sssd.entries.collect(&:key).select { |k| k.downcase == key.downcase }.first || key
      end
      sssd.section(key)
    end
  end
end
