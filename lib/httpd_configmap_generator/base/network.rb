module HttpdConfigmapGenerator
  class Base
    module Network
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
        command_run!(HOSTNAME_COMMAND, :params => [host]) if command_run(HOSTNAME_COMMAND).output.strip != host
      end

      def fetch_network_file(source_file, target_file)
        require "net/http"

        delete_target_file(target_file)
        create_target_directory(target_file)
        info_msg("Downloading #{source_file} ...")
        result = Net::HTTP.get_response(URI(source_file))
        raise "Failed to fetch URL file source #{source_file}" unless result.kind_of?(Net::HTTPSuccess)
        File.write(target_file, result.body)
      end
    end
  end
end
