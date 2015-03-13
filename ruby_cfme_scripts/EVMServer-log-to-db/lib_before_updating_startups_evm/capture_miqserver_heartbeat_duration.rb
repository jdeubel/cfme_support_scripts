=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_miqserver_heartbeat_duration.rb 20242 2010-04-12 14:26:08Z thennessy $
=end
class MiqServer_Heartbeat
  attr_accessor :begin_time, :end_time, :pid, :duration, :server_guid, :host_name, :appliance_name, :log_datetime
  attr_accessor :heartbeat_interval, :prior_successful_heartbeat_endtime
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
    @prior_successful_heartbeat_endtime = nil
    @heartbeat_interval = nil
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
   if /Complete/ =~ $Parsed_log_line.payload then
     $current_miqserver_heartbeat.prior_successful_heartbeat_endtime = $Parsed_log_line.log_datetime
     #capture the last good heartbeat time and keep it for later reference
   end
end
end
def capture_miqserver_heartbeat_duration(payload)
  #the intent of this code section is to capture two elemens:
  # 1- the actual heartbeat duration when heartbeats are successful
  # 2- when heartbeats are not successul, the gap between the last successful heartbeat and the next successful heartbeat
 case  payload.miq_post_cmd
 when /GUID/
 when /Last Heartbeat/
 when /Complete/ then
   if $current_miqserver_heartbeat.prior_successful_heartbeat_endtime != nil then
    $current_miqserver_heartbeat.heartbeat_interval = ($Parsed_log_line.log_datetime - $current_miqserver_heartbeat.prior_successful_heartbeat_endtime).to_i
   else
     $current_miqserver_heartbeat.heartbeat_interval = 0
   end
    #if we have a completed hearbeat, then calculate the duration since the last completed hearbeat
    complete_heartbeat()
 else
   if $current_miqserver_heartbeat.begin_time != nil then                 # if I see two begin heartbeats then use current time as end time and handle as prior heartbeat ehd
     complete_heartbeat()
   end
   $current_miqserver_heartbeat.begin_time = $Parsed_log_line.log_datetime #establish heartbeat begin time

 end
end


