# 
# main.rb
# 
# Created on Nov 1, 2007, 2:59:55 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

#       set_trace_func proc {|event, file, line, id, binding, classname | printf  "%8s %s:%02d %10s %8s\n",event, file, line, id, classname}

$:.push("#{File.dirname(__FILE__)}")
require 'date'                        #require date functions
require 'parsedate'                   #require parsedate
require 'rexml/document'              #require xml
require 'pp'                          #require prettyPrint
require 'csv'                         #require csv module
require 'rubygems'
require 'dictionary'                  #order hash keys statically by definition  
include ParseDate                     #prepare for date parsing
include 

def file_analyze(target)
  
end

def parse_controller_line(target,instance,last_prefix_line)
#  puts "Line number #{instance.line_count} at offset #{instance.msg_offset}=>#{target}"
  command_hash = Dictionary.new
  command_hash["start date"] = Time.at(instance.get_last_log_time).gmtime.strftime("%m/%d/%Y")
                 command_hash["hour" ] =  Time.at(instance.get_last_log_time).gmtime.hour 
                 command_hash["start time" ] =  instance.get_last_log_time
                 command_hash["process id"] = instance.msg_process_id
                 command_hash["needs review" ] =  nil
                 command_hash["originated_at" ] =  target.split[3]
                 command_hash["addressed_to_server"] = nil
                 command_hash["duration"] =  nil
                 command_hash["controller" ] =  target.split[1]
                 command_hash["method_name" ] =  nil
                 command_hash["method_duration" ] =  nil
                 command_hash["command" ] =  target.split[-1].tr("[]","  ").strip
                 command_hash["begins_at_offset" ] =  instance.msg_offset
                 command_hash["line_number_begin"] =  instance.line_count
                 command_hash["line_number_end"] =  nil
                 command_hash["ends_at_offset" ] =  nil
                  
                  
                   
#puts  command_hash.inspect    
return command_hash
end
def parse_completed_line(target,instance,command_hash)

#  command_hash = {"line_number_end" => instance.line_count,
#                   "ends_at_offset"=> instance.msg_offset,
#                   "duration"=>nil,
#                   "addressed_to_server" => nil
#                   }
  command_hash["line_number_end"] = instance.line_count
  command_hash["ends_at_offset"] = instance.msg_offset
  
  
  if /: Completed in (\d*\.\d*)[[:print:]]{1,100}\|[[:print:]]{1,100}\|[[:print:]]{1,100}\[http:\/\/(\S*?)\/\S*\]/ =~ target then 
    command_hash["duration"] = $1
    command_hash["addressed_to_server"] = $2
    end

#  puts command_hash.inspect
#  pp command_hash
  return command_hash
end

class MiqServerLog 
	attr_accessor :msgid, :msg_type, :msg_time, :msg_offset, :msg_process_id, :msg_type_text, :msg_payload
#       Class Attributes removed from above :agent_name, :agent_os, :agent_version, :host_os, :host_name, :host_IP_Address        
#	attr_reader :count, :good_count, :info_count, :error_count, :debug_count, :fatal_count,:warn_count
        @@agent_log = nil
        @@application_log = nil
        @@count = 0
	@@good_count = 0
	@@info_count = 0
	@@error_count = 0
	@@debug_count = 0
	@@fatal_count = 0
	@@warn_count = 0
	@@summary_count = 0
	@@host_os = nil
	@@host_os_version = nil
	@@host_vmdb_id = nil
	@@host_IP_Address = nil
	@@host_name = nil
	@@agent_name = nil
	@@agent_version = nil
	@@appliance_IP_Address = nil
	@@xml_initialization = true
        @@xml_error_initialization = true
	@@msg_server_time = 0
	@@server_agent_offset = 0
	@@invalid_count = 0
	@@startup_count = 0
	@@shutdown_count = 0
	@@log_start_time = nil
	@@log_end_time = nil
        @@pending_payload = nil
        @@prefix_missing = nil	
	@@xml_detail = nil
        @@log_file_name = nil
        @@log_file_size = nil
	
	def parse_log_line(log_line)
        return false if log_line.size  < 3
        @has_prefix = true
        @has_payload = true
        @msg_type = nil
	if /-- :/ !~ log_line then 
                payload = nil 
                @@pending_payload = true
                @@prefix_missing = true  
