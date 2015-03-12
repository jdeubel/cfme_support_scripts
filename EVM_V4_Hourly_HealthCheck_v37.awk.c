
function string_to_date(instring) { _work_string = instring
                                     #print "parm passed into string_to_date is '" instring "'"
                                     if (index(_work_string,"[") > 0) {_work_string = substr(_work_string,index(_work_string,"[")+1)}
                                     if (index(_work_string,"]") > 0) {_work_string = substr(_work_string,1,index(_work_string,"]")-1)}
                                     #print "after initial processing value is'" _work_string "'"
                                     _work_year = substr(_work_string,1,4)
                                     _work_month = substr(_work_string,6,2)
                                     _work_day = substr(_work_string,9,2)
                                     _work_time = substr(_work_string,12,8)
                                     _return_value = _work_month "/" _work_day "/" _work_year " " _work_time
                                     #print "return value is ''" _return_value "'"
                                     return _return_value
                                    }
function _mktime(instring) {
                            #function expect input string as YYYY-MM-DDTHH:MM:SS 
                            #print instring
                            _logtime = substr(instring,2,length(instring)-3)     #strip off leading "[" and trailing "Z]"
                            gsub("-"," ",_logtime)                               # alter dashes to blanks
                            sub("T"," ",_logtime)                                # change T to blank
                            gsub(":"," ",_logtime)                               #change ":" to blanks
                           _time_value = mktime(_logtime)
                           return _time_value
                           }
function _CnU_lost_time(expected_time,actual_time) {
                                                   #print expected_time, actual_time
                                                    return (_mktime(actual_time) - _mktime(expected_time))
                                                   } 
                                                   
function normalize_to_GB(value, metric)     {
     return_value = value
     if (metric == "GB") {return return_value}
     if ( metric == "MB") {return_value = value / 1000
                           return return_value}  # normalize to GB
     if ( metric == "KB") {return_value = value / 1000000
                           return return_value} # normalize to GB
     if ( metric == "Bytes") {return_value = value / 1000000000
                               return return_value} # normalize to GB
     return return_value 
     }

function capture_filesystem_info()    {
# print $0
 filesystem_name = $13
 filesystem_type = $14
 filesystem_total_size = normalize_to_GB($15, $16)
 filesystem_used_size = normalize_to_GB($17, $18)
 filesystem_available_size = normalize_to_GB($19, $20)
 filesystem_used_percent =  $21
 filesystem_mounted_on = $26
 save_filesystem_info()
 reset_filesystem_info()
 }


function save_filesystem_info() {
 if (filesystem_line_count == 0) {print "Appliance name,time of day,filesystem name,filesystem type,total size (GB),used size (GB),available size (GB),used %,mounted on" > "Filesystems_usage_info.csv"
                                  filesystem_line_count = 1}
                  
  print EVM_Server_name,string_to_date($3),filesystem_name,filesystem_type,filesystem_total_size,filesystem_used_size,filesystem_available_size,filesystem_used_percent,filesystem_mounted_on >> "Filesystems_usage_info.csv"
  filesystem_line_count += 1

}
 
 function reset_filesystem_info() {
 filesystem_name = ""
 filesystem_type = ""
 filesystem_total_size = 0
 filesystem_used_size = 0
 filesystem_available_size = 0
 filesystem_used_percent =  0
 filesystem_mounted_on = "" 
 }

                                                                             
BEGIN {
# read thru the last_startup.txt file to identify the EVM Server name to inject into each line
EVM_Server_name = ""
   find_server_name = getline < "last_startup.txt"

    while (find_server_name > 0 )  {  
          if ($0 ~ /Server EVM id and name\:/) {EVM_Server_name  = $NF
                                            #print
                                            #print "EVM_Server_name =",EVM_Server_name
                                            }
          find_server_name = (getline < "last_startup.txt" )    
          } 
OFS = ","
###
### V4 Roles Array Definition
V4_roles_array["alert_processor"] = ""
V4_roles_array["automate"] = ""
V4_roles_array["dbops" ] = ""
V4_roles_array["dbowner" ] = ""
V4_roles_array["dbsync"] = ""
V4_roles_array["database_synchronization"] = ""
V4_roles_array["event"] = ""
V4_roles_array["performancecollector"] = ""
V4_roles_array["performancecoordinator"] = ""
V4_roles_array["performanceprocessor"] = ""
V4_roles_array["reporting"] = ""
V4_roles_array["scheduler"] = ""
V4_roles_array["smartproxy"] = ""
V4_roles_array["smartstate"] = ""
V4_roles_array["smartstate_drift"] = ""
V4_roles_array["smirefresh"] = ""
V4_roles_array["userinterface"] = ""
V4_roles_array["vcenter"] = ""
V4_roles_array["vcrefresh"] = ""
V4_roles_array["webservices"] = ""
V4_roles_array["kvm"] = ""
V4_roles_array["ems_operations"] = ""
V4_roles_array["user_interface"] = ""
V4_roles_array["web_services"] = ""
V4_roles_array["database_operations"] = ""
V4_roles_array["database_owner"] = ""
V4_roles_array["ems_inventory"] = ""
V4_roles_array["ems_metrics_coordinator"] = ""
V4_roles_array["ems_metrics_processor"] = ""
V4_roles_array["ems_metrics_collector"] = ""
V4_roles_array["ldap_synchronization"] = ""
V4_roles_array["notifier"] = ""
V4_roles_array["storage_inventory"] = ""
V4_roles_array["storage_metrics_collector"] = ""
V4_roles_array["storage_metrics_coordinator"] = ""
V4_roles_array["storage_metrics_processor"] = ""
V4_roles_array["vmdb_storage_bridge"] = ""  
V4_roles_array["vdi_inventory"] = ""    
V4_roles_array["rhn_mirror"] = ""                                    
V4_roles_array["unknown"] = ""

####
HOUR = 0 
log_date = 0 
datehour = ""
new_datehour = ""
errors = 0   
warnings = 0  
info = 0   
debug = 0   
server_start =0  
worker_start =0  
workers_killed = 0 
has_not_responded = 0
broker_not_available = 0
full_vc_refreshes_started = 0
full_vc_refreshes_ended = 0
performance_purges_ended = 0
performance_instances_deleted = 0
max_VC_refresh_time = 0    
max_all_target_refresh_time = 0
ems_refresh = 0
db_errors = 0
refresh_timeouts = 0
workermonitor_starts = 0
vm_collections = 0
gt_600 = 0
events_caught = 0
events_queued = 0
evm_events = 0
evm_alerts = 0
create_evaluate_alerts = 0
process_evaluate_alerts = 0
VC_ID = ""
vcid_last_refresh_started = ""
delete_duration = 0
delete_count = 0
garbage_collection_count = 0
garbage_collection_min_time = 0
garbage_collection_max_time = 0
vim_failed_to_create_new_connection_count = 0
vm_scan_start_count = 0
vm_scan_complete_count = 0
vm_scan_max_active = 0
vm_scan_active_count = 0

bloat_data_count = 0
postgresql_activity_stats = 0
table_statistics_data_count = 0
table_size_data_count = 0

print "Evm Server Name,log date time,scans started,scans ended,max active scans,active at end of hour" > "V4_Vm_Scan_Activity.csv"
print "EVM Server Name,log date time,msg put or get,alert type"     > "V4_Alert_Info.csv"
print "EVM Server Name,log date time,table type,msg state,zone,zone count,role name,count" > "V4_Queue_counts_by_state_and_role.csv"
print ""  >  "V4_evaluate_alerts.txt"            #clear any existing file
print "" >   "V4_EVM_alerts_raised.txt"          #clear any existing file
print "" >   "V4_EVM_event_raised.txt"           #clear any existing file
print "" >   "V4 Preloading Broker.txt"          #clear any existing file
print "" > "V4 Alerts Triggered.txt"             #clear any existing file
print "" > "V4 Server_Monitor_loop.txt"          #clear any existing file
print "" > "Queued_email.txt"                    #clear any existing file
print "" > "Creating_provision_instances_for_request.txt"  # clear any existing file
print "" > "provision_detail_tracking.cmd"       # clear any existing file
print "" > "chase_provision_requests.cmd"        # clear any existing file
print "EVM Server Name,date time,total time,worker dequeue, worker messaging, worker monitor,server dequeue,heartbeat,log active servers" > "V4_Server_Monitor_loop.csv"
print "EVM server name,datehour,errors,warnings,info,debug,server starts,worker monitor starts,worker starts,workers killed,has not responded count,garbage collections,garbage collection max seconds,broker not available or drb uri error,vim failed to create new connection count,ems refresh completed,full VC refresh started,full VC refresh completed,max VC refresh duration,max all target refresh duration,VC id,db errors,refresh timeouts,vmid of last VC refresh started,C&U VM collection count,VM C&U Wait > 600 seconds,VM C&U misses,C&U host collection count, C&U host wait > 600 seconds,Host C&U misses,C&U storage collection count,C&U storage wait > 600 seconds,events caught,events queued,performance purges ended, performance instances deleted,evm events count,evm alerts count,alert msgs created,alert msgs processed"
print "EVM server name,Hour,Duration,Count" > "V4 Hourly VM Perf_capture Counts by Duration.csv"
print "EVM server name,Hour,Duration,Count" > "V4 Hourly Host Perf_capture Counts by Duration.csv"
print "EVM server name,Hour,Duration,Count" > "V4 Hourly Storage Perf_capture Counts by Duration.csv"
print "EVM server name,worker process,start time,end time,purged records count" > "V4 Purged  Performances.csv"
print "EVM server name,log date time,dequeue wait time" > "V4_vm_perf_capture_dequeue_times.csv"
print "EVM server name,log date time,element class,element name,expected time,actual time,missed duration (seconds)" >"V4_C&U_Collection_misses.csv"
print "EVM server name,log date time,class type,method name,row count" > "V4_Performance_Rows_Captured.csv"
print "" > "V4_EVM_Roles_actions.txt"
print "" > "MiqServer_log_status.txt"
print "" > "MiqWorker_log_status.txt"
print "" > "q_task_keeper_lines"
#print "" > "Filesystems_usage_info.csv"
#print "EVM Server Name,log date time,Pid:Tid,local,master,status,appliance id,pid,guid,appliance name,zone,hostname,build,version,ipaddress,roles count,alert processor,automate,db ops,db owner,db sync,database synchronization,event,performance collector,performance coordinator,performance processor,reporting,scheduler,smart proxy,smart state,smart state drift,smi refresh,user interface,vcenter,vc refresh,web services,kvm,ems operations,user interface,web services,database operations,database owner,ems inventory,ems metrics coordinator,ems metrics processor,ems metrics collector,ldap synchronization,notifier,storage inventory,storage metrics collector,storage metrics coordinator,storage metrics processor,vmdb storage bridge,vdi inventory,unknown" > "V4_EVM_appliance_active_roles.csv"
 print "EVM Server Name,log date time,Pid:Tid,local,master,status,appliance id,pid,guid,appliance name,zone,hostname,build,version,ipaddress,roles count,alert processor,automate,db ops,db owner,db sync,database synchronization,event,performance collector,performance coordinator,performance processor,reporting,scheduler,smart proxy,smart state,smart state drift,smi refresh,user interface,vcenter,vc refresh,kvm,ems operations,user interface,web services,database operations,database owner,ems inventory,ems metrics coordinator,ems metrics processor,ems metrics collector,ldap synchronization,notifier,storage inventory,storage metrics collector,storage metrics coordinator,storage metrics processor,vmdb storage bridge,vdi inventory,RHN mirror,unknown" > "V4_EVM_appliance_active_roles.csv"
print "" > "V4_Schedule_actions.txt"
print "miq license info text file" > "V4_miqlicense.txt"
print "EVM server name,refresh end date time,Pid:Tid,vc name,vc id, total time,parse vc data,get vc data,db save inventory,get vc data ems customization spec,post refresh ems,filter vc data,get vc data total,get vc data host scsi" > "V4 VC Refresh Timings.csv"

vc_refresh_total_time = 0
vc_refresh_parse_vc_data = 0
vc_refresh_get_vc_data = 0
vc_refresh_db_save_inventory = 0
vc_refresh_get_vc_data_ems_customization_spec = 0
vc_refresh_post_refresh_ems = 0
vc_refresh_filter_vc_data = 0
vc_refresh_get_vc_data_total = 0
vc_refresh_get_vc_data_host_scsi = 0
vc_refresh_vc_name = ""
vc_refresh_vc_id = ""
vc_refresh_timings = ""
vc_refresh_end_time = ""
vc_refresh_pidtid = ""
Vm_CnU_misses = 0
Host_CnU_misses = 0
Storage_CnU_misses = 0

## FILESYSTEM GLOBAL VARIABLES
 filesystem_name = ""
 filesystem_type = ""
 filesystem_total_size = 0
 filesystem_used_size = 0
 filesystem_available_size = 0
 filesystem_used_percent =  0
 filesystem_mounted_on = "" 
 filesystem_line_count = 0


  }
