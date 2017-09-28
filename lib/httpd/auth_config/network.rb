module Httpd
  module AuthConfig
    def realm
      domain.upcase
    end

    def domain
      opts[:host].gsub(/^([^.]+\.)/, '') if opts[:host].present? && opts[:host].include?('.')
    end

    def host_reachable?(host)
      require 'net/ping'
      Net::Ping::External.new(host).ping
    end
  end
end
