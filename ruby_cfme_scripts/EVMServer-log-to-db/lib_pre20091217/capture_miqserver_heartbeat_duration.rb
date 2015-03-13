=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_miqserver_heartbeat_duration.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
class MiqServer_Heartbeat
  attr_accessor :begin_time, :end_time, :pid, :duration, :server_guid, :host_name, :appliance_name, :log_datetime
  def initialize
    @server_guid = nil
    @host_name = nil
    @appliance_name = nil
    @server_guid = $Startups[$startup_cnt]["server_guid"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["server_guid"].class.to_s != "NilClass"
    @host_name = $Startups[$startup_cnt]["hostname"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["hostname"].class.to_s != "NilClass"
    @appliance_name = $Startups[$startup_cnt]["appliance name"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["appliance name"].class.to_s != "NilClass"
    @log_datetime = $Parsed_log_line.log_datetime_string.split(".")[0] if $Parsed_log_line.class.to_s != "NilClass"
    @begin_time = nil
    @end_time = nil
    @pid = nil
    @duration = nil
  end
end
def complete_heartbeat

  if $current_miqserver_heartbeat.begin_time == nil then
  puts "#{__FILE__}:#{__LINE__}-> Heartbeat cmpleted without hearbeat begin at \n\t#{$current_miqserver_heartbeat.end_time} "
  else
   $current_miqserver_heartbeat.end_time = $Parsed_log_line.log_datetime
   $current_miqserver_heartbeat.duration = $current_miqserver_heartbeat.end_time - $current_miqserver_heartbeat.begin_time
   $miqserver_heartbeats_array << $current_miqserver_heartbeat
   $current_miqserver_heartbeat = MiqServer_Heartbeat.new
end
end
def capture_miqserver_heartbeat_duration(payload)
 case  payload.miq_post_cmd
 when /GUID/
 when /Last Heartbeat/
 when /Complete/ then
    complete_heartbeat()
 else
   if $current_miqserver_heartbeat.begin_time != nil then                 # if I see two begin heartbeats then use current time as end time and handle as prior heartbeat ehd
     complete_heartbeat()
   end
   $current_miqserver_heartbeat.begin_time = $Parsed_log_line.log_datetime #establish heartbeat begin time

 end
end


