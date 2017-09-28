require "pathname"

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
    end
  end
end
