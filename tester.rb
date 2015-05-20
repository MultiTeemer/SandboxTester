require 'test-unit'
require 'fileutils'
require './constants.rb'

module Tester
  
  class SandboxTester < Test::Unit::TestCase

    private

    def fail_on_th_test_msg(test_order)
      "Fail on #{test_order}th test"
    end

    protected

    class FileHandler

      private

      @path

      public

      attr_reader :path

      def initialize(path, write_data = nil)
        @path = path
        write(write_data)
      end

      def read
        IO.read(@path)
      end

      def write(write_data)
        File.open(@path, 'w') { |f| f.write(write_data) } unless write_data.nil?
      end

      def clear
        File.open(@path, 'w') { |f| f.write(nil) }
      end

      def to_s
        @path
      end

      def delete
        FileUtils.rm(@path)
      end

    end

    def tests_count
      count = Dir.entries('.').size - 2
      (1..count)
    end

    def create_temporary_file(file_name, write_data = nil)
      FileHandler.new(file_name, write_data)
    end

    @one_test

    public

    def initialize(test_method_name, test = nil)
      super test_method_name

      @one_test = test
    end

    def run_sandbox_test(test_order = nil, args = {}, argv = [])
      executable = Dir[File.absolute_path(Dir.getwd) + '/*'].find do |filename|
        filename =~ /#{sprintf('%02d', test_order)}(\.(.*))?$/
      end

      raise "Wrong test order: #{test_order.inspect}" if executable.nil?

      if File.file?(executable)
        ext = Utils.file_extension(executable)

        unless ext == 'exe'

          executable = Utils.get_compiler_for(executable).cmd + ' ' + executable
          args[:command] = Args::FlagArgument.new
        end
      else
        files = Dir.entries(executable) - %w[ . .. ]

        if files.length == 1
          file = (Dir.entries(executable) - %w[ . .. ])[0]
          executable = "java -classpath #{executable}/ #{file[0 .. file.length - 7]}"

          args[:command] = Args::FlagArgument.new
        else
          return files.sort.map { |exec| Utils.sandbox.run(exec, args, argv) }
        end
      end

      Utils.sandbox.run(executable, args, argv)
    end

    def exit_success?(report, test_order = -1)
      aseq(Constants::EXIT_PROCESS_RESULT, report[Constants::TERMINATE_REASON_FIELD], test_order)
      aseq('0', report[Constants::EXIT_STATUS_FIELD], test_order)
      aseq('<none>', report[Constants::SPAWNER_ERROR_FIELD], test_order)
    end

    def setup
      name = self.class.name
      dir = name.slice(0, name.length - 5)
      dir[0] = dir[0].downcase!
      Dir.chdir("#{dir}Tests/")
      Dir.mkdir('bin') unless Dir.exists?('bin')
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

end
