module Httpd
  module AuthConfig
    def self.options_required
      {
        :host => "Application Domain"
      }
    end

    def self.options_optional
      {
      }
    end
  end
end
