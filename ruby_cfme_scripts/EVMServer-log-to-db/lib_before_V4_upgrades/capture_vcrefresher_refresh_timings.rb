=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_vcrefresher_refresh_timings.rb 24591 2010-11-08 15:45:16Z thennessy $
=end

class Vcrefresher_refresh_times
  attr_accessor :ems_name, :target_class, :target_name, :target_id,:refresh_time
  attr_accessor :server_guid, :host_name, :appliance_name, :log_datetime
  def initialize(payload)
    @ems_name = nil
    @target_class = nil
    #target_name = nil
    @target_id = nil
    @refresh_time = nil

    @server_guid = nil
    @host_name = nil
    @appliance_name = nil
    @server_guid = $Startups[$startup_cnt]["server_guid"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["server_guid"].class.to_s != "NilClass"
    @host_name = $Startups[$startup_cnt]["hostname"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["hostname"].class.to_s != "NilClass"
    @appliance_name = $Startups[$startup_cnt]["appliance name"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["appliance name"].class.to_s != "NilClass"
    @log_datetime = $Parsed_log_line.log_datetime_string.split(".")[0] if $Parsed_log_line.class.to_s != "NilClass"

    #[----] I, [2009-10-06T02:12:02.671481 #5122]  INFO -- :
#Q-task_id([vc-refresher]) MIQ(VcRefresher-refresh) EMS: [Vi4VC] Refreshing target ExtManagementSystem [Vi4VC] id [1]...Completed in 11.140752 seconds
#   puts "#{__FILE__}:#{__LINE__} - "
#   pp payload
# log one changed ~ 2010-10-21 in build 3.3.2.21 to inject ems id into log line -  may be useful elsewhere
    case payload
    when  /EMS\:\s*\[(.*)?\],\s*id\:\s*\[(.*)\]\s*Refreshing target\s*(\S*)\s*\[(.*?)\]\s*id\s*\[(\d*)\]\.\.\.Completed in\s*(.*) seconds/  then
    #if /EMS\:\s*\[(.*)?\],\s*id\:\s*\[(.*)\]\s*Refreshing target\s*(\S*)\s*\[(.*?)\]\s*id\s*\[(\d*)\]\.\.\.Completed in\s*(.*) seconds/ =~ payload then
     #             1                   2                             3        4                 5                         6
     @ems_name = $1
     @target_class = $3
     @target_name = $4
     @target_id = $5
     @refresh_time = $6.strip.to_f
#   end

#   if /EMS\:\s*\[(.*)\]\s*Refreshing target\s*(\S*)\s*\[(.*?)\]\s*id\s*\[(\d*)\]\.\.\.Completed in\s*(.*) seconds/ =~ payload then
    when /EMS\:\s*\[(.*)\]\s*Refreshing target\s*(\S*)\s*\[(.*?)\]\s*id\s*\[(\d*)\]\.\.\.Completed in\s*(.*) seconds/ then
     @ems_name = $1
     @target_class = $2
     @target_name = $3
     @target_id = $4
     @refresh_time = $5.strip.to_f
#   end
#MIQ(Storage-refresh_file_list) Starting file refresh for Storage [ChiDemo1] via EMS [vi4esx3.galaxy.local]...Completed in [7.776706] seconds 
#   if /Storage \[(.*?)\]\s*via EMS \[(.*?)\]\.\.\.Completed in\s*\[(.*)\] seconds/ =~ payload then

    when  /Storage \[(.*?)\]\s*via EMS \[(.*?)\]\.\.\.Completed in\s*\[(.*)\] seconds/ then
#   if /EMS\:\s*\[(.*)\]\s*Refreshing target\s*(\S*)\s*\[(.*?)\]\s*id\s*\[(\d*)\]\.\.\.Completed in\s*(.*) seconds/ =~ payload then
     @ems_name = $2
     @target_class = "Storage"
     @target_name = $1
     @target_id = nil
     @refresh_time = $3.strip.to_f
#   end
  end
  end
end
class Storage_refresh < Vcrefresher_refresh_times
  def initialize(payload)
    super(payload)
  end
end
def capture_vcrefresher_refresh_timings(payload)
  x = nil                                               # set temp holder to nil for later testing
  case payload.miq_post_cmd
  when /seconds/ then
      case payload.miq_post_cmd
      when /Refreshing target/
         x= Vcrefresher_refresh_times.new(payload.miq_post_cmd)

      when /Storage/
        x = Storage_refresh.new(payload.miq_post_cmd)
      end
  else
  end
  save_large_integer_value(x.target_id) if x
  $vcrefresher_refresh_array << x if x            # only if the temp holder is non-nil

end
