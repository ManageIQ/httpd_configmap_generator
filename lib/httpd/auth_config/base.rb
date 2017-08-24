module Httpd
  module AuthConfig
    def self.new_config(auth_type)
      auth_class(auth_type).new
    end

    private

    def self.auth_class(auth_type)
      auth_type = auth_type.camelize
      raise "Invalid Authentication Type #{auth_type} specified" unless const_defined?(auth_type, false)
      const_get(auth_type, false)
    end
  end
end
