require 'test/unit'
require './utils.rb'

class TimeTests < Utils::SpawnerTester

  def test_idleness
    params = [ { :idleness => 0.5, :time_limit => 3 } ] * 2
    params.each_index do |i|
      aseq(Utils::IDLENESS_LIMIT_EXCEEDED_RESULT, run_spawner_test(i + 1, params[i])[Utils::TERMINATE_REASON_FIELD], i)
    end
  end

  def test_load_ratio

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