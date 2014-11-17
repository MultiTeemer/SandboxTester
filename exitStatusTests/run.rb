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
      rpt = run_spawner_test(i)
      idx = i - 1
      aseq(Utils::ABNORMAL_EXIT_PROCESS_RESULT, rpt[Utils::TERMINATE_REASON_FIELD], idx)
      aseq(statuses[idx], rpt[Utils::EXIT_STATUS_FIELD], idx) if idx < statuses.size
    end
  end

end