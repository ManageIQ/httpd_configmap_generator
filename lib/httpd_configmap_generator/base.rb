require "pathname"
require "httpd_configmap_generator/base/command"
require "httpd_configmap_generator/base/config"
require "httpd_configmap_generator/base/config_map"
require "httpd_configmap_generator/base/file"
require "httpd_configmap_generator/base/kerberos"
require "httpd_configmap_generator/base/network"
require "httpd_configmap_generator/base/pam"
require "httpd_configmap_generator/base/principal"
require "httpd_configmap_generator/base/sssd"

module HttpdConfigmapGenerator
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

    def initialize(opts = {})
      @opts = opts
      @realm = @domain = nil
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
        :host   => { :description => "Application Domain",
                     :short       => "-h" },
        :output => { :description => "Configuration map file to create",
                     :short       => "-o" }
      }
    end

    def optional_options
      {
        :force => { :description => "Force configuration if configured already",
                    :short       => "-f",
                    :default     => false },
        :debug => { :description => "Enable debugging",
                    :short       => "-d",
                    :default     => false }
      }
    end

    def run_configure(opts)
      validate_options(opts)
      @opts = opts
      unconfigure if configured? && opts[:force]
      raise "#{self.class.name} Already Configured" if configured?
      unless ENV["HTTPD_AUTH_TYPE"]
        raise "Not running in httpd_configmap_generator container - Skipping #{self.class.name} configuration"
      end
      configure(opts)
    end

    def validate_options(_options)
      nil
    end
  end
end
