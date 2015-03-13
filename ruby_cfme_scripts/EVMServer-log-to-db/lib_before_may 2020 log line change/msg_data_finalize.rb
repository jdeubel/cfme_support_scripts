=begin rdoc
this code module will handle the output processing of log_msg_info class
instances into an output file based on the name of the current input file.
the initial convention will be the base_file_name + "msg_info.csv"

After csv processing is completed, I'll add in ActiveRecord processing
to capture complete log/customer/appliance context
but appliance logging is still in flux and I'd rather wait for some level
of new implementation before beginning this.

$Id: msg_data_finalize.rb 20579 2010-04-23 12:50:41Z thennessy $

=end  
$msg_info_open = nil
# set to false initially and then set to true when later modules are called
# for processing when logs are finally processed
def msg_info_to_csv(base_file_name,x)
  # first parm is base file name then 
  # expect single hash where key is msgid and value is 
  # instance of log_msg_info class
  if !$msg_info_open then 
    msg_info_out = File.new($diag_dir + "\\" + base_file_name + "_msg_info.csv","w")
    $msg_info_open = true
    _title_line = "server guid,server host,msg id,startup,processing status,create time,msg size,processing duration," +
                  "delivery begin time,in-queue wait duration,ident id,task id," +
                  "timeout value,method name,msg data store,data msg cmd,class name, instance number,error text,msg role,msg zone, create pid, process pid,priority,Args,worker id"
    msg_info_out.puts(_title_line)            
    # don't make any assumptions about msg id begin or end values,
    # just process what you have....
    x.each { |key, instance|
#      if key == 2 || key == '2' then
#        puts ""
#      end
      if instance.msg_queued_time == nil || instance.msg_queued_time == "" then
        if instance.deliver_begin_time.class != instance.create_time.class then
#          puts "#{File.basename(__FILE__)}:#{__LINE__}"
           instance.msg_queued_time = -1
        else
          instance.msg_queued_time = instance.deliver_begin_time - instance.create_time
        end
      end
      instance.data_msg_cmd = instance.data_msg_cmd.tr('[]',' ').strip if instance.data_msg_cmd != nil
      if instance.msg_class_name == nil then              # if the message has no class name

        if instance.data_msg_cmd == nil then  
#        puts "#{__FILE__}:#{__LINE__}- #{instance.inspect}"
            instance.msg_class_name = instance.msg_role
          else 

          _work_array = instance.data_msg_cmd.split(".")    # lets try to build one from the msg cmd
            if _work_array.size > 1 then                      # if the msg cmd has a '.' then assume that to be the class
              instance.msg_class_name = _work_array[0].tr('[',' ').strip        # and inject it into the msg_class_name value
            end
         end       
      end
      msg_info_out.puts("#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
          "#{key},#{instance.msg_startup_cnt},#{force_empty_string(instance.msg_delivery_complete_status)},#{instance.create_time}," +
          "#{instance.msg_size},#{instance.msg_process_duration},#{instance.deliver_begin_time},#{instance.msg_queued_time}," +
          "#{instance.ident_id},#{instance.task_id},#{instance.timeout_duration},#{force_empty_string(instance.msg_method_name)}," +
          "#{force_empty_string(instance.msg_data_store)},#{force_empty_string(instance.data_msg_cmd)},#{force_empty_string(instance.msg_class_name)},#{instance.msg_instance_id}," +
          "#{force_empty_string(instance.error_text)}," +
          "#{force_empty_string(instance.msg_role)},#{force_empty_string(instance.msg_zone)}," +
          "#{instance.put_pid},#{instance.process_pid},#{instance.msg_priority},#{force_empty_string(instance.msg_args)},#{instance.worker_id}")
      
    }
    msg_info_out.close
    $msg_info_open = nil
  end
end
def force_empty_string(in_string)
  if in_string == nil || in_string == "" then
#    puts "#{__FILE__}:#{__LINE__}- force_empty_string routine :: #{in_string} changed to '\"\"'"
    in_string = '" "'

  else
    in_string = in_string
  end
end