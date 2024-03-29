=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_miqserver_count_for_state.rb 22406 2010-07-25 17:07:44Z thennessy $
=end

def process_miqserver_count_for_state(payload)

if $queue_counts_by_table == nil then
  $queue_counts_by_table = File.new($diag_dir + $directory_separator + "queue_counts_by_table_" + $base_file_name + ".csv","w")
  $queue_counts_by_table.puts "server guid,host,appliance name,startup,date and time,table type,zone,state or process type,role,count"

end
#[----] I, [2010-02-19T01:51:31.935645 #2594]  INFO -- :
#MIQ(MiqServer-system_status) [EVM Server (2166)] MiqQueue count for state=["ready"] by role: {"smartstate"=>1}
#MIQ(MiqServer-system_status) [EVM Server (2887)] Job count for state=["finished"] by process_type: {"VmScan"=>822}

case payload.miq_post_cmd
when /\]\s*(\S*)\s*count for state=\[(.*)?\]\s*by\s*(role|process_type)\:\s*(.*)/ then
  _table_type = $1
  _state = $2.tr('"'," ").strip
  _role_types = $4

  current_startup = $Startups[$startup_cnt]
  _log_time = $Parsed_log_line.log_datetime_string.split(".")[0]  
  if _role_types != nil then
  _role_array = _role_types.tr("{}","  ").strip.split(",") 
  _role_array.each do |element|
        element_array = element.split("=>")
        _role = element_array[0].tr('"',' ').strip                            # remove double quotes if any
        _count = element_array[1]
        $queue_counts_by_table.puts "#{current_startup["server_guid"]},#{current_startup["host"]},\"#{current_startup["appliance name"]}\",#{$startup_cnt},#{_log_time},#{_table_type},,#{_state},#{_role},#{_count}"
        end
  end
#  puts "#{__FILE__}:#{__LINE__}->#{_role_array.inspect}"
#[----] I, [2010-07-23T23:44:29.939114 #4545:15a4db602f08]  INFO -- : Q-task_id([log_status])
# MIQ(MiqServer.log_system_status) [EVM Server (4436)] MiqQueue count for state=["dequeue"] by zone and role: {"default"=>{nil=>1, "smartproxy"=>1}} 
# Job count for state=["finished"] by zone and process_type: {"default"=>{"VmScan"=>954}}
when /\]\s*(\S*)\s*count for state=\[(.*)?\]\s*by\s*zone and (role|process_type)\:\s*(.*)/ then
  _table_type = $1
  _state = $2.tr('"'," ").strip
  _tmp_hash = eval "_tmp_hash = " + $4.to_s  
  current_startup = $Startups[$startup_cnt]
  _log_time = $Parsed_log_line.log_datetime_string.split(".")[0]    
#  _tmp_hash = Hash.new

  _tmp_hash.each { |zone,roles|
    roles.each {|_role,_count|

#  _role_types = $4
  $queue_counts_by_table.puts "#{current_startup["server_guid"]},#{current_startup["host"]},\"#{current_startup["appliance name"]}\",#{$startup_cnt},#{_log_time},#{_table_type},#{zone},#{_state},#{_role},#{_count}"
 
#  if _role_types != nil then
#  _role_array = _role_types.tr("{}","  ").strip.split(",")
#  _role_array.each do |element|
#        element_array = element.split("=>")
#        _role = element_array[0].tr('"',' ').strip                            # remove double quotes if any
#        _count = element_array[1]
#        $queue_counts_by_table.puts "#{current_startup["server_guid"]},#{current_startup["host"]},\"#{current_startup["appliance name"]}\",#{$startup_cnt},#{_log_time},#{_table_type},#{zone},#{_state},#{_role},#{_count}"
#        end
#  end
    }}
end
end
