require 'test/unit'
require './tester.rb'
require './constants.rb'
require './signals.rb'

class SignalsTests < Tester::SandboxTester

    def test_exits
      rpt = run_sandbox_test(1)
      aseq(ExitStatus::EXIT_SUCCESS, rpt[Constants::EXIT_STATUS_FIELD], 1)
      rpt = run_sandbox_test(2)
      aseq(ExitStatus::EXIT_FAILURE, rpt[Constants::EXIT_STATUS_FIELD], 2)
    end

    def test_signals
      rpt = run_sandbox_test(1)
      aseq(Signals::SIGFPE, rpt[Constants::EXIT_STATUS_FIELD], 1)
      rpt = run_sandbox_test(2)
      aseq(Signals::SIGSEGV, rpt[Constants::EXIT_STATUS_FIELD], 2)
      rpt = run_sandbox_test(3)
      aseq(Signals::SIGPWR, rpt[Constants::EXIT_STATUS_FIELD], 3)
    end
end
