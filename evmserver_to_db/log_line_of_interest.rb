=begin rdoc
$Id: log_line_of_interest.rb 20684 2010-05-03 20:39:57Z thennessy $

=end
def log_line_of_interest(parsed_log_line)
  #this routine is called with a single line object which is an already parsed log line
  # this routine formats the output line and places it into the common ouput dataset
  if $log_lines_of_interest then                   # if loging is active then proceed
    #server guid
    #server host
    #log time
    #server startup time
    #payload or message
#  puts "#{__FILE__}:#{__LINE__}"
  log_time_array = parsed_log_line.log_raw_datetime.split
  display_log_time = log_time_array[0] + "-" + log_time_array[1] + "-" + log_time_array[2] + "T"+ log_time_array[3] + ":"+log_time_array[4] + ":" +log_time_array[5] + "." + log_time_array[6]
  output_line = "#{display_log_time},#{parsed_log_line.log_pid},#{parsed_log_line.payload}"
  $log_lines_of_interest.puts "#{output_line}"
  end
end
def determine_if_log_line_of_interest(parsed_log_line)
  x = parsed_log_line
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
  when /MiqQueue Destroy/ then log_line_of_interest(x)
  when /Stopping worker\:/ then log_line_of_interest(x)
  when /restarting worker/ then log_line_of_interest(x)
    when /Worker exiting/ then log_line_of_interest(x)
    when /started\./ then log_line_of_interest(x)
  end
end
