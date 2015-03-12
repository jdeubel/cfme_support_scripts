BEGIN{

     }
     
{ if (length($0) == 0) {
                      next
                      }}
/server guid/  { if (NR == 1) {print > "filtered_combined_evm_msg_info.csv"
                               next
                               }
else {next}}
                       
 {print >> "filtered_combined_evm_msg_info.csv"}                                      
END{
    close("filtered_combined_evm_msg_info.csv")
   }
