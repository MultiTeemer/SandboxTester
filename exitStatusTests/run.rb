require 'test/unit'
require './tester.rb'
require './constants.rb'

class ExitStatusTests < Tester::SandboxTester

  def test_main
    statuses = [
      Constants::STACK_OVERFLOW_EXIT_STATUS,
      Constants::ACCESS_VIOLATION_EXIT_STATUS,
      Constants::INT_DIVIDE_BY_ZERO_EXIT_STATUS,
      Constants::PRIVILEGED_INSTRUCTION_EXIT_STATUS,
      Constants::STACK_OVERFLOW_EXIT_STATUS,
      Constants::STACK_OVERFLOW_EXIT_STATUS,
      Constants::ACCESS_VIOLATION_EXIT_STATUS, #Utils::ARRAY_BOUNDS_EXCEEDED_EXIT_STATUS, TODO: figure out
      Constants::ACCESS_VIOLATION_EXIT_STATUS,
      Constants::ACCESS_VIOLATION_EXIT_STATUS,
      Constants::ACCESS_VIOLATION_EXIT_STATUS,
    ]
    tests_count.each do |i|
      rpt = run_sandbox_test(i)
      idx = i - 1
      aseq(Constants::ABNORMAL_EXIT_PROCESS_RESULT, rpt[Constants::TERMINATE_REASON_FIELD], i)
      aseq(statuses[idx], rpt[Constants::EXIT_STATUS_FIELD], i) if idx < statuses.size
    end
  end

end