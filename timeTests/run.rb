require 'test/unit'
require './utils.rb'

class TimeTests < Utils::SpawnerTester

  def test_idleness_benchmark
    sep = '-' * 30
    tests_count.each do |order|
      l, r = 0.0, 100.0
      m = (l + r) / 2
      while r - l > 1
        rpt = run_spawner_test(order, { :idleness => '1s', :time_limit => '2s', :load_ratio => m / 100.0 })
        puts rpt[Utils::TERMINATE_REASON_FIELD]
        if rpt[Utils::TERMINATE_REASON_FIELD] == Utils::IDLENESS_LIMIT_EXCEEDED_RESULT
          r = m
        else
          l = m
        end
        m = (l + r) / 2
      end
      puts sep, "Benchmark for #{%w[ input output ][order - 1]}", m, sep
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