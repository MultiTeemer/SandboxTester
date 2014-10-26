require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class TimeTests < Utils::SpawnerTester

  def test_load_ratio
    params = [ { :y => 0.3 } ] * 2
    params.each_index do |i|
      rpt = self.run_spawner_test($spawner, i + 1, params[i])
      assert_equal(Utils::LOAD_RATIO__RESULT, rpt[Utils::TERMINATE_REASON_FIELD])
    end
  end

  def test_time_limit
    params = [
        { :tl => 0.5 },
        { :d => 0.5 },
        { :d => 0.3 },
    ]
    params.each_index do |i|
      rpt = self.run_spawner_test($spawner, i + 1, params[i])
      assert_equal(Utils::TIME_LIMIT_EXCEEDED_RESULT, rpt[Utils::TERMINATE_REASON_FIELD])
    end
  end


end