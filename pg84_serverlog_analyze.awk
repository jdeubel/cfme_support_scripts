BEGIN {OFS = ","
    # create serverlog_diagnostic directory if one doesn't already exist
    if (system("mkdir serverlog_diagnostics") != 0) {print "directory \"serverlog_diagnostics\" already exists, not created"}
    
vacuum_table_name = ""
vacuum_index_scans = 0
vacuum_pages_removed = 0
vacuum_pages_remain = 0
vacuum_tuples_removed = 0
vacuum_tuples_remain = 0
vacuum_elapsed_time_seconds = 0
_lock_type = ""
log_date = ""
log_time = ""
log_source = ""
print "type,date,time,source,table name,elapsed time (seconds),tuples removed,tuples remaining,pages removed,pages remaining" > "serverlog_diagnostics\\automatic_statistics.csv"
print "date,time,source,duration (ms),query verb,query_first_part" > "serverlog_diagnostics\\simple_query.csv"
print "date,time,source,duration (ms),process,lock type,lock status,transaction/tuple,statement" > "serverlog_diagnostics\\lock_activity.csv"
print "date,time,source,time zone,ip address,port,session id,user@db,local process id" > "serverlog_diagnostics\\worker_terminations.csv" # workers being recycled
print "" > "fatal-detail-error-hint.txt"
       }
function insert(in_string,insert_position,insert_string) {
                                                          before_tmp = substr(in_string,1,insert_position)
                                                          after_tmp = substr(in_string,insert_position+1)
                                                          return  before_tmp insert_string after_tmp
                                                          }       
        
