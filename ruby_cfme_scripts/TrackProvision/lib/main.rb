=begin rdoc
Copyright 2008,2009, 20010, 2011 ManageIQ, Inc
$Id: Log_class.rb.rb 16597 2009-10-12 15:36:47Z thennessy $
=end

=begin rdoc
The intent of this project is to develop code that will scann the provided evm.log files to distill 
all of the "miq_provision_request_###" and "miq_provision_3333" log lines and then to present the "miq_provision_###'
log lines in a manner that allows one to tract the provision request thru the actual provision steps.
the provision reuuest can be made across zones.  Provision steps are generally zone specific but can 
be dispatched on different appliances in the same zone.

Operational overview:
it is expected that this tool will be launched from a current directory which contains subdirectories in which 
evm.log files are to be found.  the depth of these directories is not yet specified, so I will only go 
one deep for the present (eg,current_directory\subdirectory\evm.log)

each evm.log file will be identified (subdirectory).  the subdirectory name is expected to be meaningful
because I cannot depend on the evm.log file to contain any significant markers (appliance name, host name, zone, etc)



Tom Hennessy Jan 2011
=end

class Request
    @request_id = nil
   @request_target_zone = nil
   @request_first_seen = nil
   @request_last_seen = nil
   @request_subdirectory = nil
   @request_message_id = nil
   @request_message_create_time = nil
   @request_message_deliver_begin_time = nil
   @request_message_deliver_duration  = nil
   @request_message_deliver_status = nil
    
   def initialize(logline) 
     
   end
end
class ParsedLogLine
  attr_accessor :parsedlogline_datetime, :parsedlogline_qtaskid, :parsedlogline_pid, :parsedlogline_ismessage
  attr_accessor :parsedlogline_target_zone, :parsedlogline_messageid, :parsedlogline_message_status
  attr_accessor :parsedlogline_message_type, :parsedlogline_message_duration, :parsedlogline_message_target_qtaskid
  attr_accessor :parsedlogline_logline, :parsedlogline_current_file, :parsedlogline_message_command
  attr_accessor :parsedlogline_message_args, :parsedlogline_type

  @parsedlogline_current_file = nil
  @parsedlogline_datetime = nil                        # string from preamble
  @parsedlogline_qtaskid = nil                         # Q-task_id as first word of payload if it is there
  @parsedlogline_pid = nil                             # PID of process
  @parsedlogline_ismessage = nil                       # not-nil if .put, .get or .delivered type message
  @parsedlogline_target_zone = nil                     # zone specified if this is a message
  @parsedlogline_messageid = nil                       #message id
  @parsedlogline_message_status = nil                  # status at message processing end
  @parsedlogline_message_type = nil                    # .put, .get , .delivered
  @parsedlogline_message_duration = nil                # message processing duration
  @parsedlogline_message_target_qtaskid = nil          # target Q-task_id from message itself
  @parsedlogline_logline = nil                         # unaltered log line text
  @parsedlogline_message_command = nil                 # command for message to execute
  @parsedlogline_message_args = nil                    # command args
  @parsedlogline_type = nil                            # info, error, warning
  def initialize(logline)
    @parsedlogline = logline
    @parsedlogline_current_file = $current_logfile
    logline_parts = logline.split("\-\- \:")
    if logline_parts.size != 2 then
      puts "improper log line -> '#{logline}'"
    end
    # split log line into two part array: 0-> standard preamble, 1- payload
    preamble_array = logline_parts[0].split
    @parsedlogline_type = preamble_array[-1]
    # preamble element     contents
    # 0                    "[----]"
    # 1                    "[EDIWF]"
    # 2                    "[ccyy-mm-ddThh:mm:ss.tttttt"
    # 3                     "#PID:TID]
    # 4                     "INFO|WARN\FATAL|DEBUG"
    @parsedlogline_datetime = preamble_array[2]
    @parsedlogline_pid = preamble_array[3]
    payload_array = logline_parts[1].split
    # break up payload to simplify accessing the first two words
    if /Q-task_id\(\[(.*?)\]\)/  =~ logline_parts[1] then
      @parsedlogline_qtaskid = $1
    end
    _logline = nil
    if /MIQ\(MiqQueue\.(.*?)\)/ =~ logline_parts[1] then
      _queuetype = $1
      if /,\s*Args\:\s*/ =~ logline then
        _postmatch = $POSTMATCH
        _prematch = $PREMATCH
        if /,\s*Delivered in/ =~ _postmatch then
          _logline = _prematch + ", Delivered in" + $POSTMATCH
          @parsedlogline_message_args = $PREMATCH
        else
          _logline = _prematch
          @parsedlogline_message_args = _postmatch.chomp
        end
          logline_parts = _logline.split("\-\- \:")
          payload_array = logline_parts[1].split
      end
