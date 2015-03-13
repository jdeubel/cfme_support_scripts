# 
# main.rb
# 
# Created on Oct 25, 2007, 1:33:14 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
require "stringio"

file_count = ARGV.size
puts file_count
Buffer_read = 1024 # default size to read from end of log file


ARGV.each do |filename| 
  case filename
  when /(\S*)\-(\S*)\-(\S*)\-(\d*)T(\d*)Z\-(\S*)\.(\S*)/ then 
      miqagent = $1
      vmmhostname = $2
      miqbuild = $3
      logdate = $4
      logstarttime = $5
      logsegment = $6
      filetype = $7
      puts "agent name is '#{$1}'\nhost name is '#{$2}'\nbuild number is '#{$3}'\n log begin date & time is '#{$4}-#{$5}'
           \nthis is log segment number '#{$6}' and the file type is '#{$7}'"
  else puts "file named #{filename} \ndoes not conform to logging standard, skipping"
    bad_file_name = true
    next
  end
  next if bad_file_name
  file_size = 0
  file_size = File.stat(filename).size if File.file?(filename) # if real file then use size from stat function
  puts "for #{filename} file size is #{File.stat(filename).size}"
  next if File.stat(filename).size == 0
#  case file_size        # look at file size to see if it is smaller than a cluster size or so
#  when buffer_read > file_size then end_offset = file_size    # if too small, then read the whole thing into memory
#  else end_offset = buffer_read       # else just read the last "buffer_read" butes 
#  end
 logfile = File.open(filename,"r")
 line1 = logfile.gets
 logfile.close
 puts "Buffer_read value is '#{Buffer_read}' file_size value is '#{file_size}'"
# case file_size
# when 0  then
# when
if   Buffer_read > file_size  then 
   puts "doing read of '#{filename}' with size = '#{file_size}' for #{file_size} bytes beginning at offset 0"
    lastblock = IO.read(filename,file_size,0)
end
if  file_size >= Buffer_read then 
    puts "doing read of '#{filename}' with size = '#{file_size}' for #{Buffer_read} bytes beginning at offset #{file_size - Buffer_read}"
   lastblock = IO.read(filename, Buffer_read, (file_size - Buffer_read))
 end
# lastblock = IO.read(filename,end_offset,file_size-end_offset)
 puts "first log line is ************\n#{line1}\n"
# puts "************\nLast Block\n#{lastblock}\n\n\n"
 puts "#size of last block read in is '#{lastblock.size}'"
 sio = StringIO.new(lastblock)
 good_last_line = " no good last line found"
  while last_lines = sio.gets
    case last_lines
    when /\s*\[\-\-\-\-\]\s*[I|D|W|E|F|S]\,\s*\[(\d*)\-(\d*)\-(\d*)T(\d*)\:(\d*):(\d*)\.(\d*)\s*\#(\d*)\]/ then good_last_line = last_lines
      # line above is regulare expression for standard log line prefix
    else next
    end
  end
puts " ** #{good_last_line}"  
  name_array=Array.new
  name_array=filename.split(".")
  puts name_array.size
  name_array.each do |x|
  puts x  
  end
#  puts name_array[0..size-1]
  
puts  name_array.inspect
end
   
#var1[] = *ARGV
#var1.inspect
exit
puts "Hello World"
