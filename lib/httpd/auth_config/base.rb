require 'pathname'

module Httpd
  module AuthConfig
    class Base
      APACHE_USER          = "apache".freeze
      HTTP_KEYTAB          = "/etc/http.keytab".freeze
      IPA_COMMAND          = "/usr/bin/ipa".freeze
      KERBEROS_CONFIG_FILE = "/etc/krb5.conf".freeze
      LDAP_ATTRS           = {
        "mail"        => "REMOTE_USER_EMAIL",
        "givenname"   => "REMOTE_USER_FIRSTNAME",
        "sn"          => "REMOTE_USER_LASTNAME",
        "displayname" => "REMOTE_USER_FULLNAME",
        "domainname"  => "REMOTE_USER_DOMAIN"
      }.freeze
      PAM_CONFIG           = "/etc/pam.d/httpd-auth".freeze
      SSSD_CONFIG          = "/etc/sssd/sssd.conf".freeze
      TIMESTAMP_FORMAT     = "%Y%m%d_%H%M%S".freeze

      attr_accessor :opts
      attr_accessor :realm
      attr_accessor :domain

      def initialize(opts = {})
        @opts = opts
        @realm = @domain = nil
      end

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
        domain.upcase
      end

      def domain
        opts[:host].gsub(/^([^.]+\.)/, '') if opts[:host].present? && opts[:host].include?('.')
      end

      def template_directory
        @template_directory ||= begin
          Pathname.new(Bundler.locked_gems.specs.select { |g| g.name == "httpd-authconfig" }.first.gem_dir).join("templates")
        end
      end

      def host_reachable?(host)
        require 'net/ping'
        Net::Ping::External.new(host).ping
      end
    end
  end
end
