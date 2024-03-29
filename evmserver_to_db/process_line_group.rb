=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_line_group.rb 24289 2010-10-18 21:36:08Z thennessy $
=end
def instantiate_active_process
       $active_processes[$Parsed_log_line.log_pid] = {"PID" => $Parsed_log_line.log_pid ,
       "first seen" => $Parsed_log_line.log_datetime_string.split(".")[0] ,"first seen seconds" => $Parsed_log_line.log_datetime,
       "last heard from" => $Parsed_log_line.log_datetime_string.split(".")[0] , "last heard from seconds" => $Parsed_log_line.log_datetime,
       "process type" => nil,'active roles' =>nil, 'assigned roles'=> nil,
       "GUID" => nil, "started" => nil, "lines" => 0, "build id" => nil, "log id" => nil, "lines after exit" => 0,
       "error_cnt" => 0, "warn_cnt" => 0, "fatal_cnt" => 0, "debug_cnt" => 0, "startup count" => $startup_cnt,
       "requested_exit" => nil, "detected_exit" => nil, "detected_exit_seconds" => nil,
       "killed" => nil, "requested_exit_reason" => nil,
       "file_status" => "closed", "file_handle" => nil,
       "server_guid" => nil, "server_hostname" => nil,"error_pid" => nil,
       "broker_connect_time" => nil,"broker_connect_type" => nil,"ems_ipaddress" => nil,"broker_userid" => nil,"ems_name" => nil,"ems_identifier" => nil,
#       "server_guid" => $Startups[$startup_cnt]["server_guid"], "server_hostname" => $Startups[$startup_cnt]["host"]
     }
end
def process_line_group(line_group_in)
#  case line_group_in.class.to_s
# when "Array"
#      if /failed authentication/ =~ line_group_in[0]  then
#        puts "#{__FILE__}:#{__LINE__}- #{line_group_in[0]}"
#      end
#  when "String"
#       if /failed authentication/ =~ line_group_in  then
#        puts "#{__FILE__}:#{__LINE__}- #{line_group_in}"
#      end
#  end
# if /ENV\[\'EVMSERVER\'\]\: true/ =~ line_group_in[0] ||
#     /ENV\[\'EVMSERVER\'\]\: true/  =~ line_group_in then
#    puts "#{__FILE__}:#{__LINE__}- #{line_group_in[0]}"
#  end
#  if /has reached the interval/ =~ line_group_in[0] &&
#        /MiqQueue\./  !~ line_group_in[0] then
#    puts "#{__FILE__}:#{__LINE__}- #{line_group_in[0]}"
#  end
#    if /\(VimBrokerWorker\)/ =~ line_group_in[0] && /Queueing refresh/ =~ line_group_in[0] then
#      puts "#{__FILE__}:#{__LINE__}=>#{line_group_in[0]}"
#  end
#      if /requesting worker to exit/ =~ line_group_in[0] && /aae49ed4-6476-11df-b1bd-005056ba15fb/ =~ line_group_in[0] then
#    puts "#{__FILE__}:#{__LINE__}=>#{line_group_in[0]}"
#  end
#
# look for stopping worker literal
#  line_group_in.each do |x|
#    if /Updating Vm/ =~ line_group_in[0] then
#    puts "#{__FILE__}:#{__LINE__}->#{line_group_in[0]}"
#    end
#  end

# lines below short circuit DEBUG log line evalutiona - added 2010-07-22 to speed up log processing by tch
  if /DEBUG \-\-\ \:/ =~ line_group_in[0] then
    return
  end
# end of 2010-07-22 DEBUG log lins short circuit
#puts "#{__FILE__}:#{__LINE__}- #{line_group_in[0]}\n"
  $Parsed_log_line = Parsed_log_line.new(line_group_in[0])
=begin rdoc
  following code is being added to identify the ruby main process as early as possible
  so that the detail code examination now being done for every log line to find startup
  configuration information can be limited to only log lines from the main ruby process
  which should reduce the processing time considerably
=end
#  if /action\-finished/ =~ $Parsed_log_line.payload && /successfully/ !~ $Parsed_log_line.payload then
#    puts "#{__FILE__}:#{__LINE__}"
#  end
  if $EVMServerPid == nil  then
    case $Parsed_log_line.payload
    when /atStartup\)/ then
      $EVMServerPid = $Parsed_log_line.log_pid    #Capture main ruby process pid
      puts "#{__FILE__}:#{__LINE__}- $EVMServerPid value found.  Using'#{$EVMServerPid}'"
    when /\[EVM Server \((\d*)\)\]/ then
      $EVMServerPid = $1
      puts "#{__FILE__}:#{__LINE__}- $EVMServerPid value found.  Using'#{$EVMServerPid}'"
    end
  end


