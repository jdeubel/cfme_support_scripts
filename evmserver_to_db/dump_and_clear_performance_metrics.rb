=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: dump_and_clear_performance_metrics.rb 21179 2010-05-24 11:26:54Z thennessy $
=end
def dump_and_clear_performance_metrics
     $Performance_metrics.each do |measurement|

     case measurement.class.to_s
     when "NilClass" then next      # if array has been preallocated then this can happen
     when "Performance_interval_metrics" then
       interval_stats_line = "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," <<
                  "#{measurement.log_datetime},#{measurement.target_class},#{measurement.target_element_name},#{measurement.target_element_id}," <<
                  "#{measurement.interval},#{measurement.miq_cmd},#{measurement.pid},#{measurement.taskid}," <<
                  "#{measurement.total_time},#{measurement.unaccounted_time}," <<
                  "#{measurement.capture_state}," <<
                  "#{measurement.db_find_prev_perfs}," <<
                  "#{measurement.process_perfs_tag}," <<
                  "#{measurement.process_perfs}," <<
                  "#{measurement.collect_metrics}," <<
                  "#{measurement.db_find_metrics}," <<
                  "#{measurement.process_perfs_db}," <<
                  "#{measurement.process_counter_values}," <<
                  "#{measurement.db_find_counters}," <<
                  "#{measurement.rollup_perfs}," <<
                  "#{measurement.db_update_perf}," <<
                  "#{measurement.process_bottleneck}," <<
                  "#{measurement.add_missing_intervals}," <<
                  "#{measurement.db_processing}," <<
                  "#{measurement.num_vim_queries}," <<
                  "#{measurement.vim_connect}," <<
                  "#{measurement.perf_processing}," <<
                  "#{measurement.capture_counters}," <<
                  "#{measurement.num_vim_trips}," <<
                  "#{measurement.capture_intervals}," <<
                  "#{measurement.build_query_params}," <<
                  "#{measurement.vim_execute_time}," <<
                  "#{measurement.db_find_storage_files}," <<
                  "#{measurement.init_attrs}"
#                  "db processing, num vim queries, vim connect, perf processing, capture counters," +
#                  "num vim trips,capture intervals,build query params, vim execute time," +
#                  "db find storage files,init attrs"
#
#                  "#{measurement.db_find_prev_perfs}"
#    $performance_metrics_interval_file.puts  "server_guid,hostname," +
#                  "log_datetime,target class,target element nane,target element id," +
#                  "interval,miq cmd,pid,taskid," +
#                  "total time,unaccounted time," +
#                  "capture state,db find prev perfs,process perfs tag,process perfs,collect metrics" +
#                  "db find metrics,process perfs db, process_counter values,db find counters,rollup perfs,db update perf,process bottleneck,db find prev perfs"

        $performance_metrics_interval_file.puts "#{interval_stats_line}" if $performance_metrics_interval_file
     when "Performance_realtime_metrics" then
       interval_stats_line = "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," <<
                  "#{measurement.log_datetime},#{measurement.build_vim_queries},#{measurement.db_processing}," <<
                  "#{measurement.interval},#{measurement.map_mors_to_intervals},#{measurement.map_mors_to_vmdb_objs}," <<
                  "#{measurement.miq_cmd},#{measurement.num_vim_queries},#{measurement.num_vim_trips}," <<
                  "#{measurement.target_class},#{measurement.target_element_name},#{measurement.target_element_id},#{measurement.taskid}," <<
                  "#{measurement.total_time},#{measurement.vim_connect},#{measurement.vim_execute_time},#{measurement.running_vm_count},#{measurement.perf_processing}," <<
                  "#{measurement.pid},#{measurement.start_range},#{measurement.end_range},#{measurement.build_query_params},#{measurement.write_counters}," <<
                  "#{measurement.capture_counters},#{measurement.unaccounted_time}," <<
                  "#{measurement.capture_counters},#{measurement.db_find_storage_files},#{measurement.init_attrs}"
        $performance_metrics_realtime_file.puts "#{interval_stats_line}" if $performance_metrics_realtime_file
     else puts "#{__FILE__}:#{__LINE__}- '#{measurement.class}' doesn't match either 'Performance_interval_metrics' or 'Performance_realtime_metrics'"
     end
   end
   $Performance_metrics.clear
end
