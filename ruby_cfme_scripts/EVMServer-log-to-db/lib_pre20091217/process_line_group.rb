=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_line_group.rb 17490 2009-12-02 20:38:41Z thennessy $
=end
def process_line_group(line_group_in)
#    if /starting\. PID \[24751\]/ =~ line_group_in[0] then
#    puts "#{__FILE__}:#{__LINE__}=>#{line_group_in[0]}"
#  end
# look for stopping worker literal
#  line_group_in.each do |x|
#    if /communicates with/ =~ line_group_in[0] then
#    puts "#{__FILE__}:#{__LINE__}->#{line_group_in[0]}"
#    end
#  end

  $Parsed_log_line = Parsed_log_line.new(line_group_in[0])
#  puts "#{$Saved_parsed_log_line.class}"
  if $Saved_parsed_log_line.class != $Parsed_log_line.class then
    inter_line_delay = 0
  else
    inter_line_delay = 0
    inter_line_delay = $Parsed_log_line.log_datetime.to_i - $Saved_parsed_log_line.log_datetime.to_i 
      if inter_line_delay > $delay_limit then
        puts "intra-log line time delay of #{inter_line_delay} seconds exceed #{$delay_limit} seconds- current log line follows:" +
          "\n\t#{line_group_in[0]}"
        _note_it = $Parsed_log_line
        _note_it.payload = "gap in log before this line of #{$delay_limit} seconds.\n#{_note_it.payload}"


#          "\n\tprior log line:#{$Saved_parsed_log_line.inspect}\n\tcurrent log line:#{$Parsed_log_line.inspect}"
      end
      if inter_line_delay < 0 then
        _note_it = $Parsed_log_line
        _note_it.payload = "*** current log line is retrograde with respect to preceeding log lines by #{inter_line_delay} seconds.  log line follows:\n'#{line_group_in[0]}' ****\n"
        log_line_of_interest(_note_it)
      end
      $Saved_parsed_log_line = $Parsed_log_line
    end
   x = $Parsed_log_line
  case x.payload
#  when /job will not be added/ then log_line_of_interest(x)          # job not added to jobs table because similar jog already exists
#  I have decided to ignore the line above since there are so many of these in accumulate
  when /Database Adapter/ then log_line_of_interest(x)               #capture startup line
#  when $La_000 then log_line_of_interest(x)
  when /exceeded limit/ then log_line_of_interest(x)                 # capture  limit exceeded line
  when /exceeded / then log_line_of_interest(x)                      # capture threshold or swap space warning message
#  when $La_001 then log_line_of_interest(x)
  when /takeover/ then log_line_of_interest(x)                       # get awareness to takeover activity
#  when $La_002 then log_line_of_interest(x)
  when /power state/ then log_line_of_interest(x)                    # get awareness of power state changes
#  when $La_003 then log_line_of_interest(x)
  when /roles have changed/ then log_line_of_interest(x)             # get awareness of role changes
  when /role added/ then log_line_of_interest(x)                     # get awareness of role changes
  when /Old roles/ then log_line_of_interest(x)
  when /New roles/ then log_line_of_interest(x)                      #
  when /Roles added/ then log_line_of_interest(x)                    #
  when /Roles removed/ then log_line_of_interest(x)              #      #      #
  when /role removed/ then log_line_of_interest(x)                   #
  when /Roles unchanged/ then log_line_of_interest(x)                   #
  when /Workers are being synchronized/ then log_line_of_interest(x)  #
#  when $La_004 then log_line_of_interest(x)
  when /remove_snapshot_by_description/ then 
    log_line_of_interest(x) if /run_miq_cmd/ =~ x.payload            # only collect log lines where we have to delete the snapshot via failsafe
#  when $La_005 then log_line_of_interest(x)
                                                                     # get awareness of snapshot removal issues
  when /Unable to establish vim connection/ then log_line_of_interest(x) # capture vim connection failures
  when /VM scan job will not be added/ then log_line_of_interest(x) # scan jobs are scheduled too frequently
  when /Not enough free memory/ then log_line_of_interest(x) # indicates a memory problem in the system
  when /\% of swap/ then log_line_of_interest(x)             # capture any of the swap messages
  when /Stopping all workers/ then log_line_of_interest(x)   # catpure miqserver timeout messages
  when /\-stop\) Stopping worker\:/ then log_line_of_interest(x) # capture unusual stopping messages
  when /Stopping Broker/ then log_line_of_interest(x)        # if broker is shutting down, find out why

  end

