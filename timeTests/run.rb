require 'fileutils'
require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class TimeTests < Utils::SpawnerTester

  def test_time_limit
    Utils::compile_for_test(__method__)
    puts self.run_spawner_test($spawner, 1, {:tl => 0.5})

    Utils::clear(Dir.getwd)
  end


end