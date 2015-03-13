=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_ems_performance_interval_metrics.rb 20948 2010-05-14 21:36:09Z thennessy $
=end
$Performance_metrics = Array.new
class Performance_interval_metrics
attr_accessor :taskid, :miq_cmd, :interval, :target_class, :target_element_id,:target_element_name
attr_accessor :capture_state, :collect_metrics, :process_perfs, :process_perfs_tag, :db_find_prev_perfs, :total_time
attr_accessor :log_datetime, :pid , :accumulated_times, :unaccounted_time, :db_find_metrics, :process_perfs_db, :process_counter_values
attr_accessor :db_find_counters, :rollup_perfs, :db_update_perfs, :process_bottleneck, :db_update_perf, :add_missing_intervals

attr_accessor :db_processing, :num_vim_queries, :vim_connect, :perf_processing, :capture_counters 
attr_accessor :start_range, :end_range, :num_vim_trips, :capture_intervals, :build_query_params, :vim_execute_time
attr_accessor :db_find_storage_files, :init_attrs

  def initialize(parsed_log_line)
    @taskid = nil
    @miq_cmd = nil
    @interval = nil
    @target_class = nil
    @target_element_id = nil
    @target_element_name = nil
#    @vim_connect = nil
#    @build_vim_queries = nil
#    @map_mors_to_vmdb_objs = nil
#    @num_vim_trips = nil
#    @num_vim_queries = nil
    @total_time = nil
    @capture_state = nil
    @collect_metrics = nil
    @process_perfs = nil
    @process_perfs_tag = nil
    @db_find_prev_perfs = nil
    @add_missing_intervals = nil
    @accumulated_times = 0
    @unaccounted_time = 0
#    @vim_execute_time = nil
#    @map_mors_to_intervals = nil
#    @db_processing = nil
#    @log_datetime = nil
    @pid = parsed_log_line.log_pid

    @db_find_metrics = nil
    @process_perfs_db = nil

    @process_counter_values = nil
    @db_find_counters = nil
    @rollup_perfs = nil
    @db_update_perf = nil
    @process_bottleneck = nil

#added 5/5/2010
    @db_processing = nil
    @num_vim_queries = nil
    @vim_connect = nil
    @perf_processing = nil
    @capture_counters = nil
    @start_range = nil
    @end_range = nil
    @num_vim_trips = nil
    @capture_intervals = nil
    @build_query_params = nil
    @vim_execute_time = nil
    @db_find_storage_files = nil
    @init_attrs = nil



#[----] I, [2010-04-04T05:08:39.073322 #10688]  INFO -- :
#Q-task_id([perf_collection]) MIQ(Storage.perf_capture) [hourly] Capture for Storage name: [msan1], id: [7]...Complete -
#Timings: {:process_perfs=>1.8948609828949, :capture_state=>0.0249810218811035, :process_perfs_tag=>0.363616943359375, 
#:db_find_prev_perfs=>0.0024268627166748, :total_time=>2.40874195098877}
#
#MIQ(Vm.perf_capture) [realtime] Capture for Vm name: [MSSQL2005-NJ], id: [18]...Complete -
#Timings: {:total_time=>7.18024301528931, :capture_state=>0.752928018569946, :collect_metrics=>6.41138219833374}
    if /MIQ\((.*)?\)\s*\[(\S*)\]\s*Capture\s*for\s*(\S*)\s*name\:\s*\[(.*)?\]\,\s*id\:\s*\[(\d*)\]...Complete\s*-\s*Timings\:\s*\{(.*)\}/ =~parsed_log_line.payload then
#      puts "#{__FILE__}:#{__LINE__}-#{$Parsed_log_line}"
      @taskid = ""
      @miq_cmd = $1
      @interval = $2
      @target_class = $3
      @target_element_name = $4
      @target_element_id = $5
      _timings_hash = $6
      @log_datetime = parsed_log_line.log_datetime_string.split(".")[0]
    end
#
#[----] I, [2010-04-14T13:48:34.553927 #14137]  INFO -- : Q-task_id([perf_collection])
#MIQ(Vm.perf_process) [realtime] Processing for Vm name: [Mail6650], id: [1819], for range [2010-04-14T13:41:20Z - 2010-04-14T13:45:20Z]...Complete -
#Timings {
#:process_perfs=>0.0970451831817627,
#:db_find_metrics=>0.00693202018737793,
#:db_find_counters=>0.107452154159546,
#:process_perfs_db=>0.209760427474976,
#:total_time=>0.496645927429199,
#:process_counter_values=>0.00453710556030273,
#:db_find_prev_perfs=>0.024738073348999}
#

  if /MIQ\((.*)?\)\s*\[(\S*)\]\s*(Processing|Rollup)\s*for\s*(\S*)\s*name\:\s*\[(.*)?\],\s*id\:\s*\[(\d*)\](.*)\s*Timings(.*)/ =~ parsed_log_line.payload then
      @taskid = ""
      @miq_cmd = $1
      @interval = $2
      @target_class = $4
      @target_element_name = $5
      @target_element_id = $6
      _timings_hash = $8.tr("{}:","   ").strip
      @log_datetime = parsed_log_line.log_datetime_string.split(".")[0]
  end
