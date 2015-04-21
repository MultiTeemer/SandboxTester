require 'fileutils'

File.open('backdoor.txt', 'w') { |f| f.write('some data') }