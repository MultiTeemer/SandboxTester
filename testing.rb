require 'fileutils'
require 'optparse'
require './utils.rb'

spawner = ARGV[0] # TODO: use optparse for retrieving command line args

if spawner == nil
    puts 'no spawner provided for testing'
    exit(0)
end

Dir.foreach('.') do |item|
    if Utils::system_dir?(item) == false && File.directory?(item)
        Dir.chdir(item)
        system('ruby', 'run.rb', spawner)
        Dir.chdir('..')
    end
end