#  puts "#{$Saved_parsed_log_line.class}"
  if $Saved_parsed_log_line.class != $Parsed_log_line.class then
    inter_line_delay = 0
  else
    inter_line_delay = 0
    inter_line_delay = $Parsed_log_line.log_datetime.to_i - $Saved_parsed_log_line.log_datetime.to_i 
      if inter_line_delay > $delay_limit && $base_file_name == "evm" then        # only take exception if evm.log is in play here
        puts "intra-log line time delay of #{inter_line_delay} seconds exceed #{$delay_limit} seconds- current log line follows:" <<
          "#{line_group_in[0]}"
        _note_it = $Parsed_log_line
        _note_it.payload = "gap in log before this line of #{$delay_limit} seconds.\n#{_note_it.payload}"


#          "\n\tprior log line:#{$Saved_parsed_log_line.inspect}\n\tcurrent log line:#{$Parsed_log_line.inspect}"
      end
      if inter_line_delay < 0 then
        _note_it = $Parsed_log_line
        _note_it.payload = "*** current log line is retrograde with respect to preceeding log lines by #{inter_line_delay} seconds.  log line follows:\n'#{line_group_in[0]}' ****\n"
        log_line_of_interest(_note_it)
      end
      $Saved_parsed_log_line = $Parsed_log_line
    end
   x = $Parsed_log_line
   determine_if_log_line_of_interest(x)


#  _examine_pid = line_group_in[0].split                 #split into workds
#  $Parsed_log_line.log_pid = _examine_pid[3].tr("#]","  ").strip #look at PID field and remove non-pid characters
#  if _examine_pid[3] != "5373" then
#    puts "#{__FILE__}:#(__LINE__}"
#  end
  $line_group_pid = $Parsed_log_line.log_pid                     # set this as a global variable for reference everywhere

  if $active_processes.empty? || !$active_processes.has_key?($Parsed_log_line.log_pid)  then #if there is no entry in active process list
                                                         # then create one
                                                         # after checking to see if the process counts have wrapped
    if $line_group_pid.to_i < $last_pid then                            # if new pid is less than last high pid
      $pid_cycle += 1                                                   # increment pid recycle count
      $last_pid = $line_group_pid.to_i                                  # and set new pid as $last_pid
    else
      $last_pid = $line_group_pid.to_i                               # else just make new pid as $last_pid value
    end

# review all $active_processes and identify elements that we haven't heart from in more than 7250 seconds
_close_process = Array.new
  $active_processes.each do |_key,xamine_process|
    if $Parsed_log_line.log_datetime &&                         # make sure log_datetime isnlt empty
        xamine_process["last heard from seconds"] &&         # make sure last_heart_from_seconds isn't empty
        $Parsed_log_line.log_datetime - xamine_process["last heard from seconds"]   > $process_inactive_harvest_time  then            #this exceeds the default interval by 3 minutes +
#      puts "#{__FILE__}:#{__LINE__}=> ********** probable inactive process follows ****** current time is #{$Parsed_log_line.log_datetime}\n\t time since last hear from is #{$Parsed_log_line.log_datetime - xamine_process[1]["last heard from seconds"]} seconds"
#      pp xamine_process
      _close_process << _key
    end
    if xamine_process["killed"] &&                           #if process is killed and we haven't heard from it in 300 seconds, then harvest the process
       xamine_process["last heard from seconds"] &&
     $Parsed_log_line.log_datetime - xamine_process["last heard from seconds"]   > 300 then 
      _close_process << _key
    else
        if xamine_process["killed"] &&                           #if process is killed and we haven't heard from it in 300 seconds, then harvest the process
       xamine_process["last heard from seconds"] == nil then       # if no lasst heard from time
#     $Parsed_log_line.log_datetime - xamine_process[1]["last heard from seconds"]   > 300 then
                                                                      # if the process is killed and there is not last heard from date then just harvest the process
      _close_process << _key
        end
    end
    if $Parsed_log_line.log_datetime &&
        xamine_process["detected_exit_seconds"] &&
        $Parsed_log_line.log_datetime - xamine_process["detected_exit_seconds"] > 120 then
      _close_process << _key
