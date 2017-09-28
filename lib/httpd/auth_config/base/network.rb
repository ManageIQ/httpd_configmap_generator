module Httpd
  module AuthConfig
    class Base
      def realm
        domain.upcase
      end

      def domain
        domain_from_host(opts[:host])
      end

      def domain_from_host(host)
        host.gsub(/^([^.]+\.)/, '') if host.present? && host.include?('.')
      end

      def host_reachable?(host)
        require 'net/ping'
        Net::Ping::External.new(host).ping
      end
    end
  end
end
