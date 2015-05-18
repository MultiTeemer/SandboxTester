require './args.rb'
require './constants.rb'

module Wrappers

  class SandboxWrapper

    protected

    @path
    @cmd_args_mapping
    @cmd_flags_mapping
    @cmd_arg_val_delim
    @cmd_args
    @cmd_args_multipliers
    @cmd_flags
    @tmp_file_name
    @features

    def parse_report(rpt)
      raise 'Virtual method called!'
    end

    def arg_for_property?(properties, arg)
      properties = [properties] unless properties.kind_of? Array
      properties.each { |property| return true if arg.to_s === @cmd_args_mapping[property].to_s }
      false
    end


    def unify(arg)
      raise 'Virtual method called!'
    end

    def suffix(arg_class)
      raise 'Virtual method called!'
    end

    def transform_arg(arg)
      u_arg = unify(arg)
      u_arg.to_s + suffix(u_arg)
    end

    public

    attr_reader :cmd_args,
                :cmd_args_multipliers,
                :cmd_flags,
                :tmp_file_name

    def initialize(path)
      @path = path
      @tmp_file_name = 'tmp.txt'
      @features = []
    end

    def run(executable, args = {}, flags = [], argv = [])
      cmd = @path
      args.each do |k, v|
        next if v.nil?

        key = (@cmd_args_mapping[k].nil? ? k : @cmd_args_mapping[k]).to_s

        if v.kind_of?(Array)
          cmd += v.map{ |val| " -#{key}#{@cmd_arg_val_delim}#{transform_arg(val)}" }.join(' ')
        else
          cmd += " -#{key}#{@cmd_arg_val_delim}#{transform_arg(v)}"
        end
      end
      run_flags = flags.map{ |el| "--#{@cmd_flags_mapping[el].to_s}" unless @cmd_flags_mapping[el].nil? }
      cmd += " #{ run_flags.join(' ') } #{ executable } #{ argv.join(' ') }"
      parse_report(%x[#{cmd}])
    end

    def get_correct_value_for(arg)

    end

    def get_wrong_value_for(arg)

    end

    def has_feature?(feature)
      @features.include?(feature)
    end

  end

  class CatsSpawnerWrapper < SandboxWrapper

    private

    @environment_mods

    def add_degrees(units)
      degrees = %w[ da h k Ki M Mi G Gi T Ti P Pi d c m u n p f ]
      res = []
      units.each { |unit| degrees.each { |degree| res.push(degree + unit) } }
      res
    end

    protected

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
      arg
    end

    def suffix(arg)
      case arg
        when Args::SecondsArgument then 's'
        when Args::MinutesArgument then 'm'
        when Args::MillisecondsArgument then 'ms'
        when Args::ByteArgument then 'B'
        when Args::KilobyteArgument then 'kB'
        when Args::GigabyteArgument then 'GB'
        else ''
      end
    end

    public

    attr_accessor :environment_mods

    def initialize(path)
      super
      @cmd_arg_val_delim = ':'
      @cmd_args_mapping = {
          :time_limit => :tl,
          :memory_limit => :ml,
          :write_limit => :wl,
          :user => :u,
          :password => :p,
          :input => :i,
          :output => :so,
          :error => :se,
          :idleness => :y,
          :deadline => :d,
          :load_ratio => :lr,
          :directory => :wd,
          :environment_mode => :env,
          :environment_vars => :D,
      }
      @cmd_flags_mapping = {
          :hide_output => :ho,
          :hide_report => :hr,
          :command => :cmd,
      }
      @cmd_args = %w[ ml tl d wl u p runas s sr so i lr sl wd env D ]
      @cmd_flags = %w[ ho sw cmd ] #TODO: hide report workaround
      @cmd_args_multipliers = {
          :memory_limit => add_degrees(%w[ B b ]),
          :time_limit => add_degrees(%w[ s m h d ]),
      }
      @environment_mods = %w[ inherit user-default clear ]
      @features = %w[
          environment_modes
          deadline
          write_limit
      ]
    end

    def get_correct_value_for(arg)
      1
    end

    def get_wrong_value_for(arg)
      'something_wrong'
    end

  end

  class PCMS2RunWrapper < SandboxWrapper

    protected

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
        when Args::GigabyteArgument then arg.to_bytes
        when Args::MinutesArgument then arg.to_seconds
        else arg
      end
    end

    def suffix(arg)
      case arg
        when Args::MillisecondsArgument then 'ms'
        when Args::KilobyteArgument then 'K'
        when Args::MegabyteArgument then 'M'
        else ''
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
          :idleness => :y,
          :load_ratio => :r,
          :directory => :d,
          :store_in_file => :s,
          :environment_vars => :D,
      }
      @cmd_flags_mapping = {
          :hide_report => :q,
      }
      @cmd_args = %w[ t m r y d i o e s D ] #l p
      @cmd_flags = %w[ x w 1 ] # q
      @cmd_args_multipliers = {
          :memory_limit => %w[ K M ],
          :time_limit => %w[ s ms ],
      }
    end

    def get_correct_value_for(arg)
      case true
        when arg_for_property?(:load_ratio, arg) then 0.5
        when arg_for_property?(:directory, arg) then '.'
        when arg_for_property?(%i[input output error], arg) then @tmp_file_name
        else 1
      end
    end

    def get_wrong_value_for(arg)
      case true
        when arg_for_property?(%i[input output error store_in_file], arg) then '"L:\Some\Unknown\Folder\On\Not\Existing\HDD"'
        when arg_for_property?(:load_ratio, arg) then 1
        when arg_for_property?(%i[time_limit idleness], arg) then 0.5
        when arg_for_property?(:directory, arg) then nil
        else 'something_wrong'
      end
    end

  end

end