# above logic is intended to close pids after waiting 120 seconds log time so that log lines that
#  are posted after the worker is signaled to exit are captured into the right pid_file
#  and doesn't cause too much needless file processing.
    end    
    end


    if _close_process.size > 0 then
      puts "inactive processes being removed from active process list"
      pp _close_process
      _close_process.each do |pid|
        # it is possible that the same key may occurr multiple times in this hash so 
        # before processing each instance, lets make sure it is still in the hash
        if $active_processes.has_key?(pid) then
#        if pid.class.to_s == "NilClass" or $active_processes[pid].class.to_s == "NilClass" || $active_processes[pid]["PID"].class.to_s == "NilClass" then
#          puts "PID value is #{pid}"
#          puts "$active_processes hash entry for pid is #{$active_processes[pid].inspect}"
#          puts "PID value from hash instance is #{$active_processes[pid]["PID"].inspect}"
#        else
         archive_active_process($active_processes[pid]["PID"])
        end

#        _pid_file = $active_processes[pid]["file_handle"]
#        _pid_file.close
#        $active_processes[pid]["file_handle"] = nil
#        $active_processes[pid]["file_status"] = "closed"
#        $all_process_archive << $active_processes[pid]
#        $active_processes.delete(pid)
      end
      puts "active process count after removing inactive processes is #{$active_processes.size}"
      if $active_processes.size > $active_process_limit then
        puts "current log time is #{$Parsed_log_line.log_datetime_string}\ncurrent log time in seconds is #{$Parsed_log_line.log_datetime}\n $active processes follow:"
        $active_processes.each do |key, element|
          element['last heard from seconds'] = 0 if element['last heard from seconds'] == nil
          puts "#{key}->  time delta => #{$Parsed_log_line.log_datetime - element['last heard from seconds']}"
          element.each do |keya, elementa|
            puts "\t\t#{keya}->#{elementa}"
          end
        end
#        exit
      end
    end



     $active_processes[$Parsed_log_line.log_pid] = {"PID" => $Parsed_log_line.log_pid ,
       "first seen" => $Parsed_log_line.log_datetime_string.split(".")[0] ,"first seen seconds" => $Parsed_log_line.log_datetime,
       "last heard from" => $Parsed_log_line.log_datetime_string.split(".")[0] , "last heard from seconds" => $Parsed_log_line.log_datetime,
       "process type" => nil,'active roles' =>nil, 'assigned roles'=> nil,
       "GUID" => nil, "started" => nil, "lines" => 0, "build id" => nil, "log id" => nil, "lines after exit" => 0,
       "error_cnt" => 0, "warn_cnt" => 0, "fatal_cnt" => 0, "debug_cnt" => 0, "startup count" => $startup_cnt,
       "requested_exit" => nil, "detected_exit" => nil, "detected_exit_seconds" => nil,
       "killed" => nil, "requested_exit_reason" => nil,
       "file_status" => "closed", "file_handle" => nil,
       "server_guid" => nil, "server_hostname" => nil,"error_pid" => nil,
       "broker_connect_time" => nil,"broker_connect_type" => nil,"ems_ipaddress" => nil,"broker_userid" => nil,"ems_name" => nil,"ems_identifier" => nil,
#       "server_guid" => $Startups[$startup_cnt]["server_guid"], "server_hostname" => $Startups[$startup_cnt]["host"]
     }
     #conditional assignments for server guid and host name
     $active_processes[$Parsed_log_line.log_pid]["server_guid"] = $Startups[$startup_cnt]["server_guid"] if $Startups[$startup_cnt]
     $active_processes[$Parsed_log_line.log_pid]["server_hostname"] = $Startups[$startup_cnt]["hostname"] if $Startups[$startup_cnt]
     if $Error_pids != nil && $Error_pids.size > 0 then
       $Error_pids.each do |error_pid|
         if error_pid == $Parsed_log_line.log_pid then 
           $active_processes[$Parsed_log_line.log_pid]["error_pid"] = true  # if this is marked as a pid with errors than capture that
         end
       end
       end
#     end
     _new_pid_file = nil
     __open_files = 0
#     puts "#{__FILE__}:#{__LINE__}->#{$active_processes.size} active process elements"
     $active_processes.each do |key,_hash_item_instance|
#       puts "#{_hash_item.size} elements in $active_processes"
#       _hash_item.each do |_hash_item_instance|
#         if _hash_item_instance.class.to_s != "String" then
           puts "#{__FILE__}:#{__LINE__}->#{_hash_item_instance["PID"]}-last heard from [#{_hash_item_instance["last heard from"]} " if _hash_item_instance["file status"] == "open"
           __open_files  += 1 if _hash_item_instance["file status"] == "open"