#      if /Args\:\s*\[(.*?)\],/ =~ logline then
##        puts "Args value is '#{$1}'" if $1 != nil
#        if $POSTMATCH == nil then
#          _logline = $PREMATCH
#        else
#        _logline = $PREMATCH + $POSTMATCH
#        end
#        if _logline != nil then
#          logline_parts = _logline.split("\-\- \:")
#          payload_array = logline_parts[1].split
#        end
#      end
      case _queuetype
      when /get|delivered|put/ then
        @parsedlogline_ismessage = 1
        @parsedlogline_message_type = _queuetype
     _queuemsg_array = logline_parts[1].split("\],")
        # if this is a miqqueue message then the parts I need are separated by commas
        _queuemsg_array.each do |element|
          element = element + "\]"
          case element
          when /Message id\:\s*\[(\d*)\]/ then @parsedlogline_messageid = $1 
          when /Zone\:\s*\[(.*?)\]/ then @parsedlogline_target_zone  = $1  
          when /State\:\s*\[(.*?)\]/ then @parsedlogline_message_status = $1
          when /Delivered in \[(.*?)\] seconds/ then @parsedlogline_message_duration = $1
          when /Task id\:\s*\[(.*?)\]/ then
            @parsedlogline_message_target_qtaskid = $1

#            if /job/ =~ $1 then
#              puts "found one ->#{$1} - messageid #{@parsedlogline_messageid}"
#            end
          when /ERROR\: \s*\[(.*?)\]/ then
            @parsedlogline_message_status = $1
          when /Role\:/ then
          when /Server\:/ then
          when /Ident\:/
          when /Target id\:/
          when /Instance id\:/
          when /Timeout\:/
          when /Command\:\s*\[/ then @parsedlogline_message_command = $POSTMATCH 
          when /Priority\:/
          when /Data\:/
          when /Args\:/
          when /Worker id\:/
          when /Dequeued in\:/
          when / id\:/
          when / Deliver On\:/
          else
            puts "unrecognized fragment #{element}\n\t in log line #{logline}"
          end
        end
      end
      case _queuetype
      when "get" then
        if /_provision_/ !~ @parsedlogline_message_target_qtaskid then 
          @parsedlogline_ismessage = nil
        end
      
      end
      
      
    end
  end
end

class Messages
  attr_accessor :message_create_QtaskId, :message_QtaskId, :message_create_subdirectory
  attr_accessor :message_create_pid, :message_deliver_pid
  attr_accessor :message_deliver_subdirectory, :message_create_datetime, :message_deliver_begin_datetime
  attr_accessor :message_deliver_duration, :message_deliver_status, :message_target_zone, :message_command
  attr_accessor :message_args, :message_id

  @message_create_QtaskId = nil              # q task id of log line creating .put
  @message_QtaskId = nil                     # q task id within created message
  @message_create_subdirectory = nil         # subdirectory containing evm.log where message .put was found
  @message_create_pid = nil                  # pid of process creating message (.put)
  @message_deliver_pid = nil                 # pid of process getting the message (.get)
  @message_deliver_subdirectory = nil        # subdirectory containing evm.log where message .get was found
  @message_create_datetime = nil             # log datetime of .put   
  @message_deliver_begin_datetime = nil      # log datetime of .get
  @message_deliver_duration = nil            # duration from message "Delivered in" log line
  @message_deliver_status = nil              # status from message "Delivered in" log line
  @message_id = nil
  @message_target_zone = nil
  @message_command = nil                     # command associated with message
  @message_args = nil                        # command args
  
 def initialize(parsedlogline)
   @message_id = parsedlogline.parsedlogline_messageid
   @message_create_QtaskId = parsedlogline.parsedlogline_qtaskid
   @message_create_subdirectory = $current_logfile
   @message_create_pid = parsedlogline.parsedlogline_pid
   @message_create_datetime = parsedlogline.parsedlogline_datetime
   @message_target_zone = parsedlogline.parsedlogline_target_zone
   @message_command = parsedlogline.parsedlogline_message_command if parsedlogline.parsedlogline_message_command
   @message_args = parsedlogline.parsedlogline_message_args if parsedlogline.parsedlogline_message_args


 end
 end
 def process_message(parsedlogline)
 if $Messages.has_key?(parsedlogline.parsedlogline_messageid) then
   _message = $Messages[parsedlogline.parsedlogline_messageid]
 else
   _message = Messages.new(parsedlogline)
 end
   case parsedlogline.parsedlogline_message_type
   when /put/ then
#  @message_create_QtaskId = nil              # q task id of log line creating .put
#  @message_QtaskId = nil                     # q task id within created message
#  @message_create_subdirectory = nil         # subdirectory containing evm.log where message .put was found
#  @message_create_pid = nil                  # pid of process creating message (.put)
#  @message_deliver_pid = nil                 # pid of process getting the message (.get)
#  @message_deliver_subdirectory = nil        # subdirectory containing evm.log where message .get was found
#  @message_create_datetime = nil             # log datetime of .put

     _message.message_create_QtaskId = parsedlogline.parsedlogline_qtaskid # if _message.message_create_QtaskId == nil
     _message.message_QtaskId = parsedlogline.parsedlogline_message_target_qtaskid # if _message.message_QtaskId == nil
     _message.message_create_subdirectory = $current_logfile
     _message.message_create_pid = parsedlogline.parsedlogline_pid
     _message.message_create_datetime = parsedlogline.parsedlogline_datetime
     _message.message_id = parsedlogline.parsedlogline_messageid
     _message.message_deliver_status = parsedlogline.parsedlogline_message_status if _message.message_deliver_status == nil
     
   when /get/ then
     _message.message_deliver_pid = parsedlogline.parsedlogline_pid
     _message.message_deliver_begin_datetime = parsedlogline.parsedlogline_datetime
     _message.message_QtaskId = parsedlogline.parsedlogline_message_target_qtaskid if parsedlogline.parsedlogline_message_target_qtaskid != nil
     _message.message_deliver_subdirectory = $current_logfile
     _message.message_id = parsedlogline.parsedlogline_messageid

   when /delivered/ then
     _message.message_deliver_duration = parsedlogline.parsedlogline_message_duration
     _message.message_deliver_status = parsedlogline.parsedlogline_message_status
     _message.message_id = parsedlogline.parsedlogline_messageid
   end
   $Messages[parsedlogline.parsedlogline_messageid] = _message
 end
 def request_and_provision(object)
   if $Requests_And_Provisions then

     $Requests_And_Provisions.puts "message id - #{object.message_id}, create q-taskid='#{object.message_create_QtaskId}',target q-taskid='#{object.message_QtaskId}'," +
                   "target zone (#{object.message_target_zone})," +
                   "status(#{object.message_deliver_status}),delivered in '#{object.message_deliver_subdirectory}',processed in pid(#{object.message_deliver_pid})"

   else
     $Requests_And_Provisions = File.new("Requests_and_Provisions.txt","w") #create new file
     request_and_provision(object)
   end
 end
 def expose_miqrequest_to_provision_request_mapping
   request_to_provision_request_file = File.new("Request_to_ProvisionRequest_mappings.txt","w")
   _sorted_request_array = $MiqRequest_hash.keys.sort
   _sorted_request_array.each do |key|
    request_to_provision_request_file.puts "MiqRequest.#{key.to_s} maps to #{$MiqRequest_hash[key]["qtaskid"]}"
   end
   request_to_provision_request_file.close
 end
 def capture_non_info_provision(evmlog)
   error_files  = Hash.new 
   directory_path = File.dirname(evmlog)
   _evmlog = File.new(evmlog)                # open evmlog file for input
   last_line_provision_error = nil                      # flag toggled when non-info line processed
   qtaskid = nil
   while evmlog_in = _evmlog.gets

     if / INFO / =~ evmlog_in  &&
         /[Pp]owershell/ !~ evmlog_in then
       last_line_provision_error = nil
       next
     end
     if last_line_provision_error && /^\[\-\-\-\-\]/ !~ evmlog_in then
#     if last_line_provision_error == nil && / ERROR | INFO | WARN / !~ evmlog_in then
#       puts "#{evmlog_in}"
       handle = error_files[qtaskid]["handle"]
       handle.puts "#{evmlog_in}"
       next
     else
       last_line_provision_error = nil
     end
     if /miq_provision_/ =~ evmlog_in || /vm_refresh/ =~ evmlog_in then
         case evmlog_in
             when / ERROR | WARN / then
                 if  /request_starting/ !~ evmlog_in then
                   last_line_provision_error = 1
                 end
             when /[Pp]owershell/ then
               last_line_provision_error = 1
            else
             last_line_provision_error = nil
         end
     else
       next if !last_line_provision_error     # if this is not recognized as a miq_provision line and
       # it isn't a continuation of a special line (powershell, error or warn type) then get next log line
       end
         if /Q-task_id\(\[(.*?)\]\)/ =~ evmlog_in then
           qtaskid = $1

           if /_provision_/ =~ qtaskid  || /vm_refresh/ =~ qtaskid then
              # if this is a provision request or the "vm_refresh" that disconnects from the chain
              # then capture and distill it
             if  error_files.has_key?(qtaskid) then
             handle = error_files[qtaskid]["handle"]
             handle.puts "#{evmlog_in}"
             else
             error_and_warnings = File.new(directory_path+ "/" + qtaskid + "_errors_and_warnings","w")
             error_files[qtaskid] = {"handle"=> error_and_warnings}
             error_and_warnings.puts "#{evmlog_in}"
             end
           end
         end
#         puts "#{evmlog_in}"
#       end

#     end
   end
   error_files.each do |key, file|
#     puts "closing #{key}"
     file["handle"].close
   end
 end
 
require 'find'
require 'rubygems'
require 'English'

 $Requests_And_Provisions = nil


$evmlog_files = Array.new
$Request_message = Array.new
$Provision_message = Array.new
$Messages = Hash.new
$evmlog_input = nil
$current_logfile = nil
$provision_evmlog = Hash.new
suspicion_limit = 1000

 ####
 $MiqRequest_parsedlogline = nil
 $MiqRequest = nil
 $MiqRequest_hash = Hash.new
 ####
if ARGV[0] != nil && ARGV[0].to_i > 0 then
  puts "threshhold fof suspicious provisioning is #{ARGV[0]} log lines"
  suspicion_limit = ARGV[0].to_i
else
  puts "threshhold for suspicious provisioning is #{suspicion_limit} log lines"
  
  
end


Find.find(".") do |evmlog|
if /\/evm\.log$/ =~ evmlog then
  puts"#{evmlog}"
  $evmlog_files <<evmlog
 end
end
$evmlog_files.each do |af|
 if $evmlog_input then              #if evmfile is already or still opened
   $evmlog_input.close              # then close it and
   $evmlog_input = nil              # rest the handle to nil
 end
$current_logfile = af                   # capture current input file name
puts "processing input file #{$current_logfile}"
_cmd_string = "cmd.exe /C grep -E -i \"miq_(provision_|request\\\=|request_created)\" \"#{af}\" | grep -i \"^\\\[\\-\\-\\-\\-\\\]\" | grep -iv \"stale, retrying\" | grep -iv \"request_starting\"> \"#{af}_filtered\" "
puts "preparing to execute '#{_cmd_string}'"
#puts `cd `
#puts "#{_response}"
puts `#{_cmd_string}`
_cmd_string = "cmd.exe /C grep -v \" INFO \" \"#{af}_filtered\"  > \"#{af}_filtered_errors\" "
puts "preparing to execute '#{_cmd_string}'"      #exclude all INFO log line and retain others (errors warn types)
puts `#{_cmd_string}`

_cmd_string = "cmd.exe /C grep -E -i \"MiqRequest\\\.[0-9]{1,9}\" \"#{af}\"  > \"#{af}_miqrequests\" "
puts "preparing to execute '#{_cmd_string}'"
puts `#{_cmd_string}`

   # if af + "_filtered_errors" = 0 then we don't need to process the evm log for this appliance
   capture_non_info_provision(af)

 $evmlog_input = File.new(af + "_filtered")
 
 while input_line = $evmlog_input.gets

#if /job_/ =~ input_line then
#  puts "#{__FILE__}:#{__LINE__}: #{input_line}"
#end
 if /miq_provision_/ =~ input_line then
#   puts input_line
   parsedlogline = ParsedLogLine.new(input_line)
   if parsedlogline.parsedlogline_qtaskid &&
      /_provision_/ =~ parsedlogline.parsedlogline_qtaskid then      # if there is a qtaskid for the log line
     if  $provision_evmlog.has_key?(parsedlogline.parsedlogline_qtaskid + "|"+af) then
       _evmlog_counts = $provision_evmlog[parsedlogline.parsedlogline_qtaskid + "|" +af]
     else
       _evmlog_counts_key = parsedlogline.parsedlogline_qtaskid + "|" +af
       _evmlog_counts = {"INFO"=>0, "WARN"=> 0, "ERROR"=>0, "qtaskid"=> parsedlogline.parsedlogline_qtaskid,
                        "evmlog" => af
       }
     end

   case parsedlogline.parsedlogline_type.strip
   when "ERROR" then _evmlog_counts["ERROR"] += 1
   when "WARN" then _evmlog_counts["WARN"] += 1
   when "INFO" then _evmlog_counts["INFO"] += 1
   else
     puts "unknown log line type - #{input_line}"
   end
   $provision_evmlog[_evmlog_counts_key] = _evmlog_counts if _evmlog_counts_key
   _evmlog_counts = nil
   _evmlog_counts_key = nil
   end   
   if parsedlogline.parsedlogline_ismessage   then
     _msg_context = nil
     if parsedlogline.parsedlogline_qtaskid != nil then _msg_context = parsedlogline.parsedlogline_qtaskid
     else _msg_context = parsedlogline.parsedlogline_message_target_qtaskid
     end
     case _msg_context
#     when nil then $Request_message << parsedlogline
     when /request/ then $Request_message << parsedlogline
     else
       $Provision_message << parsedlogline
     end
     process_message(parsedlogline)
   end
 end

end
 if $evmlog_input then              #if evmfile is already or still opened
   $evmlog_input.close              # then close it and
   $evmlog_input = nil              # rest the handle to nil
 end
 $evmlog_miqrequests = File.new(af+"_miqrequests")
 while miqrequest_input = $evmlog_miqrequests.gets
   if /Q-task_id/ !~ miqrequest_input then
     next    # if log line has no qtaskid then skip it
   end
   puts "#{miqrequest_input}"
  if  /MiqRequest\.(\d*)/ =~ miqrequest_input then
    $MiqRequest = $1
    puts "got one #{$MiqRequest}"
    _qtaskid = nil
    if /Q-task_id\(\[(.*)\]\)/ =~ miqrequest_input then
      _qtaskid = $1
    end
#    $MiqRequest_parsedlogline = ParsedLogLine.new(miqrequest_input)
    if _qtaskid != nil then
      if $MiqRequest_hash.has_key?($MiqRequest + _qtaskid) then #If hash entry does not exist
      else
        $MiqRequest_hash[$MiqRequest] = { "qtaskid" => _qtaskid}
         puts "MiqRequest found is #{$MiqRequest} with Qtaskid = '#{_qtaskid}'"
      end
    end
  end
end
end
puts "$MiqRequest_hash.size is '#{$MiqRequest_hash.size}' entries"
 expose_miqrequest_to_provision_request_mapping
 puts "processing of all input files is complete, moving to consolidation phase"
#$Request_message.each do |request|
# puts "\n\n\n****Request******"
#  puts "#{message.parsedlogline_qtaskid},#{message.parsedlogline_message_target_qtaskid},#{message.parsedlogline_current_file},#{message.parsedlogline_message_type},#{message.parsedlogline_messageid}," +
#      "#{message.parsedlogline_target_zone},#{message.parsedlogline_message_status},#{message.parsedlogline_message_duration}"
#
#end
#puts "Countof provision messages is #{$Provision_message.size}"
#puts "Qtaskid,target taskid,message type, messageid,target zone,message status,message duration"
#$Provision_message.each do |message|
# puts "#{message.parsedlogline_qtaskid},#{message.parsedlogline_message_target_qtaskid},#{message.parsedlogline_current_file},#{message.parsedlogline_message_type},#{message.parsedlogline_messageid}," +
#      "#{message.parsedlogline_target_zone},#{message.parsedlogline_message_status},#{message.parsedlogline_message_duration}"
#end
#puts "Count of Request messages is #{$Request_message.size}"
#puts "Qtaskid,target taskid,message type, messageid,target zone,message status,message duration"
_sorted_messages = $Messages.keys.sort
_already_iterated_qtaskid = Hash.new
_already_iterated_messageid = Hash.new
_sorted_messages.each do |messageid1|
  if !_already_iterated_messageid.has_key?(messageid1) then
#  puts "_sorted_message_id - #{messageid}"
  if $Messages.has_key?(messageid1) then
        message = $Messages[messageid1]

               if message.message_deliver_status == "ok" then
                 _status0 = " "
               else _status0 = "**"
               end
               if message.message_create_QtaskId != nil && message.message_create_QtaskId != "" then
                   puts "#{_status0}message id - #{messageid1}, create q-taskid='#{message.message_create_QtaskId}',target q-taskid='#{message.message_QtaskId}'," +
                   "target zone (#{message.message_target_zone})," +
                   "status(#{message.message_deliver_status}),delivered in '#{message.message_deliver_subdirectory}',processed in pid(#{message.message_deliver_pid})"
               else
                   puts "#{_status0}message id - #{messageid1}, create q-taskid='#{message.message_create_QtaskId}'," +
                   "\n\tcreated in '#{message.message_create_subdirectory}', in process '#{message.message_create_pid}', at time '#{message.message_create_datetime}',\n\t"  +
                   "target q-taskid='#{message.message_QtaskId}'," +
                   "target zone (#{message.message_target_zone})," +
                   "status(#{message.message_deliver_status}),delivered in '#{message.message_deliver_subdirectory}',processed in pid(#{message.message_deliver_pid})"

               end
                 _already_iterated_messageid[messageid1] = {"value" => 0}

             _sorted_messages.each do |tier2_id|
               if tier2_id > messageid1 then
               message2 = $Messages[tier2_id]



               case message2.message_deliver_status
               when nil then _status1 = "??"
               when /error/ then _status1 = "!!"
               when /ok/ then _status1 = "  "
               when /ready/ then _status1 = "??"
               else
                 _status1 = message2.message_deliver_status
               end
#               if message2.message_deliver_status == "ok" then
#                 _status1 = " "
#               else _status1 = "**"
#               end
               
               if message.message_QtaskId && message.message_QtaskId == message2.message_create_QtaskId && !_already_iterated_qtaskid.has_key?(message.message_QtaskId) then

             if /_request_/  =~ message2.message_create_QtaskId &&
               /_provision_/ =~ message2.message_QtaskId then
                 puts "writing #{tier2_id}"
                request_and_provision(message2)
            end

                 case _status1
                 when "  " then
                 puts "\t#{_status1}\tmessage id = #{tier2_id}, create q-taskid='#{message2.message_create_QtaskId}',target q-taskid='#{message2.message_QtaskId}'," +
                   "target zone (#{message2.message_target_zone})," +
                   "status(#{message2.message_deliver_status}),delivered in '#{message2.message_deliver_subdirectory}',processed in pid(#{message2.message_deliver_pid})"
                 else
                   if message2.message_command == nil then
                     message2.message_command = ""
                   end
                  puts "\t#{_status1}\tmessage id = #{tier2_id}, create q-taskid='#{message2.message_create_QtaskId}',target q-taskid='#{message2.message_QtaskId}',\n\t\t\t" +
                   "target zone (#{message2.message_target_zone})," +
                   "status(#{message2.message_deliver_status}),delivered in '#{message2.message_deliver_subdirectory}'," +
                   "\n\t\t\tcommand '[#{message2.message_command}'," +
                   "\n\t\t\targs '#{message2.message_args}'," +
                   "\n\t\t\tprocessed in pid(#{message2.message_deliver_pid}),msg delivery begin = '#{message2.message_deliver_begin_datetime}',msg processing time='#{message2.message_deliver_duration}'" +
                   "\n "

                 end
                 _already_iterated_messageid[tier2_id] = {"value" =>0}
               end
               
             end
             
             end
             _already_iterated_qtaskid[message.message_QtaskId] = {"value" => 0}
  else
    puts "no $Message[#{messageid1}] entry "
#  array_element.each do |messageid, message|

    end
_already_iterated_messageid[messageid1] = {"value" =>0}
  end

end
puts "count of $provision_evmlog instances is #{$provision_evmlog.size}"
puts "object type of $provision_evmlog is #{$provision_evmlog.class.to_s}"
$Linecount_keys = Hash.new
_sorted_provisions = $provision_evmlog.keys
_sorted_provisions = _sorted_provisions.sort
$Errors_and_Warnings = File.new("Provision_Errors_and_Warnings.txt","w")

_sorted_provisions.each do |key|
#puts "#{key}"  
 values = $provision_evmlog[key]
  if values['ERROR'] > 0 || values['WARN'] > 0 then
  $Errors_and_Warnings.puts "provision id = '#{values['qtaskid']}, evm log = '#{values['evmlog']}'" +
        "\n\t\t ERROR CNT = #{values['ERROR']}" +
        "\n\t\t WARN cnt = #{values['WARN']}" +
        "\n\t\t INFO cnt = #{values['INFO']}"
      $Errors_and_Warnings.puts "\n\t====================================="
      error_lines = File.new(File.dirname(values["evmlog"])+ "/" + values["qtaskid"] + "_errors_and_warnings")
      while error_line = error_lines.gets
        $Errors_and_Warnings.puts "\t#{error_line}"
      end
      $Errors_and_Warnings.puts "\t========================================\n\n"
      error_lines.close
      puts "removing file #{File.dirname(values["evmlog"])+ "/" + values["qtaskid"] + "_errors_and_warnings"}"
      _remove_file = File.delete(File.dirname(values["evmlog"])+ "/" + values["qtaskid"] + "_errors_and_warnings")
  end
  _line_count = 0
  ["INFO","WARN","ERROR"].each do |element|
    _line_count += values[element].to_i if values[element]      # add up all of the lines for a total count
  end
  _infocount_key = ("000000000000000" + _line_count.to_s)[-10..-1]  # get last 10 positions of line counts
#  puts "#{_infocount_key}"
  $Linecount_keys[_infocount_key] = {"key"=> key}

  end
  if $Linecount_keys.size > 0 then
    _suspicious = File.new("Suspicious provisions","w")
    _suspicious.puts "Provisioning related Q-task_id's with log line counts exceeding #{suspicion_limit} log lines\n" +
                     "_____________________________________________________________________________________________\n\n"

  _sorted_linecount = $Linecount_keys.keys.sort
  _sorted_linecount.reverse!
  _sorted_linecount.each do |linecnt|
#    puts "#{linecnt.class.to_s} value is '#{linecnt}'"
    _linecount_instance = $provision_evmlog[$Linecount_keys[linecnt]["key"]]
#    puts "_linecount_instance is of type #{_linecount_instance.class.to_s}"
    if _linecount_instance["INFO"] > suspicion_limit then
        _suspicious.puts "provision id = '#{_linecount_instance['qtaskid']}, evm log = '#{_linecount_instance['evmlog']}'" +
        "\n\t\t ERROR CNT = #{_linecount_instance['ERROR']}" +
        "\n\t\t WARN cnt = #{_linecount_instance['WARN']}" +
        "\n\t\t INFO cnt = #{_linecount_instance['INFO']}"
    end
  end
  end
  _suspicious.close if _suspicious
  $Requests_And_Provisions.close if $Requests_And_Provisions
  $Errors_and_Warnings.close
exit

