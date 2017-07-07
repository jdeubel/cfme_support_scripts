=begin rdoc
this code module will handle the output processing of log_msg_info class
instances into an output file based on the name of the current input file.
the initial convention will be the base_file_name + "msg_info.csv"

After csv processing is completed, I'll add in ActiveRecord processing
to capture complete log/customer/appliance context
but appliance logging is still in flux and I'd rather wait for some level
of new implementation before beginning this.

$Id: msg_data_finalize.rb 24123 2010-10-08 22:08:53Z thennessy $

=end
#require "dictionary"
#$large_integer = Hash.new
#$large_integer = Array.new(5000000,nil)  # start with 5 million instances  to see how big this gets.

$large_integer_index = 0                 # use to store values without any missing entries
$msg_server_guid = Hash.new
$msg_server_host = Hash.new
$msg_processing_status = Hash.new
$msg_ident_id = Hash.new
$msg_task_id = Hash.new
$msg_method_name = Hash.new
$msg_data_store = Hash.new
$msg_data_msg_cmd = Hash.new
$msg_class_name = Hash.new
$msg_error_text = Hash.new
$msg_role = Hash.new
$msg_zone = Hash.new
$msg_args = Hash.new


$msg_info_open = nil
$msg_info_out = nil
# set to false initially and then set to true when later modules are called
# for processing when logs are finally processed
def msg_info_to_csv(base_file_name,x)
  # first parm is base file name then 
  # expect single hash where key is msgid and value is 
  # instance of log_msg_info class
  if !$msg_info_open then 
    $msg_info_out = File.new($diag_dir +  $directory_separator + $base_file_name + "_msg_info.csv","w")
    $msg_info_open = true
    _title_line = "server guid,server host,msg id,startup,processing status,create time,msg size,processing duration," +
                  "delivery begin time,in-queue wait duration,ident id,task id," +
                  "timeout value,method name,msg data store,data msg cmd,class name, instance number,error text,msg role,msg zone, create pid, process pid,priority,Args,worker id"
    $msg_info_out.puts(_title_line)
    # don't make any assumptions about msg id begin or end values,
    # just process what you have....
  end
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
      if $Startups[$startup_cnt]["server_guid"] != nil then
        if !$msg_server_guid.has_key?($Startups[$startup_cnt]["server_guid"]) || $msg_server_guid.empty?  then
          $msg_server_guid[$Startups[$startup_cnt]["server_guid"]] = 1
        else
          $msg_server_guid[$Startups[$startup_cnt]["server_guid"]]+= 1
        end
      end

    if $Startups[$startup_cnt]["hostname"] != nil then
        if !$msg_server_host.has_key?($Startups[$startup_cnt]["hostname"]) || $msg_server_host.empty?  then
          $msg_server_host[$Startups[$startup_cnt]["hostname"]] = 1
        else
          $msg_server_host[$Startups[$startup_cnt]["hostname"]] += 1
        end
    end
    if instance.msg_delivery_complete_status != nil then
      if !$msg_processing_status.has_key?(instance.msg_delivery_complete_status) || $msg_processing_status.empty?  then
        $msg_processing_status[instance.msg_delivery_complete_status] = 1
      else
        $msg_processing_status[instance.msg_delivery_complete_status] += 1
      end
    end
    if instance.ident_id != nil then
      if !$msg_ident_id.has_key?(instance.ident_id) || $msg_ident_id.empty? then
        $msg_ident_id[instance.ident_id] = 1
      else
        $msg_ident_id[instance.ident_id] += 1
      end
    end
    if  instance.task_id != nil then
      if !$msg_task_id.has_key?(instance.task_id) || $msg_task_id.empty?  then
        $msg_task_id[instance.task_id] = 1
      else
        $msg_task_id[instance.task_id] += 1
      end
    end
    if instance.msg_method_name  != nil then
      if !$msg_method_name.has_key?(instance.msg_method_name) || $msg_method_name.empty?  then
        $msg_method_name[instance.msg_method_name] = 1
      else
        $msg_method_name[instance.msg_method_name] += 1
      end
    end
    if instance.msg_data_store != nil then
      if !$msg_data_store.has_key?(instance.msg_data_store) || $msg_data_store.empty?  then
        $msg_data_store[instance.msg_data_store] = 1
      else
        $msg_data_store[instance.msg_data_store] += 1
      end
    end
    if instance.data_msg_cmd != nil then
      if !$msg_data_msg_cmd.has_key?(instance.data_msg_cmd) || $msg_data_msg_cmd.empty?  then
        $msg_data_msg_cmd[instance.data_msg_cmd] = 1
      else
        $msg_data_msg_cmd[instance.data_msg_cmd] += 1
      end
    end
    if instance.msg_class_name != nil then
      if !$msg_class_name.has_key?(instance.msg_class_name) || $msg_class_name.empty?  then
        $msg_class_name[instance.msg_class_name] = 1
      else
        $msg_class_name[instance.msg_class_name] += 1
      end
    end
    if instance.error_text != nil then
      if !$msg_error_text.has_key?(instance.error_text) || $msg_error_text.empty?  then
        $msg_error_text[instance.error_text] = 1
      else
        $msg_error_text[instance.error_text] += 1
      end
    end
    if instance.msg_role != nil then
      if !$msg_role.has_key?(instance.msg_role) || $msg_role.empty? then
        $msg_role[instance.msg_role] = 1
      else
        $msg_role[instance.msg_role] += 1
      end
    end
    if instance.msg_zone != nil then
      if !$msg_zone.has_key?(instance.msg_zone) || $msg_zone.empty?  then
        $msg_zone[instance.msg_zone] = 1
      else
        $msg_zone[instance.msg_zone] += 1
      end
    end
#    if instance.msg_args != nil then
      if !$msg_args.has_key?(instance.msg_args) || $msg_args.empty?  then
        $msg_args[instance.msg_args] = 1
      else
        $msg_args[instance.msg_args] += 1
      end
#    end
      $msg_info_out.puts("#{$Startups[$startup_cnt]["server_guid"]},#{$Startups[$startup_cnt]["hostname"]}," +
          "#{key},#{instance.msg_startup_cnt},#{force_empty_string(instance.msg_delivery_complete_status)},#{instance.create_time}," +
          "#{instance.msg_size},#{instance.msg_process_duration},#{instance.deliver_begin_time},#{instance.msg_queued_time}," +
          "#{instance.ident_id},#{instance.task_id},#{instance.timeout_duration},#{force_empty_string(instance.msg_method_name)}," +
          "#{force_empty_string(instance.msg_data_store)},#{force_empty_string(instance.data_msg_cmd)},#{force_empty_string(instance.msg_class_name)},#{instance.msg_instance_id}," +
          "#{force_empty_string(instance.error_text)}," +
          "#{force_empty_string(instance.msg_role)},#{force_empty_string(instance.msg_zone)}," +
          "#{instance.put_pid},#{instance.process_pid},#{instance.msg_priority},#{force_empty_string(instance.msg_args)},#{instance.worker_id}")
      
    }
    if x.size > 1 then        # if only a single element in hash then leave open as updates are dribbling ine
                              #otherwise expect it is final cleanup with many instances
                              # and close up at that point
      $msg_info_out.close
      $msg_info_open = nil
    end
  end
#end
def force_empty_string(in_string)
  if in_string == nil || in_string == "" then
#    puts "#{__FILE__}:#{__LINE__}- force_empty_string routine :: #{in_string} changed to '\"\"'"
    in_string = '" "'

  else
    in_string = in_string
  end
end