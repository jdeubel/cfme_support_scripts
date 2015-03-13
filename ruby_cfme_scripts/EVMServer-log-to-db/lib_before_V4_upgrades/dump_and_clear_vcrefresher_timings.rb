=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: dump_and_clear_vcrefresher_timings.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def dump_and_clear_vcrefresher_timings
  $vcrefresher_refresh_array.each do |x|
    if x.log_datetime then
      vcrefresher_timings = "#{x.server_guid},#{x.host_name},#{x.appliance_name},#{x.log_datetime},#{x.ems_name},#{x.target_class},#{x.target_name},#{x.target_id},#{x.refresh_time}"
      $vcrefresher_timings_file.puts vcrefresher_timings
    end
  end
  $vcrefresher_refresh_array.clear
end
