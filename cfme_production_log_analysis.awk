BEGIN { FS = " " 
      OFS = ","
      begin_part = ""
      full_log_line = ""
      active_pidTid = ""
      error_lines = "production_error.txt"
      print "">error_lines
      active_error = ""
      log_time = 1
      log_start_time = 1                # log_time and log_start_time are the same data values
      log_complete_time = 14            # log_complete_time added to simplify calculating the elapsed time duration of a UI process
      host_local_time = 2
      cmd = 3
      cmd_text = 4
      ip_address = 5
      log_type = 6
      duration = 7
      status_string = 8
      status_code = 9
      controller_id = 10
      process_as = 11
      parameter = 12
      redirect_to = 13
      active_pidTid = 15
      task_id = 16
      rendered_count = 0
      print "\"start log date time\",\"complete log date time\",\"pid-tid\",\"host local start time\",task_id,command,\"command text\",\"ip address\",\"log type\",duration(ms),\"status string\",\"status code\",\"controller id\",\"process as\",parameter,\"redirect to\""
      print ""  > "browser_info.txt"
      print "browser type,browser version,browser OS,userid,User Time Zone Offset" > "browser_info.csv"
      browser_type = ""
      browser_version = ""
      browser_os = ""
      browser_userid = ""
      browser_timezone_offset = ""
      
      } 
/^[^\[]/ {next }                                  #skip all lines that don't begin with '['      
/^ / { next}                                      # skip all lines that don't begin with standard preamble
/ FATAL / { next }                               # skip all fatal lines
/ WARN / {next }                                 # skip all WARN lines
/^Action/ { next}                                # skip all lines beginning with 'Action'

      
/\-\- \: Connecting/ { next }
/\-\- \: Migrating/ { next }
/\-\- \: CONNECTION RETRY/ {next}

/\-\- \:   Rendered/ { 
                      Transaction_array[$4,rendered_count]++ 
                      next }
/\-\- \: Sent/ {next}
/\-\- \: Started/ { 
#[----] I, [2013-06-20T13:08:07.979431 #6231:82c9ff4]  INFO -- : Started POST "/dashboard/window_sizes?width=1214&height=678&" for 127.0.0.1 at 2013-06-20 09:08:07 -0400
#  $1   $2         $3                       $4          $5  $6 $7  $8      $9       $10                                         $11  $12     $13   $14      $15       $16
                     
                   Transaction_array[$4,active_pidTid] = substr($4,2,length($4)-2)            # get pid_tid string
                   _temp = substr($3,2,19)
                    _x = gsub(/T/," ",_temp)                                                                                            
                   Transaction_array[$4,log_start_time] =   _temp
 #                 print "log_start_time = " _temp
                   Transaction_array[$4,rendered_count] = 0
                   Transaction_array[$4,task_id] = ""
                   Transaction_array[$4,cmd] = $9
                   Transaction_array[$4,cmd_text] = $10
                   Transaction_array[$4,ip_address] = $12
                   Transaction_array[$4,host_local_time] = $14 " " $15
                   Transaction_array[$4,log_type] = $5

                   next
                  }
/^$/               { next }
/browser_/ { print >> "browser_info.txt"
              browser_type = ""
              browser_version = ""
              browser_os = ""
              browser_userid = ""
              browser_timezone_offset = ""
              
#[----] I, [2013-01-22T11:55:03.745405 #16298:8d38800]  INFO -- :   Parameters: {"user_name"=>"admin", "user_password"=>"[FILTERED]", "browser_name"=>"Mozilla", "browser_version"=>"an unknown version", "browser_os"=>"Mac", "user_TZO"=>"5", "_"=>""}
# $1    $2    $3                         $4              $5  $6 $7    $8
#             print "log line=>" $0
             array_cnt = split($0,parsed_log_line,",")                  #parse log line using comma instead of blank

             first_element = parsed_log_line[2]                         # need to get first hash index name
#             print "first_element=>" first_element
             first_element_count = split(first_element,temp_array,"{")  # split first array element using "{"
 #            print "first_array_element =>" temp_array[2]
             parsed_log_line[2] = temp_array[2]                         # the second element of temp_array now has the hash assignment
             for (array_index in parsed_log_line ) { z = split(parsed_log_line[array_index],temp_array, "=>")  # split hash assignment into a two element array
 #                                                   print "parsed_log_line[" array_index "] => " parsed_log_line[array_index]
                                                    cnt = gsub(/\}/,"",temp_array[2]) 
                                                    if (temp_array[1] ~ /user_name/ ) { browser_userid = temp_array[2]}
                                                    if (temp_array[1] ~ /browser_name/ ) {browser_type = temp_array[2]}
                                                    if (temp_array[1] ~ /browser_version/ ) { browser_version = temp_array[2]}
                                                    if (temp_array[1] ~ /browser_os/ ) { browser_os = temp_array[2]}
                                                    if (temp_array[1] ~ /user_TZO/ ) { browser_timezone_offset = temp_array[2]}
#                                                   if (temp_array[1] ~ /task_id/ ) { Transaction_array[$4,task_id] = temp_array[2] }
                                                    }
              print browser_type,browser_version,browser_os,browser_userid,browser_timezone_offset >> "browser_info.csv" 
              for (array_index in parsed_log_line) { delete parsed_log_line[array_index]}  # empty log line array
              for (array_index in temp_array) {delete temp_array[array_index]}             # empty temp_array                                   
#              exit

            }