#        end


#       end
    end
    puts "#{__FILE__}:#{__LINE__}-> current open file count is #{__open_files}" if __open_files > 0
    new_file_name = "#{$pid_dir}" <<  $directory_separator << "Active_process_#{$Parsed_log_line.log_pid.to_s.rjust(5,"0")}_#{$startup_cnt}_#{$pid_cycle}_"<<$base_file_name<<".log"
    if File.exist?(new_file_name) then
        puts "#{__FILE__}:#{__LINE__}-> trying to overwrite existing file #{new_file_name}"
#    if File.exist?($pid_dir<< $directory_separator <<
#         "Active_process_#{$Parsed_log_line.log_pid.to_s.rjust(5,"0")}_#{$startup_cnt}_#{$pid_cycle}_"<<$base_file_name<<".log") then

         puts "#{line_group_in}"
    end
     _new_pid_file = File.new(new_file_name,"w") if $create_pid_files
     # keep one file name for EVM and another for PRODUCTION until merged
#     line_group_in.each do |x|
#       puts._new_pid_file(x)
#     end
#     if $base_file_name == "production" then
#       puts "#{__FILE__}:#{__LINE__}"
#     end
     $active_processes[$Parsed_log_line.log_pid]["file_handle"] =  _new_pid_file
     $active_processes[$Parsed_log_line.log_pid]["file_status"] =  "open" if $create_pid_files
  else
#  puts "#{__FILE__}:#{__LINE__}->line group 0 => #{line_group_in[0].inspect}"

  end
  case $active_processes[$Parsed_log_line.log_pid]["file_status"]
  when /open/ then 
  _pid_file = $active_processes[$Parsed_log_line.log_pid]["file_handle"]
  line_group_in.each do |_x|
      _pid_file.puts "#{_x}" if _pid_file && $active_processes[$Parsed_log_line.log_pid]["error_pid"]  # 201005 23 - only write out error pid process lines
      $active_processes[$Parsed_log_line.log_pid]["lines"] += 1
      $active_processes[$Parsed_log_line.log_pid]["lines after exit"] += 1     if $active_processes[$Parsed_log_line.log_pid]["requested_exit_reason"]
      ## count lines after logical process exit !!!
     end    
  when /closed/ then
   _pid_file = $active_processes[$Parsed_log_line.log_pid]["file_handle"]
#    puts "attempt to write to closed file for pid \"#{$Parsed_log_line.log_pid}\"\: log lines follow\: "
    line_group_in.each do |_x|
        puts "Active_pid_ file for pid '#{$Parsed_log_line.log_pid}' already closed for log line \n\t#{_x} "
#       _pid_file.puts "#{_x}" if _pid_file                       # if file still current
      $active_processes[$Parsed_log_line.log_pid]["lines"] += 1          # increment gross line count for process
      $active_processes[$Parsed_log_line.log_pid]["lines after exit"] += 1     # count lines after logical process exit !!!

#    puts "\t#{__FILE__}:#{__LINE__}->#{_x}"
    end
  end
# the following code may not be precisely correct, but it should get us close enought to the last time
# that the process is recognized in the log handler by using the time of the first line in the line group
$active_processes[$line_group_pid]["last heard from"] = $Parsed_log_line.log_datetime_string
$active_processes[$line_group_pid]["last heard from seconds"] = $Parsed_log_line.log_datetime

  case line_group_in[0]
  when /ERROR --/ then $active_processes[$line_group_pid]["error_cnt"] += 1
#    when $La_008 then $active_processes[$line_group_pid]["error_cnt"] += 1
  when /WARN --/  then $active_processes[$line_group_pid]["warn_cnt"] += 1
#    when $La_009 then $active_processes[$line_group_pid]["error_cnt"] += 1
  when /DEBUG --/ then $active_processes[$line_group_pid]["debug_cnt"] += 1
#    when $La_010 then $active_processes[$line_group_pid]["error_cnt"] += 1
  when /FATAL --/ then $active_processes[$line_group_pid]["fatal_cnt"] += 1
#    when $La_011 then $active_processes[$line_group_pid]["error_cnt"] += 1
  end
#  _test_value = true
  _test_value = triage_log_line1(line_group_in)
  if _test_value then
#    puts "#{__FILE__}:#{__LINE__} true value returned \n\t #{line_group_in[0]}"
    return
  end
#  return if triage_log_line1(line_group_in)

