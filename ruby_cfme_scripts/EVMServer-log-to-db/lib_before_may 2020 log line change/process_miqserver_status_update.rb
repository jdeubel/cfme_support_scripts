=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_miqserver_status_update.rb 17820 2009-12-17 18:58:10Z thennessy $
=end
def process_miqserver_status_update(_payload)
#MIQ(MiqWorker.status_update)
#MiqScheduleWorker: [EVM Schedule Worker (5190)] Worker PID [5190], GUID [105b4c02-e4bd-11de-9ad5-0050569167ba], Last Heartbeat [Wed Dec 09 12:20:57 UTC 2009],
#Process Info: Memory Usage [102199296], Memory Size [217395200], Memory % [2.6], CPU Time [7], CPU % [7.5], Priority [26]
#
#MIQ(MiqServer-status_update)
#[EVM Server (4500)] Process info: Memory Usage [113168384], Memory Size [128307200], Memory % [2.79999995231628],
# CPU Time [07:43:48], CPU % [6.59999990463257], Priority [30]


#        if /EVM Server/ =~ _payload.miq_post_cmd then
#          puts "#{__FILE__}:#{__LINE__} -> #{_payload.inspect}"
#        end
      if /\[EVM Server\s*\((\d{1,5})\)\]\s*Process info\:\s*(.*)/ =~ _payload.miq_post_cmd  then
#       if $La_63 =~ _payload.miq_post_cmd then
        _worker_method_name = "EVMServer!"
        _worker_type_text = $2
        _worker_pid = $1
#        _worker_part1 = $4
#        _worker_part2 = $5
        _worker_stats_hash = Hash.new
          _worker_stats_hash["category"] = nil
          _worker_stats_hash["subcategory"] = nil
          _worker_stats_hash["ip_address"] = nil
          _worker_stats_hash["priority"] = nil
#        if /Event Monitor/ =~ _worker_type_text then                #log doesn't differentiate well between
#          if $La_64 =~ _worker_type_text then
          _worker_stats_hash["worker_type"] = "EVMServer!"  # event catcher and handler, so take the type from the method name
#          _worker_type_text.split.each do |_worker_type_word|
#              case _worker_type_word
##              when /vCenter\:/ then _worker_stats_hash["category"] = "Virtual Center"    # capture vCenter as the category
#              when $La_65  then _worker_stats_hash["category"] = "Virtual Center"    # capture vCenter as the category
##              when /\((.*)\)/ then _worker_stats_hash["ip_address"] = $1                  # Capture the ip address of the EMS
#              when $La_66 then _worker_stats_hash["ip_address"] = $1                  # Capture the ip address of the EMS
#              end
#          end
#        else                                                        # from the method name
#          _worker_stats_hash["worker_type"] = _worker_type_text
#        end
          _worker_stats_hash["worker_pid"] = _worker_pid

#          if /[Ee]vent/ =~ _payload.miq_cmd then            # if event is part of the miq cmd
#          if $La_67 =~ _payload.miq_cmd then            # if event is part of the miq cmd
#                                                            # then is is either a monitor or a handler - catch it
#                                                            # and isolate the ip address being monitored too
#          _worker_type_text_array = _worker_type_text.split # break into separate words and replace last with event type
#          case _payload.miq_cmd
##          when /[Cc]atcher/ then _worker_type_text_array[-1] = "Catcher"
##          when /[Hh]andler/ then _worker_type_text_array[-1] = "Handler"
#          when $La_68 then _worker_type_text_array[-1] = "Catcher"
#          when $La_69 then _worker_type_text_array[-1] = "Handler"
#
#          end
#          _worker_type_text = _worker_type_text_array.join(" ")  # recombine phrase
#          _worker_stats_hash["worker_type"] = _worker_type_text  # update the worker type to be catcher or handler type
#          _worker_type_text_array.each do |_word|
#                case _word
##                when /\((.*)\)/ then _worker_stats_hash["ip_address"] = $1
#                when $La_66 then _worker_stats_hash["ip_address"] = $1
##                when /vCenter\:/ then _worker_stats_hash["category"] = "Virtual Center"
#                when $La_65 then _worker_stats_hash["category"] = "Virtual Center"
#                end
#              end
#          end
          capture_process_info("",_worker_type_text,_worker_stats_hash,$Parsed_log_line.log_datetime)
      end
end
