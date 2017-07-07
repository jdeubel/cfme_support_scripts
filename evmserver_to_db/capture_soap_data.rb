=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_soap_data.rb 19061 2010-02-10 21:08:27Z thennessy $
=end
class HandSoap
  attr_accessor :request_time_of_day, :responses_time_of_day, :request_length, :response_length, :uri, :http_status, :soap_action,:request_time_of_day_string
  attr_accessor :request_date_minute

  @request_time_of_day = nil
  @request_time_of_day_string = nil
  @request_date_minute = nil
  @response_time_time_of_day = nil
  @req_response_duration = nil
  @request_length = nil
  @response_length = nil
  @uri = nil
  @http_status = nil
  @soap_action = nil
  
  def initialize(parsed_log_line)
   _io_type = ""
   _t = 0
   if /HandSoap R/ =~ parsed_log_line.payload then
    _temp = parsed_log_line.payload.split(",")
    _temp.each do |element|
        case element
        when /(\S*)\:\s*length\:\s*\[(\d*)\]/ then
          _io_type = $1
          _t = $2
        when /URI\: \[(.*?)\]/ then @uri = $1
        when /SOAPAction\: \[(.*?)\]/ then @soap_action = $1
        when /HTTP\-Status\: \[(\d*)\]/ then @http_status = $1
        end
      end
  end
  case _io_type
  when /Request/ then
    @request_time_of_day = parsed_log_line.log_datetime
    @request_time_of_day_string = parsed_log_line.log_datetime_string.split(".")[0]
    @request_length = _t
    _temp1 = parsed_log_line.log_datetime_string.split(":")  # prepare to generate minute based value
    @request_date_minute = _temp1[0] + ":" + _temp1[1] + ":00"       # truncating seconds to get minute of day
  when /Response/ then

  end
  end
end
def capture_soap_data(parsed_log_line)

  if !$SOAP_active then
    $SOAP_data = File.new($diag_dir + $directory_separator + "Soap_traffic_#{$base_file_name}.csv","w")
    $SOAP_active = true
    $SOAP_data.puts "Server Guid,Server host,request time-of-day,request minute-of-day,req-response duration,request length,response length,PID,URI,SOAPAction,HTTP_status"
  end
  _URI = ""
  _http_status = ""
  _soapaction = ""
  _io_type = ""
  _t = ""
#  puts "#{__FILE__}#{__LINE__}"
  if /HandSoap Request/ =~ parsed_log_line.payload then
    x = HandSoap.new(parsed_log_line)
    $Active_Handsoap[parsed_log_line.log_pid] = x
  end

  if /HandSoap R/ =~ parsed_log_line.payload then
    _temp = parsed_log_line.payload.split(",")
    _temp.each do |element|
        case element
        when /(\S*)\:\s*length\:\s*\[(\d*)\]/ then
          _io_type = $1
          _t = $2
        when /URI\: \[(.*?)\]/ then _URI = $1
        when /SOAPAction\: \[(.*?)\]/ then _soapaction = $1
        when /HTTP\-Status\: \[(\d*)\]/ then _http_status = $1
        end
      end
  end
  
    _temp1 = parsed_log_line.log_datetime_string.split(":")  # prepare to generate minute based value
    _date_minute = _temp1[0] + ":" + _temp1[1] + ":00"       # truncating seconds to get minute of day
  
  if /length\=(\d{1,12})/ =~ parsed_log_line.payload then
    _t = $1                                       # save value
      if /\-\-\-\s*(.*)\s*length/ =~ parsed_log_line.payload then   #don't assume only ": SOAP " log lines are being processed
        _io_type = $1
      else _io_type = ""
      end
  end
  case _io_type
  when /Request/ then
#    if $Active_Handsoap.has_key?(parsed_log_line.log_pid) then
#      puts "#{__FILE__}:#{__LINE__}-.Two Active Requests for HandSoap found:#{parsed_log_line.inspect}"
#      $Active_Handsoap.delete(parsed_log_line.log_pid)            #remove prior entry
#      $Active_Handsoap[parsed_log_line.log_pid] ={"request time"=> parsed_log_line.log_datetime,
#          "request date time" => parsed_log_line.log_datetime_string(".")[0],
#          "request_length" => _t, "URI" => _URI, "SOAPAction" => _soapaction, "HTTP_Status" => _http_status,
#          "response_length" => 0, "req_response_duration" => 0,
#      }
#    else
#    end
  when /Response/ then
    if $Active_Handsoap.has_key?(parsed_log_line.log_pid) then
      x =$Active_Handsoap[parsed_log_line.log_pid]
      if $Server_GUID.class == "NilClass" then _server_guid = ""
      else _server_guid = $Server_GUID
      end
      if $startup_cnt == 0 || $startup_cnt.class == "NilClass" then
          _host = ""
      else
          _host = $Startups[$startup_cnt]["hostname"]
      end
     _pid = parsed_log_line.log_pid
#"Server Guid,Server host,request time-of-day,request minute-of-day,req-response duration,request length,response length,PID,URI,SOAPAction,HTTP_status"
      output_line = "\"#{_server_guid}\"," + "#{_host},"  + "#{x.request_time_of_day_string},#{x.request_date_minute}," +
                    "#{parsed_log_line.log_datetime - x.request_time_of_day},#{x.request_length},#{_t},#{_pid},\"#{x.uri}\",\"#{x.soap_action}\",\"#{_http_status}\"" if _io_type != nil
      $SOAP_data.puts "#{output_line}"
    else
      puts "#{__FILE__}:#{__LINE__}=> expected $Active_handsoap hash entry not found =>#{parsed_log_line.inspect}"
    end
  end

    end
#end
