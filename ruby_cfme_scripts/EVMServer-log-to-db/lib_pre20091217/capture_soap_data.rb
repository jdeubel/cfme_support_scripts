=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_soap_data.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def capture_soap_data(parsed_log_line)
  if !$SOAP_active then
    $SOAP_data = File.new($diag_dir + '\\' +"Soap_traffic.csv","w")
    $SOAP_active = true
    $SOAP_data.puts "Server Guid, Server host, time-of-day,minute-of-day,IO type,length,PID"
  end
#  puts "#{__FILE__}#{__LINE__}"
  if /length\=(\d{1,12})/ =~ parsed_log_line.payload then
    _t = $1                                       # save value
    _temp1 = parsed_log_line.log_datetime_string.split(":")  # prepare to generate minute based value
    _date_minute = _temp1[0] + ":" + _temp1[1] + ":00"       # truncating seconds to get minute of day
    if /\-\-\-\s*(.*)\s*length/ =~ parsed_log_line.payload then   #don't assume only ": SOAP " log lines are being processed
      _io_type = $1
    else _io_type = ""
    end
    if $Server_GUID.class == "NilClass" then _server_guid = ""
    else _server_guid = $Server_GUID
    end
    if $startup_cnt == 0 || $startup_cnt.class == "NilClass" then
        _host = ""
    else
        _host = $Startups[$startup_cnt]["hostname"]
    end
   _pid = parsed_log_line.log_pid
    output_line = "\"#{_server_guid}\"," + "#{_host},"  + "#{parsed_log_line.log_datetime_string}," +
                  "#{_date_minute},\"#{_io_type}\","  + _t + ",#{_pid}"
    $SOAP_data.puts "#{output_line}"
    end
end
