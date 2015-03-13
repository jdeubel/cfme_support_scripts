require "rubygems"
require "English"
require "fileutils"
require "stringio"
  $event_arguments = Hash.new
  vc_events_file = File.new("vc_event_detail.csv","w")
  vc_events_file.puts("msgid,msg command,msg put time,event type,event create time,chainid,vm name,vm id,host name")
while linein = gets
  if /MIQ\(MiqQueue\.put\)\s*(.*)/ =~ linein then
    payload = $1
  else
    next
  end
  log_line_array = linein.split
#  log_line_time = log_line_array[2][2,(log_line_array[2].size -1)].gsub(/T/," ")
  log_line_time = log_line_array[2].gsub("T"," ")                      # remove literal T from time
  log_line_time = log_line_time[1,log_line_time.size - 1]                # drop leading square bracket
if /Args\:\s*\[(.*)\]$/ =~ payload then
  event_string = $1
  payload_prefix = $PREMATCH
else
  next
end
payload_prefix_array = payload_prefix.split(",")
payload_prefix_array.each {|element|
                          case element
                          when /Message id\:\s*\[(\d*)\]/ then $message_id = $1
                          when /  id\:\s*\[(.*?)\]/ then $id = $1
                          when /Zone\:\s*\[(.*)\}/ then $zone = $1
                          when /Role\:\s*\[(.*)\]/ then $role = $1
                          when /Server\:\s*\[(.*)\]/ then $server = $1
                          when /Ident\:\s*\[(.*)\]/ then $ident = $1
                          when /Target id\:\s*\[(.*)\]/ then $target_id =$1
                          when /Instance id\:\s*\[(.*)\]/ then $instance_id = $1
                          when /Task id\:\s*\[(.*)\]/ then $task_id = $1
                          when /Command\:\s*\[(.*)\]/ then $command = $1
                          when /Timeout\:\[(\d*)\]/ then $timeout =$1
                          when /Priority\:\s*\[(.*)\]/ then $priority = $1
                          when /State\:\s*\[(.*)\]/ then $state = $1
                          when /Deliver on\:\s*\[(.*)\]/ then $deliver_on = $1
                          when /Data\:\s*\[(.*)\]/ then $data = $1
                          end
                          }
  puts "================================================="
case linein

when /.*?Args\:\s*\[(.*)\]$/ then
#  puts $1
  event_string  = $1
  eval "$event_arguments = #{event_string}"
#  puts "#{event_arguments.inspect}"
  $event_arguments.each {|key,value|
      case key
      when "createdTime" then
        $event_create_time = value.gsub(/[ZT]/," ")
      end    
    case value.class.to_s
    when "String" then
      puts "#{key}.value is of class String, value ='#{value}'"

    else
      puts "#{key}.value is of class '#{value.class.to_s}' value is #{value.inspect}"
      case key
      when "vm" then 
        $vm_name = value["name"]
        $vm_id = value["vm"]
      when "host" then $host_name = value["name"]
      end
    end
  }
end
puts "====================================================\n\n"
chainid = $event_arguments["chainId"]
#if $event_arguments["vm"].class.to_s == "Hash"  then
#  vm = $event_arguments["vm"]
#  vm_name = vm["name"]
#end
  vc_events_file.puts "#{$message_id},#{$command},#{log_line_time.to_s},#{$event_arguments["eventType"]},#{$event_create_time},#{chainid},#{$vm_name},#{$vm_id},#{$host_name}"
$vm_name = nil
$host_name = nil
$vm_id = nil
$event_arguments.clear
end
vc_events_file.close
exit