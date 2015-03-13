require "csv"
require "rubygems"
require "fileutils"
$Global_string_hash = Hash.new
def close_all_files
  puts "writing arrays to output files and closing output files"
 $msg_ids_file = File.new("test_msg_ids.csv","w")
 $msg_ids_file.puts("msg_id_id,msg_id")
 puts("msg id id, msgid")
  array_to_file($msg_ids,$msg_ids_file)
# $msg_ids = Array.new
#$db_record_ids = Array.new
#$db_record_ids_file = File.new("test_db_record_ids.csv","w")
#  array_to_file($db_record_ids,$db_record_ids_file)
#
#$msg_class_names = Array.new
$msg_class_names_file = File.new("test_msg_class_names.csv","w")
$msg_class_names_file.puts("msg_class_name_id,msg_class")
puts("msg_class_name_id,msg class")
  array_to_file($msg_class_names, $msg_class_names_file)

#$msg_data_msg_cmds = Array.new
$msg_data_msg_cmds_file = File.new("test_msg_data_msg_cmds.csv","w")
$msg_data_msg_cmds_file.puts("msg_data_msg_cmd_id,msg_data_msg_cmd")
puts("msg_data_msg_cmds_id,msg data msg cmd")
  array_to_file($msg_data_msg_cmds, $msg_data_msg_cmds_file)
  
#$msg_data_stores = Array.new
$msg_data_stores_file = File.new("test_msg_data_stores.csv","w")
$msg_data_stores_file.puts("msg_data_store_id,msg_data_store")
puts("msg_data_stores_id,msg data stores")
  array_to_file($msg_data_stores, $msg_data_stores_file)
 
#$msg_error_texts = Array.new
$msg_error_texts_file = File.new("test_msg_error_texts.csv","w")
$msg_error_texts_file.puts("msg_error_text_id,msg_error_text")
puts("msg_error_text_id,msg error text")
  array_to_file($msg_error_texts, $msg_error_texts_file)
 
#$msg_ident_ids = Array.new
$msg_ident_ids_file = File.new("test_msg_ident_ids.csv","w")
$msg_ident_ids_file.puts("msg_ident_id_id,msg_ident_id")
puts("msg_ident_id_id,msg ident id")
  array_to_file($msg_ident_ids, $msg_ident_ids_file)
 
#$msg_method_names = Array.new
$msg_method_names_file = File.new("test_msg_method_names.csv","w")
$msg_method_names_file.puts("msg_method_name_id,msg_method_name")
puts("msg_method_names_id,msg method name")
  array_to_file($msg_method_names, $msg_method_names_file)
 
#$msg_processing_status = Array.new
$msg_processing_status_file = File.new("test_msg_processing_status.csv","w")
$msg_processing_status_file.puts("msg_processing_status_id,msg_processing_status")
puts("msg_processing_status_id,msg processing status")
  array_to_file($msg_processing_status, $msg_processing_status_file)
 
#$msg_roles = Array.new
$msg_roles_file = File.new("test_msg_roles.csv","w")
$msg_roles_file.puts("msg_role_id,msg_role")
puts("msg_role_id,msg role")
  array_to_file($msg_roles, $msg_roles_file)
 
#$msg_server_guids = Array.new
$msg_server_guids_file = File.new("test_msg_server_guids.csv","w")
$msg_server_guids_file.puts("msg_server_guid_id,msg_server_guid")
puts("msg_server_guid_id,msg server guid")
  array_to_file($msg_server_guids, $msg_server_guids_file)
 
#$msg_server_hosts = Array.new
$msg_server_hosts_file = File.new("test_msg_server_hosts.csv","w")
$msg_server_hosts_file.puts("msg_server_host_id,msg_server_host")
puts("msg_server_host_id,msg server host")
  array_to_file($msg_server_hosts, $msg_server_hosts_file)

#$msg_task_ids = Array.new
$msg_task_ids_file = File.new("test_msg_task_ids.csv","w")
$msg_task_ids_file.puts("msg_task_id_id,msg_task_id")
puts("msg_task_id_id,msg task id")
  array_to_file($msg_task_ids, $msg_task_ids_file)

#$msg_zones = Array.new
$msg_zones_file = File.new("test_msg_zones.csv","w")
$msg_zones_file.puts("msg_zone_id,msg_zone")
puts("msg_zone_id,msg zone")
  array_to_file($msg_zones, $msg_zones_file)

