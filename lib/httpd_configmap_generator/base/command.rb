require "awesome_spawn"

module HttpdConfigmapGenerator
  class Base
    def command_run(executable, options = {})
      if opts && opts[:debug]
        debug_msg("Running Command: #{AwesomeSpawn.build_command_line(executable, options)}")
      end
      AwesomeSpawn.run(executable, options)
    end

    def command_run!(executable, options = {})
      if opts && opts[:debug]
        debug_msg("Running Command: #{AwesomeSpawn.build_command_line(executable, options)}")
      end
      AwesomeSpawn.run!(executable, options)
    end

    def log_command_error(err)
      err_msg("Command Error: #{err}")
      if err.kind_of?(AwesomeSpawn::CommandResultError)
        err_msg("stdout: #{err.result.output}")
        err_msg("stderr: #{err.result.error}")
      else
        err_msg(err.backtrace)
      end
    end
  end
end
