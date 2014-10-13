require 'fileutils'
require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class WriteTests < Utils::SpawnerTester

  def test_write
    Utils::compile_for_test(__method__)
    assert_in_delta(self.run_spawner_test($spawner, 1)[Utils::WRITTEN_FIELD], 1, 0.1)
    Utils::clear(Dir.getwd)
  end

  def test_write_limit
    Utils::compile_for_test(__method__)
    exit_success?(self.run_spawner_test($spawner, 1))
    assert_equal(self.run_spawner_test($spawner, 1, { :wl => 1e-2 })[Utils::TERMINATE_REASON_FIELD], Utils::WRITE_LIMIT_EXCEEDED_RESULT)
    Utils::clear(Dir.getwd)
  end

end