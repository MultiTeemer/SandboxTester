require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class BaseTests < Utils::SpawnerTester

  def test_main
    (1..4).each do |i|
      rprt = run_spawner_test($spawner, i)
      exit_success?(rprt)
      asindel(0, rprt[Utils::USER_TIME_FIELD], 1e-3, i)
      asindel(0, rprt[Utils::WRITTEN_FIELD], 1e-3, i)
      asindel(0, rprt[Utils::PEAK_MEMORY_USED_FIELD], 3e-1, i)
    end
  end

end