#		return false 
        else
        prefix, payload = log_line.split("-- :") # separate prefix and payload  
        @has_prefix = true
	end       
	if payload == nil || payload.strip.size < 3 then 
          payload = nil     # if no  payload, then it follows on a different line. 
           @@pending_payload = true           
	else
	payload = payload.chomp.strip
	end

        @has_prefix = nil if prefix == nil
        @has_payload = nil if payload == nil
#	return false if payload == nil
	@@good_count += 1
#	puts prefix
#	puts payload
	prefix_array = prefix.tr("[]#,","    ").split  #remove special characters from prefix area
	@msgid = prefix_array[0]                       # currently all dashes 
	@msg_type = prefix_array[1]                     #one character- comma removed
	case @msg_type                                  # only these msg types are defined
	when "I" then @@info_count += 1
	when "E" then @@error_count += 1
	when "D" then @@debug_count += 1
	when "W" then @@warn_count += 1
	when "S" then @@summary_count += 1
	when "F" then @@fatal_count += 1
	else
          puts "Unknown message type '#{prefix_array[1]}' encountered- check with development"
	end
#	puts prefix_array[2]
#	@msg_time = ParseDate.parsedate(prefix_array[2])
#	puts "log date is #{prefix_array[2]} is retained as #{@msg_time} \n"
	if /(\d*)-(\d*)-(\d*)T(\d*):(\d*):(\d*).(\d*)/ =~ prefix_array[2] then
	   @msg_time = "%10.6f" % Time.gm($1,$2,$3,$4,$5,$6,$7).to_f
           @@log_end_time = @msg_time # grab each time as it may be the last in log
#	   puts @msg_time.to_f
#	   puts "%10.6f" % @msg_time.to_f
	   end
