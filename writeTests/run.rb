require 'test/unit'
require './utils.rb'

class WriteTests < Utils::SpawnerTester

  def test_write
    asindel(1, self.run_spawner_test(1)[Utils::WRITTEN_FIELD], 0.1, 0)
  end

  def test_write_limit
    tests_count.each do |test_order|
      exit_success?(self.run_spawner_test(test_order))
      aseq(Utils::WRITE_LIMIT_EXCEEDED_RESULT, self.run_spawner_test(1, { :wl => '1kB' })[Utils::TERMINATE_REASON_FIELD], test_order)
    end
  end

end