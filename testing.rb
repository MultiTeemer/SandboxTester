require 'fileutils'
require 'inifile'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'optparse'
require './utils.rb'

tests_tags = %w[ base exitStatus memory time write cmdArgs environment security ]

tests_tags.each { |tag| require "./#{tag}Tests/run.rb" }

options = {
    :tests => {},
}

OptionParser.new do |opts|

  tests_tags.each do |tag|
    opts.on("--#{tag}", "--#{tag}[=OPTIONAL]", "Run test for #{tag}") do |m|
      options[:tests][tag.to_sym] = m.nil? ? true : m.split(',')
    end
  end

  opts.on('--path=MANDATORY', '', 'Path to testing item') { |path| options[:path] = path }

  opts.on('--type=MANDATORY', '', 'Type of testing item') do |type|
    options[:type] = type if %w[ cats cats_old pcms2 ].include? type
  end

  opts.on('--one=MANDATORY', '', 'Run single test') do |test|
    options[:single] = test
  end

end.parse!

options[:type] = 'cats' if options[:type].nil?
options[:path] = IniFile.load('settings.ini')[options[:type]]['path'] if options[:path].nil?
tests_tags.each { |tag| options[:tests][tag.to_sym] = true  } if options[:tests].size == 0

exit 0 if options[:path].nil?

Utils.init_spawner(options[:type], options[:path])

test_suit = Test::Unit::TestSuite.new("Testing #{options[:path]}")

options[:tests].each do |tag, cat|

  name = tag.to_s

  if cat.kind_of?(Array)
    tests_names = cat
  else
    tests_names = Dir.entries("#{name}Tests/src/") - %w[ . .. ]
  end

  class_name = name
  class_name[0] = name[0].upcase

  tests_names.each do |test_name|
    test_suit << Object.const_get("#{class_name}Tests").new("test_#{test_name}", options[:single])
  end

end

Test::Unit::UI::Console::TestRunner.run(test_suit)
