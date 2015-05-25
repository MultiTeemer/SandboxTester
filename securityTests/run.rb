require 'test/unit'
require './args.rb'
require './constants.rb'
require './tester.rb'

class SecurityTests < Tester::SandboxTester

  private

    @can_read
    @can_write

  public

  def initialize(test_method_name, test = nil)
    super

    @can_read = 'canRead.txt'
    @can_write = 'canWrite.txt'
  end

  def setup
    super

    setup_script = '../../lib/spawner/user-setup.ps1'

    system("powershell -file #{setup_script} -canRead #{@can_read} -canWrite #{@can_write} > nul")
  end

  def run_sandbox_test(test_order = nil, args = {}, argv = [], wait = 1)
    string = Args::StringArgument
    args[:logon] = Args::UserCredentialsArgument.new(string.new('runner'), string.new('12345'))

    super
  end

  def test_file_system
    args = [
        {
            :time_limit => Args::SecondsArgument.new(1),
        },
        {
            :write_limit => Args::KilobyteArgument.new(1),
        },
    ]

    (1..4).each do |i|
      args.each_index do |j|
        rpt = run_sandbox_test(i, args[j], [], 3)

        aseq(0, rpt[Constants::WRITTEN_FIELD] || 0, i)
      end
    end

    out = FileHandler.new('out.txt')

    (5..8).each do |i|
      run_sandbox_test(i, { :output => Args::StringArgument.new(out.path) })

      aseq(0, out.read.to_i, i)

      out.clear
    end

    out.delete

    #9th test

    sibling_dir = 'test'

    run_sandbox_test(9, {}, [sibling_dir])

    success = !Dir.entries('..').include?(sibling_dir)

    FileUtils.rm_rf("../#{sibling_dir}")

    astrue(success, 9)

    #10th test

    Dir.mkdir("../#{sibling_dir}")

    file_content = '123'
    file = FileHandler.new("../#{sibling_dir}/file.txt", file_content)

    run_sandbox_test(10, {}, [file.path])

    success = file.read == file_content

    FileUtils.rm_rf("../#{sibling_dir}")

    astrue(success, 10)

    #11th test

    filename = 'file.txt'
    path = "../#{filename}"

    run_sandbox_test(11, {}, [filename])

    success = !File.exist?(path) || IO.read(path).bytesize == 0

    File.delete(path) if File.exist?(path)

    astrue(success, 11)
  end

  def test_destabilization
    unless @one_test.nil?
      run_sandbox_test(@one_test.to_i)
    else
      tests_count.each { |i| run_sandbox_test(i) }
    end
  end

  def test_exceptions
    tests_count.each do |i|
      if i % 2 == 1
        aseq(Constants::ABNORMAL_EXIT_PROCESS_RESULT, run_sandbox_test(i)[Constants::TERMINATE_REASON_FIELD], i)
      else
        exit_success?(run_sandbox_test(i), i)
      end
    end
  end

  def test_interruns_communications
    tests_count.each do |i|
      out = FileHandler.new('out.txt')
      rpts = run_sandbox_test(i, { :output => Args::StringArgument.new(out.path) })

      success = !out.read == 'some data'
      out.delete

      astrue(success, i)
    end
  end

end