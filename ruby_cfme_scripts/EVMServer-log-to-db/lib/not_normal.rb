=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: not_normal.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def not_normal(of_interest)
  $Error_log.puts "\n***\n"
  case of_interest.class.to_s
    when "String" then  $Error_log.puts(of_interest)
    when "Array" then 
        of_interest.each do |x|
          $Error_log.puts(x) if /DEBUG --/ !~ x
        end
  end        
  $Error_log.puts "\n***\n"
  #  if of_interest.size > 1 && /ERROR -- :/ =~ of_interest[0] then
  #    puts "#{of_interest.size} log lines associated with =>#{of_interest[0]}"
  #
  #  end
  log_line_summarize(of_interest[0]) if of_interest.class.to_s == "Array"
  log_line_summarize(of_interest) if of_interest.class.to_s == "String"
end
