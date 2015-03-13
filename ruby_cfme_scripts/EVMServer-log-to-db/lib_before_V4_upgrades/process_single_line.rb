=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_single_line.rb 20150 2010-04-05 15:28:28Z thennessy $
=end
def process_single_line(single_line)
  $processed_single_line_groups += 1
  # if debug, increment counter
#    if /count for state/ =~ single_line[0] then
#  puts "#{__FILE__}:#{__LINE__}-> "
#  end#
#  if $job_uuid.match(single_line[0]) then
#  puts "#{__FILE__}:#{__LINE__}-> "
#  end
#if /\[455\]/ =~ single_line[0] then
#  puts "#{__FILE__}:#{__LINE__}->#{single_line[0]}"
#end
  $debug_line_count += 1 if /DEBUG --/ =~ single_line[0]
  # copy non-debug messages to output file
  
  $modified_log.puts(single_line) if /DEBUG --/ !~ single_line[0] && $create_modified == true
   
  
  #distill "messages of interest" into a separate file 
  # for later investication
#        if /ERROR --|WARN --|\] started on |[Ee]rror / =~ single_line[0] then 
#          not_normal(single_line)
#              elsif /FATAL --/=~ single_line[0] then
#            fatal_messages(single_line)
#        end
  case single_line[0]
  when /ERROR --|WARN --|\] started on |[Ee]rror / then
    not_normal(single_line)
  when /FATAL --/ then
    fatal_messages(single_line)
  when /INFO --/ then
    log_line_summarize(single_line[0])
    
  end

end
