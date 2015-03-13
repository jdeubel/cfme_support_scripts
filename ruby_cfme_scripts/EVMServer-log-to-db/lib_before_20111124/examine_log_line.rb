=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: examine_log_line.rb 24591 2010-11-08 15:45:16Z thennessy $
=end
$Startup_yml_text = ""
def examine_log_line(log_line)
#  if /PolicyEngine/  =~ log_line  then
#    puts "#{__FILE__}:#{__LINE__}=>#{log_line}"
#  end
  return if log_lines_to_skip(log_line)
#  if /OS\:\[(.*)\]/ =~ log_line then
#      puts "#{__FILE__}:#{__LINE__}=>#{log_line}"
#  end
#    if /Q-[Tt]ask_id/ =~ log_line && /JOB/ =~ log_line then
#    puts "#{__FILE__}:#{__LINE__}=>#{log_line}"
#  enda
#  if /JobProxyDispatcher-process_job_signal/ =~ log_line then
#    puts "#{__FILE__}:#{__LINE__}"
#  end
#  if /Job created: guid:/ =~ log_line  && /\[60f2391a-c550-11dd-a540-0050569b1ef6\]/ =~ log_line then
#    puts "#{__FILE__}:#{__LINE__}=> #{log_line}"
#  end
#if   /Job created\: guid\:/ =~ log_line then
#    puts "#{__FILE__}:#{__LINE__}=> #{log_line}"
#end
#  if /scan-remove_queued_snapshot_delete/ =~ log_line then
#    puts "#{__FILE__}:#{__LINE__}->#{log_line}"
#  end
if /Q-[Tt]ask_id\(\[\]\) / =~ log_line then
#  puts "#{__FILE__}:#{__LINE__}- #{log_line}"
  log_line = $PREMATCH + $POSTMATCH
     x = Parsed_log_line.new(log_line)
end
  case log_line
#  when /\<AutomationEngine\>/ then  return      # skip
  when /\<AuditSuccess\>/  then    return      # skip
  when /\<PolicyEngine\>/  then  return         # skip
  when /log_ar_stats/ then
          capture_db_statistics($Parsed_log_line.payload)
      return
  when /\-\- \: \<VIM>\ /
#    puts "#{__FILE__}:#{__LINE__}-> VIM ERROR =>'#{log_line}'"
    recurse_log_line = $PREMATCH + "-- : " + $POSTMATCH
