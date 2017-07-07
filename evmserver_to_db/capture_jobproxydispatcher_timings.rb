=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_jobproxydispatcher_timings.rb 21973 2010-07-02 04:39:02Z thennessy $
=end

$Jobproxydispatcher_file = nil

def capture_jobproxydispatcher_timings(log_line)
  if $Jobproxydispatcher_file == nil then
    $Jobproxydispatcher_file = File.new($diag_dir  + $directory_separator + "jobproxydispatcher_timings.csv","w")
    $Jobproxydispatcher_file.puts "server guid,host name,appliance name,startup,log datetime,PID," +
                                     "start job on proxy count,jobs to dispatch count,get eligible proxies for job count,busy proxy count," +
                                     "queue signal count,queue signal," +
                                     "total time,vm find,start job on proxy,busy proxy concurrent job max,get eligible proxies for job," +
                                     "get eligible proxies for job proxies4job,busy proxy,pending  jobs,unaccounted time," +
                                     "busy proxies,busy hosts for embedded scanning,active scans"
#        $Jobproxydispatcher_file.puts"#{current_startup["server_guid"]},#{current_startup["hostname"]},#{current_startup["appliance name"]},#{$startup_cnt}," +
#                                     "#{current_process["PID"]}," +
#                                     "start job on proxy count,jobs to dispatch count,get eligible proxies for job count,busy proxy count," +
#                                     "total time,vm find,start job on proxy,bisy proxy concurrent job max,get eligible proxies for job," +
#                                     "get eligible proxies for job proxies4job,busy proxy,"
# additions
#C:/documents and settings/administrator/my documents/NetBeansProjects/EVMServer-log-to-db/lib/capture_jobproxydispatcher_timings.rb:84- jobproxydispatcher fragment ' :queue_signal_count=>0' does not match any expected value
#C:/documents and settings/administrator/my documents/NetBeansProjects/EVMServer-log-to-db/lib/capture_jobproxydispatcher_timings.rb:84- jobproxydispatcher fragment ' :queue_signal=>0' does not match any expected value
#C:/documents and settings/administrator/my documents/NetBeansProjects/EVMServer-log-to-db/lib/capture_jobproxydispatcher_timings.rb:84- jobproxydispatcher fragment ' :busy_proxies=>0.00171089172363281' does not match any expected value
#C:/documents and settings/administrator/my documents/NetBeansProjects/EVMServer-log-to-db/lib/capture_jobproxydispatcher_timings.rb:84- jobproxydispatcher fragment ' :busy_hosts_for_embedded_scanning=>0.00284600257873535' does not match any expected value

  end
#:queue_signal_count=>0
 queue_signal_count = 0
#:queue_signal=>0'
 queue_signal = 0
#:busy_proxies=>0.00171089172363281'
 busy_proxies = 0
#:busy_hosts_for_embedded_scanning=>0.00284600257873535'
  busy_hosts_for_embedded_scanning = 0
