module Httpd
  module AuthConfig
    class Ipa < Base
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
        service = Principal.new(:hostname => opts[:host], :realm => realm, :service => "HTTP")
        puts "Kerberos Principal: #{service.name}"
      end

      def realm
        @realm ||= opts[:iparealm] if opts[:iparealm].present?
        @realm ||= domain
        @realm ||= super
        @realm = @realm.upcase
      end

      def domain
        @domain ||= opts[:ipadomain] if opts[:ipadomain].present?
        @domain ||= super
        @domain
      end
    end
  end
end
