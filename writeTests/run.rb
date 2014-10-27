require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class WriteTests < Utils::SpawnerTester

  def test_write
    asindel(1, self.run_spawner_test(1)[Utils::WRITTEN_FIELD], 0.1, 0)
  end

  def test_write_limit
    exit_success?(self.run_spawner_test($spawner, 1))
    aseq(Utils::WRITE_LIMIT_EXCEEDED_RESULT, self.run_spawner_test(1, { :wl => 1e-2 })[Utils::TERMINATE_REASON_FIELD], 0)
  end

end