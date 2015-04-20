require 'fileutils'

bytes = 0

Dir.entries('..').each do |entry|
  next if %w[ . .. ].include?(entry)
  next unless File.directory?(entry) or File.absolute_path(entry) != Dir.getwd

  files = Dir.entries('../' + entry).select{ |something| File.file?(something) }

  bytes += files.map{ |file| IO.read("../#{entry}/#{file}").bytesize }.reduce(:+)
end

puts bytes
