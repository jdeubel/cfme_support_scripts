=begin rdoc
$Id: MIQ_cmd_handler.rb 24123 2010-10-08 22:08:53Z thennessy $

=end
$Msg = Hash.new       # utility hash added 2010-10-08 to facilitate single message saving
$MiqQueue = Hash.new # archive of queued messages
$MiqDeliver_error = Hash.new # holding area for msg errors
$MiqQueue_new_by_pid = Hash.new # inbound msg limbo until saved
#                                 only one msg per pid until saved
#                                 doesn't need further correlation
#                                 after saved, move to $MiqQueue
#                                 and delete entry from $MiqQueue_new_by_pid
# Hash Keys
# create_pid - process id that recieved the msg
# process_pid - process id that processed the msg
# target_id - from msg log line
# ident_id - from msg log line
# msg_state - process thru "enter" , "ready", "in_cmd" , 
# msg_size - from msg log line
# msg_id - from msg log line
# msg_state - from msg log line
# create_time - from first put log line
# save_time from last put log line
# deliver_begins_time - from first .deliver log line
# deliver_complete_time - from "delivered" log line
# msg_delivery_complete  - from "[...] message [###}" log line
class Log_msg_info
  attr_accessor :create_pid, :process_pid, :ident_id, :msg_state, :msg_size, :msg_id
  attr_accessor :create_time, :save_time,  :deliver_complete_time
  attr_accessor :msg_delivery_complete_status, :msg_process_duration, :msg_data_store
  attr_accessor :target_id, :ready_time, :data_msg_cmd, :timeout_duration, :task_id, :error_text
  attr_accessor :msg_queued_time, :msg_zone, :msg_role, :msg_server, :msg_class_name, :msg_method_name
  attr_accessor :msg_startup_cnt, :msg_instance_id, :worker_id
  attr_accessor :put_pid, :deliver_pid, :server_guid_put, :server_guid_deliver, :msg_priority, :msg_args
  attr_reader :deliver_begin_time
  def initialize(log_line)
    if log_line.class.to_s != "NilClass" then
      case log_line.payload
      when /MiqQueue(\.|\#)put/ then
        @put_pid = log_line.log_pid
        @server_guid_put = $Startups[$startup_cnt]["server_guid"]
      when /MiqQueue(\.|\-|\#)delivered/ then
        @deliver_pid = log_line.log_pid
        @server_guid_deliver = $Startups[$startup_cnt]["server_guid"]
      when /scan-remove_queued_snapshot_delete/ then
        @deliver_pid = log_line.log_pid
        @server_guid_deliver = $Startups[$startup_cnt]["server_guid"]
      end
    end
    @create_pid = log_line.log_pid if log_line != nil
    @process_pid = nil
    @ident_id = nil
    @target_id = nil
    @task_id = nil
    @msg_state = nil
    @msg_size = nil
    @msg_id = nil
    @create_time = log_line.log_datetime if log_line != nil
    @save_time = nil
    @ready_time = nil
    @deliver_begin_time = nil
    @deliver_complete_time = nil
    @msg_delivery_complete_status = nil
    @msg_process_duration = nil    
    @msg_data_store = nil
    @data_msg_cmd = nil
    @timeout_duration = nil
    @error_text = nil
    @msg_queued_time = nil
    @msg_zone = nil
    @msg_role = nil
    @msg_server = nil
    @msg_class_name = nil
    @msg_method_name = nil
    @msg_priority = nil
    @msg_startup_cnt = $startup_cnt     # this requires a global to be defined and have a value
    @msg_args = nil
    @worker_id = nil
  end
  def deliver_begin_time=(field)
#    puts "#{File.basename(__FILE__)}:#{__LINE__}=>#{field} is of type #{field.class}"
    @deliver_begin_time = field
    
  end

end
def selected_args(args_string)
#    if !args_string.include?(",") && !args_string.include?('\"') && args_string != "[]" then
#      puts "#{args_string}"
#    end
          _tmp = nil                                                                  # return nil if "null" arguements are found
          _tmp_string =args_string.split(",")                                         # take the entire Args: value
          if _tmp_string.size > 2
            then _tmp = _tmp_string[0..2].join(",")
          else
            _tmp = _tmp_string.join(",")
          end
          _tmp = _tmp.tr('"','\'') if _tmp != "[[]]"
          _tmp = "\"" + _tmp + "\"" if _tmp.include?(",")                              #if the ARGS contains a comma, then double-quote enclose it

    return _tmp
end
def miqqueue_deliver_handler(data, log_line_instance)
   # two input fields, first is data following MiqQueue.delivers string
  # the second is the log_line_instance needed to gather boiler-plate info
  # like pid number and tod 
  # third is the object into which data will be placed and must match the
  # msg_id extracted from the data component
  #
  # this routine is also used to process the "miqqueue.get" type messages and extract info from those if necessary
  # [----] I, [2010-04-15T13:03:02.426595 #2529]  INFO -- : MIQ(MiqQueue.get)
  # Message id: [1], Worker id: [5], Zone: [default], Role: [], Server: [], Ident: [generic], Target id: [], Instance id: [], Task id: [],
  # Command: [MiqEvent.raise_evm_event], Timeout: [600], Priority: [100], State: [dequeue], Data: [],
  # Args: [["MiqServer", 1], "miq_server_is_master", {:event_details=>"MiqServer [EVM] id [1] has taken over master"}],
  # Dequeued in: [33.412025] seconds
  #
  # 
#  log_msg_info_instance = $MiqQueue[log_line_instance.log_pid]

#  if  log_line_instance.log_type_word == "ERROR" then
#    puts ""
#  end
#  if /1388/ =~ data then
#    puts "#{__FILE__}:#{__LINE__}->#{data}"
#  end
#  puts "#{log_line_instance.inspect}"
    case data
    when /stale/                                            #ignore stale msgs
    when /WARN\: Couldn't find Job with ID\=/   then        #ignore this type of line

   when  /\(PID:\s*(\S*)\)? Message id:\s*\[(\d*)\], Ident:\s*\[(\S*)\]?, (.*)$/ =~ data then
     if !$MiqQueue.has_key?($2) then 
   # if the $MiqQueue Hash has no key for this then it is probably because
   # this is data left over from a previous shutdown of the appliance
   # so  none of the information normally obtained from the ".put" processing
   # is going to exist, and we have to manufacture what we can from available
   # log information
       $MiqQueue[$2] = Log_msg_info.new(nil)
#       $MiqQueue[$2].process_pid = $1.tr(")",' ').strip
       $MiqQueue[$2].process_pid = log_line_instance.log_pid
       $MiqQueue[$2].msg_id = $2
       $MiqQueue[$2].deliver_begin_time = log_line_instance.log_datetime
       $MiqQueue[$2].ident_id = $3.strip
       $MiqQueue[$2].task_id = nil
       $MiqQueue[$2].target_id = nil
       
     end
     log_msg_info_instance = $MiqQueue[$2]
     log_msg_info_instance.msg_id = $2 if log_msg_info_instance.msg_id == nil
#     _data_msg_id = $2
     log_msg_info_instance.process_pid = log_line_instance.log_pid
     log_msg_info_instance.deliver_begin_time = log_line_instance.log_datetime if log_msg_info_instance.deliver_begin_time == nil
#     _data_pid = $1
     log_msg_info_instance.ident_id = $3.tr('],','  ').strip if log_msg_info_instance.ident_id == nil
#     _data_ident_id = $3  
     _data_text = $4
    # if this is an ERROR log line, then capture the error info into 
    # the log_msg_info_instance
    if log_line_instance.log_type_word == "ERROR" then
#      if /Path:\s*,\s*\'(.*)\'$/ =~ _data_text then
       if /\,\s*\'(.*)$/ =~ _data_text then
        log_msg_info_instance.error_text = $1
       end
    end

     case _data_text
     when /reading/ then
       if /reading\s*(\d*)\s*bytes of data from (.*)$/ =~ _data_text then
#         log_msg_info_instance.msg_data_store = $2
         log_msg_info_instance.deliver_begin_time = log_line_instance.log_datetime
         log_msg_info_instance.msg_data_store = $2.strip
         puts "#{File.basename(__FILE__)}:#{__LINE__}=>Mismatch in data bytes read" if $1 != log_msg_info_instance.msg_size 
       end

       if /reading\s*\[(\d*)\]\s*bytes of data/ =~ _data_text then
#         log_msg_info_instance.msg_data_store = $2
         log_msg_info_instance.deliver_begin_time = log_line_instance.log_datetime
         log_msg_info_instance.msg_data_store = $1.strip
         puts "#{File.basename(__FILE__)}:#{__LINE__}=>Mismatch in data bytes read" if $1 != log_msg_info_instance.msg_size
       end

     when /Command:|Delivered/ then
       if /Target id: \[(\d*)\], Task id: \[(.*)\], Command: (.*?), Timeout: (\d*)/ =~ _data_text then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
         log_msg_info_instance.task_id = $2  
         log_msg_info_instance.data_msg_cmd = $3.tr(',',' ').strip
         log_msg_info_instance.timeout_duration = $4
         log_msg_info_instance.msg_method_name = log_msg_info_instance.data_msg_cmd.split(".")[1]  # isolate and capture method name
       end
       if /Target id: \[(\d*)\], Task id: \[(.*)\], Delivered in \[(.*)\] seconds, status \[(\S*)\]/ =~ _data_text then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
         log_msg_info_instance.task_id = $2  
         log_msg_info_instance.msg_process_duration = $3         
         log_msg_info_instance.msg_delivery_complete_status = $4

       end
       if /Target id: \[(\d*)\], Task id: \[(.*)\], Command: (.*?), Path\:\s*(.*)$/ =~ _data_text then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
         log_msg_info_instance.task_id = $2  
         log_msg_info_instance.data_msg_cmd = $3.tr(',',' ').strip
         log_msg_info_instance.error_text = '"' + $4.strip + '"'
         log_msg_info_instance.msg_method_name = log_msg_info_instance.data_msg_cmd.split(".")[1]  # isolate and capture method name
       end
       
       # MIQ(MiqQueue.delivered)  Message id: [1000463646747], State: [ok], Delivered in [602.842410586] seconds
       if /Message id: \[(\d*)\], State: \[(\S*)\], Delivered in \[(.*)\] seconds/ =~ _data_text then
        log_msg_info_instance.msg_process_duration = $3  
        log_msg_info_instance.msg_delivery_complete_status = $2
       end
     
     else
       puts "#{File.basename(__FILE__)}:#{__LINE__}=>Unexpected MiqQueue.deliver log line payload => #{data}"
     end

    
#[----] I, [2008-08-19T11:39:08.627418 #4575]  INFO -- : MIQ(MiqQueue.deliver)  
#(PID: 4575) Message id: [1], Zone: [*], Role: [], Server: [ceadcea4-6de1-11dd-9314-000c29519586], 
#Ident: [generic], Target id: [], Task id: [], Command: Host.discoverHost, Timeout: 600      

#(PID: 4575) Message id: [1], Zone: [*], Role: [], 
#Server: [ceadcea4-6de1-11dd-9314-000c29519586], Ident: [generic], 
#Target id: [], Task id: [], Delivered in [0.794067] seconds, status [ok]     
    
    
    when /\(PID\:\s*(\S*)\)? Message id\:\s*\[(\d*)\],\s*(.*)$/       # beginning in build 9646 this line has change
                                          # so I'm creating a more general trap for MIQ(MiqQueue.deliver)
                                          # type messages and depending on the message format after the PID
                                          # to be formatted with a series of comma separated strings
                                          # which I can use to part the line and extract info as needed
          handle_deliver_msg_log_data($2,$3)
#    when /hennessy_testing/
##     puts "#{__FILE__}:#{__LINE__}=> RUNNING NEW CODE"
#    _temp_pid = log_line_instance.log_pid
#     if !$MiqQueue.has_key?($2) then
#   # if the $MiqQueue Hash has no key for this then it is probably because
#   # this is data left over from a previous shutdown of the appliance
#   # so  none of the information normally obtained from the ".put" processing
#   # is going to exist, and we have to manufacture what we can from available
#   # log information
#       $MiqQueue[$2] = Log_msg_info.new(nil)
#       $MiqQueue[$2].process_pid = log_line_instance.log_pid
#       $MiqQueue[$2].msg_id = $2
#       $MiqQueue[$2].deliver_begin_time = log_line_instance.log_datetime
#       $MiqQueue[$2].ident_id = $3.strip
#       $MiqQueue[$2].task_id = nil
#       $MiqQueue[$2].target_id = nil
#
#     end
#     log_msg_info_instance = $MiqQueue[$2] # make this a local varialble
#     log_msg_info_instance.process_pid = _temp_pid
#     log_msg_info_instance.server_guid_deliver = $Startups[$startup_cnt]["server_guid"]
#     log_msg_info_instance.msg_id = $2 if log_msg_info_instance.msg_id == nil
#     _work_array = $3.split(",")          #separage the text following the message id into array elements
#     _work_array.each {|key_value_text|
#       case key_value_text
#       when /[Dd]elivered in \[(.*)\]\s* seconds/ then
#          log_msg_info_instance.msg_process_duration = $1   # capture deliver time
#       when /Command:\s*(.*)/ then
#          log_msg_info_instance.data_msg_cmd = $1           # capture command
#          log_msg_info_instance.deliver_begin_time ||= log_line_instance.log_datetime # for first .deliver inject begin time
#          log_msg_info_instance.deliver_complete_time = log_line_instance.log_datetime  # assume any/all following deliver messages are the last of sequence
#       when /status\s*\[(\S*)\]/
#          log_msg_info_instance.msg_delivery_complete_status = $1 # capture status
#       when /Zone:\s*\[(\S*)\]/ then
#         log_msg_info_instance.msg_zone = $1
#       when /Role:\s*\[(\S*)\]/ then
#         log_msg_info_instance.msg_role = $1
#       when /Server:\s*\[(\S*)\]/ then
#         log_msg_info_instance.msg_server = $1
#       when /Ident:\s*\[(\S*)\]/ then
#         log_msg_info_instance.ident_id = $1
#       when /Target id:\s*\[(\S*)\]/ then
#         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
#       when /Task id:\s*\[(\S*)\]/ then
#         log_msg_info_instance.task_id = $1
#       when /\s+Timeout:\s*(\d*)/ then
#         log_msg_info_instance.timeout_duration = $1
#       when /Command:\s*(\S*)\.(\S*)/ then
#         log_msg_info_instance.data_msg_cmd = $1 + "." + $2 #class name and method
#                                                   # are combined so split them
#                                                   # at the period
#       when /Class name:\s*\[(\S*)\]/ then
#         log_msg_info_instance.msg_class_name = $1 # capture class name in isolation
#       when /reading (\d*)\s*bytes of data/ then
#         _tmp_size = $1
#         case log_msg_info_instance.msg_size
#         when nil then log_msg_info_instance.msg_size = _tmp_size
#         else
#           if log_msg_info_instance.msg_size != _tmp_size then
#             puts "#{__FILE__}:#{__LINE__} => msg put(#{log_msg_info_instance.msg_size} and deliver(#{_tmp_size} sizes don't match\n\t'#{log_line_instance.inspect}'"
#
#           end
#         end
##         log_msg_info_instance.msg_size = $1
#       else
#         log_msg_info_instance.error_text = key_value_text  if log_line_instance.log_type_word == "ERROR" # if none of the above checks apply
#       end
#
#
#     }
         when /Message id\:\s*\[(\d*)\],\s*(.*)$/       # beginning in build 17227 this line has changed again
           handle_deliver_msg_log_data($1,$2)

    else
#     if /INFO|ERROR/ =~ log_line_instance.log_type_word then
    if log_line_instance.log_type_word != "INFO" then
      $MiqDeliver_error[log_line_instance.log_pid] = data
#      log_msg_info_instance.error_txt = data
    end
    puts "#{File.basename(__FILE__)}:#{__LINE__}=>Expected MiqQueue.deliver format not found '#{data}' => log line instance follows:\n\t#{log_line_instance}"
    end
#  if /\(PID:\s*(\S*)\)? Message id:\s*\[(\d*)\], Ident:\s*\[(\S*)\], Target id:\s*\[(.*)\], Task id:\s*\[(\S*)\]/
end
def handle_deliver_msg_log_data(msgid,data)
  log_line_instance = $Parsed_log_line
    _temp_pid = log_line_instance.log_pid
     if !$MiqQueue.has_key?(msgid) then
   # if the $MiqQueue Hash has no key for this then it is probably because
   # this is data left over from a previous shutdown of the appliance
   # so  none of the information normally obtained from the ".put" processing
   # is going to exist, and we have to manufacture what we can from available
   # log information
       $MiqQueue[msgid] = Log_msg_info.new(nil)
       $MiqQueue[msgid].process_pid = log_line_instance.log_pid
       $MiqQueue[msgid].msg_id = msgid
       $MiqQueue[msgid].deliver_begin_time = log_line_instance.log_datetime
       $MiqQueue[msgid].ident_id = nil
       $MiqQueue[msgid].task_id = nil
       $MiqQueue[msgid].target_id = nil

     end
     log_msg_info_instance = $MiqQueue[msgid] # make this a local varialble
     save_large_integer_value(msgid)
     log_msg_info_instance.process_pid = _temp_pid
     log_msg_info_instance.server_guid_deliver = $Startups[$startup_cnt]["server_guid"]
     log_msg_info_instance.msg_id = msgid if log_msg_info_instance.msg_id == nil
     _data = data                                                              # establish variable as copy of parm
     if /, Dequeued in: \[(.*)?\] seconds/ =~ data then
       _data = $PREMATCH                                                       # modify variable once we have logically removed some data elements
       log_msg_info_instance.msg_queued_time = $1.to_f
       if /,\s*Args\:\s*(.*)/ =~ _data then
          _data = $PREMATCH                                                    # modify variable once we have logically removed some data elements
#        #  _tmp_string =$1.tr('[]{}"',"     ").strip.split(",")
#           _tmp_string =$1.split(",")                                          # take the entire Args: value
#          if _tmp_string.size > 2
#            then _tmp = _tmp_string[0..1].join(",")
#          else
#            _tmp = _tmp_string.join(",")
#          end
          _tmp_msg_args = $1
          if !_tmp_msg_args.include?(",")  then
            log_msg_info_instance.msg_args = _tmp_msg_args.tr('"',"\'")   
          else
            log_msg_info_instance.msg_args = selected_args(_tmp_msg_args)      #_tmp.tr('"','\'') if _tmp != "[[]]"  # same the args data but alter all internal double quotes to single quotes
          end
       end
     end
     _work_array = _data.split(",")          #separage the text following the message id into array elements
     _work_array.each {|key_value_text|
       case key_value_text
       when /[Dd]elivered in \[(.*)\]\s* seconds/ then
          log_msg_info_instance.msg_process_duration = $1   # capture deliver time
          $Msg[msgid] = log_msg_info_instance                 # if we have delivered time then msg is complete
                                                         # move it into utlity hash
          msg_info_to_csv($base_file_name,$Msg)       # call routine to write to output file
          $Msg.clear
       when /Command:\s*\[(.*)?\]/ then
          log_msg_info_instance.data_msg_cmd = $1           # capture command
          log_msg_info_instance.deliver_begin_time ||= log_line_instance.log_datetime # for first .deliver inject begin time
          log_msg_info_instance.deliver_complete_time = log_line_instance.log_datetime  # assume any/all following deliver messages are the last of sequence
          log_msg_info_instance.msg_method_name = log_msg_info_instance.data_msg_cmd.split(".")[1]  # isolate and capture method name
       when /status\s*\[(\S*)\]/
          log_msg_info_instance.msg_delivery_complete_status = $1 # capture status
       when /Zone:\s*\[(\S*)\]/ then
         log_msg_info_instance.msg_zone = $1
       when /Role:\s*\[(\S*)\]/ then
         log_msg_info_instance.msg_role = $1
       when /Server:\s*\[(\S*)\]/ then
         log_msg_info_instance.msg_server = $1
       when /Ident:\s*\[(\S*)\]/ then
         log_msg_info_instance.ident_id = $1

       when /Instance id:\s*\[(\S*)\]/ then
         log_msg_info_instance.msg_instance_id = $1
         save_large_integer_value(log_msg_info_instance.msg_instance_id)
       when /Target id:\s*\[(\S*)\]/ then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
       when /Task id:\s*\[(\S*)\]/ then
         log_msg_info_instance.task_id = $1
#       when /\s+Timeout:\s*(\d*)/ then
#         log_msg_info_instance.timeout_duration = $1
       when /Timeout\:\s*\[(\d*)\]/ then
         log_msg_info_instance.timeout_duration = $1
       when /Worker id\:\s*\[(.*)\]/ then
         log_msg_info_instance.worker_id = $1
         save_large_integer_value(log_msg_info_instance.worker_id)
       when /State\:\s*\[(.*)\]/ then
         log_msg_info_instance.msg_state = $1
          log_msg_info_instance.msg_delivery_complete_status = $1 # capture status
       when /Priority\:\s*\[(.*?)\]/ then log_msg_info_instance.msg_priority = $1 if $1 != nil
       when /Command:\s*\[(\S*)\.(\S*)?\]/ then
         log_msg_info_instance.data_msg_cmd = $1 + "." + msgid #class name and method
                                                   # are combined so split them
                                                   # at the period
       when /Class name:\s*\[(\S*)\]/ then
         log_msg_info_instance.msg_class_name = $1 # capture class name in isolation
       when /Data\:\s*\[(\d*)\]/ then log_msg_info_instance.msg_size = $1 if log_msg_info_instance.msg_size == nil
       when /[Ee]rror\:\s*\[(.*)\]/ then 
         log_msg_info_instance.error_text = $1
         puts "#{__FILE__}:#{__LINE__} -> msgid #{msgid} data '#{key_value_text}"
#         $Msg[msgid] = log_msg_info_instance                 # if we have delivered time then msg is complete
#                                                         # move it into utlity hash
#          msg_info_to_csv($base_file_name,$Msg)       # call routine to write to output file
#          $Msg.clear
       when /reading (\d*)\s*bytes of data/ then
         _tmp_size = $1
         case log_msg_info_instance.msg_size
         when nil then log_msg_info_instance.msg_size = _tmp_size
         else
           if log_msg_info_instance.msg_size != _tmp_size then
             puts "#{__FILE__}:#{__LINE__} => msg put(#{log_msg_info_instance.msg_size} and deliver(#{_tmp_size} sizes don't match\n\t'#{log_line_instance.inspect}'"

           end
         end
#         log_msg_info_instance.msg_size = $1
       else
         log_msg_info_instance.error_text = key_value_text  if log_line_instance.log_type_word == "ERROR" # if none of the above checks apply
       end


     }

#        if log_msg_info_instance.msg_method_name != nil && log_msg_info_instance.msg_method_name.strip == "agent_state_update_queue"    then
#          puts "#{__FILE__}:#{__LINE__}"
#        end
         if log_msg_info_instance.msg_method_name != nil && 
            log_msg_info_instance.msg_method_name.strip == "agent_state_update_queue" &&
            log_msg_info_instance.msg_args != nil &&
            log_msg_info_instance.msg_args.size > 36  then
            _temp_array=log_msg_info_instance.msg_args.split(",")
            _temp_job_uuid = _temp_array[0].tr("['","  ").tr('"',' ').strip
            log_msg_info_instance.task_id = _temp_job_uuid if _temp_job_uuid.size == 36
         end
    if log_msg_info_instance.msg_process_duration == nil then
      $MiqQueue[msgid] = log_msg_info_instance     # set the  updates into the hash entry
    else
      $MiqQueue.delete(msgid)
#      puts "#{__FILE__}:#{__LINE__} -> msgid #{msgid} removed from $MiqQueue"
    end
end
def miqqueue_put_handler(data,log_line_instance,log_msg_info_instance)
  # three input fields, first is data following MiqQueue.put
  # the second is the log_line_instance needed to gather boiler-plate info
  # like pid number and tod
    # third is the object into which data will be placed
#  if $MiqQueue_new_by_pid.index(log_line_instance.log_pid) == nil then
#    # if no entry with this pid then create one
#    $MiqQueue_new_by_pid["create_pid"] = log_line_instance.log_pid
#  end
#puts "#{log_line_instance.inspect}"
#if /Job.signal/ =~ data then
#    puts "#{__FILE__}:#{__LINE__}=>#{log_line_instance.inspect}"
#end
#    log_msg_info_instance.create_pid = log_line_instance.log_pid
if /,\s*Args\:\s(.*)/ =~ data then
  _data = $PREMATCH
#  _tmp_string =$1.tr('[]{}"',"     ").strip.split(",")
#   _tmp_string =$1.split(",")                                          # take the entire Args: value
#  if _tmp_string.size > 2
#    then _tmp = _tmp_string[0..1].join(",")
#  else
#    _tmp = _tmp_string.join(",")
#  end
#  log_msg_info_instance.msg_args = _tmp.tr('"','\'') if _tmp != "[[]]"  # same the args data but alter all internal double quotes to single quotes
  log_msg_info_instance.msg_args =  selected_args($1)
#  puts "#{__FILE__}:#{__LINE__}=> args values follow #{$1}"
else
  _data = data
end
    case _data
    when /Zone:\s*\[/ then
      _working_array = _data.split(",")                    # split the payload at the commas
      _working_array.each {|key_value|
        case key_value
#Zone: [North], Role: [], Server: [], Target id: [2], Ident: [ems_2], 
#Message id: [82], Class name: [EmsEvent], Instance id: [], Method name: [add], Task id: [] saved queue entry          
        when /Zone:\s*\[(.*)\]/ then log_msg_info_instance.msg_zone = $1 if $1 != nil
        when /Role:\s*\[(\S*)\]/ then log_msg_info_instance.msg_role = $1 if $1 != nil
        when /Server:\s*\[(\S*)\]/ then log_msg_info_instance.msg_server = $1 if $1 != nil
        when /Target id:\s*\[(\S*)\]/ then log_msg_info_instance.target_id = $1 if $1 != nil
        when /Ident:\s*\[(\S*)\]/ then log_msg_info_instance.ident_id = $1 if $1 != nil
        when /Message id:\s*\[(\S*)\]/ then
          log_msg_info_instance.msg_id = $1 if $1 != nil
          save_large_integer_value(log_msg_info_instance.msg_id)

        when /Class name:\s*\[(\S*)\]/ then log_msg_info_instance.msg_class_name = $1 if $1 != nil
        when /Instance id:\s*\[(\S*)\]/ then log_msg_info_instance.msg_instance_id = $1
        when /Method name:\s*\[(\S*)\]/ then 
          log_msg_info_instance.msg_method_name = $1 if $1 != nil
        when /State\:\s*\[(\S*)\]/ then log_msg_info_instance.msg_state = $1 if $1 != nil
        when /Priority\:\s*\[(.*?)\]/ then log_msg_info_instance.msg_priority = $1 if $1 != nil
        when /Worker id\:\s*\[(.*)\]/ then log_msg_info_instance.worker_id = $1 if $1 != nil
        when /Command\:\s*\[(.*)\]/ then 
          log_msg_info_instance.data_msg_cmd = $1 if $1 != nil
          if /\./ =~ log_msg_info_instance.data_msg_cmd && log_msg_info_instance.msg_method_name == nil then                    # if data_msg_command has a method seperator
              _tmp_work = log_msg_info_instance.data_msg_cmd.tr("[]","  ").split(".")
              log_msg_info_instance.msg_class_name = _tmp_work[0] if log_msg_info_instance.msg_class_name == nil
              log_msg_info_instance.msg_method_name = _tmp_work[1] if log_msg_info_instance.msg_method_name == nil
          end
        when /Timeout\:\s*\[(\d*)\]/ then
          log_msg_info_instance.timeout_duration = $1
#Data: [81 bytes]
        when /Data\:\s*\[(\d*)(.*?)\]/ then log_msg_info_instance.msg_size = $1 if log_msg_info_instance.msg_size == nil
        when /Args\:\s*\[(.*)\]/ then                              # ignore the Args: values for now
          _tmp_string = $1.tr("[]","  ").strip.split(" ")
          if _tmp_string.size > 0 then
          else
            puts "#{__FILE__}:#{__LINE__}=>single string value for Args is '#{_tmp_string}' "
          end

        when /Task id:\s*\[(\S*)\]/ then 
          log_msg_info_instance.task_id = $1
          if /saved queue entry/ =~ key_value then
            log_msg_info_instance.msg_state = "ready"
#            log_msg_info_instance.ready_time = log_line_instance.log_datetime
            log_msg_info_instance.create_time = log_line_instance.log_datetime if log_msg_info_instance.create_time == nil
            log_msg_info_instance.ready_time = log_line_instance.log_datetime if log_msg_info_instance.ready_time == nil
            log_msg_info_instance.save_time = log_line_instance.log_datetime if log_msg_info_instance.save_time == nil

          end
          if /\]\s*(\d*)\s*bytes saved/ =~key_value then
            log_msg_info_instance.msg_size = $1 if log_msg_info_instance.msg_size == nil
          end
        when /Worker\s*id\:\s*\[(.*)\]/ then
          log_msg_info_instance.worker_id = $1
        when "  id: []" then            #ignore these fragments
        when /Deliver On\:\s*\[(.*)\]/ then # don't process for the time being, just recognize it
        else
          puts "#{__FILE__}:#{__LINE__}=>MiqQueue.put parameter not recognized -> '#{key_value}'\n\t#{$Parsed_log_line.inspect}"
          puts "#{log_line_instance}"
        end
      }      
      when  /Target\s*id:\s*\[(.*)\],?\s*Ident:\s*\[(\S*)\]?,\s*(.*)/  then
      log_msg_info_instance.target_id = $1
#      $MiqQueue_new_by_pid["target_id"] = $1
      log_msg_info_instance.ident_id = $2.tr('],','  ').strip
#      $MiqQueue_new_by_pid["ident_id"] = $2
      _text = $3
            case _text
            when /enter/ then 
      #        $MiqQueue_new_by_pid["miq_state"] = "enter"
              log_msg_info_instance.msg_state = "enter"
      #        $MiqQueue_new_by_pid["create_time"] = log_line_instance.log_datetime
            when /(\d*)\s*bytes saved data to disk/ then 
              log_msg_info_instance.msg_state = "saved to disk"
      #        $MiqQueue_new_by_pid["miq_state"] = "saved to disk"
              log_msg_info_instance.msg_size = $1
      #        $MiqQueue_new_by_pid["msg_size"] = $1
              log_msg_info_instance.save_time = log_line_instance.log_datetime
      #        $MiqQueue_new_by_pid["save_time"] = log_line_instance.log_datetime

      #      when /Message id\s*\[(\d*)\],\s*changed state to 'ready' and saved/ then 
            when /Message id:\s*\[(\d*)\],\s*(.*)\s*saved queue entry/
              log_msg_info_instance.msg_state = "ready"
      #        $MiqQueue_new_by_pid["miq_state"] = "ready"
              log_msg_info_instance.msg_id = $1
      #        $MiqQueue_new_by_pid["msg_id"] = $1
              log_msg_info_instance.ready_time = log_line_instance.log_datetime
              log_msg_info_instance.create_time = log_line_instance.log_datetime if log_msg_info_instance.create_time == nil
              log_msg_info_instance.ready_time = log_line_instance.log_datetime if log_msg_info_instance.ready_time == nil
              #non generic messages may have skipped the step above where msg size 
              # and saved_time are set, so lets capture what we can
              log_msg_info_instance.save_time = log_line_instance.log_datetime if log_msg_info_instance.save_time == nil
      #        $MiqQueue_new_by_pid["ready_time"] = log_line_instance.log_datetime
            end

    else
#      puts "#{File.basename(__FILE__)}:#{__LINE__}=>#{data}"
    end
    # make sure each .put msg returns with a create time
    log_msg_info_instance.create_time = log_line_instance.log_datetime if log_msg_info_instance.create_time == nil      
#        if log_msg_info_instance.msg_method_name.strip == "agent_state_update_queue"    then
#          puts "#{__FILE__}:#{__LINE__}"
#        end
    if log_msg_info_instance.msg_method_name != nil &&
       log_msg_info_instance.msg_method_name.strip == "agent_state_update_queue" &&
       log_msg_info_instance.msg_args.size > 36  then
            _temp_array=log_msg_info_instance.msg_args.split(",")
            _temp_job_uuid = _temp_array[0].tr("['","  ").tr('"',' ').strip
            log_msg_info_instance.task_id = _temp_job_uuid if _temp_job_uuid.size == 36 
    end

end
def handle_remove_snapshot_by_description(data)
  if  /scan\-remove_queued_snapshot_delete/ =~ data then
#[----] I, [2010-03-31T04:27:34.994374 #3524]  INFO -- :
#Q-task_id([78f47e1a-3c7d-11df-8c4e-0050569138a3])
#JOB([78f47e1a-3c7d-11df-8c4e-0050569138a3] vm_scan_context) scan-remove_queued_snapshot_delete:
#Removing queued item with Message id: [757], Method name: [remove_snapshot_by_description], Task id: [78f47e1a-3c7d-11df-8c4e-0050569138a3]
  if /Removing queued item with Message id\: \[(\d*)\], Method name\: \[(.*)?\], Task id\: \[(.*)?\]/ =~ data then
    msgid = $1
    _method_name = $2
    _task_id = $3
  else return                       # return to caller if search criteria is not matched
  end
  else return                       # return to caller if search criteria is not matched
  end
   log_line_instance = $Parsed_log_line
    _temp_pid = log_line_instance.log_pid
     if !$MiqQueue.has_key?(msgid) then
   # if the $MiqQueue Hash has no key for this then it is probably because
   # this is data left over from a previous shutdown of the appliance
   # so  none of the information normally obtained from the ".put" processing
   # is going to exist, and we have to manufacture what we can from available
   # log information
       $MiqQueue[msgid] = Log_msg_info.new(nil)
       $MiqQueue[msgid].process_pid = log_line_instance.log_pid
       $MiqQueue[msgid].msg_id = msgid
       $MiqQueue[msgid].deliver_begin_time = log_line_instance.log_datetime
       $MiqQueue[msgid].ident_id = nil
       $MiqQueue[msgid].task_id = nil
       $MiqQueue[msgid].target_id = nil

     end
     log_msg_info_instance = $MiqQueue[msgid] # make this a local varialble
     log_msg_info_instance.process_pid = _temp_pid
     log_msg_info_instance.server_guid_deliver = $Startups[$startup_cnt]["server_guid"]
     log_msg_info_instance.msg_id = msgid if log_msg_info_instance.msg_id == nil
     log_msg_info_instance.msg_state = "removed"
     log_msg_info_instance.msg_delivery_complete_status = "removed"
     log_msg_info_instance.deliver_begin_time = log_line_instance.log_datetime
#     $MiqQueue[msgid] = log_msg_info_instance
      $Msg[msgid] = log_msg_info_instance                 # if we have delivered time then msg is complete
                                                     # move it into utlity hash
      msg_info_to_csv($base_file_name,$Msg)       # call routine to write to output file
      $Msg.clear
      $MiqQueue.delete(msgid)                     #remove it from the global table

end
def save_vmmetadata_handler(data)
end
def proxy_heartbeat_handler(data)
  
end
def host_heartbeat_handler(data)
  
end
def state_save_doc_handler(data)
end
def state_save_state_handler(data)
end
def vm_save_ems_inventory_handler(data)
end
def agent_job_state_handler(data)
end
def proxy_call_ws_handler(data)
end
def storage_save_ems_inventory_handler(data)
end
def host_save_ems_inventory_handler(data)
end
def extmanagementsystem_getemsinventory_handler(data)
end
def extmanagementsystem_connect_handler(data)
end
def vm_scan_job_handler(data)
end
def hardware_add_elements_handler(data)
end
def extmanagementsystems_run_vm_cmd_handler(data)
end
def atstartup_handler(data)
end
def vm_scan_metadata_handler(data)
end
def miqworker_stop_handler(data)
end
def extmanagementsystem_scan_handler(data)
end
def extmanagementsystem_disconnect_from_ems_handler(data)
end
def miqworker_start_handler(data)
end
def miqlicense_check_license_handler(data)
end
def agent_log_handler(data)
end
def action_atstartup_handler(data)
end
def miqworker_start_worker_handler(data)
end
def add_blackbox_to_vm_config_handler(data)
end
#def vm_save_ems_inventory_handler(data)
#end
def agent_config_handler(data)
end
def vm_controller_button(data)
end
def miqqueue_get_handler(data)
end
def save_host_metadata_handler(data)
end
def config_handler(data)
end
def host_discoverhost_handler(data)
end
def changestate_handler(data)
end
def host_call_ws_from_queue_handler(data)
end
def eventcatcher_monitor_handler(data)
  # passed in data is the string after the miq(eventcatcher) command
  # use the $Parsed_log_line instance instead
  
  # two general log types listed below:
  #[----] I, [2009-04-03T00:51:04.825750 #4725]  INFO -- : MIQ(EventCatcher) EMS [10.233.71.130] as [svc_miq] Skipping caught event [AlarmStatusChangedEvent]
  #[----] I, [2009-04-03T00:52:12.116389 #4725]  INFO -- : MIQ(EventCatcher) EMS [10.233.71.130] as [svc_miq] Caught event [VmResourceReallocatedEvent] chainId [1637224] 
  

  _event_caught_instance = EMS_Event.new
  if /EMS\s*\[(.*?)\]\s*as\s*\[(.*?)\]/ =~ data then
    _ems_ip_address = $1
    _ems_userid = $2
    _leftover = $POSTMATCH  
#  end

  case _leftover
  when /skipping the following events\:$/ then
#    _event_type = "no event"
#    _event_process= "no event"
     return
#    when /Skipping caught event\s*\[(.*?)\]/ then

    when /Skipping caught event\s\[(.*?)\]\s*chainId\s*\[(.*)?\]/ then
      _event_type = $1
      _event_process = "Skipping"
      _event_chainid = $2
    when /Skipping caught event\s\[(.*?)\]\s*$/ then
      _event_type = $1
      _event_process = "Skipping"
      _event_chainid = nil      
    when /Caught event\s*\[(.*)\]\s*chainId\s*\[(.*)?\]/
      _event_type = $1
      _event_process = "catching"
      _event_chainid = $2
  when /Caught event\s*\[(.*)\]\s*$/
      _event_type = $1
      _event_process = "catching"
      _event_chainid = nil
      
  when /Queueing event\s*\[(.*)\]\s*chainId\s*\[(.*)?\]/ then
#[----] I, [2009-04-03T00:52:12.476672 #4725]  INFO -- : MIQ(EventCatcher) EMS [10.233.71.130] as [svc_miq] Queueing event [VmResourceReallocatedEvent] chainId [1637224]
      _event_type = $1
      _event_process = "queueing"
      _event_chainid = $2
  when /Validating/ then
#      _event_type = "validating"
#      _event_process = "validating"
       return
  when /Initializing/ then
#      _event_type = "initializing"
#      _event_process = "initializing"
      return       

  when /Event Catcher thread gone. Restarting../ then return
  when /Checking that worker monitor/ then return
  when /Starting work since worker monitor has started/ then return  
  when /(Starting|Started) [E|e]vent catcher thread/ then return
  when /(Starting|Started) Event Monitor Thread/ then return
  when /Event Monitor Thread gone/ then return
  when /Unexpected response returned from Management System/ then return
  when /No route to host/ then return
  when /Unable to find instance for Worker Monitor/ then return
  when /Synchronizing configuration/ then return
  when /Synchronizing active roles/ then return
  when /Garbage collection/ then return
  when /Initializing DRb Connection/ then return
  when /Event Monitor Thread terminated normally/ then return
  when /Active Roles/ then return
  when /Exit request/ then return
  when /EventCatcher started\./ then return
  when /Workers are being synchronized:/ then return
  when /EMS\s*\[(.*?)\]\s*as\s*\[(.*?)\]\s*Unexpected response returned from Management System/ then
#Unexpected response returned from Management System
#MIQ(EventCatcher) EMS [192.168.252.6] as [administrator] Unexpected response returned from Management System, see log for details

     _event_type = "probable connection attempt"
     _event_process = "connect"

  else
    puts "#{__FILE__}:#{__LINE__}->unrecognized event logging record #{data}"
  end
=begin rdoc
  @event_type = nil
    @event_chaingid = nil
    @event_process = nil
    @event_ems_ip_address = nil
    @event_ems_userid = nil
    @event_server_name = $Startups[$startup]["name"]
    @event_server_guid = $Startups[$startup]["server_guid"]
    @event_server_startup = $startup
    @event_log_time = $Parsed_log_line.log_datetime_string
=end
    if _event_type.class.to_s == "NilClass" then
      _event_type = "[]"
    else _event_type = "[" + _event_type + "]"
    end
    _event_caught_instance.event_type = _event_type 
    _event_caught_instance.event_chainid = _event_chainid if _event_chainid.class.to_s != "NilClass"
    _event_caught_instance.event_process = _event_process
    _event_caught_instance.event_ems_ip_address = _ems_ip_address
    _event_caught_instance.event_ems_userid = _ems_userid
#    $Caught_event << _event_caught_instance
    $Events_csv.puts "#{_event_caught_instance.event_server_name},#{_event_caught_instance.event_server_guid},#{_event_caught_instance.event_server_startup},#{_event_caught_instance.event_log_time}," +
      "#{_event_caught_instance.event_type},#{_event_caught_instance.event_process},#{_event_caught_instance.event_ems_ip_address},#{_event_caught_instance.event_ems_userid},#{_event_caught_instance.event_chainid}"

#    if $Caught_event.has_key?(_event_type) then
#      $Caught_event[_event_type]["count"] =+ 1
#
#      _event_caught_instance[_event_type] = {"ems_address" => _ems_ip_address, "ems_userid" => _ems_userid, "disposition" => _event_process,
#        "chainid" => _event_chainid,"log_time" =>$Parsed_log_line.log_datetime_string  }
#      $Caught_event[_event_type]["instance_array"] << _event_caught_instance[_event_type]
#    else
##      _instance_array = Array.new
#      $Caught_event[_event_type] = {"count" => 1, "instance_array" => Array.new}
#      _event_caught_instance[_event_type] = {"ems_address" => _ems_ip_address, "ems_userid" => _ems_userid, "disposition" => _event_process,
#        "chainid" => _event_chainid,"log_time" =>$Parsed_log_line.log_datetime_string   }
##      _instance_array << _event_caught_instance
##        $Caught_event[_event_type]["count"] = 1
###        _instance_array[0] = $Caught_event[_event_type]["instance_array"]
#        $Caught_event[_event_type]["instance_array"][0] =  _event_caught_instance[_event_type]
##      _instance_array.clear
#    end
#    $Caught_event[_event_type]["instance_array"] << _event_caught_instance
  end
#    _event_caught_instance.clear

end
def agent_register_handler(data)
end
def host_add_elements_handler(data)
end
def host_create_discovered_ems_handler(data)
end
def server_status_update_handler(data)
  puts "#{__FILE__}:#{__LINE__}=>#{data}"
end
def save_large_integer_value(x)
# routine is intented to capture into dictionary $large_integer
# all of the new 12 charactere id fields that evm version 4 has created
# so that I can build an index within the sql log db and use a 4 byte integer
# to reference each unique 12 character integer as a string
    if x == nil ||   # if x is nill or
       x == "" ||    # x is empty, or
       x.to_i == 0 then  # x is a non-number then skip it
      return     # ignore calls that have invalid string
    else
        if $large_integer_file == nil then
          $large_integer_file = File.new($diag_dir + $directory_separator + "large_integer_"+ $base_file_name + ".csv","w")
          $large_integer_file.puts "large integer"
        end
        x = ('000000000000000000' + x.to_s)[-18,18]   # capture last 18 characters of expanded x
        $large_integer_file.puts x
#    $large_integer.each do |element|
#            large_integer.puts "#{element}" if element  # write out value if it isn't nil
#          end
#    end
#      $large_integer[$large_integer_index] =x
      $large_integer_index += 1
    end
#          if $large_integer.has_key?(x) then
#            $large_integer[x] += 1
#          else $large_integer[x] = 1
#          end
end
#end
  