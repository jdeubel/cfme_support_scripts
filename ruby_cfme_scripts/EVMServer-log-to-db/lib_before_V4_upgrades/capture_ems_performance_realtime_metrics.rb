=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_ems_performance_realtime_metrics.rb 20948 2010-05-14 21:36:09Z thennessy $
=end

class Performance_realtime_metrics
attr_accessor :taskid, :miq_cmd, :interval, :target_class, :target_element_id,:target_element_name
attr_accessor :vim_connect, :build_vim_queries, :map_mors_to_vmdb_objs, :num_vim_trips, :num_vim_queries, :total_time
attr_accessor :vim_execute_time, :capture_intervals, :db_processing, :log_datetime, :running_vm_count,:perf_processing, :pid
attr_accessor :start_range, :end_range, :build_query_params, :write_counters, :capture_counters, :unaccounted_time
attr_accessor :capture_state, :init_attrs,:db_find_storage_files, :map_mors_to_intervals

  def initialize(parsed_log_line)
    @taskid = nil
    @miq_cmd = nil
    @interval = nil
    @target_class = nil
    @target_element_id = nil
    @target_element_name = nil
    @vim_connect = nil
    @build_vim_queries = nil
    @map_mors_to_vmdb_objs = nil
    @num_vim_trips = nil
    @num_vim_queries = nil
    @total_time = nil
    @perf_processing = nil
    @vim_execute_time = nil
    @capture_intervals = nil
    @db_processing = nil
    @log_datetime = nil
    @running_vm_count = nil
    @start_range = nil
    @end_range = nil
    @build_query_params = nil
    @write_counters = nil
    @capture_counters = nil
    @capture_state = nil
    @map_mors_to_intervals = nil
    @init_attrs = nil
    @db_find_storage_files = nil
    @accumulated_times = 0
    @unaccounted_time = 0
    @pid = parsed_log_line.log_pid



#    [----] I, [2009-03-18T10:44:17.914406 #12378]  INFO -- :
#      #MIQ(VimPerformanceHelper-vim_collect_perf_data) [Realtime] for: 2 running Vms on [Host],
#[3], [PE1.demo.manageiq.com] Timings:
#{:vim_connect=>2.490083, :build_vim_queries=>9.810275, :map_mors_to_vmdb_objs=>1.090027,
#:num_vim_trips=>3, :num_vim_queries=>22, :total_time=>37.121238, :vim_execute_time=>15.20405,
#:map_mors_to_intervals=>0.620313, :db_processing=>1.455}
#
#log line changes April 2010 follow with sample:
#[----] I, [2010-04-14T13:50:25.581043 #14134]  INFO -- : Q-task_id([perf_collection])
#MIQ(Vm.vim_collect_perf_data) [realtime] for: [Vm], [1835], [MIQ-FTP1] Finished performance data collection and processing - Timings:
#{:map_mors_to_vmdb_objs=>0.000288009643554688, :start_range=>"2010-04-14T13:41:40Z", :build_query_params=>0.000448942184448242,
#:end_range=>"2010-04-14T13:50:20Z", :vim_execute_time=>0.0380809307098389, :db_processing=>0.419581890106201,
#:perf_processing=>0.00547099113464355, :vim_connect=>0.429398059844971, :num_vim_queries=>1, :map_mors_to_intervals=>0.00579714775085449,
#:write_counters=>1.16646194458008, :total_time=>2.13073492050171, :num_vim_trips=>1, :capture_counters=>0.0633420944213867}

#    if /\.perf_/ =~ parsed_log_line.payload then
#      puts "#{__FILE__}:#{__LINE__}-> performance capture...."
#    end
    if /MIQ\((.*?)\)\s*\[(\S*)\]\s*for\:\s*(\d*?)\s*running Vms on\s*\[(\S*)\],\s*\[(\d*?)\],\s*\[(.*?)\]\s*Timings\:\s*\{(.*)\}/ =~ parsed_log_line.payload then
#        @taskid = $1
        @miq_cmd = $1
        @interval = "Realtime"
        @running_vm_count=$3
        @target_class = $4
        @target_element_id = $5
        @target_element_name = $6
        _timing_hash = $7
    end
#[----] I, [2009-10-02T00:43:20.880390 #5445]  INFO -- :
#MIQ(VimPerformanceHelper-vim_collect_perf_data) [Realtime] for: [Vm], [111], [APSQLUPG2]
#Timings: {:perf_processing=>0.023157, :map_mors_to_vmdb_objs=>6.729559, :num_vim_queries=>1, :num_vim_trips=>1,
#:total_time=>146.856907, :db_processing=>2.131673, :vim_connect=>134.109982, :build_vim_queries=>3.286051,
#:vim_execute_time=>0.191914, :map_mors_to_intervals=>0.059234}
    if /MIQ\((.*?)\)\s*\[(\S*)\]\s*for\:\s*\[(\S*)\],\s*\[(\d*?)\],\s*\[(.*)\]\s*Timings\:\s*\{(.*)\}/ =~ parsed_log_line.payload then
