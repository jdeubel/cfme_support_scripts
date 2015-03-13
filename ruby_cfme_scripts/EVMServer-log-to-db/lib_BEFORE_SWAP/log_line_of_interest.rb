=begin rdoc
$Id: log_line_of_interest.rb 16597 2009-10-12 15:36:47Z thennessy $

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
  display_log_time = log_time_array[0] + "-" + log_time_array[1] + "-" + log_time_array[2] +"T"+ log_time_array[3]+":"+log_time_array[4]+":" +log_time_array[5]+"."+log_time_array[6]
  output_line = "#{display_log_time},#{parsed_log_line.log_pid},#{parsed_log_line.payload}"
  $log_lines_of_interest.puts "#{output_line}"
  end
end
