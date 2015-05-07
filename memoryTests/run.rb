require 'test/unit'
require './args.rb'
require './tester.rb'
require './constants.rb'

class MemoryTests < Tester::SpawnerTester

  def test_successful_allocation
    expected_memory = [
        { :memory => Args::MegabyteArgument.new(4), :delta => 1e-1 },
        { :memory => Args::MegabyteArgument.new(4), :delta => 1e-1 },
        { :memory => Args::MegabyteArgument.new(4), :delta => 1e-1 },
        { :memory => Args::MegabyteArgument.new(40), :delta => 2 },
        { :memory => Args::MegabyteArgument.new(40), :delta => 2 },
        { :memory => Args::MegabyteArgument.new(2000), :delta => 5}
    ]
    expected_memory.each_index do |i|
      rpt = run_spawner_test(i + 1)
      exit_success?(rpt)
      asindel(expected_memory[i][:memory], rpt[Constants::PEAK_MEMORY_USED_FIELD], expected_memory[i][:delta], i)
    end
  end

  def test_memory_limit
    memory_limit = [Args::MegabyteArgument.new(3)] * 12
    memory_limit.each_index do |i|
      rpt = run_spawner_test(i + 1, { :memory_limit => memory_limit[i] })
      aseq(Constants::MEMORY_LIMIT_EXCEEDED_RESULT, rpt[Constants::TERMINATE_REASON_FIELD], i + 1)
    end
  end

  def test_benchmark
    sep = '-' * 30 + "\n"

    puts sep
    puts 'Sandbox memory overhead'
    puts run_spawner_test(2)[Constants::PEAK_MEMORY_USED_FIELD]
    puts sep

    puts 'Maximum memory allocation threshold'
    l, r = 3.0, 5.0
    delta = 1e-6
    while (l - r).abs >= delta
      m = (l + r) / 2
      rpt = run_spawner_test(1, { :memory_limit => Args::MegabyteArgument.new(4) }, [], [ m * 2 ** 20 ])
      #puts [m * 2 ** 20, rpt[Constants::TERMINATE_REASON_FIELD], rpt[Constants::PEAK_MEMORY_USED_FIELD]].join ' '
      if rpt[Constants::TERMINATE_REASON_FIELD] == Constants::MEMORY_LIMIT_EXCEEDED_RESULT
        r = m
      else
        l = m
      end
    end
    puts m
    puts sep
  end

end