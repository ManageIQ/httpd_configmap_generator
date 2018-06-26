require "base64"
require "yaml"
require "uri"
require "etc"

module HttpdConfigmapGenerator
  class ConfigMap < Base
    DATA_SECTION = "data".freeze
    AUTH_CONFIGURATION = "auth-configuration.conf".freeze

    attr_accessor :config_map
    attr_accessor :opts

    def initialize(opts = {})
      @opts = opts
      @config_map = template
    end

    def generate(auth_type, realm = "undefined", file_list = nil, metadata = {})
      info_msg("Generating Auth Config-Map for #{auth_type}")
      @config_map = template(auth_type, realm)
      file_specs = gen_filespecs(file_list)
      define_configuration(file_specs, metadata)
      include_files(file_specs)
    end

    def load(file_path)
      @config_map = File.exist?(file_path) ? YAML.load_file(file_path) : {}
    end

    def save(file_path)
      delete_target_file(file_path)
      info_msg("Saving Auth Config-Map to #{file_path}")
      File.open(file_path, "w") { |f| f.write(config_map.to_yaml) }
    end

    def add_files(file_list)
      return unless file_list
      file_specs = gen_filespecs_for_files_to_add(file_list)
      update_configuration(file_specs)
      include_files(file_specs)
    end

    def export_file(file_entry, output_file)
      basename, _target_file, _mode = search_file_entry(file_entry)
      raise "File #{file_entry} does not exist in the configuration map" unless basename
      delete_target_file(output_file)
      create_target_directory(output_file)
      debug_msg("Exporting #{file_entry} to #{output_file} ...")
      content = config_map.fetch_path(DATA_SECTION, basename)
      content = Base64.decode64(content) if basename =~ /^.*\.base64$/
      File.write(output_file, content)
    end

    private

    def template(auth_type = "internal", kerberos_realms = "undefined")
      {
        DATA_SECTION => {
          "auth-type"            => auth_type,
          "auth-kerberos-realms" => kerberos_realms
        },
        "kind"       => "ConfigMap",
        "metadata"   => {
          "name" => "httpd-auth-configs"
        }
      }
    end

    def gen_filespecs(file_list)
      file_specs = []
      file_list.each do |file|
        file_specs << file_entry_spec(file.strip)
      end unless file_list.nil?
      file_specs.sort_by { |file_spec| file_spec[:basename] }
    end

    # Supporting the following signatures:
    #   /path/of/real/file
    #   /path/of/source/file,/path/of/real/file
    #   /path/of/source/file,/path/of/real/file,mode
    #   http://url_source,/path/of/real/file,mode
    def gen_filespecs_for_files_to_add(file_list)
      file_specs = []
      file_list.each do |file_to_add|
        file_spec = file_to_add.split(",").map(&:strip)
        file_entry =
          case file_spec.length
          when 1
            file_entry_spec(file_spec.first)
          when 2
            source_file, target_file = file_spec
            file_entry_for_source_target(source_file, target_file)
          when 3
            source_file, target_file, mode = file_spec
            file_entry_for_source_target_mode(source_file, target_file, mode)
          else
            raise "Invalid file specification #{file_to_add}"
          end
        file_specs << file_entry
      end
      file_specs.sort_by { |file_spec| file_spec[:basename] }
    end

    def file_entry_for_source_target(source_file, target_file)
      raise "Must specify a mode for URL file sources" if source_file =~ URI.regexp(%w(http https))
      file_entry = file_entry_spec(source_file, target_file)
      file_entry[:source_file] = source_file
      file_entry
    end

    def file_entry_for_source_target_mode(source_file, target_file, mode)
      if source_file =~ URI.regexp(%w(http https))
        fetch_network_file(source_file, target_file)
        file_entry = file_entry_spec(target_file, target_file, mode)
      else
        file_entry = file_entry_spec(source_file, target_file, mode)
        file_entry[:source_file] = source_file
      end
      file_entry
    end

    def file_entry_spec(source_file, target_file = nil, mode = nil)
      target_file = source_file.dup unless target_file
      unless mode
        stat = File.stat(source_file)
        file_owner = Etc.getpwuid(stat.uid).name
        file_group = Etc.getgrgid(stat.gid).name
      end
      {
        :basename => File.basename(target_file).dup,
        :binary   => file_binary?(source_file),
        :target   => target_file,
        :mode     => mode ? mode : "%4o:%s:%s" % [stat.mode & 0o7777, file_owner, file_group]
      }
    end

    def update_configuration(file_specs, metadata={})
      auth_configuration = fetch_auth_configuration
      return define_configuration(file_specs) unless auth_configuration
      # first, remove any file_specs references in the file list, we don't want duplication here.
      auth_configuration = auth_configuration.split("\n")
      file_specs.each do |file_spec|
        entry = auth_configuration.select { |line| line =~ file_entry_regex(file_spec[:target]) }
        auth_configuration -= entry if entry
      end
      auth_configuration = auth_configuration.join("\n") + "\n"
      # now, append any of the new file_specs at the end of the list.
      append_configuration(auth_configuration, file_specs, metadata)
    end

    def search_file_entry(target_file)
      auth_configuration = fetch_auth_configuration
      return nil unless auth_configuration
      auth_configuration = auth_configuration.split("\n")
      entry = auth_configuration.select { |line| line =~ file_entry_regex(target_file) }
      entry ? entry.first.split('=')[1].strip.split(' ') : nil
    end

    def define_configuration(file_specs, metadata={})
      auth_configuration = "# External Authentication Configuration File\n#\n"
      append_configuration(auth_configuration, file_specs, metadata)
    end

    def include_files(file_specs)
      file_specs.each do |file_spec|
        content = File.read(file_spec[:source_file] || file_spec[:target])
        content = Base64.encode64(content) if file_spec[:binary]
        # encode(:universal_newline => true) will convert \r\n to \n, necessary for to_yaml to render properly.
        config_map[DATA_SECTION].merge!(file_basename(file_spec) => content.encode(:universal_newline => true))
      end
    end

    def file_basename(file_spec)
      file_spec[:binary] ? "#{file_spec[:basename]}.base64" : file_spec[:basename]
    end

    def append_configuration(auth_configuration, file_specs, metadata)
      file_specs.each do |file_spec|
        debug_msg("Adding file #{file_spec[:target]} ...")
        auth_configuration += "file = #{file_basename(file_spec)} #{file_spec[:target]} #{file_spec[:mode]}\n"
      end
      config_map[DATA_SECTION] ||= {}

      metadata.each do |key, value|
        config_map[DATA_SECTION].merge!(key => value)
      end

      config_map[DATA_SECTION].merge!(AUTH_CONFIGURATION => auth_configuration)
    end

    def fetch_auth_configuration
      config_map.fetch_path(DATA_SECTION, AUTH_CONFIGURATION)
    end

    def file_entry_regex(target_file)
      /^file = .* #{target_file} .*$/
    end
  end
end
