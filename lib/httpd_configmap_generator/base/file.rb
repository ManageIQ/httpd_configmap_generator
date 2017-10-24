require "pathname"

module HttpdConfigmapGenerator
  class Base
    def template_directory
      @template_directory ||=
        Pathname.new(Gem::Specification.find_by_name("httpd_configmap_generator").full_gem_path).join("templates")
    end

    def cp_template(file, src_dir, dest_dir = "/")
      src_path  = path_join(src_dir, file)
      dest_path = path_join(dest_dir, file.gsub(".erb", ""))
      if src_path.to_s.include?(".erb")
        File.write(dest_path, ERB.new(File.read(src_path), nil, '-').result(binding))
      else
        FileUtils.cp(src_path, dest_path)
      end
    end

    def delete_target_file(file_path)
      if File.exist?(file_path)
        if opts[:force]
          info_msg("File #{file_path} exists, forcing a delete")
          File.delete(file_path)
        else
          raise "File #{file_path} already exist"
        end
      end
    end

    def create_target_directory(file_path)
      dirname = File.dirname(file_path)
      return if File.exist?(dirname)
      debug_msg("Creating directory #{dirname} ...")
      FileUtils.mkdir_p(dirname)
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

    def file_binary?(file)
      data = File.read(file)
      ascii = control = binary = total = 0
      data[0..512].each_byte do |c|
        total += 1
        if c < 32
          control += 1
        elsif c >= 32 && c <= 128
          ascii += 1
        else
          binary += 1
        end
      end
      control.to_f / ascii > 0.1 || binary.to_f / ascii > 0.05
    end
  end
end
