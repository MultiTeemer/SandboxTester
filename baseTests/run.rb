require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class BaseTests < Utils::SpawnerTester

  def test_main
    (1..4).each do |i|
      rprt = run_spawner_test($spawner, i)
      exit_success?(rprt)
      assert_in_delta(rprt[Utils::USER_TIME_FIELD], 0, 1e-3)
      assert_in_delta(rprt[Utils::WRITTEN_FIELD], 0, 1e-3)
      assert_in_delta(rprt[Utils::PEAK_MEMORY_USED_FIELD], 0, 3e-1)
    end
  end

end

