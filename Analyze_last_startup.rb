=begin rdoc
Copyright 2008-2010 ManageIQ, Inc
$Id: Analyze_last_startup.rb 24237 2010-10-15 03:42:37Z thennessy $
=end

def save_startup_config_details(in_array,startup)
        configs = File.new("last_startup_config.csv","w")
        configs_preamble = "#{startup.server_guid},#{startup.hostname},#{startup.appliance_name},#{startup.server_log_start_time},"
#        configs_preamble = "server guid,hostname,appliance name,startup time,"
        configs.puts("server guid,hostname,appliance name,startup time,config line, value")
#        configs.puts("#{startup.server_guid},#{startup.hostname},#{startup.appliance_name},#{startup.server_log_start_time},config line, value")
        $global_configs.each {|config_line|
                              configs.puts configs_preamble + "#{config_line}"
        }
        configs.close
end
def decompose_hash(external_key,key,value)
  $recursion += 1
  preamble = ""
  $recursion.times do preamble += "*" end
#  if /pattern/ =~ "#{key}" then
#    puts "#{__FILE__}:#{__LINE__}"
#  end
#  puts preamble + " entering decompose_hase with external key '#{external_key}',key parms value  '#{key}' & class value '#{value.class.to_s}'"

    external_key = external_key + "|" + "#{key}" if $recursion > 1
    if /server\|/ =~ external_key then
      puts "#{__FILE__}:#{__LINE__}"
    end
    case external_key
    when "server|company" then 
      $server_company = value.strip.tr(" ","-")
    when "server|name" then $server_name = value.strip.tr(" ","-")
    when "server|zone" then $server_zone = value.strip.tr(" ","-")
    end
#  puts preamble + "external key is #{external_key} value type is '#{value.class.to_s}'"
  case value.class.to_s
  when /Hash/ then
    value.each { |keyx,valuex|
       temp_ext_key = external_key
      decompose_hash(temp_ext_key , keyx ,valuex)
    }
  when /Array/ then
#    puts preamble + "for external key '#{external_key}' an array is identified and is being processed"
    _i = 0
    value.size.times  do
      element = value[_i]
      _temp_ext_key1 = external_key +"[#{_i}]"
          case element.class.to_s
          when /Hash/ then
    #      end
    #      if element.class.to_s == "Hash" then
            element.each { |keyy,valuey|
    #                        _temp_ext_key0 = external_key
    #                         _temp_ext_key1 = _temp_ext_key0 + "|" + "#{keyy}" +"|" + "'#{valuey}'"
                            decompose_hash(_temp_ext_key1,"#{keyy}",valuey)

            }
          when /Array/ then
            $global_configs << "#{_temp_ext_key1},\"#{value.split.join(",")}\""
          else
            $global_configs << "#{_temp_ext_key1},\"#{element}\""
          end
      _i += 1
    end

  else
#    puts preamble + "external key is #{external_key} value is #{value}"
    $global_configs << "#{external_key},\"#{value}\""
  end
#  puts preamble + " exiting decompose_hase withexternal key '#{external_key}',key parms value  '#{key}' & class value '#{value.class.to_s}}'"
  $recursion -= 1
end

def rename_pdf_file
rename_pdf_cmd = File.new("rename_top_pdf.cmd","w")
rename_pdf_cmd.puts "pushd %1"
rename_pdf_cmd.puts "call top_summary_stats.csv"
rename_pdf_cmd.puts "rename top_summary_stats.pdf \"#{$server_company}_#{$server_zone}_#{$server_name}_top_summary_stats.pdf\" "
rename_pdf_cmd.puts "copy \"#{$server_company}_#{$server_zone}_#{$server_name}_top_summary_stats.pdf\" ..\\*.*"
rename_pdf_cmd.puts "popd"
rename_pdf_cmd.close
end


class Appliance_info
  attr_accessor :server_guid, :server_zone, :server_role, :server_id, :appliance_name, :hostname, :real_memory, :swap_memory, :processor_count, :ipaddress
  attr_accessor :processor_speed, :processor_type, :evm_version, :evm_build, :ruby_version, :rails_version, :rails_environment
  attr_accessor :server_display_start_time, :server_log_start_time
  def initialize
    @server_guid = nil
    @server_zone = nil
    @server_role = nil
    @server_id = nil
    @server_log_start_time = nil
    @server_display_start_time
    @appliance_name = nil
    @hostname = nil
    @ipaddress = nil
    @real_memory = nil
    @swap_memory = nil
    @processor_count = 0
    @processor_speed = nil
    @processor_type = nil
    @evm_version = nil
    @evm_build = nil
    @ruby_version = nil
    @rails_version = nil
    @rails_environment = nil
  end
end
require "yaml"
require "pp"
# SVN Doc Info
$SVN_rev = "$Revision$ "
$SVN_author = "$Author$ "
$SVN_changed = "$Date: 2010-10-14 22:42:37 -0500 (Thu, 14 Oct 2010) $"
$SVN_id = "$Id: Analyze_last_startup.rb 24237 2010-10-15 03:42:37Z thennessy $"

$server_name = "Nautilus-" + rand(10000).to_s
$server_company = "Jules-Verne"
$server_zone = "Dr-Nemo"
puts "Analyze_last_startup info\n\t#{$SVN_id}"
#=============
$:.push("#{File.dirname(__FILE__)}")  # force the directory with initial code to be on the search path

if File.exists?("last_startup.txt") then
  puts "full file name is #{Dir.pwd + "\\last_startup.txt"}"
  startup_config = File.new("last_startup.txt","r")
else
  puts "No 'last_startup.txt' file found.  exiting"
  rename_pdf_file
  exit
