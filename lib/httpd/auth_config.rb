require "httpd/auth_config/version"
require "httpd/auth_config/options"
require "httpd/auth_config/base"
require "httpd/auth_config/ipa"
require "httpd/auth_config/principal"

module Httpd
  module AuthConfig
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
    private_class_method :auth_class
  end
end
