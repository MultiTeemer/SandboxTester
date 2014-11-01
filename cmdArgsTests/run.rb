require 'test/unit'
require './utils.rb'

class CmdArgsTests < Utils::SpawnerTester

  private

  def compare_with_none_error(expected, rpt, test_order)
    puts rpt if expected != (rpt[Utils::SPAWNER_ERROR_FIELD] == Utils::NONE_ERROR_SP_ERROR)
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
    [1, nil].each do |test_order|
      (0..args.size).each do |length|
        args.combination(length).each do |combination|
          args = {}
          combination.each { |k| args[k] = 'something_wrong' }
          error_on_execute?(run_spawner_test(test_order, args), length)
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

end