$1 !~ /\[\-\-\-\-\]/ {   # if this isn't typical log line then look for critical text
                      if ( $0 ~ /Segmentation/ )    { print good_log_line >> "---Critical Error.txt"
                                                      print >> "---Critical Error.txt"}    # print info if found
                      next                 # and move onto next log line
                      }
/ DEBUG \-\- \:/ {next}
/\[\-\-\-\-\]/ {good_log_line = $0}         # keep the last good log line around in case we get a critial error without the standard log preamble
$2  ~ /E,/ {errors++
            if ($0 ~ /Broker is not available/) {broker_not_available++}
            }
/MIQ\(MiqLicense/ {
                   print >> "V4_miqlicense.txt"
                   next 
                   }
/performance rows\.\.\.Complete \-/     { split(substr($8,5,length($8)-5),_work_array,".")      # class and method names into array
                                          _work_rows = $11                                      # row count captured
                                          print EVM_Server_name,string_to_date($3),_work_array[1],_work_array[2],_work_rows >>"V4_Performance_Rows_Captured.csv"
                                         }       
/Refreshing targets for EMS\.\.\.Complete \- Timings\:/ {
                     vc_refresh_end_time = $3
                     vc_refresh_pidtid = $4
                     _work_string = substr($0,index($0,"EMS: ")+length("EMS: "))   # get trailing part of line
                     _end_position = index(_work_string,"],")                   # get end of vc name
                     vc_refresh_vc_name = substr(_work_string,1,_end_position)  # distill vc name
                     _word_cntr = 8      #if vc is one word then this is where the id: string is
                     while (_word_cntr <= NF)       #loop thru the rest of the words 
                           {
                           #print "word cntr ="_word_cntr " is '" $(_word_cntr) "'"
                           #print  
                           if ($(_word_cntr) == "id:") {vc_refresh_vc_id = $(_word_cntr + 1) }
                             if ($(_word_cntr) ~/total_time/) 
                                  { _temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                    gsub(","," "_temp)                                    
                                     vc_refresh_total_time = int(_temp)
                                     }
                             if ($(_word_cntr) ~/parse_vc_data/) 
                                { _temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp)  
                                  vc_refresh_parse_vc_data = int(_temp)
                                  }
                             if ($(_word_cntr) ~/get_vc_data/) 
                                  { _temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp)
                                  vc_refresh_get_vc_data = int(_temp)
                                  }
                             if ($(_word_cntr) ~/db_save_inventory/) 
                                  {_temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp) 
                                  vc_refresh_db_save_inventory = int(_temp)
                                  }
                             if ($(_word_cntr) ~/get_vc_data_ems_customization_spec/) 
                                  {_temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp) 
                                  vc_refresh_get_vc_data_ems_customization_spec = int(_temp)
                                  }
                             if ($(_word_cntr) ~/post_refresh_ems/) 
                                  {_temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp) 
                                  vc_refresh_post_refresh_ems = int(temp)
                                  }
                             if ($(_word_cntr) ~/filter_vc_data/) 
                                  { _temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp) 
                                   vc_refresh_filter_vc_data = int(_temp)
                                   }
                             if ($(_word_cntr) ~/get_vc_data_total/) 
                                  { _temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp) 
                                   vc_refresh_get_vc_data_total = int(_temp)
                                   }
                             if ($(_word_cntr) ~/get_vc_data_host_scsi/) 
                                  {_temp = substr($(_word_cntr),index($(_word_cntr),">")+1)
                                  gsub(","," "_temp) 
                                  vc_refresh_get_vc_data_host_scsi = int(_temp)
                                  }
                             _word_cntr++ 
                             #print
                             #print "word counter= "_word_cntr 
                           }
                           
                     print EVM_Server_name,string_to_date(vc_refresh_end_time),vc_refresh_pidtid,vc_refresh_vc_name,vc_refresh_vc_id,vc_refresh_total_time,vc_refresh_parse_vc_data,vc_refresh_get_vc_data,vc_refresh_db_save_inventory,vc_refresh_get_vc_data_ems_customization_spec,vc_refresh_post_refresh_ems,vc_refresh_filter_vc_data,vc_refresh_get_vc_data_total,vc_refresh_get_vc_data_host_scsi > "V4 VC Refresh Timings.csv"
                     vc_refresh_total_time = 0
                      vc_refresh_parse_vc_data = 0
                      vc_refresh_get_vc_data = 0
                      vc_refresh_db_save_inventory = 0
                      vc_refresh_get_vc_data_ems_customization_spec = 0
                      vc_refresh_post_refresh_ems = 0
                      vc_refresh_filter_vc_data = 0
                      vc_refresh_get_vc_data_total = 0
                      vc_refresh_get_vc_data_host_scsi = 0
                      vc_refresh_vc_name = ""
                      vc_refresh_vc_id = ""
                      vc_refresh_timings = ""
                      vc_refresh_end_time = ""
                      vc_refresh_pidtid = ""
                     }
