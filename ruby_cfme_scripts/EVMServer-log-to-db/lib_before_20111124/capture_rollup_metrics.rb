=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_rollup_metrics.rb 24591 2010-11-08 15:45:16Z thennessy $
=end
$Rollup_metrics_csv = nil
class Performance_rollup_metrics
attr_accessor :taskid, :miq_cmd, :interval, :target_class, :target_element_id,:target_element_name, :target_interval
attr_accessor :total_time, :accumulated_times, :unaccounted_time, :pid, :log_datetime

attr_accessor :rollup_perfs, :db_find_prev_perfs, :process_perfs_tag, :db_update_perf,:process_bottleneck 

  def initialize(parsed_log_line)
    @taskid = nil
    @miq_cmd = nil
    @interval = nil
    @target_class = nil
    @target_element_id = nil
    @target_element_name = nil
    @target_interval = nil
    @rollup_perfs = nil
    @db_find_prev_perfs = nil
    @process_perfs_tag = nil
    @db_update_perf = nil
    @process_bottleneck = nil
    @total_time = nil
    @accumulated_times = 0
    @unaccounted_time = 0
    @pid = parsed_log_line.log_pid
    @log_datetime = parsed_log_line.log_datetime



#[----] I, [2010-10-14T08:05:08.662375 #10948:15a19181af04]  INFO -- : 
#   MIQ(MiqEnterprise.perf_rollup) [hourly] Rollup for MiqEnterprise name: [Enterprise], id: [1] 
#   for hour: [2010-10-14T06:00:00Z]...Complete - Timings: 
#   {:total_time=>315.386096954346, 
#   :rollup_perfs=>300.134909152985, 
#   :db_find_prev_perfs=>0.0178289413452148, 
#   :process_perfs_tag=>14.7252938747406, 
#   :db_update_perf=>0.49918007850647, 
#   :process_bottleneck=>0.00868797302246094}
#   
#[----] I, [2010-10-14T08:05:11.189245 #10948:15a19181af04]  INFO -- : 
    #MIQ(Vm.perf_rollup) [hourly] Rollup for Vm name: [KOPPRINT78707], id: [106] 
    #for hour: [2010-10-14T07:00:00Z]...Complete - Timings: 
    #{:total_time=>2.22584009170532, 
    #:rollup_perfs=>0.109019994735718, 
    #:db_find_prev_perfs=>1.99115395545959, 
    #:process_perfs_tag=>1.81198120117188e-05, 
    #:db_update_perf=>0.039111852645874, 
    #:process_bottleneck=>0.0180380344390869} 
#
    if /MIQ\((.*)?\.perf_rollup\)\s*\[(.*)?\]\s*Rollup\s*for\s*(.*)?\s*name\:\s*\[(.*)?\],\s*id\:\s*\[(.*)?\]\s*for\s*(hour|time)\:\s*\[(.*)?\]\.\.\.Complete\s*\-\s*Timings\:\s*/ =~ parsed_log_line.payload then
        @taskid = $1
        _timing_hash = $POSTMATCH          
        @miq_cmd = $1 + ".perf_rollup"
        @interval = $2
        @target_class = $3.strip
        @target_element_id = $5
        @target_element_name = $4
        @target_interval = $6
      else
        puts "#{__FILE__}:#{__LINE__}-\n\tunrecognized performance rollup \n\t in line #{parsed_log_line.payload}"
    
    end
        @log_datetime = parsed_log_line.log_datetime_string
        if _timing_hash then
        _working_times = _timing_hash.split(",")
#        _hash_of_fragments = Hash.new
        _working_times.each do |fragment|
                    fragment.tr!("{}=>:","     ").strip!
                    case fragment
                    when /rollup_perfs/ then 
                      @rollup_perfs = fragment.split[1].to_f
                      @accumulated_times += @rollup_perfs
                    when /total_time/ then 
                      @total_time = fragment.split[1].to_f


                    when /db_find_prev_perf/ then 
                      @db_find_prev_perfs = fragment.split[1].to_f
                      @accumulated_times += @db_find_prev_perfs
                      
                    when /process_perfs_tag/ then 
                      @process_perfs_tag = fragment.split[1].to_f
                      @accumulated_times += @process_perfs_tag

                    when /db_update_perf/ then 
                      @db_update_perf = fragment.split[1].to_f
                      @accumulated_times += @db_update_perf

                    when /process_bottleneck/ then 
                      @process_bottleneck = fragment.split[1].to_f
                       @accumulated_times += @process_bottleneck
                    else
                      puts "#{__FILE__}:#{__LINE__}-\n\tunrecognized performance fragment '#{fragment}'\n\t in line #{parsed_log_line.inspect}"

                    end

                  end
                  @unaccounted_time = @total_time - @accumulated_times
        else
          puts "#{__FILE__}:#{__LINE__}-\n\ttiming information missing \n\t in line #{parsed_log_line.payload}"
        end

#      end
#    puts "#{__FILE__}:#{__LINE__}"
  end
end

def capture_rollup_metrics(parsed_log_line)
  _x = Performance_rollup_metrics.new(parsed_log_line)
  if !$Rollup_metrics_csv then          # if value of variable is nil then open new file
    $Rollup_metrics_csv = File.new($diag_dir  + "\\" + "performance_rollup.csv","w")
    $Rollup_metrics_csv.puts "server guid,hostname,log datetime,startup cnt,process id,target class,target name,target id," <<
                                "interval,target interval,total time,rollup_perfs,db find prev perfs," <<
                                "process perfs tab,db update perf,process bottleneck,unaccounted time"
   end

   rollup_stats_line = "#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," <<
        "#{_x.log_datetime},#{$startup_cnt},#{_x.pid},#{_x.target_class},\"#{_x.target_element_name}\",#{_x.target_element_id}," <<
        "#{_x.interval},\"#{_x.target_interval}\",#{_x.total_time},#{_x.rollup_perfs},#{_x.db_find_prev_perfs},"<<
        "#{_x.process_perfs_tag},#{_x.db_update_perf},#{_x.process_bottleneck},#{_x.unaccounted_time}"

    $Rollup_metrics_csv.puts "#{rollup_stats_line}" if $Rollup_metrics_csv
end


