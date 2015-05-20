require 'timeout'

require './args.rb'
require './constants.rb'
require './sandbox_args.rb'

module Wrappers

  class SandboxWrapper

    protected

    @path
    @cmd_args_mapping
    @cmd_arg_val_delim
    @cmd_args
    @tmp_file_name
    @features

    def parse_report(rpt)
      raise 'Virtual method called!'
    end

    def unify(arg)
      raise 'Virtual method called!'
    end

    def to_cmd(mean, val)
      key = @cmd_args_mapping[mean]

      "#{key.nil? ? nil : ('-' + key.to_s + @cmd_arg_val_delim)}#{unify(val)}"
    end

    public

    attr_reader :cmd_args,
                :tmp_file_name

    def initialize(path)
      @path = path
      @tmp_file_name = 'tmp.txt'
      @features = []
      @cmd_args_mapping = {}
      @cmd_arg_val_delim = ''
    end

    def run(executable, args = {}, argv = [], waiting = 1)
      cmd = @path

      args.each { |mean, val| cmd += ' ' + to_cmd(mean, val) }

      cmd += " #{executable} #{argv.join(' ')}"

      begin
        raw_report = Timeout::timeout(waiting) { %x[#{cmd}] }
      rescue
        rpt = { Constants::SANDBOX_RUN_STATUS => Constants::SANDBOX_RUN_STATUS_TIMEOUT }
        raw_report = nil
      end

      unless raw_report.nil?
        rpt = parse_report(raw_report).merge(
            {
                Constants::SANDBOX_RUN_STATUS => Constants::SANDBOX_RUN_STATUS_COMPLETED
            }
        )
      end

      rpt
    end

    def has_feature?(feature)
      @features.include?(feature)
    end

  end

  class CatsSpawnerWrapper < SandboxWrapper

    private

    @environment_mods

    class DeadlineArgument < SandboxArgs::TimeLimitArgument
    end

    class HideOutputFlag < SandboxArgs::FlagArgument

      def initialize(val = true)
        super Args::FlagArgument.new(val), :hide_output
      end

    end

    class CommandFlag < SandboxArgs::FlagArgument

      def initialize(val = 'cmd')
        super Args::FlagArgument.new(val), :command
      end

    end

    class EnvironmentModeArgument < SandboxArgs::EnumArgument

      def initialize(val = nil)
        super val, :environment_mode, %w[ inherit user-default clear ]
      end

    end

    def parse_report(rpt)
      res = {}
      Constants::REPORT_FIELDS.each do |field|
        rpt =~ /\n#{field}:\s+(.+)(\(\S+\))?\n/i
        v = $1
        v = $1.to_f if v =~ /^(\d+\.?\d+)\s?(\S+)?$/
        res[field.to_sym] = v
      end
      res
    end

    def unify(arg)
      case arg
        when Args::TimeArgument then arg.to_ms.to_s + 'ms'
        when Args::MemoryArgument then arg.to_bytes.to_s + 'B'
        when Args::UserCredentialsArgument then "-u #{arg.username} -p #{arg.password}"
        when Args::IdlenessLimitArgument then "-lr #{arg.required_load} -y #{arg.idleness}"
        when Args::FlagArgument then
          if arg.val.instance_of?(TrueClass)
            '1'
          elsif arg.val.instance_of?(FalseClass)
            '0'
          elsif arg.val.to_s == 'cmd'
            ''
          else
            arg.val.to_s
          end
        when Args::ArrayArgument then arg.val.map{ |e| "-D #{e}" }.join(' ')
        else arg.to_s
      end
    end

    public

    attr_accessor :environment_mods

    def initialize(path)
      super

      @cmd_arg_val_delim = ' '

      @cmd_args_mapping = {
          :time_limit => :tl,
          :memory_limit => :ml,
          :write_limit => :wl,
          :input => :i,
          :output => :so,
          :error => :se,
          :deadline => :d,
          :directory => :wd,
          :hide_output => :ho,
          :hide_report => :hr,
          :command => :cmd,
          :environment_mode => :env,
      }

      @cmd_args = [
          SandboxArgs::TimeLimitArgument,
          SandboxArgs::MemoryLimitArgument,
          SandboxArgs::WriteLimitArgument,
          SandboxArgs::InputFileArgument,
          SandboxArgs::OutputFileArgument,
          SandboxArgs::ErrorFileArgument,
          SandboxArgs::WorkingDirectoryArgument,
          SandboxArgs::UserCredentialsArgument,
          SandboxArgs::IdlenessLimitArgument,
          SandboxArgs::EnvironmentVariablesArgument,
          DeadlineArgument,
          HideOutputFlag,
          EnvironmentModeArgument,
      ].map { |klass| klass.new }

      @environment_mods = %w[ inherit user-default clear ]

      @features = %w[
          environment_modes
          deadline
          write_limit
          hide_report
      ]
    end

  end

  class PCMS2RunWrapper < SandboxWrapper

    private

    def parse_report(rpt)
      res = {}
      if rpt =~ /^running/i
        rpt =~ /^\s*time consumed:\s+([0-9]+\.[0-9]+)(.*)$/i
        res[Constants::USER_TIME_FIELD] = $1.to_f
        rpt =~ /^\s*peak memory:\s+([0-9]+)(.*)$/i
        res[Constants::PEAK_MEMORY_USED_FIELD] = $1.to_f / 2 ** 20
        if rpt =~ /crash/i
          rpt =~ /crash\s+([_a-z]+)\s+/i
          error_msg = $1.to_s
          res[Constants::EXIT_STATUS_FIELD] = case error_msg
            when 'EXCEPTION_ACCESS_VIOLATION' then Constants::ACCESS_VIOLATION_EXIT_STATUS
            when 'EXCEPTION_INT_DIVIDE_BY_ZERO' then Constants::INT_DIVIDE_BY_ZERO_EXIT_STATUS
            when 'EXCEPTION_PRIV_INSTRUCTION' then Constants::PRIVILEGED_INSTRUCTION_EXIT_STATUS
            when 'EXCEPTION_STACK_OVERFLOW' then Constants::STACK_OVERFLOW_EXIT_STATUS
            else nil
          end
          res[Constants::TERMINATE_REASON_FIELD] = Constants::ABNORMAL_EXIT_PROCESS_RESULT
        elsif rpt =~ /program successfully terminated/i
          res[Constants::TERMINATE_REASON_FIELD] = Constants::EXIT_PROCESS_RESULT
          res[Constants::EXIT_STATUS_FIELD] = '0'
          res[Constants::SPAWNER_ERROR_FIELD] = Constants::NONE_ERROR_SP_ERROR
        else
          rpt =~ /to terminate...\s+([ a-z]+)\s+/i
          exit_status_msg = $1.to_s.downcase
          res[Constants::SPAWNER_ERROR_FIELD] = Constants::NONE_ERROR_SP_ERROR
          res[Constants::TERMINATE_REASON_FIELD] = case exit_status_msg
             when 'memory limit exceeded' then Constants::MEMORY_LIMIT_EXCEEDED_RESULT
             when 'time limit exceeded' then Constants::TIME_LIMIT_EXCEEDED_RESULT
             when 'idleness limit exceeded' then Constants::IDLENESS_LIMIT_EXCEEDED_RESULT
             else res[Constants::SPAWNER_ERROR_FIELD] = nil
           end
        end
      end
      res
    end

    def unify(arg)
      case arg
        when Args::TimeArgument then arg.to_ms.to_s + 'ms'
        when Args::MemoryArgument then arg.to_bytes
        when Args::UserCredentialsArgument then "-l #{arg.username} -p #{arg.password}"
        when Args::IdlenessLimitArgument then "-r #{arg.required_load} -y #{arg.idleness}"
        when Args::ArrayArgument then arg.val.join('-D ')
        when Args::FlagArgument then ''
        else arg.to_s
      end
    end

    public

    def initialize(path)
      super

      @cmd_arg_val_delim = ' '

      @cmd_args_mapping = {
          :time_limit => :t,
          :memory_limit => :m,
          :user => :l,
          :password => :p,
          :input => :i,
          :output => :o,
          :error => :e,
          :directory => :d,
          :store_in_file => :s,
          :hide_report => :q,
          :environment_vars => :D,
      }

      @cmd_args = [
          SandboxArgs::TimeLimitArgument,
          SandboxArgs::MemoryLimitArgument,
          SandboxArgs::InputFileArgument,
          SandboxArgs::OutputFileArgument,
          SandboxArgs::ErrorFileArgument,
          SandboxArgs::WorkingDirectoryArgument,
          SandboxArgs::UserCredentialsArgument,
          SandboxArgs::IdlenessLimitArgument,
          SandboxArgs::EnvironmentVariablesArgument,
      ].map { |klass| klass.new }

      @features = %w[
          hide_report
      ]
    end

  end

end
