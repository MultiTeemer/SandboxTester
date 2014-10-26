require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class WriteTests < Utils::SpawnerTester

  def test_write
    assert_in_delta(1, self.run_spawner_test($spawner, 1)[Utils::WRITTEN_FIELD], 0.1)
  end

  def test_write_limit
    exit_success?(self.run_spawner_test($spawner, 1))
    assert_equal(Utils::WRITE_LIMIT_EXCEEDED_RESULT, self.run_spawner_test($spawner, 1, { :wl => 1e-2 })[Utils::TERMINATE_REASON_FIELD])
  end

end