#[----] I, [2010-04-30T12:10:48.828056 #2447]  INFO -- : 
#Q-task_id([job_dispatcher]) MIQ(JobProxyDispatcher-dispatch) Complete - Timings: {
#:start_job_on_proxy_count=>0,
start_job_on_proxy_count = 0
#:vm_find=>0.00134897232055664,
vm_find = 0
#:start_job_on_proxy=>0,
start_job_on_proxy = 0
#:jobs_to_dispatch_count=>0,
jobs_to_dispatch_count = 0
#:miq_vim_broker_available=>0.0028231143951416
miq_vim_broker_available = 0
#:busy_proxy__concurrent_job_max=>0,
busy_proxy_concurrent_job_max = 0
#:get_eligible_proxies_for_job=>0,
get_eligible_proxies_for_job = 0
#:get_eligible_proxies_for_job_count=>0,
get_eligible_proxies_for_job_count = 0
#:busy_proxy_count=>0,
busy_proxy_count = 0
#:get_eligible_proxies_for_job__proxies4job=>0,
get_eligible_proxies_for_job_proxies4job = 0
#:busy_proxy=>0,
busy_proxy = 0
#:total_time=>0.0187890529632568,
total_time = 0
#:pending_jobs=>0.00192689895629883}
pending_jobs = 0
# :active_scans=>
active_scans = 0
if /Timings\:\s*\{(.*)?\}/ =~ $Parsed_log_line.payload then
    _timings = $1
  _timings_array = _timings.split(",")
  unaccounted_time = 0
  accumulted_time = 0
  _timings_array.each do |fragment| 
    case fragment
    when /busy_hosts_for_embedded_scanning\s*=>\s*(.*)/ then
      busy_hosts_for_embedded_scanning = $1.strip.to_f
    when /busy_proxies\s*=>\s*(.*)/ then
      busy_proxies = $1.strip.to_f
    when /queue_signal\s*=>\s*(.*)/ then
      queue_signal = $1.strip.to_f
    when /queue_signal_count\s*=>\s*(\d*)/ then
      queue_signal_count = $1.strip.to_f
    when /start_job_on_proxy_count\s*=>\s*(.*)/ then
       start_job_on_proxy_count = $1.strip.to_f
    when /start_job_on_proxy\s*=>\s*(.*)/ then
      start_job_on_proxy = $1.strip.to_f
    when /vm_find\s*=>\s*(.*)/ then
      vm_find = $1.strip.to_f
    when /jobs_to_dispatch_count\s*=>\s*(.*)/ then
      jobs_to_dispatch_count = $1.strip.to_f
    when /busy_proxy__concurrent_job_max\s*=>\s*(.*)/ then
      busy_proxy_concurrent_job_max = $1.strip.to_f
    when /busy_proxy_count\s*=>\s*(.*)/ then
      busy_proxy_count = $1.strip.to_f
    when /get_eligible_proxies_for_job__proxies4job\s*=>\s*(.*)/ then
      get_eligible_proxies_for_job_proxies4job = $1.strip.to_f
    when /busy_proxy\s*=>\s*(.*)/   then
      busy_proxy = $1.strip.to_f
    when /total_time\s*=>\s*(.*)/ then
      total_time = $1.strip.to_f
    when /pending_jobs\s*=>\s*(.*)/ then
      pending_jobs = $1.strip.to_f
    when /get_eligible_proxies_for_job_count\s*=>\s*(.*)/ then
      get_eligible_proxies_for_job_count = $1.strip.to_f
    when /get_eligible_proxies_for_job\s*=>\s*(.*)/ then
      get_eligible_proxies_for_job = $1.strip.to_f
    when /miq_vim_broker_available\s*=>\s*(.*)/ then
      miq_vim_broker_available = $1.strip.to_f
    when /active_scans\s*=>\s*(.*)/ then
      active_scans = $1.strip.to_f
    when /busy_resources_for_embedded_scanning\s*=>\s*(.*)/ then

    else
      puts "#{__FILE__}:#{__LINE__}- jobproxydispatcher fragment '#{fragment}' does not match any expected value"
    end
  end
      current_process = $active_processes[$Parsed_log_line.log_pid]
      current_startup = $Startups[$startup_cnt]

# From Joe Rafaniello email:
#So, now, the sums and subtotals are defined as below:
#:total_time = SUM(:get_eligible_proxies_for_job, :start_job_on_proxy, :pending_jobs, :busy_proxy, :vm_find, other misc. untracked calls)

      unaccounted_time = total_time -
                        (get_eligible_proxies_for_job + start_job_on_proxy + pending_jobs + busy_proxy + vm_find )
#                        (vm_find + start_job_on_proxy + busy_proxy_concurrent_job_max + get_eligible_proxies_for_job + get_eligible_proxies_for_job_proxies4job + busy_proxy)
    $Jobproxydispatcher_file.puts"#{current_startup["server_guid"]},#{current_startup["hostname"]},#{current_startup["appliance name"]},#{$startup_cnt}," +
                                     "#{$Parsed_log_line.log_datetime_string.split(".")[0]},#{current_process["PID"]}," +
                                     "#{start_job_on_proxy_count},#{jobs_to_dispatch_count},#{get_eligible_proxies_for_job_count},#{busy_proxy_count}," +
                                     "#{queue_signal_count},#{queue_signal}," +
                                     "#{total_time},#{vm_find},#{start_job_on_proxy},#{busy_proxy_concurrent_job_max},#{get_eligible_proxies_for_job}," +
                                     "#{get_eligible_proxies_for_job_proxies4job},#{busy_proxy},#{pending_jobs},#{unaccounted_time}," +
                                     "#{busy_proxies},#{busy_hosts_for_embedded_scanning},#{active_scans}"
#                                     "start job on proxy count,jobs to dispatch count,get eligible proxies for job count,busy proxy count," +
#                                     "total time,vm find,start job on proxy,busy proxy concurrent job max,get eligible proxies for job," +
#                                     "get eligible proxies for job proxies4job,busy proxy,"
end
end