$2  ~ /W,/ {warnings++
            if ($0 ~ /Garbage collection took/) {garbage_collection_count++
                                                 _temp_garbage_collection_time = $(NF-1)
                                                 
                                                 if (garbage_collection_min_time == 0 ) {garbage_collection_min_time = _temp_garbage_collection_time}
                                                 if (garbage_collection_min_time > _temp_garbage_collection_time) {garbage_collection_min_time = _temp_garbage_collection_time}
                                                 if (garbage_collection_max_time == 0) {garbage_collection_max_time = _temp_garbage_collection_time}
                                                 if (garbage_collection_max_time < _temp_garbage_collection_time) {garbage_collection_max_time = _temp_garbage_collection_time}
                                                 
                                                 }
#MIQ(Vm.perf_capture) [realtime] For Vm name: [SF_40120+_ChiDB], id: [99000000000120], expected to get data as of [2011-08-01T16:46:20Z], but got data as of [2011-08-01T16:48:40Z]                                                 
             if ($0 ~ /expected to get data as of/) {  # print
                                                      _actual_collect_time = $NF
                                                      _expected_collect_time = $(NF-6)  
                                                      _name_begin = index($0,"name: [") + length("name: [")
                                                      _work_string = substr($0,_name_begin)                  # isolate log line from beginning of name
                                                      _name_end = index(_work_string,"],")                   # now the _name_end is the length of the string to move +1
                                                      #_name_length = _name_end - _name_begin                # no longer needed
                                                      _perf_capture_name =    substr(_work_string,1,_name_end-1)    # reduce length by one and substring it into variable
                                                     # print " perf capture name is ''" _perf_capture_name "'"
                                                      _converted_actual_collect_time = string_to_date(_actual_collect_time)
                                                     # print " _actual_collect_time=>" _actual_collect_time ": _converted_actual_collect_time => " _converted_actual_collect_time
                                                      _converted_expected_collect_time = string_to_date(_expected_collect_time)

                                                      print EVM_Server_name "," string_to_date($3) "," $11 ",\"" _perf_capture_name "\"," _converted_expected_collect_time "," _converted_actual_collect_time "," _CnU_lost_time($NF,$(NF-6))>>"V4_C&U_Collection_misses.csv"
                                                      if ($11 == "Vm") {Vm_CnU_misses++
                                                                       #print $11 
                                                                       }
                                                      if ($11 == "Host") {Host_CnU_misses++
                                                                        #print $11
                                                                        }
                                                      if ($11 == "Storage") {Storage_CnU_misses++
                                                                            #print $11
                                                                            }
                                                     }
                if ($0 ~ /Active VimBroker DRb URI is blank/) {broker_not_available++}                                                                        
           }

$2  ~ /I,/ {info++ }
$2  ~ /D,/ {debug++}
$3  ~ /(.*?)T(.*)/ {  #print $0
          datehour_array_count = split($3,date_array,":")
         # print date_array[1] 
          new_datehour = date_array[1]                                                      
            if (new_datehour != datehour) { #print "new datehour value is '" datehour "'" 
            old_datehour = datehour
            datehour = new_datehour
            datehour_display = substr(old_datehour,7,2) "/" substr(old_datehour,10,2) "/" substr(old_datehour,2,4) " " substr(old_datehour,13,3) ":00:00" ; # print datehour_display
            if ( length(datehour_display) > 12) {   # don't print the initial value since it is malformed and does not represent anything anyway
#            print datehour_display, errors, warnings,info, debug,  server_start,workermonitor_starts,worker_start,workers_killed,has_not_responded,garbage_collection_count,ems_refresh,full_vc_refreshes_started,full_vc_refreshes_ended,max_VC_refresh_time,VC_id,db errors,refresh_timeouts,vcid_last_refresh_started,vm_collections,gt_600,events_caught,events_queued
            print EVM_Server_name, datehour_display, errors, warnings,info, debug,  server_start,workermonitor_starts,worker_start,workers_killed,has_not_responded,garbage_collection_count,sprintf("%.0f",garbage_collection_max_time),broker_not_available,vim_failed_to_create_new_connection_count,ems_refresh,full_vc_refreshes_started,full_vc_refreshes_ended,max_VC_refresh_time,max_all_target_refresh_time,VC_id,db_errors,refresh_timeouts,vcid_last_refresh_started,vm_collections,vm_gt_600,Vm_CnU_misses,host_collections,host_gt_600,Host_CnU_misses,storage_collections,storage_gt_600,events_caught,events_queued,performance_purges_ended,performance_instances_deleted,evm_events,evm_alerts,create_evaluate_alerts,process_evaluate_alerts
            datehour = new_datehour  
            errors = 0   
            warnings = 0  
            info = 0   
            debug = 0   
            server_start =0  
            worker_start =0  
            workers_killed = 0 
            has_not_responded = 0
            full_vc_refreshes_started = 0
            full_vc_refreshes_ended = 0
            ems_refresh = 0    
            max_VC_refresh_time    = 0  
            max_all_target_refresh_time = 0 
            db_errors = 0   
            refresh_timeouts = 0 
            workermonitor_starts = 0    
            vm_collections = 0
            host_collections = 0
            storage_collections = 0
            vm_gt_600 = 0
            host_gt_600 = 0
            storage_gt_600 = 0
            VC_id = ""
            events_caught = 0
            events_queued = 0
            evm_events = 0
            evm_alerts = 0
            create_evaluate_alerts = 0
            process_evaluate_alerts = 0

            Vm_CnU_misses = 0
            Host_CnU_misses = 0
            Storage_CnU_misses = 0
            broker_not_available = 0
            vcid_last_refresh_started = ""
            performance_purges_ended = 0
            performance_instances_deleted = 0
            garbage_collection_count = 0
            garbage_collection_max_time = 0
            garbage_collection_min_time = 0
            vim_failed_to_create_new_connection_count = 0
            for (item in VM) {print EVM_Server_name,datehour_display,item,VM[item]  >>   "V4 Hourly VM Perf_capture Counts by Duration.csv"
                  delete VM[item]}
            for (item in Host) {print EVM_Server_name,datehour_display,item,Host[item] >> "V4 Hourly Host Perf_capture Counts by Duration.csv"
                  delete Host[item]}
            for (item in Storage) {print EVM_Server_name,datehour_display,item,Storage[item] >> "V4 Hourly Storage Perf_capture Counts by Duration.csv"
                  delete Storage[item]}             
         #print new_datehour


            print EVM_Server_name,datehour_display,vm_scan_start_count,vm_scan_complete_count,vm_scan_max_active,vm_scan_active_count >>"V4_Vm_Scan_Activity.csv"        
            vm_scan_start_count = 0     # reset started count for next hour
            vm_scan_complete_count = 0  # reset completed count for next hour
            #vm_scan_max_active = 0     # don't reset max active as I want to track that across hours
            #vm_scan_active_count = 0   # don't reset active scan count as I want to use that to track active across hours

                         }        
                                           }
                      }
/[Cc]aught event/ {events_caught++}
/Queueing event/ {events_queued++}
   
/MIQ\(MiqServer\.start\) Server IP Address\:/ {server_start++}                 
# /\[VMDB\]/ {server_start++}

/failed to create new connection for/     {vim_failed_to_create_new_connection_count++}
/abstract_adapter/ {if ($5 == "ERROR") {db_errors++}}  # if the string "abstract_adapter" is found on an ERROR log line then increment counter
/1205 response/ {db_errors++}                          # all " 1205 response" strings are db errors       
/execution expired  Method\:\[refresh\]/ {refresh_timeouts++ }      # this is intended to catch failing vc refresh occurances
/MiqQueue\.get/ { if ( $0 !~ /stale/  && $0 ~ /\.perf_capture/ )   {
                                         _msgid = substr($11,2,length($11)-3)
                                        if ($0 ~ /(Vm|VmVmware|VmRedhat)\.perf_capture/ ) { msgid[_msgid] = "VM"
                                                                                            #print "found vm->" $0
                                                                                           }  
                                        else if ($0 ~ /(Host|HostRedhat|HostVmware|HostVmwareEsx)\.perf_capture/ ) msgid[_msgid] = "Host"
                                        else if ($0 ~ /Storage\.perf_capture/ ) msgid[_msgid] = "Storage"
                                        else msgid[_msgid] = "unknown"
                                                                  }
                } 
/MiqQueue\.delivered/ {if ($0 ~ /\[ok\]\,/) {
                                              _msgid = substr($11,2,length($11)-3)
                                              #print _msgid
                                              if (_msgid in msgid)  {
                                                                     _duration = int(substr($(NF-1),2,length($(NF-1))-2))   # convert duration into integer
                                                                     # compares below find which kind of entry this "perf_capture" was for
                                                                     # and then increments the array value for the duration in seconds by 1
                                                                     if      (msgid[_msgid] == "VM") {VM[_duration] += 1
                                                                                                       #print "VM DURATION FOR MSGID" _msgid " is " _duration "-(" $(NF-1)")"
                                                                                                       #print $0
                                                                                                       }
                                                                     else if (msgid[_msgid] == "Host") Host[_duration] += 1
                                                                     else if (msgid[_msgid] == "Storage") Storage[_duration] += 1
                                                                     delete msgid[_msgid]            # no need to keep this entry so delete it
                                                                     }
                                              
                                              } 
                      }           
