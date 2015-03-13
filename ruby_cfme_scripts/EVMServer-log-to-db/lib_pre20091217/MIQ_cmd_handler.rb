=begin rdoc
$Id: MIQ_cmd_handler.rb 17490 2009-12-02 20:38:41Z thennessy $

=end 
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
  attr_accessor :msg_startup_cnt, :msg_instance_id
  attr_accessor :put_pid, :deliver_pid, :server_guid_put, :server_guid_deliver, :msg_priority
  attr_reader :deliver_begin_time  
  def initialize(log_line)
    if log_line.class.to_s != "NilClass" then
      case log_line.payload
      when /MiqQueue\.put/ then
        @put_pid = log_line.log_pid
        @server_guid_put = $Startups[$startup_cnt]["server_guid"]
      when /MiqQueue[\.|\-]deliver/ then
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
  end
  def deliver_begin_time=(field)
#    puts "#{File.basename(__FILE__)}:#{__LINE__}=>#{field} is of type #{field.class}"
    @deliver_begin_time = field
    
  end

end

def miqqueue_deliver_handler(data, log_line_instance)
   # two input fields, first is data following MiqQueue.delivers string
  # the second is the log_line_instance needed to gather boiler-plate info
  # like pid number and tod 
  # third is the object into which data will be placed and must match the
  # msg_id extracted from the data component
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
       if /Target id: \[(\d*)\], Task id: \[(.*)\], Command: (.*),? Timeout: (\d*)/ =~ _data_text then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
         log_msg_info_instance.task_id = $2  
         log_msg_info_instance.data_msg_cmd = $3.tr(',',' ').strip
         log_msg_info_instance.timeout_duration = $4
       end
       if /Target id: \[(\d*)\], Task id: \[(.*)\], Delivered in \[(.*)\] seconds, status \[(\S*)\]/ =~ _data_text then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
         log_msg_info_instance.task_id = $2  
         log_msg_info_instance.msg_process_duration = $3         
         log_msg_info_instance.msg_delivery_complete_status = $4         
       end
       if /Target id: \[(\d*)\], Task id: \[(.*)\], Command: (.*),? Path: ,\s*(.*)$/ =~ _data_text then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
         log_msg_info_instance.task_id = $2  
         log_msg_info_instance.data_msg_cmd = $3.tr(',',' ').strip
         log_msg_info_instance.error_text = '"' + $4.strip + '"'
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
    puts "#{File.basename(__FILE__)}:#{__LINE__}=>Expected MiqQueue.deliver format not found #{data} => log line instance follows:\n\t#{log_line_instance.inspect}"
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
     log_msg_info_instance.process_pid = _temp_pid
     log_msg_info_instance.server_guid_deliver = $Startups[$startup_cnt]["server_guid"]
     log_msg_info_instance.msg_id = msgid if log_msg_info_instance.msg_id == nil
     _work_array = data.split(",")          #separage the text following the message id into array elements
     _work_array.each {|key_value_text|
       case key_value_text
       when /[Dd]elivered in \[(.*)\]\s* seconds/ then
          log_msg_info_instance.msg_process_duration = $1   # capture deliver time
       when /Command:\s*(.*)/ then
          log_msg_info_instance.data_msg_cmd = $1           # capture command
          log_msg_info_instance.deliver_begin_time ||= log_line_instance.log_datetime # for first .deliver inject begin time
          log_msg_info_instance.deliver_complete_time = log_line_instance.log_datetime  # assume any/all following deliver messages are the last of sequence
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
       when /Target id:\s*\[(\S*)\]/ then
         log_msg_info_instance.target_id = $1 if log_msg_info_instance.target_id == nil
       when /Task id:\s*\[(\S*)\]/ then
         log_msg_info_instance.task_id = $1
       when /\s+Timeout:\s*(\d*)/ then
         log_msg_info_instance.timeout_duration = $1
       when /Timeout\:\s*\[(\d*)\]/ then
         log_msg_info_instance.timeout_duration = $1
       when /State\:\s*\[(.*)\]/ then
         log_msg_info_instance.msg_state = $1
          log_msg_info_instance.msg_delivery_complete_status = $1 # capture status
       when /Command:\s*(\S*)\.(\S*)/ then
         log_msg_info_instance.data_msg_cmd = $1 + "." + msgid #class name and method
                                                   # are combined so split them
                                                   # at the period
       when /Class name:\s*\[(\S*)\]/ then
         log_msg_info_instance.msg_class_name = $1 # capture class name in isolation
       when /Data\:\s*\[(\d*)\]/ then log_msg_info_instance.msg_size = $1 if log_msg_info_instance.msg_size == nil
       when /[Ee]rror\:\s*\[(.*)\]/ then log_msg_info_instance.error_text = $1
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
    case data
    when /Zone:\s*\[/ then
      _working_array = data.split(",")                    # split the payload at the commas
      _working_array.each {|key_value|
        case key_value
#Zone: [North], Role: [], Server: [], Target id: [2], Ident: [ems_2], 
#Message id: [82], Class name: [EmsEvent], Instance id: [], Method name: [add], Task id: [] saved queue entry          
        when /Zone:\s*\[(\S*)\]/ then log_msg_info_instance.msg_zone = $1
        when /Role:\s*\[(\S*)\]/ then log_msg_info_instance.msg_role = $1
        when /Server:\s*\[(\S*)\]/ then log_msg_info_instance.msg_server = $1
        when /Target id:\s*\[(\S*)\]/ then log_msg_info_instance.target_id = $1
        when /Ident:\s*\[(\S*)\]/ then log_msg_info_instance.ident_id = $1
        when /Message id:\s*\[(\S*)\]/ then log_msg_info_instance.msg_id = $1
        when /Class name:\s*\[(\S*)\]/ then log_msg_info_instance.msg_class_name = $1
        when /Instance id:\s*\[(\S*)\]/ then log_msg_info_instance.msg_instance_id = $1
        when /Method name:\s*\[(\S*)\]/ then log_msg_info_instance.msg_method_name = $1
        when /State\:\s*\[(\S*)\]/ then log_msg_info_instance.msg_state = $1
        when /Priority\:\s*\[(.*?)\]/ then log_msg_info_instance.msg_priority = $1
        when /Command\:\s*\[(.*)\]/ then log_msg_info_instance.data_msg_cmd = $1
        when /Timeout\:\s*\[(\d*)\]/ then log_msg_info_instance.timeout_duration = $1
#Data: [81 bytes]
        when /Data\:\s*\[(\d*)\]/ then log_msg_info_instance.msg_size = $1 if log_msg_info_instance.msg_size == nil
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
    when /Skipping caught event\s*\[(.*?)\]/ then 
      _event_type = $1
      _event_process = "Skipping"
    when /Caught event\s*\[(.*)\]\s*chainId\s*\[(.*)?\]/
      _event_type = $1
      _event_process = "catching"
      _event_chainid = $2
  when /Queueing event\s*\[(.*)\]\s*chainId\s*\[(.*)?\]/ then
#[----] I, [2009-04-03T00:52:12.476672 #4725]  INFO -- : MIQ(EventCatcher) EMS [10.233.71.130] as [svc_miq] Queueing event [VmResourceReallocatedEvent] chainId [1637224]
      _event_type = $1
      _event_process = "queueing"
      _event_chainid = $2
  when /Validating/ then
      _event_type = "validating"
      _event_process = "validating"

  when /Event Catcher thread gone. Restarting../ then return
  when /[Starting|Started] [E|e]vent catcher thread/ then return
  when /[Starting|Started] Event Monitor Thread/ then return
  when /Event Monitor Thread gone/ then return
  when /Unexpected response returned from Management System/ then return
  when /No route to host/ then return
  when /Unable to find instance for Worker Monitor/ then
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
#end
  