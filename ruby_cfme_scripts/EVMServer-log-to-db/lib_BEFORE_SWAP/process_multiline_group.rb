=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_multiline_group.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def process_multiline_group(multi_line)
  $processed_multi_line_groups += 1
  if /DEBUG --/ =~ multi_line[0] then
    $debug_line_count += multi_line.size
    #increment count of debug and associated lines
  end
  if /Worker exiting./ =~ multi_line[-1] then
    if /role added, restarting./ =~ multi_line[-1] then
      $active_processes[$line_group_pid]["requested_exit_reason"] = "restarting for roll-added reason"
    end
    $active_processes[$line_group_pid]["detected_exit"] = $Parsed_log_line.log_datetime_string
    $active_processes[$line_group_pid]["detected_exit_seconds"] = $Parsed_log_line.log_datetime
    if $active_processes[$line_group_pid]["file_status"] == "open" then
#      $active_processes[$line_group_pid]["file_status"] = "closed"  # change file status to closed
#      _temp_file = $active_processes[$line_group_pid]["file_handle"] # get file handle
#      _temp_file.close                                               # close the file
#      $active_processes[$line_group_pid]["file_handle"] = nil        # reset the file handle since the file is now closed
      if $active_processes[$line_group_pid]["requested_exit_reason"] == nil  then
        $active_processes[$line_group_pid]["requested_exit_reason"] = "terminated by error"
      end
    end
#         $all_process_archive << $active_processes[$line_group_pid]    #copy hash heap to archive array
         # now remove the entry from the active_process list
#         $active_processes.delete($line_group_pid)
  end
#  if /DEBUB --/ !~ multi_line[0] then
#    multi_line.each do |x|
#      _x = x.size
#      puts "#{x}"
#    end
#  end
# Lets see if the first line has a payload or not
_payload = multi_line[0].split("-- :")
if _payload[1].size < 3 || _payload[1] == nil then
  #if there is no payload then it is in the next non-blank line
  # so lets remove all blank lines
#  if multi_line[1].size < 3 then
    while multi_line[1].size < 3
      multi_line.delete_at(1)
    end
#  end
  multi_line[0] = multi_line[0].chomp + multi_line[1]
  multi_line.delete_at(1)
end
  
  if /^Processing/ =~ multi_line[1] then 
    multi_line[0] = multi_line[0].chomp + multi_line[1]
    multi_line.delete_at(1)
  end
  if /^ZiYa/ =~ multi_line[1] then
    multi_line[0] = multi_line[0].chomp + multi_line[1]
    multi_line.delete_at(1)
  end
  if /ActionController:/ =~ multi_line[1] && /FATAL --/ =~ multi_line[0] then
    multi_line[0] = multi_line[0].chomp + multi_line[1]
    multi_line.delete_at(1)
  end
  if /DEBUG --/ !~ multi_line[0] && $create_modified == true then
    multi_line.each do |_x|
      $modified_log.puts(_x)
    end
  end
  case multi_line[0]
  when /ERROR --/ then not_normal(multi_line)
  when /WARN --/ then not_normal(multi_line)
  when /INFO --/ then 
    log_line_summarize(multi_line[0])
  when /FATAL --/ then fatal_messages(multi_line)
  end
#    if /ERROR --|WARN --/ =~ multi_line[0] then 
#      not_normal(multi_line)
#    elsif /FATAL --/=~ multi_line[0] then
#      fatal_messages(multi_line)
#    end 
  end
