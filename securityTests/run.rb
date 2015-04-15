require 'test/unit'
require './args.rb'
require './utils.rb'

class SecurityTests < Utils::SpawnerTester

  def test_file_system
    args = [
        {
            :time_limit => Args::SecondsArgument.new(1),
        },
        {
            :write_limit => Args::KilobyteArgument.new(1),
        },
    ]

    tests_count.each do |i|
      args.each_index do |j|
        run_spawner_test(i, args[j])
      end
    end

  end

  def test_destabilization
    tests_count.each { |i| run_spawner_test(i) }
  end

  def test_exceptions
    tests_count.each do |i|
      if i % 2 == 1
        aseq(Utils::ABNORMAL_EXIT_PROCESS_RESULT, run_spawner_test(i)[Utils::TERMINATE_REASON_FIELD], i)
      else
        exit_success?(run_spawner_test(i), i)
      end
    end
  end

end