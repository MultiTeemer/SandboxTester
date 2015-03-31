require 'test/unit'
require './utils.rb'

class MemoryTests < Utils::SpawnerTester

  def test_successful_allocation
    expected_memory = [
        { :memory => 4, :delta => 1e-1 },
        { :memory => 4, :delta => 1e-1 },
        { :memory => 4, :delta => 1e-1 },
        { :memory => 40, :delta => 2 },
        { :memory => 40, :delta => 2 },
        { :memory => 2000, :delta => 5}
    ]
    expected_memory.each_index do |i|
      rpt = run_spawner_test(i + 1)
      exit_success?(rpt)
      asindel(expected_memory[i][:memory], rpt[Utils::PEAK_MEMORY_USED_FIELD], expected_memory[i][:delta], i)
    end
  end

  def test_memory_limit
    memory_limit = [1 << 20 + 1 << 19] * 12
    memory_limit.each_index do |i|
      rpt = run_spawner_test(i + 1, { :memory_limit => memory_limit[i] })
      aseq(Utils::MEMORY_LIMIT_EXCEEDED_RESULT, rpt[Utils::TERMINATE_REASON_FIELD], i + 1)
    end
  end

  def test_benchmark
    sep = '-' * 30 + "\n"

    puts sep
    puts 'Sandbox memory overhead'
    puts run_spawner_test(2)[Utils::PEAK_MEMORY_USED_FIELD]
    puts sep

    puts 'Maximum memory allocation threshold'
    l, r = 3.0, 5.0
    delta = 1e-6
    while (l - r).abs >= delta
      m = (l + r) / 2
      rpt = run_spawner_test(1, { :memory_limit => '4M' }, [], [ m * 2 ** 20 ])
      #puts [m * 2 ** 20, rpt[Utils::TERMINATE_REASON_FIELD], rpt[Utils::PEAK_MEMORY_USED_FIELD]].join ' '
      if rpt[Utils::TERMINATE_REASON_FIELD] == Utils::MEMORY_LIMIT_EXCEEDED_RESULT
        r = m
      else
        l = m
      end
    end
    puts m
    puts sep
  end

end