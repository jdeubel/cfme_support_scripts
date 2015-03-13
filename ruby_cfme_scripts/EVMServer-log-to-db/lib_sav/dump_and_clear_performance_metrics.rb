=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: dump_and_clear_performance_metrics.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def dump_and_clear_performance_metrics
     $Performance_metrics.each do |measurement|
     case measurement.class.to_s
     when "Performance_interval_metrics" then
       interval_stats_line = "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
                  "#{measurement.log_datetime},#{measurement.build_vim_queries},#{measurement.db_processing}," +
                  "#{measurement.interval},#{measurement.map_mors_to_intervals},#{measurement.map_mors_to_vmdb_objs}," +
                  "#{measurement.miq_cmd},#{measurement.num_vim_queries},#{measurement.num_vim_trips}," +
                  "#{measurement.target_class},#{measurement.target_element_name},#{measurement.target_element_id},#{measurement.taskid}," +
                  "#{measurement.total_time},#{measurement.vim_connect},#{measurement.vim_execute_time},#{measurement.perf_processing}"
        $performance_metrics_interval_file.puts "#{interval_stats_line}" if $performance_metrics_interval_file
     when "Performance_realtime_metrics" then
       interval_stats_line = "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
                  "#{measurement.log_datetime},#{measurement.build_vim_queries},#{measurement.db_processing}," +
                  "#{measurement.interval},#{measurement.map_mors_to_intervals},#{measurement.map_mors_to_vmdb_objs}," +
                  "#{measurement.miq_cmd},#{measurement.num_vim_queries},#{measurement.num_vim_trips}," +
                  "#{measurement.target_class},#{measurement.target_element_name},#{measurement.target_element_id},#{measurement.taskid}," +
                  "#{measurement.total_time},#{measurement.vim_connect},#{measurement.vim_execute_time},#{measurement.running_vm_count},#{measurement.perf_processing}"
        $performance_metrics_realtime_file.puts "#{interval_stats_line}" if $performance_metrics_realtime_file
     else puts "#{__FILE__}:#{__LINE__}- '#{measurement.class}' doesn't match either 'Performance_interval_metrics' or 'Performance_realtime_metrics'"
     end
   end
   $Performance_metrics.clear
end
