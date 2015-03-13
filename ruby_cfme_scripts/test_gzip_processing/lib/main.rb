# To change this template, choose Tools | Templates
# and open the template in the editor.
#
#require 'zlib'
require 'stringio'

fx = "gzip\\evm.log.gz"

#s = Time.new
#infile = Zlib::GzipReader.new(File.new(f, "r"))
##infile = IO.popen("zcat #{f}", "r")
#linecount = 0
#while x = infile.read { |l|
##infile.each_line { |l|
#  linecount += 1 }
#end
#e = Time.new
#print "Read #{linecount} lines in #{e - s} seconds\n"

  Zlib::GzipReader.open(fx) {|gz|
    $blob = StringIO.new(gz.read)
#    print gz.read
  }
#  print blob.size
while x =$blob.gets
  puts x
end

#  File.open(fx) do |f|
#    gz = Zlib::GzipReader.new(f)
#     x = StringIO.new(gz.readlines)
#    size_x = x.length
#    while in_line = x.gets
##    x.each do |x_line|
#      puts in_line
#    end
##    print gz.
#    gz.close
#  end

