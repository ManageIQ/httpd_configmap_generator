require 'pathname'

module Httpd
  module AuthConfig
    class Base
      APACHE_USER          = "apache".freeze
      HTTP_KEYTAB          = "/etc/http.keytab".freeze
      IPA_COMMAND          = "/usr/bin/ipa".freeze
      KERBEROS_CONFIG_FILE = "/etc/krb5.conf".freeze
      LDAP_ATTRS           = {
        "mail"        => "REMOTE_USER_EMAIL",
        "givenname"   => "REMOTE_USER_FIRSTNAME",
        "sn"          => "REMOTE_USER_LASTNAME",
        "displayname" => "REMOTE_USER_FULLNAME",
        "domainname"  => "REMOTE_USER_DOMAIN"
      }.freeze
      PAM_CONFIG           = "/etc/pam.d/httpd-auth".freeze
      SSSD_CONFIG          = "/etc/sssd/sssd.conf".freeze
      TIMESTAMP_FORMAT     = "%Y%m%d_%H%M%S".freeze

      attr_accessor :opts
      attr_accessor :realm
      attr_accessor :domain

      def initialize(opts = {})
        @opts = opts
        @realm = @domain = nil
      end

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

      def template_directory
        @template_directory ||= begin
          Pathname.new(Bundler.locked_gems.specs.select { |g| g.name == "httpd-authconfig" }.first.gem_dir).join("templates")
        end
      end

      def cp_template(file, src_dir, dest_dir = "/")
        src_path  = path_join(src_dir, file)
        dest_path = path_join(dest_dir, file.gsub(".erb", ""))
        if src_path.to_s.include?(".erb")
          File.write(dest_path, ERB.new(File.read(src_path), nil, '-').result(binding))
        else
          FileUtils.cp src_path, dest_path
        end
      end

      def rm_file(file, dir = "/")
        path = path_join(dir, file)
        File.delete(path) if File.exist?(path)
      end

      def path_join(*args)
        path = Pathname.new(args.shift)
        args.each { |path_seg| path = path.join("./#{path_seg}") }
        path
      end
    end
  end
end
