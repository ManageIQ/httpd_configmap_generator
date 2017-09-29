require "pathname"
require "httpd/auth_config/base/file"
require "httpd/auth_config/base/config"
require "httpd/auth_config/base/configmap"
require "httpd/auth_config/base/network"
require "httpd/auth_config/base/principal"
require "httpd/auth_config/base/sssd"
require "httpd/auth_config/base/pam"
require "httpd/auth_config/base/kerberos"

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
      attr_accessor :timestamp

      def initialize(opts = {})
        @opts = opts
        @realm = @domain = nil
        @timestamp = Time.now.strftime(TIMESTAMP_FORMAT)
      end

      def auth
        {
        }
      end
    end
  end
end
