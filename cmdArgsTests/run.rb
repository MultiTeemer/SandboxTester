require 'test/unit'
require './utils.rb'
require './tester.rb'
require './constants.rb'

class CmdArgsTests < Tester::SandboxTester

  private

  def create_temporary_file
    super('tmp.txt', 'some data')
  end

  def compare_with_none_error(expected, rpt, test_order)
    aseq(expected, rpt[Constants::SPAWNER_ERROR_FIELD] == Constants::NONE_ERROR_SP_ERROR, test_order)
  end

  def error_on_execute?(rpt, test_order = -1)
    compare_with_none_error(false, rpt, test_order)
  end

  def execute_success?(rpt, test_order = -1)
    compare_with_none_error(true, rpt, test_order)
  end

  def stuff
    [
        {
            :order => 1,
            :func => Proc.new { |rpt| execute_success?(rpt) },
        },
        {
            :order => nil,
            :func => Proc.new { |rpt| error_on_execute?(rpt) },
        },
    ]
  end

  public

  def test_args_combinations
    args = Utils.spawner.cmd_args
    create_temporary_file
    stuff.each do |item|
      (0..args.size).each do |length|
        args.combination(length).each do |combination|
          correct_args, wrong_args = {}, {}
          combination.each do |k|
            correct_args[k] = Utils.spawner.get_correct_value_for(k)
            wrong_args[k] = Utils.spawner.get_wrong_value_for(k)
          end
          #puts '-' * 30 + 'correct'
          #puts correct_args
          #puts run_spawner_test(item[:order], wrong_args)
          #puts '-' * 30
          item[:func].call(run_sandbox_test(item[:order], correct_args), length)
          #puts '-' * 30 + 'wrong'
          #puts wrong_args
          #puts run_spawner_test(item[:order], wrong_args)
          #puts '-' * 30
          error_on_execute?(run_sandbox_test(item[:order], wrong_args)) if wrong_args.size > 0
        end
      end
    end
  end

  def test_args_multipliers
    stuff.each do |item|
      Utils.spawner.cmd_args_multipliers.each do |cat, arr|
        arr.push('').each do |mult|
          item[:func].call(run_sandbox_test(item[:order], {cat => "1#{mult} "}))
        end
      end
    end
  end

  def test_flags_combinations
    flags = Utils.spawner.cmd_flags
    stuff.each do |item|
      (0..flags.size).each do |length|
        flags.combination(length).each do |run_flags|
          item[:func].call(run_sandbox_test(item[:order], {}, run_flags))
        end
      end
    end
  end

  def test_flags_as_args #TODO: hide spawner output
    flags = Utils.spawner.cmd_flags
    [1, nil].each do |test_order|
      (0..flags.size).each do |length|
        flags.combination(length).each do |run_flags|
          args = {}
          run_flags.each { |flag| args[flag.to_sym] = 1 }
          error_on_execute?(run_sandbox_test(test_order, args)) if test_order.nil? or args.size > 0
        end
      end
    end
  end

  def test_flags_args_combinations
    args, flags = Utils.spawner.cmd_args, Utils.spawner.cmd_flags
    create_temporary_file
    stuff.each do |item|
      (0..args.size).each do |args_count|
        args.combination(args_count).each do |args_arr|
          run_args, error_args = {}, {}
          args_arr.each do |arg|
            run_args[arg.to_sym]  = Utils.spawner.get_correct_value_for(arg)
            error_args[arg.to_sym] = Utils.spawner.get_wrong_value_for(arg)
          end
          (0..flags.size).each do |flags_count|
            flags.combination(flags_count).each do |run_flags|
              item[:func].call(run_sandbox_test(item[:order], run_args, run_flags))
              error_on_execute?(run_sandbox_test(item[:order], error_args, run_flags)) if error_args.size > 0
            end
          end
        end
      end
    end
  end

end