end
#test = YAML.load_file("startup_config_2.txt")
#puts "#{test.inspect}"
string_array = Array.new
$external_key = ""
string_var = " "
$recursion = 0
$global_configs = Array.new
Last_startup = Appliance_info.new

while linein = startup_config.gets
#  puts "#{linein}"
  line_array = linein.split("-- :")
if /\[----\]/ =~ line_array[0] then
#  puts "#{linein}"
   case line_array[1]
   when /\[VMDB\] started on \[(.*)\]/ then
     Last_startup.server_display_start_time = $1
     _work = line_array[0].split[2]
     _work.tr!('\[',' ')
     _work.tr!("-"," ")
     _work.tr!("T.","  ")
#     _
     puts "#{_work}"
     __work = _work.split
     puts "#{__work}"
     Last_startup.server_log_start_time = __work[1].to_s + "/" + __work[2].to_s + "/" + __work[0].to_s + " " + __work[3].to_s
     $global_configs << "#{'_EVM|_Server_start_datetime'},#{Last_startup.server_log_start_time}"

   when /Server GUID\:\s*(.*)/ then
     Last_startup.server_guid = $1.strip
     $global_configs << "#{'_EVM|Server_GUID'},#{Last_startup.server_guid}"
   when/Server Zone:\s*(.*)/ then
     Last_startup.server_zone = $1.strip
     $global_configs << "#{'_EVM|Server_zone'}, \"#{Last_startup.server_zone}\""
   when /Server Role:\s*(.*)/ then
     Last_startup.server_role = $1.strip
     $global_configs << "#{'_EVM|Server_role'},\"#{Last_startup.server_role}\""
   when /Server EVM id and name:\s*(\d*)\s*(.*)/ then
     Last_startup.server_id = $1
     $global_configs << "#{'_EVM|Server_id'},\"#{Last_startup.server_id}\""
     Last_startup.appliance_name = $2.strip
     $global_configs << "#{'_EVM|appliance_name'},\"#{Last_startup.appliance_name}\""
   when /hostname\:\s*(.*)/ then
     Last_startup.hostname = $1.strip
#     $global_configs << "#{'_EVM|hostname'},\"#{Last_startup.hostname}\""
   when /ipaddress:\s*(.*)/ then
     Last_startup.ipaddress = $1.strip
     $global_configs << "#{'_EVM|ipaddress'},\"#{Last_startup.ipaddress}\""
   when /RUBY Environment\:\s*(.*)/ then
     Last_startup.ruby_version = $1.strip
     $global_configs << "#{'_EVM|ruby_version'},\"#{Last_startup.ruby_version}\""
   when /RAILS Environment\:\s*(\S*)\s*version\s*(.*)/ then
     Last_startup.rails_environment = $1
     $global_configs << "#{'_EVM|rails_environment'},\"#{Last_startup.rails_environment}\""
     Last_startup.rails_version = $2.strip
     $global_configs << "#{'_EVM|rails_version'},\"#{Last_startup.rails_version}\""
   when /Version\:\s*(.*)/ then
     Last_startup.evm_version = $1.strip
     $global_configs << "#{'_EVM|evm_version'},\"#{Last_startup.evm_version}\""
   when /Build\:\s*(.*)/ then
     Last_startup.evm_build = $1.strip
     $global_configs << "#{'_EVM|evm_build'},\"#{Last_startup.evm_build}\""
   when /VMDB settings END/ then
     line_array[1] = "#" + line_array[1]
     vmdb_flag = nil
   when /VMDB settings/ then
     vmdb_flag = true
     line_array[1] = "#" + line_array[1]
   when /Log line size/ then line_array[1] = "#" + line_array[1]
   when / get_/ then
   when / [\:\-]/ then
   else
     line_array[1] = "#" + line_array[1]
   end
else
  case linein
  when /MemTotal\:\s*(\d*)\s*kB/ then
    Last_startup.real_memory = $1
    $global_configs << "#{'_EVM|real_memory'},\"#{Last_startup.real_memory}\""
  when /SwapTotal\:\s*(\d*)\s*kB/ then
    Last_startup.swap_memory = $1
    $global_configs << "#{'_EVM|swap_memory'},\"#{Last_startup.swap_memory}\""
  when /processor\s*\:\s*(\d*)/ then
    Last_startup.processor_count += 1

  when /cpu MHz(.*)\:\s*(.*)/ then
    Last_startup.processor_speed = $2 if Last_startup.processor_speed == nil

  end
  next
end
   string_var = string_var + line_array[1] if vmdb_flag
   if string_var.size > 1 && vmdb_flag == nil then
#     puts "#{string_var.inspect}"
     $config_yaml = YAML.load(string_var)
#     puts "#{test_yaml.inspect}"
      $config_yaml.each do |key, value|
        decompose_hash("#{key}",key,value)
        $external_key = "#{key}"
#       puts "key is #{key}, type is #{value.class.to_s}"
       value.each do |key , value|
         _temp_key = "#{key}"
         $external_key = $external_key + "|"+ _temp_key
#         puts "\tkey is #{$external_key}, type is #{value.class.to_s}"
       end
       end
#        puts "#{$global_configs}"

        vmdb_flag = true
#        configs = File.new("config.csv","w")
#        $global_configs.each {|config_line|
#                              configs.puts "#{config_line}"
#        }
#        configs.close
#     exit
   end
end

pp "#{Last_startup.inspect}"
    $global_configs << "#{'_EVM|hostname'},\"#{Last_startup.hostname}\""
    $global_configs << "#{'_EVM|processor_count'},\"#{Last_startup.processor_count}\""
    $global_configs << "#{'_EVM|processor_speed'},\"#{Last_startup.processor_speed}\""

    save_startup_config_details($global_configs,Last_startup)
    puts "configuration line count is = #{$global_configs.size} lines "
    $global_configs.clear
    rename_pdf_file
    exit



