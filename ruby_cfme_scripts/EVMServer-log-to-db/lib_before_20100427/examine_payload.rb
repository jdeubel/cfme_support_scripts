=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: examine_payload.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def examine_payload(payload)
  #this routine expects a string as input and will examine that string
  #for expected payload contents
#  puts "#{payload} is of type '#{payload.class}'"
  if / JOB\(| MIQ\(/ =~ payload then
    case payload
    when /JOB\((.*)\[(.*)\]/  then
      puts "JOB STATEMENT MAJOR = #{$1}- OBJECT IS '#{$2}'"
    when /MIQ\((.*)\)/  then

      _found = $1
      puts "MIQ STATEMENT MAJOR = #{_found}"        
     
#    when /\((.*)\) / =~ payload then

    end
#    puts ""
#    if /JOB\((.*)\)|MIQ\((.*)\)/ =~ payload then 
#      if/\((.*)\)/ =~ payload then
#        puts $1
#      end
#    end
#    puts "#{$MATCH} includes #{$1}"
  end
end
