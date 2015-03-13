=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: log_line_summarize.rb 24591 2010-11-08 15:45:16Z thennessy $
=end
def log_line_summarize(one_string)
#    if /Garbage/ =~ one_string then
#    puts "#{__FILE__}:#{__LINE__}=>#{one_string}"
#  end
#  if /reading/ =~ one_string then
#    puts "#{__FILE__}:#{__LINE__}=>#{one_string}"
#  end
#  memory usage has exceeded
#proxies4job\) Proxies for
  # this routine expects a string to be passed in, not an array
#  puts "#{one_string}"
  # split line into standard boiier plate and payload
  return if log_lines_to_skip(one_string)
  _line_date_time_compare = $Parsed_log_line.log_raw_datetime.tr(" ",".")   #inject regexp "any char" where blanks are
  if /#{_line_date_time_compare}/ =~ one_string then                        # if this line matches one for which we already have current created a class instance
#    puts "#{__FILE__}:#{__LINE__}=> liens are identical"
    _parsed_one_string = $Parsed_log_line                                   # then use it
  else 
   _parsed_one_string = Parsed_log_line.new(one_string)                     # otherwise we need to create a new one
  end

#  _parsed_one_string = $Parsed_log_line                                    #take the global object instead of creating another object
#  case _parsed_one_string.log_type_word
## the only lines of interest for summarizing are ERROR, WARN
## and selected INFO type lines, all others should be skipped
#    when /ERROR/ then
#    when /WARN/  then
#    when /INFO/  then
#      case _parsed_one_string.payload
#        # there is a large set of log messages that contain the work error
#        # but do not indicate errors as we are tracking them, so identify
#        # the ones to ignore here and catch all of the others
#      when /status \[error\]/ then   return      #ignore info log lines with this text
#      when /vm_scan_context/ then    return      #ignore info log lines with this text
#      when /GeneralHostErrorEvent/   then  return #ignore info log lines with this text
#      when /status: error/ then      return      #ignore info log lines with this text
#      when /There is no owning Host for this VM/ then
#        # this error message comes from "MIQ(vm_controller-button)" type log message
#        # and I consider this to be a non-error from a programming/debugging perspective
#        # The line above removes it from the error summary, but it will still
#        # be presented in the evm_error.txt file
#      when /^Completed|^Redirected/ then
#        # if just informational messages containing "error" text just
#        # skip them
#      when /MIQ\(config\) Database Adapter\:/ then  #allow this line since it begins a new startup
#      else
#        if /[Ee]rror/ !~ _parsed_one_string.payload then
#          return
#        end
#      end
##  else
##    return
#  end
  line_array = one_string.split("-- :")
  # save the payload for later processing
  _original_payload = line_array[1]
#  if /Creating/ =~ _original_payload then
#    puts "#{__FILE__}:#{__LINE__}- ?"
#  end
  case _original_payload.lstrip
  when /$HandSoap/ then
    capture_soap_data(_parsed_one_string)
    return if _parsed_one_string.log_type_word == "INFO" # && _parsed_one_string.payload.split.size == 3
  when /\-\-\-\s*Request\:/ then
    capture_soap_data(_parsed_one_string)
    return if _parsed_one_string.log_type_word == "INFO" && _parsed_one_string.payload.split.size == 3
  when /\-\-\-\s*Response\:/ then
    capture_soap_data(_parsed_one_string)
    return if _parsed_one_string.log_type_word == "INFO" && _parsed_one_string.payload.split.size == 3
  when /Q\-task_id\(\[vc\-refresher\]\)/ then
#    if /save_(\S*?)\_inventory/ =~ _original_payload then
      process_vc_refresher_log_lines(one_string)
