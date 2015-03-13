=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_ems_performance_interval_metrics.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
$Performance_metrics = Array.new
class Performance_interval_metrics
attr_accessor :taskid, :miq_cmd, :interval, :target_class, :target_element_id,:target_element_name
attr_accessor :vim_connect, :build_vim_queries, :map_mors_to_vmdb_objs, :num_vim_trips, :num_vim_queries, :total_time
attr_accessor :vim_execute_time, :map_mors_to_intervals, :db_processing, :log_datetime

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
    @vim_execute_time = nil
    @map_mors_to_intervals = nil
    @db_processing = nil
    @log_datetime = nil
    if /Q-task_id\(\[(.*?)\]\)\s*MIQ\((.*?)\)\s*\[(\S*)\]\s*for\:\s*\[(\S*?)\],\s*\[(\d*)\],\s*\[(.*?)\]\s*Timings\:\s*\{(.*)\}/ =~ parsed_log_line.payload then
        @taskid = $1
        @miq_cmd = $2
        @interval = $3
        @target_class = $4
        @target_element_id = $5
        @target_element_name = $6
        _timing_hash = $7
        @log_datetime = parsed_log_line.log_datetime_string
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

