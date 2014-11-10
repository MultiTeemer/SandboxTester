require 'test/unit'
require './utils.rb'

class CmdArgsTests < Utils::SpawnerTester

  private

  def compare_with_none_error(expected, rpt, test_order)
    aseq(expected, rpt[Utils::SPAWNER_ERROR_FIELD] == Utils::NONE_ERROR_SP_ERROR, test_order)
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
    stuff.each do |item|
      (0..args.size).each do |length|
        args.combination(length).each do |combination|
          correct_args, wrong_args = {}, {}
          combination.each { |k| correct_args[k], wrong_args[k] = 1, 'something_wrong' }
          item[:func].call(run_spawner_test(item[:order], correct_args), length)
          error_on_execute?(run_spawner_test(item[:order], wrong_args))
          error_on_execute?(run_spawner_test(item[:order], wrong_args)) if wrong_args.size > 0
        end
      end
    end
  end

  def test_args_multipliers
    stuff.each do |item|
      Utils.spawner.cmd_args_multipliers.each do |cat, arr|
        arr.push('').each do |mult|
          item[:func].call(run_spawner_test(item[:order], {cat => "1#{mult} "}))
        end
      end
    end
  end

  def test_flags_combinations
    flags = Utils.spawner.cmd_flags
    stuff.each do |item|
      (0..flags.size).each do |length|
        flags.combination(length).each do |run_flags|
          item[:func].call(run_spawner_test(item[:order], {}, run_flags))
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
          error_on_execute?(run_spawner_test(test_order, args)) if test_order.nil? or args.size > 0
        end
      end
    end
  end

  def test_flags_args_combinations
    args, flags = Utils.spawner.cmd_args, Utils.spawner.cmd_flags
    stuff.each do |item|
      (0..args.size).each do |args_count|
        args.combination(args_count).each do |args_arr|
          run_args, error_args = {}, {}
          args_arr.each { |arg| run_args[arg.to_sym], error_args[arg.to_sym] = 1, 'something_wrong' }
          (0..flags.size).each do |flags_count|
            flags.combination(flags_count).each do |run_flags|
              item[:func].call(run_spawner_test(item[:order], run_args, run_flags))
              error_on_execute?(run_spawner_test(item[:order], error_args, run_flags)) if error_args.size > 0
            end
          end
        end
      end
    end
  end

end