require 'test/unit'
require './utils.rb'

class EnvironmentTests < Utils::SpawnerTester

  def test_main
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
          :output => out.file_name,
          :environment_mode => mode,
      }

      exit_success?(run_spawner_test(variables_counter_idx, args), test_counter)

      vars_count = out.read.to_i

      astrue(vars_count > 0, test_counter)

      test_counter += 1

      #check vars count
      env_vars.each do |vars|
        exit_success?(run_spawner_test(variables_counter_idx, args.merge(create_args.call(vars))), test_counter)

        astrue(vars_count + vars.keys.size == out.read.to_i, test_counter)

        test_counter += 1
      end

      get_var = lambda do |name|
        out.read.split(/\n/).map { |str| str.split(/=/) }.select { |pair| pair[0] == name.to_s }.flatten[1]
      end

      #check vars correctness
      env_vars.each do |vars|
        exit_success?(run_spawner_test(variables_printer_idx, args.merge(create_args.call(vars))), test_counter)

        vars.each { |k, v| aseq(v, get_var.call(k), test_counter) }

        test_counter += 1
      end

      #check vars replacement
      exit_success?(run_spawner_test(variables_printer_idx, args.merge({ :environment_vars => 'OS=12345' })), test_counter)
      aseq('12345', get_var.call('OS'), test_counter)
    end
  end

end