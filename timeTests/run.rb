require 'test/unit'
require './utils.rb'

class TimeTests < Utils::SpawnerTester

  def test_load_ratio
    params = [
        { :y => 0.3 },
        { :y => 0.5, :tl => 1 },
    ]
    params.each_index do |i|
      rpt = self.run_spawner_test(i + 1, params[i])
      aseq(Utils::LOAD_RATIO_RESULT, rpt[Utils::TERMINATE_REASON_FIELD], i)
    end
  end

  def test_time_limit
    params = [
        { :tl => 0.5 },
        { :d => 0.5 },
        { :d => 0.3 },
    ]
    params.each_index do |i|
      rpt = self.run_spawner_test(i + 1, params[i])
      aseq(Utils::TIME_LIMIT_EXCEEDED_RESULT, rpt[Utils::TERMINATE_REASON_FIELD], i)
    end
  end


end