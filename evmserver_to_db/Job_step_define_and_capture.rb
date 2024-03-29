# 
=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: Job_step_define_and_capture.rb 23993 2010-10-05 02:28:18Z thennessy $
=end
# $Jobsteps_csv = File.new("Job_steps_" + base_file_name + ".csv","w")
# $Jobsteps_csv.puts "jobid, time of day, log msg type,log pid, job action,action message, jobstep type"
# $Jobsteps_csv.puts "#{_payload.job_uuid},#{x.log_datetime},#{x.log_type},#{x.log_pid},#{_payload}"
#
#class Job_Step
#  @job_guid = nil
#  @jobstep_datetime = nil
#  @jobstep_msg_type = nil
#  @jobstep_payload_type1 = nil
#  @jobstep_payload_type2 = nil
#  @jobstep_pid_id = nil
#  @jobstep_action_type = nil
#  @jobstep_message = nil
#  
#  attr_accessor :job_guid, :jobstep_datetime, :jobstep_msg_type, :jobstep_payload_type1, :jobstep_payload_type2, :jobstep_pid_id
#  attr_accessor :jobstep_action_type, :jobstep_message
#  def initialize(job_instance,log_instance)
#    # two parms are passed into the initialize function 
#    # a log line instance already parsed and initialized
#    # and a job_instance
#    # from these a job_step instance is constructed
#    # from which job_step lines are written
#    
#  end
# 
#end
def transform_job_action(instring)
         return_string = instring
          if instring!= nil && instring.to_s.size > 5 then       # only check if job_action is not null
             case instring
             when /reference\: \[Snapshot for scan job\:/ then
               return_string = $PREMATCH + "reference: [Snapshot for scan job:"
             when /^Scanning / then
               _work = instring.split
               _work[2] = sprintf("%.1f",_work[2])
               return_string = _work.join(" ")
             when /VM Snapshot/ then
               _work = instring.split
               _work[2] = sprintf("%.1f",_work[2])
               return_string = _work.join(" ")
             when /Command (syncmetadata|scanmetadata) completed/ then
               _work = instring.split
               _work[3] = sprintf("%.1f",_work[3])
               return_string = _work.join(" ")
             when /Loading (Linux|Windows) VM IN/ then
               _work = instring.split
               _work[4] = sprintf("%.1f",_work[4])
               return_string = _work.join(" ")
             else
               return_string = instring
             end
          else return_string = instring
         end
#           puts "#{__FILE__}:#{__LINE__}=> '#{instring}' returns '#{return_string}'"
        return return_string
end
def transform_parsed_log_instance_payload(instring)
        # purpose of following case statement is to reduce the number of unique payload values so that these lines
        # can better be handled as a common string in the sqldb into which the job step records are condensed
        # following the case statements is a set of if statements to catch those instances where more than
        # one set of conditions might be satisfied in the case search and to catch and correct those which
        # have slipped thru
        return_string = instring
#        if /communicates with/ =~ instring then
#          puts "#{__FILE__}:#{__LINE__}- #{instring}"
#        end
         case return_string
         when /Q-task_id\(\[(.*?)\]\) MIQ\(save_vmmetadata\)\: vm \[\],  job \[(.*?)\] enter/ then
              return_string = "MIQ(save_vmmetadata): vm[], job [...] enter"
         when /Q-task_id\(\[(.*?)\]\) MIQ\(agent_job_state\)\: jobid\: \[(.*?)\] starting/ then
              return_string = "MIQ)agent_job_state): starting"
         when /Q-task_id\(\[(.*?)\]\) FileSystem\:/ then
              return_string = "FileSystem:" + $POSTMATCH
         when /vm_scan_context\) action\-process_data\: Summary XML/ then
              return_string = "vm_scan_context) action-process_data: Summary XML"
         when /Process Info\:/ then
              return_string = "Process Info:"
         when /MIQ\(scan\-action\-call_snapshot_delete\) Deleting snapshot\:/ then
              return_string = "MIQ(scan-action-call_snapshot_delete) Deleting snapshot:"
         when /Q-task_id\(\[(.*?)\]\) MIQ\((\S*)\) \[(\d*)\] message \[(\d*)\] delivered \[OK\]/ then
              return_string = $2 + " message delivered ok"
         when /JOB\(\[(.*?)\] vm_scan_context\) action\-process_data\: starting/ then
              return_string = "vm_scan_context) action-process_data: starting"
         when /Q-task_id\(\[(.*?)\]\) MIQ\(Vm-save_metadata\) TaskId = \[(.*?)\]/ then
              return_string = "MIQ(Vm-save_metadata)"
         when /Q-task_id\(\[(.*?)\]\) MIQ\(save_vmmetadata\)\: vm \[\] data put on queue, job \[(.*?)\]/ then
              return_string = "MIQ(save_vmmetadata): vm [] data put on queue"
         when /JOB\(\[(.*?)\] vm_scan_context\) action-synchronizing/ then
              return_string = "vm_scan_context) action-synchronizing"
         when /JOB\(\[(.*?)\] vm_scan_context\) Agent state update\: state\: \[Scanning\], message\: \[(\S*)\]/ then
              return_string = "Agent state update: message:[" + $2 + "]"
         when /Q-task_id\(\[(.*?)\]\) MIQ\(save_vmmetadata\)\: vm \[(.*?)\] found vm object id \[(\d*)\], job \[(.*?)\]/ then
              return_string = "MIQ(save_vmmetadata): vm[] found vm object id []"
         when /vm_scan_context\) action-process_data\: Document=vmmetadata/ then
              return_string = "action-process_data: Document=vmmetadata"
         when /vm_scan_context\) dispatch_finish\: Dispatch Status is 'finished'/ then
              return_string = "dispatch_finish: Dispatch Status is 'finished'"
         when /vm_scan_context\) action-finished\: job finished,/ then
              return_string = $POSTMATCH

         when /MIQ\(State-save_state\)\: Vm\: id=\[44\], synchronizing states/ then
              return_string = "MIQ(State-save_state): Vm: id=[##], synchronizing states"
          when /MIQ\(ExtManagementSystem-get_vim_vm_by_path\)/ then
              return_string = "MIQ(ExtManagementSystem-get_vim_vm_by_path)" + $POSTMATCH
          when /vm_scan_context\) action-call_snapshot_delete\: Enter/ then
              return_string = "vm_scan_context) action-call_snapshot_delete: Enter"
          when /vm_scan_context\) action-process_data\: sending \:synchronize/ then
              return_string = "vm_scan_context) action-process_data: sending :synchronize"
          when /VdlConnection\.getDisk\:/ then
              return_string = "VdlConnection.getDisk:" + $POSTMATCH
          when /MIQ\(MiqFaultTolerantVim[\-\.]_connect\)/ then
              return_string = "MIQ(MiqFaultTolerantVim-_connect)" + $POSTMATCH
          when /MIQ\(FsProbe-getFsMod\) FS probe detected \[(\S*)\] for \[(.*?)\]/ then
              return_string = "MIQ(FsProbe-getFsMod) FS probe detected [" + $1 + "]"
          when /Scanning \[(\S*)\] information ran for \[(.*?)\] seconds/ then
              return_string = "Scanning [" + $1 + "] information ran for [" + $2 + "] seconds"
         when /Job \[(.*?)\] update\: userid\:/ then
              return_string = "update: userid:" + $POSTMATCH
         when /MIQ\(Vm-save_metadata\) Summary XML received/ then
              return_string = "MIQ(Vm-save_metadata) Summary XML received"
         when /Command \[scanmetadata\] completed successfully in \[(.*?)\] seconds/ then
           return_string =  "Command [scanmetadata] completed successfully in [" + $1 + "] seconds"
         when /for VM\[id\]=\[(\d*)\] / then
           return_string = $PREMATCH + "for VM[id]=[##] " + $POSTMATCH
         when /id=\[(\d*)\]/ then
           return_string = $PREMATCH + "id=[##]" + $POSTMATCH
         when /Id\: \[(\D*)\]/ then
           return_string =  $PREMATCH + "Id: [##]" + $POSTMATCH
         when /MIQ\(State-save_doc\)\: name=vm, scantype=full/ then
           return_string =  "MIQ(State-save_doc): name=vm, scantype=full"
         when /MIQ\(State-save_doc\)\: id\: \[(\d*)\], name\: \[(.*?)\], scantype\: \[full\]/ then
           return_string =  "MIQ(State-save_doc): id: [##], name\: [...], scantype: [full]"
         when /MIQ\(State-save_doc\)\: id\: \[(\d*)\], name\: \[(.*?)\], scantype\: \[diff\]/ then
           return_string =  "MIQ(State-save_doc): id: [##], name\: [...], scantype: [diff]"
         when /MIQ\(State-save_doc\)\: name=vm, scantype=diff/ then
           return_string =  "MIQ(State-save_doc): name=vm, scantype=diff"
         when /TaskId\:\[(.*)?\]/ then
           return_string =  $PREMATCH + "TaskId:[...]" + $POSTMATCH
         when /aborting job \[/ then
           return_string =  $PREMATCH + "aborting job"
         when /guid\: \[(.*)?\],/ then
           return_string =  $PREMATCH + "guid: [...]," + $POSTMATCH
         when /Translated path/ then
           return_string =  $PREMATCH + "Translated path"
         when /^to scan vm/ then
           return_string =    "to scan vm"
         when /id\:\[(\d*)?\]/ then
           return_string = $PREMATCH + "id: [##]"
         else
         end
         if /Q-task_id\(\[(.*)?\]\) / =~ return_string then
           return_string = $POSTMATCH
         end
         if /JOB\(\[(.*)?\] / =~ return_string then
           return_string = $POSTMATCH
         end
         if /Translated path/ =~ return_string then
           return_string = $PREMATCH + "Translated path"
         end
# name: [Scan from Vm tch-rh64-B-s57a-16294], target
         if /name\: \[(.*)?\], target/ =~ return_string then
           return_string = $PREMATCH + "name: [...], target" + $POSTMATCH
         end
#  NAME [Scan from Vm MIQ-MySQL] SCAN
         if /NAME \[(.*)?\] SCAN/ =~ return_string then
           return_string = $PREMATCH + "NAME [...] SCAN" + $POSTMATCH
         end
# id: [17]
         if /id\:\s*\[(\d*)\]/ =~ return_string then
           return_string = $PREMATCH + "id: [##]" + $POSTMATCH
         end
#PID [30171] GUID [da1db7e0-bfc0-11de-ac0f-005056917806]
         if /PID \[(\d*)\] GUID \[(.*?)\]/ =~ return_string then
           return_string = $PREMATCH + "PID [###] GUID [...]" + $POSTMATCH
         end
         case return_string
         when / in \[(.*?)\]\s*seconds/ then
           return_string = $PREMATCH + " in [" + sprintf("%.1f",$1) + "] seconds" + $POSTMATCH
         when /for \[(.*?)\]\s*seconds/ then
            return_string = $PREMATCH + "for [" + sprintf("%.1f",$1) + "] seconds" + $POSTMATCH
#         when /created in \[(.*?)\]\s*seconds/ then
#           return_string = $PREMATCH + "created in [" +sprintf("%.1f",$1) + "] seconds" + $POSTMATCH
         end
#         puts "#{__FILE__}:#{__LINE__}- \n\tinstring value '#{instring}'\n\treturns '#{return_string}' "
         return return_string
end
#end
def jobstep_csv_write(job_instance,parsed_log_instance)
  if /storage_dispatcher_context/ =~ parsed_log_instance.payload &&
     /undefined method/ =~ parsed_log_instance.payload then
      puts "#{__FILE__}:#{__LINE__}=> undefined method in #{parsed_log_instance.payload}"   
  end
  if job_instance.job_uuid == nil || job_instance.job_uuid.size != 36 then
    puts "#{__FILE__}:#{__LINE__}=> INVESTIGATE ERROR OF MISSING JOB UUID ->#{parsed_log_instance.inspect}"
    return
  end
  case job_instance.jobstep_created
    # the case reference is to a togle that should only allow
    # one write per job statement.  It is set to true after
    # the write occurs to prevent duplicates
  when nil
      if /TRACE/!~ parsed_log_instance.payload   then
        if /storage_dispatcher_instance/ =~ parsed_log_instance.payload then
          unpeal_storage_dispatcher_context(job_instance)
         end
         if /sleeping/ =~ job_instance.job_action then
           puts "#{__FILE__}:#{__LINE__}- sleeping in job action text"
         end
         if /Scanning completed/ =~ parsed_log_instance.payload && /Scanning completed/ !~ job_instance.job_action then

            puts "#{__FILE__}:#{__LINE__}=> job action doesn't reflect payload for scanning ending"
         end
#         case $Jobsteps_csv
         if $Jobsteps_csv && !$job_step_togle then
           job_instance.job_buildid.tr('"',' ').strip if job_instance.job_buildid != nil
#         when true
           case parsed_log_instance.payload
           when /proxy-call_ws/ then
             if /Calling\:\s*\[(.*)\]/ =~ parsed_log_instance.payload then
               _ws_call_object = eval($1)

              $Jobsteps_csv.puts "#{$Startups[$startup_cnt]["server_guid"]},\"#{$Startups[$startup_cnt]["hostname"]}\"," +
              "\"#{job_instance.job_buildid}\"," +
              "#{_ws_call_object[:taskid]},#{_ws_call_object[:method_name]},#{parsed_log_instance.log_datetime}," +
              "#{parsed_log_instance.log_type_word},#{parsed_log_instance.log_pid},#{job_instance.job_userid}," +
              "\"#{_ws_call_object[:method_name]}\",\"host=#{_ws_call_object[:host]},hostid=#{_ws_call_object[:hostId]}\""

             end
           else
#         end
             if /pending/ !~ parsed_log_instance.payload && $Jobsteps_csv then

                $Jobsteps_csv.puts "#{$Startups[$startup_cnt]["server_guid"]},\"#{$Startups[$startup_cnt]["hostname"]}\"," +
                  "\"#{job_instance.job_buildid}\"," +
                  "#{job_instance.job_uuid},#{job_instance.job_cmd},#{parsed_log_instance.log_datetime}," +
                  "#{parsed_log_instance.log_type_word},#{parsed_log_instance.log_pid},#{job_instance.job_userid}," +
                  "\"#{transform_job_action(job_instance.job_action)}\",\"#{transform_parsed_log_instance_payload(parsed_log_instance.payload.tr('"',"'"))}\"" 
#                  "\"#{transform_job_action(job_instance.job_action)}\",\"#{transform_parsed_log_instance_payload(job_instance.job_modifiers[1].tr('"',"'"))}\""
                
             else
                $Jobsteps_csv.puts "#{$Startups[$startup_cnt]["server_guid"]},\"#{$Startups[$startup_cnt]["hostname"]}\"," +
                   "\"#{job_instance.job_buildid}\"," +
                   "#{job_instance.job_uuid},#{job_instance.job_cmd},#{parsed_log_instance.log_datetime}," +
                   "#{parsed_log_instance.log_type_word},#{parsed_log_instance.log_pid},#{job_instance.job_userid},\"#{transform_job_action(job_instance.job_action)}\""


             end
         end
         end
        job_instance.jobstep_created = true  # prevents duplicate job entries into jobstep file/table
        if $generatedb then                                # if $generate db is active, then create db entry
          jobstep_record = EvmJobsteps.new
          jobstep_record.evm_jobsteps_hostname = $Startups[$startup_cnt]["hostname"]
          jobstep_record.evm_jobsteps_job_uuid = job_instance.job_uuid
          jobstep_record.evm_jobsteps_log_type_word = $Parsed_log_line.log_type_word
          jobstep_record.evm_jobsteps_log_pid = $Parsed_log_line.log_pid
          jobstep_record.evm_jobsteps_job_cmd = job_instance.job_cmd
          jobstep_record.evm_jobsteps_job_userid = job_instance.job_userid
          jobstep_record.evm_jobsteps_job_action = job_instance.job_action
#        if parsed_log_instance.payload.length > 256 then
#          puts "#{__FILE__}:#{__LINE__}= payload size is #{$Parsed_log_line.payload.length} -#{$Parsed_log_line.payload}"
#        end
          jobstep_record.evm_jobsteps_job_payload = parsed_log_instance.payload
          jobstep_record.evm_jobsteps_log_datetime_seconds = $Parsed_log_line.log_datetime
          jobstep_record.evm_jobsteps_log_datetime_string = $Parsed_log_line.log_datetime_string
          jobstep_record.save
#          puts "#{jobstep_record.id}"
        end

      else
      end
    end
end
def unpeal_storage_dispatcher_context(job_instance)
  puts "#{__FILE__}:#{__LINE__}=> " 
end
