require 'test/unit'
require './utils.rb'

class TimeTests < Utils::SpawnerTester

  def test_idleness_benchmark
    sep = '-' * 30
    tests_count.each do |order|
      l, r = 0.0, 100.0
      while r - l > 1
        m = (l + r) / 2
        rpt = run_spawner_test(order, { :idleness => '1s', :time_limit => '2s', :load_ratio => m / 100.0 })
        case rpt[Utils::TERMINATE_REASON_FIELD]
          when Utils::IDLENESS_LIMIT_EXCEEDED_RESULT then r = m
          when Utils::TIME_LIMIT_EXCEEDED_RESULT then l = m
          else aseq(true, rpt[Utils::TERMINATE_REASON_FIELD], order)
        end
      end
      puts sep, "Benchmark for #{%w[ input output ][order - 1]}: #{l}-#{r}%", sep
    end
  end

  def test_load_ratio

  end

  def test_time_limit
    params = [ { :time_limit => 1 } ] * 3
    params.each_index do |i|
      aseq(Utils::TIME_LIMIT_EXCEEDED_RESULT, run_spawner_test(i + 1, params[i])[Utils::TERMINATE_REASON_FIELD], i)
    end
  end

  def test_deadline
    params = [ { :deadline => 1 } ] * 4
    params.each_index do |i|
      aseq(Utils::TIME_LIMIT_EXCEEDED_RESULT, run_spawner_test(i + 1, params[i])[Utils::TERMINATE_REASON_FIELD], i)
    end
  end

end