#    end
  when /$MIQ\{(\S*?)\-disconnect_/ then            # if the first word is MIQ and looks like an ems type action, process it
    process_vc_refresher_log_lines(one_string)     # even though this isn't a vc-refresher log line
  when /$MIQ\{(\S*?)\-disconnect_/ then            # if the first word is MIQ and looks like an ems type action, process it
    process_vc_refresher_log_lines(one_string)     # even though this isn't a vc-refresher log line

  when /MIQ\(EmsRefreshHelper[\-|\.]save_(\S*)_inventory/ then            # if the first word is MIQ and looks like an ems type action, process it
    process_vc_refresher_log_lines(one_string)     # even though this isn't a vc-refresher log line
    
# MIQ(VcRefresher.get_vc_data) EMS: [Virtual Center (10.200.16.206)] Retrieving Storage inventory...Complete - Count: [83]
  when /MIQ\(VcRefresher\.get_vc_data\)/ then
    process_vc_refresher_log_lines(one_string)     # VC elements counts are in these lines

  when /VdlConnection\.__closeDisk__\:/ then
    return if _parsed_one_string.log_type_word == "WARN"
  when / VdlDisk\: / then
     return if _parsed_one_string.log_type_word == "WARN"
  end

  #Failed to log user event with EMS.  Error: [NoMethodError]: undefined method `path' for "
  if /Failed to log user event with EMS.  Error\: \[NoMethodError\]\: undefined method `path' for / =~ _original_payload then
    _original_payload = $PREMATCH + "Failed to log user event with EMS.  Error: [NoMethodError]: undefined method `path' for ..."
    line_array[1] = _original_payload
  end




# with PID [18824] has not responded in 1832.616127 seconds, restarting worker
   if /with PID \[(\d{1,6})\]\s*GUID\s*\[(.*?)\]\s*has not responded in\s+(\d{3,6})\.(\d{3,6})\s+seconds, restarting worker/ =~ _original_payload then
     _pid = $1
     _guid = $2
     _hiatus = $3 + "." + $4
     if $active_processes.has_key?(_pid) then
       if $active_processes[_pid]["requested_exit_reason"] == nil ||
          $active_processes[_pid]["requested_exit_reason"].class.to_s == "NilClass" then              # if nil then set value to string
#       end
      $active_processes[_pid]["requested_exit_reason"] = "no response in #{_hiatus} seconds"
       else                                                                         #else append to existing string
         $active_processes[_pid]["requested_exit_reason"] += "-no response in #{_hiatus} seconds"
       end
     else "PID #{_pid} is not in $active_processes - dumping\n#{$Parsed_log_line.inspect}"
     end
#    _original_payload = $PREMATCH + "with PID [###] has not responded in ####.#### seconds, restarting worker" + $POSTMATCH
#    line_array[1] = _original_payload
  end

#Deleting snapshot: reference: [snapshot-34492]
  if /Deleting snapshot\: reference\:\s\[snapshot\-(\d{1,20})\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "Deleting snapshot: reference: [snapshot-####]" + $POSTMATCH
    line_array[1] = _original_payload
  end

#Time Threshold [Wed Mar 25 10:57:16 UTC 2009] Last Heartbeat [Wed Mar 25 10:57:15 UTC 2009], restarting worker
  if /Time Threshold \[(.*?)\] Last Heartbeat \[(.*?)\]\, restarting worker/ =~ _original_payload then
    _original_payload = $PREMATCH + "Time Threshold [...] Last Heartbeat [...], restarting worker" + $POSTMATCH
    line_array[1] = _original_payload
  end
#Couldn't open disk file: [DCRaid2] Xav Secondary/Xav Secondary_3.vmdk
  if /Couldn't open disk file\: \[(.*?)\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "Couldn't open disk file: [#{$1}] {vmpath/vmname}"
                                                          #decided to retain the Datastore name for the time being,
                                                          # just dropping the vm specific info
    line_array[1] = _original_payload
  end
#Unable to process snapshot metadata for config file [[DCRaid2] Sp47-testupgrade-bh/Sp47-testupgrade-bh.vmx].
#Message:[can't convert Hash into String]
  if /Unable to process snapshot metadata for config file \[(.*)\]\.\s*Message\:/ =~ _original_payload then
    _original_payload = $PREMATCH + "Unable to process snapshot metadata for config file [[datastore] vm-path/vmname]. Message:" + $POSTMATCH
                                                          #decided to retain the Datastore name for the time being,
                                                          # just dropping the vm specific info
    line_array[1] = _original_payload
  end

#Transaction (Process ID 58) was deadlocked
  if /Transaction \(Process ID (.*?)\) was deadlocked/ =~ _original_payload then
    _original_payload = $PREMATCH + "Transaction (Process ID ###) was deadlocked"
    line_array[1] = _original_payload
  end

#NAME [Scan from Vm Lockheed-2.1.0.16] preventing current process from proceeding due to policy failure
  if /NAME \[(.*?)\] preventing current process from proceeding due to policy failure/ =~ _original_payload then
    _original_payload = $PREMATCH + "NAME [Scan from Vm ....] preventing current process from proceeding due to policy failure " + $POSTMATCH
    line_array[1] = _original_payload
  end

#Processing Vm: [jeos303] failed with error [Unable to find uuid]. Skipping Vm.
if /Processing Vm\:\s*\[(.*?)\] failed with error \[Unable to find uuid\]. Skipping Vm./ =~ _original_payload then
    _original_payload = $PREMATCH + "Processing Vm: [...] failed with error [Unable to find uuid]. Skipping Vm." + $POSTMATCH
    line_array[1] = _original_payload
  end

#The parent virtual disk has been modified since the child was created
  if /The parent virtual disk has been modified since the child was created/ =~ _original_payload then
    _original_payload = $PREMATCH + "The parent virtual disk has been modified since the child was created"
    line_array[1] = _original_payload
  end

#The parent virtual disk has been modified since the child was created
  if /The parent of this virtual disk could not be opened/ =~ _original_payload then
    _original_payload = $PREMATCH + "The parent of this virtual disk could not be opened"
    line_array[1] = _original_payload
  end

# MIQ(Storage-scan_timer) Queuing scan of storage [DemoXEN] failed due to error:[RuntimeError], [No active EMS available for Datastore [...]...skipping
  if /Queuing scan of storage \[(\*?)\] failed/ =~ _original_payload then
    _original_payload = $PREMATCH + "Queuing scan of storage [...] failed" + $POSTMATCH

  end

#MIQ(EmsEvent.add) ems_id: [1] Event Type cannot be determined for TaskEvent in event_data:
  if /Event Type cannot be determined for TaskEvent in event_data\:/ =~ _original_payload then
    _original_payload = $PREMATCH + "Event Type cannot be determined for TaskEvent in event_data:"  # deliberately drop the trailing text
   line_array[1] = _original_payload
  end

    if /\#\<(.*)?\:0x(.*)?\>/ =~ _original_payload then
      _original_payload = $PREMATCH + "#<#{$1}:0x......>" + $POSTMATCH
      line_array[1] = _original_payload
#      puts "#{line_array[1]}"
    end

#  MIQ(MiqPerfCollectorWorker-clean_active_messages) Message id: [455726] Setting state to 'error'  
  if /Message id\:\s*\[(\d*)\] Setting state to 'error'/ =~ _original_payload then
    _original_payload = $PREMATCH + "Message id: [....] Setting state to 'error'"
    line_array[1] = _original_payload
  end

# connect_to_ems - Unable to connect to the EMS: [30.5.224.22] for Resource: [Vm], id: [2]
  if /connect_to_ems \- Unable to connect to the EMS\:\s*\[(.*?)\] for Resource\: \[(\S*)\], id\: \[(\d*)\]/  =~ _original_payload then
    _original_payload = $PREMATCH + "connect_to_ems - Unable to connect to the EMS: [EMSname] for Resource: [resource class], id: [instance id]"
    line_array[1] = _original_payload
  end
# for: [Host], [1], [vi4esx6.galaxy.local]  Unhandled exception during perf data collection:: [execution expired],
  if /for\: \[(\S*)\], \[(\d*)\], \[(.*?)\] Unhandled exception during perf data collection: \\s*\[execution expired\],/  =~ _original_payload then
    _original_payload = $PREMATCH + "for: [class_type], [instance id], [instance name] Unhandled exception during perf data collection: [executon expired], ..."
    line_array[1] = _original_payload
  end
#MIQ(VimPerformanceHelper-vim_collect_perf_data) [Realtime] for: [Vm], [268], [amrsdv227035d] Unhandled exception during perf data collection:....
  if /MIQ\(VimPerformanceHelper-vim_collect_perf_data\) \[(\S*)\] for\: \[(\S*)\], \[(\d*)\], \[(.*?)\] Unhandled exception during perf data collection:..../  =~ _original_payload then
    _original_payload = $PREMATCH + "MIQ(VimPerformanceHelper-vim_collect_perf_data) [interval] for: [class_type], [instance id], [instance name] Unhandled exception during perf data collection:...."
    line_array[1] = _original_payload
  end

#WARN: Couldn't find Job with ID=13402,
  if /Couldn't find Job with ID=(\d{1,12})/ =~ _original_payload then
    _original_payload = $PREMATCH + "Couldn't find Job with ID=####" + $POSTMATCH
   line_array[1] = _original_payload
  end

#job timed out after 348.11987 seconds of inactivity
  if /timed out after\s*(.*)\s*seconds/ =~ _original_payload then
    _original_payload = $PREMATCH + "timed out after #####.##### seconds" + $POSTMATCH
   line_array[1] = _original_payload
  end

#MIQ(MiqQueue.deliver) (PID: ...) Message id: [...], Ident: [generic], Zone: [default], Role: [smartproxy], Server: [0a97d6aa-f206-11dd-b2cf-005056800b06], Target id: [], Task id: [...], Command: MiqServer.scan_sync_vm, timed out after 123.934433 seconds. Timeout threshold [1200]
 if /Server\:\s*\[(.*?)\]\,/ =~ _original_payload then
    _original_payload = $PREMATCH + "Server: [...]," + $POSTMATCH
   line_array[1] = _original_payload
 end

#   MIQ(WorkerMonitor) System memory usage has exceeded 10% of swap: Total: [2344120320], Used: [1184079872]
  if /System memory usage has exceeded (.*)\%\s*of swap\: Total\: \[(.*?)\], Used\: \[(.*?)\]/ =~ _original_payload then
    log_line_of_interest(_parsed_one_string)
    _original_payload = $PREMATCH + "System memory usage has exceeded " + $1 +"% of swap: Total: ["+ $2 + "], Used: [....]" + $POSTMATCH
   line_array[1] = _original_payload
  end

#ScanMetadata error status:[16]: message:[Unable to mount filesystem. Reason:[VixDiskLib_raw.open (errcode=16028): Too many levels of redo logs - [SE_FEOpen-E0] cn071vcce130/cn071vcce130-000369.vmdk
  if /Reason\:\[VixDiskLib_raw.open \(errcode=16028\)\: Too many levels of redo logs/ =~ _original_payload then
    log_line_of_interest(_parsed_one_string)
    _original_payload = $PREMATCH + "Reason:[VixDiskLib_raw.open (errcode=16028): Too many levels of redo logs"  # don't include $POSTMATCH since that has too much detail
   line_array[1] = _original_payload
  end

#  with PID [4892] process memory usage [393326592] exceeded limit [367001600], restarting worker
   if /process memory usage \[(\d{1,11})\] exceeded limit \[(\d{1,12})\]/ =~ _original_payload then
       _original_payload = $PREMATCH + "process memory usage [....] exceeded limit [" + $2 +"]" + $POSTMATCH
       line_array[1] = _original_payload
   end
#Retrying due to 1205 response from sql server
   if /Retrying due to 1205 response from sql server\s*(.*)?\s*WHERE/ =~ _original_payload then
       _original_payload = $PREMATCH + "Retrying due to 1205 response from sql server " + $1 + " WHERE ...."
       line_array[1] = _original_payload
   end

# MIQ(job-check_jobs_for_timeout) Job: guid: [934ca590-6639-11df-af9f-005056a6334a]
   if /MIQ\(job\-check_jobs_for_timeout\)\s*Job\:\s*guid\:\s*\[(.*)?\]/ =~ _original_payload then
       _original_payload = $PREMATCH + "MIQ(job-check_jobs_for_timeout) Job: guid: [...]" + $POSTMATCH
       line_array[1] = _original_payload
   end

# MIQ(abstract_adapter) Name: [MiqQueue Create], Message: [ODBC::Error: 37000 (1222) [unixODBC][FreeTDS][SQL Server]Lock request time out period exceeded.:
# INSERT INTO [miq_queue] ([created_on], [class_name], [args], [miq_worker_id], [zone], [reserved], [target_id], [updated_on], [task_id], [deliver_on], [queue_name],
# [msg_timeout], [priority], [lock_version], [miq_callback], [role], [instance_id], [md5], [msg_data], [method_name], [server_guid], [state])
# VALUES('2010-05-24 09:37:31.940', 'JobProxyDispatcher', '--- []
   if /Lock request time out period exceeded.: INSERT INTO\s*(.*)?\s*VALUES\(/ =~ _original_payload then
       _original_payload = $PREMATCH + "Lock request time out period exceeded.: INSERT INTO " + $1 + " VALUES(....)"
       line_array[1] = _original_payload
   end
#end

#MIQ(WorkerMonitor) Worker [MiqGenericWorker] with PID [4470] GUID [cf575320-0c1a-11de-88e9-005056a164b2] has not responded in 612.82805 seconds, restarting worker
#    if /with PID \[(\d{1,5})\] process memory usage \[(\d{1,11})\] exceeded limit \[(\d{1,12})\], restarting worker/ =~ _original_payload then
   if /PID\s*\[(.*?)\]\s*GUID\s*\[(.*?)\]/ =~ _original_payload then
       _original_payload = $PREMATCH + "PID [...] GUID [....]" + $POSTMATCH
       line_array[1] = _original_payload
   end

   if /of swap: Total\: \[(\d*)\]/ =~ _original_payload then
       _original_payload = $PREMATCH + "of swap: Total: [#{$1}]" 
       line_array[1] = _original_payload
   end

  #VMDB::Initializer.init - Program Name: runner, PID: 2696, ENV['MIQ_GUID']: 299d0d18-f25e-11df-a3ff-005056a6005e, ENV['EVMSERVER']:
  if /VMDB\:\:Initializer\.init/ =~ _original_payload then
    _temp = $POSTMATCH
    _temp_array = _temp.split(",")
    _temp_array.each do |element|
        case element
        when /Program Name\:\s*(.*)/ then
        when /PID\:\s*(\d*)/ then _pid = $1
        when /ENV\[\'MIQ\_GUID\'\]\:\s*(.*)/ then _guid = $1
        end
      end
        if $active_processes.has_key?(_pid) then
          $active_processes[_pid]["GUID"] = _guid
          $active_processes[_pid]['last heard from'] = $Parsed_log_line.log_datetime_string.split(".")[0]
          $active_processes[_pid]['last heard from seconds'] = $Parsed_log_line.log_datetime
          $active_processes[_pid]['first seen seconds'] = $Parsed_log_line.log_datetime
        else
          $active_processes[_pid] = {"GUID"=> _guid,
            "last heard from" => $Parsed_log_line.log_datetime_string.split(".")[0] ,
            "last heard from seconds" => $Parsed_log_line.log_datetime,
            "first seen seconds" => $Parsed_log_line.log_datetime}
        end
        if $guid_process_xref.has_key?(_guid) then
          $guid_process_xref["pid"] = _pid
        else
          $guid_process_xref[_guid] = {"pid"=> _pid}
        end
  end


  # MIQ(WorkerMonitor) PID [2391], GUID [85b4699e-38ef-11df-8aa4-005056916ea7], Zone [default],
  #  Active Roles ["reporting", "smartstate", "smartstate_drift", "vcenter"], 
  #  Assigned Roles [event,reporting,scheduler,smartstate,smartstate_drift,vcenter,vcrefresh], Configuration:
   if /MIQ\((.*)?\)\s*PID\s*\[(\d*)\],\s*GUID\s*\[(.*)?\],\s*Zone\s*\[(.*)?\],\s*Active Roles\s*\[(.*)?\],\s*Assigned Roles\s*\[(.*)\],\s*Configuration:/ =~ _original_payload then
#     puts "#{__FILE__}:#{__LINE__}- #{_original_payload}"
     _miq_worker_type = $1
     _pid = $2
     _guid = $3
     _zone = $4
     _active_roles = $5.tr('"'," ")                # translate out the double quotes from the string preventing problems when importing to access or csv
     _active_roles_ = _active_roles.split(",")
     _active_roles = ""
     _active_roles_.each do |x|
       _active_roles<< x.strip + ','
     end

     _assigned_roles = $6
     if _assigned_roles.class.to_s == "NilClass" then
       _assigned_roles = ""
     end
#        puts "#{__FILE__}:#{__LINE__}- #{_original_payload}"
        if $active_processes.has_key?(_pid) then
          $active_processes[_pid]["GUID"] = _guid
          $active_processes[_pid]['process type'] = _miq_worker_type
          $active_processes[_pid]['active roles'] = '"' + _active_roles + '"'
          $active_processes[_pid]['assigned roles'] = '"' + _assigned_roles + '"'
          $active_processes[_pid]['last heard from'] = $Parsed_log_line.log_datetime_string.split(".")[0]
          $active_processes[_pid]['last heard from seconds'] = $Parsed_log_line.log_datetime
          $active_processes[_pid]['first seen seconds'] = $Parsed_log_line.log_datetime if $active_processes[_pid]['first seen seconds'] == nil
        end
   end

     if /MIQ\((.*)?\)\s*ID\s*\[(\d*)\]\,\s*PID\s*\[(\d*)\],\s*GUID\s*\[(.*)?\],\s*Zone\s*\[(.*)?\],\s*Active Roles\s*\[(.*)?\],\s*Assigned Roles\s*\[(.*)\],\s*Configuration:/ =~ _original_payload then
#     puts "#{__FILE__}:#{__LINE__}- #{_original_payload}"
     _miq_worker_type = $1
     _worker_id = $2
     _pid = $3
     _guid = $4
     _zone = $5
     _active_roles = $6.tr('"'," ")                # translate out the double quotes from the string preventing problems when importing to access or csv
     _active_roles_ = _active_roles.split(",")
     _active_roles = ""
     _active_roles_.each do |x|
       _active_roles<< x.strip + ','
     end

     _assigned_roles = $7
     if _assigned_roles.class.to_s == "NilClass" then
       _assigned_roles = ""
     end
#        puts "#{__FILE__}:#{__LINE__}- #{_original_payload}"
        if $active_processes.has_key?(_pid) then
          $active_processes[_pid]["GUID"] = _guid
          $active_processes[_pid]['process type'] = _miq_worker_type
          $active_processes[_pid]['active roles'] = '"' + _active_roles + '"'
          $active_processes[_pid]['assigned roles'] = '"' + _assigned_roles + '"'
          $active_processes[_pid]["worker id"] = _worker_id
          $active_processes[_pid]['last heard from'] = $Parsed_log_line.log_datetime_string.split(".")[0]
          $active_processes[_pid]['last heard from seconds'] = $Parsed_log_line.log_datetime

        end
   end

    if  /(.*)\s*starting\. [PID|GUID]\s*(.*)/ =~ _original_payload then
      _payload_1 = $1.strip
      _payload_2 = $2
      _pid =  line_array[0].split[-2].tr("#]","  ").strip
      $active_processes[_pid]["worker type"] = _payload_1
      $active_processes[_pid]["requested_exit_reason"] = nil
      _payload_array = _payload_2.split(",")
      _payload_array.each do |x|
#        case x
        if /\[(.{36})\]/ =~ _payload_2 then $active_processes[_pid]["GUID"] = $1 
          $guid_process_xref[$1] = {"pid" => _pid}
        end
        if /Zone\s*\[(.*?)\],\s+/ =~ _payload_2 then $active_processes[_pid]["zone"] = $1 end
        if /Role\s*\[(.*?)\]?,\s+/ =~ _payload_2 then $active_processes[_pid]["role"] = $1 end
#        end
      end
      return                          #processing fot his line is complete, return
    end
    if /Exit request received. Worker exiting.|Invoking shutdown method for MiqServer/ =~ _original_payload ||
        /restarting\. Worker exiting/ =~ _original_payload ||
        /timout error Worker exiting/ =~ _original_payload ||
        /seconds Worker exiting\./ =~ _original_payload  ||
        /seconds\. Worker exiting\./ =~ _original_payload ||
        /Stopping all workers/ =~ _original_payload then

#      puts "#{__FILE__}:#{__LINE__} ->#{one_string}"
#      _temp_array = line_array[0].split
      if /Stopping all workers/ =~ _original_payload && /Parent MiqServer/ =~ _original_payload && /has not responded/ =~ _original_payload then
         if /Stopping all workers/ =~ _original_payload then
           $miqserver_termination_msg = $PREMATCH + "Stopping all workers"
         end
#        $miqserver_termination_msg = _original_payload
      end



      if /restarting/ =~ _original_payload then
        $active_processes[$line_group_pid]["requested_exit_reason"] = "restarting for roll change reason"
      end
      if /timout/ =~ _original_payload then
        $active_processes[$line_group_pid]["requested_exit_reason"] = "process timout reason"
      end
      if /Monitor stopping because parent MiqServer not responding/ =~ _original_payload then
        $active_processes[$line_group_pid]["requested_exit_reason"] = "Monitor stopping because parent MiqServer not responding"
        $miqserver_termination_msg = nil
      end
      if /Unable to find instance for Worker Monitor\./ =~ _original_payload &&
          /Parent MiqServer id/ =~ _original_payload &&
          /has not responded in (\d*) seconds\. Worker exiting\./ =~ _original_payload then
        $active_processes[$line_group_pid]["requested_exit_reason"] = "Monitor stopping because parent MiqServer not responding"
      end
    $active_processes[$line_group_pid]["detected_exit"] = $Parsed_log_line.log_datetime_string.split(".")[0]
    $active_processes[$line_group_pid]["detected_exit_seconds"] = $Parsed_log_line.log_datetime
      if $active_processes[$line_group_pid]["file_status"] == "open" then
#        $active_processes[$line_group_pid]["file_status"] = "closed"  # change file status to closed
#        _temp_file = $active_processes[$line_group_pid]["file_handle"] # get file handle
#        _temp_file.close                                               # close the file
#        $active_processes[$line_group_pid]["file_handle"] = nil        # reset the file handle since the file is now closed
      if $active_processes[$line_group_pid]["requested_exit_reason"] == nil  then
         if     $Startups[$startup_cnt]["status"] != "shutdown" then
                if $miqserver_termination_msg != nil then
                   $active_processes[$line_group_pid]["requested_exit_reason"] = '"' + $miqserver_termination_msg + '"'
                else
                   $active_processes[$line_group_pid]["requested_exit_reason"] = "no reason available"
                end
         else
         $active_processes[$line_group_pid]["requested_exit_reason"] = "at shutdown"
         end
      end
 # now remove this process from the active_process list and add it to the archive_process list
       _temp_guid = $active_processes[$line_group_pid]["GUID"]
       if _temp_guid == nil ||_temp_guid.size != 36 then
         puts "#{__FILE__}:#{__LINE__}"
         puts "\t$active_processes[#{$line_group_pid}] seems to have malformed GUID-'#{_temp_guid}' " #- entry being dumped for inspection \n #{$active_processes[$line_group_pid].inspect}"
       end
#         puts "#{__FILE__}:#{__LINE__}"
#         puts "\t$active_process with PID-#{$line_group_pid} and GUID '#{$active_processes[$line_group_pid]["GUID"]}' being added to $all_process_archive"
#         $all_process_archive << $active_processes[$line_group_pid]    #copy hash heap to archive array
         # now remove the entry from the active_process list
#         $active_processes.delete($line_group_pid)
#         puts "#{__FILE__}:#{__LINE__}"
#         puts "\tPID #{$line_group_pid} is removed from $active_processes"
#       end
#         $all_process_archive << $active_processes[$line_group_pid]  if $active_processes[$line_group_pid].class.to_s != "NilClass"  #copy hash heap to archive array
         # now remove the entry from the active_process list
#         $active_processes.delete($line_group_pid) if $active_processes[$line_group_pid].class.to_s != "NilClass"
      end
#      return                          #processing fot his line is complete, return
# "RETURN" ABOVE IS COMMENTED OUT BY TCH 20090916 BECAUSE IT DOES NOT ALLOW FOR THE LAST LINE OF A PROCESS TO BE AN ERROR type line.  If it is, the error is not captured.
    end
#MIQ(MiqEventCatcher-stop) Stopping worker: queue_name [ems_1], GUID [c61047e6-e397-11dd-b170-005056806e93]...
#[----] I, [2009-02-26T20:07:57.317533 #18682]  INFO -- : MIQ(MiqWorkerMonitor-stop) Stopping worker: PID [18167], GUID [65a360e6-043a-11de-b176-005056807778], queue_name []...

  if /Stopping worker\:/ =~ _original_payload || 
      /requesting worker to exit/ =~ _original_payload ||
      /Stopping Broker/ =~ _original_payload then
    capture_stopping_worker_request() if /status \[stopped\].../ !~ _original_payload && /status \[killed\]/ !~ _original_payload
    return
      if /PID\s*\[(.*)\]/ =~ _original_payload then
#      if $guid_process_xref.has_key?($1) then
      _target_pid = $1
      capture_process_stop_request(_target_pid)
#      $active_processes[_target_pid]["requested_exit"] = $Parsed_log_line.log_datetime_string # populate request to exit time
#      else puts "#{__FILE__}:#{__LINE__}-> Stopping non-existent guid-pid not recorded=>'#{one_string}'"
#      end
#      $active_processes.has_attribute()
# need to create a guid-process cross reference hash
# so that I can find the $active_processes hash key for this GUID instance
      else
    if /GUID\s*\[(.*)\]/ =~ _original_payload then
      if $guid_process_xref.has_key?($1) then
      _target_pid = $guid_process_xref[$1]["pid"]
      capture_process_stop_request(_target_pid)
#      $active_processes[_target_pid]["requested_exit"] = $Parsed_log_line.log_datetime_string # populate request to exit time
      else puts "#{__FILE__}:#{__LINE__}-> Stopping non-existent guid-pid not recorded=>'#{one_string}'"
      end
#      $active_processes.has_attribute()
# need to create a guid-process cross reference hash
# so that I can find the $active_processes hash key for this GUID instance
    end
      return                          #processing fot his line is complete, return
  end
  end

#  if /Unable to find uuid. Skipping Vm./ =~ _original_payload then
#    puts "#{__FILE__}:#{__LINE__}=>#{one_string}"
#  end
  # break up the boilerplate and extract the log severity type
  severity = line_array[0].split[-1]
#  case severity
#  when /ERROR/
#
#  end
case severity
when /INFO/ then                                            
  case _original_payload                                    # if this is INFO
  when /[Ee]rror/ then                                      # AND contains word 'error'
  when /job aborting/ then                                  # or contains phrase 'job aborting'
  when /GeneralHostErrorEvent/   then
      examine_log_line(one_string) unless /\[initialize\]/ =~ one_string
      return
  when /vm_scan_context/ then
      examine_log_line(one_string) unless /\[initialize\]/ =~ one_string
      return
#  when //
  else
      examine_log_line(one_string) unless /\[initialize\]/ =~ one_string
    return
  end
when /ERROR|WARN/ then
#  if /Worker Monitor id \[(.*)?\] PID \[(.*)?\] GUID \[(.*)?\]/ =~ _original_payload then
#    _original_payload = $PREMATCH + "Worker Monitor id [...] PID [....] GUID [....]" + $POSTMATCH
#    line_array[1] = _original_payload
#  end
  if /Create disk space by deleting unneeded files/ =~ _original_payload then
    _original_payload = $PREMATCH
    line_array[1] = _original_payload
  end

    if /Alarm Event missing data required for evaluating Alerts, skipping. Full data/ =~ _original_payload then
      _original_payload = $PREMATCH + "Alarm Event missing data required for evaluating Alerts, skipping. Full data..."
      line_array[1] = _original_payload
    end

  if /Worker Monitor id \[(\d*)?\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "Worker Monitor id [...]" + $POSTMATCH
    line_array[1] = _original_payload
  end
  if /PID \[(.*)?\] GUID \[(.*)?\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "PID [....] GUID [....]" + $POSTMATCH
    line_array[1] = _original_payload
#        line_array[1] = _original_payload
  end

  if / ID\s*\[(\d*)\]/ =~ _original_payload then
    _original_payload = $PREMATCH + " ID [....]" + $POSTMATCH
    line_array[1] = _original_payload
#        line_array[1] = _original_payload
  end

    if / SPID\: \[(\d*)\]/ =~ _original_payload  then
    _original_payload = $PREMATCH + " SPID [....]" + $POSTMATCH
    line_array[1] = _original_payload
#        line_array[1] = _original_payload
    end
  if /Worker id\: \[(.*?)\],/ =~ _original_payload then
    _original_payload = $PREMATCH + "Worker id: [....]" + $POSTMATCH
    line_array[1] = _original_payload
#        line_array[1] = _original_payload
  end


    if /Message has been in 'dequeue' state since (.*)?, setting state to 'error'/ =~ _original_payload then
        _original_payload = $PREMATCH + "Message has been in 'dequeue' state since ....., setting state to 'error'" + $POSTMATCH
        line_array[1] = _original_payload
        line_array[1] = _original_payload
    end

#Q-task_id([message specific id]) MIQ(VimPerformanceMixin.host2mor)
#Failed to resolve MOR from Host id: [22], hostname: [gobesxd1.ameren.com], ip address: [10.200.16.194], vim_data.....
#Q-task_id([message specific id]) MIQ(VimPerformanceMixin.vm2mor)
#Failed to resolve MOR from Vm id: [355], uuid [503a3ebc-c781-3646-21a0-c2234c8f38cb], vim_data
 
  if /Failed to resolve MOR from / =~ _original_payload then
     if /, vim_data/ =~ _original_payload then
      _original_payload = $PREMATCH + ", vim_data ..."
      line_array[1] = _original_payload
      
     end
  end

#Could not find VM: cn069ojte154.tic.ca.kp.org/cn069ojte154.tic.ca.kp.org.vmx Method:[log_backtrace]
   if /Could not find VM\:\s*(.*)\s+Method/ =~ _original_payload then
    _original_payload = $PREMATCH + "Could not find VM: ..... Method"  + $POSTMATCH
    line_array[1] = _original_payload
  end
     if /Could not find VM\:\s*(.*)\s*/ =~ _original_payload then
    _original_payload = $PREMATCH + "Could not find VM: ..... "  + $POSTMATCH
    line_array[1] = _original_payload
  end
 
#Invalid cursor state:
   if /Invalid cursor state\:/ =~ _original_payload then
    _original_payload = $PREMATCH + "Invalid cursor state: ....." 
    line_array[1] = _original_payload
  end

#not supported [65], aborting
   if /not supported \[(\d{1,6})\], aborting/ =~ _original_payload then
    _original_payload = $PREMATCH + "not supported [####], aborting" + $POSTMATCH
    line_array[1] = _original_payload
  end


#with error Timeout::Error: execution expired:
   if /with error Timeout\:\:Error\: execution expired\:/ =~ _original_payload then
    _original_payload = $PREMATCH + "with error Timeout::Error: execution expired:......"  
    line_array[1] = _original_payload
  end



#'Timeout::Error: execution expired:
   if /\'Timeout\:\:Error\: execution expired\:/ =~ _original_payload then
    _original_payload = $PREMATCH + "'Timeout::Error: execution expired:......" 
    line_array[1] = _original_payload
  end



#no credentials defined for Host [cnwdcesxt004.tic.ca.kp.org]
   if /no credentials defined for Host \[(.*)\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "no credentials defined for Host [....]" + $POSTMATCH
    line_array[1] = _original_payload
  end


#getSnapMor: VM [Local Storage - cn074esxe183] cn074ctrx191/cn074ctrx191.vmx has no snapshots
   if /getSnapMor\:\s+VM\s+\[(.*)\.vmx has no snapshots/ =~ _original_payload then
    _original_payload = $PREMATCH + "getSnapMor: VM [STORAGE NAME] - VM NAME.vmx has no snapshots" + $POSTMATCH
    line_array[1] = _original_payload
  end


#No eligible proxies for VM :[cn069ojte156.tic.ca.kp.org/cn069ojte156.tic.ca.kp.org.vmx]
   if /No eligible proxies for VM \:\[(.*)\.vmx\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "No eligible proxies for VM :[....vmx]" + $POSTMATCH
    line_array[1] = _original_payload
  end

#Could not find VM: cn069ojte157.tic.ca.kp.org/cn069ojte157.tic.ca.kp.org.vmx Event
   if /Could not find VM:\s*(.*)\.vmx\s*Event/ =~ _original_payload then
    _original_payload = $PREMATCH + "Could not find VM: ....vmx Event" + $POSTMATCH
    line_array[1] = _original_payload
  end
#for Job: [ce07fbfa-9daf-11df-9616-005056911403]
  if /for Job\: \[(.*)\]/  =~ _original_payload then
    _original_payload = $PREMATCH + "for Job : [...]" + $POSTMATCH
    line_array[1] = _original_payload
  end
#Proxies for [Vm:94-CN049TRSV193:on]
   if /Proxies for \[Vm\:(.*?)\:(.*?)\]\s/ =~ _original_payload then
    _original_payload = $PREMATCH + "Proxies for [Vm:....:" + $2 + "] " + $POSTMATCH
    line_array[1] = _original_payload
  end

   if /Q-[Tt]ask_id\(\[(.{2,36})\]\)\s*JOB\(\[/ =~ _original_payload then
#    puts "#{one_string}"
    _original_payload = $PREMATCH + "JOB([" + $POSTMATCH
    line_array[1] = _original_payload
  end
#Q-task_id([message specific id]) MIQ(Vm-path) VM [cn069ojte152.tic.ca.kp.org]
   if /\s*VM\s*\[(.*)\]\s*/ =~ _original_payload then
    _original_payload = $PREMATCH + " VM [...\] " + $POSTMATCH
    line_array[1] = _original_payload
  end
# MIQ(management_system_controller-button): local-cnwdcesxt006:
   if /\)\:\s*(.*)\:\s*Error/ =~ _original_payload then
    _original_payload = $PREMATCH + "): {unique VM name}: Error" + $POSTMATCH
    line_array[1] = _original_payload
  end
#for Datastore [cnwdcesxt004:storage1]
   if /for Datastore\s*\[(.*)\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "for Datastore [...]" + $POSTMATCH
    line_array[1] = _original_payload
  end
#MIQ(VimPerformanceHelper-map_mors_to_objects) failed to map mor to object for object [Host] id: [9] with error [
  if /MIQ\(VimPerformanceHelper-map_mors_to_objects\) failed to map mor to object for object/ =~ _original_payload then
      if /with error\s*\[/ =~ _original_payload then
        _original_payload = $PREMATCH + "with error [...]"   # truncate remaineder of very long message
        line_array[1] = _original_payload
      end
  end
#MIQ(VimPerformanceHelper-vim_collect_perf_data) Unhandled exception during perf data collection:
   if /MIQ\(VimPerformanceHelper-vim_collect_perf_data\)/ =~ _original_payload then
     if /Unhandled exception during perf data collection\:/ =~ _original_payload then
       _original_payload = $PREMATCH + "Unhandled exception during perf data collection:...."
       line_array[1] = _original_payload
     end
     if /Timeout Error during perf data collection\: \[execution expired\]/ =~ _original_payload then
       _original_payload = $PREMATCH + "Timeout Error during perf data collection: [execution expired]...."
       line_array[1] = _original_payload
     end
  end

#] VM:[[esxdev003:storage1] VirtualAppliances.net LAMP/VirtualAppliances.net LAMP.vmx]
    if  /\]\s+VM\:\[(.*)\]/ =~ _original_payload then
#    puts "#{one_string}"
    _original_payload = $PREMATCH + "] VM:[...]" + $POSTMATCH
    line_array[1] = _original_payload
  end

#Q-task_id([message specific id]) MIQ(MiqQueue.deliver) (PID: ...) Message id: [...],
#Ident: [generic], Zone: [*], Role: [], Server: [4cc3f6ec-e2db-11dd-9984-000c29ee28ac], Target id: [],
#Task id: [9c592148-e33d-11dd-8748-0050568a6238], Command: MiqServer.scan_sync_vm, timed out after 600 seconds

#for VM :[[Local Storage - cn074esxe182] pdviactrx189/pdviactrx189.vmx] -
#[No active SmartProxies found to analyze this VM], aborting job [48d20e9a-e338-11dd-baba-005056806e93].
  if  /job \[(.{36})\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "job [...]" + $POSTMATCH
    line_array[1] = _original_payload
  end
  if  /for\s+VM\s*\:\[\[(.*)\]\s*\-/ =~ _original_payload then
    _original_payload = $PREMATCH + "for VM :[[...]...] -" + $POSTMATCH
    line_array[1] = _original_payload
  end

#MIQ(VimPerformanceHelper-vim_collect_perf_data) Timeout Error during perf data collection: [execution expired]
  if  /\s+Task id\:\s*\[(.{36})\],/ =~ _original_payload then
#    puts "#{one_string}"
    _original_payload = $PREMATCH + " Task id: [...]," + $POSTMATCH
    line_array[1] = _original_payload
  end
  if  /Message id\: \[(\d*)\]?\,/ =~ _original_payload then
#    puts "#{one_string}"
    _original_payload = $PREMATCH + "Message id: [...]," + $POSTMATCH
    line_array[1] = _original_payload
  end
  if  /PID\:\s*(\d{1,6})\s*\)/ =~ _original_payload then
    _original_payload = $PREMATCH + "PID: ...) " + $POSTMATCH
    line_array[1] = _original_payload
  end
  if  /for VM:\[(.*)\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "for VM:[...]" + $POSTMATCH
    line_array[1] = _original_payload
  end
  if  /for VM\s*\[(.*)\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "for VM [...]" + $POSTMATCH
    line_array[1] = _original_payload
  end
  if  /Command \[(\S*)\] failed after \[(.*)\] seconds.  TaskId:\[(.*)\]/ =~ _original_payload then
    _original_payload = "Command [" + $1 + "] failed after [##.##] seconds.  TaskId:[....]"
    # take the command failure and preserve the command but generalize the duration and the taskid so it can be summarized
    # at the highest level
    line_array[1] = _original_payload
  end
    if  /Host:0x(.*)\>/ =~ _original_payload then
#    puts "#{one_string}"
    _original_payload = $PREMATCH + "Host:<...> " + $POSTMATCH
    line_array[1] = _original_payload
    end
   if  /TaskId:\[([abcdef0123456789\-]+)\]\s+/  =~ _original_payload then
      _original_payload = $PREMATCH + "TaskId:[....] " + $POSTMATCH               #catch errors wher Taskid not Job is used
      line_array[1] = _original_payload
    end
  if  /MIQ\(vm_controller-button\):(.*):? The Default Repository SmartProxy, (.*),? is not running \'scan\' not attempted/  =~ _original_payload then
      _original_payload = "MIQ(vm_controller-button): [Specific VM Name]: The Default Repository SmartProxy, #{$2} is not running 'scan' not attempted"
      line_array[1] = _original_payload
  end
  if /for VM \[(.*)\]\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "for VM [...]]" + $POSTMATCH
    line_array[1] = _original_payload
  end
  if /\<AutomationEngine\> Instance \[(.*)\] not found in MiqAeDatastore/ =~_original_payload then
    _original_payload = "<AutomationEngine> Instance [....] not found in MiqAeDatastore"
    line_array[1] = _original_payload
  end
   if /Not enough free memory \[(.*)\]/ =~ _original_payload then
    _original_payload = $PREMATCH + "Not enough free memory [...]" + $POSTMATCH
    line_array[1] = _original_payload
  end

  if /Since failures occurred, not disconnecting for Vms/ =~ _original_payload then
    _original_payload = $PREMATCH + "Since failures occurred, not disconnecting for Vms" # msg is huge - drop the following text
    line_array[1] = _original_payload
  end
#  Resource: [Vm], id: [1122] - Failed to initialize
  if /Resource\: \[(\S*)\], id\: \[(\d*)\] \- Failed to initialize/ =~ _original_payload then
    _original_payload = $PREMATCH + "Resource: [class name], id: [instance id] - Failed to initialize" + $POSTMATCH
    line_array[1] = _original_payload
  end
# MIQ(VimPerformanceHelper-perf_init_vim_and_history) Resource: [class name], id: [instance id] - Failed to initialize performance history from:
# due to error [Resource: [Vm], id: [368] is not connected to an EMS]
  if /\[Resource\: \[(\S*)\], id\: \[(\d*)\] is not connected to an EMS/ =~ _original_payload then
    _original_payload = $PREMATCH + "[Resource: [class name], id: [instance id] is not connected to an EMS" + $POSTMATCH
    line_array[1] = _original_payload
  end
end

#  if severity == "ERROR" && /Q-[Tt]ask_id\(\[(.{2,36})\]\)\s*JOB\(\[/ =~ _original_payload then
##    puts "#{one_string}"
#    _original_payload = $PREMATCH + "JOB([" + $POSTMATCH
#    line_array[1] = _original_payload
#  end

#    if severity == "ERROR" && /Task id\:\s*\[(.{2,36})\]?\,/ =~ _original_payload then
##    puts "#{one_string}"
#    _original_payload = $PREMATCH + "Task id: [...]," + $POSTMATCH
#    line_array[1] = _original_payload
#  end

  
#  if severity == "ERROR" && /Message id\: \[(\d*)\]?\,/ =~ _original_payload then
##    puts "#{one_string}"
#    _original_payload = $PREMATCH + "Message id: [...]," + $POSTMATCH
#    line_array[1] = _original_payload
#  end
#  if severity == "ERROR" && /PID\:\s*(\d{1,6})\s*\)/ =~ _original_payload then
#    _original_payload = $PREMATCH + "PID: ...) " + $POSTMATCH
#    line_array[1] = _original_payload
#  end
#    if severity == "ERROR" && /for VM:\[(.*)\]/ =~ _original_payload then
#    _original_payload = $PREMATCH + "for VM:[...]" + $POSTMATCH
#    line_array[1] = _original_payload
#  end
#  if severity == "ERROR" && /Command \[(\S*)\] failed after \[(.*)\] seconds.  TaskId:\[(.*)\]/ =~ _original_payload then
#    _original_payload = "Command [" + $1 + "] failed after [##.##] seconds.  TaskId:[....]"
#    # take the command failure and preserve the command but generalize the duration and the taskid so it can be summarized
#    # at the highest level
#    line_array[1] = _original_payload
#  end
#    if severity == "ERROR" && /Host:0x(.*)\>/ =~ _original_payload then
##    puts "#{one_string}"
#    _original_payload = $PREMATCH + "Host:<...> " + $POSTMATCH
#    line_array[1] = _original_payload
#    end
#   if /ERROR|WARN/ =~ severity  && /TaskId:\[([abcdef0123456789\-]+)\]\s+/  =~ _original_payload then
#      _original_payload = $PREMATCH + "TaskId:[....] " + $POSTMATCH               #catch errors wher Taskid not Job is used
#      line_array[1] = _original_payload
#    end
  
#  if severity == "ERROR" && /MIQ\(vm_controller-button\):(.*):? The Default Repository SmartProxy, (.*),? is not running \'scan\' not attempted/  =~ _original_payload then
#      _original_payload = "MIQ(vm_controller-button): [Specific VM Name]: The Default Repository SmartProxy, #{$2} is not running 'scan' not attempted"
#      line_array[1] = _original_payload
#  end
  
  if /Read-only file system \-\s*(.*\.msg)/ =~ _original_payload then
    _work_array = _original_payload.split
    _work_array[-2] = "[specific msgid]"
    _original_payload = _work_array.join(" ")
    line_array[1] = _original_payload

    puts "#{File.basename(__FILE__)}:#{__LINE__}=>#{_original_payload}"
  end
  #examine the first word of the payload to see if it contains a job/taskid 
  # or "#<*>" object string and
  # if it does, lets remove it making the error type more general
  if /\#\<.*\>\)/ =~ _original_payload then
    # begin ruby 1.9
#    payload_array = _original_payload.partition(/\#\<.*\>\)/)
#    payload_array[1] = "#<line_specific_identifier>)"
#    _payload = payload_array.join(" ").split
    #end ruby 1.9
    _begin0 = _original_payload.index("#<")
    _end0 = _original_payload.index(">)",(_begin0 + 1)) #if _begin0.class == fixnum
    _payload_array = _original_payload.split("#<")
    _part_two = _payload_array[-1].split(">)")
#    _payload = (_payload_array[0] + "#<line_specific_identifier>) " + _part_two[1.._part_two.size].join(" ")).split
    _payload = (_payload_array[0] + "#<line_specific_identifier>) " + _part_two[1.._part_two.size].join).split
    puts "#{File.basename(__FILE__)}:#{__LINE__}=> found special string \n string is #{_original_payload}\n begin substition at #{_begin0+2}\n end substition at #{_end0}"
    pp "#{File.basename(__FILE__)}:#{__LINE__}=>#{_payload.inspect}"
    line_array[1] = _payload_array[0] + "#<line_specific_identifier>)" + _part_two[1.._part_two.size].join(" ")
  else
    if line_array[1].class == "NilClass" then
      puts "#{File.basename(__FILE__)}:#{__LINE__}"
    end
#    puts "#{__FILE__}:#{__LINE__}=> #{line_array[1]}\n\f full line = \'#{one_string}\'"
  _payload = line_array[1].split #split into separate words
   end 
   if /MIQ\(vm_controller-button\)\:/ =~ _original_payload && /VM does not have BlackBox\./ =~ _original_payload then
     line_array[1] = _payload[0] + "(UNIQUE VM NAME)" + " VM does not have BlackBox."
   end
# puts "#{_payload}"
  # look at first word to see if it contains a guid
  # and if it does, remove it
  # lets catch all of the 'storate_dispatcher_context errors in the following
  # code section

  if severity =='ERROR' && /storage_dispatcher_context/ =~ line_array[1] then
    case line_array[1]
    when /action-process_start: Error job/ then
      if /eligible proxies/ =~ line_array[1] then
      _payload[0] = "JOB[specific job id] storage_dispatcher_context terminated for \"no eligible proxies for VM\" reason"
      line_array[1] = _payload[0]
      end
      if /undefined method/ =~ line_array[1] then
      _payload[0] = "JOB[specific job id] storage_dispatcher_context terminated for \"undefined method\" reason"
      line_array[1] = _payload[0]        
      end
    when /action-process_finish: pending job/  then
      _payload[0] = "JOB[specific job id] storage_dispatcher_context removed from pending queue \"no eligible proxies for VM\" reason. Hosts may not be credentialed"
      line_array[1] = _payload[0]      
    end
  end
  if severity == 'WARN' && /storage_dispatcher_context/ =~ line_array[1] then
    case line_array[1]
    when /(.*),\s*state_data:/ then
      line_array[1] = $1
    end
  end
  
  # process and generalize the MiqQueue.deliver errors here
    if severity == 'ERROR' && /MIQ\(MiqQueue[\.|\-]deliver/ =~ line_array[1] then
    # capture specific error line information and generalize it for error summary reporting
    case line_array[1]
    when /MIQ\(MiqQueue[\.|\-]deliver\)\s*\(PID: (\d*)\)\s*(.*)$/ then
      _temp = $2
      # capture into _temp everything that follows the PID 
      _pid = $Parsed_log_line.log_pid
      # capture the PID but we'll generalize later
      _temp_array = _temp.split(",")
      # break the string following PID into array segments and generalize each
      _work_string = ""
      _temp_array.each {|x|
        case x
        when /Message id\:\s*\[(\d*)\]/ then  _work_string = _work_string + "Message id: [...], "
        when /Ident:\s*\[(.*)\]/ then _work_string = _work_string + "ident: [....], "
        when /Target id\:\s*\[(\d*)\]/ then _work_string = _work_string + "Target id: [...], "
        when /Task id\: \[(\S*)\]/ then _work_string = _work_string + "Task id: [....], "
        when /Path\:\s*(.*)/ then _work_string = _work_string + "Path: ....msg, "
        when /No eligible proxies for vm :\[(.*)\]/ then _work_string =_work_string + "No eligible proxies for vm :[...],"
        when /aborting job \[(.*)\]/ then _work_string = _work_string + "aborting job [...],"
        when /error\: \[(.*?)\]/ then _work_string = _work_string + " error: [.....],"
        else _work_string = _work_string + x + ", "
        end
      }        
#        _temp = _temp_array.join(",")
        # combine the modifications that are now generalized back into _temp string
        line_array[1] = "MIQ(MiqQueue.deliver) (PID: ... ) " + _work_string
        # assign to line_array[1] for error summary reporting
    when /MIQ\(MiqQueue[\.|\-]delivered\)\s*(.*)$/ then
            _temp = $1
      # capture into _temp everything that follows the PID
      _pid = $Parsed_log_line.log_pid
      # capture the PID but we'll generalize later
      _temp_array = _temp.split(",")
      # break the string following PID into array segments and generalize each
      _work_string = ""
      _temp_array.each {|x|
        case x
        when /Message id\:\s*\[(\d*)\]/ then  _work_string = _work_string + "Message id: [...], "
        when /Ident:\s*\[(.*)\]/ then _work_string = _work_string + "ident: [....], "
        when /Target id\:\s*\[(\d*)\]/ then _work_string = _work_string + "Target id: [...], "
        when /Task id\: \[(\S*)\]/ then _work_string = _work_string + "Task id: [....], "
        when /Path\:\s*(.*)/ then _work_string = _work_string + "Path: ....msg, "
        when /No eligible proxies for vm :\[(.*)\]/ then _work_string =_work_string + "No eligible proxies for vm :[...],"
        when /aborting job \[(.*)\]/ then _work_string = _work_string + "aborting job [...],"
        when /error\: \[(.*?)\]/ then _work_string = _work_string + " error: [.....],"
        else _work_string = _work_string + x + ", "
        end
      }
#        _temp = _temp_array.join(",")
        # combine the modifications that are now generalized back into _temp string
        line_array[1] = "MIQ(MiqQueue.deliver) (PID: ... ) " + _work_string
        # assign to line_array[1] for error summary reporting
    end
  end
  
  # process and generalize the Q-Task_id errors here
#  if severity == 'ERROR' && /Q-Task_id/ =~ _original_payload then
#    puts "#{File.basename(__FILE__)}:#{__LINE__}"
#  end
  if /ERROR|WARN/ =~ severity  && /Q\-Task_id/ =~ line_array[1] then
  #if /ERROR|WARN/ =~ severity &&/Q-Task_id =~ line_array[1] then  
    
#    if /Unable to find uuid/ =~ line_array[1] then
#      puts "#{__FILE__}:#{__LINE__} -> #{line_array[1]}" 
#    end
    case line_array[1]
    when /for xml\:/  then
 #Q-Task_id([message specific id]) MIQ(vm-save_metadata): Invalid xml error [undefined method `elements' for nil:NilClass] for xml:[      
      # if the log line contains the xml, then lets truncate the rest of the line
      # assume it is only the xml
      line_array[1] = $PREMATCH + "for xml: [<....>]"
      # because some of the following logic looks at the _payload array
      # lets make sure that it corresponds to the new line_array[1]
      _payload = line_array[1].split
 
    when /No eligible proxies/   then
#Q-Task_id([message specific id]) JOB([f761815e-6e60-11dd-b4b5-000c2913e66a] vm_scan_context) action-abort: 
#job aborting, No eligible proxies for vm :[//dev012/target_machines/scratch/vhd_vms/VS Team/Vista_VS.vmc], aborting job [f761815e-6e60-11dd-b4b5-000c2913e66a].   
      
      _temp_array = line_array[1].split(",")         # ok, lets create another working array
                                                      # where elements are deliminated by commas (since vm name may include spaces)
      _temp_array.size.times do |i|
        case _temp_array[i]
        when /JOB\(\[(.*?)\]/ then _temp_array[i] = $PREMATCH + "JOB([...]" + $POSTMATCH # generalize JOB id
        when /vm\s*\:\[(.*?)\]/ then _temp_array[i] = $PREMATCH + "VM :[...]" + $POSTMATCH  # generalized vm name
        when /job\s\[(.*?)\]/ then _temp_array[i] = $PREMATCH + "job [...]" + $POSTMATCH    # generalize job id
        end
      end
        line_array[1] = _temp_array.join(",")         # put everything back into the array
        _payload = line_array[1].split                # then split again into _payload array by space separated words

    when /\) Proxies for \[Vm:/ then
      # this routine is engaged when all possible proxies are in an off state
      if /JOB\(\[(.*)\]\s* proxies4job\)/ =~ line_array[1] then
        line_array[1] = $PREMATCH + "JOB([...] proxies4job\)" + $POSTMATCH # generalize JOB id
        _payload = line_array[1].split                # then split again into _payload array by space separated words
      end
#       _temp_array = line_array[1].split(",")         # ok, lets create another working array
#                                                      # where elements are deliminated by commas (since vm name may include spaces)
#                                                      
#      _temp_array.size.times do |i|
#        case _temp_array[i]
#        when /JOB\(\[(.*)\]/ then _temp_array[i] = $PREMATCH + "JOB([...]" + $POSTMATCH # generalize JOB id
#        when /vm\s*\:\[(.*)\]/ then _temp_array[i] = $PREMATCH + "VM :[...]" + $POSTMATCH  # generalized vm name
#        when /job\s\[(.*)\]/ then _temp_array[i] = $PREMATCH + "job [...]" + $POSTMATCH    # generalize job id
#        end
#      end
#        line_array[1] = _temp_array.join(",")         # put everything back into the array
#        _payload = line_array[1].split       
    when /Vm\: \[(.*)\] Unable to find uuid\./ then
      line_array[1] = $PREMATCH + "Vm: [...] Unable to find uuid." + $POSTMATCH   # generalize the payload content
      _payload = line_array[1].split                                              # force the payload array to match the generalized content
    when /JOB\(\[.*?\]\s*proxies4job\) Proxies for VM:\[(.*?)\]s*on storage/ then
      line_array[1] = $PREMATCH + "JOB([....] proxies4job) Proxies for VM:[##]-[vm name] on storage" + $POSTMATCH # generalize the job uuid into the payload content
      
      _payload = line_array[1].split                  # then split again into _payload array by space separated words
      
    end
                                                      
                                                      
 
  end
  
  # with the regular expression below I'm trying to distill both error and
  # warning messages into their essence for summary reporting:
  
  if /ERROR|WARN/ =~ severity  then
    if /MIQ\(/ =~ line_array[1] then
      case line_array[1]

      when /on target \[(.*)\],/ then
        line_array[1] = $PREMATCH + "on target [...] " + $POSTMATCH
      when /Worker guid \[(.*)\],/ then
        line_array[1] = $PREMATCH + "Worker guid [...] " + $POSTMATCH
      when /Worker guid \[(.*)\] being/ then
        line_array[1] = $PREMATCH + "Worker guid [...] being " + $POSTMATCH
      when /No host found for id \[(.*)\]/ then
        line_array[1] = $PREMATCH + "No host found for id [...]" + $POSTMATCH
      when /No proxy found for id \[(.*)\]/ then
        line_array[1] = $PREMATCH + "No proxy found for id [...]" + $POSTMATCH
      when /Error\: \[Couldn't find all Vms with IDs \((.*?)\)/ then
        line_array[1] = $PREMATCH + "Error: [Couldn't find all Vms with IDs (...)" + $POSTMATCH

# MIQ(Vm.vim_collect_perf_data) [Realtime] for: [Vm], [2603], [nzxpap34] Unhandled exception during perf data collection: [MIQ(MiqFaultTolerantVim-_connect) Rescue: DRb::DRbConnError: Unable to establish vim connection to: [172.18.194.21]; Broker may be not running.], class: [MiqException::MiqVimBrokerConnError] with requested query: [nil]
      when /Unhandled exception during perf data collection/ then
        _prematch = $PREMATCH
        _postmatch = $POSTMATCH
        if /\[Realtime\]\s*for\:\s*\[(\S+)\],\s*\[(\d+)\],\s*\[(.*)?\]/ =~ _prematch then
          _prematch = $PREMATCH + "[Realtime] for: [class], [###], [class instance name]"
        end
        line_array[1] = _prematch + " Unhandled exception during perf data collection:" + _postmatch


  #Event Type cannot be determined for TaskEvent. Using generic eventType [TaskEvent] instead. event:
      when /Event Type cannot be determined for TaskEvent. Using generic eventType \[TaskEvent\] instead. event\:/ then
        line_array[1] = $PREMATCH + "Event Type cannot be determined for TaskEvent. Using generic eventType [TaskEvent] instead. event: [{...}]"
      end
    end
    if /Q\-task_id/ =~ line_array[1] then
      case line_array[1]
  #Q-task_id([message specific id]) VMware(VixDiskLib): [NFC ERROR] NfcFssrvr_DiskOpen: received diskLib error 1048585 from server: NfcFssrvrOpen: Failed to open '/vmfs/volumes/492dabe8-fc71ea49-98d0-0018fe2fc605/ANPXPHH1/ANPXPHH1_1.vmdk': An error was detected.
      when /NfcFssrvrOpen\: Failed to open '(.*)'/ then
        line_array[1] = $PREMATCH + "NfcFssrvrOpen: Failed to open '---'" + $POSTMATCH
        _payload = line_array[1].split                                      # implant thish changed line into the _payload variable for subsequent processing
      end
    end
#    end
    
  end
  
  if severity !='INFO' && 
      /storage_dispatcher_context/ !~ line_array[1] &&
      /(\S+\s*\[)/ =~ _payload[0]  &&                            # use this to catch Q-taskid[ types but bypass "[xxxx]" types
      /Errno/ != _payload[0] then

#    puts "#{one_string}"
    _payload[0] = $1 + "message specific id])"             # strip out variable portion
#    if /action-process_start: Error job/ =~ line_array[1] && /No eligible proxies/ =~ line_array[1] then
#      line_array[1] = _payload[0] + 
#                      "storage_dispatcher_context) action-process_start: Error job[...]:" + 
#                      " No eligible proxies for vm:"
#    else
    line_array[1] = _payload.join(" ")  # rebuild the payload       
#    end
    
  end
  if /#\<(.*)\>/ =~ _payload[-1] then
      _payload[-1] = "unique class.objectid"
     line_array[1] = _payload.join(" ")  # rebuild the payload        
    end

    
#  if /INFO/=~ severity && /[Ee]rror/ !~ line_array[1] then
    # don't add into hash if nothing provocative
    # and only and INFO level message
    # otherwise this warrants further examination
    # as a possible error
#    
#  else
#  # prepend severity to payload  
#      key = severity + ":" + line_array[1]
#      if $Error_summary.has_key?(key) then
#          $Error_summary[key] += 1
#      else $Error_summary[key] = 1
#      end
#    end
#puts "#{line_array.inspect}"
    if /INFO/ =~ severity &&                                        #examine more closely INFO lines with the word error
       /[Ee]rror/ !~ line_array[1] &&
       /power state has changed / !~ line_array &&                  # catch state changes into INFO
       /\<PolicyEngine\>/ !~ line_array &&
         /ActiveRecord/ !~ line_array &&
#         /MIQ\(MiqAlert\.evaluate_alerts\)/ !~ line_array &&
       /job aborting/ !~ line_array[1]  then

      # added 20080805 because of komodo scan error not being picked up!
        # if the work error is not in the payload, then skip this entirely!   
        # don't add into hash if nothing provocative
        # otherwise this warrants further examination
        # as a possible error        
    else
      case line_array[1]                                            # these case conditions exclude INFO lines that should be ignored
                                                                    # if not explicitly ignored then it shows up in ERROR_summary report

        # there is a large set of log messages that contain the work error
        # but do not indicate errors as we are tracking them, so identify
        # the ones to ignore here and catch all of the others
      when /status \[error\]/ then         #ignore info log lines with this text
#      when /vm_scan_context/ then          #ignore info log lines with this text
#      when /GeneralHostErrorEvent/   then   #ignore info log lines with this text
      when /status: error/ then            #ignore info log lines with this text
      when /count for state/ then          # ignore count of state log lines
      when /MiqQueue\.delivered/ then        # ignore error msg put log lines- they are handled elsewhere
      when /MiqQueue\.put/ then
      when /MiqQueue\.get/ then
      when /MIQ\(MiqAlert\.evaluate_alerts\)/ then
      when /MiqQueue.m_callback/ then
      when /Advanced Settings Deleting/ then  # ignore these since the word error is in the vector/hash
      when /\<PolicyEngine\>/ then           #ignore these since error is probably in the policyname
      when /ErrorEvent/ then                 #lots of ErrorEvent being captured needlessly
#      when /HostDasErrorEvent/ then        #ignore this info log line
      when /Importing Policy\:/ then
      when / VdlDisk: / then               #ignore disk open warnings
      when /Importing Action\:/ then
      when /MIQ\(alert-preload\)/ then
#      when /\<AutomationEngine\> \<User-Defined Method\>/ then
      when /MIQ\(AlertMixin-event_log_threshold\?\)/ then
      when /Evaluating Alert/ then
      when /Evaluate Alert/ then
      when /Resolving policy/ then
      when /does not apply, skipping/ then   # skip policy log line if it doesn't apply
      when /policy_description\:/ then
      when /Instantiating/ then
      when /MiqAeEvent.build_evm_event/ then
      when /Guest Applications Deleting id\:/ then
      when /Adding file\:/ then
      when /MiqRedirectOutput\.send_to_log/ then
      when /Invoking action/ then
      when /Event Logs Deleting/ then
      when /task\-update_status/ then
      when /Error \[ODBC/ then
      when /Virtual machine is configured to use a device that prevents the snapshot operation/ then # ignore this INFO line
      when /Could not find VM/ then        # ignore this info line
      when /Parameters\:/ then            # ignore rails log message where this occurs
      when /Saving, state\: aborting, message\: Unable to mount filesystem.  Reason\:\[unknown error/ then
      when /MIQ\(MiqQueue\.delivered\) Message id\:\s*\[(.*)\], State\: \[error\]/ then
      when /action\-finished\:\s*job finished/ then # ignore job ending where error has already been recognized
        #    puts "#{__FILE__}:#{__LINE__} - #{log_line}"
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
      when /There is no owning Host for this VM/ then
        # this error message comes from "MIQ(vm_controller-button)" type log message
        # and I consider this to be a non-error from a programming/debugging perspective
        # The line above removes it from the error summary, but it will still
        # be presented in the evm_error.txt file
      when /^Completed|^Redirected/ then
        # if just informational messages containing "error" text just
        # skip them
      when /MiqVimDataStore/                    # these messages are huge and not of interest
      when /\{\:method_name=>\"powershell_command\"/ then # ignore this log line
      when /\:error=>false/  then               #ignore these lines
      else
        if /BlackBox/ =~ line_array[1] && severity == "ERROR" then
          puts "#{__FILE__}:#{__LINE__}"
        end
        # Since I'm trying to distill out possible errors from non-error marked lines
        # lets see if there is a job quid and if so, generalize the line to squeeze it out
        # and report it as a general, not a specific error
        if /INFO/ =~ severity && /JOB\(\[(.*)\]\s/ =~ line_array[1] && /[Ee]rror/ =~ line_array[1] then
          case line_array[1]
          when /JOB\(\[(abcdefg0-9\-)+\]\s/ then
              line_array[1] = $PREMATCH + "JOB([...] " + $POSTMATCH
          end
        end
        if $startup_cnt == nil then
          recognize_evm_startup()
          $Log_build_id = "startup_not_yet_found"
        end

  if /Garbage collection took\s*(.*)\s*seconds/ =~ line_array[1] then
    line_array[1] = $PREMATCH + "Garbage collection took "
    _time = $1.to_f
    _work_string = ""
#    case _time
    if _time > 600 then
      _work_string = (_time/100).to_i * 100         # turn value into hundreds of seconds
    else
      _work_string = (_time/5).to_i * 5           # turn value to tens of seconds

    end
    line_array[1] = line_array[1] +"> #{_work_string} seconds"
  end
  if /has not responded in\s*(.*)\s*seconds/ =~ line_array[1] then
    _remainder= $POSTMATCH
    line_array[1] = $PREMATCH + "has not responded in "
    _time = $1.to_f
    _work_string = ""
     if _time > 600 then
      _work_string = (_time/100).to_i * 100         # turn value into hundreds of seconds
    else
      _work_string = (_time/10).to_i * 10           # turn value to tens of seconds

    end
    line_array[1] = line_array[1] +"> #{_work_string} seconds" + _remainder
  end


         key = severity + ":" + " (#{$Log_build_id}).#{$startup_cnt}\t" + line_array[1]
          if $Error_summary.has_key?(key) then
          $Error_summary[key] += 1
          else $Error_summary[key] = 1
          end
      end
    end
    begin
#    if one_string.size == 0 || one_string == nil || one_string.class != 'String' then
#      puts ""
#    end
# puts "one_string value is '#{one_string}'"
  examine_log_line(one_string) unless /\[initialize\]/ =~ one_string
    rescue SystemCallError
      puts "#{__FILE__}:#{__LINE__}\n\t one_string value is #{one_string}"
      raise
    rescue SyntaxError => error_raised
       puts "SyntaxError=> #{error_raised}\n\t #{__FILE__}:#{__LINE__}\n\t one_string value is #{one_string}"     
      raise
#    rescue StandardError =>error_raised
#       puts "***\n\tStandardError=> #{error_raised}\n\t #{__FILE__}:#{__LINE__}\n\t one_string value is #{one_string}***\n\t\n\n"
#      raise
    end
#  examine_payload(_original_payload)
end
def recognize_evm_startup()
  $miqserver_termination_msg = nil
  if $startup_cnt > 0  then
    if  $Parsed_log_line.class.to_s != "Parsed_log_line" ||        # if $Parsed_log_line not of correct type
        $Startups[$startup_cnt].class.to_s == "NilClass" ||        # or $Startups[$Startup_cnt] is nil or "log_time" is nil then
        $Startups[$startup_cnt]["log_time"] == "" ||
        $Startups[$startup_cnt]["log_time"].class.to_s == "NilClass" then 
        puts "#{__FILE__}:#{__LINE__}-> something in here isn't going to be a number:" + 
             "\n\t$Startups[#{$startup_cnt}]=>#{$Startups[$startup_cnt].inspect}\n\t$Parsed_log_line=>#{$Parsed_log_line.inspect}"
#      return end
  else
      if  $Parsed_log_line.log_datetime - $Startups[$startup_cnt]["log_time"] < 60 then
      return             # need this check to prevent double counting initial startup since there is
                         # not yet a specific log line to indicated beginning of new startup
     end
    end
  end
#   puts "Examine $Performance_metrics here"

#   $Performance_metrics.each do |measurement|
#     case measurement.class
#     when /Performance_interval_metrics/ then
#       interval_stats_line = "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
#                  "#{measurement.log_datetime},#{measurement.build_vm_queries},#{measurement.db_processing}," +
#                  "#{measurement.interval},#{measurement.map_mors_to_intervals},#{measurement.map_mors_to_vmdb.objs}," +
#                  "#{measurement.miq_cmd},#{measurement.num_vim_queries},#{measurement.num_vim_trips}," +
#                  "#{measurement.target_class},#{measurement.target_element_id},#{measurement.taskid}," +
#                  "#{measurement.total_time},#{measurement.vim_connect},#{measurement.vim_execute_time}"
#        $performance_metrics_interval_file.puts "#{interval_stats_line}" if $performance_metrics_interval_file
#     when /Performance_realtime_metrics/
#     end
#   end
#   $Performance_metrics.clear                         #after all data is saved to disk, clear for next startup collection
#  end
   dump_and_clear_performance_metrics()
   if !$Parsed_log_line.startup_incremented then
    $startup_cnt += 1
    $Parsed_log_line.startup_incremented = true
   end
    $pid_cycle = 0                                        # reset pid cycle counter
    $last_pid = $Parsed_log_line.log_pid.to_i             # take current pid as the highest pid for this startup
#    $Startups[$startup_cnt] = {"count" => $startup_cnt, "log_time" => $Parsed_log_line.log_datetime,
#      "display_time" => nil,
#      "server_guid" => nil,
#      "role" => nil,
#      "zone" => nil,
#      "host" => nil,
#      "hostname" => nil,
#      "company" => nil,
#      "db username" => nil,
#      "db mode" => nil,
#      "db adapter" => nil,
#      "db database" => nil,
#      "db dsn" => nil,
#      "db max_connections" => nil,
#      "evmserver_table_startup_id" => nil,
#    }
    initialize_evm_startups_config()
    if $active_processes[$Parsed_log_line.log_pid]["worker type"].class.to_s == "NilClass" then
      puts "#{__FILE__}:#{__LINE__}: "
    end
    $active_processes[$Parsed_log_line.log_pid]["worker type"] = "EVM Server!"
    $active_processes[$Parsed_log_line.log_pid]["startup count"] = $startup_cnt
# since this is a startup all of the previous $active_processes should be moved to $all_process_archive
# with the exception of the current process number
    puts "$all_process_archive count is #{$all_process_archive.size} before copying"
    puts "$active_processes count is #{$active_processes.size} beginning to copy to $all_process_archive"
    $active_processes.each do |pid_key,process_hash|
        if pid_key == $Parsed_log_line.log_pid then
          next
        else
          _file = process_hash["file_handle"]              # get file handle value
        #  _file.close if _process["file_status"] == "open"
          _file.close if _file                             # if file is open, close it
          process_hash["file_handle"] = nil                #reset the value to nil
          process_hash["file_status"] = "closed"           #reset the file status to closed
          process_hash["requested_exit_reason"] = "at shutdown" if process_hash["requested_exit_reason"] == nil
          _temp_guid = process_hash["GUID"]                # save this guid
          if _temp_guid == nil || _temp_guid.size != 36 then
            puts "$active_processes[#{pid_key}] has invalid GUID #{_temp_guid}" #- contents being dumped for examination: \n#{process_hash.inspect}"
          end
            $all_process_archive << process_hash           # copy hash to the process archive array
            $guid_process_xref.delete(_temp_guid)
            puts "$active_processes[#{pid_key}] copied to $all_process_archive[#{_temp_guid}]"
#          end
        end
    end
    _temp_active_process = $active_processes[$Parsed_log_line.log_pid] #save current pid info as only current info
    $active_processes.clear                                 # empty the active process hash table
    $guid_process_xref.clear                                # empty the guid-pid cross reference has too
    $active_processes[$Parsed_log_line.log_pid] = _temp_active_process
    puts "evm startup with pid[#{$Parsed_log_line.log_pid}] is only entry in $active_processes hash"
    puts "$all_process_archive count is #{$all_process_archive.size}"
    if $generatedb then
      evmserver_startup = EvmStartups.new
      evmserver_startup.evm_server_startup_count = $startup_cnt
      evmserver_startup.evm_startup_process_id = $Parsed_log_line.log_pid
      evmserver_startup.evm_startup_first_seen_seconds = $Parsed_log_line.log_datetime
      evmserver_startup.evm_startup_first_seen_string = $Parsed_log_line.log_datetime_string
      evmserver_startup.evm_startup_process_id = $Parsed_log_line.log_pid
      evmserver_startup.save
      $Startups[$startup_cnt]["evmserver_table_startup_id"] = evmserver_startup.id
      puts "#{$Startups[$startup_cnt].inspect}"
    end
end
def capture_stopping_worker_request()
  # this routine is called when one process is requesting the termination of another
  # this is not the routine which processes the killing of one process by another
  # the only information needed is the $Parsed_log_line

  # get PID if it is available
  _temp_payload = $Parsed_log_line.payload
  # current log line is requesting stop of a pid-guid
    if /PID\s*\[(\d{1,5})\]/ =~ _temp_payload then
      _tmp_pid = $1
          if !$active_processes.has_key?(_tmp_pid) then
            # if the first time we are seeing this pid is during the shutdown process
            # then we have to do alot of processing to "fill in the gaps" or skip it entirely
            # for now I'm just going to skip it
            capture_process_stop_request(_tmp_pid)
            return
          end

      end
      if _tmp_pid == nil then
        puts "#{__FILE__}:#{__LINE__}; PID value is nil. payload follows:-> #{_temp_payload}"
      else
      if $active_processes[_tmp_pid]["GUID"] == "uninitialized" || $active_processes[_tmp_pid]["GUID"] == nil then
        # lets see if the required $active_processes[_tmp_pid]["GUID"]$active_processes pid entry has a valid guid
        # if guid is "uninitialized" then we can correct it here so that everything works ok
         if /GUID\s*\[(.*?)\]/ =~ _temp_payload then
           _tmp_guid = $1
           $active_processes[_tmp_pid]["GUID"] = _tmp_guid
           # inject correct guid for pid into $active_processes entry
           $guid_process_xref[_tmp_guid]= { "pid" => _tmp_pid}
           # inject guid as key to cross referrence guid pointing to correct pid
           # now everything should just flow
         end
      end
    end

  case _temp_payload

  when /GUID\s*\[(.*?)\]/ then
       if $guid_process_xref.has_key?($1) then
        _target_pid = $guid_process_xref[$1]["pid"]
        capture_process_stop_request(_target_pid)
#      $active_processes[_target_pid]["requested_exit"] = $Parsed_log_line.log_datetime_string # populate request to exit time
      else
        _unknown_guid = $1
        _log_line = $Parsed_log_line
        puts "#{__FILE__}:#{__LINE__}-> Stopping non-existent guid-pid not recorded=>'#{_unknown_guid}'\n\t #{$Parsed_log_line}\n\t log date time:#{_log_line.log_datetime_string}"
      end
   when /PID\s*\[(.*?)\]/ then capture_process_stop_request($1)     
  end
  # if PID is not available then get GUID
end
def capture_process_stop_request(pid)
  if pid == nil || pid == "" then
    puts "#{__FILE__}:#{__LINE__}- PID[#{pid}] not found in $active_processes hash - dumping log line for analysis" +
      "\n\t#{$Parsed_log_line.inspect} "
    return
  end
  if $active_processes.has_key?(pid) then
    $active_processes[pid]["requested_exit"] = $Parsed_log_line.log_datetime_string.split(".")[0] if $active_processes[pid]["requested_exit"] == nil  # populate request to exit time
#    $active_processes[pid]["request_exit_reason"] = ""          # set defaul reason to empty
    if /requesting worker to exit/ =~ $Parsed_log_line.payload || 
        /is being stopped/ =~ $Parsed_log_line.payload ||
        /Stopping Broker/ =~ $Parsed_log_line.payload
        then    # if worker is being signaled to stop
#MIQ(WorkerMonitor) Worker [MiqGenericWorker] with PID [5066] GUID [45d6f770-439e-11de-9d68-0050568026c2] is being stopped because system resources exceeded threshold, it will be restarted once memory has freed up

        if $active_processes[pid]["requested_exit_reason"].class.to_s == "NilClass" ||
            $active_processes[pid]["requested_exit_reason"] == nil ||
            $active_processes[pid]["requested_exit_reason"] == "" then
                                                                       # and reason isn't already captured
          case $Parsed_log_line.payload
          when /system resources exceeded/ then
            $active_processes[pid]["requested_exit_reason"] = "system resources exceeded"  # capture reason
          when /uptime has reached the interval/ then
            $active_processes[pid]["requested_exit_reason"] = "interval limit" #capture reason
          when /process\s*memory\s*usage\s*\[(.*?)\]\s*exceeded/ then
            _memory_used = $1.to_i
#CC:\Users\Tom Hennessy\Documents\kaiser\03-20-09\8a\cn049miqe240_4_20090320_080505\
            $active_processes[pid]["requested_exit_reason"] = "memory usage"   #capture reason
            $active_processes[pid]["memory size"] = _memory_used

#[----] I, [2009-10-22T12:50:04.308167 #15529]  INFO -- : MIQ(VimBrokerWorker) PID [15529] GUID [3e549f54-bf07-11de-9c48-00505691302e] 
#Worker Monitor id [364] PID [14983] GUID [d7e87e22-bf04-11de-a74c-00505691302e] has not responded in 180 seconds. 
#Parent MiqServer id [1] GUID [517dd17e-bea1-11de-a74c-00505691302e] has not responded in 180 seconds. Stopping Broker. 
          when /Parent MiqServer id \[(\d*)\] GUID \[(.*)\] has not responded in (\d*) seconds. Stopping Broker/
            $active_processes[pid]["requested_exit_reason"] = "Parent MiqServer not heartbeating Broker Stopping"
          else
            if $miqserver_termination_msg == nil then 
             $active_processes[pid]["requested_exit_reason"] = "not captured"   #capture reason as "unknown" in effect   
             puts "#{__FILE__}:#{__LINE__}-\n\tworker being requested to stop but reason not recognized\n\t#{$Parsed_log_line.inspect}"            
            else 
            $active_processes[pid]["requested_exit_reason"] = '"' + $miqserver_termination_msg + '"'
            end
          end
        end
    end
  else
    puts "#{__FILE__}:#{__LINE__}- PID[#{pid}] not found in $active_processes hash - dumping log line for analysis" +
      "\n#{$Parsed_log_line.inspect}\n - dumping $active_processes hash for analysis\n"
    $active_processes.each do |key, element|
      puts "#{key}-> #{element.inspect}"
    end
  end
  end
#end
#end