/(FATAL|ERROR) \-\- \:/ { 
                         Transaction_array[$4,status_string] = $5 "-"
                         active_error = 1
                         print "***">>"production_error.txt"
                         print $0>>"production_error.txt"
                         while (getline > 0) {
                                              if ($0 ~ /^\[\-\-\-\-]/ ) {active_error = " "
                                                                          print "****" >> "production_error.txt"
                                                                          print " ">> "production_error.txt"
                                                                          next
                                                                           }
                                                  print $0>>"production_error.txt"                                           
                                              }
                                              
                         next
                          }
/\-\- \: $/  {
              begin_part = $0
              #print
              Transaction_array[$4] = $4                                 #substr($4,2,length($4)-2)
              active_pidTid = $4                                         # substr($4,2,length($4)-2)
              Transaction_array[$4,log_time] = substr($3,2,10) " " substr($3,13)
              #print "time is = ",Transaction_array[$4,log_time]
              Transaction_array[$4,log_type] = $5
              
              next
             }
/^Start/     { #print
              Transaction_array[active_pidTid, cmd] = $2
              Transaction_array[active_pidTid, cmd_text] = $3
              Transaction_array[active_pidTid, ip_address]  = $5
              Transaction_array[active_pidTid, host_local_time] = "\"" $7 " " $8 " " $9 "\"" 
              #print "active_pidTid = " active_pidTid
              active_pidTid = ""
              full_log_line = begin_part $0
               #print full_log_line
               begin_part = ""
               full_log_line = ""
               next
              }   
/\-\- \: Processing/ {
                      Transaction_array[$4,controller_id] = $10
                      Transaction_array[$4,process_as] = $12
                      next
                     } 
/\-\- \: Redirected/ { Transaction_array[$4,redirect_to] = $(NF)
                       next
                       }                     
/\-\- \:   Parameters/ { x = 9               # positional field value after "Parameters" literal
                         _temp_string = ""
                        while (x <= NF) { _temp_string = _temp_string $(x)
                               #print x, _temp_string
                               x += 1
                               }
                        t = gsub(/"/,"'",_temp_string)    
                        #print _temp_string   
                        Transaction_array[$4,parameter] = "\"" _temp_string "\"" 
                        if (_temp_string ~ /task_id/ ) { begin_position = index(_temp_string, "task_id'=>'") + length("task_id'=>'")    #look for beginning or string
                                                         _temp_string2 = substr(_temp_string,begin_position)
                                                        end_position = index(_temp_string2,"'")                       # look for next single quote
                                                        Transaction_array[$4,task_id] = "\"" substr(_temp_string2,1,end_position -1 ) "\""     # capture & save task_id
                                                                }
                        next }  
                        
# [----] I, [2013-06-20T09:11:00.546215 #6231:82c9ff4]  INFO -- : Completed 200 OK in 141ms (Views: 82.6ms | ActiveRecord: 9.3ms)
#   $1   $2        $3                      $4            $5  $6 $7 $8       $9  $10    $12                             
/\-\- \: Completed/ {   #print $0
                        #print $1, $2, $3, $4
                        #print $4
                      Transaction_array[$4,status_code] = $9
                      Transaction_array[$4,status_string] =  $10
                      Transaction_array[$4,duration] = substr($12,1,length($12)-2)
                      #print "value of $4 is = " $4
                      #print "value of Transaction_array[$4] is " Transaction_array[$4]
                      #print "transaction_array duration=" Transaction_array[$4,duration]                      
                      #exit
                      #print "completion info",Transaction_array[$4],Transaction_array[$4,duration]
                      #for (item in Transaction_array) print item, Transaction_array[item]
                      #exit
                      _temp = substr($3,2,19)                     #capture the log end time
                      _x = gsub(/T/, " ",_temp)
#                     print "log complete time =" _temp
                      Transaction_array[$4,log_complete_time] =     _temp
                      print Transaction_array[$4,log_start_time],
                            Transaction_array[$4,log_complete_time],
                            Transaction_array[$4,active_pidTid],
                            Transaction_array[$4,host_local_time],
                            Transaction_array[$4,task_id],
                            Transaction_array[$4,cmd],
                            Transaction_array[$4,cmd_text],
                            Transaction_array[$4,ip_address],
                            Transaction_array[$4,log_type],
                            Transaction_array[$4,duration],
                            Transaction_array[$4,status_string],
                            Transaction_array[$4,status_code],
                            Transaction_array[$4,controller_id],
                            Transaction_array[$4,process_as],
                            Transaction_array[$4,parameter],
                            Transaction_array[$4,redirect_to]
                            
                            
                     delete Transaction_array[$4,log_time] 
                     delete Transaction_array[$4]
                     delete Transaction_array[$4,host_local_time] 
                     delete Transaction_array[$4,cmd] 
                     delete Transaction_array[$4,cmd_text] 
                     delete Transaction_array[$4,ip_address] 
                     delete Transaction_array[$4,log_type] 
                     delete Transaction_array[$4,duration] 
                     delete Transaction_array[$4,status_string] 
                     delete Transaction_array[$4,status_code] 
                     delete Transaction_array[$4,controller_id] 
                     delete Transaction_array[$4,process_as] 
                     delete Transaction_array[$4,parameter]  
                     delete Transaction_array[$4,redirect_to]                          
                      next
                      
                     } 
/\-\- \: Filter/ { next }    
# filter out less likely but disruptive log lines below
/Sent mail/ {next}
/DEBUG/ {next}
/token authenticity/ {next}    

# if it gets this far, just add it to the output line and I'll deal with it later                                                      
{ print }

END { 
     close("production_error.txt")
     close("browser_info.txt")
     close("browser_info.csv")
     }
