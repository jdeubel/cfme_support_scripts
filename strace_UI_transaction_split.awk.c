BEGIN {
transaction = 0
capture_log_lines = 0
output_file = ""

begin_time = ""
close_time = ""
print "transaction, begin time,end time" >  "__transaction_summary_times"
}


/select\(20/ { if ( $0 ~ / \= 1/ ) { 
                               #print "before value of transaction is " transaction
                               ++transaction
                               #print "after increment  value of transaction is " transaction
                               output_file = "transaction_" transaction
                               print > output_file
                               capture_log_lines = 1
                               #print "from select - transaction =" transaction
                               begin_time = $1
                               next
                              }
              }                
#/select\(20\, \[17 19\]\, \[\]\, \[\], \{0\, 90000\}\) \= 1/ { ++transaction
#                                                               print > "transaction_" transaction
#                                                               capture_log_lines = 1
#                                                               print "from select"
#                                                               next
#                                                              }

/close\(20/ { if (  capture_log_lines == 1 ) { 
                print >> output_file
                close(output_file) 
                 capture_log_lines = 0
                 #print "from close"
                 close_time = $1
                 print output_file","begin_time","close_time >> "__transaction_summary_times"
                 close_time = ""
                 begin_time = ""
                 next 
                                             } 
                 }    
                 
 { if (  capture_log_lines == 1 ) { #print  "normal log line ->" $0
                                   print >> output_file 
                                   }
  }       
                          
                                                                          
END {
      close(output_file) 
      }