#  _examine_pid = line_group_in[0].split                 #split into workds
#  $Parsed_log_line.log_pid = _examine_pid[3].tr("#]","  ").strip #look at PID field and remove non-pid characters
#  if _examine_pid[3] != "5373" then
#    puts "#{__FILE__}:#(__LINE__}"
#  end
  $line_group_pid = $Parsed_log_line.log_pid                     # set this as a global variable for reference everywhere

  if $active_processes.empty? || !$active_processes.has_key?($Parsed_log_line.log_pid)  then #if there is no entry in active process list
                                                         # then create one
                                                         # after checking to see if the process counts have wrapped
    if $line_group_pid.to_i < $last_pid then                            # if new pid is less than last high pid
      $pid_cycle += 1                                                   # increment pid recycle count
      $last_pid = $line_group_pid.to_i                                  # and set new pid as $last_pid
    else
      $last_pid = $line_group_pid.to_i                               # else just make new pid as $last_pid value
    end

# review all $active_processes and identify elements that we haven't heart from in more than 7250 seconds
_close_process = Array.new
  $active_processes.each do |xamine_process|
    if $Parsed_log_line.log_datetime &&                         # make sure log_datetime isnlt empty
        xamine_process[1]["last heard from seconds"] &&         # make sure last_heart_from_seconds isn't empty
        $Parsed_log_line.log_datetime - xamine_process[1]["last heard from seconds"]   > 7400 then            #this exceeds the default interval by 3 minutes +
#      puts "#{__FILE__}:#{__LINE__}=> ********** probable inactive process follows ****** current time is #{$Parsed_log_line.log_datetime}\n\t time since last hear from is #{$Parsed_log_line.log_datetime - xamine_process[1]["last heard from seconds"]} seconds"
#      pp xamine_process
      _close_process << xamine_process[0]
    end
    if xamine_process[1]["killed"] &&                           #if process is killed and we haven't heard from it in 300 seconds, then harvest the process
       xamine_process[1]["last heard from seconds"] &&
     $Parsed_log_line.log_datetime - xamine_process[1]["last heard from seconds"]   > 300 then 
      _close_process << xamine_process[0]
    else
        if xamine_process[1]["killed"] &&                           #if process is killed and we haven't heard from it in 300 seconds, then harvest the process
       xamine_process[1]["last heard from seconds"] == nil then       # if no lasst heard from time
#     $Parsed_log_line.log_datetime - xamine_process[1]["last heard from seconds"]   > 300 then
                                                                      # if the process is killed and there is not last heard from date then just harvest the process
      _close_process << xamine_process[0]
        end
    end
    if $Parsed_log_line.log_datetime &&
        xamine_process[1]["detected_exit_seconds"] &&
        $Parsed_log_line.log_datetime - xamine_process[1]["detected_exit_seconds"] > 120 then
      _close_process << xamine_process[0]
# above logic is intended to close pids after waiting 120 seconds log time so that log lines that
#  are posted after the worker is signaled to exit are captured into the right pid_file
#  and doesn't cause too much needless file processing.
    end    
    end


    if _close_process.size > 0 then
      puts "inactive processes being removed from active process list"
      pp _close_process
      _close_process.each do |pid|
        # it is possible that the same key may occurr multiple times in this hash so 
        # before processing each instance, lets make sure it is still in the hash
        if $active_processes.has_key?(pid) then
#        if pid.class.to_s == "NilClass" or $active_processes[pid].class.to_s == "NilClass" || $active_processes[pid]["PID"].class.to_s == "NilClass" then
#          puts "PID value is #{pid}"
#          puts "$active_processes hash entry for pid is #{$active_processes[pid].inspect}"
#          puts "PID value from hash instance is #{$active_processes[pid]["PID"].inspect}"
#        else
         archive_active_process($active_processes[pid]["PID"])
        end

