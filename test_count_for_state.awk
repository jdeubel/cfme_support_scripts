BEFORE {  
OFS=","
FS=" "          # STANDARD BLANK FOR WORD PARSING
print "HEADER LINE" > "TOMTEST_QUEUE_COUNTS.CSV"
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
                     zone_count = split(zone_and_role_string,zone_array,"},")
                     for (zone in zone_array ) {
                                                zone_string_end = index( zone_array[zone], "=>{" )
                                                zone_string = substr(zone_array[zone], 1, zone_string_end -1 )
                                                gsub(/\s/,"",zone_string)
                                                role_string = substr(zone_array[zone], zone_string_end + 3 )
                                                role_count = split( role_string,role_array, " ")
                                                for (role in role_array)  {
                                                                           role_item_count = split(role_array[role], role_item_element, "=>")
                                                                           gsub(/\}/,"",role_item_element[2])
                                                                           gsub(/,/,"",role_item_element[2])
                                                                           print type,state_literal,zone_count,zone_string,role_item_element[1],role_item_element[2]    >> "TOMTEST_QUEUE_COUNTS.CSV"
                                                                           }
                                                delete zone_array[zone]
                                                }
                     zone_count = 0
                     type = ""
                     state_literal = ""
                     zone_and_role_string = ""                           
                     next                           
                    }

END {    
CLOSE("TOMTEST_QUEUE_COUNTS.CSV")
     }
