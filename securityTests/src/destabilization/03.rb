require 'fileutils'

i = 0

while true
  File.open("dir#{i += 1}.txt", 'w') { |file| file.write('a') }
end