/ started\./ {worker_start++}
/being killed/ {workers_killed++}
/has not responded/ {has_not_responded++}

#MIQ(VcRefresher.refresh) Refreshing all targets...Completed in 48.346351s
/MIQ\(VcRefresher.refresh\) Refreshing all targets\.\.\.Completed/ { #print
                                                                           _all_targets_refresh_time = $NF
                                                                           gsub(/s/,"",_all_targets_refresh_time)
                                                                           _all_targets_refresh_time = int(_all_targets_refresh_time)
                                                                           #print "all targets refresh time found is ",_all_targets_refresh_time
                                                                           if (max_all_target_refresh_time < _all_targets_refresh_time) {max_all_target_refresh_time = _all_targets_refresh_time }
                                                                           _all_targets_refresh_time = 0
                                                                    } 
# /Refreshing targets for EMS\: (.*?)\.\.\.Complete/ {ems_refresh++}        superceeded

# sample payload for regex prototype /MIQ(VcRefresher.refresh) EMS: [nycs00058100], id: [1] Refreshing target ExtManagementSystem [nycs00058100] id [1]...Complete

/MIQ\(VcRefresher\.refresh\) EMS\: \[(.*?)\]\, id\: \[(.*?)\] Refreshing target (EmsVmware|EmsVc|ExtManagementSystem) \[(.*?)\] id \[(.*?)\]\.\.\.Complete/ {
                                                            full_vc_refreshes_ended++
                                                            #print
                                                            }
#/MIQ\(VcRefresher\.refresh\) EMS\:\s*\[(.*)\],\s*id\:\s*\[(.*?)\]\s*Refreshing target\s*ExtManagementSystem\s*\[(.*?)\]\s*id\s*\[(.*?)\]\.\.\.Complete/   


 # /MIQ(VcRefresher.refresh) EMS: [nycs00057696 PB], id: [3]   ExtManagementSystem: [nycs00057696 PB], id: [3]
 
/MIQ\(VcRefresher\.refresh\) EMS\: \[(.*)\]\, id\: \[(.*)\]   (EmsVmware|EmsVc|ExtManagementSystem)\: \[(.*)\], id\: \[(.*)\]/ {full_vc_refreshes_started++
                                                             #print
                                                             _temp = split($(NF),vcid_array,".")         # separate by trailing periods
                                                             vcid_last_refresh_started = vcid_array[1]   # the first array element has the vc id
                                                             #add code to delete entire array   
                                                             vcid_array[1] = ""                          # drop array value after assign
                                                             }

                                                              
