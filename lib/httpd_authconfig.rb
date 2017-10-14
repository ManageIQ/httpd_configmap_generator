require "httpd_authconfig/version"
require "httpd_authconfig/base"
require "httpd_authconfig/active_directory"
require "httpd_authconfig/ipa"
require "httpd_authconfig/saml"
require "httpd_authconfig/update"
require "httpd_authconfig/export"
require "more_core_extensions/core_ext/hash"

module HttpdAuthConfig
  def self.new_config(auth_type)
    auth_class(auth_type).new
  end

  def self.supported_auth_types
    constants.collect do |c|
      k = const_get(c)
      k::AUTH[:subtype] if k.kind_of?(Class) && k.constants.include?(:AUTH)
    end.compact
  end

  def self.auth_class(auth_type)
    require "active_support/core_ext/string" # for camelize

    auth_type = auth_type.tr('-', '_').camelize
    raise "Invalid Authentication Type #{auth_type} specified" unless const_defined?(auth_type, false)
    const_get(auth_type, false)
  end
end
