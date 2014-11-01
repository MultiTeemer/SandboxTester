require 'test/unit'
require './utils.rb'

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
      Utils::ACCESS_VIOLATION_EXIT_STATUS,
      Utils::ACCESS_VIOLATION_EXIT_STATUS,
    ]
    tests_count.each do |i|
      rpt = self.run_spawner_test(i)
      aseq(rpt[Utils::TERMINATE_REASON_FIELD], Utils::ABNORMAL_EXIT_PROCESS_RESULT, i - 1)
      aseq(rpt[Utils::EXIT_STATUS_FIELD], statuses[i - 1], i - 1) if i - 1 < statuses.size
    end
  end

end