#	return false if $1 == nil	   
	@msg_process_id = prefix_array[3]
	@msg_type_text = prefix_array[4]
	@msg_payload = payload
	if /Server Time:\[(\d*)-(\d*)-(\d*)T(\d*):(\d*):(\d*)Z/ =~ payload then
#       current log only returns server time in seconds, so set microseconds = 0 below	
		@@msg_server_time = Time.gm($1,$2,$3,$4,$5,$6,0).to_i
		@@server_agent_offset = @msg_time.to_f - @@msg_server_time
		end
	
#	puts self.inspect
#	return self
	end
        
        def file_attributes(input)
          @@log_file_name = input
          @@log_file_size = 0
          @@log_file_size = File.size(input)
        end
        def get_pending_payload
          @@pending_payload
        end
        def reset_pending_payload
          @@pending_payload = nil
        end
        def get_prefix_missing
          @@prefix_missing
        end
        def reset_prefix_missing
          @@prefix_missing = nil
        end
        
	def initialize(log_line, offset)
	@@count += 1
        @valid = false
        @msg_offset = offset
        if log_line.size < 3 then 
          @valid = false
            return @valid           
        end
#	puts "log line # #{@@count} line offset is #{@msg_offset}"
	# the return from this routine indicates if the line is a valid log line
        if /\[\-\-\-\-\]\s[I|S|D|E|W|F],\s\[(\S*)T(\S*)\s\#(\d*)\] / =~ log_line then 
          @valid = parse_log_line(log_line)
          timestamp = $1 + "T" + $2+ "Z"
          @@prefix_missing = nil
 #         puts "converted time of #{timestamp} is #{Time.iso8601(timestamp).to_f}"
        else @@prefix_missing =  true
        end
	# if it is not valid, then increment invalid_count
	if @valid then
	else @@invalid_count += 1;
	end
	# return to the caller with an indication if the input is a valid log line
#	return @valid
	end
	
	def to_xml(target)
	xml_initialize(target) if @@xml_initialization # check to see if output already initialized
#	node2 = target.add_element("line")
	node2 = @@xml_detail.add_element("line")
#	node2.target.add_element("line")
#	@@xml_detail = node2
	node2.add_attribute("msgid",@msgid)
	node2.add_attribute("type",@msg_type)
	node2.add_attribute("time",@msg_time)
	node2.add_attribute("process_id",@msg_process_id)
	node2.add_attribute("type_text",@msg_type_text)
	node2.add_attribute("payload",@msg_payload)
	node2.add_attribute("agent_server_time_offset",@@server_agent_offset)
	end
        
        def to_xml_error(target)
          xml_error_initialize(target) if @@xml_error_initialization #check to see if output already initialized
          err_node2 = @@xml_error_detail.add_element("error_line")
          err_node2.add_attribute("line",@@count)
          err_node2.add_attribute("offset",@msg_offset)
          err_node2.add_attribute("type",@msg_type)
        end
	
	def xml_initialize(target)
	@@xml_initialization = false
#	target = REXML::Document.new()
#	target  << REXML::XMLDecl.new(1.0, "UTF-8")
	node0 = target.add_element("miqhost_log_info")
	@@xml_miqhost_log_level = node0
#	puts node0
	node1 = node0.add_element("log_lines")
	@@xml_log_lines_level = node1
#	puts node1
#	node2 = node1.add_element("line")
	@@xml_detail = node1
#	puts "@@xml_detail value is #{@@xml_detail}"
#	puts node2
#	puts target
#	puts target.class
#	puts target.inspect
	end
        
        def xml_error_initialize(target)
        @@xml_error_initialization = false  
        err_node0 = target.add_element("miqhost_errors_index")
        @@xml_miqhost_errlog_level = err_node0
        err_node1 = err_node0.add_element("errlog_lines")
        @@xml_error_detail = err_node1
        end
	
	def terminate_log
	node0 = @@xml_miqhost_log_level
	node0.add_attribute("total_line_count",@@count)
	node0.add_attribute("valid_log_lines",@@good_count)
	node0.add_attribute("info_line_count",@@info_count)
	node0.add_attribute("warning_line_count",@@warn_count)
	node0.add_attribute("fatal_line_count",@@fatal_count)
	node0.add_attribute("debug_line_count",@@debug_count)
	node0.add_attribute("error_line_count",@@error_count)
	node0.add_attribute("summary_line_count",@@summary_count)	
	node0.add_attribute("host_name",@@host_name)
	node0.add_attribute("host_os",@@host_os)
	node0.add_attribute("host_IP_Address",@@host_IP_Address)
	node0.add_attribute("agent_name",@@agent_name)
	node0.add_attribute("agent_version",@@agent_version)	
	node0.add_attribute("log_start_time",@@log_start_time)
	node0.add_attribute("log_end_time",@@log_end_time)
        
        if @@xml_error_initialization  then  #only do this if errors have been recognized and processed
        else   
          err_node0 = @@xml_miqhost_errlog_level
          err_node0.add_attribute("total_line_count",@@count)
          err_node0.add_attribute("valid_log_lines",@@good_count)
          err_node0.add_attribute("info_line_count",@@info_count)
          err_node0.add_attribute("warning_line_count",@@warn_count)
          err_node0.add_attribute("fatal_line_count",@@fatal_count)
          err_node0.add_attribute("debug_line_count",@@debug_count)
          err_node0.add_attribute("error_line_count",@@error_count)
          err_node0.add_attribute("summary_line_count",@@summary_count)	
          err_node0.add_attribute("host_name",@@host_name)
          err_node0.add_attribute("host_os",@@host_os)
          err_node0.add_attribute("host_IP_Address",@@host_IP_Address)
          err_node0.add_attribute("agent_name",@@agent_name)
          err_node0.add_attribute("agent_version",@@agent_version)	
          err_node0.add_attribute("log_start_time",@@log_start_time)
          err_node0.add_attribute("log_end_time",@@log_end_time) 
          err_node0.add_attribute("log_file_name",@@log_file_name) 
          err_node0.add_attribute("log_file_size",@@log_file_size)
  #	node0.add_attribute("agent_version",@@agent_version)
  #	node0.add_attribute("agent_version",@@agent_version)
          end
        end
	
	def line_count
	@@count
	end
	def good_count
	@@good_count
	end
	def warn_count
	@@warn_count
	end
	def debug_count
	@@debug_count
	end
	def summary_count
	@@summary_count
	end
	def info_count
	@@info_count
	end
	def error_count
	@@error_count
	end
	def fatal_count
	@@fatal_count
	end
	def valid
	@valid
	end
	def invalid_count
	@@invalid_count
	end
	def capture_startup
	@@startup_count += 1
	@@log_start_time = @msg_time.to_f
	end
	def startup_count
	@@startup_count
	end
	def capture_shutdown
	@@shutdown_count += 1
	@@log_end_time = @msg_time
	end
	def shutdown_count
	@@shutdown_count
	end
	def agent_name(name)
	@@agent_name = name
	end
	def host_os(name)
	@@host_os = name
	end
	
	def agent_version(version)
	@@agent_version = version
	end
	
	def host_name(name)
	@@host_name = name
	end
	def host_IP_Address(address)
	@@host_IP_Address = address
	end
        def get_last_log_time
          @@log_end_time.to_f
        end

end



# initially accept a single parm as the file name to analyze
# eventually this needs to be modified to handle a number of files passed in 
# as an array of names... but not initially
begin_time = Time.now
argument_count = ARGV.size            # get count of arguments passed in on initialization
exit if argument_count < 1            # if no parms are paased then generate an error and exit
if argument_count < 1 then puts " Expecting at least one file name as input, nothing is recognized, \n Processing is terminating." 
  exit
end
  
input_file = ARGV[0]                  # get input file name
puts "Log File being processed is '#{input_file}'."
input_file_stats = File.stat(input_file)
puts input_file_stats.inspect
case input_file_stats.file?
when false then puts "paramater #{input_file} is not a file.\n Program is terminating."
  exit
end
input_file_basename = File.basename(input_file,".*")
puts "Input File Basename is '#{input_file_basename}'"
log_file = File.open(input_file,"r")
long_lines = File.open("Long_lines.txt","w+")
puts "#{input_file} size = 0, no log file processing possible.\n Program is termination." if input_file_stats.size == 0
log_file_offset = 0
main_thread = Array.new
array_of_hashes = Array.new
debug_cnt = 0
current_time = Time.now
external_line_count = 0
while line_in = log_file.gets
  external_line_count =+ 1 #increment external line counter
  next if line_in.size < 20
  
  if /^Processing|^\[----\]/  =~ line_in && /DEBUG -- :/ !~ line_in then
  else next
  end
if /(\S*)\s--\s:\s*(\S*)/ =~ line_in then
  log_line = MiqServerLog.new(line_in, log_file_offset)
elsif 
  if /^\S/ =~ line_in then
  puts line_in.inspect 
  end  
  
end
  part1, part2 = line_in.chomp.split("-- :") #try to split the input line
  
#  part1_array = part1.split
#  part2_array = part2.split
#  if part1_array[0] !~ /^\[/ then  #see if the first word marks a messageid
#    
#  end
  #line_in is a string
  #log_line is an instance of MiqServerLog
  log_line = MiqServerLog.new(line_in, log_file_offset) # add to MiqServerLog object
#   puts log_line.object_id
#  pp log_line
#  puts log_line.inspect
#  debug_cnt += 1
#  if debug_cnt == 1724 then
#    debug_cnt.inspect
#  end
  
#if array_of_hashes.size > 20000 then break end     

if log_line.line_count % 50000 == 0 then 
  puts "50k lines in #{Time.now - current_time}"
  current_time = Time.now
end
  log_file_offset = log_file.pos                          # advance offset for next read
  if line_in.size < 3 then next   # if line size too small then skip it
  end
  if line_in.size <=512 then #next                         # not interested in small  lines
    elsif line_in =~ /host-self_register/ then long_lines.puts("line size is #{line_in.size}=>'#{line_in}'") 
      #caputre host self-registration 
      elsif log_line.msg_type == "D" || log_line.msg_type == nil then next #ignore debug and invalid log lines
      else long_lines.puts("line size is #{line_in.size}=>'#{line_in}'") # some lines are very long, so lets capture & examine
      end 
  if log_line.get_prefix_missing and log_line.get_pending_payload      then
    main_thread[(main_thread.size) -1]= main_thread[(main_thread.size) -1].chomp + line_in #this is the payload for the previous prefix line
    log_line.reset_prefix_missing
    log_line.reset_pending_payload
  end
  if log_line.get_pending_payload then main_thread << line_in # this line has prefix but no payload
  end  
if /: Completed/ =~ line_in then 
#  completed_hash = parse_completed_line(line_in,log_line)
#  array_of_hashes[(array_of_hashes.size) -1] = array_of_hashes[(array_of_hashes.size) -1].merge(completed_hash)
#  completed_hash.clear               empty the hash, just in case
#  pp array_of_hashes
  parse_completed_line(line_in,log_line,array_of_hashes[-1])
#  puts array_of_hashes[-1].inspect
end 
#  log_line_words = line_in.split(" ")                  # get words separately
  if /Processing/ =~ line_in and log_line.msg_type == nil then 
    array_of_hashes << parse_controller_line(line_in,log_line,array_of_hashes[-1]) #if the first word is Processing
    # then this is a controller method call  that appends to the prior prefix only line 
#    puts array_of_hashes[-1].inspect
  end
#  if /-- : (MIQ\S*): {enter|Starting|starting|host)/ =~ line_in then
#    array_of_hashes[-1].merge!({"method_name" => $1})
#  end
#if /-- : (MIQ\S*): exit/  
#  array_of_hashes[-1].merge!({"method_duration" => line_in.split[-2].tr("[]","  ").strip})
##  if /-- : (MIQ\S*): exit[[:print:]]\[(\d*\.\d*)\] seconds/ =~ line_in then
##    
#  end
  if /-- : (MIQ\S*):/ =~ line_in  then
    temp_method_name = $1
    if /Starting|starting|enter|Connecting/ =~ line_in then
      array_of_hashes[-1].merge!({"method_name" => temp_method_name})
    elsif /exit/ =~ line_in then
      array_of_hashes[-1].merge!({"method_duration" => line_in.split[-2].tr("[]","  ").strip})
    end
   if /E|W|F/ =~ log_line.msg_type 
     then 
     temp_hash = array_of_hashes[-1]
     if temp_hash["process id"] == log_line.msg_process_id then 
      array_of_hashes[-1].merge!({"needs review" => log_line.msg_type})
     end
  end
end
end
#puts log_line.inspect
#puts MiqServerLog.inspect
counter  = 0
puts "Count of elements in main_thread array is #{main_thread.size}."
puts "count of elements in array_of_hashes array is #{array_of_hashes.size}."
#main_thread.each do |instance|
#  puts "log_line{#{counter}) is '#{instance}'"
#  break if counter > 10
#  counter += 1
#end
#counter = 0
#array_of_hashes.each do |hash_entry|
#  pp hash_entry
#  break if counter > 10
#  counter += 1
#end
transaction_summary = CSV.open(input_file_basename + ".csv","w")
   temp_array = array_of_hashes[0].keys
#  temp_array_b = temp_array.each.join(",")
transaction_summary << temp_array 
  array_of_hashes.each do |hash_entry|
#      temp_string = hash_entry.values
#      puts temp_string.inspect
#      puts "#{temp_string}"
#      transaction_summary << temp_string
      transaction_summary << hash_entry.values
      end
      # At this point I have two sets of data- main_thread is an array of payload fragments 
      # some which represent normal Controller processing initiation, others represent the beginning of
      # a fatal error sequence and should probably be retained
      # "array_of_hashes" is an array that contains information about each interaction with the EVM 
      # application from a console, MIQ agent or some other web-services based agent
      
puts "Processing time for #{input_file} with #{log_line.line_count} lines is #{Time.now - begin_time}"