#$msg_args = Array.new
$msg_args_file = File.new("test_args.csv","w")
$msg_args_file.puts("msg_args_id,msg_arg")
puts("msg_args_id,msg arg")
  array_to_file($msg_args, $msg_args_file)

#$msg_worker_ids = Array.new
$msg_worker_ids_file = File.new("test_msg_worker_ids.csv","w")
$msg_worker_ids_file.puts("msg_worker_id_id,msg_worker_id")
puts("msg_worker_ids_id,msg worker id")
  array_to_file($msg_worker_ids, $msg_worker_ids_file)

#$msg_instance_numbers = Array.new
$msg_instance_numbers_file = File.new("test_msg_instance_numbers.csv","w")
$msg_instance_numbers_file.puts("msg_instance_number_id,msg_instance_number")
puts("msg_instance_number_id,msg instance number")
  array_to_file($msg_instance_numbers, $msg_instance_numbers_file)

end
def array_to_file(array,file)
  array_count = 0
  puts " array_to_file file parameter is of type #{file.class.to_s}"
  array.size.times {
                          _temp_string = array[array_count].to_s
                          if _temp_string.index(",") then
                            _temp_string = '"' + _temp_string + '"'
                          end
                          array_count += 1
                          _temp_string = array_count.to_s + "," + _temp_string
                          file.puts("#{_temp_string}")
                          puts("#{_temp_string}")
                        }
file.close
#return
end

def return_array_index(element,array)
#  puts "#{element}, #{array.inspect}"
  if element.class.to_s != "NilClass" then
    element.strip!

  else
    element = "-1"
  end
     combined_key = array.object_id.to_s + element
 if $Global_string_hash.has_key?(combined_key) then
   return_value = $Global_string_hash[combined_key]
 else
   array << element
   $Global_string_hash[combined_key] = array.size
   return_value = array.size
 end
end

#Global Arrays for processing
$msg_ids = Array.new
$db_record_ids = Array.new
$msg_class_names = Array.new
$msg_data_msg_cmds = Array.new
$msg_data_stores = Array.new
$msg_error_texts = Array.new
$msg_ident_ids = Array.new
$msg_method_names = Array.new
$msg_processing_status = Array.new
$msg_roles = Array.new
$msg_server_guids = Array.new
$msg_server_hosts = Array.new
$msg_task_ids = Array.new
$msg_zones = Array.new
$msg_args = Array.new
$msg_worker_ids = Array.new
$msg_instance_numbers = Array.new


reader = CSV.open("filtered_combined_evm_msg_info.csv","r")
writer = File.new("sorted_evm_msg_info.csv","w")
header = reader.shift
puts "#{header.inspect}"
outfile_header = "created_on_server_guid_id,created_on_server_host_id,created_on_startup," +
                 "processed_on_server_guid_id,processed_on_server_host_id,msg_id_id,processed_on_startup,msg_processing_status_id," +
                 "create_time,delivery_begin_time,processing_duration,in-queue_wait_duration,msg_ident_id_id," +
                 "msg_task_id_id,timeout_value,msg_method_name_id,msg_data_store_id,msg_data_msg_cmd_id,msg_class_name_id," +
                 "instance_number_id,msg_error_text_id,msg_role_id,msg_zone_id,priority,create_pid,process_pid,msg_args_id," +
                 "worker_id_id"

  writer.puts "00000000000000000000," + outfile_header

# input file column mapping
server_guid = 0
server_host = 1
msg_id = 2
startup = 3
processing_status = 4
raw_create_time = 5
msg_size = 6
processing_duration = 7
delivery_begin_time = 8
inqueue_wait_duration = 9
ident_id = 10
task_id = 11
timeout_value = 12
method_name = 13
msg_data_store = 14
data_msg_cmd = 15
class_name = 16
 instance_number = 17
error_text = 18
msg_role = 19
msg_zone = 20
raw_create_pid = 21
raw_process_pid = 22
raw_priority = 23
raw_args = 24
worker_id = 25

