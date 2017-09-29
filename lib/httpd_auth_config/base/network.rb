module HttpdAuthConfig
  class Base
    HOSTNAME_COMMAND = "/usr/bin/hostname".freeze

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
      require "net/ping"
      Net::Ping::External.new(host).ping
    end

    def update_hostname(host)
      if AwesomeSpawn.run(HOSTNAME_COMMAND).output.strip != host
        AwesomeSpawn.run!(HOSTNAME_COMMAND, :params => [host])
      end
    end
  end
end
