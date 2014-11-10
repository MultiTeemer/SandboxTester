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
      when 'cats' then CatsSpawnerWrapper
      when 'pcms2' then PCMS2SpawnerWrapper
    end).new(path)
  end

  class SpawnerTester < Test::Unit::TestCase

    protected

    def tests_count
      count = Dir.entries('.').size - 2
      (1..count)
    end

    public

    def run_spawner_test(test_order = nil, args = {}, flags = [], argv = [])
      file = " #{File.absolute_path(Dir.getwd)}/#{sprintf('%02d', test_order)}.exe" unless test_order.nil?
      Utils.spawner.run(file, args, flags, argv)
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
    @cmd_args
    @cmd_args_multipliers
    @cmd_flags

    def parse_report(rpt)

    end

    public

    attr_reader :cmd_args,
                :cmd_args_multipliers,
                :cmd_flags

    def initialize(path)
      @path = path
    end

    def run(executable, args = {}, flags = [], argv = [])
      cmd = @path
      args.each { |k, v| cmd += " -#{@cmd_args_mapping[k].nil? ? k : @cmd_args_mapping[k]}#{@cmd_arg_val_delim}#{v}" }
      cmd += " #{flags.map{ |el| '-' + el }.join(' ')} #{executable} #{argv.join(' ')}"
      parse_report(%x[#{cmd}])
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
      @cmd_args = %w[ ml tl d wl u p runas s sr so i lr sl wd ]
      @cmd_flags = %w[ ho sw ] #TODO: hide report workaround
      @cmd_args_multipliers = {
          :memory_limit => add_degrees(%w[ B b ]),
          :time_limit => add_degrees(%w[ s m h d ]),
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
          :time_limit => :t,
          :memory_limit => :m,
          :user => :l,
          :password => :p,
          :input => :i,
          :output => :o,
          :error => :e,
          :idleness => :i,
          :load_ratio => :r,
          :directory => :d,
      }
      @cmd_args = %w[ t m r y d l p i o e s D ]
      @cmd_flags = %w[ x q w 1 ]
      @cmd_args_multipliers = {
          :memory_limit => %w[ K M ],
          :time_limit => %w[ s ms ],
      }
    end

  end

end