/Refreshing targets for EMS\.\.\.Complete \- Timings\:/ {     ems_refresh++

                                                                          for (wordcnt = 12; wordcnt <= NF ;wordcnt++) { #print wordcnt,$wordcnt 
                                                                                                                       if  ($wordcnt ~ /total_time/) { #print "total time found",$wordcnt 
                                                                                                                                                      refresh_time = substr($wordcnt,(index($wordcnt,">")+1))   # find total time in log line
                                                                                                                                                     gsub(/,/,"",refresh_time)                                # get substring following "=>"
                                                                                                                                                     refresh_time = int(refresh_time)                         # turn this into an integer
                                                                                                                                                     wordcnt = NF+1
                                                                                                                                                    }
                                                                                                                      }
                                                              #refresh_time = $(NF-1) # GET REFRESH TIME IN SECONDS
                                                              if (max_VC_refresh_time < refresh_time) {
                                                                                                       max_VC_refresh_time = refresh_time
                                                                                                       # _count = split($(NF-3),vcid_array,".")        # split out the vc id by getting first part isolated
                                                                                                       # VC_id = vcid_array[1]
                                                                                                       #add code to delete entire array
                                                                                                       # vcid_array[1] = ""
                                                                                                       }
                                                                           refresh_time = 0
                                                                           }                                                               
                                                              
                                                              
 /WorkerMonitor started\./ {workermonitor_starts++}
 /\[(Vm|VmVmware|VmRedhat)\.perf_capture\]/  { if ( $8 ~ /MIQ\(MiqQueue.get/  ) { 
                                  vm_collections++
                                   wait_time = int(substr($(NF-1),2,length($(NF-1))-2))
                                  if (wait_time > 600)    
                                      {vm_gt_600++; 
                                      # print $3,wait_time  # suspent printing this for now
                                      }
                                                          }                            
                          }
 /\[(Host|HostVmwareEsx|HostRedhat)\.perf_capture\]/  { if ( $8 ~ /MIQ\(MiqQueue.get/ ) { 
                                  host_collections++
                                  wait_time = int(substr($(NF-1),2,length($(NF-1))-2))
                                  if (wait_time > 600)    
                                      {host_gt_600++; 
                                      # print $3,wait_time  # suspent printing this for now
                                      }
                                                          }  
                                                                                    
                          } 
 /\[Storage\.perf_capture\]/  { if ( $8 ~ /MIQ\(MiqQueue.get/ ) { 
                                  storage_collections++                                 
                                  wait_time = int(substr($(NF-1),2,length($(NF-1))-2))
                                  if (wait_time > 600)    
                                      {storage_gt_600++;  
                                      # print $3,wait_time  # suspent printing this for now
                                      }
                                                          }
                          }
#[----] I, [2012-06-15T18:14:49.554361 #21119:15b46a9f9140]  INFO -- : MIQ(VimPerformance.purge) Purging 1000 realtime performances.
#[----] I, [2012-06-15T18:14:49.879208 #21119:15b46a9f9140]  INFO -- : MIQ(VimPerformance.purge) Purging 620 realtime performances. 
#/MIQ\(VimPerformance\.purge\) Purging/ { if ($(NF) == "performances." {_purge_record_count = $(NF-2) 
#                                                                       performance_instances_deleted += _purge_record_count
#                                                                      }
#[----] I, [2012-06-15T18:14:49.999033 #21119:15b46a9f9140]  INFO -- : 
#MIQ(VimPerformance.purge) Purging all realtime performances older than [Fri Jun 15 14:14:33 UTC 2012]...Complete - Deleted 1620 records and 0 associated tag values - Timings: {:total_time=>0.53476619720459, :query_oldest=>0.0557169914245605, :query_batch=>0.263683795928955, :purge_vim_performances=>0.205416917800903}                                                                       
/Purging all (realtime|hourly|daily) performances older than/ { if ($22 == "Deleted") {_purge_record_count = $23             # get total count of records deleted
                                                                   performance_purges_ended++
                                                                   performance_instances_deleted += _purge_record_count
                                                                   # print "purge end time",$3
                                                                   _purge_end_time = $3
                                                                 sub(/T/," ",_purge_end_time)    # grab log time from standard preamble
                                                                 _purge_end_time = substr(_purge_end_time,2,19)   # convert to date time usable by excel
                                                                 print EVM_Server_name,substr($4,2,length($4)-2),purge_worker_array[substr($4,2,length($4)-2)],_purge_end_time,_purge_record_count >> "V4 Purged  Performances.csv"      #write to output file
                                                                 delete purge_worker_array[$4]         # remove array element no longer needed.
                                                                }
                                        else { 
                                               # print "purge begin time",$3
                                               _purge_start_time = $3
                                               sub(/T/," ",_purge_start_time)                    # this is beginning of purge sequence so grab start time
                                               purge_worker_array[substr($4,2,length($4)-2)] = substr(_purge_start_time,2,19) # save into array element associated with worker pid:tid
                                              }                                                                       
                                                                      
                                        }                              
 /Purging all (realtime|hourly|daily) (metrics|performances)/ {  if ($(NF) == "records")   {_purge_record_count = $(NF-1)         # get count of records deleted
                                                                   performance_purges_ended++
                                                                   performance_instances_deleted += _purge_record_count
                                                                   # print "purge end time",$3
                                                                   _purge_end_time = $3
                                                                 sub(/T/," ",_purge_end_time)    # grab log time from standard preamble
                                                                 _purge_end_time = substr(_purge_end_time,2,19)   # convert to date time usable by excel
                                                                 print EVM_Server_name,substr($4,2,length($4)-2),purge_worker_array[substr($4,2,length($4)-2)],_purge_end_time,_purge_record_count >> "V4 Purged  Performances.csv"      #write to output file
                                                                 delete purge_worker_array[$4]         # remove array element no longer needed.
                                                                }
                                        else { 
                                               # print "purge begin time",$3
                                               _purge_start_time = $3
                                               sub(/T/," ",_purge_start_time)                    # this is beginning of purge sequence so grab start time
                                               purge_worker_array[substr($4,2,length($4)-2)] = substr(_purge_start_time,2,19) # save into array element associated with worker pid:tid
                                              } 
                                      }

#[----] I, [2013-04-08T13:20:18.028555 #23530:cf9004]  INFO -- : MIQ(Metric::Purging.purge) Purging all realtime metrics older than [2013-04-08 09:20:10 UTC]...
#[----] I, [2013-04-08T13:20:21.534414 #23530:cf9004]  INFO -- : MIQ(Metric::Purging.purge) Purging 1000 realtime metrics.
#[----] I, [2013-04-08T13:20:21.956807 #23530:cf9004]  INFO -- : MIQ(Metric::Purging.purge) Purging 1000 realtime metrics.
#[----] I, [2013-04-08T13:20:22.634827 #23530:cf9004]  INFO -- : MIQ(Metric::Purging.purge) Purging 860 realtime metrics.
#[----] I, [2013-04-08T13:20:23.722280 #23530:cf9004]  INFO -- : MIQ(Metric::Purging.purge) Purging all realtime metrics older than [2013-04-08 09:20:10 UTC]...Complete - Deleted 2860 records and 0 associated tag values - Timings: {:query_oldest=>2.5185458660125732, :query_batch=>1.057755470275879, :purge_metrics=>1.337859869003296, :total_time=>5.693000793457031} 
#   1   2          3                      4             5    6 7            8                9       10 11       12      13     14   15         16       17              18 19       20

/Purging all (realtime|hourly|daily) metrics older than/ { if ($19 == "Deleted") {_purge_record_count = $20             # get total count of records deleted
                                                                   performance_purges_ended++
                                                                   performance_instances_deleted += _purge_record_count
                                                                   # print "purge end time",$3
                                                                   _purge_end_time = $3
                                                                 sub(/T/," ",_purge_end_time)    # grab log time from standard preamble
                                                                 _purge_end_time = substr(_purge_end_time,2,19)   # convert to date time usable by excel
                                                                 print EVM_Server_name,substr($4,2,length($4)-2),purge_worker_array[substr($4,2,length($4)-2)],_purge_end_time,_purge_record_count >> "V4 Purged  Performances.csv"      #write to output file
                                                                 delete purge_worker_array[$4]         # remove array element no longer needed.
                                                                }
                                        else { 
                                               # print "purge begin time",$3
                                               _purge_start_time = $3
                                               sub(/T/," ",_purge_start_time)                    # this is beginning of purge sequence so grab start time
                                               purge_worker_array[substr($4,2,length($4)-2)] = substr(_purge_start_time,2,19) # save into array element associated with worker pid:tid
                                              }                                                                       
                                                                      
                                        } 



                                      
/Preloading broker/ { print >> "V4 Preloading Broker.txt" }   
/miqlicense/ { print >> "miqlicense.txt"}  
/Alert Triggered/ {print >> "V4 Alerts Triggered.txt"}  
/MiqServer\.monitor_loop/ { 
                            _log_datetime = $3
                            _total_time = 0
                            _worker_dequeue = 0
                            _worker_messaging = 0
                            _worker_monitor = 0
                            _server_dequeue = 0
                            _heartbeat = 0
                            _log_active_servers = 0
                            for ( fld_cnt = 14; fld_cnt <= NF; fld_cnt++ )
                                { split($(fld_cnt),_element_array,">" )
                                  _duration = substr(_element_array[2],1,length(_element_array[2]) - 1 )
                                  
                                  if ( $(fld_cnt) ~ /total_time/ ) { _total_time = _duration }
                                  if ( $(fld_cnt) ~ /worker_dequeue/ ) { _worker_dequeue = _duration }
                                  if ( $(fld_cnt) ~ /worker_messaging/ ) { _worker_messaging = _duration }
                                  if ( $(fld_cnt) ~ /worker_monitor/ ) { _worker_monitor = _duration }
                                  if ( $(fld_cnt) ~ /server_dequeue/ ) { _server_dequeue = _duration }
                                  if ( $(fld_cnt) ~ /heartbeat/ ) { _heartbeat = _duration }
                                  if ( $(fld_cnt) ~ /log_active_servers/ ) { _log_active_servers = _duration }
                                #  if ( $(fld_cnt) ~ /total_time/ ) { _total_time = _duration }
                                #  if ( $(fld_cnt) ~ /total_time/ ) { _total_time = _duration }
                                  
                                }
                            print EVM_Server_name,string_to_date(_log_datetime),_total_time,_worker_dequeue,_worker_messaging,_worker_monitor,__server_dequeue,_heartbeat,_log_active_servers >> "V4_Server_Monitor_loop.csv"
                            # print >> "V4 Server_Monitor_loop.txt" 
                            }
/MiqQueue\.get/    && /Vm(.*?)\.perf_capture\]/ { _log_datetime = $3
                                            _wait_time = $(NF-1)
                                             # print "wait time=" _wait_time                                        
                                            _pid_tid = $4
                                             _log_year = substr(_log_datetime,2,4)
                                             _log_month = substr(_log_datetime,7,2)
                                             _log_day = substr(_log_datetime,10,2)
                                             _log_time = substr(_log_datetime,13,8) 
                                             _pid_tid = substr(_pid_tid,1,length(_pid_tid)-1)                 # strip off traiing end-bracket
                                             _wait_time = substr(_wait_time,2,length(_wait_time)-2)       # get values between begin-end brackets

                                             _print_string = EVM_Server_name "," _log_month "/" _log_day "/" _log_year " " _log_time "," _wait_time
                                             print _print_string >> "V4_vm_perf_capture_dequeue_times.csv"
                                             }   

/MIQ\(Event\.raise_evm_event\)\: Event Raised / { evm_events++ 
                                             print >> "V4_EVM_event_raised.txt"
                                             }  
                                             
/MIQ\(Event.raise_evm_event\)\: Alert for Event/ { evm_alerts++
                                               print >> "V4_EVM_alerts_raised.txt"
                                    }    
    
                                                
/Command\: \[MiqAlert\.evaluate_alerts\]/ {  print >> "v4_evaluate_alerts.txt"
                                           if ( $0 ~ /\.put/ ) {create_evaluate_alerts++
                                                               _word_cnt = 40
                                                               while (_word_cnt <= $NF)  { if ($(_word_cnt) ~ /Args\:/) { print EVM_Server_name ,string_to_date($3),"put",$(_word_cnt + 3) >> "V4_Alert_Info.csv"
                                                                                                                        _word_cnt  = $NF + 1
                                                                                                                        next
                                                                                                                       }
                                                                                          _word_cnt++
                                                                                          #print _word_cnt, "put", $NF $0
                                                                                          }
                                                               }  
                                           if ( $0 ~ /\.get/ ) {process_evaluate_alerts++
                                                               _word_cnt = 40                                                               
                                                               while (_word_cnt <= $NF)  { if ($(_word_cnt) ~ /Args\:/) { print EVM_Server_name ,string_to_date($3),"get",$(_word_cnt + 3) >> "V4_Alert_Info.csv"
                                                                                                                        _word_cnt  = $NF + 1
                                                                                                                        next
                                                                                                                       }
                                                                                          _word_cnt++
                                                                                          #print _word_cnt, "get",$NF , $0
                                                                                          }
                                                               }
                                           } 
/OpsSettings\.settings_update/ {
                                print  >> "V4_EVM_Roles_actions.txt"      #trying to capture all of the configuration changes 
                                }   
                                
/Configuration\.create_or_update/ {
                                print  >> "V4_EVM_Roles_actions.txt"      #trying to capture all of the configuration changes 
                                }                                  
                                                                    
/\.(activate|deactivate)/ {                                               #trying to capture all of the roles changes expressed into the log
                           print  >> "V4_EVM_Roles_actions.txt"
                           } 
/MiqServer\.log_role_changes/ {                                               #trying to capture all of the roles changes expressed into the log
                           print  >> "V4_EVM_Roles_actions.txt"
                           }  
                           
/_master_/ {                                               #trying to capture all of the roles changes expressed into the log
                           print  >> "V4_EVM_Roles_actions.txt"
                           }    
/MiqServer\: / {                                               #trying to capture all of the roles changes expressed into the log
                           print  >> "V4_EVM_Roles_actions.txt"
#[----] I, [2013-02-20T02:45:54.147826 #2859:15595f83a144]  INFO -- : MiqServer: local=Y, master=Y, status= started, id=00001, pid=02859, guid=dd51a8d2-7b05-11e2-a866-0050569101b4, name=EVM, zone=default, hostname=tomhennessy-pc.manageiq.com, ipaddress=192.168.253.122, version=4.0.1.56, build=41851, active roles=dbops:dbowner:event:reporting:scheduler:smartstate:smartstate_drift:userinterface:vcenter:vcrefresh:webservices
#Default split
#  $1   $2              $3              $4                    $5   $6 $7 $8         $9       $10          $11   $12       $13         $14     $15                                        $16           $17       $18                                           $19                      $20           $21         $22   $23
#split-by-comma
#    $1   |                       $2                                                      | $3     |  $4            |   $5     | $6       | $7                                       | $8      |     $9      | $10                                |  $11                      | $12            |  $13        | $14
# because some of the values may be created with embedded blanks, it is more certain to split the line using the comma instead of blanks, so I'm creating two sets
# of working "parse fields"- the default field count by $# and a second where the log line is parsed by "," to provide more certaintly
# in catching servername for target appliances and zone name for target appliance, each of which could contain blanks
                          #print $0
                          #print $9
                          
                          z0 = split($0,comma_parsed_line,",")        # log line parsed by commas insted of blanks
                          z00=gsub(/,/,"")
                          #print $0
                          z=split($9, local_array,"=")  # strip out trailing comma then split into array
                          #print "count of elements is=" z
                          local_value = local_array[z]
                          #print "$9 = " $9 " local_array["z"]="local_value
                          #print $0
                          z=split($10 ,master_array,"=")
                          master_value = master_array[z]
                          
                          status_value = $12
                          
                          z=split($13,applianceid_array,"=")
                          applianceid_value = """" applianceid_array[z] """"
                          
                          z=split($14,pid_array,"=")
                          pid_value = pid_array[z]
                          
                          z=split($15, guid_array, "=")
                          guid_value = """" guid_array[z] """"
                          
                          z=split(comma_parsed_line[12], version_array, "=")     # get version string as offset from last field
                          version_value = version_array[z]
                          
                          z=split(comma_parsed_line[13], build_array, "=")     # get build string as offset from last field
                          build_value = build_array[z]
                                                    
                          z=split(comma_parsed_line[11], ipaddress_array, "=")     # get ipaddress string as offset from last field
                          ipaddress_value = ipaddress_array[z]
                          
                          z=split(comma_parsed_line[10], hostname_array, "=")     # get nostname string as offset from last field
                          hostname_value = hostname_array[z] 
                          
                          z=split(comma_parsed_line[9], zone_array, "=")     # get version string as offset from last field
                          zone_value = zone_array[z] 
                          
                          z=split(comma_parsed_line[8], appliancename_array, "=" )  
                          appliancename_value = appliancename_array[2]
                          
                          z=split($NF,roles_array0,"=")
                          z=split(roles_array0[z],roles_array,":")
                          roles_count = z
#                                                         print "roles_count = " roles_count               #DEBUGGING                          
                          for ( roles in roles_array ) { 
#                                                         print roles                                     #DEBUGGING
#                                                         print roles_array[roles]                        #DEBUGGING
                                                        if ( roles_array[roles] in V4_roles_array) { 
                                                                                                    #print "role '" roles_array[roles] "'found in V4_roles_array"  #DEBUGGING
                                                                                                     V4_roles_array[roles_array[roles]] = 1 
                                                                                                     } 
                                                        else { formated_string = """" roles_array[roles] """"
                                                               print "Unrecognized role => '"  formated_string "', " $0
#                                                               exit                                       #DEBUGGING
                                                               if ( V4_roles_array["unknown"] = "" ) { V4_roles_array["unknown"] = 1 }
                                                               else {++V4_roles_array["unknown"]  }
                                                              }                                
                                                        }
#                         SINCE I am not sure when of if the roles_array is reset, I do it manually here
                          for ( roles in roles_array) { delete roles_array[roles] }                                                        
                          
#                          active_role_string=V4_roles_array["alert_processor"],V4_roles_array["automate"],V4_roles_array["dbops"],V4_roles_array["dbowner"],V4_roles_array["event"],V4_roles_array["performancecollector"],V4_roles_array["performancecoordinator"],V4_roles_array["performanceprocessor"],V4_roles_array["reporting"],V4_roles_array["scheduler"],V4_roles_array["smartproxy"],V4_roles_array["smartstate"],V4_roles_array["smartstate_drift"],V4_roles_array["smirefresh"],V4_roles_array["userinterface"],V4_roles_array["vcenter"],V4_roles_array["vcrefresh"],V4_roles_array["webservices"]
                                                                       
                          preamble_string = EVM_Server_name","string_to_date($3)","$4","local_value","master_value","status_value","applianceid_value","pid_value","guid_value","appliancename_value","zone_value","hostname_value","build_value","version_value","ipaddress_value","roles_count
                          print preamble_string,V4_roles_array["alert_processor"],V4_roles_array["automate"],V4_roles_array["dbops"],V4_roles_array["dbowner"],V4_roles_array["dbsync"],V4_roles_array["database_synchronization"],V4_roles_array["event"],V4_roles_array["performancecollector"],V4_roles_array["performancecoordinator"],V4_roles_array["performanceprocessor"],V4_roles_array["reporting"],V4_roles_array["scheduler"],V4_roles_array["smartproxy"],V4_roles_array["smartstate"],V4_roles_array["smartstate_drift"],V4_roles_array["smirefresh"],V4_roles_array["userinterface"],V4_roles_array["vcenter"],V4_roles_array["vcrefresh"],V4_roles_array["webservices"],V4_roles_array["ems_operations"],V4_roles_array["user_interface"],V4_roles_array["web_services"],V4_roles_array["database_operations"],V4_roles_array["database_owner"],V4_roles_array["ems_inventory"],V4_roles_array["ems_metrics_coordinator"],V4_roles_array["ems_metrics_processor"],V4_roles_array["ems_metrics_collector"],V4_roles_array["ldap_synchronization"],V4_roles_array["notifier"],V4_roles_array["storage_inventory"],V4_roles_array["storage_metrics_collector"],V4_roles_array["storage_metrics_coordinator"],V4_roles_array["storage_metrics_processor"],V4_roles_array["vmdb_storage_bridge"],V4_roles_array["vdi_inventory"],V4_roles_array["rhn_mirror"],V4_roles_array["unknown"] >> "V4_EVM_appliance_active_roles.csv"
#                          exit                                                                             #DEBUGGING
                           for (roles in V4_roles_array) { V4_roles_array[roles] = ""}    # after line is processed - clear out counter array
                           }                                                    
                                                   
/Address already in use/ { print >> "---Critical Error.txt"}         # rare but critical issue - Vim Broker bind port in use=>> no broker!!!        
/MIQ\(Schedule\./ { print >> "V4_Schedule_actions.txt"}   
/\[MiqSchedule\./ { print >> "V4_Schedule_actions.txt"}
/OpsSettings\.schedule_edit/  { print >> "V4_Schedule_actions.txt"}    

                                                                                          
/Event Raised \[vm_scan_start\]/       {vm_scan_start_count++
                                        vm_scan_active_count++
                                        if (vm_scan_active_count > vm_scan_max_active) {vm_scan_max_active = vm_scan_active_count}
                                        }
                                        
/Event Raised \[vm_scan_(complete|abort)\]/ {vm_scan_complete_count++
                                     vm_scan_active_count--
                                     }
/queue_email/ {
                print  >> "Queued_email.txt" 
                } 
                
# [----] I, [2013-05-29T11:48:33.606174 #10388:3b30800]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (10128)] Job count for state=["waiting_to_start"] by zone and process_type: {"default"=>{"VmScan"=>168}}
#    1   2                  3                4             5   6 7             8                   9                          10    11       12   13   14   15              16           17   18  19      20        21
# [----] I, [2013-05-29T11:53:31.104311 #10388:3b30800]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (10128)] MiqQueue count for state=["dequeue"] by zone and role: {"default"=>{nil=>1, "smartproxy"=>2, "smartstate"=>1, "ems_operations"=>2}} 
#    1   2                  3                4             5   6 7             8                   9                              10        11     12        13  14      15           16  17   18  19    20
# ----] I, [2013-05-31T05:20:05.084677 #17059:156e7fbae138]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (3925)] MiqQueue count for state=["ready"] by zone and role: {"EMEA WebUI"=>{nil=>24, "smartstate"=>1}, "default"=>{nil=>9, "smartstate"=>1}, "EMEA WORKER1"=>{"performanceprocessor"=>3, nil=>224, "vcrefresh"=>1, "event"=>9108282, "performancecollector"=>700, "smartstate"=>1}, "EMEA WORKER2"=>{nil=>2693, "vcrefresh"=>1, "event"=>7101923, "performancecollector"=>1238}, nil=>{nil=>1}, "EMEA-DB"=>{nil=>8, "smartstate"=>1}} 
 /count for state/ { #print
                     type = $13 # either "JOB" or "MiqQueue"
                     state_literal = $16
                     state_literal_begin = index(state_literal, "=")
#                    print "state_literal_begin =" state_literal_begin
                     if (state_literal_begin == 0) { #print " state literal begin not found, skipping to next line" 
                                                    next
                                                    }   
                     state_literal = substr(state_literal,state_literal_begin +1 + length("="), length(state_literal) - state_literal_begin - 2 )
                     if ( $0 ~ /by zone and role/) {zone_and_role_begin = index( $0 , " role: {") + 8 }  
                     if ($0 ~ /by zone and process_type/ ) { zone_and_role_begin = index( $0 , "type: {") + 7 } 
#                    zone_and_role_begin = index( $0, " role:" )          begin first zone
#                    print $0
#                    print "zone_and_role_begin = " zone_and_role_begin
                     if (zone_and_role_begin == 0) { #print " zone and role begin not found, skipping to next line"
                                                   next
                                                   }
                     zone_and_role_string = substr($0, zone_and_role_begin )
                     zone_count = split(zone_and_role_string,zone_array,"}, ")
                     for (zone in zone_array ) {
                                                zone_string_end = index( zone_array[zone], "=>{" )
                                                zone_string = substr(zone_array[zone], 1, zone_string_end -1 )
#                                                gsub(/\s/,"",zone_string)
                                                if ( zone_string ~ /^\s/ ) { print "'"zone_string"'"
                                                                             zone_string = substr(zone_string,2)}    # remove leading space from zone name
                                                role_string = substr(zone_array[zone], zone_string_end + 3 )
                                                role_count = split( role_string,role_array, " ")
                                                for (role in role_array)  {
                                                                           role_item_count = split(role_array[role], role_item_element, "=>")
                                                                           gsub(/\}/,"",role_item_element[2])
                                                                           gsub(/,/,"",role_item_element[2])
# "EVM Server Name,log date time,msg state,zone,zone count,role name,count" > "V4_Queue_counts_by_state_and_role.csv"                                                                           
                                                                           print EVM_Server_name,string_to_date($3),type,state_literal,zone_string,zone_count,role_item_element[1],role_item_element[2]    >> "V4_Queue_counts_by_state_and_role.csv"
                                                                           }
                                                delete zone_array[zone]
                                                }
                     zone_count = 0
                     type = ""
                     state_literal = ""
                     zone_and_role_string = ""                           
                     next                           
                    }
# Intent here is to capute all q-task_id log lines and examine for detailed separation
# "job_dispatch" can contain scan jobs, so they have to be examined closely and perhaps to into two different files
#  otherwise "job _dispatch" log lines can be disguarded although they can and do show up in other contexts so that is handled elsewhere
/Q-task_id/ {   if ($8 ~ /job_dispatch/) { 
                                           if ( $0 ~ /{job\: |Job )/) { print >> "q_task_keeper_lines" }
                                          next }
                   if ($8 ~ /log_status/) { 
                                            if ( $0 ~ /MiqWorker/ ) {print >> "MiqWorker_log_status.txt" ; next}
                                            if ( $0 ~ /MiqServer/ ) { print >> "MiqServer_log_status.txt" 
#[----] I, [2014-04-10T07:42:25.919063 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] Disk Usage:
#  $1  $2   $3                            $4          $5  $6 $7         $8                                  $9           $10  $11     $12    $13   $14
#[----] I, [2014-04-10T07:42:25.919346 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] Filesystem     Type        Total         Used    Available        %Used       iTotal        iUsed        iFree       %iUsed   Mounted on
#[----] I, [2014-04-10T07:42:25.930442 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] /dev/mapper/VGCFME-LVOS   ext4       9.8 GB       1.9 GB       7.5 GB          21%       655360        89918       565442          14%            /
#                                                                                                                                                  $13                  $14       $15 $16      $17 $18      $19 $20         $21         $22          $23          $24           $25           $26
#[----] I, [2014-04-10T07:42:25.932006 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] tmpfs         tmpfs       2.9 GB      0 Bytes       2.9 GB           0%       748869            1       748868           1%     /dev/shm
#[----] I, [2014-04-10T07:42:25.933691 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] /dev/vda1      ext4     503.9 MB      64.6 MB     413.8 MB          14%        32768           45        32723           1%        /boot
#[----] I, [2014-04-10T07:42:25.936072 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] /dev/mapper/VGCFME-LVRepo   ext4       9.8 GB     150.5 MB       9.2 GB           2%       655360           11       655349           1%        /repo
#[----] I, [2014-04-10T07:42:25.937771 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] /dev/mapper/VGCFME-LVLog   ext4       9.8 GB     344.3 MB         9 GB           4%       655360          200       655160           1% /var/www/miq/vmdb/log
#[----] I, [2014-04-10T07:42:25.939451 #6329:aa4808]  INFO -- : Q-task_id([log_status]) MIQ(MiqServer.log_system_status) [EVM Server (7022)] /dev/mapper/vg_data-lv_pg   ext4      98.4 GB      70.2 GB      23.2 GB          76%      6553600         3267      6550333           1% /opt/rh/postgresql92/root/var/lib/pgsql/data                                            
                                                             if ($13 == "tmpfs" ) {capture_filesystem_info() ; next} 
                                                             if ($13 ~ /^\/dev/ )   {capture_filesystem_info() ; next}                                      

                                          
                                            
                                            
                                                  next } 
                                            next
                                            }
                   if  ($8 ~ /(request|task|provision|service|automat)/ ) { 
#                                                                           if( $0 !~ /\.deliver/) {
                                                                            print >>"q_task_keeper_lines" }   
#                                                                                                   }
     
             }


/ \: MIQ\(MiqQueue\.(put|get)/  {
                              if ( $0 ~ /Task id\: \[job_dispatcher\]/) {next}  
                              if ( $0 ~ /Task id\: \[\]/) {next}
                              if ($0 ~  /(job_dispatcher|log_status)/) {
                                                                         if ( $0 ~ /[Jj]ob/) { print >> "q_task_keeper_lines" }
                                                                        next}
                              if ( $0 ~ /request|task|provisiion|service|automat/)  {
                                                                                    print >> "q_task_keeper_lines"
                                                                                    }
#                              if ( $0 ~ /Task id\: \[\]/) {next} 
                              else if ($0 ~ /Task id\: \[job_dispatcher\]/) {next}                                                                                   
                                   else 
                                        print >> "q_task_keeper_lines"
                              }
 #[----] I, [2013-07-24T12:30:39.346331 #15403:8b18994]  INFO -- : Q-task_id([miq_provision_1000000000464]) MIQ(MiqProvisionVmware.execute_queue) Queuing VM Provisioning: [Provision from [demouser-Win2K8R2-x64.Template] to [demouser-EIP_VIM_Fix008]]...
 # $1    $2                  $3                $4         $5  $6 $7       $8                                       $9                              $10    $11  $12                                                                         $NF
/Queuing VM Provisioning/ {                                                                         #Capture V5 provisioning request with template and target names
                           print >> "Creating_provision_instances_for_request.txt"
                                            vm_name_temp = substr($NF,2,length($NF)- (length("]]...") +1) )       # capture target vm name
#                                            print vm_name_temp >> "provision_detail_tracking.cmd"
                                            array_count = split($8, full_request_name, "_" )           # extract request id   
                                            provision_request_temp = substr(full_request_name[array_count],1,length(full_request_name[array_count])-2)
#                                            print provision_request_temp >> "provision_detail_tracking.cmd"
                                            print "call chase_provision_details " vm_name_temp " " provision_request_temp >>  "provision_detail_tracking.cmd"                            
                           next
                           }                    
#[----] I, [2013-07-24T12:30:44.275807 #27117:1c7c800]  INFO -- : Q-task_id([miq_provision_request_1000000000277]) MIQ(MiqQueue.put)        Message id: [1000120936190],  id: [], Zone: [Worker Zone1], Role: [automate], Server: [], Ident: [generic], Target id: [], Instance id: [], Task id: [miq_provision_1000000000468], Command: [MiqAeEngine.deliver], Timeout: [600], Priority: [100], State: [ready], Deliver On: [], Data: [], Args: [{:object_type=>"MiqProvisionVmware", :object_id=>1000000000468, :attrs=>{"request"=>"vm_provision"}, :instance_name=>"AUTOMATION", :user_id=>1000000000058}]                     
#   $1  $2               $3                  $4          $5  $6 $7                  $8                                  $9                     $10             $11
/Q-task_id\(\[miq_provision_request_/    {    if($0 ~ /vm_provision/) {      # only process log lines with  the provision_request-to-provision transition
                                              provision_request_id = substr($8,12,length($8)-11-2)       #capture the provision request id 
                                              cnt_ = split($0,fragments, ",")         # break log line into comma separated fragments and find the Task Id
                                              
#                                              print provision_request_id   >>  "chase_provision_requests.cmd"
                                              for (element in fragments) { #print fragments[element] >> "chase_provision_requests.cmd" 
                                                                          if (  fragments[element] ~ /Task id\: \[/ ) { 
                                                                                                           offset_length = length("Task id: [")
                                                                                                           provision_id = substr(fragments[element],offset_length + 2,length(fragments[element]) - 2 - offset_length)
#                                                                                                           print "request id => " provision_request_id "  provision id => " provision_id    >>  "chase_provision_requests.cmd"
                                                                                                           print "call chase_provision_id " provision_request_id " " provision_id >>  "chase_provision_requests.cmd"
                                                                                                           }
                                                                         }              
                                            }}
                    
                    
/Creating provision instances for request/ {                                                          # capture V4 provisioning request with template request name and target name
                                            print >> "Creating_provision_instances_for_request.txt"
# Sample                                             
#[----] I, [2013-07-11T15:22:40.504937 #22323:15c3be69c138]  INFO -- : Q-task_id([miq_provision_request_4000000000223]) MIQ(MiqProvisionRequest.create_provision_instances) Creating provision instances for request: [Provision from [Linux_CentOS63app_v2_gold] to [comtftp-ch2-a1p]]...
   $1   $2       $3                       $4                  $5  $6 $7            $8                                                                                                                                                                                       $NF
                                            vm_name_temp = substr($NF,2,length($NF)- (length("]]...") +1) )       # capture target vm name
#                                            print vm_name_temp >> "provision_detail_tracking.cmd"
                                            array_count = split($8, full_request_name, "_" )           # extract request id   
                                            provision_request_temp = substr(full_request_name[array_count],1,length(full_request_name[array_count])-2)
#                                            print provision_request_temp >> "provision_detail_tracking.cmd"
                                            print "call chase_provision_details " vm_name_temp " " provision_request_temp >>  "provision_detail_tracking.cmd"                       
                                            next                                                       # no more processing needed
                                            }  
 
/Current database bloat data/ {    observation_date_time = string_to_date($3)  
                                   #print
                                   getline    #advance to line of titles
                                   gsub(/\|/,",",$0)                    # convert all vertical bars to commas
                                   bloat_titles = $0                          # get title line                                   
                                   #print bloat_titles
                                   if (bloat_data_count == 0 ) {print "CFME server name,Observation date-time," bloat_titles > "v4_vmdb_table_bloat_info.csv"
                                                                bloat_data_count += 1
                                                                 }
                                   getline    #advance to line of all separater characters
                                   while (getline > 0) { 
                                                        if (/^\-/) {#print "skipping separator line"
                                                                    next
                                                                    }
                                                        if (/^\s/) {#print "end of bloat data"
                                                                    next
                                                                    }                                                                    
                                                        if (/^$/) {#print "end of bloat data"
                                                                    next 
                                                                    }                                                                                
                                                         gsub(/\|/,",")           
                                                        bloat_data_values =  $0
                                                        print EVM_Server_name,observation_date_time,bloat_data_values  >> "v4_vmdb_table_bloat_info.csv"
                                                        bloat_data_count += 1
                                                       
                                                        }
                                } 


/Current table statistics data/ {    observation_date_time = string_to_date($3)  
                                   #print
                                   getline    #advance to line of titles
                                   gsub(/\|/,",",$0)                    # convert all vertical bars to commas
                                   table_statistics_titles = $0                          # get title line                                   
                                   #print bloat_titles
                                   if ( table_statistics_data_count == 0 ) {print "CFME server name,Observation date-time," table_statistics_titles > "v4_vmdb_table_statistics_data.csv"
                                                                table_statistics_data_count += 1
                                                                 }
                                   getline    #advance to line of all separater characters
                                   while (getline > 0) { 
                                                        if (/^\-/) {#print "skipping separator line"
                                                                    next
                                                                    }
                                                        if (/^\s/) {#print "end of bloat data"
                                                                    next
                                                                    }                                                                    
                                                        if (/^$/) {#print "end of bloat data"
                                                                    next 
                                                                    }                                                                                
                                                         gsub(/\|/,",")           
                                                        statistics_data_values =  $0
                                                        print EVM_Server_name,observation_date_time,statistics_data_values  >> "v4_vmdb_table_statistics_data.csv"
                                                        table_statistics_data_count += 1
                                                       
                                                        }
                                } 

 # Current table size data
 
/Current table size data/ {    observation_date_time = string_to_date($3)  
                                   #print
                                   getline    #advance to line of titles
                                   gsub(/\|/,",",$0)                    # convert all vertical bars to commas
                                   table_size_titles = $0                          # get title line                                   
                                   #print bloat_titles
                                   if ( table_size_data_count == 0 ) {print "CFME server name,Observation date-time," table_size_titles > "v4_vmdb_table_size_data.csv"
                                                                table_size_data_count += 1
                                                                 }
                                   getline    #advance to line of all separater characters
                                   while (getline > 0) { 
                                                        if (/^\-/) {#print "skipping separator line"
                                                                    next
                                                                    }
                                                        if (/^\s/) {#print "end of bloat data"
                                                                    next
                                                                    }                                                                    
                                                        if (/^$/) {#print "end of bloat data"
                                                                    next 
                                                                    }                                                                                
                                                         gsub(/\|/,",")           
                                                        table_size_data_values =  $0
                                                        print EVM_Server_name,observation_date_time,table_size_data_values  >> "v4_vmdb_table_size_data.csv"
                                                        table_statistics_data_count += 1
                                                       
                                                        }
                                }  
 
 
 
#[----] I, [2014-02-21T03:24:31.854926 #1965:7c2810]  INFO -- : MIQ(DbConfig.log_activity_statistics) <<-ACTIVITY_STATS_CSV
#session_id,xact_start,last_request_start_time,command,task_state,login,application,request_id,net_address,host_name,client_port,wait_time_ms,blocked_by
                                
/\-ACTIVITY_STATS_CSV$/  { observation_date_time = string_to_date($3)
                              #print
                              getline    #advance to line of titles
                              activity_statistics_titles = $0       # get title lines
                              if (postgresql_activity_stats == 0 ) {  #print
                                                                    postgresql_activity_stats += 1
                                                                    print "CFME server name, Observation date-time," activity_statistics_titles > "v4_postgresql_activity_stats.csv"
                                                                    #last_log_line_data = "CFME server name,Observation date-time," activity_statistics_titles
                                                                    last_log_line_data = ""
                                                                    #print last_log_line_data
                                                                    }
                              getline last_log_line_data            # prime last_log_line_data with first line of query info                                      
                              while ( $1 != "ACTIVITY_STATS_CSV" ) {getline                               # advance to next log line
                               #print "value of $1 is '" $1 "''"
                              if ($1 == "ACTIVITY_STATS_CSV")   { print EVM_Server_name,observation_date_time,last_log_line_data >> "v4_postgresql_activity_stats.csv"  #flush last log line of data
                                                                   next
                                                                }
                              if ( last_log_line_data ~ /,$/) {  
                                                  # if (last_log_line_data == "") {last_log_line_data = $0}
                                                    print EVM_Server_name,observation_date_time,last_log_line_data >> "v4_postgresql_activity_stats.csv"  
                                                    postgresql_activity_stats += 1
                                                    last_log_line_data = $0                                # set $0 as the beginning of next sql query
                                                   }
                                   else { last_log_line_data =last_log_line_data $0                              # append input line to last full good query
                                        }      
                                                                  }
                               next                                                                                                        
                             }
                                                                                                                                                                                                                                                                                                                         
END {OFS = ","
            # need to format the current date time into displayable date time
            datehour_display = substr(datehour,7,2) "/" substr(datehour,10,2) "/" substr(datehour,2,4) " " substr(datehour,13,3) ":00:00" ; # print datehour_display
            print EVM_Server_name , datehour_display, errors, warnings,info, debug,  server_start,workermonitor_starts,worker_start,workers_killed,has_not_responded,garbage_collection_count,sprintf("%.0f",garbage_collection_max_time),broker_not_available,vim_failed_to_create_new_connection_count,ems_refresh,full_vc_refreshes_started,full_vc_refreshes_ended,max_VC_refresh_time,max_all_target_refresh_time,VC_id,db_errors,refresh_timeouts,vcid_last_refresh_started,vm_collections,vm_gt_600,Vm_CnU_misses,host_collections,host_gt_600,Host_CnU_misses,storage_collections,storage_gt_600,events_caught,events_queued,performance_purges_ended,performance_instances_deleted,evm_events,evm_alerts,create_evaluate_alerts,process_evaluate_alerts
            for (item in VM) {print EVM_Server_name,datehour_display,item,VM[item]  >>   "V4 Hourly VM Perf_capture Counts by Duration.csv"
                  delete VM[item]
                  close("V4 Hourly VM Perf_capture Counts by Duration.csv") }
            for (item in Host) {print EVM_Server_name,datehour_display,item,Host[item] >> "V4 Hourly Host Perf_capture Counts by Duration.csv"
                  delete Host[item]
                  close("V4 Hourly Host Perf_capture Counts by Duration.csv")}
            for (item in Storage) {print EVM_Server_name,datehour_display,item,Storage[item] >> "V4 Hourly Storage Perf_capture Counts by Duration.csv"
                  delete Storage[item]
                  close("V4 Hourly Storage Perf_capture Counts by Duration.csv")}
            close("V4 Purged  Performances.csv")                                    # close performance purge  detail file
            close("V4 VC Refresh Timings.csv")                                      # close VC refresh timings    
            close("V4_vm_perf_capture_dequeue_times.csv")                              # close VM_perf_capture wiat times file
            close("V4_Performance_Rows_Captured.csv")                                #close performance rows count file
            close("V4_miqlicense.txt")                                               #close license text file
            close("V4_evaluate_alerts.txt") 
            close("V4_EVM_alerts_raised.txt")
            close("V4_EVM_event_raised.txt" )
            close("V4_EVM_Roles_actions.txt")
            close("V4_Vm_Scan_Activity.csv")
            close("V4_EVM_appliance_active_roles.csv")
            close("Queued_email.txt")
            close("V4_Queue_counts_by_state_and_role.csv")
            close("provision_detail_tracking.cmd")
            close("Creating_provision_instances_for_request.txt")
            close("chase_provision_requests.cmd")
            close("q-task_keeper_lines")
            close("MiqWorker_log_status.txt")
            close("MiqServer_log_status.txt")
            close("Filesystems_usage_info.csv")
            close("v4_postgresql_activity_stats.csv")
            close("v4_vmdb_table_bloat_info.csv")
            close("v4_vmdb_table_statistics_data.csv")
            close("v4_vmdb_table_size_data.csv")
    }