require "httpd_configmap_generator/version"
require "httpd_configmap_generator/base"
require "httpd_configmap_generator/active_directory"
require "httpd_configmap_generator/ipa"
require "httpd_configmap_generator/ldap"
require "httpd_configmap_generator/saml"
require "httpd_configmap_generator/oidc"
require "httpd_configmap_generator/update"
require "httpd_configmap_generator/export"
require "more_core_extensions/core_ext/hash"

module HttpdConfigmapGenerator
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
