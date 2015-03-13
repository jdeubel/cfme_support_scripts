=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_queueing_refresh.rb 24591 2010-11-08 15:45:16Z thennessy $
=end
$queueing_refresh_csv = nil

def capture_queueing_refresh(payload)
  if $queueing_refresh_csv == nil then
    $queueing_refresh_csv = File.new($diag_dir + "\\" + $base_file_name+"_queueing_refresh.csv","w")
    $queueing_refresh_csv.puts "server guid,hostname,log datetime,startup cnt,process id,EMS id,refresh type,refresh class,element id,property"
  end
  _temp = nil                 # set default value for later checking
  _emsid =  nil
  case payload
#  if  /Queueing refresh on\s*(.*)\s*\[(.*)?\]\s*for properties\s*/ =~ payload then
  when  /Queueing refresh on\s*(.*)\s*\[(.*)?\]\s*for properties\s*/ then
    _temp = $POSTMATCH    
    refresh_type = $1
    refresh_class = $2

#  end
#[----] I, [2010-10-22T11:52:22.369073 #2402:1564f4392efc]  INFO -- : 
#MIQ(VimBrokerWorker) Queueing refresh for Vm id: [73], EMS id: [1] 
#                                           1       2            3
#on event [VirtualMachine-update] for properties 
#    4       5                                   -> 6
#["config.hardware.device[2000].backing.fileName", "config.hardware.device[2000].backing.parent", "config.hardware.device[2001].backing.fileName", "config.hardware.device[2001].backing.parent", "snapshot"]
  when  /Queueing refresh for\s*(\S*)\s*id\:\s*\[(\d*)\]\,\s*EMS\s*id\:\s*\[(\d*)\]\s*on\s*(\S*)\s*\[(.*)?\]\s*for properties\s*/ then
    _temp = $POSTMATCH
    _emsid = $3
    _element_id = $2
    refresh_type = $4
    refresh_class = $5

  end
  if _temp != nil then
    _standard_preamble = "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," <<
        "#{$Parsed_log_line.log_datetime_string.split(".")[0]},#{$startup_cnt},#{$Parsed_log_line.log_pid},#{_emsid},"
    property_array = _temp.to_s.split(",")
    property_array.each {|property|
      property = property.strip
      _string_index = 2
      found_doublequote = true
      until !found_doublequote do
      _string_index = property.index('"',_string_index)
        if _string_index == nil then
          found_doublequote = nil
        else
          property.insert(_string_index+1,'"') if (property.size - _string_index) > 2
          _string_index += 2
        end
      end
      $queueing_refresh_csv.puts "#{_standard_preamble}\"#{refresh_type.strip}\",\"#{refresh_class.strip}\",#{_element_id},#{property.tr("[]"," ").strip}"
    }

#  end
  end
end
