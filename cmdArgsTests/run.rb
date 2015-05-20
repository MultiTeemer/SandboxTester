require 'test/unit'
require './utils.rb'
require './tester.rb'
require './constants.rb'
require './sandbox_args.rb'

class CmdArgsTests < Tester::SandboxTester

  private

  def error_on_execute(rpt, test_order)
    reason = rpt[Constants::TERMINATE_REASON_FIELD]

    reason.nil? or reason != Constants::EXIT_PROCESS_RESULT
  end

  public

  def test_correct_args
    args = Utils.sandbox.cmd_args

    tests_counter = 0

    (0..args.length).each do |comb_len|
      args.combination(comb_len).each do |comb|
        run_args = {}

        comb.each do |arg|
          run_args[arg.mean] = arg.class.correct_value
        end

        rpt = run_sandbox_test(1, run_args)
        runs_counter = 0

        while rpt[Constants::TERMINATE_REASON_FIELD].nil? and runs_counter < 100
          rpt = run_sandbox_test(1, run_args)
          runs_counter += 1
        end

        exit_success?(rpt, tests_counter += 1)
      end
    end
  end

  def test_wrong_args
    args = Utils.sandbox.cmd_args

    tests_counter = 0

    args.each do |arg|
      tests_counter += 1

      error_on_execute(run_sandbox_test(1, {arg.mean => arg.class.wrong_value}), tests_counter)
    end
  end

  def test_hide_report
    omit_unless(Utils.sandbox.has_feature?('hide_report'))

    rpt = run_sandbox_test(1, { :hide_report => SandboxArgs::HideReportFlag.new })

    aseq(nil, rpt[Constants::TERMINATE_REASON_FIELD], 1)
  end

end