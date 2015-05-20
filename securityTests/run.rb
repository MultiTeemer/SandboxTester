require 'test/unit'
require './args.rb'
require './constants.rb'
require './tester.rb'

class SecurityTests < Tester::SandboxTester

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
        run_sandbox_test(i, args[j])
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

    Dir.rmdir("../#{sibling_dir}")

    astrue(success, 9)

    #10th test

    Dir.mkdir("../#{sibling_dir}")

    file_content = '123'
    file = FileHandler.new("../#{sibling_dir}/file.txt", file_content)

    run_sandbox_test(10, {}, [file.path])

    success = file.read == file_content

    Dir.rm_rf("../#{sibling_dir}")

    astrue(success, 10)
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