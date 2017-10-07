require "httpd_authconfig/version"
require "httpd_authconfig/base"
require "httpd_authconfig/ipa"

module HttpdAuthConfig
  def self.new_config(auth_type)
    auth_class(auth_type).new
  end

  def self.supported_auth_types
    %w(ipa)
  end

  def self.auth_class(auth_type)
    require "active_support/core_ext/string" # for camelize

    auth_type = auth_type.camelize
    raise "Invalid Authentication Type #{auth_type} specified" unless const_defined?(auth_type, false)
    const_get(auth_type, false)
  end
end
