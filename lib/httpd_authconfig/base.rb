require "pathname"
require "httpd_authconfig/base/file"
require "httpd_authconfig/base/config"
require "httpd_authconfig/base/configmap"
require "httpd_authconfig/base/network"
require "httpd_authconfig/base/principal"
require "httpd_authconfig/base/sssd"
require "httpd_authconfig/base/pam"
require "httpd_authconfig/base/kerberos"

module HttpdAuthConfig
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

    def err_msg(msg)
      STDERR.puts(msg)
    end

    def info_msg(msg)
      STDOUT.puts(msg)
    end

    def debug_msg(msg)
      STDOUT.puts(msg) if opts[:debug]
    end

    def required_options
      {
        :host   => { :description => "Application Domain" },
        :output => { :description => "Output file",
                     :short       => "-o" }
      }
    end

    def optional_options
      {
        :force => { :description => "Force configuration if configured already",
                    :default     => false },
        :debug => { :description => "Enabling debugging",
                    :short       => "-d",
                    :default     => false }
      }
    end

    # NOTE: see if this can't be done by Trollop
    def validate_options(options)
      output_file = Pathname.new(options[:output]).cleanpath.to_s
      raise "Output file must live under /tmp" unless output_file.start_with?("/tmp/")
    end
  end
end
