module Httpd
  module AuthConfig
    class Base
      def  enable_kerberos_dns_lookups
        FileUtils.copy(KERBEROS_CONFIG_FILE, "#{KERBEROS_CONFIG_FILE}.miqbkp")
        krb5config = File.read(KERBEROS_CONFIG_FILE)
        krb5config[/(\s*)dns_lookup_kdc(\s*)=(\s*)(.*)/, 4] = 'true'
        krb5config[/(\s*)dns_lookup_realm(\s*)=(\s*)(.*)/, 4] = 'true'
        File.write(KERBEROS_CONFIG_FILE, krb5config)
      end
    end
  end
end
