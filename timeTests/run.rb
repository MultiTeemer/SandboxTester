require 'test/unit'
require './utils.rb'

class TimeTests < Utils::SpawnerTester

  def test_load_ratio
    params = [
        { :idleness => 0.3 },
        { :idleness => 0.5, :time_limit => 1 },
    ]
    params.each_index do |i|
      rpt = self.run_spawner_test(i + 1, params[i])
      aseq(Utils::LOAD_RATIO_RESULT, rpt[Utils::TERMINATE_REASON_FIELD], i)
    end
  end

  def test_time_limit
    params = [
        { :time_limit => 0.5 },
        { :deadline => 0.5 },
        { :deadline => 0.3 },
    ]
    params.each_index do |i|
      rpt = self.run_spawner_test(i + 1, params[i])
      aseq(Utils::TIME_LIMIT_EXCEEDED_RESULT, rpt[Utils::TERMINATE_REASON_FIELD], i)
    end
  end


end