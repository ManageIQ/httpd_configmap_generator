module HttpdConfigmapGenerator
  class Base
    module Kerberos
      def enable_kerberos_dns_lookups
        info_msg("Configuring Kerberos DNS Lookups")
        config_file_backup(KERBEROS_CONFIG_FILE)
        krb5config = File.read(KERBEROS_CONFIG_FILE)
        krb5config[/(\s*)dns_lookup_kdc(\s*)=(\s*)(.*)/, 4] = 'true'   if krb5config[/(\s*)dns_lookup_kdc(\s*)=/]
        krb5config[/(\s*)dns_lookup_realm(\s*)=(\s*)(.*)/, 4] = 'true' if krb5config[/(\s*)dns_lookup_realm(\s*)=/]
        debug_msg("- Updating #{KERBEROS_CONFIG_FILE}")
        File.write(KERBEROS_CONFIG_FILE, krb5config)
      end
    end
  end
end
