require 'test/unit'
require './utils.rb'

class WriteTests < Utils::SpawnerTester

  def test_write
    tests_count.each do |test_order|
      asindel(1, run_spawner_test(test_order)[Utils::WRITTEN_FIELD], 0.1, 0)
    end
  end

  def test_write_limit
    tests_count.each do |test_order|
      aseq(Utils::WRITE_LIMIT_EXCEEDED_RESULT, run_spawner_test(test_order, { :wl => '1kB' })[Utils::TERMINATE_REASON_FIELD], test_order)
    end
  end

  def test_streams_redirecting
    tests_passed = 0
    write_data = '1'
    in_file_name = 'in.txt'
    out_file_name = 'out.txt'
    err_file_name = 'err.txt'
    in_file_handler = FileHandler.new(in_file_name, write_data)
    out_file_handler = FileHandler.new(out_file_name)
    err_file_handler = FileHandler.new(err_file_name)
    #streams_combinations = (1..3).map{ |len| %i[ input output error ].combination(len).to_a } #TODO: wtf?!! why this code is looping?
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
      args[:input], args[:time_limit] = in_file_name, '3s' if input_provided
      args[:output] = out_file_name if output_provided
      args[:error] = err_file_name if error_provided

      rpt = run_spawner_test(test_number, args)

      exit_success?(rpt)

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

    streams_combinations.reject! { |comb| comb.size == 1 or not comb.include? :input }

    streams_combinations.each_index do |i|

      in_file_handler.write(write_data)

      combination = streams_combinations[i]
      test_number = tests_passed + i + 1

      output_provided = combination.include? :output
      error_provided = combination.include? :error

      args = {}
      args[:input], args[:time_limit] = in_file_name, '3s'
      args[:output] = in_file_name if output_provided
      args[:error] = in_file_name if error_provided

      rpt = run_spawner_test(test_number, args)

      exit_success?(rpt)

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
        :time_limit => 0.5,
    }

    exit_success?(run_spawner_test(1, args)) # TODO: why? may be it should give time limit exceeded for example?

    (2..3).each do |test_order|
      rpt = run_spawner_test(test_order, args)
      aseq(Utils::TIME_LIMIT_EXCEEDED_RESULT, rpt[Utils::TERMINATE_REASON_FIELD], test_order)
      assert_not_equal(0, rpt[Utils::WRITTEN_FIELD], fail_on_th_test_msg(test_order))
    end
  end

  def test_redirect_and_hide_output
    out_handler = FileHandler.new('out.txt')
    exit_success?(run_spawner_test(1, { :output => out_handler.file_name }, [ :hide_output ]))
    astrue(out_handler.read.empty?, 1)
  end

end