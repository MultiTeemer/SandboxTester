module Utils

  require 'test/unit'

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

  TIME_LIMIT_EXCEEDED_RESULT = 'TimeLimitExceeded'
  WRITE_LIMIT_EXCEEDED_RESULT = 'WriteLimitExceeded'
  MEMORY_LIMIT_EXCEEDED_RESULT = 'MemoryLimitExceeded'
  ABNORMAL_EXIT_PROCESS_RESULT = 'AbnormalExit'
  LOAD_RATIO__RESULT = 'LoadRatio'

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
		['.', '..', '.idea', '.git'].include? dir
  end

  def self.compile_for_cpp(file, out)
    system('g++', file, "-o#{out}") unless system_dir?(file)
  end

  def self.get_dir_name(test_name)
    test_name.slice(5, test_name.length)
  end

  def self.compile_for_test(test_name)
    test_name = get_dir_name(test_name)
    Dir.foreach("src/#{test_name}") do |file|
      unless system_dir?(file)
        compile_for_cpp("src/#{test_name}/#{file}", "bin/#{file.slice(0, file.length - 4)}.exe")
      end
    end
  end

  def self.clear(dir)
    Dir.foreach('bin/') do |item|
      File.delete("bin/#{item}") if item =~ /\.(exe|txt)$/
    end
  end

  class SpawnerTester < Test::Unit::TestCase

    public

    def self.parse_spawner_report(report)
      res = {}
      REPORT_FIELDS.each do |field|
        report =~ /\n#{field}:\s+(.+)(\(\S+\))?\n/i
        v = $1
        v = $1.to_f if v =~ /^(\d+\.?\d+)\s?(\S+)?$/
        res[field.to_sym] = v
      end
      res
    end

    def run_spawner_test(spawner, test_order, args = {}, argv = [])
      cmd = spawner
      args.each_pair { |k, v| cmd += " -#{k.to_s}:" + v.to_s }
      cmd += " #{File.absolute_path(Dir.getwd)}/bin/#{sprintf('%02d', test_order)}.exe #{argv.join(' ')}"
      self.class::parse_spawner_report(%x[#{cmd}])
    end

    def exit_success?(report)
      assert_equal(report[TERMINATE_REASON_FIELD], 'ExitProcess')
      assert_equal(report[EXIT_STATUS_FIELD], '0')
      assert_equal(report[SPAWNER_ERROR_FIELD], '<none>')
    end

    def setup
      Utils.compile_for_test(self.method_name)
    end

    def teardown
      Utils.clear('.')
    end

  end

end