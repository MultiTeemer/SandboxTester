require 'test/unit'
require './utils.rb'
require './tester.rb'
require './constants.rb'

class EnvironmentTests < Tester::SandboxTester

  def test_modes
    omit_unless(Utils.spawner.has_feature?('environment_modes'))

    env_vars = [
        {
          :var => 'val',
        },
        {
            :var1 => 'val1',
            :var2 => 'val2',
        },
    ]
    test_counter = 1
    variables_counter_idx = 1
    variables_printer_idx = 2
    create_args = lambda do |hash|
      arr = []

      hash.each do |k, v|
        arr.push(k.to_s + '=' + v.to_s)
      end

      { :environment_vars => arr }
    end

    Utils.spawner.environment_mods.each do |mode|
      out = FileHandler.new('tmp.txt')
      args = {
          :output => out.path,
          :environment_mode => mode,
      }

      exit_success?(run_sandbox_test(variables_counter_idx, args), test_counter)

      vars_count = out.read.to_i

      test_counter += 1

      #check vars count
      env_vars.each do |vars|
        exit_success?(run_sandbox_test(variables_counter_idx, args.merge(create_args.call(vars))), test_counter)

        astrue(vars_count + vars.keys.size == out.read.to_i, test_counter)

        test_counter += 1
      end

      get_var = lambda do |name|
        out.read.split(/\n/).map { |str| str.split(/=/) }.select { |pair| pair[0] == name.to_s }.flatten[1]
      end

      #check vars correctness
      env_vars.each do |vars|
        exit_success?(run_sandbox_test(variables_printer_idx, args.merge(create_args.call(vars))), test_counter)

        vars.each { |k, v| aseq(v, get_var.call(k), test_counter) }

        test_counter += 1
      end

      #check vars replacement
      exit_success?(run_sandbox_test(variables_printer_idx, args.merge({ :environment_vars => 'OS=12345' })), test_counter)
      aseq('12345', get_var.call('OS'), test_counter)
    end
  end

  def test_vars
    var_name = 'var'
    var_value = 'val'
    out_handler = FileHandler.new('out.txt')
    args = {
        :environment_vars => [var_name + '=' + var_value],
        :output => out_handler.path,
    }

    exit_success?(run_sandbox_test(1, args), 1)

    run_sandbox_test(2, args, [], [var_name])

    aseq(var_value, out_handler.read, 2)

    ids = (1..50).to_a.map { |_| rand(1 .. 1 << 15).to_s }
    vars = ids.map { |o| "#{var_name + o}=#{var_value + o}" }
    args = {
        :environment_vars => vars,
    }

    exit_success?(run_sandbox_test(1, args), 3)

    ids.each do |id|
      run_sandbox_test(2, args, [], [var_name + id])
      aseq(var_value, out_handler.read, 4)
    end
  end

end