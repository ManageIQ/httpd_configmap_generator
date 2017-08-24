module Httpd
  module AuthConfig
    class Ipa
      def self.options_required
        super.merge(
          :ipaserver    => "IPA Server Fqdn",
          :ipaprincipal => "IPA Server Principal",
          :ipapassword  => "IPA Server Password"
        )
      end

      def self.options_optional
        super.merge(
          :ipadomain => "Domain of IPA Server",
          :iparealm  => "Realm of IPA Server"
        )
      end
    end
  end
end