#        @taskid = $1
        @miq_cmd = $1
        @interval = $2
        @running_vm_count= nil
        @target_class = $3
        @target_element_id = $4
        @target_element_name = $5
        _timing_hash = $6
    end
        if /MIQ\((.*?)\)\s*\[(\S*)\]\s*for\:\s*\[(\S*)\],\s*\[(\d*?)\],\s*\[(.*)\]\s*(.*?)\-\s*Timings\:\s*\{(.*)\}/ =~ parsed_log_line.payload then
#        @taskid = $1
        @miq_cmd = $1
        @interval = $2
        @running_vm_count= nil
        @target_class = $3
        @target_element_id = $4
        @target_element_name = $5
        _timing_hash = $7
    end
        @log_datetime = parsed_log_line.log_datetime_string
        if _timing_hash then
        _working_times = _timing_hash.split(",")
#        _hash_of_fragments = Hash.new
        _working_times.each do |fragment|
                    fragment.tr!("=>","  ").strip!
                    case fragment
                    when /vim_connect/ then 
                      @vim_connect = fragment.split[1].to_f
                      @accumulated_times += @vim_connect
                    when /build_vim_queries/ then 
                      @build_vim_queries = fragment.split[1].to_f
                      @accumulated_times += @build_vim_queries

                    when /num_vim_trips/ then 
                      @num_vim_trips = fragment.split[1]

                    when /map_mors_to_vmdb_objs/ then 
                      @map_mors_to_vmdb_objs = fragment.split[1].to_f
                      @accumulated_times += @map_mors_to_vmdb_objs

#                    when /num_vim_trips/ then @num_vim_trips = fragment.split[1]
                    when /num_vim_queries/ then 
                      @num_vim_queries = fragment.split[1]
#                      @accumulated_times += @num_vim_queries

                    when /vim_connect/ then 
                      @vim_connect = fragment.split[1].to_f
                       @accumulated_times += @vim_connect

                    when /total_time/ then 
                      @total_time = fragment.split[1].to_f

                    when /vim_execute_time/ then 
                      @vim_execute_time = fragment.split[1].to_f
                      @accumulated_times += @vim_execute_time
                    when /map_mors_to_intervals/ then 
                      @capture_intervals = fragment.split[1].to_f
                      @accumulated_times += @capture_intervals
                    when /capture_intervals/ then
                      @capture_intervals = fragment.split[1].to_f
                      @accumulated_times += @capture_intervals
                    when /db_processing/ then 
                      @db_processing = fragment.split[1].to_f
                      @accumulated_times += @db_processing

                    when /perf_processing/ then 
                      @perf_processing = fragment.split[1].to_f
                      @accumulated_times += @perf_processing
                    when /start_range/ then                      # don't process for now
                      _work_date = fragment.split[1].tr('TZ"',"   ")
                      #_work_date_array = _work_date.split(" ")
                      #yyyy mm dd hh mm ss
                      # 0    1  2  3  4  5
                      @start_range = _work_date.strip
                      @start_range = nil if @start_range == "nil"

                    when /end_range/ then                        # don't process for now
                      _work_date = fragment.split[1].tr('TZ"',"   ").strip
                      @end_range = _work_date
                      @end_range = nil if @end_range == "nil"
                      
                    when /build_query_params/ then 
                      @build_query_params = fragment.split[1].to_f
                      @accumulated_times += @build_query_params

                    when /capture_counters/ then
                      @capture_counters = fragment.split[1].to_f
                      @accumulated_times += @capture_counters

                    when /write_counters/ then
                      @write_counters = fragment.split[1].to_f
                      @accumulated_times += @write_counters

                    when /capture_state/ then
                      @capture_state = fragment.split[1].to_f
                      @accumulated_times += @capture_state

                    when /init_attrs/ then
                      @init_attrs = fragment.split[1].to_f
                      @accumulated_times += @init_attrs

                    when /db_find_storage_files/ then
                      @db_find_storage_files = fragment.split[1].to_f
                      @accumulated_times += @db_find_storage_files
                    else
                      puts "#{__FILE__}:#{__LINE__}-\n\tunrecognized performance fragment '#{fragment}'\n\t in line #{parsed_log_line.inspect}"

                    end

                  end
                  @unaccounted_time = @total_time - @accumulated_times
        else
          puts "#{__FILE__}:#{__LINE__}-\n\tunrecognized performance log line \n\t in line #{parsed_log_line.inspect}"
        end

#      end
#    puts "#{__FILE__}:#{__LINE__}"
  end
end

def capture_ems_performance_realtime_metrics(parsed_log_line)
  _x = Performance_realtime_metrics.new($Parsed_log_line)
  $Performance_metrics << _x if _x.log_datetime != nil
end
def capture_270x_perf_timings(parsed_log_line)
#[----] I, [2009-12-19T07:13:11.512814 #5626]  INFO -- :
#MIQ(Vm.perf_capture_queue) Skipping capture of Vm name: [tch-UBUNTU-SERVER-904-TESTING], id: [59]
# - Performance last captured on [Sat Dec 19 06:34:23 UTC 2009] is within threshold
#[----] I, [2009-12-19T07:23:18.960033 #29834]  INFO -- :
#MIQ(Vm.perf_capture) [realtime] Capture for Vm name: [MSSQL2005-NJ], id: [21]...Complete
#- Timings: {:total_time=>3.30679488182068, :collect_metrics=>3.21678996086121, :capture_state=>0.0285618305206299}
  _x = Performance_270x_metrics.new($Parsed_log_line)
end
