=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: triage_log_line1.rb 24591 2010-11-08 15:45:16Z thennessy $
=end
def triage_log_line1(line_group_in)
=begin rdoc
  The intention of this routine is to collect all of the filters that are easily knowable
  before we begin intensive log line analysis so that log lines which cannot be of interest
  are removed from further processing as soon as possible

  The input object contains an array of one or more log lines, we will only examine the first array entry
  
  this code acts like a function in other languages, returning either True or False
  if True 
    then the log line is no longer needed and we can return to process then next log line
    otherwise
         the log line is subject to further analysis  
=end
#  if $Parsed_log_line.class != 'NilClass' then
#    if $Parsed_log_line.triage.class != "NilClass" && $Parsed_log_line.triage != nil then
#      puts "duplicate call to triage_log_line1 suppressed"
#      return
#    end
#    $Parsed_log_line.triage = true
#  end

    if /has reached the interval/ =~ line_group_in[0] &&
        /MiqQueue\./  !~ line_group_in[0] then
     puts "#{__FILE__}:#{__LINE__}- #{line_group_in}[0]"
  end
  current_log_line = $Parsed_log_line
  return_value = false
  if log_lines_to_skip(line_group_in[0]) then
    return true
  end
  case current_log_line.payload_word1
   when /\<PolicyEngine\>/ then
      return_value = true
      return return_value
  when /HandSoap/ then
    process_handsoap(current_log_line)
    return_value = true
    return return_value
  when /MiqVimUpdate[\.|\-]monitorUpdates\:/ then 
    return_value = true
    return return_value
#  when /MIQ\(VcRefresher[\.|\-]get_vc_data\)/ then return
#  when /MIQ\(PostgreSQL-log_db_stats\)/ then
  when /MiqVimDataStore\(/ then  
    return_value = true
    return return_value
  when /MiqVimInventory\(/ then  
    return_value = true
    return return_value
  when /MIQ\(MiqServer[\-|\.]status_update\)/ then
      if /Process info/ !~ current_log_line.payload then                       # ignore the non-'process info' lines
        return_value = true
        return return_value
      end
  when /$Q-task_id/ then
    case current_log_line.payload
    when /VMware\(VixDiskLib\)/ then  
      return_value = true
      return return_value
    when /MIQ\(save_vmmetadata\)\:/ then
      return_value = true
      return return_value
#    when /\) Scanning \[/ then                          #allow this to drop thru
    when /MIQ\(Config\./ then                             #don't follow this log line
      return_value = true
      return return_value
    when /<PolicyEngine>/ then
      return_value = true
      return return_value
#    when /MIQ\(MiqFaultTolerantVim\-_connect\)/ then return
    when /MIQ\(Vm\-save_metadata\)/ then
      return_value = true
      return return_value

    end
  when /MIQ\(EmsRefreshHelper[\-|\.]update_relats\)/ then
    return_value = true
    return return_value
  when /<AutomationEngine>/ then
    return_value = false
    return return_value
  when /<PolicyEngine>/ then
    return_value = true
    return return_value
  when /MiqVimBroker[\-|\.]getMiqVim\:/ then
    return_value = true
    return return_value
  when /VimBrokerWorker/ then
    if /Queueing refresh/ =~ current_log_line.payload then      #capture the info in these log lines
      return_value = false
      return return_value
    end
#MIQ(VimBrokerWorker) Preloading broker for EMS: [Virtual Center (192.168.254.25)], successful
#MIQ(VimBrokerWorker) Preloading broker for EMS: [Virtual Center (192.168.254.25)]
    case line_group_in[0]
    when /Preloading broker/ then
      capture_broker_latency_times($Parsed_log_line)
    end
  when /MiqBrokerObjRegistry\.release/ then
    return_value = true
    return return_value
  when /MiqBrokerObjRegistry\.registerBrokerObj/ then
    return_value = true
    return return_value
  when /MiqBrokerObjRegistry\.unregisterBrokerObj/ then
    return_value = true
    return return_value
#  when /MIQ\(VcRefresher-refresh\)/ then #allow this to drop thru
#  when /MIQ\(EventCatcher\)/ then        #allow this to drop thru
  when /MiqVimVm\(/ then
    return_value = true
    return return_value
  when /MIQ\(MiqFaultTolerantVim._connect\)/ then
      case line_group_in[0]
      when /Connecting/ then
        capture_broker_latency_times($Parsed_log_line)
#      when /Connecting/ then
#        capture_broker_latency_times($Parsed_log_line)
      when /Preloading broker for EMS\:/ then
        capture_broker_latency_times($Parsed_log_line)
      when /API version\:/ then
        capture_broker_latency_times($Parsed_log_line)
      when /\[Broker\]\s*Connected/ then
        capture_broker_latency_times($Parsed_log_line)
      when /Connected/ then
        capture_broker_latency_times($Parsed_log_line)
      end
    return_value = true
    return return_value
  else

  end
end