#        _pid_file = $active_processes[pid]["file_handle"]
#        _pid_file.close
#        $active_processes[pid]["file_handle"] = nil
#        $active_processes[pid]["file_status"] = "closed"
#        $all_process_archive << $active_processes[pid]
#        $active_processes.delete(pid)
      end
      puts "active process count after removing inactive processes is #{$active_processes.size}"
    end



     $active_processes[$Parsed_log_line.log_pid] = {"PID" => $Parsed_log_line.log_pid ,
       "first seen" => $Parsed_log_line.log_datetime_string.split(".")[0] ,"first seen seconds" => $Parsed_log_line.log_datetime,
       "last heard from" => $Parsed_log_line.log_datetime_string.split(".")[0] , "last heard from seconds" => $Parsed_log_line.log_datetime,
       "process type" => nil,
       "GUID" => nil, "started" => nil, "lines" => 0, "build id" => nil, "log id" => nil, "lines after exit" => 0,
       "error_cnt" => 0, "warn_cnt" => 0, "fatal_cnt" => 0, "debug_cnt" => 0, "startup count" => $startup_cnt,
       "requested_exit" => nil, "detected_exit" => nil, "detected_exit_seconds" => nil,
       "killed" => nil, "requested_exit_reason" => nil,
       "file_status" => "closed", "file_handle" => nil,
       "server_guid" => nil, "server_hostname" => nil,
#       "server_guid" => $Startups[$startup_cnt]["server_guid"], "server_hostname" => $Startups[$startup_cnt]["host"]
     }
     #conditional assignments for server guid and host name
     $active_processes[$Parsed_log_line.log_pid]["server_guid"] = $Startups[$startup_cnt]["server_guid"] if $Startups[$startup_cnt]
     $active_processes[$Parsed_log_line.log_pid]["server_hostname"] = $Startups[$startup_cnt]["hostname"] if $Startups[$startup_cnt]
     _new_pid_file = nil
     __open_files = 0
#     puts "#{__FILE__}:#{__LINE__}->#{$active_processes.size} active process elements"
     $active_processes.each do |_hash_item|
#       puts "#{_hash_item.size} elements in $active_processes"
       _hash_item.each do |_hash_item_instance|
         if _hash_item_instance.class.to_s != "String" then
           puts "#{__FILE__}:#{__LINE__}->#{_hash_item_instance["PID"]}-last heard from [#{_hash_item_instance["last heard from"]} " if _hash_item_instance["file status"] == "open"
           __open_files  =+ 1 if _hash_item_instance["file status"] == "open"
        end

       end
    end
    puts "#{__FILE__}:#{__LINE__}-> current open file count is #{__open_files}" if __open_files > 0
    if File.exist?($pid_dir + "\\" +
         "Active_process_#{$Parsed_log_line.log_pid.to_s.rjust(5,"0")}_#{$startup_cnt}_#{$pid_cycle}_" + $base_file_name + ".log") then 
        puts "#{__FILE__}:#{__LINE__}-> trying to overwrite existing file #{$pid_dir + "\\" +
         "Active_process_#{$Parsed_log_line.log_pid.to_s.rjust(5,"0")}_#{$startup_cnt}_#{$pid_cycle}_" + $base_file_name + ".log"}"
         puts "#{line_group_in}"
    end
     _new_pid_file = File.new($pid_dir + "\\" +
         "Active_process_#{$Parsed_log_line.log_pid.to_s.rjust(5,"0")}_#{$startup_cnt}_#{$pid_cycle}_" +
         $base_file_name + ".log","w") if $create_pid_files
     # keep one file name for EVM and another for PRODUCTION until merged
#     line_group_in.each do |x|
#       puts._new_pid_file(x)
#     end
     if $base_file_name == "production" then
       puts "#{__FILE__}:#{__LINE__}"
     end
     $active_processes[$Parsed_log_line.log_pid]["file_handle"] =  _new_pid_file
     $active_processes[$Parsed_log_line.log_pid]["file_status"] =  "open" if $create_pid_files
  else
#  puts "#{__FILE__}:#{__LINE__}->line group 0 => #{line_group_in[0].inspect}"

  end
  case $active_processes[$Parsed_log_line.log_pid]["file_status"]
  when /open/ then 
  _pid_file = $active_processes[$Parsed_log_line.log_pid]["file_handle"]
  line_group_in.each do |_x|
      _pid_file.puts "#{_x}" if _pid_file
      $active_processes[$Parsed_log_line.log_pid]["lines"] += 1
      $active_processes[$Parsed_log_line.log_pid]["lines after exit"] += 1     if $active_processes[$Parsed_log_line.log_pid]["requested_exit_reason"]
      ## count lines after logical process exit !!!
     end    
  when /closed/ then
   _pid_file = $active_processes[$Parsed_log_line.log_pid]["file_handle"]