#output file column mapping
created_on_server_guid = 0          # mapped from created -> server_guid
created_on_server_host = 1          # mapped from created -> server_host
created_on_startup = 2              # mapped from created -> startup
processed_on_server_guid = 3        # mapped from delivered -> server_guid
processed_on_server_host =4         # mapped from delivered -> server_host
msg_id_id = 5                       # mapped from created -> msg_id
processed_on_startup = 6            # mapped from delivered -> startup 
msg_processing_status_id = 7        # mapped from delivered -> processing_status
combined_create_time = 8            # mapped from created-> raw_create_time
combined_delivery_begin_time = 9    # mapped from delivered -> raw_create_time
combined_processing_duration = 10            # mapped from delivered -> processing_duration
combined_inqueue_wait_duration = 11 # mapped from delivered -> inqueue_wait_duration
msg_ident_id_id = 12                # mapped from created -> ident_id
msg_task_id_id = 13                 # mapped from created => task_id
combined_timeout_value = 14         # mapped from created -> timeout_value
msg_method_name_id = 15             # mapped from created -> method_name
msg_data_store_id = 16              # mapped from created -> msg_data_store
msg_data_msg_cmd_id = 17            # mapped from created -> data_msg_cmd
msg_class_name_id = 18              # mapped from created -> class_name
msg_instance_number_id = 19         # mapped from created -> instance_number
msg_error_text_id = 20              # mapped from delivered -> error_text
msg_role_id = 21                    # mapped from created -> msg_role
msg_zone_id = 22                    # mapped from created -> msg_zone
combined_priority = 23              # mapped from created -> raw_priority
create_pid = 24                     # mapped from created -> raw_create_pid
process_pid = 25                    # mapped from delivered -> raw_process_pid
msg_args_id = 26                    # mapped from created -> raw_args
worker_id_id = 27                   # mapped from delivered -> worker_id





