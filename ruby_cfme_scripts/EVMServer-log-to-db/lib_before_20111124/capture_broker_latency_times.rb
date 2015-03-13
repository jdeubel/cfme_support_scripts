=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_broker_latency_times.rb 20976 2010-05-17 19:12:54Z thennessy $
=end

def capture_broker_latency_times(parsed_log_line)
#  puts "#{__FILE__}:#{__LINE__}-#{parsed_log_line.payload}"
  #File.new($diag_dir  + "\\" + "db_statistics_"+ $base_file_name + ".csv","w")
  if $broker_connection_latency == nil then
    $broker_connection_latency = File.new($diag_dir  + "\\" + "broker_connection_latency.csv","w")
    $broker_connection_latency.puts"server guid,host name,appliance name,zone,startup,PID,connect type,request start time,request duration,EMS name,EMS type,userid,ipaddress,API version"
  end

#[----] I, [2010-04-05T09:17:50.238817 #18363]  INFO -- : MIQ(VimBrokerWorker) Preloading broker for EMS: [ptssappvms03]
#[----] I, [2010-04-05T09:17:51.556960 #18363]  INFO -- : MIQ(VimBrokerWorker) Preloading broker for EMS: [ptssappvms03], successful

#[----] I, [2010-04-04T08:03:10.204865 #7687]  INFO -- : MIQ(MiqFaultTolerantVim-_connect) EMS: [ptssappvms01] [Broker] Connecting with address: [155.65.123.20], userid: [ptssappvms01\servteam]...
#[----] I, [2010-04-04T08:03:33.840539 #7687]  INFO -- : MIQ(MiqFaultTolerantVim-_connect) EMS: [ptssappvms01] [Broker] Connecting to EMS: [ptssappvms01]...Complete

  if $active_processes.has_key?($Parsed_log_line.log_pid) then
    current_process = $active_processes[$Parsed_log_line.log_pid]
  else
    puts "#{__FILE__}:#{__LINE__}->Illogical condition - log line for PID that does not exist in $active_processes: log line follows \n\t#{parsed_log_line.inspect}"
    return
  end
    case parsed_log_line.payload
    when /EMS\:\s*(.*)\s*is\s(.*?),\s*API version\:\s*(.*)/ then
# MIQ(MiqFaultTolerantVim-_connect) EMS: 10.127.207.144 is VC, API version: 2.5u2
            current_process["ems_type"] = $2.strip
            current_process["api_version"] = $3.strip
            $active_processes[parsed_log_line.log_pid] = current_process            # inject updated active process instance back into $active_processes object
    when /Preloading broker for EMS\:\s*\[(.*)\]/ then
      _ems_name = $1
          if /successful/ =~ parsed_log_line.payload then
            current_process["broker_connect_type"] = "preloading"
            create_broker_latency_instance(current_process)
            current_process_reset(current_process)
            $active_processes[parsed_log_line.log_pid] = current_process            # inject updated active process instance back into $active_processes object
          else
            current_process["ems_name"] = _ems_name
            current_process["broker_connect_time"] = parsed_log_line.log_datetime
            current_process["broker_connect_time_string"] = parsed_log_line.log_datetime_string.split(".")[0]
            $active_processes[parsed_log_line.log_pid] = current_process            # inject updated active process instance back into $active_processes object
          end
    when /EMS\:\s*\[(.*)?\]\s*\[(.*)?\]\s*Connecting with\s*(address|ipaddress)\:\s*\[(.*)?\],\s*userid\:\s*\[(.*?)\]/ then
#EMS: [Virtual Center (192.168.252.6)] [Broker] Connecting with address: [192.168.252.6], userid: [thennessy]...
      _ems_name = $1
      _ems_ipaddress = $4
      _userid ='"'+$5 + '"' if $5 != nil
      current_process["ems_name"] = '"' + _ems_name +'"'
      current_process["ems_ipaddress"] = _ems_ipaddress
      current_process["broker_userid"] = _userid
      current_process["broker_connect_time_string"] = parsed_log_line.log_datetime_string.split(".")[0]
      current_process["broker_connect_time"] = parsed_log_line.log_datetime
      current_process["broker_connect_type"] = "connecting"
      $active_processes[parsed_log_line.log_pid] = current_process            # inject updated active process instance back into $active_processes object

    when /EMS\:\s*\[(.*)?\]\s*Connecting with\s*address\:\s*\[(.*)?\],\s*userid\:\s*\[(.*?)\]/ then
