require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class ExitStatusTests < Utils::SpawnerTester

  def test_main
    statuses = [
      Utils::STACK_OVERFLOW_EXIT_STATUS,
      Utils::ACCESS_VIOLATION_EXIT_STATUS,
      Utils::INT_DIVIDE_BY_ZERO_EXIT_STATUS,
      Utils::PRIVILEGED_INSTRUCTION_EXIT_STATUS,
      Utils::STACK_OVERFLOW_EXIT_STATUS,
      Utils::STACK_OVERFLOW_EXIT_STATUS,
      Utils::ACCESS_VIOLATION_EXIT_STATUS, #Utils::ARRAY_BOUNDS_EXCEEDED_EXIT_STATUS, TODO: figure out
      Utils::ACCESS_VIOLATION_EXIT_STATUS,
    ]
    statuses.each_index do |i|
      rpt = self.run_spawner_test($spawner, i + 1)
      assert_equal(rpt[Utils::EXIT_STATUS_FIELD], statuses[i])
      assert_equal(rpt[Utils::TERMINATE_REASON_FIELD], Utils::ABNORMAL_EXIT_PROCESS_RESULT)
    end
  end

end