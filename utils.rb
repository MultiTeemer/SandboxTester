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
  ABNORMAL_EXIT_PROCESS_RESULT = 'AbnormalExit'
  LOAD_RATIO_RESULT = 'LoadRatio'

  ACCESS_VIOLATION_EXIT_STATUS = 'AccessViolation'
  STACK_OVERFLOW_EXIT_STATUS = 'StackOverflow'
  INT_DIVIDE_BY_ZERO_EXIT_STATUS = 'IntegerDivideByZero'
  ILLEGAL_INSTRUCTION_EXIT_STATUS = 'IllegalInstruction'
  PRIVILEGED_INSTRUCTION_EXIT_STATUS = 'PrivilegedInstruction'
  ARRAY_BOUNDS_EXCEEDED_EXIT_STATUS = 'ArrayBoundsExceeded'

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
    Dir.foreach('bin/') do |item|
      File.delete("bin/#{item}") if item =~ /\.(exe|txt|o)$/
    end
  end

  @spawner = nil

  def self.spawner
    @spawner
  end

  def self.init_spawner(type, path)
    @spawner = (case type
      when 'fefu' then FefuSpawnerWrapper
      when 'pcms2' then PCMS2SpawnerWrapper
    end).new(path)
  end

  class SpawnerTester < Test::Unit::TestCase

    public

    def run_spawner_test(test_order, args = {}, argv = [])
      file = " #{File.absolute_path(Dir.getwd)}/#{sprintf('%02d', test_order)}.exe"
      Utils.spawner.run(file, args, argv)
    end

    def exit_success?(report)
      assert_equal(Utils::EXIT_PROCESS_RESULT, report[TERMINATE_REASON_FIELD])
      assert_equal('0', report[EXIT_STATUS_FIELD])
      assert_equal('<none>', report[SPAWNER_ERROR_FIELD])
    end

    def setup
      name = self.class.name
      dir = name.slice(0, name.length - 5)
      dir[0] = dir[0].downcase!
      Dir.chdir("#{dir}Tests/")
      Utils.compile_for_test(self.method_name)
      Dir.chdir('./bin/')
    end

    def teardown
      Dir.chdir('..')
      Utils.clear
      Dir.chdir('..')
    end

    def aseq(expected, actual, test_order)
      assert_equal(expected, actual, "Fail on #{test_order + 1}th test")
    end

    def asindel(expected, actual, delta, test_order)
      assert_in_delta(expected, actual, delta, "Fail on #{test_order + 1}th test")
    end

  end

  class SpawnerWrapper

    protected

    @path
    @cmd_args_mapping
    @cmd_arg_val_delim

    def parse_report(rpt)

    end

    public

    def initialize(path)
      @path = path
    end

    def run(executable, args = {}, argv = [])
      cmd = @path
      args.each { |k, v| cmd += " -#{@cmd_args_mapping[k].nil? ? k : @cmd_args_mapping[k]}#{@cmd_arg_val_delim}#{v}" }
      cmd += " #{executable} #{argv.join(' ')}"
      parse_report(%x[#{cmd}])
    end

  end

  class FefuSpawnerWrapper < SpawnerWrapper

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
          :time_limit => 'tl',
          :memory_limit => 'ml',
          :user => 'u',
          :password => 'p',
          :input => 'i',
          :output => 'so',
          :idleness => 'y',
      }
    end

  end

  class PCMS2SpawnerWrapper < SpawnerWrapper

    protected

    def parse_report(rpt)

    end

    public

    def initialize(path)
      super
      @cmd_arg_val_delim = ' '
      @cmd_args_mapping = {
          :time_limit => 't',
          :memory_limit => 'm',
          :user => 'l',
          :password => 'p',
          :input => 'i',
          :output => 'o',
          :error => 'e',
          :idleness => 'i',
          :load_ratio => 'r',
      }
    end

  end

end