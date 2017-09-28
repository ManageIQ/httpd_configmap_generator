module Httpd
  module AuthConfig
    def self.required_options
      {
        :host => { :description => "Application Domain" }
      }
    end

    def self.optional_options
      {
      }
    end
  end
end
