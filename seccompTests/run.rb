require 'test/unit'
require './tester.rb'
require './constants.rb'
require './signals.rb'

class SeccompTests < Tester::SandboxTester

  def test_main
    tests_count.each do |i|
      rpt = run_sandbox_test(i, { :security => Args::FlagArgument.new(true) })
      #exit_success?(rpt)
      aseq("1", rpt[Constants::SECURITY_LEVEL_FIELD], i)
      aseq(Signals::SIGSYS, rpt[Constants::EXIT_STATUS_FIELD], i)
      aseq(Constants::ABNORMAL_EXIT_PROCESS_RESULT, rpt[Constants::TERMINATE_REASON_FIELD], i)
    end
  end

end
