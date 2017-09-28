require "pathname"

module Httpd
  module AuthConfig
    class Base
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
end
