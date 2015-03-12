BEGIN{
print "record id" > "distilled_db_record_ids.csv"
     }
     
{ if (length($0) == 0) {
                      _record_id = ""
                      next
                      }
else if (_record_id == $1) { next}
else if ($1 == "large") {
                      _record_id = ""
                      next
                      }
else if (_record_id != $1) { print sprintf("%d", $1) >> "distilled_db_record_ids.csv"     
                              _record_id = $1
                           }                                                
}                      

 
END{}
