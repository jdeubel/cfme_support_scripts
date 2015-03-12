

BEGIN {}
#[yyyy-mm-ddThh:mm:ss.tttttt]
/\[/ { _logtime = substr($3,2,20)        
 #      sub("\[","",_logtime)
       gsub("-"," ",_logtime)
       sub("T"," ",_logtime)
       gsub(":"," ",_logtime)
       _time_value = mktime(_logtime)
       print "input = " _logtime " mktime output is "   _time_value
       }
