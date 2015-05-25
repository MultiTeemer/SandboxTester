require 'fileutils'

File.open("../#{ARGV[0]}", 'w') { |f| f.write(1) }