require "optparse"
require "aws-sdk"

module NWMedia
  class Options
    Version = "1.0.0"

    ENVIRONMENTS = %i[dev gamma]

    class ScriptOptions
      attr_accessor :cmd,
                    :flags,
                    :domain,
                    :region,
                    :profile,
                    :bucket,
                    :stack_name,
                    :env,
                    :project_root,
                    :project_name,
                    :dist_folder,
                    :debug

      def initialize
        @cmd = nil
        @flags = []
        @domain = "nichols.works"
        @region = "us-east-1"
        @profile = "nichols-works"
        @bucket = nil
        @stack_name = nil
        @env = :dev
        @project_root = "#{File.expand_path File.join("..", "..", ".."), __FILE__}"
        @project_name = "#{File.basename @project_root}"
        @dist_folder = nil
        @debug = false
      end

      def client
        {
          region: @region,
          credentials: Aws::SharedCredentials.new(profile_name: @profile)
        }
      end
    end

    class << self
      def parse(args)
        @options ||= ScriptOptions.new
        @parser || OptionParser.new { |parser|
          @parser = parser
          parser.banner = "Usage #{$PROGRAM_NAME} [options#{@cmds_defined ? '|command' : ''}]"
          parser.separator ""
          parser.separator "Specific options:"

          yield self if block_given?

          parser.separator ""
          parser.separator "Common options:"
          profile_option
          env_option
          root_option
          debug_option
          help_option
          version_option
        }.parse!(args)
        raise OptionParser::InvalidOption, "-e no environment given" unless @options.env
        raise OptionParser::InvalidOption, "no command given" if @cmds_defined && !@options.cmd
        @options
      rescue OptionParser::ParseError => e
        puts e
        puts @parser
      end

      def command_option(commands)
        raise StandardError.new "Commands must be given as an array" unless commands.is_a? Array
        @cmds_defined = true
        cmd_list = "[#{commands.join(', ')}]"
        @parser.on("-c COMMAND", commands, "Command", "  #{cmd_list}") { |cmd|
          @options.cmd = cmd
        }
      end

      def flags_option(flags)
        raise StandardError.new "Flags must be given as an array" unless flags.is_a? Array
        flag_list = "[#{flags.join(', ')}]"
        @parser.on("-f FLAG", "--extra-flag FLAG", "#{flag_list}") { |flag|
          @options.flags << flag
        }
      end

      def profile_option
        @parser.on_tail("-p PROFILE", "--profile PROFILE", "The AWS profile to use for credentials") { |profile|
          @options.profile = profile
        }
      end

      def s3_bucket_option(default_bucket)
        @options.bucket = default_bucket
        @parser.on("-b BUCKET", "--bucket BUCKET", "The AWS bucket to use", "  Default: #{@options.bucket}") { |bucket|
          @options.bucket = bucket
        }
      end

      def ops_stack_name_option(default_stack)
        @options.stack_name = default_stack
        @parser.on("-s STACK", "--stack STACK", "The name of the AWS OpsWorks stack to use", "  Default: #{@options.stack_name}") { |stack|
          @options.stack_name = stack
        }
      end

      def env_option
        env_list = "[#{ENVIRONMENTS.join(', ')}]"
        @parser.on_tail("-e ENV", "--env ENV", ENVIRONMENTS, "Select environment (REQUIRED)", "  #{env_list}") { |env|
          @options.env = env.to_sym
        }
      end

      def root_option
        @parser.on_tail("-r ROOT", "--root ROOT", "Change project root path", "  Default: #{@options.project_root}") { |root|
          @option.project_root = root
          @option.project_name = File.basename(root)
        }
      end

      def gradle_dist_folder_option(default_dist_folder)
        @options.dist_folder = default_dist_folder
        @parser.on("--dist DIST", "Select gradle distributions path", "  Default: #{@options.dist_folder}") { |dist_folder|
          @option.dist_folder = dist_folder
        }
      end

      def debug_option
        @parser.on_tail("-d", "--[no-]debug", "Enable debug (verbose) mode") { |debug|
          @options.debug = debug
        }
      end

      def help_option
        @parser.on_tail("-h", "--help", "Prints this help") {
          puts @parser
          exit
        }
      end

      def version_option
        @parser.on_tail("-v", "--version", "Show version") {
          puts Version
          exit
        }
      end
    end
  end
end
