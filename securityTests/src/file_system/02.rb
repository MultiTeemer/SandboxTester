require 'fileutils'

i = 0

while true
  Dir.mkdir("dir#{i += 1}")
end