$0 ~ /\:LOG\:  duration\:/ {_log_line = $0
                             _statement = substr(_log_line,index(_log_line,"statement:")+length("statement:"))
                             if (length(_statement) > 254) {_statement = substr(_statement,1,254)}
                             gsub(/\"/,"'",_statement)
                             print $1,$2,$3,$5,$8,"\""_statement"\"" >> "serverlog_diagnostics\\simple_query.csv"
                             }
#2011-03-20 15:25:35 GMT:165.222.71.32(53832):root@vmdb_production:[26932]:LOG:  process 26932 still waiting for ShareLock on transaction 1189510228 after 5001.757 ms
#2011-03-20 15:25:35 GMT:165.222.71.33(35129):root@vmdb_production:[26962]:LOG:  process 26962 still waiting for ExclusiveLock on tuple (1005,31) of relation 838776 of database 838417 after 5001.666 ms 
#2011-03-20 15:25:36 GMT:165.222.71.32(40984):root@vmdb_production:[27065]:LOG:  process 27065 acquired ExclusiveLock on tuple (1039,69) of relation 838776 of database 838417 after 5851.573 ms 

#2011-03-20 15:25:35 GMT:165.222.71.32(53832):root@vmdb_production:[26932]:STATEMENT:                UPDATE "miq_queue"                              
/\:LOG\:  process / { if ($0 ~ /still waiting/) {_lock_type =  $9
                                                if (_lock_type == "AccessShareLock") {_duration = $(NF-4)} else {_duration = $(NF-1)}
                                                _process = $5
                                                _wait_target = "\""$12"\"" 
                                                if (index(_wait_target,",") > 0) { _wait_target = insert(_wait_target,index(_wait_target,",")," ")}
                                                _lock_status = $7 
                                                }
                      if ($0 ~ /acquired/) {_lock_type = $7
                                            if (_lock_type == "AccessShareLock") {_duration = $(NF-4)} else {_duration = $(NF-1)}
                                            _process = $5
                                           # _duration = $(NF-1)
                                            _wait_target = "\""$10"\""                                            
                                            if (index(_wait_target,",") > 0) { _wait_target = insert(_wait_target,index(_wait_target,",")," ")}
                                            _lock_status = $6
                                            }
                    }
/\:LOG\:  received/ { print >> "serverlog_diagnostics\\fatal-detail-error-hint.txt"}                                           

/\:STATEMENT\:/ { if (_lock_type == "") {next} # if _lock_type is empty then skip this line  
                  else {_statement = substr($0,index($0,":STATEMENT:") + length(":STATEMENT:"),100)
                   gsub(/\"/,"'",_statement)
                    #print $0 >> "serverlog_diagnostics\\lock_activity.csv"
                    #print _statement >> "lock_activity.csv"
                   
                   _element_cnt = split(_statement,_statement_array," ")
                    #print "_statement_array element count = "_element_cnt   >> "serverlog_diagnostics\\lock_activity.csv"
                   _trimmed_statement = ""
                   for (_index = 1;_index <= _element_cnt;_index++) {_trimmed_statement = _trimmed_statement" "_statement_array[_index]
                                                    #print _trimmed_statement   >> "serverlog_diagnostics\\lock_activity.csv"
                                                    }
                   print   $1,$2,$3,_duration,_process,_lock_type,_lock_status,_wait_target,"\""_trimmed_statement"\"" >> "serverlog_diagnostics\\lock_activity.csv"
                                                    
                   for (item in _statement_array) {delete _statement_array[item] }  # remove all array elements
                   _lock_type = ""
                   
                       } 
                 }                                             

/\:LOG\:  unexpected / { _source_array_cnt = split($3,_source_array,":") 
                         _time_zone = _source_array[1]
                         _ipaddress_port = _source_array[2]
                         gsub(/\(/," ",_ipaddress_port)
                         gsub(/\)/," ",_ipaddress_port)
                         split(_ipaddress_port,_ip_port_array," ")
                         _ipaddress = _ip_port_array[1]
                         _port = _ip_port_array[2] 
                         # print "_ipaddress - "_ipaddress
                         # print "_port - "_port
                         # print "_ipaddress_port-"_ipaddress_port
                         _session_id = _source_array[3]
                         _user_db = _source_array[4]
                         _local_pid = _source_array[5]                      
                        print $1,$2,$3,_time_zone,_ipaddress,_port,_session_id,_user_db,_local_pid >> "serverlog_diagnostics\\worker_terminations.csv" 
                        }

/automatic analyze of table/ {    print $5,$1,$2,$3,$8,$(NF-1) >> "serverlog_diagnostics\\automatic_statistics.csv"
                              }
#2011-03-20 00:33:53 GMT::@:[21922]:LOG:  automatic vacuum of table "vmdb_production.public.hosts": index scans: 0                               
/automatic vacuum of table/  {    log_date = $1
                                  log_time = $2
                                  log_source = $3
                                  gsub(/\:/,"",$8)
                                  log_table = $8
                              }
                              
$1 ~ /pages\:/ { vacuum_pages_removed = $2
                 vacuum_pages_remain = $4
               }   
$1 ~ /tuples\:/ {vacuum_tuples_removed = $2
                vacuum_tuples_remain = $4
                 }                       
$1 ~ /system/ { if (log_source == "" ) {next}
                else vacuum_elapsed_time_seconds = $(NF-1)
               print "vacuum",log_date,log_time,log_source,log_table,vacuum_elapsed_time_seconds,vacuum_tuples_removed,vacuum_tuples_remain,vacuum_pages_removed,vacuum_pages_remain >> "serverlog_diagnostics\\automatic_statistics.csv"
                vacuum_table_name = ""
                vacuum_index_scans = 0
                vacuum_pages_removed = 0
                vacuum_pages_remain = 0
                vacuum_tuples_removed = 0
                vacuum_tuples_remain = 0
                vacuum_elapsed_time_seconds = 0
                log_date = ""
                log_time = ""
                log_source = ""              
               }  
/\:(FATAL|DETAIL|ERROR|WARNING|HINT)\:/ { print >> "serverlog_diagnostics\\fatal-detail-error-hint.txt"}                                       
END {close("serverlog_diagnostics\\simple_query.csv")
     close("serverlog_diagnostics\\automatic_statistics.csv")
     close("serverlog_diagnostics\\lock_activity.csv")
     close("serverlog_diagnostics\\worker_terminations.csv")
     }