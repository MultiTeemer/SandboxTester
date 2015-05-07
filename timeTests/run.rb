require 'test/unit'
require './utils.rb'
require './args.rb'
require './tester.rb'
require './constants.rb'

class TimeTests < Tester::SpawnerTester

  def test_idleness_benchmark
    sep = '-' * 30
    tests_count.each do |order|
      l, r = 0.0, 100.0
      while r - l > 1
        m = (l + r) / 2
        rpt = run_spawner_test(
            order,
            {
                :idleness => Args::SecondsArgument.new(1),
                :time_limit => Args::SecondsArgument.new(2),
                :load_ratio => Args::PercentArgument.new(m)
            }
        )
        case rpt[Constants::TERMINATE_REASON_FIELD]
          when Constants::IDLENESS_LIMIT_EXCEEDED_RESULT then r = m
          when Constants::TIME_LIMIT_EXCEEDED_RESULT then l = m
          else aseq(true, rpt[Constants::TERMINATE_REASON_FIELD], order)
        end
      end
      puts sep, "Benchmark for #{%w[ input output ][order - 1]}: #{l}-#{r}%", sep
    end
  end

  def test_load_ratio

  end

  def test_time_limit
    params = [ { :time_limit => Args::SecondsArgument.new(1) } ] * 3
    params.each_index do |i|
      aseq(Constants::TIME_LIMIT_EXCEEDED_RESULT, run_spawner_test(i + 1, params[i])[Constants::TERMINATE_REASON_FIELD], i)
    end
  end

  def test_deadline
    omit_unless(Utils.spawner.has_feature?('deadline'))

    params = [ { :deadline => Args::SecondsArgument.new(1) } ] * 4
    params.each_index do |i|
      aseq(Constants::TIME_LIMIT_EXCEEDED_RESULT, run_spawner_test(i + 1, params[i])[Constants::TERMINATE_REASON_FIELD], i)
    end
  end

end