=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: dump_and_clear_miqserver_heartbeats.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def dump_and_clear_miqserver_heartbeats
  $miqserver_heartbeats_array.each do |x|
    if x.log_datetime then
      miqserver_heartbeat_record = "#{x.server_guid},#{x.host_name},#{x.appliance_name},#{x.log_datetime},#{x.duration}"
      $miqserver_heartbeats_file.puts miqserver_heartbeat_record
    end
  end
  $miqserver_heartbeats_array.clear
end