#exit
xcount = 0
_temp_string = Array.new
reader.each { |row|
              xcount += 1
#              _temp_string = Array.new
#              element_count = 0
#              row.size.times { |element_|
#                          element = row[element_count].to_s
#                        if element.class.to_s != "NilClass" && element.index(",") then
#                          element = '"' + element + '"'
#                        end
#                        if element.class.to_s == "NilClass" then
#                          element = ""
#                        end
#              _temp_string = _temp_string <<  element + ","
#              element_count += 1
#              }
              msgid_ = "000000000000000000" + row[2]
              msgid_ = msgid_[-18,18]
#              puts "#{msgid_}"
              case row[raw_create_time].to_s.size
              when 0 then
                record_type = "deliver"
                _temp_string[processed_on_server_guid] = return_array_index(row[server_guid],$msg_server_guids)
                _temp_string[processed_on_server_host] = return_array_index(row[server_host],$msg_server_hosts)


#processed_on_server_guid = 3        # mapped from delivered -> server_guid
                _temp_string[processed_on_server_guid] = return_array_index(row[server_guid],$msg_server_guids)
#processed_on_server_host =4         # mapped from delivered -> server_host
                _temp_string[processed_on_server_host] = return_array_index(row[server_host],$msg_server_hosts)

                _temp_string[msg_id_id] = return_array_index(row[msg_id],$msg_ids)
#                puts "index for msg_id #{row[msg_id]} is #{_temp_string[msg_id_id]}"

#processed_on_startup = 6            # mapped from delivered -> startup
                _temp_string[processed_on_startup] = row[startup]
#msg_processing_status_id = 7        # mapped from delivered -> processing_status
                _temp_string[msg_processing_status_id] = return_array_index(row[processing_status],$msg_processing_status)
#combined_delivery_begin_time = 9    # mapped from delivered -> raw_create_time
                _temp_string[combined_delivery_begin_time] = row[delivery_begin_time]
#combined_processing_duration = 10            # mapped from delivered -> processing_duration
                _temp_string[combined_processing_duration] = row[processing_duration]
#combined_inqueue_wait_duration = 11 # mapped from delivered -> inqueue_wait_duration
                _temp_string[combined_inqueue_wait_duration] = row[inqueue_wait_duration]
#msg_error_text_id = 19              # mapped from delivered -> error_text
                _temp_string[msg_error_text_id] = return_array_index(row[error_text],$msg_error_texts)
#process_pid = 24                    # mapped from delivered -> raw_process_pid
                _temp_string[process_pid] = row[raw_process_pid]
#worker_id_id = 26                   # mapped from delivered -> worker_id
                _temp_string[worker_id_id] = return_array_index(row[worker_id],$msg_worker_ids)
 # change introduced 5/7/2012 to ensure that method name info is captured for messages created prior to log capture               
                _temp_string[msg_ident_id_id] = return_array_index(row[ident_id],$msg_ident_ids)
                _temp_string[msg_task_id_id]  = return_array_index(row[task_id],$msg_task_ids)
                _temp_string[combined_timeout_value] = row[timeout_value]
                _temp_string[msg_method_name_id] = return_array_index(row[method_name],$msg_method_names)
                _temp_string[msg_data_store_id] = return_array_index(row[msg_data_store],$msg_data_stores)
                _temp_string[msg_data_msg_cmd_id] = return_array_index(row[data_msg_cmd],$msg_data_msg_cmds)
                _temp_string[msg_class_name_id] = return_array_index(row[class_name],$msg_class_names)
                _temp_string[msg_instance_number_id] = return_array_index(row[instance_number],$msg_instance_numbers)
                
 # end of 5/7/2012 change                
                
             
0              else
                record_type = "create"
=begin
created_on_server_guid = 0          # mapped from created -> server_guid
created_on_server_host = 1          # mapped from created -> server_host
created_on_startup = 2              # mapped from created -> startup
msg_id_id = 5                       # mapped from created -> msg_id
combined_create_time = 8            # mapped from created-> raw_create_time
msg_ident_id_id = 12                # mapped from created -> ident_id
combined_timeout_value = 13         # mapped from created -> timeout_value
msg_method_name_id = 14             # mapped from created -> method_name
msg_data_store_id = 15              # mapped from created -> msg_data_store
msg_data_msg_cmd_id = 16            # mapped from created -> data_msg_cmd
msg_class_name_id = 17              # mapped from created -> class_name
msg_instance_number_id = 18         # mapped from created -> instance_number
msg_role_id = 20                    # mapped from created -> msg_role
msg_zone_id = 21                    # mapped from created -> msg_zone
combined_priority = 22              # mapped from created -> raw_priority
create_pid = 23                     # mapped from created -> raw_create_pid
msg_args_id = 25                    # mapped from created -> raw_args
=end
                
                _temp_string[created_on_server_guid] = return_array_index(row[server_guid],$msg_server_guids)
                _temp_string[created_on_server_host] = return_array_index(row[server_host],$msg_server_hosts)
                _temp_string[created_on_startup] = row[startup]
                _temp_string[msg_id_id] = return_array_index(row[msg_id],$msg_ids)
#                puts "index for msg_id #{row[msg_id]} is #{_temp_string[msg_id_id]}"
                _temp_string[combined_create_time] = row[raw_create_time]
                _temp_string[msg_ident_id_id] = return_array_index(row[ident_id],$msg_ident_ids)
                _temp_string[msg_task_id_id]  = return_array_index(row[task_id],$msg_task_ids)
                _temp_string[combined_timeout_value] = row[timeout_value]
                _temp_string[msg_method_name_id] = return_array_index(row[method_name],$msg_method_names)
                _temp_string[msg_data_store_id] = return_array_index(row[msg_data_store],$msg_data_stores)
                _temp_string[msg_data_msg_cmd_id] = return_array_index(row[data_msg_cmd],$msg_data_msg_cmds)
                _temp_string[msg_class_name_id] = return_array_index(row[class_name],$msg_class_names)
                _temp_string[msg_instance_number_id] = return_array_index(row[instance_number],$msg_instance_numbers)
                _temp_string[msg_role_id] = return_array_index(row[msg_role],$msg_roles)
                _temp_string[msg_zone_id] = return_array_index(row[msg_zone],$msg_zones)
                _temp_string[combined_priority] = row[raw_priority]
                _temp_string[create_pid] = row[raw_create_pid]
                _temp_string[msg_args_id] = return_array_index(row[raw_args],$msg_args)
              end

              _outstring = msgid_ + "," + _temp_string.join(",")
              _temp_string.clear
              puts "#{xcount}, #{_outstring}"
              
              writer.puts _outstring

            }
            puts "#{xcount} records processed"
            writer.close

            close_all_files

            sort_em = "cmd.exe /C sort //+1 sorted_evm_msg_info.csv"
            puts sort_em
            sortem_results = `sort_em`
            puts sortem_results
exit
