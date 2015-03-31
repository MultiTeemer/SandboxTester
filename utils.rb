module Utils

  require 'test/unit'
  require 'fileutils'

  APPLICATION_FIELD = :application
  PARAMETERS_FIELD  = :parameters
  SECURITY_LEVEL_FIELD = :securityLevel
  CREATE_PROCESS_METHOD_FIELD = :createProcessMethod
  USER_NAME_FIELD = :userName
  USER_TIME_LIMIT_FIELD = :userTimeLimit
  DEADLINE_FIELD = :deadline
  MEMORY_LIMIT_FIELD = :memoryLimit
  WRITE_LIMIT_FIELD = :writeLimit
  USER_TIME_FIELD = :userTime
  PEAK_MEMORY_USED_FIELD = :peakMemoryUsed
  WRITTEN_FIELD = :written
  TERMINATE_REASON_FIELD = :terminateReason
  EXIT_STATUS_FIELD = :exitStatus
  SPAWNER_ERROR_FIELD = :spawnerError

  EXIT_PROCESS_RESULT = 'ExitProcess'
  TIME_LIMIT_EXCEEDED_RESULT = 'TimeLimitExceeded'
  WRITE_LIMIT_EXCEEDED_RESULT = 'WriteLimitExceeded'
  MEMORY_LIMIT_EXCEEDED_RESULT = 'MemoryLimitExceeded'
  IDLENESS_LIMIT_EXCEEDED_RESULT = 'IdlenessLimitExceeded'
  ABNORMAL_EXIT_PROCESS_RESULT = 'AbnormalExitProcess'
  LOAD_RATIO_RESULT = 'LoadRatio'

  ACCESS_VIOLATION_EXIT_STATUS = 'AccessViolation'
  STACK_OVERFLOW_EXIT_STATUS = 'StackOverflow'
  INT_DIVIDE_BY_ZERO_EXIT_STATUS = 'IntegerDivideByZero'
  ILLEGAL_INSTRUCTION_EXIT_STATUS = 'IllegalInstruction'
  PRIVILEGED_INSTRUCTION_EXIT_STATUS = 'PrivilegedInstruction'
  ARRAY_BOUNDS_EXCEEDED_EXIT_STATUS = 'ArrayBoundsExceeded'

  NONE_ERROR_SP_ERROR = '<none>'

  REPORT_FIELDS = %i[
        application
        parameters
        securityLevel
        createProcessMethod
        userName
        userTimeLimit
        deadline
        memoryLimit
        writeLimit
        userTime
        peakMemoryUsed
        written
        terminateReason
        exitStatus
        spawnerError
    ]

	def self.system_dir?(dir)
		%w[ . .. .idea .git ].include? dir
  end

  def self.compile(compiler, file, out)
    system("#{compiler} #{file} -o#{out} 1>nul 2>nul") unless system_dir?(file)
  end

  def self.compile_cpp(file, out)
    compile('g++', file, out)
  end

  def self.compile_pascal(file, out)
    compile('fpc', file, out)
  end

  def self.get_dir_name(test_name)
    test_name.slice(5, test_name.length)
  end

  def self.compile_for_test(test_name)
    test_name = get_dir_name(test_name)
    Dir.foreach("src/#{test_name}") do |file|
      unless system_dir?(file)
        input, output = "src/#{test_name}/#{file}", "bin/#{file.slice(0, file.length - 4)}.exe"
        if file =~ /\.cpp$/
          compile_cpp(input, output)
        elsif file =~ /\.pas$/
          compile_pascal(input, output)
        end
      end
    end
  end

  def self.clear
    FileUtils.rm_rf('bin')
  end

  @spawner = nil

  def self.spawner
    @spawner
  end

  def self.init_spawner(type, path)
    @spawner = (case type
      when 'cats' then CatsSpawnerWrapper
      when 'pcms2' then PCMS2SpawnerWrapper
      else nil
    end).new(path)
  end

  class SpawnerTester < Test::Unit::TestCase

    private

    def fail_on_th_test_msg(test_order)
      "Fail on #{test_order}th test"
    end

    protected

    class FileHandler

      private

      @file_name

      public

      attr_reader :file_name

      def initialize(file_name, write_data = nil)
        @file_name = file_name
        write(write_data)
      end

      def read
        IO.read(@file_name)
      end

      def write(write_data)
        File.open(@file_name, 'w') { |f| f.write(write_data) } unless write_data.nil?
      end

      def clear
        File.open(@file_name, 'w') { |f| f.write(nil) }
      end

      def to_s
        @file_name
      end

    end

    def tests_count
      count = Dir.entries('.').size - 2
      (1..count)
    end

    def create_temporary_file(file_name, write_data = nil)
      FileHandler.new(file_name, write_data)
    end

    public

    def run_spawner_test(test_order = nil, args = {}, flags = [], argv = [])
      file = " #{File.absolute_path(Dir.getwd)}/#{sprintf('%02d', test_order)}.exe" unless test_order.nil?
      Utils.spawner.run(file, args, flags, argv)
    end

    def exit_success?(report, test_order = -1)
      aseq(Utils::EXIT_PROCESS_RESULT, report[TERMINATE_REASON_FIELD], test_order)
      aseq('0', report[EXIT_STATUS_FIELD], test_order)
      aseq('<none>', report[SPAWNER_ERROR_FIELD], test_order)
    end

    def setup
      name = self.class.name
      dir = name.slice(0, name.length - 5)
      dir[0] = dir[0].downcase!
      Dir.chdir("#{dir}Tests/")
      Dir.mkdir('bin')
      Utils.compile_for_test(self.method_name)
      Dir.chdir('./bin/')
    end

    def teardown
      Dir.chdir('..')
      Utils.clear
      Dir.chdir('..')
    end

    def aseq(expected, actual, test_order)
      assert_equal(expected, actual, fail_on_th_test_msg(test_order))
    end

    def asindel(expected, actual, delta, test_order)
      assert_in_delta(expected, actual, delta, fail_on_th_test_msg(test_order))
    end

    def astrue(actual, test_order)
      assert_true(actual, fail_on_th_test_msg(test_order))
    end

    def asfalse(actual, test_order)
      assert_false(actual, fail_on_th_test_msg(test_order))
    end

  end

  class SpawnerWrapper

    protected

    @path
    @cmd_args_mapping
    @cmd_flags_mapping
    @cmd_arg_val_delim
    @cmd_args
    @cmd_args_multipliers
    @cmd_flags
    @tmp_file_name

    def parse_report(rpt)

    end

    def arg_for_property?(properties, arg)
      properties = [properties] unless properties.kind_of? Array
      properties.each { |property| return true if arg.to_s === @cmd_args_mapping[property].to_s }
      false
    end

    public

    attr_reader :cmd_args,
                :cmd_args_multipliers,
                :cmd_flags,
                :tmp_file_name

    def initialize(path)
      @path = path
      @tmp_file_name = 'tmp.txt'
    end

    def run(executable, args = {}, flags = [], argv = [])
      cmd = @path
      args.each { |k, v| cmd += " -#{@cmd_args_mapping[k].nil? ? k : @cmd_args_mapping[k]}#{@cmd_arg_val_delim}#{v}" }
      run_flags = flags.map{ |el| '-' + (@cmd_flags_mapping[el].nil? ? el.to_s : @cmd_flags_mapping[el].to_s) }
      cmd += " #{ run_flags.join(' ') } #{ executable } #{ argv.join(' ') }"
      parse_report(%x[#{cmd}])
    end

    def get_correct_value_for(arg)

    end

    def get_wrong_value_for(arg)

    end

  end

  class CatsSpawnerWrapper < SpawnerWrapper

    private

    def add_degrees(units)
      degrees = %w[ da h k Ki M Mi G Gi T Ti P Pi d c m u n p f ]
      res = []
      units.each { |unit| degrees.each { |degree| res.push(degree + unit) } }
      res
    end

    protected

    def parse_report(rpt)
      res = {}
      REPORT_FIELDS.each do |field|
        rpt =~ /\n#{field}:\s+(.+)(\(\S+\))?\n/i
        v = $1
        v = $1.to_f if v =~ /^(\d+\.?\d+)\s?(\S+)?$/
        res[field.to_sym] = v
      end
      res
    end

    public

    def initialize(path)
      super
      @cmd_arg_val_delim = ':'
      @cmd_args_mapping = {
          :time_limit => :tl,
          :memory_limit => :ml,
          :user => :u,
          :password => :p,
          :input => :i,
          :output => :so,
          :error => :se,
          :idleness => :y,
          :deadline => :d,
          :load_ratio => :lr,
          :directory => :wd,
      }
      @cmd_flags_mapping = {
          :hide_output => :ho,
          :hide_report => :hr,
      }
      @cmd_args = %w[ ml tl d wl u p runas s sr so i lr sl wd ]
      @cmd_flags = %w[ ho sw ] #TODO: hide report workaround
      @cmd_args_multipliers = {
          :memory_limit => add_degrees(%w[ B b ]),
          :time_limit => add_degrees(%w[ s m h d ]),
      }
    end

    def get_correct_value_for(arg)
      1
    end

    def get_wrong_value_for(arg)
      'something_wrong'
    end

  end

  class PCMS2SpawnerWrapper < SpawnerWrapper

    private

    def fractional_s_to_ms(secs)
      (secs * 1000).to_i.to_s
    end

    protected

    def parse_report(rpt)
      res = {}
      if rpt =~ /^running/i
        rpt =~ /^\s*time consumed:\s+([0-9]+\.[0-9]+)(.*)$/i
        res[Utils::USER_TIME_FIELD] = $1.to_f
        rpt =~ /^\s*peak memory:\s+([0-9]+)(.*)$/i
        res[Utils::PEAK_MEMORY_USED_FIELD] = $1.to_f / 2 ** 20
        if rpt =~ /crash/i
          rpt =~ /crash\s+([_a-z]+)\s+/i
          error_msg = $1.to_s
          res[Utils::EXIT_STATUS_FIELD] = case error_msg
            when 'EXCEPTION_ACCESS_VIOLATION' then Utils::ACCESS_VIOLATION_EXIT_STATUS
            when 'EXCEPTION_INT_DIVIDE_BY_ZERO' then Utils::INT_DIVIDE_BY_ZERO_EXIT_STATUS
            when 'EXCEPTION_PRIV_INSTRUCTION' then Utils::PRIVILEGED_INSTRUCTION_EXIT_STATUS
            when 'EXCEPTION_STACK_OVERFLOW' then Utils::STACK_OVERFLOW_EXIT_STATUS
            else nil
          end
          res[Utils::TERMINATE_REASON_FIELD] = Utils::ABNORMAL_EXIT_PROCESS_RESULT
        elsif rpt =~ /program successfully terminated/i
          res[Utils::TERMINATE_REASON_FIELD] = Utils::EXIT_PROCESS_RESULT
          res[Utils::EXIT_STATUS_FIELD] = '0'
          res[Utils::SPAWNER_ERROR_FIELD] = Utils::NONE_ERROR_SP_ERROR
        else
          rpt =~ /to terminate...\s+([ a-z]+)\s+/i
          exit_status_msg = $1.to_s.downcase
          res[Utils::SPAWNER_ERROR_FIELD] = Utils::NONE_ERROR_SP_ERROR
          res[Utils::TERMINATE_REASON_FIELD] = case exit_status_msg
            when 'memory limit exceeded' then Utils::MEMORY_LIMIT_EXCEEDED_RESULT
            when 'time limit exceeded' then Utils::TIME_LIMIT_EXCEEDED_RESULT
            when 'idleness limit exceeded' then Utils::IDLENESS_LIMIT_EXCEEDED_RESULT
            else res[Utils::SPAWNER_ERROR_FIELD] = nil
            end
        end
      end
      res
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