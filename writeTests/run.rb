require 'test/unit'
require './utils.rb'
require './args.rb'
require './tester.rb'

class WriteTests < Tester::SandboxTester

  def test_write
    tests_count.each do |test_order|
      asindel(1, run_sandbox_test(test_order)[Constants::WRITTEN_FIELD], 0.1, 0)
    end
  end

  def test_write_limit
    omit_unless(Utils.spawner.has_feature?('write_limit'))

    tests_count.each do |test_order|
      aseq(
          Constants::WRITE_LIMIT_EXCEEDED_RESULT,
          run_sandbox_test(test_order, { :wl => Args::KilobyteArgument.new(1) })[Constants::TERMINATE_REASON_FIELD],
          test_order
      )
    end
  end

  def test_streams_redirecting #TODO: checkout out randomness of test failing
    tests_passed = 0
    write_data = '1'
    in_file_name = 'in.txt'
    out_file_name = 'out.txt'
    err_file_name = 'err.txt'
    in_file_handler = FileHandler.new(in_file_name, write_data)
    out_file_handler = FileHandler.new(out_file_name)
    err_file_handler = FileHandler.new(err_file_name)
    streams_combinations = [
        [:input], [:output], [:error],
        [:input, :output], [:input, :error], [:output, :error],
        [:input, :output, :error],
    ]

    streams_combinations.each_index do |i|

      combination = streams_combinations[i]
      test_number = i + 1

      input_provided = combination.include? :input
      output_provided = combination.include? :output
      error_provided = combination.include? :error

      args = {}
      args[:input], args[:idleness], args[:load_ratio] = in_file_name, '1s', 5 if input_provided
      args[:output] = out_file_name if output_provided
      args[:error] = err_file_name if error_provided

      rpt = run_sandbox_test(test_number, args)

      exit_success?(rpt, test_number)

      if input_provided
        astrue(out_file_handler.read == write_data, test_number) if output_provided
        astrue(err_file_handler.read == write_data, test_number) if error_provided
      else
        asfalse(out_file_handler.read.empty?, test_number) if output_provided
        asfalse(err_file_handler.read.empty?, test_number) if error_provided
      end

      out_file_handler.clear if output_provided
      err_file_handler.clear if error_provided

      tests_passed += 1
    end

    streams_looping = []

    streams_combinations.each_index do |i|
      comb = streams_combinations[i]
      if comb.size > 1 && comb.include?(:input)
        streams_looping.push({
           :order => i,
           :comb => comb
        })
      end
    end

    streams_looping.each_index do |i|

      in_file_handler.write(write_data)

      combination = streams_looping[i][:comb]
      test_number = tests_passed + i + 1

      output_provided = combination.include? :output
      error_provided = combination.include? :error

      args = {}
      args[:input], args[:time_limit] = in_file_name, '3s'
      args[:output] = in_file_name if output_provided
      args[:error] = in_file_name if error_provided

      rpt = run_sandbox_test(streams_looping[i][:order], args)

      exit_success?(rpt, test_number)

      astrue(in_file_handler.read != write_data, test_number)

      in_file_handler.clear

      tests_passed += 1

    end
  end

  def test_streams_redirecting_to_null
    args = {
        :input => 'nul',
        :output => 'nul',
        :error => 'nul',
        :time_limit => Args::MillisecondsArgument.new(500),
    }

    exit_success?(run_sandbox_test(1, args)) # TODO: why? may be it should give time limit exceeded for example?

    (2..3).each do |test_order|
      rpt = run_sandbox_test(test_order, args)
      aseq(Constants::TIME_LIMIT_EXCEEDED_RESULT, rpt[Constants::TERMINATE_REASON_FIELD], test_order)
      assert_not_equal(0, rpt[Constants::WRITTEN_FIELD], fail_on_th_test_msg(test_order))
    end
  end

  def test_redirect_and_hide_output
    out_handler = FileHandler.new('out.txt')
    exit_success?(run_sandbox_test(1, { :output => out_handler.path, :hide_output => Args::FlagArgument.new }))
    astrue(out_handler.read.empty?, 1)
  end

end