#  case x.payload_word1
#  when /HandSoap/ then
#    process_handsoap(x)
#    return
#  when /MiqVimUpdate[\.|\-]monitorUpdates\:/ then return
##  when /MIQ\(VcRefresher[\.|\-]get_vc_data\)/ then return
##  when /MIQ\(PostgreSQL-log_db_stats\)/ then
#  when /MiqVimDataStore\(/ then return
#  when /MiqVimInventory\(/ then return
#  when /MIQ\(MiqServer[\-|\.]status_update\)/ then
#      return if /Process info/ !~ x.payload              # ignore the non-'process info' lines
#  when /$Q-task_id/ then
#    case x.payload
#    when /VMware\(VixDiskLib\)/ then return
#    when /MIQ\(save_vmmetadata\)\:/ then return
##    when /\) Scanning \[/ then                          #allow this to drop thru
#    when /MIQ\(Config\./ then return                    #don't follow this log line
#    when /<PolicyEngine>/ then return
##    when /MIQ\(MiqFaultTolerantVim\-_connect\)/ then return
#    when /MIQ\(Vm\-save_metadata\)/ then return
#
#    end
#  when /MIQ\(EmsRefreshHelper[\-|\.]update_relats\)/ then return
#  when /<AutomationEngine>/ then return
#  when /<PolicyEngine>/ then return
#  when /MiqVimBroker[\-|\.]getMiqVim\:/ then return
#  when /VimBrokerWorker/ then
##MIQ(VimBrokerWorker) Preloading broker for EMS: [Virtual Center (192.168.254.25)], successful
##MIQ(VimBrokerWorker) Preloading broker for EMS: [Virtual Center (192.168.254.25)]
#    case line_group_in[0]
#    when /Preloading broker/ then
#      capture_broker_latency_times($Parsed_log_line)
#    end
#  when /MiqBrokerObjRegistry\.release/ then return
#  when /MiqBrokerObjRegistry\.registerBrokerObj/ then return
#  when /MiqBrokerObjRegistry\.unregisterBrokerObj/ then return
##  when /MIQ\(VcRefresher-refresh\)/ then #allow this to drop thru
##  when /MIQ\(EventCatcher\)/ then        #allow this to drop thru
#  when /MiqVimVm\(/ then return
#  when /MIQ\(MiqFaultTolerantVim\-_connect\)/ then
#      case line_group_in[0]
#      when /Connecting with address\:/ then
#        capture_broker_latency_times($Parsed_log_line)
#      when /Connecting to EMS\:/ then
#        capture_broker_latency_times($Parsed_log_line)
#      when /Preloading broker for EMS\:/ then
#        capture_broker_latency_times($Parsed_log_line)
#      when /API version\:/ then
#        capture_broker_latency_times($Parsed_log_line)
#
#      end
#  else
#
#  end

case $active_processes[$Parsed_log_line.log_pid]["process type"]    # added 10/19/2009 to skip over vimbroker log lines if possible
when /Vim/ then
  if /Stopping Broker/ =~ line_group_in[0] ||
      / started\./ =~ line_group_in[0] ||
      /exit/ =~ line_group_in[0] ||
      / ERROR / =~ line_group_in[0] ||                              # is this is an error then I need to capture it and summarize
      /Queueing refresh / =~ line_group_in[0] ||
      /log_db_stats/ =~ line_group_in[0] then
      if line_group_in.size == 1 then process_single_line(line_group_in[0])
        else process_multiline_group(line_group_in)
      end
  end
when nil then
#[----] I, [2012-04-09T12:06:01.436317 #20858:157b542d393c]  INFO -- :
#  #MIQ(EmsRefreshCoreWorker) ID [9885], PID [20858], GUID [5bd40cfe-823c-11e1-8b6d-005056af00a5], Zone [default], Active Roles [], Assigned Roles [], Configuration:
    case line_group_in[0]
    when /MIQ\((\S*)\)\s*ID\s*\[(\d*)\],\s*PID\s*\[(\d*)\],\s*GUID\s*\[(.*?)\],\s*Zone\s*\[(.*?)\],\s*Active Roles\s*\[(.*?)\],\s*Assigned Roles\s*\[(.*?)\],\s*Configuration\:/ then
        $active_processes[$Parsed_log_line.log_pid]["process type"] = $1 # plug process type
