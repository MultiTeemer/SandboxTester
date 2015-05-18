require 'test/unit'
require './tester.rb'
require './constants.rb'

class BaseTests < Tester::SandboxTester

  def test_main
    tests_count.each do |i|
      rpt = run_sandbox_test(i)
      exit_success?(rpt)
      asindel(0, rpt[Constants::USER_TIME_FIELD], 1e-2, i)
      asindel(0, rpt[Constants::WRITTEN_FIELD], 1e-3, i)
      asindel(0, rpt[Constants::PEAK_MEMORY_USED_FIELD], 3e-1, i)
    end
  end

end

