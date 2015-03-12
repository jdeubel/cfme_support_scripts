BEGIN {  

   find_server_name = getline < "last_startup.txt"

    while (find_server_name > 0 )  {  
          if ($0 ~ /Server EVM id and name\:/) {EVM_Server_name  = $NF
                                            print
                                            print "EVM_Server_name =",EVM_Server_name
                                            }
          find_server_name = (getline < "last_startup.txt" )    
          }                        
 }        



end {
  print "lines read =",linecnt
}