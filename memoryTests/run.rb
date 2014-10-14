require 'test/unit'
require '../utils.rb'

$spawner = ARGV[0]

class MemoryTests < Utils::SpawnerTester

  def test_successful_allocation
    Utils::compile_for_test(__method__)
    expected_memory = [
        { :memory => 4, :delta => 1e-1 },
        { :memory => 4, :delta => 1e-1 },
        { :memory => 4, :delta => 1e-1 },
        { :memory => 40, :delta => 2 },
        { :memory => 40, :delta => 2 },
        { :memory => 2000, :delta => 5}
    ]
    expected_memory.each_index do |i|
      rpt = self.run_spawner_test($spawner, i + 1)
      exit_success?(rpt)
      assert_in_delta(rpt[Utils::PEAK_MEMORY_USED_FIELD], expected_memory[i][:memory], expected_memory[i][:delta])
    end
    Utils::clear('.')
  end

  def test_memory_limit
    Utils::compile_for_test(__method__)
    memory_limit = [*([4] * 5), 1e-3]
    memory_limit.each_index do |i|
      rpt = self.run_spawner_test($spawner, i + 1, {:ml => memory_limit[i]})
      #puts rpt[Utils::MEMORY_LIMIT_FIELD],rpt[Utils::PEAK_MEMORY_USED_FIELD], rpt[Utils::TERMINATE_REASON_FIELD]
      #assert_equal(rpt[Utils::TERMINATE_REASON_FIELD], 'MemoryLimitExceeded')
    end
    Utils::clear('.')
  end

  def test_benchmark
    Utils::compile_for_test(__method__)
    rpt = self.run_spawner_test($spawner, 1, { :ml => 4 })
    puts 'Benchmark:'
    puts '-' * 30 + "\n"
    puts 'Malloc/free'
    puts "Terminate reason: #{rpt[Utils::TERMINATE_REASON_FIELD]}"
    puts '-' * 30 + "\n"
    rpt = self.run_spawner_test($spawner, 2, { :ml => 4 })
    puts 'New[]/delete[]'
    puts "Terminate reason: #{rpt[Utils::TERMINATE_REASON_FIELD]}"
    puts '-' * 30 + "\n"
    Utils::clear('.')
  end

end