#    puts "attempt to write to closed file for pid \"#{$Parsed_log_line.log_pid}\"\: log lines follow\: "
    line_group_in.each do |_x|
        puts "Active_pid_ file for pid '#{$Parsed_log_line.log_pid}' already closed for log line \n\t#{_x} "
#       _pid_file.puts "#{_x}" if _pid_file                       # if file still current
      $active_processes[$Parsed_log_line.log_pid]["lines"] += 1          # increment gross line count for process
      $active_processes[$Parsed_log_line.log_pid]["lines after exit"] += 1     # count lines after logical process exit !!!

#    puts "\t#{__FILE__}:#{__LINE__}->#{_x}"
    end
  end
# the following code may not be precisely correct, but it should get us close enought to the last time
# that the process is recognized in the log handler by using the time of the first line in the line group
$active_processes[$line_group_pid]["last heard from"] = $Parsed_log_line.log_datetime_string
$active_processes[$line_group_pid]["last heard from seconds"] = $Parsed_log_line.log_datetime

  case line_group_in[0]
  when /ERROR --/ then $active_processes[$line_group_pid]["error_cnt"] += 1
#    when $La_008 then $active_processes[$line_group_pid]["error_cnt"] += 1
  when /WARN --/  then $active_processes[$line_group_pid]["warn_cnt"] += 1
#    when $La_009 then $active_processes[$line_group_pid]["error_cnt"] += 1
  when /DEBUG --/ then $active_processes[$line_group_pid]["debug_cnt"] += 1
#    when $La_010 then $active_processes[$line_group_pid]["error_cnt"] += 1
  when /FATAL --/ then $active_processes[$line_group_pid]["fatal_cnt"] += 1
#    when $La_011 then $active_processes[$line_group_pid]["error_cnt"] += 1
  end
case $active_processes[$Parsed_log_line.log_pid]["process type"]    # added 10/19/2009 to skip over vimbroker log lines if possible
when /Vim/ then
  if /Stopping Broker/ =~ line_group_in[0] || /exit/ =~ line_group_in[0] then
      if line_group_in.size == 1 then process_single_line(line_group_in)
        else process_multiline_group(line_group_in)
      end
  end
#  puts "#{__FILE__}:#{__LINE__}- vim broker log line"
else
  if line_group_in.size == 1 then process_single_line(line_group_in)
  else process_multiline_group(line_group_in)
  end
end
  # empty the array since all processing should be completed
  # line_group_in = line_group_in.clear 
  line_group_in.clear
#end
end
class Log_Processes_Info
  attr_accessor :key_field, :process_guid, :process_type, :process_timeout
    attr_accessor :start_time, :line_cnt, :error_cnt, :warn_cnt, :fatal_cnt
    attr_accessor :requested_exit_time, :requested_exit_info, :detected_exit_time
    attr_accessor :max_used_storage, :cpu_time_used, :last_heart_from
    attr_accessor :file_status, :file_handle
  def initialize(parsed_logline)     #consider using already parsed log line as input
    @key_field = nil                  #combine startup cnt, pid#, & bld number for uniqueness
    @process_guid = nil               # if process has guid put it here
    @process_type = nil               # if process type is known, put it here
    @process_timeout = nil            # if separate timeout info put it here
    @start_time = nil                 # time when process first detected
    @line_cnt = 0                     # each time a line is added, increment this
    @error_cnt = 0                    # for each error detected increment
    @warn_cnt = 0                     # for each warning detected increment
    @fatal_cnt = 0                    # for each fatal msg detected , increment
    @requested_exit_time = nil        # if we detect another process requesting this one terminate, put info here
    @requested_exit_info = nil        # gather pid, worker type of process requesting exit
    @detected_exit_time = nil         # when/if log reports exit ending record here
    @max_used_storage = nil           # record maximum storage attributed to this process
    @cpu_time_used = nil              # collect cpu time
    @last_heard_from_time = nil       # time last log line recognized
    @file_status = "initial"               # for output file -status (open or closed)
    @file_handle = nil                # if file is open then put file object here

  end
end
