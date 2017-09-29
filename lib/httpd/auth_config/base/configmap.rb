require "base64"

module Httpd
  module AuthConfig
    class Base
      def generate_configmap(auth_type, auth_configuration, realm, file_list)
        configmap_header(auth_type, auth_configuration, realm)
        configmap_file_section(file_list)
        configmap_trailer
      end

      private

      def out(section, line)
        prefix = ""
        if section == 1
          prefix = "  "
        elsif section == 2
          prefix = "    "
        elsif section == 3
          prefix = "      "
        end
        puts "#{prefix}#{line}\n"
      end

      def configmap_basename(file_spec)
        basename = file_spec[:basename]
        file_spec[:binary] ? "#{basename}.base64" : basename
      end

      def configmap_header(auth_type, auth_configuration, kerberos_realms)
        out(0, "data:")
        out(1, "auth-type: #{auth_type}")
        out(1, "auth-configuration: #{auth_configuration}")
        out(1, "auth-kerberos-realms: #{kerberos_realms}")
      end

      def configmap_trailer
        out(0, "kind: ConfigMap")
        out(0, "metadata:")
        out(1, "name: httpd-auth-configs")
      end

      def configmap_configuration(file_specs)
        out(1, "auth-configuration.conf: |")
        out(2, "# External Authentication Configuration File")
        out(2, "#")
        file_specs.each do |file_spec|
          out(2, "file = #{configmap_basename(file_spec)} #{file_spec[:target]} #{file_spec[:mode]}")
        end
      end

      def configmap_file_list(file_specs)
        file_specs.each do |file_spec|
          out(1, "#{configmap_basename(file_spec)}: |")
          if file_spec[:binary]
            Base64.encode64(File.read(file_spec[:target])).split("\n").each do |line|
              out(3, line)
            end
          else
            File.read(file_spec[:target]).split("\n").each do |line|
              out(3, line)
            end
          end
        end
      end

      def configmap_file_section(file_list)
        file_specs = []
        file_list.each do |file|
          file = file.strip
          basename = File.basename(file).dup
          binary = file_binary?(file)
          stat = File.stat(file)
          mode = sprintf("%4o:%s:%s", stat.mode & 07777, stat.uid, stat.gid)
          file_specs << { :basename => basename, :binary => binary, :target => file, :mode => mode }
        end
        file_specs = file_specs.sort_by { |file_spec| file_spec[:basename] }
        configmap_configuration(file_specs)
        configmap_file_list(file_specs)
      end
    end
  end
end