#        $active_processes[$Parsed_log_line.log_pid][""] = $2  # plug ID
#        $active_processes[$Parsed_log_line.log_pid][""] = $3  # plug PID
#        $active_processes[$Parsed_log_line.log_pid][""] = $4  # plug GUID
#        $active_processes[$Parsed_log_line.log_pid][""] = $5  # plug Zone
#        $active_processes[$Parsed_log_line.log_pid][""] = $6  # plug Active Roles
#        $active_processes[$Parsed_log_line.log_pid][""] = $7  # plug Assigned Roles
        _worker_type = $1
        _pid = $3
        _guid = $4
        _active_roles = $6
        _assigned_roles = $7
        _active_roles = "" if _active_roles == nil
        _assigned_roles = "" if _assigned_roles == nil
        $active_processes[_pid]["GUID"] = _guid
        $active_processes[_pid]["process type"] = _worker_type
        $active_processes[_pid]["worker type"] = _worker_type
        $active_processes[_pid]["assigned roles"] = '"' + _assigned_roles + '"'
        $active_processes[_pid]["active roles"] = '"' + _active_roles + '"'

#        $active_processes[_pid] = {"GUID"=> _guid, "PID" => _pid,
#            "process type" => _worker_type, "worker type" => _worker_type,
#            "assigned roles" => '"' + _assigned_roles + '"', "active roles" => '"' + _active_roles + '"',
#            "last heard from" => $Parsed_log_line.log_datetime_string.split(".")[0] ,
#            "last heard from seconds" => $Parsed_log_line.log_datetime,
#
#            "first seen seconds" => $Parsed_log_line.log_datetime}
    when /ERROR \-\-/  then # =~ line_group_in[0] then
          if line_group_in.size.to_i == 1 then
            process_single_line(line_group_in)
          else
            process_multiline_group(line_group_in)
          end  
    when /\:\s*(\S*)\s*started\./ then # =~ line_group_in[0] then
        puts "EVMServer? log line #{line_group_in[0]}"
        $active_processes[$Parsed_log_line.log_pid]["process type"] = $1
    end
  if /\:\s*(\S*)\s*started\./ =~ line_group_in[0] then
    puts "EVMServer? log line #{line_group_in[0]}"
    $active_processes[$Parsed_log_line.log_pid]["process type"] = $1
  end
     when "" then
        if /\:\s*(\S*)\s*started\./ =~ line_group_in[0] then
         puts "EVMServer? log line #{line_group_in[0]}"
         $active_processes[$Parsed_log_line.log_pid]["process type"] = $1
       end



#  puts "#{__FILE__}:#{__LINE__}- vim broker log line"
else
#    if /has reached the interval/ =~ line_group_in[0] &&
#        /MiqQueue\./  !~ line_group_in[0]then
#    puts "#{__FILE__}:#{__LINE__}- #{line_group_in[0]}"
  end
  if line_group_in.size.to_i == 1 then
    process_single_line(line_group_in)
  else
    process_multiline_group(line_group_in)
  end
#end
  # empty the array since all processing should be completed
  # line_group_in = line_group_in.clear 
  line_group_in.clear
#end
end
class Log_Processes_Info
  attr_accessor :key_field, :process_guid, :process_type, :process_timeout
    attr_accessor :start_time, :line_cnt, :error_cnt, :warn_cnt, :fatal_cnt
    attr_accessor :requested_exit_time, :requested_exit_info, :detected_exit_time
    attr_accessor :max_used_storage, :cpu_time_used, :last_heart_from
    attr_accessor :file_status, :file_handle
  def initialize(parsed_logline)     #consider using already parsed log line as input
    @key_field = nil                  #combine startup cnt, pid#, & bld number for uniqueness
    @process_guid = nil               # if process has guid put it here
    @process_type = nil               # if process type is known, put it here
    @process_timeout = nil            # if separate timeout info put it here
    @start_time = nil                 # time when process first detected
    @line_cnt = 0                     # each time a line is added, increment this
    @error_cnt = 0                    # for each error detected increment
    @warn_cnt = 0                     # for each warning detected increment
    @fatal_cnt = 0                    # for each fatal msg detected , increment
    @requested_exit_time = nil        # if we detect another process requesting this one terminate, put info here
    @requested_exit_info = nil        # gather pid, worker type of process requesting exit
    @detected_exit_time = nil         # when/if log reports exit ending record here
    @max_used_storage = nil           # record maximum storage attributed to this process
    @cpu_time_used = nil              # collect cpu time
    @last_heard_from_time = nil       # time last log line recognized
    @file_status = "initial"               # for output file -status (open or closed)
    @file_handle = nil                # if file is open then put file object here

  end
end