#EMS: [Virtual Center (192.168.252.6)] [Broker] Connecting with address: [192.168.252.6], userid: [thennessy]...
      _ems_name = $1
      _ems_ipaddress = $2
      _userid ='"'+$3 + '"' if $3 != nil
      current_process["ems_name"] = '"' + _ems_name +'"'
      current_process["ems_ipaddress"] = _ems_ipaddress
      current_process["broker_userid"] = _userid
      current_process["broker_connect_time_string"] = parsed_log_line.log_datetime_string.split(".")[0]
      current_process["broker_connect_time"] = parsed_log_line.log_datetime
      current_process["broker_connect_type"] = "connecting"
      $active_processes[parsed_log_line.log_pid] = current_process            # inject updated active process instance back into $active_processes object

    when /EMS\:\s*\[(.*)?\]\s*\[(.*)?\]\s*Connecting to EMS\:\s*\[(.*)?\]...Complete/
      if current_process["broker_connect_time"] == nil then
            puts "out of sequence broker complete log line = #{parsed_log_line.inspect}"
      else
            create_broker_latency_instance(current_process)
            current_process_reset(current_process)
            $active_processes[parsed_log_line.log_pid] = current_process 
      end

#MIQ(MiqFaultTolerantVim-_connect) EMS: [Virtual Center (192.168.254.25)] Connecting to EMS: [Virtual Center (192.168.254.25)]...Complete
    when /EMS\:\s*\[(.*)?\]\s*Connecting to EMS\:\s*\[(.*?)\]...Complete/
      if current_process["broker_connect_time"] == nil then
            puts "out of sequence broker complete log line = #{$Parsed_log_line.inspect}"
      else
            create_broker_latency_instance(current_process)
            current_process_reset(current_process)
            $active_processes[parsed_log_line.log_pid] = current_process
      end
#IQ(MiqFaultTolerantVim._connect) EMS: [SGAFISVC001 (10.134.8.11)] [Broker] Connected
    when  /EMS\:\s*\[(.*)?\]\s*\[Broker\]\s*Connected/
      if current_process["broker_connect_time"] == nil then
            puts "out of sequence broker complete log line = #{$Parsed_log_line.inspect}"
      else
            create_broker_latency_instance(current_process)
            current_process_reset(current_process)
            $active_processes[parsed_log_line.log_pid] = current_process
      end
    when  /EMS\:\s*\[(.*)?\]\s*Connected/
      if current_process["broker_connect_time"] == nil then
            puts "out of sequence broker complete log line = #{$Parsed_log_line.inspect}"
      else
            create_broker_latency_instance(current_process)
            current_process_reset(current_process)
            $active_processes[parsed_log_line.log_pid] = current_process
      end
    else
      puts "#{__FILE__}:#{__LINE__}-> doesn't meet regexp match\n\t#{parsed_log_line.payload}"
    end
#    if current_process["broker_connect_time"] == nil then
#      puts "#{__FILE__}:#{__LINE__}-#{$Parsed_log_line.payload}"
#    end
#  end
end
def create_broker_latency_instance(current_process)
#    $broker_connection_latency.puts"server guid,host name,appliance name,PID,request start time,request duration,VC name,EMS identifier,userid,ipaddress"  
      current_startup = $Startups[$startup_cnt]
      if $Parsed_log_line.log_datetime != nil && current_process["broker_connect_time"] != nil then
      _elapsed_time = $Parsed_log_line.log_datetime - current_process["broker_connect_time"]
#      puts "#{current_process.inspect}"
     $broker_connection_latency.puts "#{current_startup["server_guid"]},#{current_startup["hostname"]},#{current_startup["appliance name"]}," + 
                                     "#{$Startups[$startup_cnt]["zone"]},#{$startup_cnt}," +
                                     "#{current_process["PID"]}," + 
                                     "#{current_process["broker_connect_type"]},#{current_process["broker_connect_time_string"]},#{_elapsed_time},#{current_process["ems_name"]}," +
                                     "#{current_process["ems_type"]}," +
                                     "#{current_process["broker_userid"]},#{current_process["ems_ipaddress"]},\"#{current_process["api_version"]}\""
      else
        puts "#{__FILE__}:#{__LINE__}-broker_latency being skipped because either current_process[\"broker_connect_time\"] or $Parsed_log_line.log_datetime is nil "
        puts "#{__FILE__}:#{__LINE__}-#{$Parsed_log_line}"
        puts "#{__FILE__}:#{__LINE__}-#{$Parsed_log_line}"
      end
                                       
  
end
def current_process_reset(current_process)
  current_process["broker_connect_time"] = nil
  current_process["broker_connect_type"] = nil
  current_process["ems_ipaddress"] = nil
  current_process["broker_userid"] = nil
  current_process["ems_name"] = nil
  current_process["ems_identifier"] = nil
end
