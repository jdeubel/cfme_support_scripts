# 
# main.rb
# 
# Created on Nov 12, 2007, 1:36:38 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
$:.push("#{File.dirname(__FILE__)}")

puts "Hello World"
class TestClass
  include Enumerable
  attr_accessor :word1, :wordcount, :raw_data, :line_length  
  @@instance_count = 0
 
  def initialize(input)
    @word1 = input.split[0]
    @wordcount = input.split.size
    @line_length = input.size
    @raw_data = input
    @@instance_count += 1
    return self
  end
  def TestClass.each 
    require 'enumberable'
    self.raw_data
  end
  def get_instance_count
    @@instance_count
  end

end
log_line_array =Array.new

input_file = File.open(ARGV[0],"r")
 while line_in = input_file.gets
   log_line = TestClass.new(line_in)
   log_line_array <<log_line
   if log_line.get_instance_count == 10 then break
    end
 end
 log_line_array.each do 
   |x| puts "Raw data is '#{x.raw_data}' \n Word count is #{x.wordcount}\n Line length is #{x.line_length}"
    end
 exit

