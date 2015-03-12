BEGIN {
       }
/EmsRefresh\.refresh/ { if ( $0 ~ /\.get/) {
                                            # print
                                            arg_string = substr($0 , index($0, "Args: ") + 6)  
                                            element_count = gsub(/\,/,",",arg_string) / 2 
                                            print $11 $(NF-1)",element count is " element_count
                                            }
                       }                                                            
       
END {
     }       