#   x = Parsed_log_line.new(log_line)
    examine_log_line(recurse_log_line)
    return
  when /Q-[Tt]ask_id\(\[(.{2,36})\]\)\s*MIQ\(MiqQueue\./ # =~ log_line then
    # tch 2008-12-17
    # with new message formatting many of the old messages are now preceeded
    # with the preamble string "Q-[tt}ask_id({job_guid])" so this is the
    # first attempt to remove these from the msg processing log lines
    # and allow the old processing of msg lines to continue
    # this uses a recursive call to the same routine.
    #
    recurse_log_line = $PREMATCH + "MIQ(MiqQueue." + $POSTMATCH
#   x = Parsed_log_line.new(log_line)
    examine_log_line(recurse_log_line)
    return
#  when /Q-[Tt]ask_id\(\[(.*)\]?\)\s*JOB/ =~ log_line then
#    #TCH 2008-12-20 ADDED similar catch for q-task_id...JOB...
#    recurse_log_line = $PREMATCH + "JOB" + $POSTMATCH
#    examine_log_line(recurse_log_line)
#    return
   when /Q-[Tt]ask_id\(\[(.*)\]?\)\s*JOB\(\[/ # =~ log_line && /JOB/ =~ log_line then
    #TCH 2008-12-20 ADDED similar catch for q-task_id...JOB...
    recurse_log_line = $PREMATCH + "JOB([" + $POSTMATCH
#   x = Parsed_log_line.new(log_line)
    examine_log_line(recurse_log_line)
    return

   when /Q-[Tt]ask_id\(\[(.*)\]?\)\s*Job/ # =~ log_line && /JOB/ =~ log_line then
    #TCH 2008-12-20 ADDED similar catch for q-task_id...JOB...
    recurse_log_line = $PREMATCH + "Job" + $POSTMATCH
#   x = Parsed_log_line.new(log_line)
    examine_log_line(recurse_log_line)
    return

  when /Q-[Tt]ask_id\(\[(.{2,36})\]\)\s*MIQ\(/ # =~ log_line then
    # tch 2008-12-17
    # with new message formatting many of the old messages are now preceeded
    # with the preamble string "Q-[tt}ask_id({job_guid])" so this is the
    # first attempt to remove these from the msg processing log lines
    # and allow the old processing of msg lines to continue
    # this uses a recursive call to the same routine.
    #
    recurse_log_line = $PREMATCH + "MIQ(" + $POSTMATCH    
    
    if !$job_step_togle && log_line =~ $Q_task_id_with_jobuuid  then                                                # if job step record not already written
#    if !$job_step_togle && /Q\-task_id\(\[([a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12})\)\]/ =~ log_line then
#    if !$job_step_togle && /Q\-task_id\(\[([-a-f0-9]{36,36})\)\]/ =~ log_line then
#      if !$job_step_togle && /Q\-task_id\9\[(.*)\]\)/
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
      $job_step_togle = true

    end

#   x = Parsed_log_line.new(log_line)
    examine_log_line(recurse_log_line)
    return

#  when $Q_task_id_with_jobuuid then
#    if !$job_step_togle then                                                # if job step record not already written
#      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
#      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
#      $job_step_togle = true
#    end


  end
   x = Parsed_log_line.new(log_line)       #  remove unnecessary objecect creation since it
#    x = $Parsed_log_line                    #  use the already created global object value instead
  # lines below is for debugging specific situation and can be ignored
  if /JOB\(/ =~ log_line && /MIQ\(/ =~ log_line && /ERROR/ =~ log_line then 
    #    puts ""
  end
  #  if /Job / =~ log_line then   # for debugging to catch new job loglines that are special
  #    puts ""
  #  end

  if / started\. / =~ x.payload then
    capture_process_startup(x)
    return
  end

  if /MIQ\(config\) Database Adapter\: \[(.*?)\], version\:/ =~ log_line ||
      /MIQ\(MiqServer.start\) Invoking startup method for MiqDatabase/ =~ log_line ||
      /MIQ\(MiqLicense\-atStartup\) Validating license\.\.\./ =~ log_line then
    $EVMServerPid = x.log_pid\
  end

if $EVMServerPid == nil || $EVMServerPid == x.log_pid then
    case log_line

    when /\* EVM License \*/ then $License_scan_active = true       #indicate that license info collection is active
    when /\* EVM License END/ then $License_scan_active = nil      #indicate that license info collection is terminated
    end
    if $VMDB_scan_active then
      $Startup_yml_text << $Parsed_log_line.payload
      capture_evm_startup_config(log_line)
    end
    # **********************
      if $License_scan_active then                                # tch 2009-01-06 added to skip processing of license info
        return                                                    # until I can integrate it into the main log analyzer process
      end                                                         # expect to remove shortly
    # **********************

    #  if /\* \[VMDB\] started on\s*\[(.*)\]\s*\*/ =~ log_line then
      if $La_3 =~ log_line then #
    #    recognize_evm_startup()
    ##    $startup_cnt += 1
    ##    $Startups[$startup_cnt] = {"count" => $startup_cnt, "log_time" => x.log_datetime,
    ##      "display_time" => $1,
    ##      "role" => nil,"zone" => nil, "host" => nil, "hostname" => nil,
    ##      "company" => nil, "db username" => nil, "db mode" => nil,
    ##      "db adapter" => nil, "db database" => nil, "db dsn" => nil,
    ##      "db max_connections" => nil,
    ##    }
        $Startups[$startup_cnt]["display_time"] = $1        # get display time even though not completely in sync with log_time
        $Startups[$startup_cnt]["status"] = "startup"
    #    $active_job_cnt = 0
    #    #    puts "#{__FILE__}:#{__LINE__}"
        $VMDB_scan_active = true
        $startup_config = File.new($diag_dir + "\\" + "startup_config_#{$startup_cnt}","w")
        capture_evm_startup_config(log_line)
      end
    #  if /VMDB settings END/ =~ log_line then             #if end of VMDB then disable special recognition
      if $La_4 =~ log_line then             #if end of VMDB then disable special recognition
        _temp_startup = $Startups[$startup_cnt]

        $VMDB_scan_active = nil
        capture_evm_startup_config(log_line)            # make call so that csv file is created
        $active_processes[x.log_pid]["GUID"] = $Server_GUID if $active_processes[x.log_pid]["GUID"]== nil
        $active_processes[x.log_pid]["host"] = _temp_startup["host"] if $active_processes[x.log_pid]["host"] == nil
        $startup_config.close if $startup_config
        $startup_config = nil

      end
    #  if /DATABASE settings\:/ =~ log_line then
      if $La_5 =~ log_line then
        $DATABASE_scan_active = true
      end
    #  if /DATABASE settings END/ =~ log_line then
       if $La_6 =~ log_line then
        $DATABASE_scan_active = nil
    #    puts "#{$Startups[$startup_cnt].inspect}"
        if $generatedb then
        _hash_holder = $Startups[$startup_cnt]
            evmserver_startup = EvmStartups.find($Startups[$startup_cnt]["evmserver_table_startup_id"])
        #{"count" => $startup_cnt, "log_time" => $Parsed_log_line.log_datetime,
        #      "display_time" => nil, "server_guid" => nil,
        #      "role" => nil,"zone" => nil, "host" => nil, "hostname" => nil,
        #      "company" => nil, "db username" => nil, "db mode" => nil,
        #      "db adapter" => nil, "db database" => nil, "db dsn" => nil,
        #      "db max_connections" => nil, "evmserver_table_startup_id" => nil,
        #    }
        #    puts "#{evmserver_startup.inspect}"
          evmserver_startup.evm_startup_first_seen_seconds = $Startups[$startup_cnt]["log_time"]
          evmserver_startup.evm_server_guid = $Startups[$startup_cnt]["server_guid"]
          evmserver_startup.evm_startup_database  = $Startups[$startup_cnt]["db database"]
          evmserver_startup.evm_startup_db_adapter = $Startups[$startup_cnt]["db adapter"]
          evmserver_startup.evm_startup_fixpack = $Startups[$startup_cnt]["evm version"]
          evmserver_startup.evm_startup_evm_base = $Startups[$startup_cnt]["build"]
          evmserver_startup.evm_startup_rails_level = $Startups[$startup_cnt]["rails version"]
          evmserver_startup.evm_startup_host = $Startups[$startup_cnt]["host"]
          evmserver_startup.evm_startup_database_host = $Startups[$startup_cnt]["db host"]
          evmserver_startup.evm_startup_build = $Startups[$startup_cnt]["build"]
          evmserver_startup.evm_startup_company = $Startups[$startup_cnt]["company"]
          evmserver_startup.evm_startup_appliance_name = $Startups[$startup_cnt]["appliance name"]
          evmserver_startup.evm_startup_db_username = $Startups[$startup_cnt]["db username"]
          evmserver_startup.save
        end
       end
      if $VMDB_scan_active                                 # if VMDB config log lines, then determine subsections
        case x.payload
    #    when /^\s*:server:\s*$/ then $VMDB_scan_active = "server"
        when $La_7 then $VMDB_scan_active = "server"
        when /^\*\:queue\:\s*$/ then $VMDB_scan_active = "queue"
        when /^\*\:webservices\:\s*$/ then $VMDB_scan_active = "webservices"
        when /^\*\:log\:\s*$/ then $VMDB_scan_active = "log"
        when /^\*\:performance\:\s*$/ then $VMDB_scan_active = "performance"
        when /^\*\:workers\:\s*$/ then $VMDB_scan_active = "workers"
        when /^\*\:authentication\:\s*$/ then $VMDB_scan_active = "authentication"
        when /^\*\:repository_scanning\:\s*$/ then $VMDB_scan_active = "repository_scanning"
        when /^\*\:product\:\s*$/ then $VMDB_scan_active = "product"
        when /^\*\:ems_refresh\:\s*$/ then $VMDB_scan_active = "ems_refresh"
        when /^\*\:smtp\:\s*$/ then $VMDB_scan_active = "smtp"
        when /^\*\:coresident_miqproxy\:\s*$/ then $VMDB_scan_active = "coresident_miqproxy"
        when /^\*\:log_depot\:\s*$/ then $VMDB_scan_active = "log_depot"
        when /^\*\:session\:\s*$/ then $VMDB_scan_active = "session"
        when /^\*\:reporting\:\s*$/ then $VMDB_scan_active = "reporting"
        end
    #    end
        case $VMDB_scan_active
        when /server/ then
          case x.payload
            when /\:hostname\:\s*(.*)/ then
              $active_processes[x.log_pid]["hostname"] = $1 if $active_processes[x.log_pid]["hostname"] == nil ||  $active_processes[x.log_pid]["hostname"] == "uninitialized"
            when /\:name\:\s*(.*)/ then
              $active_processes[x.log_pid]["name"] = $1 if $active_processes[x.log_pid]["name"] == nil ||  $active_processes[x.log_pid]["name"] == "uninitialized"
            when /\:company\:\s*(.*)/ then
              $active_processes[x.log_pid]["company"] = $1 if $active_processes[x.log_pid]["company"] == nil ||  $active_processes[x.log_pid]["company"] == "uninitialized"

          end
        end
      end
    #  if /MIQ\(config\) Database Adapter\:/ =~ log_line then
      if $La_8 =~ log_line ||
      /MIQ\(MiqServer.start\) Invoking startup method for MiqDatabase/ =~ log_line ||
      /MIQ\(EvmApplication\.start\) EVM Startup initiated/ =~ log_line   then
        recognize_evm_startup()
        $active_job_cnt = 0
        $Startups[$startup_cnt]["display_time"] = x.log_raw_datetime
        $Startups[$startup_cnt]["log_time"] = x.log_datetime
      end
      #capture build information for appliance when found

    #  if /information ran for|OS\:\[/ =~ log_line then
    ##    puts "#{__FILE__}:#{__LINE__} - #{log_line}"
    #      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
    #      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
    #  end

      case x.payload.split[0]
    #  when /Version:/ then
      when $La_9 then
        _version = x.payload.split[1]
        $Startups[$startup_cnt]["evm version"] = _version
    #  when /RAILS/ then
      when $La_10 then
        $Startups[$startup_cnt]["rails environment"] = x.payload.split[2]
        $Startups[$startup_cnt]["rails version"] = x.payload.split[4]
    #  when /Build:/ then
      when $La_11 then
        $Log_build_id = x.payload.split[1]      # capture build number
        $Startups[$startup_cnt]["build"] = $Log_build_id
    #  when /:role:/ then
      when $La_12 then
    #    if /:role:\s*(.*)/ =~ x.payload then
        if $La_13 =~ x.payload then
          $Startups[$startup_cnt]["role"] = $1
        end
    #  when /:zone:/ then
      when $La_14 then
        if /\:zone\:/ =~ x.payload then
#        $Startups[$startup_cnt]["zone"] = x.payload.split[1]
         _x = $POSTMATCH
         $Startups[$startup_cnt]["zone"] = _x.strip.to_s
        end
    #  when /:host:/ then
      when $La_15 then
    #    case $VMDB_scan_active
         $Startups[$startup_cnt]["host"] = x.payload.split[1]if $VMDB_scan_active == "server" &&  $Startups[$startup_cnt]["host"] == "uninitialized"
         # if the field is still uninitialized, then take on this value, otherwise don't
         $Startups[$startup_cnt]["database host"] = x.payload.split[1] if $DATABASE_scan_active
    #    end
    #    case $DATABASE_scan_active
    ##    end
    #    end
    #  when /:hostname:/ then
      when $La_16 then
        $Startups[$startup_cnt]["hostname"] = x.payload.split[1]if $VMDB_scan_active == "server" &&  $Startups[$startup_cnt]["hostname"] == "uninitialized"
        $Startups[$startup_cnt]["host"] = $Startups[$startup_cnt]["hostname"]
        # if the field is still uninitialized, then take on this value, otherwise don't
    #  when /:name:/ then
    #  when $La_17 then
    #    $Startups[$startup_cnt]["appliance name"] = x.payload.split[1]if $VMDB_scan_active == "server" && $Startups[$startup_cnt]["appliance name"] == "uninitialized"
    #  when /:company:/ then
      when $La_18 then
    #    if /:company:\s*(.*)/ =~ x.payload then
        if $La_19 =~ x.payload then
          $Startups[$startup_cnt]["company"] = $1 if $VMDB_scan_active == "server"
        end
    #  when /:username:/ then
      when $La_20 then
        $Startups[$startup_cnt]["db username"] = x.payload.split[1]
    #  when/:mode:/ then
      when $La_21 then
        $Startups[$startup_cnt]["db mode"] = x.payload.split[1]
    #  when /:adapter:/ then
      when $La_22 then
        $Startups[$startup_cnt]["db adapter"] = x.payload.split[1]
    #  when /:database:/ then
      when $La_23
        $Startups[$startup_cnt]["db database"] = x.payload.split[1]
    #  when /:dsn:/ then
      when $La_24 then
    #    if /:dsn:\s*(.*)/ =~ x.payload then
        if $La_25 =~ x.payload then
          $Startups[$startup_cnt]["db dsn"] = $1
        end

    #  when /:max_connections:/ then
      when $La_26 then
        $Startups[$startup_cnt]["db max_connections"] = x.payload.split[1]
      end

end
  case log_line
  when /VM snapshot created/ then
#    puts "#{__FILE__}:#{__LINE__} - #{log_line}"
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
  when /information ran for/ then
#    puts "#{__FILE__}:#{__LINE__} - #{log_line}"
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
  when /OS\:\[/ then
#    puts "#{__FILE__}:#{__LINE__} - #{log_line}"
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
  when /FileSystem\:/
#[----] I, [2009-06-09T13:05:24.597402 #7794]  INFO -- : Q-task_id([3858bc1a-54f5-11de-9653-005056ac3083])
#FileSystem: 1656574692-16128, Mounted on: D:, Type: NTFS, Free bytes: 14424592384
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
  when /Command \[(.*?)\]\s*completed/ then
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
  when /call_snapshot_delete\: Enter/ then                                    #capture snapshot delete start
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
  when /snapshot_delete\, message\:/ then                                      # capture snapshot_delete message
      if /TRACE/ =~ $Parsed_log_line.payload then
        $Parsed_log_line.splice_payload($PREMATCH,$POSTMATCH )
      end
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil
  when /VdlConnection\.getDisk\:/ then
#[----] I, [2009-06-24T15:36:44.286065 #28075]  INFO -- : 
#Q-task_id([d29bdd5e-60d3-11de-91fa-005056ac7674]) VdlConnection.getDisk: 30.5.160.50 open disks = 1     
      __payload = JOB_payload.new($Parsed_log_line.payload)                   # then create one
      jobstep_csv_write(__payload,$Parsed_log_line) if __payload.job_uuid != nil    
  when /scan-remove_queued_snapshot_delete/ then
#[----] I, [2010-03-31T04:27:34.994374 #3524]  INFO -- :
#Q-task_id([78f47e1a-3c7d-11df-8c4e-0050569138a3])
#JOB([78f47e1a-3c7d-11df-8c4e-0050569138a3] vm_scan_context) scan-remove_queued_snapshot_delete:
#Removing queued item with Message id: [757], Method name: [remove_snapshot_by_description], Task id: [78f47e1a-3c7d-11df-8c4e-0050569138a3]
    handle_remove_snapshot_by_description(log_line)

  end





  #  if x.payload.split[0] == "Build:" then
  #  $Log_build_id = x.payload.split[1]      # capture build number
  #  $Startups[$startup_cnt]["build"] = $Log_build_id
  #
  #  end
  #  puts "#{x.payload}"
  # examine the first word of payload to simplify text string examinations
  _payload_word_array = x.payload.split
   
  case _payload_word_array[0]

#  when /^\[\S*\]/ then
  when $La_27 then
#    if /\[RuntimeError\]/ =~ x.payload then
    if $La_28 then
#      puts "#{__FILE__}:#{__LINE__}-> payload is '#{x.payload}'"
    end
    # process =>"[####] message delivered ..... " payloads
    # may be replaced by "Q-Task_id" form
#    if /\[(\S*)\]?\s+message\s+\[(\d*)\]?\s+delivered\s*(.*)$/ =~ x.payload then
     if /\[(\S*)\]?\s+message\s+\[(\d*)\]?\s+delivered\s*(.*)$/ =~ x.payload then
      _tmp_msg_id = $2.to_s
      _tmp_status = $3
      if _tmp_msg_id.class == "NilClass" || 
          $MiqQueue[_tmp_msg_id].class == "NilClass" || 
          $MiqQueue[_tmp_msg_id] == nil ||
          $MiqQueue.empty? then
        puts "******** #{File.basename(__FILE__)}:#{__LINE__} msgid #{_tmp_msg_id} == NilClass\n\t logline=>'#{log_line}'"
        #      end
      else
        $MiqQueue[_tmp_msg_id].msg_delivery_complete_status = _tmp_status
        $MiqQueue[_tmp_msg_id].deliver_complete_time = x.log_datetime
        if _tmp_status == "ERROR" && !$MiqDeliver_error.empty? then
          # this error message is being handled by the same process that
          # created the error that is pending in the $MiqDeliver_error hash
          # so use the log_line pid as the index into the  hash, grab the error
          # and then delete the hash entry just harvested.
          if $MiqDeliver_error.has_key?(x.log_pid) then
            $MiqQueue[_tmp_msg_id].error_text = $MiqDeliver_error[x.log_pid]
            $MiqDeliver_error.delete(x.log_pid)
            $MiqQueue[_tmp_msg_id].deliver_complete_time = x.log_datetime
            # manufacture a duration value since this is not processed and represents
            # the delay to recognize the error
            $MiqQueue[_tmp_msg_id].msg_process_duration = $MiqQueue[_tmp_msg_id].deliver_complete_time - $MiqQueue[_tmp_msg_id].ready_time          
          end
          if $MiqQueue[_tmp_msg_id].msg_process_duration == nil then
            $MiqQueue[_tmp_msg_id].msg_process_duration = $MiqQueue[_tmp_msg_id].deliver_complete_time - $MiqQueue[_tmp_msg_id].save_time
          end

        end
        if $MiqQueue[_tmp_msg_id].create_time != nil && $MiqQueue[_tmp_msg_id].deliver_begin_time != nil then
          $MiqQueue[_tmp_msg_id].msg_queued_time = $MiqQueue[_tmp_msg_id].deliver_begin_time - $MiqQueue[_tmp_msg_id].create_time
        else $MiqQueue[_tmp_msg_id].msg_queued_time = "undefined"
        end
      end
     end
    #  when /MIQ\(JobProxyDispatcher-dispatch\)/ then  # wait for job[uuid} to capture smartproxy name into $Job_csv
#  when /^Job/ then
  when $La_30
    # "Job" begins a new jobid create routine
    # as well as a delete uuid request
    _payload = JOB_payload.new(x.payload)
    # If this is the job create then we must capture this event as the first job step
    #      $Jobsteps_csv.puts "#{_payload.job_uuid},#{x.log_datetime},#{x.log_type},#{x.log_pid},#{_payload}"
    jobstep_csv_write(_payload,x)
##    if _payload.job_uuid.split.size > 1 then
##      puts "#{__FILE__}:#{__LINE__}=> uuid more than one word #{x.payload}"
##    end
#    if _payload.job_uuid.split.size > 1 then
#      puts "#{__FILE__}:#{__LINE__}=> uuid has more than one word #{_payload.inspect}"
#    end
    if $Job_cmds.has_key?(_payload.job_uuid) != true  || $Job_cmds.empty? || $Job_cmds[_payload.job_uuid].empty? then
      # if not then add it to hash
#            if _payload.job_uuid == "2f5847b6-c738-11dd-9d30-0050569b1ef6"
#              then puts ""
#            end
      $Job_cmds[_payload.job_uuid] = {"count" => 1, "create" => nil , "job_cmd" => _payload.job_cmd,
        "ready"=>nil, "finished" => nil, "job_dequeued" => nil, "started" => nil, "error" => nil, "err_msg"=> nil,
        "job_description" => _payload.job_description, "job_process_type" => _payload.job_process_type,
        "created_job_count" => JOB_payload.increment_created, "deleted" => nil, "startup_cnt" => $startup_cnt,
        "active_at_start" => nil, "active_at_end" => nil,"sync_start" => nil, "sync_end"=> nil,
      "snapshot_create"=>nil, "snapshot_complete"=> nil, "scan_start" => nil, "scan_complete" => nil,
      "sync_start"=> nil, "sync_complete"=> nil}
    else
    end      
#      if /Job deleted/ =~ x.payload then
      if $La_31 =~ x.payload then
        _work_hash = $Job_cmds[_payload.job_uuid]
        _work_hash["deleted"] = x.log_datetime
        _work_hash["last heard from"] = x.log_datetime
        _work_hash["startup_cnt"] = "?" if _work_hash["startup_cnt"] == nil  # need to provide a non empty value
        if _work_hash["job_cmd"] == nil || /probable|vm_scan_context/ =~ _work_hash["job_cmd"]   then
          _work_hash["job_cmd"] = "job deleted:" + _payload.job_description + "(#{_payload.job_target_class}=#{_payload.job_target_id})"
        end
        _work_hash["job_process_type"] = _payload.job_process_type if _work_hash["job_process_type"] == nil
        $Job_cmds[_payload.job_uuid] = _work_hash
#        $Job_cmds[_payload.job_uuid]["deleted"] = x.log_datetime
#        if $Job_cmds[_payload.job_uuid]["job_cmd"] == nil || /probable/ =~ $Job_cmds[_payload.job_uuid]["job_cmd"]  then
#          $Job_cmds[_payload.job_uuid]["job_cmd"]= _payload.job_action + ":" + _payload.job_description + "(" +
#            _payload.job_target_class + "=" + _payload.job_target_id + ")"
#          $Job_cmds[_payload.job_uuid]["err_msg"] = "no prior job create recognized"
#          end
#        end

#      elsif
#        puts "******** #{File.basename(__FILE__)}:#{__LINE__}\n\t#{log_line}\n\tduplicate guid found for taskid #{_payload.job_uuid}\n\t from 'examine_log_line.rb'\n********* "
      end

#  when /^JOB/ then
  when $La_32 then
#    if /\[Synchronize\]/ =~ x.payload then
#    puts "#{__FILE__}:#{__LINE__}=> #{x.payload}"
#    end
    # "JOB" begins information about jobid processing and transitions
    _payload = JOB_payload.new(x.payload)
    # may need to move this
    # capture this job step info
    #      $Jobsteps_csv.puts "#{_payload.job_uuid},#{x.log_datetime},#{x.log_type},#{x.log_pid},#{_payload}"
    jobstep_csv_write(_payload,x)
    #check to see if this uuid is already in hash
#    if /JOB_payload/ !~ _payload.class.to_s  then
    if $La_33 !~ _payload.class.to_s then
      puts "#{__FILE__}:#{__LINE__}=>  _payload is  not of expected ""Job_payload"" class type -> #{log_line}"
    end
#    end
#    if _payload.job_uuid.to_s.split.size > 1 then
#      puts "#{__FILE__}:#{__LINE__}=> uuid has more than one word #{_payload.inspect}"
#    end
    if $Job_cmds.has_key?(_payload.job_uuid) != true  || $Job_cmds.empty? || $Job_cmds[_payload.job_uuid].empty? then
      # if not then add it to hash  
      $Job_cmds[_payload.job_uuid] = {"count" => 1, "create" => nil ,
        "job_cmd" => _payload.job_cmd,
        "ready"=>nil, "finished" => nil, "job_dequeued" => nil, "started" => nil,
        "error" => nil, "err_msg"=> nil,
        "created_job_count" => JOB_payload.increment_created , "startup_cnt" => $startup_cnt       }
      #        puts "New taskid is '#{_payload.job_uuid}"
      #        $Job_cmds[_payload.job_uuid].each {|_x,_y| puts "key is '#{_x}' value is #{_y}"}

    else
      #        puts "Existing taskid is '#{_payload.job_uuid}"
      #        $Job_cmds[_payload.job_uuid].each {|_x,_y| puts "key is '#{_x}' value is #{_y}"}
      _work_hash = $Job_cmds[_payload.job_uuid] #unless $Job_cmds[_payload.job_uuid].empty?
      if _work_hash.empty? then    #[_payload.job_uuid]
        puts "Job Cmd for taskid #{_payload.job_uuid} has no value!!!"
      end
      #        _work_hash.each {|_x,_y| puts "key is '#{_x}' value is #{_y}"}
      _work_hash["job_cmd"] = _payload.job_cmd.split[0] if _payload.job_cmd != nil && _work_hash["job_cmd"] == nil
      _work_hash["count"] = _work_hash["count"].to_i + 1
      if _payload.job_modifiers_cnt != nil && _payload.job_modifiers_cnt != 0
        case _payload.job_modifiers[0]
#        when /dispatch_start\:/ then
        when $La_34 then
          _work_hash["ready"] = x.log_datetime
          _work_hash["last heard from"] = x.log_datetime
#        when /dispatch_finish\:/ then
        when $La_35 then
          _work_hash["finished"] = x.log_datetime
          _work_hash["last heard from"] = x.log_datetime
#        when /job aborting/ then
        when $La_36 then
          _work_hash["error"] = x.log_datetime
          _work_hash["err_msg"] = _payload.job_modifiers[1]
          _work_hash["abended_job_count"] = JOB_payload.increment_abended
          _work_hash["last heard from"] = x.log_datetime
#          if _work_hash["started"] == nil then
#            puts "#{__FILE__}:#{__LINE__}\n\tLOGICAL ERROR\n\t for guid(#{_payload.job_uuid})\n\t Job Abort log line for job that never started\n\t#{log_line}"
#          end
          if _work_hash["active_at_end"] == nil then      # if not already update, then update now
            $active_job_cnt -=  1  if _work_hash["active_at_start"] != nil               # decrement the active Jobs count
            _work_hash["active_at_end"] = $active_job_cnt
          end
#        when /: Saving/ then
        when $La_37 then
          _work_hash["create"] = x.log_datetime if _work_hash["create"] == nil
          _work_hash["last heard from"] = x.log_datetime
#        when /: start/  then
        when $La_38 then
          _work_hash["ready"] = x.log_datetime if _work_hash["ready"] == nil
          _work_hash["last heard from"] = x.log_datetime
#        when /\[Scanning\]/
        when $La_39 then
#          if /[Ss]canning completed/ =~ _payload.job_modifiers[1] then
          if $La_40 =~ _payload.job_modifiers[1] then
            _work_hash['scanning completed'] = x.log_datetime
            _work_hash["last heard from"] = x.log_datetime
#           puts "#{__FILE__}:#{__LINE__}=>#{log_line}"
          end
#        when / job finished/ then
        when $La_41 then
          _work_hash["finished"] = x.log_datetime
          _work_hash["completed_job_count"] = JOB_payload.increment_completed if _work_hash["abended_job_count"] == nil &&  _work_hash["completed_job_count"] == nil
          if _work_hash["active_at_end"] == nil then      # if not already update, then update now
                  
            _work_hash["active_at_end"] = $active_job_cnt
            $active_job_cnt -=  1    if _work_hash["active_at_start"] != nil             # decrement the active Jobs count
          end
          _work_hash["last heard from"] = x.log_datetime
#        when / finished$/ then
        when $La_42 then
          _work_hash['job_dequeued'] = x.log_datetime
          _work_hash["last heard from"] = x.log_datetime
#        when /action-process_finish:\s*job/ then
          when $La_43 then
          #              if /Job Created/ !~ _work_hash["job_cmd"]  then
          #                puts "#{__FILE__}:#{__LINE__}=> LIKELY SUSPECT"
          #              end
          _work_hash["ready"] ||= x.log_datetime
          _work_hash["job_vm_name"] ||= _payload.job_description
          _work_hash["job_cmd"] = "probable VM SCAN:" + _payload.job_description + "(" +
            _payload.job_target_class + "=" + _payload.job_target_id + ")"  if _payload.job_process_type == "VmScan"

          _work_hash["job_process_type"] = _payload.job_process_type
          #              _work_hash['job_dequeued'] = x.log_datetime
#        when / Enter$/ then
        when $La_44 then
          case _work_hash["started"]
          when nil then
            _work_hash["started"] = x.log_datetime
            $active_job_cnt +=  1                # increment the active Jobs count
            _work_hash["active_at_start"] = $active_job_cnt
          end
#        when /Agent state update:/ then
        when $La_45 then
          case _payload.job_modifiers[1]
#          when /\[Initializing scan\]/  then
          when $La_46 then
            case _work_hash["started"]
            when nil then
              _work_hash["started"] = x.log_datetime
              $active_job_cnt +=  1                # increment the active Jobs count
              _work_hash["active_at_start"] = $active_job_cnt
            end
          when /\[Synchronization in progress/ then
            _work_hash["sync_start"] = x.log_datetime
          when /\[Synchronization complete/ then
            _work_hash["sync_end"] = x.log_datetime
          end
          #              _work_hash["started"] = x.log_datetime if _work_hash["started"] == nil

          #            else
        end
        # no modifier count was found so lets assume we have
        # and MIQ COMMAND & returned info, lets see if this is an
        # error
#        if /ERROR/ =~ x.log_type_word then
        if $La_47 =~ x.log_type_word then
          # if an error is encountred then capture the first one only, with accompanying text
          _work_hash["error"] = x.log_datetime if _work_hash["error"] == nil
          _work_hash["err_msg"] = _payload.job_modifiers[0] if _work_hash["err_msg"] == nil
          _work_hash["last heard from"] = x.log_datetime
        end
          
        # Now lets see if _work_hash has a  non-nil value
        # and if it does then we need to return it back into the value
        # for the uuid-keyed hash
#    if _payload.job_uuid.split.size > 1 then
#      puts "#{__FILE__}:#{__LINE__}=> uuid has more than one word #{_payload.inspect}"
#    end
        $Job_cmds[_payload.job_uuid] = _work_hash unless _work_hash.empty?
        _work_hash = nil               # ensure that work hash is emptied
        jobstep_csv_write(_payload,x)
        #       _work_hash.clear
      end
    end
    #        $Job_cmds[_payload.job_cmd] = $Job_cmds[_payload.job_cmd].to_i + 1
    #      end
    #    pp x.payload.class
  when /^MIQ/  then
#    when $La_48 then
    # "MIQ" begins data message handling
    # may be replaced by "Q-Task_id" form
    _payload = MIQ_payload.new(x.payload)

    if $Miq_cmds.has_key?(_payload.miq_cmd) == nil || $Miq_cmds.empty? then
      $Miq_cmds[_payload.miq_cmd] = 1
    else
      $Miq_cmds[_payload.miq_cmd] = $Miq_cmds[_payload.miq_cmd].to_i + 1
    end

    case _payload.miq_cmd
### performance optimization
#   put most frequent miq cms first to reduce search time
#   also order log lines to ignore high to improve overall processing
###
#MIQ(Host.perf_capture_queue) Skipping
    when /Schedule\.action_run_report/ then return
    when /Schedule\.after_find/ then return
    when /Schedule\.run/ then return
    when /Schedule\.action_run_report/ then return
    when /MiqReport.queue_report_result/ then return
    when /Schedule.action_vm_scan/ then return
    when /Expression.evaluate/ then return
    when /MiqReport.build_report_result/ then return



    when /Vm\.perf_capture_queue/ then
      return if /Skipping/ =~ _payload.miq_post_cmd                         # elminate processing for unuseful log line
    when /Vm\.perf_collect_metrics$/ then return                                # nothing of interest in this line
#    when /perf_capture$/ then
#        return if /Timings/ !~ _payload.miq_post_cmd #then
#        else
#          return
#        end
    when /\.perf_rollup$/ then
      if /Timings/ =~ _payload.miq_post_cmd then
        capture_rollup_metrics($Parsed_log_line)
        return
      end
    when /Vm\.perf_rollup_to_parent$/ then return
    when /Vm\.perf_capture_queue$/ then return
    when /Vm\.perf_build_query_params$/ then return
    when /Vm\.perf_capture$/ then
      if /Timings/ =~ _payload.miq_post_cmd then
         capture_ems_performance_interval_metrics($Parsed_log_line)
         return
      end
      return
      
    when /Vm\.perf_process$/ then
      if /Timings/ =~ _payload.miq_post_cmd then
       capture_ems_performance_interval_metrics($Parsed_log_line)
      end       
      return

    when /BottleneckEvent\-generate_future_events/ then return


    when /(\-|\.)log_db_stats/ then
      capture_db_statistics($Parsed_log_line.payload)
      return
    when /MiqServer(\-|\.)status_update/ then
      case _payload.miq_post_cmd
      when /Process [Ii]nfo/ then
        process_miqserver_status_update(_payload)
        return
#      when /count for state/ then
#        process_miqserver_count_for_state(_payload)
#        return
      end
    when /MiqServer.log_status/ then
      case _payload.miq_post_cmd
      when /Process [Ii]nfo/ then
        process_miqserver_status_update(_payload)
        return

#      when /count for state/ then
#        process_miqserver_count_for_state(_payload)
#        return
      end
    when /MiqServer\.validate_worker/ then

=begin
***** V4 new log lines ************
[----] E, [2011-03-03T04:35:54.690670 #2626:15a72e5ef138] ERROR -- : MIQ(MiqServer.validate_worker)
Worker [MiqPerfProcessorWorker] with ID: [87], PID: [32132], GUID: [b4c67046-4547-11e0-ba51-0050569143b1]
 has not responded in 130.944902 seconds, restarting worker
[----] I, [2011-03-03T04:45:06.838857 #2626:15a72e5ef138]  INFO -- : MIQ(MiqServer.validate_worker)
Worker [MiqScheduleWorker] with ID: [91], PID: [8806], GUID: [d4e0c770-454f-11e0-ba51-0050569143b1]
 is being requested to exit due to exit file
[----] I, [2011-03-03T05:06:19.728581 #2626:15a72e5ef138]  INFO -- : MIQ(MiqServer.validate_worker)
Worker [MiqEmsRefreshWorker] with ID: [83], PID: [27525], GUID: [28f982f0-4543-11e0-ba51-0050569143b1]
 uptime has reached the interval of 7200 seconds, requesting worker to exit
[----] W, [2011-03-07T04:17:18.122073 #1541:15a9f7148140]  WARN -- : MIQ(MiqServer.validate_worker)
 Worker [MiqReplicationWorker] with ID: [1807], PID: [18320], GUID: [b1f379e0-4871-11e0-b045-00505688000a]
 process memory usage [323821568] exceeded limit [209715200], requesting worker to exit
MIQ(MiqServer.validate_worker)
Worker [MiqSmartProxyWorker] with ID: [41000000000050], PID: [9823], GUID: [d1530614-4c15-11e0-847c-005056917608]
uptime has reached the interval of 7200 seconds, requesting worker to exit
=end
      if /Worker\s*\[(.*?)\]\s*with\s*ID\:\s*\[(\d*)\],\s*PID\:\s*\[(\d*)\],\s*GUID\:\s*\[(.*?)\]\s*(.*)/ =~ _payload.miq_post_cmd then
#                    $1                       $2                   $3                    $4        $5
         _pid = $3
         _guid = $4
         _workertype = $1
         _reason_text = $5
         _reason = nil
         case _reason_text
         when /has reached the interval/ then 
           _reason = "interval limit"
           puts "#{__FILE__}:#{__LINE__}-\n\tpid '#{_pid}' guid '#{_guid}' - reason text '#{_reason_text}"
         when /has not responded in (.*?) seconds/ then _reason = " has not responded in #{$1} seconds"
         when /due to exit file/ then  _reason = "due to exit file"
         when /memory/ then _reason = "memory limit exceeded"
         end
         if _reason && $active_processes.has_key?(_pid) then
           $active_processes[_pid]["requested_exit_reason"] = _reason
         else
           puts "#{__FILE__}:#{__LINE__}-\n\tpid '#{_pid}' guid '#{_guid}' - reason text '#{_reason_text}"
         end
         if $Parsed_log_line.log_type_word != "ERROR" then
            return
         end
      end


    when /MiqServer(\-|\.)log_system_status/ then
      case _payload.miq_post_cmd
#      when /Process [Ii]nfo/ then
#        process_miqserver_status_update(_payload)
#        return
      when /count for state/ then
        process_miqserver_count_for_state(_payload)
        return

      end
#      if /Process [Ii]nfo/ =~ _payload.miq_post_cmd then
##        puts "#{__FILE__}:#{__LINE__}-#{_payload.inspect}"
#        process_miqserver_status_update(_payload)
#      else
#        return if /Process Info/ !~ _payload.miq_post_cmd           # ignore these lines for now
#      end
#    when $La_0 then                # ignore these lines for now#
     
    when /save_vmmetadata/ then return
    when /^EventCatcher/ then
      if /Synchronizing active roles and configuration/ !~ _payload.miq_post_cmd then
        eventcatcher_monitor_handler(_payload.miq_post_cmd)
      end
        return
    when /EventHandler/
    when /proxy-heartbeat/ then 
#[----] I, [2009-04-08T01:08:21.213499 #4499]  INFO -- : 
#MIQ(proxy-heartbeat): hostId:[3]]  Hostname:[cnwdcesxe002.tic.ca.kp.org]  
#SmartProxy time:[2009-04-08T01:08:19Z]  
#Host GUID:[cf4733da-fec0-11dd-99a5-005056807da9]  
#Remote Tasks Count:[0]  Exiting?:[false]       
#      puts "#{__FILE__}:#{__LINE__}- heartbeat"
      _heartbeat_array = _payload.miq_post_cmd.split
      _hostid = nil
      _hostname = nil
      _smartproxy_guid = nil
      _smartproxy_time = nil
      _active_remote_task = nil
      _exiting_smartproxy = nil
      _heartbeat_array.each do |string| 
          case string
          when /hostId\:\[(.*?)\]/ then _hostid = $1
          when /Hostname\:\[(.*?)\]/ then _hostname = $1
          when /time\:\[(.*)\]/ then _smartproxy_time = $1.tr("Z"," ")
            _work_time = _smartproxy_time.split("T")
            __date = _work_time[0].split("-")
            _year = __date[0]
            _month = __date[1]
            _day = __date[2]
            _smartproxy_time = _month + "/" + _day + "/" + _year + " " + _work_time[1].strip
          when /GUID\:\[(.*)\]/ then _smartproxy_guid = $1
          when /Count\:\[(.*)\]/ then _active_remote_task = $1
          when /Exiting\?\:\[(.*)\]/ then _exiting_smartproxy = $1
          end
      end
      _instances = Hash.new
##{$Startups[$startup_cnt]["server_guid"]},\"#{$Startups[$startup_cnt]["hostname"]}\"
      if !$heartbeats.has_key?(_smartproxy_guid) then

          $heartbeats[_smartproxy_guid] = {"hostname" => _hostname, "hostid" => _hostid, "instances" => Array.new}

         _instances[$Parsed_log_line.log_datetime_string] = {"sp_time" =>_smartproxy_time, "exiting" => _exiting_smartproxy, 
        "active_tasks"  => _active_remote_task ,"EVM_appliance_guid" => $Startups[$startup_cnt]["server_guid"],
        "EVM_appliance_hostname" => $Startups[$startup_cnt]["hostname"], "startup" =>$startup_cnt, "EVM appliance name" => $Startups[$startup_cnt]["appliance name"]}
           $heartbeats[_smartproxy_guid]["instances"] << _instances      
      else 
         _instances[$Parsed_log_line.log_datetime_string] = {"sp_time" =>_smartproxy_time, "exiting" => _exiting_smartproxy, 
        "active_tasks"  => _active_remote_task,"EVM_appliance_guid" => $Startups[$startup_cnt]["server_guid"],
        "EVM_appliance_hostname" => $Startups[$startup_cnt]["hostname"], "startup" =>$startup_cnt, "EVM appliance name" => $Startups[$startup_cnt]["appliance name"]          }
           $heartbeats[_smartproxy_guid]["instances"] << _instances
      end
#      end
#      if /hostId:[3]]  Hostname:[cnwdcesxe002.tic.ca.kp.org]  SmartProxy time:[2009-04-08T01:08:19Z]  Host GUID:[cf4733da-fec0-11dd-99a5-005056807da9]  Remote Tasks Count:[0]  Exiting?:[false] / =~ _payload_miq_post_cmd then
#      end
      
      return
    when /host_heartbeat/ then return
#MiqQueue[\.|\-]deliver
    when /MiqQueue\.delivered/  then
      miqqueue_deliver_handler(_payload.miq_post_cmd,x)

    when /MiqQueue\.deliver/ then return

    when /MiqQueue[\.|\-]get/ then
      miqqueue_deliver_handler(_payload.miq_post_cmd,x)

#MiqQueue.put
    when /MiqQueue.put/ then
#    when $La_58 then
      $MiqQueue_new_by_pid[x.log_pid] = Log_msg_info.new(x) if !$MiqQueue_new_by_pid.has_key?(x.log_pid)
      #              if /bytes saved/ =~ _payload.miq_post_cmd then
      #                puts "#{__FILE__}#{__LINE__}=> _pay.load.miq_cmd"
      #              end
      miqqueue_put_handler(_payload.miq_post_cmd,x,$MiqQueue_new_by_pid[x.log_pid])
      if $MiqQueue_new_by_pid[x.log_pid].msg_state == 'ready' then
#                  $Msg[key] = instance
#                  msg_info_to_csv($base_file_name,$Msg)
# logic alteredby tch 2010-10-09
# objective is to only allow messages put-type that we know will be processed by this
# appliance to be allowed into the $MiqQueue hash so that it doesn't grow too large
# method "remove_snapshot_by_description" is one of these.
        if /remove_snapshot_by_description/ =~ $MiqQueue_new_by_pid[x.log_pid].msg_method_name then
          $MiqQueue[$MiqQueue_new_by_pid[x.log_pid].msg_id] = $MiqQueue_new_by_pid[x.log_pid]          
        else
          $Msg[$MiqQueue_new_by_pid[x.log_pid].msg_id] = $MiqQueue_new_by_pid[x.log_pid]                    
          msg_info_to_csv($base_file_name,$Msg)
          $Msg.clear         
        end
        $MiqQueue_new_by_pid.delete(x.log_pid)
      end

#MiqWorker-status_update
#    when /MiqWorkerMonitor|MiqVimBrokerWorker|MiqGenericWorker|MiqScheduleWorker|MiqPriorityWorker|MiqEventCatcher|MiqEventHandler|MiqWorker-status_update/ then
    when /MiqWorker[\.|\-]status_update/ then process_miqworker_status_update(_payload)
    when /MiqServer[\.|\-]status_update/ then process_miqworker_status_update(_payload)
    when /MiqWorker[\.|\-]log_status/ then process_miqworker_status_update(_payload)
#    when $La_62 then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#    when $La_62a then process_miqworker_status_update(_payload)
#[----] I, [2009-01-07T12:51:21.235250 #4738]  INFO -- : MIQ(MiqWorkerMonitor) [EVM Worker Monitor (4696)] Worker guid [1873fc70-dcb9-11dd-8167-0050569b236d],
#Last Heartbeat [Wed Jan 07 12:50:24 UTC 2009],
#Process Info: Memory Usage [72744960], Memory Size [89018368], Memory % [1.8], CPU Time [00:00:09], CPU % [2.6], Priority [30]

# Altered 20090110
#[----] I, [2009-01-10T14:25:59.770255 #4881]  INFO -- : MIQ(MiqWorker-status_update) MiqPriorityWorker:
# [Priority Queue (4869)] Worker guid [d8bd22e4-df21-11dd-8ba9-0050569b77f6], Last Heartbeat [Sat Jan 10 14:25:57 UTC 2009],
# Process Info: Memory Usage [72028160], Memory Size [79831040], Memory % [1.8], CPU Time [00:00:07], CPU % [2.4], Priority [30]
#      if /(.*)\:\s*\[(.*)\((\d{1,5})\)\]\s*(.*)Process Info:\s*(.*)/ =~ _payload.miq_post_cmd  then

#MiqServer
    when /Server\.heartbeat_thread/ then
      if /^Heartbeat / =~ _payload.miq_post_cmd then
        capture_miqserver_heartbeat_duration(_payload)
      end
    when/MiqServer\.shutdown/ then
      $miqserver_termination_msg = "MiqServer shutdown in progress"
#MIQ(MiqServer.shutdown) Stopping all active workers
    when /EvmApplication\.start/ then
      puts "MiqServer startup recognized"
      $miqserver_termination_msg = nil
      #MIQ(EvmApplication.start) EVM Startup initiated
    when /MiqServer/ then 
#[----] I, [2009-10-02T00:35:43.311299 #4948]  INFO -- : MIQ(MiqServer) Heartbeat [Fri Oct 02 00:35:43 UTC 2009]...
#[----] I, [2009-10-02T00:35:43.320102 #4948]  INFO -- : MIQ(MiqServer) Heartbeat [Fri Oct 02 00:35:43 UTC 2009]...Complete
      if /^Heartbeat / =~ _payload.miq_post_cmd then
        capture_miqserver_heartbeat_duration(_payload)
      end
#[----] E, [2009-03-30T23:47:05.714806 #8733] ERROR -- :
#MIQ(MiqServer) MiqWorkerMonitor with PID [8930] GUID [c25968d4-1d40-11de-850a-0050568b4d05]
#Time Threshold [Mon Mar 30 23:45:05 UTC 2009] Last Heartbeat [Mon Mar 30 23:44:22 UTC 2009], restarting worker
       if /(\S*) with PID\s*\[(\d{1,5})\]\s*GUID\s*\[(.{36})\](.*), restarting worker/ =~ _payload.miq_post_cmd then
                                      #capture worker being terminated for missing heartbeat threshold
         _pid = $2
         _guid = $3
         _workertype = $1
#         puts "#{__FILE__}:#{__LINE__}\npid ->#{_pid}\n_guid ->#{_guid}\n _workertype->#{_workertype}\n"
#         puts "$active_processes[_pid]->#{$active_processes[_pid].inspect}"
#         puts "#{$Parsed_log_line.inspect}"
         if $active_processes.has_key?(_pid) then 
         $active_processes[_pid]["requested_exit_reason"] = "heartbeat threshold exceeded"
         else
            puts "#{__FILE__}:#{__LINE__}->process [#{_pid}] with guid[#{_guid}] is being requested to terminate - unusual but not terminal condition\n\t#{$Parsed_log_line.inspect} "
         end
         
       end
      if /(.*)Role\s*\<(.*)\>\s*on\s*Server\s*\<(.*)\>/ =~ _payload.miq_post_cmd then
        puts "#{__FILE__}:#{__LINE__}- changing value of 'appliance name' from #{$Startups[$startup_cnt]["appliance name"]} to #{$3}\n #{log_line}"
#        $Startups[$startup_cnt]["appliance name"] = $3
      end

      if $Parsed_log_line.log_type_word != "ERROR" then
        return
      end    

#EmsFolder-save_ems_inventory
    when /EmsFolder[\.|\-]save_ems_inventory/ then return
#VcRefresher-get_vc_data
    when /VcRefresher[\.|\-]get_vc_data/ then return
#VcRefresher-refresh
    when /VcRefresher[\.|\-]refresh/ then
      capture_vcrefresher_refresh_timings(_payload)
      return
      #Storage-refresh_file_list
     when /Storage[\.|\-]refresh_file_list/ then
        capture_vcrefresher_refresh_timings(_payload)
#     when /EmsRefreshHelper\-save_[storages|vms|hosts]_inventory/ then
#        capture_vcrefresher_refresh_timings(_payload)
#
#    when /EmsRefreshHelper\-save_vms_inventory/ then
#        capture_vcrefresher_refresh_timings(_payload)
#    when /EmsRefreshHelper\-save_hosts_inventory/ then
#        capture_vcrefresher_refresh_timings(_payload)
#    when /EmsRefreshHelper\-save_storages_inventory/ then
#        capture_vcrefresher_refresh_timings(_payload)
#agent_job_state
    when /agent_job_state/ then
      #                if /11e76174-c93d-11dd-8342-000c295a4baa/ =~ _payload.miq_post_cmd then
      #                    puts "#{__FILE__}:#{__LINE__}-> #{_payload.miq_post_cmd.inspect}"
      #                  end
#      puts "#{__FILE__}:#{__LINE__}=>#{_payload.miq_post_cmd}"
      case _payload.miq_post_cmd
      when /jobid:/ then
        if /jobid:\s*\[(.{36})\]\s*(.*)/ =~ _payload.miq_post_cmd then
          _jobid = $1
          _following_info = $2
          # there are multiple "starting" lines issued -catch and record only the first
          if $Job_cmds.has_key?(_jobid) != true && _following_info == "starting" then
            _work_hash = Hash.new

        _work_hash = {"count" => 1, "create" => x.log_datetime, "job_cmd" => nil,
          "ready"=>nil, "finished" => nil, "job_dequeued" => nil, "started" => nil, "error" => nil, "err_msg"=> nil,
          "job_description" => nil, "job_process_type" => nil,
          "created_job_count" => nil ,"startup_cnt" => $startup_cnt,
          "active_at_start" => nil, "active_at_end" => nil            }

            _work_hash["started"] = x.log_datetime
            $active_job_cnt +=  1                # increment the active Jobs count
            _work_hash["active_at_start"] = $active_job_cnt
            _work_hash["ready"] ||= x.log_datetime
            _work_hash["job_vm_name"] ||= "Unknown- "
            _work_hash["job_cmd"] = "probable VM SCAN:"
            _work_hash["job_description"] = "job recognized after create"
            _work_hash["job_process_type"] = "Unknown"
            _work_hash["last heard from"] = x.log_datetime
            $Job_cmds[_jobid] = _work_hash
#          else _work_hash = $Job_cmds[_jobid]
          end
#          _work_hash = Hash.new

#          if _work_hash["started"] == nil then
#            _work_hash["started"] = x.log_datetime
#            $active_job_cnt +=  1                # increment the active Jobs count
#            _work_hash["active_at_start"] = $active_job_cnt
#            $Job_cmds[_jobid] = _work_hash
#            #                _work_hash.empty
#          end

        end
      end
#vm-save_metadata
    when /vm-save_metadata/ then return
#ExtManagementSystem-get_vim_vm_by_path
    when /ExtManagementSystem-get_vim_vm_by_path/ then return
#MiqFaultTolerantVim-_connect  
    when /MiqFaultTolerantVim[\-\.]_connect/     then
#      puts "#{__FILE__}:#{__LINE__}-#{log_line}"
      return
      
#### end high usage miq cmds
###
#MIQ(MiqReplicationWorker.kill) Killing worker: ID [1000000000032], PID [2736], GUID [bc02d4a2-f264-11df-bdcb-005056a6005e], status [not responding]
    when /\.kill/
      if / ID\s*\[(\d*)\]\,\s*PID\s*\[(\d*)\]\,\s*GUID\s*\[(.*?)\]\,/ =~ _payload.miq_post_cmd then
        _worker_id = $1
        _pid = $2
        _guid = $3
        if $active_processes.has_key?(_pid) then
          $active_processes[_pid]['killed'] = $Parsed_log_line.log_datetime_string.split(".")[0]
         else
            puts "$active_process[#{_pid}] not found, may refer to already ended process\n#{$Parsed_log_line.inspect}"
        end
      end
#    when /^WorkerMonitor$/ then                       # isolate MIQ command, not just the prefix
    when $La_49 then
#MIQ(WorkerMonitor) Worker guid [89c05650-ed15-11dd-b3ee-0050569b7ccc] being killed because it is not responding
# changed to
#MIQ(WorkerMonitor) Worker [MiqGenericWorker] with PID [4782] GUID [6c0484f0-07a1-11de-b554-005056800b06] being killed because it is not responding

#      if /GUID\s*\[(.*)\]\s*being killed/ =~ _payload.miq_post_cmd
      if $La_50 =~ _payload.miq_post_cmd then
        _temp_pid_guid = $1
        if $guid_process_xref.has_key?(_temp_pid_guid) then
          _target_pid = $guid_process_xref[_temp_pid_guid]["pid"]
          if $active_processes.has_key?(_target_pid) then
          $active_processes[_target_pid]["killed"] = $Parsed_log_line.log_datetime_string.split(".")[0]      #x.log_datetime
#          if $active_processes[_target_pid]["file_status"] == "open" then
#             $active_processes[_target_pid]["file_status"] = "closed"  # change file status to closed
#            _temp_file = $active_processes[_target_pid]["file_handle"] # get file handle
#            _temp_file.close
#            $active_processes[_target_pid]["file_handle"] = nil
#             $all_process_archive << $active_processes[_target_pid]    #copy hash heap to archive array
#         # now remove the entry from the active_process list
#         $active_processes.delete(_target_pid)
#          end
          else
            puts "$active_process[#{_target_pid}] not found, may refer to already ended process\n#{$Parsed_log_line.inspect}"
          end
        end
      end
#[----] I, [2009-03-18T02:38:34.775038 #4696]  INFO -- :
#MIQ(WorkerMonitor) Worker [MiqGenericWorker] with PID [4723] GUID [d16fc4b2-1354-11de-af90-005056a163d5]
#uptime has reached the interval of 7200 seconds, , requesting worker to exit
#    if /with PID\s*\[(\d*)\].*, requesting worker to exit/ =~ _payload.miq_post_cmd then
    if $La_51 =~ _payload.miq_post_cmd && /MiqQueue/ !~ _payload.miq_cmd then
      capture_process_stop_request($1)
#      puts "#{__FILE__}:#{__LINE__}"
    end
#[----] W, [2009-05-18T12:02:46.465146 #5037]  WARN -- :
#MIQ(WorkerMonitor) System memory usage has exceeded 20% of swap: Total: [2344120320], Used: [472424448]
#[----] W, [2009-05-18T12:02:46.474885 #5037]  WARN -- :
#MIQ(WorkerMonitor) Worker [MiqGenericWorker] with PID [5066] GUID [45d6f770-439e-11de-9d68-0050568026c2] is being stopped because system resources exceeded threshold, it will be restarted once memory has freed up
    if /is being stopped/ =~ _payload.miq_post_cmd && /MiqQueue/ !~ _payload.miq_cmd then
      capture_process_stop_request($1) if /PID\s*\[(\d*)\]/ =~ _payload.miq_post_cmd
    end


#    when /config/ then
    when $La_52 then


#MIQ(MiqServer.set_role_activation) Deactivating Role <reporting> on Server <EVM>
#    when /Server-atStartup/ then
#    when $La_53 then
    when /Server[\.\-]atStartup/ then
      case _payload.miq_post_cmd
      when /Server GUID\:\s*(.*)/ then
        $Server_GUID = $1
#        $Server_zone = nil
#        $Server_role = nil
        $Startups[$startup_cnt]["server_guid"] = $Server_GUID               #Capture Server guid into startup info
#        _work_process = $active_processes[x.log_pid]
#        _work_process["GUID"] = $Server_GUID
#        $active_processes["x."]
        $active_processes[x.log_pid]["GUID"] = $Server_GUID                 # assert appliance GUID as main process guid
        $active_processes[x.log_pid]["server_guid"] = $Server_GUID
        $guid_process_xref[$Server_GUID] = {"pid" => x.log_pid}                # update guid-process xref to point at new pid for Server GUID
#      when /Server Zone\:\s*(.*)/ then
      when $La_54 then
        $Server_zone = $1
#      when /Server Role\:\s*(.*)/ then
      when $La_55 then
        $Server_role = $1
        $active_processes[x.log_pid]["assigned roles"] = $1
      when /Server IP Address\:\s*(.*)/  then
        $Server_ipaddress = $1
      when /Server Hostname\:\s*(.*)/ then
        $Server_hostname = $1
        $Startups[$startup_cnt]["hostname"] = $Server_hostname
      end
        
#    when /Configuration\.create_or_update/ then
    when $La_56 then
       _temp_array = _payload.miq_post_cmd.split(",")
       _temp_array.each do |_x|
#           if /miq_server_id\:\s\[(.*)\]/ =~ _x then
           if $La_57 =~ _x then
            $Server_miq_server_id = $1
           end
          end

#    when /MiqQueue.Deliver/  then
    when $La_59 then
      miqqueue_deliver_handler(_payload.miq_post_cmd,x)
      #      if $MiqQueue
      #        if /deliver/ =~ _payload.miq_cmd then miqqueue_deliver_handler(_payload.miq_post_cmd,x,$MiqQueue_new_by_pid[x.log_pid]) end

#    when /MiqExpression-apply_search_filter/
    when $La_60
#    when /MiqWorker-monitor/
    when $La_61


#MIQ(WorkerMonitor) Worker guid [89c05650-ed15-11dd-b3ee-0050569b7ccc] being killed because it is not responding
    when nil
       if $La_63 =~ _payload.miq_post_cmd then
        _worker_method_name = $1
        _worker_type_text = $2
        _worker_pid = $3
        _worker_part1 = $4
        _worker_part2 = $5
        _worker_stats_hash = Hash.new
          _worker_stats_hash["category"] = nil
          _worker_stats_hash["subcategory"] = nil
          _worker_stats_hash["ip_address"] = nil
          _worker_stats_hash["priority"] = nil        
#        if /Event Monitor/ =~ _worker_type_text then                #log doesn't differentiate well between
        if $La_64 =~ _worker_type_text then
          _worker_stats_hash["worker_type"] = _worker_method_name   # event catcher and handler, so take the type from the method name
          _worker_type_text.split.each do |_worker_type_word|
              case _worker_type_word
#              when /vCenter\:/ then _worker_stats_hash["category"] = "Virtual Center"    # capture vCenter as the category
              when $La_65  then _worker_stats_hash["category"] = "Virtual Center"    # capture vCenter as the category
#              when /\((.*)\)/ then _worker_stats_hash["ip_address"] = $1                  # Capture the ip address of the EMS
              when $La_66 then _worker_stats_hash["ip_address"] = $1                  # Capture the ip address of the EMS
              end
          end
        else                                                        # from the method name
          _worker_stats_hash["worker_type"] = _worker_type_text
        end
          _worker_stats_hash["worker_pid"] = _worker_pid

#          if /[Ee]vent/ =~ _payload.miq_cmd then            # if event is part of the miq cmd
          if $La_67 =~ _payload.miq_cmd then            # if event is part of the miq cmd
                                                            # then is is either a monitor or a handler - catch it
                                                            # and isolate the ip address being monitored too
          _worker_type_text_array = _worker_type_text.split # break into separate words and replace last with event type
          case _payload.miq_cmd
#          when /[Cc]atcher/ then _worker_type_text_array[-1] = "Catcher"
#          when /[Hh]andler/ then _worker_type_text_array[-1] = "Handler"
          when $La_68 then _worker_type_text_array[-1] = "Catcher"
          when $La_69 then _worker_type_text_array[-1] = "Handler"

          end
          _worker_type_text = _worker_type_text_array.join(" ")  # recombine phrase
          _worker_stats_hash["worker_type"] = _worker_type_text  # update the worker type to be catcher or handler type
          _worker_type_text_array.each do |_word|
                case _word
#                when /\((.*)\)/ then _worker_stats_hash["ip_address"] = $1
                when $La_66 then _worker_stats_hash["ip_address"] = $1
#                when /vCenter\:/ then _worker_stats_hash["category"] = "Virtual Center"
                when $La_65 then _worker_stats_hash["category"] = "Virtual Center"
                end
              end
          end
          capture_process_info(_worker_part1,_worker_part2,_worker_stats_hash,x.log_datetime)
#          puts "#{__FILE__}:#{__LINE__}=> _worker_stats_hash is \'#{_worker_stats_hash.inspect}\'"
#        _worker_part1_array = _worker_part1.split(",")
#        _worker_part1_array.each do |_wp1_x|
#          case _wp1_x
#          when /Worker guid \[(.{36})\]/ then _worker_stats_hash["guid"] = $1 #capture guid
#          when /Last Heartbeat\s*\[(.*)\]/ then _worker_stats_hash["last_heartbeat"] = $1 # capture last heartbeat
#          end
#        end
#        _worker_part2_array = _worker_part2.split(",")
#        _worker_part2_array.each do |_wp2_x|
#          case _wp2_x
#          when /usage\:\s*\[(.*)\]/ then
#            _worker_stats_hash["memory_usage"] = $1.strip.to_i #remove leading and trailing spaces
#          when /Usage\s*\[(.*)\]/ then
#            _worker_stats_hash["memory_usage"] = $1.strip.to_i #remove leading and trailing spaces
#          when /Size:\s*\[(.*)\]/ then
#            _worker_stats_hash["memory_size"] = $1.strip.to_i
#          when /Size\s*\[(.*)\]/ then
#            _worker_stats_hash["memory_size"] = $1.strip.to_i
#          when /CPU Time\:\s*\[(.*)\:(.*)\:(.*)\]/ then
#            _worker_stats_hash["cpu_time"] = (((($1.to_i*60)+$2.to_i)*60)+$3.to_i).to_i  #calculate cpu seconds
#          when /CPU Time\s*\[(.*)\:(.*)\:(.*)\]/ then
#            _worker_stats_hash["cpu_time"] = (((($1.to_i*60)+$2.to_i)*60)+$3.to_i).to_i  #calculate cpu seconds
#          when /CPU Pct\:\s*\[(.*)\]/ then
#            _worker_stats_hash["cpu_percent"] = $1
#          when /CPU \%\s*\[(.*)\]/ then
#            _worker_stats_hash["cpu_percent"] = $1
#          when /Memory Pct\:\s*\[(.*)\]/ then
#            _worker_stats_hash["memory_percent"] = $1
#          when /Memory %\s*\[(.*)\]/ then
#            _worker_stats_hash["memory_percent"] = $1
#          when /Priority\s*\[(.*)\]/ then
#            _worker_stats_hash["priority"] = $1
#          end
#        end
       end
#    when /Server-status_update/ then
    when $La_70 then
      #            puts "#{__FILE__}:#{__LINE__}"
      #            puts "#{_payload.inspect}"
#      if /(\[.*\])\s*Process info\:\s*(.*)$/ =~ _payload.miq_post_cmd then
      if $La_71 =~ _payload.miq_post_cmd then
        _worker_stats_hash = Hash.new
        _worker_identifier = $1                         # grab the worker descriptor
        _process_details = $2                   # grab the process statistics
        case _worker_identifier
#        when /\[(.*)\:(.*)\((.*)\) \s*(.*)\((\d*)\)\]/
        when $La_72 then
          # if this is a more complex descriptor, then separate out the elements
          # and capture the ip address if offered
          _worker_stats_hash["category"] = $1          # descriptor category
          _worker_stats_hash["subcategory"] = $2          # descriptor subcategory
          _worker_stats_hash["ip_address"] = $3          # descriptor ip address
          _worker_stats_hash["worker_type"] = $4 # worker type
          _worker_stats_hash["worker_pid"] = $5  # process id
          _worker_stats_hash["priority"] = nil
#        when /\[(.*)\:(.*)\((\d*)\)\]/ then
        when $La_73
          # if this is a more complex descriptor, then separate out the elements
          # if the ip address isn't recognizeable, then work harder to separate out
          # the subcategory from the worker type
          _worker_stats_hash["category"] = $1          # descriptor category
          _worker_stats_hash["subcategory"] = $2          # descriptor subcategory
          _worker_stats_hash["ip_address"] = nil          # descriptor ip address
          _worker_stats_hash["worker_type"] = nil # worker type
          _worker_stats_hash["priority"] = nil
          _worker_stats_hash["worker_pid"] = $3  # process id
#          if / Event / =~_worker_stats_hash["subcategory"] then
          if $La_74 =~_worker_stats_hash["subcategory"] then
            _worker_stats_hash["subcategory"] = $PREMATCH
            _worker_stats_hash["worker_type"] = "Event " + $POSTMATCH.strip
          end
#        when /\[(.*)\((.*)\)\]/ then
        when $La_75 then
          _worker_stats_hash["worker_type"] = $1
          _worker_stats_hash["worker_pid"] = $2
          _worker_stats_hash["category"] = nil
          _worker_stats_hash["subcategory"] = nil
          _worker_stats_hash["ip_address"] = nil
          _worker_stats_hash["priority"] = nil
#        when /\[(.*)\]/ then
        when $La_76 then
          _worker_stats_hash["worker_type"] = $1
          _worker_stats_hash["worker_pid"] = nil
          _worker_stats_hash["category"] = nil
          _worker_stats_hash["subcategory"] = nil
          _worker_stats_hash["ip_address"] = nil
          _worker_stats_hash["priority"] = nil
        end

        _process_details_array = _process_details.split(",")
        _array_cnt = 0
        #                puts "#{_worker_identifier}"
        _process_details_array.each do |xx|
          #                     puts "\t#{_array_cnt} = #{xx}"
          case xx
          when /usage\:\s*\[(.*)\]/ then
            _worker_stats_hash["memory_usage"] = $1.strip.to_i #remove leading and trailing spaces
          when /Usage\s*\[(.*)\]/ then
            _worker_stats_hash["memory_usage"] = $1.strip.to_i #remove leading and trailing spaces
          when /Size:\s*\[(.*)\]/ then
            _worker_stats_hash["memory_size"] = $1.strip.to_i
          when /Size\s*\[(.*)\]/ then
            _worker_stats_hash["memory_size"] = $1.strip.to_i
          when /CPU Time\:\s*\[(.*)\:(.*)\:(.*)\]/ then
            _worker_stats_hash["cpu_time"] = (((($1.to_i*60)+$2.to_i)*60)+$3.to_i).to_i  #calculate cpu seconds
          when /CPU Time\s*\[(.*)\:(.*)\:(.*)\]/ then
            _worker_stats_hash["cpu_time"] = (((($1.to_i*60)+$2.to_i)*60)+$3.to_i).to_i  #calculate cpu seconds
          when /CPU Pct\:\s*\[(.*)\]/ then
            _worker_stats_hash["cpu_percent"] = $1
          when /CPU \%\s*\[(.*)\]/ then
            _worker_stats_hash["cpu_percent"] = $1
          when /Memory Pct\:\s*\[(.*)\]/ then
            _worker_stats_hash["memory_percent"] = $1
          when /Memory %\s*\[(.*)\]/ then
            _worker_stats_hash["memory_percent"] = $1
          when /Priority\s*\[(.*)\]/ then
            _worker_stats_hash["priority"] = $1
          end
          _array_cnt += 1
        end
        #                    puts "***illogical condition USED memory exceeds allocated memory=>#{log_line}" if _worker_stats_hash["memory_usage"] > _worker_stats_hash["memory_size"]
        #              puts "#{__FILE__}:#{__LINE__}=> LOOK FOR PARSED LOG LINE INFO"
        $Process_statistics_csv.puts "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
          "#{$startup_cnt},#{x.log_datetime}," +
          "#{_worker_stats_hash["category"]}," +
          "#{_worker_stats_hash["subcategory"]}," +
          "#{_worker_stats_hash["ip_address"]}," +
          "#{_worker_stats_hash["worker_type"]}," +
          "#{_worker_stats_hash["worker_pid"]}," +
          "#{_worker_stats_hash["memory_usage"]}," +
          "#{_worker_stats_hash["memory_size"]}," +
          "#{_worker_stats_hash["memory_percent"]}," +
          "#{_worker_stats_hash["cpu_time"]}," +
          "#{_worker_stats_hash["cpu_percent"]},"  +
          "#{_worker_stats_hash["priority"]}" if $Process_statistics_csv  # only if processing evm.log file
        _worker_stats_hash.clear
      end
      #def class worker_status_update
      #  def initialize(_payload)
      #    @category = nil
      #    @subcategory = nil
      #    @ip_address = nil
      #    @worker_type = nil
      #    @worker_pid = nil
      #    @memory_usage = nil
      #    @memory_size = nil
      #    @memory_percent = nil
      #    @cpu_seconds = nil
      #    @cpu_percent = nil
      #  end
      #  end
      #end
    when /save_vmmetadata/ then
#    when /proxy-heartbeat/ then
      puts "#{__FILE__}:#{__LINE__}- heartbeat"
      #      puts 
    when /host_heartbeat/ then
#      puts "#{__FILE__}:#{__LINE__}=>host heartbeat"


    when /JobProxyDispatcher-start_job_on_proxy/ then
      if /Job\s*\[(.*)\]\s*update\:\s*(.*)/ =~ _payload.miq_post_cmd then
      _job_uuid = $1
      _signal_value = $2    
      end
#      _work_array = _payload.miq_post_cmd.split(",")
#      _work_array.each do |_x|
#        case _x
#        when /Job\((.*)\)\]/ then _job_uuid = $1
#        when //
#        end

      if $Job_cmds.has_key?(_job_uuid) == true then
        _work_hash = $Job_cmds[_job_uuid]
        _work_hash["started"] = x.log_datetime
        _work_hash["last heard from"] = x.log_datetime
#        case _signal_value
#          when /is waiting to start/ then                    # recognized scan is starting and inject info into work hash
#          _work_hash["ready"] = x.log_datetime
#
#        end
        $Job_cmds[_job_uuid] = _work_hash
      else
#        puts "#{__FILE__}:#{__LINE__}=> Job[#{_job_uuid}] 'ready' or starting but create never recognized"
        # in this section a job that has been created elsewhere is recognized as ready
        # but since it was not created on this appliance we need to generate the instance
        # that represents all of the data we can know about the job

        $Job_cmds[_job_uuid] = {"count" => 1, "create" => nil, "job_cmd" => nil,
          "ready"=> nil, "finished" => nil, "job_dequeued" => nil, "started" => x.log_datetime, "error" => nil, "err_msg"=> nil,
          "job_description" => nil, "job_process_type" => nil,
          "created_job_count" => nil ,"startup_cnt" => $startup_cnt,
          "active_at_start" => nil, "active_at_end" => nil            }
        _work_hash = $Job_cmds[_job_uuid]
        _work_hash["last heard from"] = x.log_datetime
        _signal_value_array = _signal_value.split(",")
        _signal_value_array.each  do |_sg_value|
              case _sg_value
              when /userid\:\s*\[(.*)\]/ then
              when /name\:\s*\[(.*)\]/ then
                _work_hash["job_description"] = $1
                _work_hash["job_cmd"] = "job starting:" + $1
              when /target class\:\s*\[(.*)\]/ then

              when /target id\:\s*\[(.*)\]/ then
                _temp_id = $1
                _work_hash["job_cmd"] = _work_hash["job_cmd"] + "(VM=" + _temp_id + ")"

              when /process type\:\s*\[(.*)\]/ then _work_hash["job_process_type"] = $1
              when /agent class\:\s*\[(.*)\]/ then
              when /agent id\:\s*\[(.*)\]/ then
              end
            end
        $Job_cmds[_job_uuid] = _work_hash
      end        
# ---------------------------------------------------------------------      
    when /proxy-call_ws/ then

      if /Calling\:\s*\[(.*)\]/ =~ _payload.miq_post_cmd then
        _ws_call = $1
        _ws_call_object = eval _ws_call
        case _ws_call_object[:method_name]
        when /ScanMetadata/ then
          __payload = JOB_payload.new($Parsed_log_line.payload)
#          puts "#{__FILE__}:#{__LINE__}-> Scan metadate host=#{_ws_call_object[:host]},hostid=#{_ws_call_object[:hostId]},job guid #{_ws_call_object[:taskid]}"
          jobstep_csv_write(__payload,$Parsed_log_line)
        end
#        puts "#{__FILE__}:#{__LINE__}- proxy-call_ws captured \n\t#{_ws_call_object.inspect}"
      end
#    when /vm-registerVm/
#    when /VmOperationsEvent-handle_policy_event/
#    when /event-raise_policy_event/
#    when /hardware-add_elements/
#    when /VmOperationEvent-handle_event/
#    when /host-scan/
#    when /VimBrokerWorker-monitor/
#    when /EventCatcher-monitor/
#    when /vm-scan_job/
#    when /Server-status_update/
#    when /atStartup/
    when /atShutdown/ then
          $Startups[$startup_cnt]["status"] = "shutdown"
#    when /Schedule-action_vm_scan/
#    when /Schedule-run/
#    when /MiqWorker.start/
#    when /MiqExpression-build_relats/
#    when /agent_config/
#    when /Schedule-before_save/
#    when /report_controller-show/
#    when /MiqWorker.start_worker/
#    when /proxy-validate_config/
#    when /MiqLicense-check_license/
#    when /Schedule-after_find/
#    when /report_controller-show_report/
#    when /MiqWorker.stop/
#    when /MiqReport-atStartup/
#    when /host_controller-update/
#    when /report_controller-new/
#    when /Action-atStartup/
#    when /host-self_register/
#    when /VimBrokerWorker.start_worker/
#    when /host_controller-show/
#    when /VimBrokerWorker.start_worker/
#    when /host_controller-show/
#    when /EventCatcher.start_worker/
#    when /User-atStartup/
#    when /agent-get/
#    when /host-discoverHost/
#    when /ExtManagementSystem-connect/
#    when /config/
#    when /host-add_elements/
    when /JobProxyDispatcher\-dispatch/  then
      capture_jobproxydispatcher_timings(x)
    when /\.perf_(capture|process|rollup)/ then
#      if /perf_process/ =~ _payload.miq_cmd && /Timings/ =~ x.payload then
#        puts "#{__FILE__}:#{__LINE__}"
#      end

      if /Timings/ =~ x.payload then
      capture_ems_performance_interval_metrics(x)
      end
    when /[\.|\-]vim_collect_perf_data/ then
#      case x.payload
#      when /Timings\:/ then capture_ems_performance_realtime_metrics(x)
#      else return
#      end
#      puts "#{__FILE__}:#{__LINE__}"
      
      case x.payload
      when /Timings\:/ then capture_ems_performance_realtime_metrics(x)
      when /Starting/ then
      when /Mapping/ then
      when /Total items/ then
      when /Finished/ then
      when /Processing/ then
      when /endTime/ then
      else
        capture_ems_performance_interval_metrics(x)
      end
#      if /Q-task_id\(\[(.*?)\]\)\s*MIQ\((.*?)\)\s*\[(\S*)\]\s*for\:\s*\[(\S*?)\],\s*\[(\d*)\],\s*\[(.*?)\]\s*Timings\:\s*\{(.*)\}/ =~ $Parsed_log_line.payload then
#        _taskid = $1
#        _miq_cmd = $2
#        _interval = $3
#        _class = $4
#        _element_id = $5
#        _element_name = $6
#        _timing_hash = $7
#        _working_times = _timing_hash.split(",")
#        _hash_of_fragments = Hash.new
#        _working_times.each do |fragment|
#                          _fragment_array = fragment.split("=>")
#                          _hash_of_fragments[_fragment_array[0]] = _fragment_array[1]
#                          end
#
#        end
#        puts "#{__FILE__}:#{__LINE__}- #{_hash_of_fragments.inspect}"
#      end
#    when /VimBrokerWorker.stop/
#    when /EventCatcher.stop/
#    when /Schedule-queue_work/
#    when /abstract_adapter/
#    when /ScheduleWorker/
#    when /EmsRefreshWorker/
#    when /PriorityWorker/
#    when /GenericWorker/
#    when /Config\.initialize/
#    when /SQLServer-initialize/
#    when /VcRefresher.retrieve_from_vc/
#    when /VcRefresher-filter_vc_data/
#    when /VcRefresher\.disconnect_from_ems/
#    when /VcRefresher\.initialize/
#    when /EmsRefreshHelper-vmdb_relats/
#    when /EmsRefreshHelper-save_ems_inventory/
#    when /EmsRefreshHelper-link_ems_inventory/
#    when /EmsRefreshHelper-save_storages_inventory/
#    when /EmsRefreshHelper-save_hosts_inventory/
#    when /EmsRefreshHelper-save_vms_inventory/
#    when /EmsRefreshHelper\-save_inventory/
#    when /event-raise_evm_event/
#    when /MiqEmsRefreshWorker\.start/
    when /VimBrokerWorker$/ then
      if /Queueing refresh/ =~ x.payload then
        capture_queueing_refresh(x.payload)
      end
#    when /MiqVimInventoryParser\-event_to_hash/
#    when /MiqLdap\.get_user_object/
#    when /MiqLdap\.initialize/
#    when /MiqLdap\.bind/
#    when /User-authenticate/
#    when /task\-update_status/
#    when /MiqQueue.m_callback/
#    when /report_controller-edit/
#    when /report_controller-menu_field_changed/
#    when /State-save_state/
#    when /State\-save_doc/
#    when /ExtManagementSystem\-invoke_vim_ws/
#    when /Vm\-classify_with_parent_folder_path/
#    when /Vm\-disconnect_ems/
#    when /Vm\-disconnect_host/
#    when /ExtManagementSystem\-verify_credentials/
#    when /MiqFaultToleraneVim\-_execute/
#    when /Zone\-get_log_depot_settings/
#    when /Zone\-synchronize_logs/
#    when /LogFile\-logs_from_server/
#    when /LogFile\-_request_logs/
#    when /LogFile\-remove_log_file_ftp/
#    when /LogFile\-connect_ftp/
#    when /VMDB\:\:Util\.zip_logs/
#    when /MiqLicense/
#    when /Zone\-queue_ntp_reload/
#    when /Event\-preload_default_definitions/
#    when /alert\-preload/
#    when /Search\-preload_default_searches/
#    when /ProductUpdate\.sync_from_product/
#    when /Group\-preload/
#    when /ChargebackRate\-preload/
#    when /MiqQeDatastore/
#    when /Config\.save/
#    when /MiqWorkerMonitor\.start/
#    when /Server/
#    when /ops_controller\-index/
#    when /ops_controller\-upload_license/
#    when /MiqLicensse\-upload/
#    when /agent\-register/
#    when /host\-call_ws_from_queue/
#    when /Zone\.get_log_depot_settings/
#    when /save_hostmetadata/
#    when /host\-save_metadata/
#    when /MiqSmbSession\-verify/
#    when /MiqSmbSession\-pingable\?/
#    when /MiqSmbSession\-mount_share/
#    when /MiqSmbSession\-relative_to_mount/
#    when /MiqSmbSession\-verify/
#    when /MiqSmbSession\-disconnect/
#    when /MiqSmbSession\-add/
#    when /LogFile\-relative_path_for_uupload/
#    when /Logfile\-build_log_uri/
#    when /host\-create_discovered_ems/
#    when /ExtManagementSystem\-stop_event_monitor/
#    when /ExtManagementSystem\-reseet_vim_cache/
#    when /MiqEventCatcher\-sync_workers/
#    when /MiqEventCatcher\.start/
#    when /MiqAlert\.evaluate_alerts/
#    when /host\-verify_credentials_with_ssh/
#    when /MiqPerfCollectorWorker/
#    when /MiqPerfProcessorWorker/
#    when /MiqSmartProxyWorker/
#    when /MiqSmisRefreshWorker/
#    when /PerfCollectorWorker/
#    when /SmisRefreshWorker/
#    when /PerfProcessorWorker/
#    when /SmartProxyWorker/
#    when /VimPerformance\-purge/
#    when /postgresql\-log_ar_stats/
#    when /Vm\.perf_build_query_params/
#    when /Vm\-save_metadata/
#    when /Vm\.perf_init/
#    when /Host\.perf_build_query_params/
#    when /ExtManagementSystem\.connect/
#    when /Vm\-registerVm/
#    when /Schedule\-refresh_updated_schedules/
#    when /Schedule\-update_schedule/
#    when /Schedule\-unschedule/
#    when /Vm\-scan/
#    when /Vm\-run_miq_cmd/
#    when /DiskProbe\-getDiskMod/
#    when /FsProbe\-getFsMod/
#    when /MiqFaultTolerantVim\-_execute/
#    when /Zone\.get_log_depot_settings/
#    when /MountManagerProbe\-getRootMod/
#    when /Schedule\-action_scan/
#    when /VimPerformanceMetric\-purge/
#    when /Schedule\-action_scan/
#    when /Schedule\-action_check_complianc/
#    when /Host\.scan_from_queue/
#    when /Host\.scan/
#    when /Host\.perf_init/
#    when /schedule\-unschedule/
#    when /Compliance\.check_compliance/
#    when /Compliance\.set_compliancy/
#    when /MiqQueue\.merge/
#    when /VimPerformanceMixin\.avail_metrics_for_entity/
#    when /MiqVimInventoryParser\-host_inv_to_hashes/
#    when /MiqVimInventoryParser\-link_root_folder/
#    when /Host\-disconnect_ems/
#    when /Storage\-scan_timer/
#    when /activate_sql_settings_for_multi_threaded_processes/
#    when /job\-delete_by_id/
#    when /job\-check_jobs_for_timeout/
#    when /ExtManagementSystem\-reset_vim_cache/
#    when /MiqSmbSession\-remove/
#    when /EmsRefreshHelper\-update_relats/
#    when /LogFile\-build_log_uri/
#    when /LogFile\-relative_path_for_upload/
#    when /Vm\.build_query_perf_parms/
#    when /Host\.build_query_perf_parms/
#    when /Job\.check_for_evm_snapshots/
#    when /VimPerformanceMixin\.host2mor/
#    when /VmdbCoreWebserviceOps-reconnect_to_db/
#    when /NTFS\:\:IndexRoot\.find/



#    else
#      puts "#{__FILE__}:#{__LINE__}->unrecognized miq_cmd = #{_payload.miq_cmd}"
    end
    
#    if _payload.miq_cmd == "MiqQueue.deliver" then
#      miqqueue_deliver_handler(_payload.miq_post_cmd,x)
#    end

    
  when /Redirected/  then 
    if /Redirected to\s*(.*)/ =~ x.payload then
      $Rails_transaction["redirected_to"] = $1
      $Rails_transaction["transaction_end_log_time"] = x.log_datetime
    end     
  when /Session/ then 
    if /Session ID:\s*(.*)/ =~ x.payload then
      $Rails_transaction["session_id"] = $1
      $Rails_transaction["transaction_end_log_time"] = x.log_datetime
    end
  when /Completed/ then
    $Rails_transaction["transaction_end_log_time"] = x.log_datetime
    _temp_array = x.payload.split("|")
    _temp_array.each {|fragment|
      case fragment
      when /Completed in\s*(.*)\s*\((.*)?\)/ then
        _resp_time = $1
        _components = $2.split(",")
#        puts "#{log_line}"
#        if /83990ms/ =~ log_line then
#          puts "#{__FILE__}:#{__LINE__}"
#        end
        if /ms/ =~ _resp_time then
          _resp_time = (_resp_time.to_f) / 1000
        end
        _components.each do |_cmp|
                  case _cmp
                  when /View\:\s*(\d*)/ then
                    $Rails_transaction["rendering_time"] = $1.to_f / 1000 # milliseconds to seconds
                  when /DB\:\s*(\d*)/ then
                    $Rails_transaction["dbtime"] = $1.to_f / 1000         # milliseconds to seconds
                  end
              end
        $Rails_transaction["rails_duration"] = _resp_time
      when /Rendering:\s*(.*)\s*\(/ then $Rails_transaction["rendering_time"] = $1.to_f
      when /DB:\s*(.*)\s*\(/ then $Rails_transaction["dbtime"] = $1.to_f
      when /(\d*)\s*(\S*)\s*(\[.*\])/ then
        $Rails_transaction["http_rc"] = $1
        $Rails_transaction["http_text"] = $2
        $Rails_transaction["http_return"] = $3
#        if $Rails_transaction["session_id"] != nil then               #if there is a session id
#          $Rails_transaction['console or web service'] = "console"    # then this is a browser session
          if /\#(.*)_field_changed/ =~ $Rails_transaction["route_to"] then # if this is a console
            $Rails_transaction["console or web service"] = "console-ajax"  # they distinguish ajax transaction
          end                                                         # from non-ajax transactions    
#        else $Rails_transaction["console or web service"] = "web service"
#        end
        #        if /Miqservices\/api/ =~ $Rails_transaction["http_return"] then  # if I find this string then
        #          $Rails_transaction["console or web service"] = "web service"   # then it looks like a heartbeat
        #                                                                         # so call it a webservice
        #        else $Rails_transaction["console or web service"] = "console"    # else call it interactive console
        #        end
      end      
    }
    
  when /Processing/
    if $Rails_transaction.size > 0 && $rails_transaction_cnt > 0 then cleanup_rails() end
    if /Processing\s*(.*)\s*\(for\s*(.*)\s*at\s*(.*)\)\s*\[(\S*)\]/ =~ x.payload then

      $rails_transaction_cnt +=1
      $Rails_transaction["count"] = $rails_transaction_cnt
      $Rails_transaction["route_to"] = $1
      $Rails_transaction["transaction_source"] = $2
      $Rails_transaction["local_time"] = $3
      $Rails_transaction["getpost"] = $4
      $Rails_transaction["log_datetime_string"] = $Parsed_log_line.log_datetime_string.split(".")[0]
      $Rails_transaction["transaction_start_log_time"] = x.log_datetime
      $Rails_transaction["transaction_end_log_time"] = x.log_datetime
      $Rails_transaction["transaction_startup"] = $startup_cnt
#      if $Rails_transaction["route_to"] == "MiqservicesController#api" then
      if /MiqservicesController\#api/ =~ $Rails_transaction["route_to"] then
        $Rails_transaction["console or web service"] = "web service"
      else
      $Rails_transaction["console or web service"] = "console"
      end
 
      #     puts "wo"
      #      puts "#{__FILE__}:#{__LINE__}"
        
    end
    #  when /Q-Task_id\(\[(\S*)\]\)\s*Job created: guid:\s*\[(.*)\],\s*(.*)/ then
    #    Q-Task_id([0c930cc0-6d5b-11dd-9b8c-005056bd15fb]) MIQ(event-raise_policy_event): Event Raised [vm_scan_abort]
    #
    #   Q-Task_id([vc-refresher]) Job created: guid: [19fdf4ba-59e2-11dd-a75a-005056bd5e0e], userid: [system], name: [Scan from Vm Refresh Test 1], target class: [Vm], target id: [130], process type: [VmScan], agent class: [], agent id: []
  when /Q-[Tt]ask_id/ then
    if /start_job_on_proxy/ =~ x.payload then
#      puts "#{__FILE__}:#{__LINE__}"
#      if /d9bc4c64-c5a5-11dd-85f4-0050569b1ef6/ =~ x.payload then
#     puts "#{__FILE__}:#{__LINE__}=>#{x.payload.inspect}"
#      end
    end
     if /Q-[Tt]ask_id\(\[(.*)\]\)/ =~ x.payload then
      _job_uuid = $1
      if _job_uuid != "job_dispatcher" then
          if $Job_cmds.has_key?(_job_uuid) then
            $Job_cmds[_job_uuid]["last heard from"] = x.log_datetime
          end
      if /MIQ\(event-raise_policy_event\)/ =~ x.payload && /vm_scan_complete/ =~ x.payload then 
        if $Job_cmds.has_key?(_job_uuid) then 
          $Job_cmds[_job_uuid]["scan_complete"] = x.log_datetime
#        end
        end
      end          
      end

     end
      #    if /Q-Task_id\(\[(\S*)\]\)\s*MIQ\((\S*)\)\:\s*Event Raised\s*\[(\S*)\]/ =~ x.payload then
    #      _payload = JOB_payload.new(x.payload)
    #    end
    # "Q-Task_id" begins
    if /Q-Task_id\(\[(\S*)\]\)\s*Job created\:\s*guid\:\s*\[(.*)\],\s*(.*)/ =~ x.payload then
      # "Job" begins a new jobid create routine
      _payload = JOB_payload.new(x.payload)
      # If this is the job create then we must capture this event as the first job step
      #      $Jobsteps_csv.puts "#{_payload.job_uuid},#{x.log_datetime},#{x.log_type},#{x.log_pid},#{_payload}"
      
  
      
      jobstep_csv_write(_payload,x)
      if $Job_cmds.has_key?(_payload.job_uuid) != true  || $Job_cmds.empty? || $Job_cmds[_payload.job_uuid].empty? then
        # if not then add it to hash
        $Job_cmds[_payload.job_uuid] = {"count" => 1, "create" => x.log_datetime, "job_cmd" => _payload.job_cmd,
          "ready"=>nil, "finished" => nil, "job_dequeued" => nil, "started" => nil, "error" => nil, "err_msg"=> nil,
          "job_description" => _payload.job_description, "job_process_type" => _payload.job_process_type, 
          "created_job_count" => JOB_payload.increment_created ,"startup_cnt" => $startup_cnt,
          "active_at_start" => nil, "active_at_end" => nil            }
      else
        puts "******** #{File.basename(__FILE__)}:#{__LINE__}\n\tduplicate guid found for taskid #{_payload.job_uuid}\n\t from 'examine_log_line.rb'\n********* "
      end      
    end
    
    #[----] I, [2008-08-21T23:53:09.952126 #8292]  INFO -- : Q-Task_id([vc-refresher]) MIQ(ExtManagementSystem-connect) EMS: [North] [Broker] Connecting with ipaddress: [10.233.71.130], userid: [svc_miq]...
    #[----] I, [2008-08-21T23:53:10.324699 #8292]  INFO -- : Q-Task_id([vc-refresher]) MIQ(ExtManagementSystem-connect) EMS: [North] [Broker] Connecting to EMS: [North]...Complete
    #[----] I, [2008-08-21T23:53:30.158031 #8292]  INFO -- : Q-Task_id([vc-refresher]) MIQ(VcRefresher-disconnect_from_ems) Disconnecting from EMS: [North]...
    #[----] I, [2008-08-21T23:53:30.160364 #8292]  INFO -- : Q-Task_id([vc-refresher]) MIQ(VcRefresher-disconnect_from_ems) Disconnecting from EMS: [North]...Complete
    #if /Q-Task_id/ =~ x.payload && /Connecting/ =~ x.payload then
    #  puts "#{__FILE__}:#{__LINE__}"
    #end
    if /Q-Task_id\(\[vc-refresher\]\)\s*MIQ\(ExtManagementSystem-connect\)\s*EMS:\s*\[(.*)\]\s*\[Broker\]\s*Connecting\s*(.*)$/ =~ x.payload then
      _ems_name = $1
      _remainder_string = $2
      if /ipaddress:\s*\[(.*)\],\s*userid:\s*\[(.*)\]/ =~ _remainder_string then
        _ip_address = $1
        _userid = $2
        puts "EMS name=>#{_ems_name}, IP Address=>#{$1}, PID=>#{x.log_pid}, log date time=>#{x.log_datetime}"
      end
      if /EMS:\s*\[(.*)\](.*)Complete$/ =~ _remainder_string then
        _ems_name2 = $1
        
        puts "EMS name2 =>#{_ems_name2}, connection complete at #{x.log_datetime}, for pid = #{x.log_pid}"
        
      end
      
    end
    if /Q-Task_id\(\[vc-refresher\]\)\s*MIQ\(VcRefresher-disconnect_from_ems\)\s*Disconnecting from EMS:\s*\[(\S*)\](.*)$/ =~ x.payload then
      
    end    
    if /Q-[Tt]ask_id\(\[job_dispatcher\]\) MIQ\(JobProxyDispatcher-process_job_signal\)\s*Enter\s*job\s*\[(.*)\], signal=\[(.*)\]/  =~x.payload then
#[----] I, [2008-12-13T17:30:43.749282 #4524]  INFO -- : Q-task_id([job_dispatcher]) MIQ(JobProxyDispatcher-process_job_signal) Enter job [c5021134-c93b-11dd-8028-000c295a4baa], signal=[dispatch_start]
      _job_uuid = $1
      _signal_value = $2
      if $Job_cmds.has_key?(_job_uuid) == true then
        _work_hash = $Job_cmds[_job_uuid]
        case _signal_value
        when /dispatch_start/ then                    # recognized scan is starting and inject info into work hash
          _work_hash["ready"] = x.log_datetime
#            $active_job_cnt +=  1                # increment the active Jobs count
#            _work_hash["active_at_start"] = $active_job_cnt
        end
        $Job_cmds[_job_uuid] = _work_hash
      end

    end
    if /Q-task_id\(\[job_dispatcher\]\) MIQ\(JobProxyDispatcher-process_start\)\s*Job\s*\[(.*)\]\s*(.*)/ =~ x.payload then
#[----] I, [2008-12-13T17:30:43.749172 #4524]  INFO -- : Q-task_id([job_dispatcher]) MIQ(JobProxyDispatcher-process_start) Job [c5021134-c93b-11dd-8028-000c295a4baa] is waiting to start
      _job_uuid = $1
      _signal_value = $2
      if $Job_cmds.has_key?(_job_uuid) == true then
        _work_hash = $Job_cmds[_job_uuid]
        case _signal_value
          when /is waiting to start/ then                    # recognized scan is starting and inject info into work hash
          _work_hash["ready"] = x.log_datetime

        end
        $Job_cmds[_job_uuid] = _work_hash
      else
#'[----] I, [2009-01-30T14:07:42.814438 #25938]  INFO -- : Q-task_id([job_dispatcher]) MIQ(JobProxyDispatcher-process_start) Job [fda03e46-eecd-11dd-9317-005056803d91] is waiting to start'

#        puts  "#{__FILE__}:#{__LINE__}=> Job[#{_job_uuid}] 'ready' but create never recognized -> '#{log_line}'"

        $Job_cmds[_job_uuid] = {"count" => 1, "create" => nil, "job_cmd" => nil,
          "ready"=> x.log_datetime, "finished" => nil, "job_dequeued" => nil, "started" => nil, "error" => nil, "err_msg"=> nil,
          "job_description" => nil, "job_process_type" => nil,
          "created_job_count" => nil ,"startup_cnt" => nil ,
          "active_at_start" => nil, "active_at_end" => nil            }
#        _work_hash = $Job_cmds[_job_uuid]
#        _signal_value_array = _signal_value.split(",")
#        _signal_value_array.each  do |_sg_value|
#              case _sg_value
#              when /userid\:\s*\[(.*)\]/ then
#              when /name\:\s*\[(.*)\]/ then
#                _work_hash["job_description"] = $1
#                _work_hash["job_cmd"] = "job starting:" + $1
#              when /target class\:\s*\[(.*)\]/ then
#
#              when /target id\:\s*\[(.*)\]/ then
#                _temp_id = $1
#                _work_hash["job_cmd"] = _work_hash["job_cmd"] + "(VM=" + _temp_id + ")"
#
#              when /process type\:\s*\[(.*)\]/ then _work_hash["job_process_type"] = $1
#              when /agent class\:\s*\[(.*)\]/ then
#              when /agent id\:\s*\[(.*)\]/ then
#              end
#            end
#        $Job_cmds[_job_uuid] = _work_hash


      end
    end
#[----] I, [2008-12-13T17:30:43.851084 #4524]  INFO -- : Q-task_id([job_dispatcher]) MIQ(JobProxyDispatcher-dispatch) STARTING job: Scan from Vm nightly-11486 on proxy: dev012.manageiq.com
    if /Q-[Tt]ask_id\(\[job_dispatcher\]\)\s*MIQ\(JobProxyDispatcher-process_start\)\s*[Jj][Oo][Bb]\s*\((.*)\)\s*(.*)/ =~ x.payload then
      _job_uuid = $1
      _signal_value = $2
      if $Job_cmds.has_key?(_job_uuid) == true then
        _work_hash = $Job_cmds[_job_uuid]
        _work_hash["last heard from"] = x.log_datetime
#        _work_hash["started"] = x.log_datetime
        case _signal_value
          when /is waiting to start/ then                    # recognized scan is starting and inject info into work hash
          _work_hash["ready"] = x.log_datetime
           
        end
        $Job_cmds[_job_uuid] = _work_hash
      else puts "#{__FILE__}:#{__LINE__}=> Job[#{_job_uuid}] 'ready' but create never recognized-> '#{log_line}'"
      end
    end
#[----] I, [2008-12-13T17:30:43.858573 #4524]  INFO -- : Q-task_id([job_dispatcher]) MIQ(JobProxyDispatcher-start_job_on_proxy) Job [c5021134-c93b-11dd-8028-000c295a4baa] update: userid: [admin], name: [Scan from Vm nightly-11486], target class: [Vm], target id: [11], process type: [VmScan], agent class: [Host], agent id: [3]
    if /Q-[Tt]ask_id\(\[job_dispatcher\]\)\s*MIQ\(JobProxyDispatcher-start_job_on_proxy\)\s*[Jj][Oo][Bb]\s*\[(.*?)\]\s*(.*)/ =~ x.payload then
      _job_uuid = $1
      _signal_value = $2
      if $Job_cmds.has_key?(_job_uuid) == true then
        _work_hash = $Job_cmds[_job_uuid]
        _work_hash["started"] = x.log_datetime
#        case _signal_value
#          when /is waiting to start/ then                    # recognized scan is starting and inject info into work hash
#          _work_hash["ready"] = x.log_datetime
#
#        end
        $Job_cmds[_job_uuid] = _work_hash
      else
#        puts "#{__FILE__}:#{__LINE__}=> Job[#{_job_uuid}] 'ready' or starting but create never recognized"
        # in this section a job that has been created elsewhere is recognized as ready
        # but since it was not created on this appliance we need to generate the instance
        # that represents all of the data we can know about the job

        $Job_cmds[_job_uuid] = {"count" => 1, "create" => nil, "job_cmd" => nil,
          "ready"=> nil, "finished" => nil, "job_dequeued" => nil, "started" => x.log_datetime, "error" => nil, "err_msg"=> nil,
          "job_description" => nil, "job_process_type" => nil,
          "created_job_count" => nil ,"startup_cnt" => $startup_cnt,
          "active_at_start" => nil, "active_at_end" => nil            }
        _work_hash = $Job_cmds[_job_uuid]
        _work_hash["last heard from"] = x.log_datetime
        _signal_value_array = _signal_value.split(",")
        _signal_value_array.each  do |_sg_value|
              case _sg_value
              when /userid\:\s*\[(.*)\]/ then
              when /name\:\s*\[(.*)\]/ then
                _work_hash["job_description"] = $1
                _work_hash["job_cmd"] = "job starting:" + $1
              when /target class\:\s*\[(.*)\]/ then

              when /target id\:\s*\[(.*)\]/ then
                _temp_id = $1
                _work_hash["job_cmd"] = _work_hash["job_cmd"] + "(VM=" + _temp_id + ")"

              when /process type\:\s*\[(.*)\]/ then _work_hash["job_process_type"] = $1
              when /agent class\:\s*\[(.*)\]/ then
              when /agent id\:\s*\[(.*)\]/ then
              end
            end
        $Job_cmds[_job_uuid] = _work_hash
      end
    end
    
    
    if /Q-[Tt]ask_id\(\[.*\]\)\s*JOB\(\[(.*{36})\]\s*(\S*)\)\s*(.*)$/ =~ x.payload then
      _job_uuid = $1
      _remainder = $3
      _job_cmd = $2
      if $Job_cmds.has_key?(_job_uuid) == true then
        _work_hash = $Job_cmds[_job_uuid]
        case _remainder
        when /action-abort:/ then
          _work_hash["error"] = x.log_datetime
          _work_hash["count"] = _work_hash["count"].to_i + 1
          _work_hash["abended_job_count"] = JOB_payload.increment_abended if _work_hash["abended_job_count"] ==  nil
          _work_hash["last heard from"] = x.log_datetime
          if /action-abort:\s*(.*)\s*name:\s\[(.*)\]\,\s*guid:/ =~ _remainder then
            _work_hash["err_msg"] = '"'+ $1+ '"'
          end
          if /action-abort:\s*(.*)/ =~ _remainder then
            _work_hash["err_msg"] = '"'+ $1+ '"' if _work_hash["err_msg"] == nil
          end
          if _work_hash["active_at_end"] == nil then      # if not already update, then update now
            _work_hash["active_at_end"] = $active_job_cnt if _work_hash["active_at_start"] != nil
            $active_job_cnt -=  1   if _work_hash["active_at_start"] != nil              # decrement the active Jobs count
              
          end
          $Job_cmds[_job_uuid] = _work_hash
        when /action-finished:\s*(.*)/ then
          _save_string = $1
          if /SmartProxy/ =~ _save_string then
            puts "#{File.basename(__FILE__)}:#{__LINE__}=> #{_save_string}"
          end
          _work_hash["finished"]= x.log_datetime
          _work_hash["completed_job_count"] = JOB_payload.increment_completed if _work_hash["abended_job_count"] == nil &&  _work_hash["completed_job_count"] == nil
          _work_hash["err_msg"] = '"'+ _save_string + '"' if _work_hash["err_msg"] == nil
          _work_hash["last heard from"] = x.log_datetime
          _work_hash["count"] = _work_hash["count"].to_i + 1
          if _work_hash["active_at_end"] == nil then      # if not already update, then update now
            _work_hash["active_at_end"] = $active_job_cnt  if _work_hash["active_at_start"] != nil
            $active_job_cnt -=  1   if _work_hash["active_at_start"] != nil              # decrement the active Jobs count
              
          end
          $Job_cmds[_job_uuid] = _work_hash
        end
      end
    end
    
    #    pp _payload.class
  else 
    #    if x.payload.class != "String" then
    #       pp "#{x.payload.class}"
    #       pp x.payload
    #    end
  end
  
  #  puts "#{x.inspect}"
  #  pp "#{x.inspect}"
  #  pp "#{x}"
  #  pp "#{x.log_datetime.to_f}"
  #  examine_payload(x.payload)
end
def cleanup_rails
  if $rails_transaction_cnt < 2 then
    puts "cleanup_rails called"
    $Rails_transactions_csv = File.new($diag_dir + '\\' + "Rails_Transactions_" + "production" + ".csv","w")
    $Rails_transactions_csv.puts("server guid,server host,startup,transaction count,transaction source," +
        "console or web service,local time,start log time,transaction duration," +
        "calculated duration,rendering time,db time, route to, log start time," +
        "log end time, session id, redirected to, http rc, http text, return url")
  end
  x = $Rails_transaction
  if x["transaction_end_log_time"] == nil || x["transaction_start_log_time"] == nil then
    puts "#{__FILE__}:#{__LINE__}\n transaction_end_log_time = #{x["transaction_end_log_time"]}\n transaction_start_log_time = #{x["transaction_start_log_time"]}"
  end
  $Rails_transactions_csv.puts "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
    "#{x["transaction_startup"]}," +
    "#{x["count"]}," +
    "#{x["transaction_source"]}," +
    "#{x["console or web service"]}," +
    "#{x["local_time"]}," +
    "#{x["log_datetime_string"]}," +
    "#{x["rails_duration"]}," +
    "#{x["transaction_end_log_time"] - x["transaction_start_log_time"]}," +
    "#{x["rendering_time"]}," +
    "#{x["dbtime"]}," +
    "#{x["route_to"]}," +
    "#{x["transaction_start_log_time"]}," +
    "#{x["transaction_end_log_time"]}," +
    "#{x["session_id"]}," +
    "#{x["redirected_to"]}," +
    "#{x["http_rc"]}," +
    "#{x["http_text"]}," +
    "#{x["http_return"]},"

  $Rails_transaction.clear               #empty out all key-value pairs
  #       $Rails_transaction["route_to"] = $1
  #     $Rails_transaction["transaction_source"] = $2
  #     $Rails_transaction["local_time"] = $3
  #     $Rails_transaction["getpost"] = $4
  #     $Rails_transaction["transaction_start_log_time"] = x.log_datetime
  #     $Rails_transaction["transaction_end_log_time"] = x.log_datetime
  #
  #     $Rails_transaction["session_id"]
  #     $Rails_transaction["redirected_to"]
  #     $Rails_transaction["http_rc"] = $1
  #     $Rails_transaction["http_text"] = $2
  #     $Rails_transaction["http_return"] = $3
  #       $Rails_transaction["rails_duration"] = $1.strip.to_f
  #       $Rails_transaction["rendering_time"] = $1.to_f
  #       $Rails_transaction["dbtime"] = $1.to_f
end
#end
def capture_process_info(part1,part2,_worker_stats_hash,log_datetime)
#[----] I, [2009-01-10T19:34:55.439254 #11979]  INFO -- : MIQ(MiqWorker-status_update)
#MiqEventCatcher: [vCenter: Virtual Center (192.168.252.6) Event Monitor (12090)] Worker guid [97c8fb6a-df4d-11dd-ac8a-0050569b77f6], Last Heartbeat [Sat Jan 10 19:33:59 UTC 2009],
#Process Info:
#Memory Usage [119869440], Memory Size [136212480], Memory % [3.0], CPU Time [00:00:12], CPU % [27.9], Priority [30]
#[----] I, [2009-01-10T19:34:55.443509 #11979]  INFO -- : MIQ(MiqWorker-status_update)
#MiqEventHandler: [vCenter: Virtual Center (192.168.252.6) Event Monitor (12093)] Worker guid [97d526e2-df4d-11dd-ac8a-0050569b77f6], Last Heartbeat [Sat Jan 10 19:33:59 UTC 2009],
#Process Info:
#Memory Usage [96968704], Memory Size [113229824], Memory % [2.4], CPU Time [00:00:08], CPU % [18.0], Priority [30]
#            puts "#{__FILE__}:#{__LINE__}->#{$Parsed_log_line.inspect}"
  _worker_part1_array = part1.split(",")
  _worker_part2_array = part2.split(",")
  _array_cnt = 0
         _worker_part1_array.each do |_wp1_x|
          case _wp1_x
          when /(MiqEventHandler|MiqEventCatcher)\:/ then

              if /(.*)\:\s*\[(.*)\:\s*(.*)\s*\((.*)\)\s*Event Monitor\s*\((\d{1,6})\)\]\s*Worker guid \[(.{36})\]/ =~ _wp1_x then
                _worker_stats_hash["worker_type"] = $1
                _worker_stats_hash["category"] = $2
                _worker_stats_hash["ip_address"] = $4
                _worker_stats_hash["worker_pid"] = $5
                _worker_stats_hash["guid"] = $6
              end
#            end
          when /EVM Server \((.*)\)/ then
            _worker_stats_hash["worker_pid"] = $1
            _worker_stats_hash["worker_type"] = "EVMServer!"
            _worker_stats_hash["ip_address"] = nil
            _worker_stats_hash["guid"] = nil
            _worker_stats_hash["category"] = nil
            _worker_stats_hash["last_heartbeat"] = nil
          when /Worker guid \[(.{36})\]/ then _worker_stats_hash["guid"] = $1 #capture guid
          when /Last Heartbeat\s*\[(.*)\]/ then _worker_stats_hash["last_heartbeat"] = $1 # capture last heartbeat
          end
        end

  # Capture server info
  # "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["host"]},"
#       _worker_stats_hash["server_guid"] = $Startups[$startup_cnt]["server_guid"]
#       _worker_stats_hash["server_hostname"] = $Startups[$startup_cnt]["host"]
#        _worker_part2_array = _worker_part2.split(",")
        _worker_part2_array.each do |_wp2_x|
          case _wp2_x
          when /usage\:\s*\[(.*)\]/ then
            _worker_stats_hash["memory_usage"] = $1.strip.to_i #remove leading and trailing spaces
          when /Usage\s*\[(.*)\]/ then
            _worker_stats_hash["memory_usage"] = $1.strip.to_i #remove leading and trailing spaces
          when /Size:\s*\[(.*)\]/ then
            _worker_stats_hash["memory_size"] = $1.strip.to_i
          when /Size\s*\[(.*)\]/ then
            _worker_stats_hash["memory_size"] = $1.strip.to_i
          when /CPU Time\:\s*\[(.*)\:(.*)\:(.*)\]/ then
            _worker_stats_hash["cpu_time"] = (((($1.to_i*60)+$2.to_i)*60)+$3.to_i).to_i  #calculate cpu seconds
          when /CPU Time\s*\[(.*)\:(.*)\:(.*)\]/ then
            _worker_stats_hash["cpu_time"] = (((($1.to_i*60)+$2.to_i)*60)+$3.to_i).to_i  #calculate cpu seconds
          when /CPU Pct\:\s*\[(.*)\]/ then
            _worker_stats_hash["cpu_percent"] = $1
          when /CPU \%\s*\[(.*)\]/ then
            _worker_stats_hash["cpu_percent"] = $1
          when /Memory Pct\:\s*\[(.*)\]/ then
            _worker_stats_hash["memory_percent"] = $1
          when /Memory %\s*\[(.*)\]/ then
            _worker_stats_hash["memory_percent"] = $1
          when /Priority\s*\[(.*)\]/ then
            _worker_stats_hash["priority"] = $1
          end
          _array_cnt += 1
        end
        if $active_processes.has_key?(_worker_stats_hash["worker_pid"]) then
          if $active_processes[_worker_stats_hash["worker_pid"]]["memory size"]== nil ||
             $active_processes[_worker_stats_hash["worker_pid"]]["memory size"] < _worker_stats_hash["memory_size"] then
            $active_processes[_worker_stats_hash["worker_pid"]]["memory size"] = _worker_stats_hash["memory_size"]
          end
          if  _worker_stats_hash["worker_type"] != nil &&
              $active_processes[_worker_stats_hash["worker_pid"]]["process type"] != _worker_stats_hash["worker_type"] then
              $active_processes[_worker_stats_hash["worker_pid"]]["process type"] = _worker_stats_hash["worker_type"]
              $active_processes[_worker_stats_hash["worker_pid"]]["worker type"]= _worker_stats_hash["worker_type"]
          end
        else
          puts "process statistics log line for pid not in $active_processes hash: process entry being created" # \n'#{_worker_stats_hash.inspect}'"
     $active_processes[_worker_stats_hash["worker_pid"]] = {"PID" => _worker_stats_hash["worker_pid"] ,
       "first seen" => $Parsed_log_line.log_datetime_string.split(".")[0] ,"first seen seconds" => $Parsed_log_line.log_datetime,
       "last heard from" => $Parsed_log_line.log_datetime_string.split(".")[0] , "last heard from seconds" => $Parsed_log_line.log_datetime,
       "process type" => _worker_stats_hash["worker_type"], "worker type" => _worker_stats_hash["worker_type"],
       "GUID" => _worker_stats_hash["guid"], "started" => nil, "lines" => 0, "build id" => nil, "log id" => nil, "lines after exit" => 0,
       "error_cnt" => 0, "warn_cnt" => 0, "fatal_cnt" => 0, "debug_cnt" => 0, "startup count" => $startup_cnt,
       "requested_exit" => nil, "detected_exit" => nil, "killed" => nil, "requested_exit_reason" => nil,
       "file_status" => "closed", "file_handle" => nil,
#       "server_guid" => "uninitialized", "server_hostname" => "uninitialized",
       "server_guid" => $Startups[$startup_cnt]["server_guid"], "server_hostname" => $Startups[$startup_cnt]["host"],
     }
       _new_pid_file = nil
     _new_pid_file = File.new($pid_dir + "\\" +
         "Active_process_#{_worker_stats_hash["worker_pid"].to_s.rjust(5,"0")}_#{$startup_cnt}_#{$pid_cycle}_" +
         $base_file_name + ".log","w") if $create_pid_files
     # keep one file name for EVM and another for PRODUCTION until merged
#     line_group_in.each do |x|
#       puts._new_pid_file(x)
#     end
     if $base_file_name == "production" then
       puts "#{__FILE__}:#{__LINE__}"
     end
     $active_processes[_worker_stats_hash["worker_pid"]]["file_handle"] =  _new_pid_file
     $active_processes[_worker_stats_hash["worker_pid"]]["file_status"] =  "open" if $create_pid_files
###
#### following code was added only to track the count of open files and isn't needed for correct operation
###
     __open_files = 0
       pp $Parsed_log_line
       puts "part1 = #{part1}"
       puts "part2 = #{part2}\nlog_datetime = #{log_datetime}"
     $active_processes.each do |_element1, _element2 |          #_element1 is key, _element2 is hash value(hash itself)
       puts "#{__FILE__}:#{__LINE__} "
       puts "_worker_stats_hash = "
       pp _worker_stats_hash
       pp _worker_stats_hash["worker_pid"]       
#       pp _tt
       pp "#{_element1},#{_element2}"
#       _element1 = _tt[0]  # this has the pid
#       _element2 = _tt[1]  # this has the rest of the hash
#      if _tt[_worker_stats_hash["worker_pid"]]["file_status"] && _tt[_worker_stats_hash["worker_pid"]]["file_status"] == "open" then
      if _element2["file_status"]  && _element2["file_status"] == "open" then
        __open_files += 1
      end
    end
    puts "current open file count is #{__open_files}" if __open_files > 0
###
### end of file open tracking code
###


        end
#        puts "#{__FILE__}:#{__LINE__}-> #{_worker_stats_hash.inspect}"
        $Process_statistics_csv.puts "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
          "#{$startup_cnt},#{log_datetime}," +
          "#{_worker_stats_hash["category"]}," +
          "#{_worker_stats_hash["subcategory"]}," +
          "#{_worker_stats_hash["ip_address"]}," +
          "#{_worker_stats_hash["worker_type"]}," +
          "#{_worker_stats_hash["worker_pid"]}," +
          "#{_worker_stats_hash["memory_usage"]}," +
          "#{_worker_stats_hash["memory_size"]}," +
          "#{_worker_stats_hash["memory_percent"]}," +
          "#{_worker_stats_hash["cpu_time"]}," +
          "#{_worker_stats_hash["cpu_percent"]},"  +
          "#{_worker_stats_hash["priority"]}" if $Process_statistics_csv  # only if processing evm.log file
        _worker_stats_hash.clear
end
def capture_process_startup(parsed_log_line)
#  puts "#{__FILE__}:#{__LINE__}->#{parsed_log_line.inspect}"
  $active_processes[parsed_log_line.log_pid]["worker type"] = parsed_log_line.payload.split[0] if $active_processes[parsed_log_line.log_pid]["worker type"] == nil
  $active_processes[parsed_log_line.log_pid]["process type"] = parsed_log_line.payload.split[0] if$active_processes[parsed_log_line.log_pid]["process type"] == nil
  $active_processes[parsed_log_line.log_pid]["server_guid"] = $Startups[$startup_cnt]["server_guid"]
  $active_processes[parsed_log_line.log_pid]["server_hostname"] = $Startups[$startup_cnt]["hostname"]

#  if /\[2470\]/ then
#    puts "#{__FILE__}:#{__LINE__}-"
#  end
  _temp_array = parsed_log_line.payload.split(", ")
  _temp_array.each do |segment|
    case segment
    when /GUID\s*\[(.*?)\]/ then
      $active_processes[parsed_log_line.log_pid]["GUID"] = $1
      $guid_process_xref[$1] = {"pid" => parsed_log_line.log_pid}
    when /PID\s*\[(.*?)\]/ then
      $active_processes[parsed_log_line.log_pid]["PID"] = $1
    when /Zone\s*\[(.*)\]/ then
      $active_processes[parsed_log_line.log_pid]["zone"] = $1

    when /Role \s*\[(.*)\]/ then
      $active_processes[parsed_log_line.log_pid]["role"] = $1
    end
#  puts "#{__FILE__}:#{__LINE__}->#{$active_processes[parsed_log_line.log_pid].inspect}"

  end
end