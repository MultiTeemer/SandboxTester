require 'fileutils'

all = 0

Dir.entries('..').each do |dir|
  next if %w[ . .. ].include?(dir)

  all += Dir.entries('../' + dir).count
end

puts all