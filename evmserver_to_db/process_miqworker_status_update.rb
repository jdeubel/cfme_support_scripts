=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_miqworker_status_update.rb 20948 2010-05-14 21:36:09Z thennessy $
=end
def process_miqworker_status_update(_payload)  # one explicit input parm: parsed miq payload and
                                                 # one implicit :$Parsed_log_line
#[----] I, [2009-01-07T12:51:21.235250 #4738]  INFO -- : MIQ(MiqWorkerMonitor) [EVM Worker Monitor (4696)] Worker guid [1873fc70-dcb9-11dd-8167-0050569b236d],
#Last Heartbeat [Wed Jan 07 12:50:24 UTC 2009],
#Process Info: Memory Usage [72744960], Memory Size [89018368], Memory % [1.8], CPU Time [00:00:09], CPU % [2.6], Priority [30]

# Altered 20090110
#[----] I, [2009-01-10T14:25:59.770255 #4881]  INFO -- : MIQ(MiqWorker-status_update) MiqPriorityWorker:
# [Priority Queue (4869)] Worker guid [d8bd22e4-df21-11dd-8ba9-0050569b77f6], Last Heartbeat [Sat Jan 10 14:25:57 UTC 2009],
# Process Info: Memory Usage [72028160], Memory Size [79831040], Memory % [1.8], CPU Time [00:00:07], CPU % [2.4], Priority [30]

#MIQ(MiqServer-status_update) [EVM Server (4500)] Process info: Memory Usage [113168384], Memory Size [128307200], Memory % [2.79999995231628],
# CPU Time [07:43:48], CPU % [6.59999990463257], Priority [30] 

# beginning builds 2.7.0.x
#[----] I, [2009-12-16T15:47:21.010356 #6022]  INFO -- : 
#MIQ(MiqWorker.status_update) MiqPerfCollectorWorker: 
#[EVM Perf Collector Worker (5563)] Worker PID [5563], GUID [b5d14dde-ea4a-11de-8eb6-005056916069], Last Heartbeat [Wed Dec 16 15:46:22 UTC 2009], 
#Process Info: Memory Usage [165109760], Memory Size [289681408], Memory % [4.3], CPU Time [65], CPU % [1.0], Priority [26] 
#        if /EVM Server/ =~ _payload.miq_post_cmd then
#          puts "#{__FILE__}:#{__LINE__} -> #{_payload.inspect}"
#        end
        if /status_update/ =~ _payload.miq_cmd then
          return
        end 
        if /Worker ID \[(\d*)\],/ =~ _payload.miq_post_cmd then
          _worker_id = $1
        else
          _worker_id = nil
        end
#  MiqGenericWorker: [Generic Worker] Worker ID [12865], PID [29507], GUID [59e19e5e-4278-11e3-b6f7-001a4ad22351], Last Heartbeat [2013-11-01 08:01:16 UTC], 
#  Process Info: 
#  Memory Usage [191254528], Memory Size [427933696], Memory % [1.53], CPU Time [52760.0], CPU % [0.01], Priority [25]         
#  MiqGenericWorker: [Generic Worker] Worker ID [12865], PID [29507], GUID [59e19e5e-4278-11e3-b6f7-001a4ad22351], Last Heartbeat [2013-11-01 08:01:16 UTC], Process Info: Memory Usage [191254528], Memory Size [427933696], Memory % [1.53], CPU Time [52760.0], CPU % [0.01], Priority [25]   
#   /(\S*\:)\s*\[(.*?)\]\s*Worker ID\s*\[(\d*)\0,\s*PID\S*\{(\d*\],\s*GUID\S*\[(.*?)\],\S*Last Heartbeat\S*\[.*?)\],\s*Process Info\:\s*Memory Usage\s*\[(\d*)/  

  # _worker_id = nil
  _worker_pid = nil
  _worker_part1 = nil
  _worker_part2 = nil
  _worker_method_name = nil
  _worker_type_text = nil
  
  case _payload.miq_post_cmd
  when /Process Info/ then
    miq_post_cmd_array = _payload.miq_post_cmd.split('Process Info:')
    miq_post_cmd_part1_array = miq_post_cmd_array[0].split(',')
    _worker_part2 = miq_post_cmd_array[1]
    miq_post_cmd_part1_array.each do |_xx|
                                     case _xx
                                    when /(\S*)\:\s+\[(.*?)\]\s+Worker ID\s+\[(\d*)\]/ then
                                        _worker_method_name = $1
                                        _worker_type_text = $2
                                        _worker_id = $3
                                    when /\[(.*?)\]\s+Worker ID\s+\[(\d*)\]/ then
                                        _worker_type_text = $1
                                        _worker_id = $2
                                         
                                    when / PID\s+\[(\d*)\]/ then
                                      _worker_pid = $1
                                    when / GUID\s+\[(.*?)\]/ then 
                                      _worker_part1 = _xx << ","
                                     when / Last/ then
                                       _worker_part1 += _xx << ","
                                     end
      
                                  end
    
