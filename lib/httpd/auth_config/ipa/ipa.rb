module Httpd
  module AuthConfig
    class Ipa
      def required_options
        Httpd::AuthConfig.required_options.merge(
          :ipaserver    => "IPA Server Fqdn",
          :ipaprincipal => "IPA Server Principal",
          :ipapassword  => "IPA Server Password"
        )
      end

      def optional_options
        Httpd::AuthConfig.optional_options.merge(
          :ipadomain => "Domain of IPA Server",
          :iparealm  => "Realm of IPA Server"
        )
      end
    end
  end
end
