# 
# create_command_history.rg.rb
# 
# Created on Feb 13, 2008, 3:20:57 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

=begin rdoc
$Id$
$Log: create_command_history.rb,v $
Revision 1.2  2008/02/14 19:20:02  Tom Hennessy
add rdoc begin block for cvs stats

=end
 
def create_command_history(input_array)

    command_summary_record = ShCommandHistory.new          # command_history_record instance             
    if $error_message_record_hash.empty? || $error_message_record_hash.size == 0 then
      ShErrorMessage.find(:all).each do |x| # populate hash
        $error_message_record_hash[x.id] = x.error_message
      end              
    end
    if $error_message_record_hash.has_value?(input_array[ERROR_REASON]) then 
    else
     x = ShErrorMessage.find_or_create_by_error_message(input_array[ERROR_REASON]) 
#     x = ShErrorMessage.find(:first, :error_message => input_array[ERROR_REASON]) #do |x|
        $error_message_record_hash[x.id] = x.error_message # populate new key-value into hash
         #end
    end                  

# agent name only referenced in log file record, not command history  
#    if $agent_name_record_hash.empty? || $agent_name_record_hash.size == 0 then
#       ShAgentName.find(:all).each do |_agent_name| #populate hash
#       $agent_name_record_hash[_agent_name.id] = _agent_name.agent_name
#     end
#    end
#    if $agent_name_record_hash.has_value?(input_array[AGENT_NAME]) then 
#    else
#      ShAgentName.find_or_create_by_agent_name(input_array[AGENT_NAME]) do |x|
#        $agent_name_record_hash[x.id] = x.agent_name # populate new key-value into hash
#         end
#    end                         

    if $process_id_record_hash.empty? || $process_id_record_hash.size == 0 then
      ShProcessId.find(:all).each do |x|   # populate hash
        $process_id_record_hash[x.id] = x.process_id
      end
    end
   if $process_id_record_hash.has_value?(input_array[PROCESS_ID]) then 
    else
   x =   ShProcessId.find_or_create_by_process_id(input_array[PROCESS_ID])
#      ShProcessId.find(:first, :process_id => input_array[PROCESS_ID])      do |x|
        $process_id_record_hash[x.id] = x.process_id # populate new key-value into hash
#         end
    end 

    if $thread_id_record_hash.empty? || $thread_id_record_hash.size == 0 then
      ShThreadId.find(:all).each do |x|   # populate hash
        $thread_id_record_hash[x.id] = x.thread_id
      end
    end
   if $thread_id_record_hash.has_value?(input_array[THREAD_ID]) then 
    else
    x =  ShThreadId.find_or_create_by_thread_id(input_array[THREAD_ID]) # do |x|
        $thread_id_record_hash[x.id] = x.thread_id # populate new key-value into hash
#         end
    end   


    if $command_name_record_hash.empty? || $command_name_record_hash.size == 0 then
  #                          command_name_record_hash = ShCommandName.find(:all)
        ShCommandName.find(:all).each do |x|
          $command_name_record_hash[x.id] = x.command_name
        end
    end
   if $command_name_record_hash.has_value?(input_array[CMD_NAME]) then 
    else
    x =  ShCommandName.find_or_create_by_command_name(input_array[CMD_NAME]) # do |x|
        $command_name_record_hash[x.id] = x.command_name # populate new key-value into hash
#         end
    end                         


    if $command_result_record_hash.empty? || $command_result_record_hash.size == 0 then
  #                            command_result_record_hash = ShCommandResult.find(:all)
     ShCommandResult.find(:all).each do |x|
       $command_result_record_hash[x.id] = x.command_result
     end
    end
    if $command_result_record_hash.has_value?(input_array[CMD_COMPLETION_STATUS]) then 
    else
    x =  ShCommandResult.find_or_create_by_command_result(input_array[CMD_COMPLETION_STATUS]) #do |x|
        $command_result_record_hash[x.id] = x.command_result # populate new key-value into hash
#         end
    end                          



    if $vm_name_record_hash.empty? || $vm_name_record_hash.size == 0 then
    ShVmName.find(:all).each do |x|
      $vm_name_record_hash[x.id] = x.vm_name
    end
    end
    if $vm_name_record_hash.has_value?(input_array[CMD_TARGET_VM]) then 
    else
    x =  ShVmName.find_or_create_by_vm_name(input_array[CMD_TARGET_VM]) # do |x|
        $command_result_record_hash[x.id] = x.vm_name # populate new key-value into hash
#         end
    end  



    if $command_parm_record_hash.empty? || $command_parm_record_hash.size == 0 then
    ShCommandParm.find(:all).each do |x| 
      $command_parm_record_hash[x.id] = x.command_parm
    end
    end
    if $command_parm_record_hash.has_value?(input_array[CMD_PARMS]) then 
    else
    x =  ShCommandParm.find_or_create_by_command_parm(input_array[CMD_PARMS]) # do |x|
        $command_parm_record_hash[x.id] = x.command_parm # populate new key-value into hash
#         end
    end                       


    command_summary_record.log_duration_seconds = input_array[CMD_DURATION]
    command_summary_record.sh_error_message_id = 
          $error_message_record_hash.index(input_array[ERROR_REASON])
    command_summary_record.sh_process_id_id = 
          $process_id_record_hash.index(input_array[PROCESS_ID]) #process_id_record.id
    command_summary_record.sh_thread_id_id = 
          $thread_id_record_hash.index(input_array[THREAD_ID]) #thread_id_record.id
    command_summary_record.sh_command_name_id = 
           $command_name_record_hash.index(input_array[CMD_NAME])   #command_name_record.id
    command_summary_record.sh_command_result_id = 
            $command_result_record_hash.index(input_array[CMD_COMPLETION_STATUS])  #command_result_record.id
    command_summary_record.sh_command_parm_id = 
            $command_parm_record_hash.index(input_array[CMD_PARMS]) #command_parms_record.id
    command_summary_record.sh_vm_name_id = 
            $vm_name_record_hash.index(input_array[CMD_TARGET_VM])    #vm_name_record.id
    command_summary_record.sh_log_file_name_id = $current_log_file_record_key
#    gm_time_input = (input_array[LOG_START_DATE].tr("/",",").to_s + "," )
#    gm_time_input = ( gm_time_input  + input_array[LOG_START_TIME].tr(":",",").to_s + ",")
#    gm_time_input = (gm_time_input  + input_array[LOG_START_MICRO_SECONDS].to_s)
    
     _y_m_d = input_array[LOG_START_DATE].tr("/",",").split(",")
     _h_m_s = input_array[LOG_START_TIME].tr(":",",").split(",")

    _gm_time_start = Time.gm(_y_m_d[0].to_i,_y_m_d[1].to_i,_y_m_d[2].to_i,_h_m_s[0].to_i,_h_m_s[1].to_i,_h_m_s[2].to_i,
                      input_array[LOG_START_MICRO_SECONDS].to_i)
    command_summary_record.log_start_time = _gm_time_start
    result = command_summary_record.save
    end

  