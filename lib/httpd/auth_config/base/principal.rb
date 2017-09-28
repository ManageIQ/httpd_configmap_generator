require "awesome_spawn"

module Httpd
  module AuthConfig
    class Principal < Base
      attr_accessor :hostname
      attr_accessor :realm        # EXAMPLE.COM
      attr_accessor :service      # HTTP

      attr_accessor :name         # Kerberos principal name generated

      def initialize(options = {})
        options.each { |n, v| public_send("#{n}=", v) }
        @realm = @realm.upcase if @realm
        @name ||= "#{service}/#{hostname}@#{realm}"
        @name
      end

      def register
        request unless exist?
      end

      private

      def exist?
        AwesomeSpawn.run(IPA_COMMAND, :params => ["-e", "skip_version_check=1", "service-find", "--principal", name]).success?
      end

      def request
        # Using --force because these services tend not to be in dns. This is like VERIFY_NONE.
        AwesomeSpawn.run!(IPA_COMMAND, :params => ["-e", "skip_version_check=1", "service-add", "--force", name])
      end
    end
  end
end