#  end
  
  
        
#      if /(.*)\:\s*\[(.*)\((\d{1,5})\)\]\s*(.*)Process Info:\s*(.*)/ =~ _payload.miq_post_cmd  then
#       if $La_63 =~ _payload.miq_post_cmd then
 when  $La_63  then
#         if /(.*)\:\s*\[(.*?)\s*Worker\s*\(\d*)\)\]\s*Worker PID\[(\d*)\],\s*GUID\s*\[(.*?)\],
        _worker_method_name = $1
        _worker_type_text = $2
        _worker_pid = $3
        _worker_part1 = $4
        _worker_part2 = $5
    end
        _worker_stats_hash = Hash.new
          _worker_stats_hash["category"] = nil
          _worker_stats_hash["subcategory"] = nil
          _worker_stats_hash["ip_address"] = nil
          _worker_stats_hash["priority"] = nil
          _worker_stats_hash["worker_type"] = nil
#        if /Event Monitor/ =~ _worker_type_text then                #log doesn't differentiate well between
          if $La_64 =~ _worker_type_text then
          _worker_stats_hash["worker_type"] = _worker_method_name   # event catcher and handler, so take the type from the method name
          _worker_type_text.split.each do |_worker_type_word|
              case _worker_type_word
#              when /vCenter\:/ then _worker_stats_hash["category"] = "Virtual Center"    # capture vCenter as the category
              when $La_65  then _worker_stats_hash["category"] = "Virtual Center"    # capture vCenter as the category
#              when /\((.*)\)/ then _worker_stats_hash["ip_address"] = $1                  # Capture the ip address of the EMS
              when $La_66 then _worker_stats_hash["ip_address"] = $1                  # Capture the ip address of the EMS
              end
          end
        else                                                        # from the method name
          _worker_stats_hash["worker_type"] = _worker_type_text
        end
          _worker_stats_hash["worker_pid"] = _worker_pid
          _worker_stats_hash["worker_id"] = _worker_id

#          if /[Ee]vent/ =~ _payload.miq_cmd then            # if event is part of the miq cmd
          if $La_67 =~ _payload.miq_cmd then            # if event is part of the miq cmd
                                                            # then is is either a monitor or a handler - catch it
                                                            # and isolate the ip address being monitored too
          _worker_type_text_array = _worker_type_text.split # break into separate words and replace last with event type
          case _payload.miq_cmd
#          when /[Cc]atcher/ then _worker_type_text_array[-1] = "Catcher"
#          when /[Hh]andler/ then _worker_type_text_array[-1] = "Handler"
          when $La_68 then _worker_type_text_array[-1] = "Catcher"
          when $La_69 then _worker_type_text_array[-1] = "Handler"

          end
          _worker_type_text = _worker_type_text_array.join(" ")  # recombine phrase
          _worker_stats_hash["worker_type"] = _worker_type_text  # update the worker type to be catcher or handler type
          _worker_type_text_array.each do |_word|
                case _word
#                when /\((.*)\)/ then _worker_stats_hash["ip_address"] = $1
#                when $La_66 then _worker_stats_hash["ip_address"] = $1
#                when /vCenter\:/ then _worker_stats_hash["category"] = "Virtual Center"
                when $La_65 then _worker_stats_hash["category"] = "Virtual Center"
                end
                                        end
          end
#           puts "#{__FILE__}:#{__LINE__}\n\t_worker_part1 = '#{_worker_part1}'\n\t_worker_part2 = '#{_worker_part2}'\n\t_worker_stats_hash = #{_worker_stats_hash.inspect}'\n\t $parsed_log_line.log_datetime = '#{$Parsed_log_line.log_datetime}'"            
          capture_process_info(_worker_part1,_worker_part2,_worker_stats_hash,$Parsed_log_line.log_datetime)  
#      end
end