require 'fileutils'

File.open(ARGV[0], 'a+') { |f| f.write(1) }