=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: dump_and_clear_miqserver_heartbeats.rb 20242 2010-04-12 14:26:08Z thennessy $
=end
def dump_and_clear_miqserver_heartbeats
  $miqserver_heartbeats_array.each do |x|
    if x && x.log_datetime then
      miqserver_heartbeat_record = "#{x.server_guid},#{x.host_name},#{x.appliance_name},#{x.log_datetime},#{x.duration},#{x.heartbeat_interval}"
      $miqserver_heartbeats_file.puts miqserver_heartbeat_record
    end
  end
  $miqserver_heartbeats_array.clear
  $miqserver_heartbeats_array_index = 0
end