#
#[----] I, [2010-04-14T13:49:04.911969 #14137]  INFO -- : Q-task_id([perf_collection])
#MIQ(Host.perf_rollup) [hourly] Rollup for Host name: [titan.galaxy.local], id: [2] for hour: [2010-04-14T13:00:00Z]...Complete - Timings {
#:rollup_perfs=>0.256566047668457,
#:db_update_perf=>0.00943398475646973,
#:process_bottleneck=>27.312961101532,
#:process_perfs_tag=>0.266296148300171,
#:total_time=>28.4226448535919,
#:db_find_prev_perfs=>0.525811910629272}

      if _timings_hash != nil then
      _working_times = _timings_hash.split(",")
      _working_times.each do |fragment|
                    fragment.tr!(":=>","   ").strip!
#                    @accumulated_times += fragment.split[1].to_f
                    case fragment
                    when /db_find_prev_perfs/ then
                      @db_find_prev_perfs = fragment.split[1].to_f
                      @accumulated_times += @db_find_prev_perfs
                    when /process_perfs_tag/ then
                      @process_perfs_tag = fragment.split[1].to_f
                      @accumulated_times += @process_perfs_tag
                    when /process_bottleneck/ then
                      @process_bottleneck = fragment.split[1].to_f
                      @accumulated_times += @process_bottleneck
                    when /db_update_perf/ then
                      @db_update_perf = fragment.split[1].to_f
                      @accumulated_times += @db_update_perf
                    when /rollup_perfs/ then
                      @rollup_perfs = fragment.split[1].to_f
                      @accumulated_times += @rollup_perfs

                    when /db_find_counters/ then
                      @db_find_counters = fragment.split[1].to_f
                      @accumulated_times += @db_find_counters

                    when /process_counter_values/ then
                      @process_counter_values = fragment.split[1].to_f
                      @accumulated_times += @process_counter_values

                    when /process_perfs_db/ then
                      @process_perfs_db = fragment.split[1].to_f
                      @accumulated_times += @process_perfs_db

                    when /db_find_metrics/ then
                      @db_find_metrics = fragment.split[1].to_f
                      @accumulated_times += @db_find_metrics
                    when /db_find_prev_perfs/ then 
                      @db_find_prev_perfs = fragment.split[1].to_f                      
                      @accumulated_times += @db_find_prev_perfs

                    when /process_perfs_tag/ then 
                      @process_perfs_tag = fragment.split[1].to_f
                       @accumulated_times += @process_perfs_tag

                    when /capture_state/ then 
                      @capture_state = fragment.split[1].to_f
                       @accumulated_times += @capture_state

                    when /process_perfs/ then 
                      @process_perfs = fragment.split[1].to_f
                       @accumulated_times += @process_perfs

                    when /total_time/ then 
                      @total_time = fragment.split[1].to_f
                      #don't accumulate this one
                      #!

                    when /collect_metrics/ then
                      @collect_metrics = fragment.split[1].to_f
                      @accumulated_times += @collect_metrics

                    when /add_missing_intervals/ then
                    @add_missing_intervals = fragment.split[1].to_f
                    @accumulated_times += @add_missing_intervals
                    when /db_processing/ then
                      @db_processing = fragment.split[1].to_f
                      @accumulated_times += @db_processing
                    when /vim_connect/ then
                      @vim_connect = fragment.split[1].to_f
                      @accumulated_times += @vim_connect
                    when /num_vim_queries/ then
                      @num_vim_queries = fragment.split[1].to_f
                    when /perf_processing/ then
                      @perf_processing = fragment.split[1].to_f
                      @accumulated_times += @perf_processing
                    when /capture_counters/ then
                      @capture_counters = fragment.split[1].to_f
                      @accumulated_times += @capture_counters
                    when /start_range/ then
                    when /end_range/ then
                    when /num_vim_trips/ then
                      @num_vim_trips = fragment.split[1].to_f
                    when /capture_intervals/ then
                      @capture_intervals = fragment.split[1].to_f
                      @accumulated_times += @capture_intervals
                    when /build_query_params/ then
                      @build_query_params = fragment.split[1].to_f
                      @accumulated_times += @build_query_params
                    when /vim_execute_time/ then
                      @vim_execute_time = fragment.split[1].to_f
                      @accumulated_times += @vim_execute_time
                    when /db_find_storage_files/ then
                      @db_find_storage_files = fragment.split[1].to_f
                      @accumulated_times += @db_find_storage_files
                    when /init_attrs/ then
                      @init_attrs = fragment.split[1].to_f
                      @accumulated_times += @init_attrs
                    else 
                      puts "#{__FILE__}:#{__LINE__}- Fragment not recognized=>' #{fragment}'\n\t#{parsed_log_line.inspect}"
                    end
