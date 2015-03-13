=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: vmdb_config_to_yaml_to_csv.rb 20579 2010-04-23 12:50:41Z thennessy $
=end
require "yaml"
$config_string_var = ""
$external_key = ""
$recursion = 0
$global_configs = Array.new

def save_startup_config_details(in_array)
        configs = File.new($diag_dir + "\\" + "startup_config_#{$startup_cnt}.csv","w")
#        configs = File.new("config.csv","w")
        configs_preamble = "#{$Server_GUID},#{$config_yaml[:server][:hostname]},#{$config_yaml[:server][:name]}," + 
                           "#{$Startups[$startup_cnt]["log_datetime_string"]},"
        configs.puts("server guid,host name,appliance name,startup time,config line, value")
        in_array << "_EVM|Version,\"#{$Startups[$startup_cnt]["evm version"]}\""
        in_array << "_EVM|Build,\"#{$Startups[$startup_cnt]["build"]}\""
        in_array << "_EVM|Appliance,\"#{$config_yaml[:server][:name]}\""
        in_array << "_EVM|startup_time,\"#{$Startups[$startup_cnt]["display_time"]}\""
#        in_array << "Ruby|"
        in_array << "_RAILS|environment,\"#{$Startups[$startup_cnt]["rails environment"]}\""
        in_array << "_RAILS|version,\"#{$Startups[$startup_cnt]["rails version"]}\""
        in_array.each {|config_line|
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
      _temp_ext_key1 = external_key + "[#{_i}]"
          case element.class.to_s
          when /Hash/ then
    #      end
    #      if element.class.to_s == "Hash" then
            element.each { |keyy,valuey|
    #                        _temp_ext_key0 = external_key
    #                         _temp_ext_key1 = _temp_ext_key0 + "|" + "#{keyy}" + "|" + "'#{valuey}'"
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

def vmdb_config_to_yaml_to_csv(payload)
string_array = Array.new

 _payload = payload
#while linein = gets
#  line_array = linein.split("-- :")

#  puts "#{linein}"
   case _payload
     when /VMDB settings END/ then
       _payload = "#" + _payload
       $VMDB_scan_active = nil
     when /VMDB settings/ then
       $VMDB_scan_active = true
       _payload = "#" + _payload
     when /Log line size/ then _payload = "#" + _payload
   when / get_/ then
   when /started on/ then _payload = "#" + _payload
   when / [\:\-]/ then
   else
     _payload = "#" + _payload
   end
  $config_string_var = $config_string_var + _payload if $VMDB_scan_active
   if $config_string_var.length > 0 && $VMDB_scan_active == nil then
#     puts "#{string_var.inspect}"
     $config_yaml = YAML.load($config_string_var)
#     puts "#{test_yaml.inspect}"
    $Startups[$startup_cnt]["appliance name"] = $config_yaml[:server][:name]
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
        save_startup_config_details($global_configs)
        puts "configuration line count is = #{$global_configs.size} lines "
        $global_configs.clear
        $config_string_var = ""
#        configs = File.new("config.csv","w")
#        $global_configs.each {|config_line|
#                              configs.puts "#{config_line}"
#        }
#        configs.close
#     exit
   end
end
#end
