require "base64"
require "yaml"
require "uri"

module HttpdAuthConfig
  class Base
    def generate_configmap(auth_type, realm, file_list)
      info_msg("Generating Auth Config-Map for #{auth_type}")
      config_map = auth_configmap_template(auth_type, realm)
      file_specs = gen_filespecs(file_list)
      configmap_configuration(config_map, file_specs)
      configmap_file_list(config_map, file_specs)
      config_map
    end

    def save_configmap(config_map, file_path)
      delete_target_file(file_path)
      info_msg("Saving Auth Config-Map to #{file_path}")
      File.open(file_path, "w") { |f| f.write(config_map.to_yaml) }
    end

    def read_configmap(file_path)
      File.exist?(file_path) ? YAML.load_file(file_path) : {}
    end

    def configmap_addfiles(config_map, file_list)
      file_specs = gen_filespecs_for_files_to_add(file_list)
      configmap_update_configuration(config_map, file_specs)
      configmap_file_list(config_map, file_specs)
      config_map
    end

    def configmap_exportfile(config_map, file_entry, output_file)
      basename, _target_file, _mode = configmap_search_file_entry(config_map, file_entry)
      raise "File #{file_entry} does not exist in the configuration map" unless basename
      delete_target_file(output_file)
      create_target_directory(output_file)
      debug_msg("Exporting #{file_entry} to #{output_file} ...")
      content = config_map.fetch_path("data", basename)
      content = Base64.decode64(content) if basename =~ /^.*\.base64$/
      File.write(output_file, content)
    end

    private

    def auth_configmap_template(auth_type, kerberos_realms)
      {
        "data"     => {
          "auth-type"            => auth_type,
          "auth-kerberos-realms" => kerberos_realms
        },
        "kind"     => "ConfigMap",
        "metadata" => {
          "name" => "httpd-auth-configs"
        }
      }
    end

    def gen_filespecs(file_list)
      file_specs = []
      file_list.each do |file|
        file = file.strip
        stat = File.stat(file)
        file_entry = {
          :basename => File.basename(file).dup,
          :binary   => file_binary?(file),
          :target   => file,
          :mode     => "%4o:%s:%s" % [stat.mode & 0o7777, stat.uid, stat.gid]
        }
        file_specs << file_entry
      end
      file_specs.sort_by { |file_spec| file_spec[:basename] }
    end

    # Supporting the following signatures:
    #   /path/of/real/file
    #   /path/of/source/file,/path/of/real/file
    #   /path/of/source/file,/path/of/real/file,mode
    #   http://url_source,/path/of/real/file,mode
    def gen_filespecs_for_files_to_add(file_list)
      require "net/http"

      file_specs = []
      file_list.each do |file_to_add|
        file_spec = file_to_add.split(",").map(&:strip)
        case file_spec.length
        when 1
          file = file_spec.first
          file_entry = file_entry_spec(file, file)
        when 2
          source_file, target_file = file_spec
          raise "Must specify a mode for URL file sources" if source_file =~ URI.regexp(%w(http https))
          file_entry = file_entry_spec(source_file, target_file)
        when 3
          source_file, target_file, mode = file_spec
          if source_file =~ URI.regexp(%w(http https))
            delete_target_file(target_file)
            create_target_directory(target_file)
            debug_msg("Downloading #{source_file} ...")
            result = Net::HTTP.get_response(URI(source_file))
            raise "Failed to fet URL file source #{source_file}" unless result.kind_of?(Net::HTTPSuccess)
            File.write(target_file, result.body)
            file_entry = file_entry_spec(target_file, target_file, mode)
          else
            file_entry = file_entry_spec(source_file, target_file, mode)
          end
        else
          raise "Invalid file specification #{file_to_add}"
        end
        file_specs << file_entry
      end
      file_specs.sort_by { |file_spec| file_spec[:basename] }
    end

    def file_entry_spec(source_file, target_file, mode = nil)
      stat = File.stat(source_file) unless mode
      {
        :basename => File.basename(target_file).dup,
        :binary   => file_binary?(source_file),
        :target   => target_file,
        :mode     => mode ? mode : "%4o:%s:%s" % [stat.mode & 0o7777, stat.uid, stat.gid]
      }
    end

    def configmap_update_configuration(config_map, file_specs)
      auth_configuration = config_map.fetch_path("data", "auth-configuration.conf")
      return configmap_configuration(config_map, file_specs) unless auth_configuration
      # first, remove any file_specs references in the file list, we don't want duplication here.
      auth_configuration = auth_configuration.split("\n")
      file_specs.each do |file_spec|
        entry = auth_configuration.select { |line| line =~ /^file = .* #{file_spec[:target]} .*$/ }
        auth_configuration -= entry if entry
      end
      auth_configuration = auth_configuration.join("\n") + "\n"
      # now, append any of the new file_specs at the end of the list.
      append_configmap_configuration(config_map, auth_configuration, file_specs)
    end

    def configmap_search_file_entry(config_map, target_file)
      auth_configuration = config_map.fetch_path("data", "auth-configuration.conf")
      return nil unless auth_configuration
      auth_configuration = auth_configuration.split("\n")
      entry = auth_configuration.select { |line| line =~ /^file = .* #{target_file} .*$/ }
      entry ? entry.first.split('=')[1].strip.split(' ') : nil
    end

    def configmap_configuration(config_map, file_specs)
      auth_configuration = "# External Authentication Configuration File\n#\n"
      append_configmap_configuration(config_map, auth_configuration, file_specs)
    end

    def configmap_file_list(config_map, file_specs)
      file_specs.each do |file_spec|
        content = File.read(file_spec[:target])
        content = Base64.encode64(content) if file_spec[:binary]
        # encode(:universal_newline => true) will convert \r\n to \n, necessary for to_yaml to render properly.
        config_map["data"].merge!(configmap_basename(file_spec) => content.encode(:universal_newline => true))
      end
    end

    def configmap_basename(file_spec)
      file_spec[:binary] ? "#{file_spec[:basename]}.base64" : file_spec[:basename]
    end

    def append_configmap_configuration(config_map, auth_configuration, file_specs)
      file_specs.each do |file_spec|
        debug_msg("Adding file #{file_spec[:target]} ...")
        auth_configuration += "file = #{configmap_basename(file_spec)} #{file_spec[:target]} #{file_spec[:mode]}\n"
      end
      config_map["data"] ||= {}
      config_map["data"].merge!("auth-configuration.conf" => auth_configuration)
    end
  end
end
