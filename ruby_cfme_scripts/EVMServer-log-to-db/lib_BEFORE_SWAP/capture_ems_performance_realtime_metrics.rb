=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_ems_performance_realtime_metrics.rb 16597 2009-10-12 15:36:47Z thennessy $
=end

class Performance_realtime_metrics
attr_accessor :taskid, :miq_cmd, :interval, :target_class, :target_element_id,:target_element_name
attr_accessor :vim_connect, :build_vim_queries, :map_mors_to_vmdb_objs, :num_vim_trips, :num_vim_queries, :total_time
attr_accessor :vim_execute_time, :map_mors_to_intervals, :db_processing, :log_datetime, :running_vm_count,:perf_processing

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
    @map_mors_to_intervals = nil
    @db_processing = nil
    @log_datetime = nil
    @running_vm_count = nil
#    [----] I, [2009-03-18T10:44:17.914406 #12378]  INFO -- :
#      #MIQ(VimPerformanceHelper-vim_collect_perf_data) [Realtime] for: 2 running Vms on [Host],
#[3], [PE1.demo.manageiq.com] Timings:
#{:vim_connect=>2.490083, :build_vim_queries=>9.810275, :map_mors_to_vmdb_objs=>1.090027,
#:num_vim_trips=>3, :num_vim_queries=>22, :total_time=>37.121238, :vim_execute_time=>15.20405,
#:map_mors_to_intervals=>0.620313, :db_processing=>1.455}
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
        @log_datetime = parsed_log_line.log_datetime_string
        if _timing_hash then
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
                    when /perf_processing/ then @perf_processing = fragment.split[1].to_f

                    else
                      puts "#{__FILE__}:#{__LINE__}-\n\tunrecognized performance fragment '#{fragment}'\n\t in line #{parsed_log_line.inspect}"

                    end

                  end
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