#        puts "#{fragment}"
      end
      @unaccounted_time = @total_time - @accumulated_times
#      if @target_class == "Host" then
#        puts "#{__FILE__}:#{__LINE__}=>#{self.inspect}"
#      end
    end

#[----] I, [2010-04-28T16:18:42.235341 #8771]  INFO -- : Q-task_id([perf_collection])
#MIQ(Host.perf_process) [realtime] Processing for Host name: [VI4ESX6.galaxy.local], id: [11], for range [2010-04-28T16:13:40Z - 2010-04-28T16:18:00Z]...Complete -
#Timings: {
#:process_counter_values=>0.0209231376647949,
#:db_find_prev_perfs=>0.00794696807861328,
#:process_perfs=>0.0386738777160645,
#:total_time=>0.454536199569702,
#:db_find_metrics=>0.119357109069824,
#:process_perfs_db=>0.248561143875122}
    if /Q-task_id\(\[(.*)?\]\)\s*MIQ\((.*)?\)\s*\[(\S*)\]\s*(\S*)\s*for\s*(\S*)\s*name\:\s*\[(.*)?\],\s*id\:\s*\[(\d*)\],(.*)\s*Timings\: \\s*\{(.*)?\}/ =~ parsed_log_line.payload then

    end
    if /Q-task_id\(\[(.*?)\]\)\s*MIQ\((.*?)\)\s*\[(\S*)\]\s*for\:\s*\[(\S*?)\],\s*\[(\d*)\],\s*\[(.*?)\]\s*Timings\:\s*\{(.*)\}/ =~ parsed_log_line.payload then
        @taskid = $1
        @miq_cmd = $2
        @interval = $3
        @target_class = $4
        @target_element_id = $5
        @target_element_name = $6
        _timing_hash = $7
        @log_datetime = parsed_log_line.log_datetime_string.splid(".")[0]
        _working_times = _timing_hash.split(",")
#        _hash_of_fragments = Hash.new
        _working_times.each do |fragment|
                    fragment.tr!(":=>","   ").strip!
                    case fragment
                    when /vim_connect/ then @vim_connect = fragment.split[1].to_f
                    when /build_vim_queries/ then @build_vim_queries = fragment.split[1].to_f
                    when /num_vim_trips/ then @num_vim_trips = fragment.split[1]
                    when /map_mors_to_vmdb_objs/ then @map_mors_to_vmdb_objs = fragment.split[1].to_f
#                    when /num_vim_trips/ then @num_vim_trips = fragment.split[1]
                    when /num_vim_queries/ then @num_vim_queries = fragment.split[1]
                    when /vim_connect/ then @vim_connect = fragment.split[1].to_f
                    when /total_time/ then @total_time = fragment.split[1].to_f
                    when /vim_execute_time/ then @vim_execute_time = fragment.split[1].to_f
                    when /map_mors_to_intervals/ then @map_mors_to_intervals = fragment.split[1].to_f
                    when /db_processing/ then @db_processing = fragment.split[1].to_f
                    else
                      puts "#{__FILE__}:#{__LINE__}-\n\tunrecognized performance fragment '#{fragment}'\n\t in line #{parsed_log_line.inspect}"

                    end

                  end

      end
#    puts "#{__FILE__}:#{__LINE__}"
  end
end
#end
def capture_ems_performance_interval_metrics(parsed_log_line)
  # if we get here then we have recognized an ems performance interval accumulation log record
  # instead of processing the miq record, we will use the grobal $Parsed_log_line to get the info we need
  _x = Performance_interval_metrics.new($Parsed_log_line)
  $Performance_metrics << _x if _x.log_datetime != nil

#        puts "#{__FILE__}:#{__LINE__}- #{$Performance_metrics.size}"
end
#def capture_ems_performance_realtime_metrics(parsed_log_line)
#  _x = Performance_realtime_metrics.new($Parsed_log_line)
#  $Performance_metrics << _x if _x.log_datetime != nil
#end

