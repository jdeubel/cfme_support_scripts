#       set_trace_func proc {|event, file, line, id, binding, classname | printf  "%8s %s:%02d %10s %8s\n",event, file, line, id, classname}
=begin rdoc
$Id: miqhost_log_parser.rb,v 1.2 2008/02/14 17:22:13 Tom Hennessy Exp $
$Header: c:\\hennessy_cvs/ruby/smarthost-to-csv/miqhost_log_parser.rb,v 1.2 2008/02/14 17:22:13 Tom Hennessy Exp $
$Log: miqhost_log_parser.rb,v $
Revision 1.2  2008/02/14 17:22:13  Tom Hennessy
added cvs keywords for testing

=end 

$:.push("#{File.dirname(__FILE__)}")  # force the directory with initial code to be on the search path

$generatedb = true
       #if  you want to have this generate a db with related tables then set the $generatedb to "true"
       
      require 'rubygems'
      if $generatedb then   
      $:.push("C:\\dev\\miq\\tools\\qawatcher\\app\\models\\")  # location where all of the models are stored        
       
      require "activerecord"
      require "stringio"          # required for advanced log processing for certain errors
      require "pp"
      ActiveRecord::Base.establish_connection( 
        :adapter => "mysql", 
        :host => "localhost", 
        :username => "root",
        :password => "root",
        :database => "ruby_testing")
# =========================================
      require "sh_command_history.rb"
      require "sh_error_message.rb"
      require "sh_version_to_sprint.rb"
      require "sh_thread_id.rb"
      require "sh_process_id.rb"
      require "sh_snapshot_value.rb"
      require "sh_agent_version.rb"
      require "sh_agent_name.rb"
      require "sh_host_available_memory_value.rb"
      require "sh_host_memory_value.rb"
      require "sh_host_ip_address.rb"
      require "sh_host_os_id.rb"
      require "sh_host_os_version.rb"
      require "sh_host_os.rb"
      require "sh_host_name.rb"
      require "sh_command_parm.rb"
      require "sh_vm_name.rb"
      require "sh_command_result.rb"
      require "sh_command_name.rb"
      require "sh_log_file.rb"
# =========================================
      end

        require "log_array_constants.rb"  
        #~ require "log_processing_status.rb"
        #~ include log_processing_status
        HOST_CHECK_END = /Host Check End/
        VM_CONSOLE_MEMORY = /\/boot\/memSize\s*\=\s*\"(\d*)\"/  
        LOG_RESTART_END =  /Use Ctrl-C to shutdown server/        

        require 'date'
        require 'parsedate'
        # require 'rubygems'
        # require 'fastercsv'
        require 'csv'
        include ParseDate
        require 'create_command_history'
parm_count = 0 # set default count of passed in paramaters
parm_count = ARGV.size
$records_created = 0
$invalid_log_name_format = 0
$previously_processed_file = 0
$log_terminate_reason = String.new

$agent_name_record_hash = Hash.new
$process_id_record_hash = Hash.new
$thread_id_record_hash = Hash.new
$command_name_record_hash = Hash.new
$command_result_record_hash = Hash.new
$vm_name_record_hash = Hash.new
$command_name_record_hash = Hash.new
$command_parm_record_hash = Hash.new
$error_message_record_hash = Hash.new
$current_log_file_record_key = nil




ARGV.each do |file_name| 
  if $generatedb then 
    db_log_file = ShLogFile.new() 
    db_log_file.log_file_name = file_name
  end
  $log_terminate_reason = "" #reset log terminate reason to empty for new log
  $current_log_file_record_key = nil
  host_OS_name = nil
  host_ip_address = nil
 puts "#{file_name}"

  input_file_basename = File.basename(file_name,".*") 
  input_file_basename_array = input_file_basename.split("-") #decompose file name into components
  date_or_sequence = input_file_basename_array.pop
  if /^\d*$/ !~ date_or_sequence  then
    $invalid_log_name_format += 1
    puts "-------------bad file name format"
    next
    end
  search_name = :file_name
  
  if $generatedb then
      already_processed = ShLogFile.find(:first, :conditions => ["log_file_name = ?", file_name])
      if already_processed != nil then
        puts "--------------file name already exists"
        $previously_processed_file += 1
        next # record already in DB, skip it
      end
      puts "****** being added and processed ********"
      sh_log_sequence_number = date_or_sequence
      sh_agent_start_time = input_file_basename_array.pop

      db_log_file.agent_version = input_file_basename_array.pop
      db_log_file.agent_name = input_file_basename_array[0]
      db_log_file.host_name = input_file_basename_array[1..input_file_basename.size].join("-")
      db_log_file.sh_log_file_size = File.size(file_name)
      db_log_file.end_date_time = File.mtime(file_name)
      db_log_file.start_date_time = sh_agent_start_time    
      db_log_file.log_terminate_reason = "unknown"
      return_code = db_log_file.save!  
      $records_created += 1
      $current_log_file_record_key = db_log_file.id
  end
#  puts "#{return_code}"
#end
#exit

#    puts "#{file_name}\n"
    
  
# end
# exit
        input_file = File.new(file_name ,"r")
        puts file_name.inspect
#        puts ARGV.inspect
#        prefix_file = File.new(input_file_basename + "-log_prefix.csv", "w+")
        completed_cmds = CSV.open(input_file_basename + "-completed_cmds.csv","w")
#        immediate_cmds = CSV.open(input_file_basename + "-immediate_cmds.csv","w")
        immediate_header = "processid, cmd name, cmd parms, cmd start date, cmd start time, cmd start microseconds,agent name, agent version, host OS, host name,  host ip address, host os version,appliance ip address, Host Id,VM CMD Target"
# attempt at creating a true CSV file
#        prefix_file.puts "Unique key, process id, thread id, cmd name, cmd parms, cmd duration, cmd completion , cmd start date, cmd start time, cmd start microseconds, cmd stop date, cmd stop time, cmd stop microseconds,agent name,agent version,host OS,host name,host ip address,host os version,appliance ip address,log msg id,log msg type,log msg type text,HOST ID,VM CMD Target,Host Memory,Available memory".split(",")
        completed_cmds << "Unique key, process id, thread id, cmd name, cmd parms, cmd duration, cmd completion , cmd start date, cmd start time, cmd start microseconds, cmd stop date, cmd stop time, cmd stop microseconds,agent name,agent version,host OS,host name,host ip address,host os version,appliance ip address,log msg id,log msg type,log msg type text,HOST ID,VM CMD Target,Host Memory,Available Memory,Error Message".split(",")
        loglinecnt = 0
        host_OS_value, host_OS_name, host_OS_version_value, host_ip_address = nil
        agent_name_value, agent_version_value, agent_registered_id = nil
        appliance_identifier, host_memory, available_memory = nil
        log_normal_line = /^\[----\] |^\[9999\] /
        log_restart_line = /\* (\[.*\]) (\[.*\]) started on /
        log_restart_line_flag = nil

        log_restart_end_flag = nil
        server_build_level = nil
        appliance_identifier = nil

        host_check_end_flag = nil
        returned_ip_address, returned_host_name = nil
        line_contains_host_os_version = nil
# log status tracking variables
        log_status = nil # valid values are nil (between logs), 1 (currently processing), 2 (closing)
        log_host_check_status = nil
        log_initialization_status = nil        
        
# initialize line counter   
        line_split = Array.new
        completed_command = Array.new
        pending_cmds = Array.new
        pending_cmds_index = 0 
        completed_commands_count = 0
        errors_identified = 0
  read_loop_start = Time.now 
while line=input_file.gets
 
# read the passed in file name
#when enf is encountered, te while statement will be false and will drop thru 
# so I'm not chompong the string here as trying to chomp may cuase an error at eof!
  line=line.chomp
#  puts line
  loglinecnt += 1 # increment the line count
  if loglinecnt.modulo(10000) == 0 then
    _x = Time.new
    _x = _x - read_loop_start
    puts " 10k lines processed in #{_x} seconds"
    read_loop_start = Time.now
  end
#   puts "log line count = #{loglinecnt}"
  next if log_normal_line !~ line
# restrict to processing only true intended log lines
  if /\* (\[.*\]) (\[.*\]) started on / =~ line then 
# the above regular expression matches on the line containg log restart marker!
#$1 now contains the agent name & $2 contains the hosting machine OS-type
    agent_name_value = $1.tr("[]","  ").strip
    host_OS_value = $2.tr("[]","  ").strip
    
    if $generatedb then    
       db_log_file.host_os = host_OS_value 
    end
    
    _line_words = line.split # split the line into blank separated fragments
    _line_words[2] = _line_words[2].tr('\[\-T:.','     ')
    _time_parts = _line_words[2].split
#      if /\[\.*\]\s..\s\[(\d*)-(\d*)-(\d*)T(\d*):(\d*):(\d*)\.(\d*)\s\#{\d*}/ =~ line then
        log_file_start_time = Time.gm(_time_parts[0],_time_parts[1],_time_parts[2],
        _time_parts[3],_time_parts[4],_time_parts[5]).to_i
#      end
#    puts _time_parts.inspect
    
    puts "#{$1} - #{agent_name_value}"
    puts "#{$2} - #{host_OS_value} "
    log_host_check_status = nil # reset "host check processing logic" 
    log_initialization_status = nil # reset 
    log_status = 1 # set indicator indicating that we are now processing a new log file    
    
    if log_host_check_status then  # host check is active then there is an error do
      puts "unexpected Host Check active in log processing.... stopping"
      puts "terminating execution for local exception at line: #{__LINE__}"            
      break
    end
    if log_initialization_status  then  #if log initialization is active then there is an error....
      puts "unexpected log initialization still active when logging restarted.... error"
      puts "terminating execution for local exception at line: #{__LINE__}\n while processing file #{file_name}"
      exit      
      else log_initialization_status = 1 # set flag indicating that log initiaiton & parms collection is active
      end
      # In all o ther caes, assume that a restart is possible.... and assert proper status for other indicators
      # call clean-up routines to clean other arrays if necessary

    next # and read the next record from the log
    end
    if log_host_check_status == 1 then
          if /(\**) Host Check End (\**)/ =~ line then  # see if this is the last line in Host Check processing
            log_host_check_status = 2    # if so, then mark Host check processing as complete
            puts host_OS_name
            puts host_ip_address

            puts returned_ip_address
            puts returned_host_name
            if host_OS_name != returned_host_name then puts "WARNING !!!\n Host_OS_name &  name returned from lookup don't match!!!\n\n"
            #  next         # advance to next input
            end
            
#          db_log_file = ShLogFile.find(:first , ["log_file_name" => file_name])
     if $generatedb then       
          db_log_file.host_ip_address = host_ip_address
          db_log_file.host_memory_value = host_memory          
          db_log_file.host_available_memory_value = available_memory        
          db_log_file.evm_server_appliance = appliance_identifier
          db_log_file.host_os = host_OS_value
          db_log_file.host_os_version = host_OS_version_value
          db_log_file_host_id = agent_registered_id  
          db_log_file.host_memory_value = host_memory
          db_log_file.host_available_memory_value = available_memory
          
#          result = db_log_file.update_attributes({:host_ip_address  => host_ip_address})
#         puts result.inspect
          result = db_log_file.update_attributes({:host_ip_address => host_ip_address,
            :host_memory_value => host_memory,
            :host_available_memory_value => available_memory,
            :host_os => host_OS_value,
            :host_os_version => host_OS_version_value,
            :host_id => agent_registered_id,
            :start_date_time => log_file_start_time,
            :sh_log_file_size => File.size(file_name),
            :end_date_time => File.mtime(file_name),
            :evm_server_build => server_build_level ,
            :evm_server_appliance => appliance_identifier
          })
          
#          result = db_log_file.update
          puts "#{result} returned from log_file_update for #{file_name}"
     end
        
          end
          # ESX memory info
          if VM_CONSOLE_MEMORY =~ line then host_memory = $1  # capture ESX console OS memory size
          end
          # Windows memory info
          if /Total Physical Memory:\s*(.*)\s*MB/ =~ line then
            host_memory = $1

            _host_memory = Array.new
            _host_memory = host_memory.split(",")
            if _host_memory.size > 1 then 
              host_memory = _host_memory.join
              end
            host_memory = host_memory.to_i

          end  
          if /Available Physical Memory:\s*(.*)\s*MB/ =~ line then
            available_memory = $1
            _memory = Array.new
            _memory = available_memory.split(",")
            if _memory.size > 1 then 
              available_memory = _memory.join
              end
            available_memory = available_memory.to_i

          end              
          if /Host name\: (.*)/ =~ line then host_OS_name = $1 # save host name if found
            if $generatedb then 
              host_computer_name = ShHostName.find_or_create_by_host_name(host_OS_name)
            end
            end
          if /Hostname\(IP Address\)\:\s*(\S*)\s*\((\d*\.\d*\.\d*\.\d*)\)/ =~line then
            host_OS_name = $1 if host_OS_name == nil
            host_ip_address = $2    if host_ip_address == nil   
            # build a catalog of computer names acting as a host
              if $generatedb then 
               host_computer_name = ShHostName.find_or_create_by_host_name(host_OS_name)
              end
            end
#          end
          if /\s+OS Name\:\s*(.*)$/ then
            host_OS_value = $1
            #build a catalog of OS values on which smarthost components are executing
            if $generatedb then 
              host_OS_value_record = ShHostOs.find_or_create_by_host_os(host_OS_value)
            end
          end
          if line_contains_host_os_version then
            line_contains_host_os_version = nil
            if /.* -- : (.*)/ =~ line then
            host_OS_version_value = $1  
              if $generatedb then 
              #build a catalog of OS version values in which smarthost components are executing
              host_OS_version_value_record = ShHostOsVersion.find_or_create_by_host_os_version(host_OS_version_value)
              end
            end
          end
          if /\s+OS Version:\s*(.*)$/ then
            host_OS_version_value = $1.strip
                if $generatedb then 
                  host_OS_version_value_record = ShHostOsVersion.find_or_create_by_host_os_version(host_OS_version_value)
                end
        end
          if /Begin command: \"\/usr\/bin\/vmware -v\" output:/ =~ line then
            line_contains_host_os_version = true          
          end
          

    
          if /IP Address\: (\d*.\d*.\d*.\d*)/ =~ line then host_ip_address = $1 # save host ip address if found               
            end
          if /Returned IP address \= (\d*.\d*.\d*.\d*)/ =~ line then returned_ip_address = $1 

            end
          if /Returned host name \= (.*)\./ =~ line then returned_host_name = $1           
          end
            
      end
    if log_host_check_status == nil  then # if status is  nil, then look for begin of host check sequence
      if /\** Host Check Start \**/ =~ line then log_host_check_status = 1 end
        #~ next
           #~ end
           end
#      end
    if log_initialization_status == 1 then
      case line
      when /Version:\s*(.*)/ then agent_version_value = $1
      when /:hostId: (\w*-\w*-\w*-\w*-\w*)$/ then agent_registered_id = $1
      when /:vmdbHost:\s*(.*)/ then appliance_identifier = $1 
      when /:server_build:\s*\"(\d*)\"$/ then server_build_level = $1
      end
      if /Version: (\d*.\d*.\d*.\d*)/           =~ line then agent_version_value = $1 end
      # four part version number with the last portion being the build number
      if / :hostId: (\w*-\w*-\w*-\w*-\w*)/  =~ line then agent_registered_id = $1 end
      # strings of word characters separated by dashes form the hostId
      if / :vmdbHost: (\S*)/   =~ line then 
        appliance_identifier = $1 end
      # currently the appliance_identifier is an ip address.... this is likely to change so be careful here
#      if / :vmdbHost: (\S*)/   =~ line then 
#        appliance_identifier = $1 end
    end
    
        line_split = line.split("-- : ")
         
        next  if line_split.size < 2 
        # if this is a startup line of asterisks in line_split[1] 
        # then loop thru collecting relavant startup info until the next
        # this also skips the error call backs if they are in the log
   
# if this is a standard log line then process it  
# if not then skip over it for now 
        next if line_split[0] !~ / INFO | ERROR | WARN /  
        next if line_split[1] !~ /Adding |Creating |Starting: |heartbeat |pid:|Miqhost:|Reason:/   && 
                line_split[1] !~ /Running Command\:|Command \[|ROLLING LOG/  #special commands like getagent or get logs

#        next if line_split[0] =~ / ERROR /
# if this is an error log line, then treat it special    
# 'next' statement allows loop to iterate rather than 'break'    
        line_split[0] = line_split[0].tr('[],','   ')   
        # removes brackets & comma following second word   
        line_split[0] = line_split[0].tr!('-T.','/  ')
        # this will change the date time values into the following  
        #   ccyy/mm/dd hh:mm:ss uuuuuu
        # and should not alter anything else in the array 
#        puts line_split
        prefix_element_array = line_split[0].split
        prefix_element_array[0] = prefix_element_array[0].tr('/','-')
        normalized_cmd_start = Array.new
#       puts " Prefix_element_array : #{prefix_element_array} \n\n"
        normalized_cmd_start[PROCESS_ID] =  prefix_element_array[5]
        normalized_cmd_start[LOG_START_DATE] =  prefix_element_array[2]
        normalized_cmd_start[LOG_START_TIME] =  prefix_element_array[3]
        normalized_cmd_start[LOG_START_MICRO_SECONDS] =  prefix_element_array[4]
        normalized_cmd_start[LOG_MSG_ID] =  prefix_element_array[0]
        normalized_cmd_start[LOG_MSG_TYPE] =  prefix_element_array[1]
        normalized_cmd_start[LOG_MSG_TYPE_TEXT] =  prefix_element_array[6]
        normalized_cmd_start[AGENT_VERSION] = agent_version_value
        normalized_cmd_start[AGENT_NAME] = agent_name_value
        normalized_cmd_start[APPLIANCE_IPADDR] = appliance_identifier  
        normalized_cmd_start[HOST_OS] = host_OS_value 
        normalized_cmd_start[HOST_ID] = agent_registered_id        
        normalized_cmd_start[HOST_IPADDRESS] = host_ip_address 
        normalized_cmd_start[HOST_NAME] = host_OS_name   
        normalized_cmd_start[HOST_OS_VERSION] = host_OS_version_value
        normalized_cmd_start[CMD_TARGET_VM] = nil
        normalized_cmd_start[HOST_MEMORY_SIZE] = host_memory
        normalized_cmd_start[AVAILABLE_MEMORY_SIZE] = available_memory
        prefix_element_array = "0 0 0 0 0 0 0 0".split
        # skip over all of the debug messages
        next  if normalized_cmd_start[LOG_MSG_TYPE] == "D"
                
        payload_string = line_split[1]
        payload_words = payload_string.split
        # break the payload into individual words
        
       if normalized_cmd_start[LOG_MSG_TYPE] == "E" && /Reason:\[/ =~  payload_string && /pid:\[....\]/ !~ payload_string then
       # if ERROR line with REASON text but no PID info then process the line.
          if pending_cmds.size > 0 && normalized_cmd_start[LOG_MSG_TYPE] == "E" && pending_cmds[-1][ERROR_REASON] == nil then
            # if there are pending cmds, this line is an error, and we haven't already done an error msg injection
            if /(.* for VM)\s+\[(.*)\]/ =~ payload_string then
              # examine payload to look for a certain msg format with VM name
              if pending_cmds[-1][CMD_TARGET_VM] == $2 then 
                pending_cmds[-1][ERROR_REASON] = $1  
              
                      # if VM name provided in msg and matches cmd target vm
                      # then just inject the boiler-plate not the VM name
                else
                pending_cmds[-1][ERROR_REASON] = payload_string #if pending_cmds[-1][CMD_TARGET_VM] != $2
                      ## otherwise inject the whole message
              end
            end 
            errors_identified += 1    # and increment the count of processed errors
#                      _x = pending_cmds[-1]     # _x should now be an array
          end   
          if $generatedb then               # if we are updating the support db then 
                                            # lets see if we have this error already captured
                                            # first we'll load all captured errors if not already loaded
            if $error_message_record_hash == nil || $error_message_record_hash.size == 0 then
              ShErrorMessage.find(:all).each do |x|
                $error_message_record_hash[x.id] = x.error_message
              end              
            end
                    if pending_cmds.size > 0 then    # if no commands are pending completion then skip over this section
                              # this can happen if the smarthost is started with only WARN level logging....why? who knows!?
                          if $error_message_record_hash.has_value?(pending_cmds[-1][ERROR_REASON]) then 
                               # if we have this error in the hash already, then no need to do more
                        else   # but if not, then lets update the DB and inject into hash table
                          ShErrorMessage.find_or_create_by_error_message(pending_cmds[-1][ERROR_REASON]) do |x|
                            $error_message_record_hash[x.id] = x.error_message
#                            agent_name_id = $agent_name_record_hash.index(x.agent_name)
                          end
                        end            
                    end 
          end
        end
        
        if /ROLLING LOG/ =~ payload_string then 
          $log_terminate_reason = $log_terminate_reason + "Log Rolling to new segment: " if $log_terminate_reason != "Log Rolling to new segment: "
          normalized_cmd_start[LOG_STOP_DATE] = normalized_cmd_start[LOG_START_DATE]
          normalized_cmd_start[LOG_STOP_TIME] = normalized_cmd_start[LOG_START_TIME]
          normalized_cmd_start[LOG_STOP_MICRO_SECONDS] = normalized_cmd_start[LOG_START_MICRO_SECONDS]
          normalized_cmd_start[CMD_NAME] = "ROLLING_LOG"
          normalized_cmd_start[CMD_DURATION] = 0.0
          normalized_cmd_start[CMD_PARMS] = payload_words[2].tr("\[\]","  ").strip
          completed_cmds << normalized_cmd_start
          completed_commands_count += 1
          
                      if $generatedb then
                        create_command_history(normalized_cmd_start)
                        
#                        if $error_message_record_hash == nil || $error_message_record_hash.size == 0 then
#                          ShErrorMessage.find(:all).each do |x|
#                            $error_message_record_hash[x.id] = x.error_message
#                          end              
#                        end
#                        if $error_message_record_hash.has_value?(normalized_cmd_start[ERROR_REASON]) then 
##                          agent_name_id = $agent_name_record_hash.index(normalized_cmd_start[AGENT_NAME])
#                        else
#                          ShErrorMessage.find_or_create_by_error_message(normalized_cmd_start [ERROR_REASON]) do |x|
#                            $error_message_record_hash[x.id] = x.error_message
##                            agent_name_id = $agent_name_record_hash.index(x.agent_name)
#                          end
#                        end                  
#              
#                        if $agent_name_record_hash == nil || $agent_name_record_hash.size == 0 then
#                          
##                         agent_name_record_hash = ShAgentName.find(:all)
#                         ShAgentName.find(:all).each do |_agent_name|
#                           $agent_name_record_hash[_agent_name.id] = _agent_name.agent_name
#                         end
##                         end
##                         agent_name_record_hash.each {|x| puts "#{x.class} #{x.inspect}" 
##                           puts "x['id'}= #{x['id']} - y['agent_name'] = #{x['agent_name']}"
##                           $agent_name_record_hash[x['id']] = x['agent_name']
##                         }
#                        end
#                        if $process_id_record_hash == nil || $process_id_record_hash.size == 0 then
##                          process_id_record_hash = ShProcessId.find(:all)
#                          ShProcessId.find(:all).each do |x|
#                            $process_id_record_hash[x.id] = x.process_id
#                          end
##                          process_id_record_hash.each { |x| 
##                            $process_id_record_hash[x['id']] = x['process_id']
##                          }
#                        end
#                        if $command_name_record_hash == nil || $command_name_record_hash.size == 0 then
##                          command_name_record_hash = ShCommandName.find(:all)
#                            ShCommandName.find(:all).each do |x|
#                              $command_name_record_hash[x.id] = x.command_name
#                            end
##                          command_name_record_hash.each { |x| 
##                            # puts "#{x.inspect}\n"
##                          $command_name_record_hash[x['id']] = x['command_name'] }
#                        end
#                        if $command_result_record_hash == nil || $command_result_record_hash.size == 0 then
##                            command_result_record_hash = ShCommandResult.find(:all)
#                         ShCommandResult.find(:all).each do |x|
#                           $command_result_record_hash[x.id] = x.command_result
#                         end
##                           
##                            command_result_record_hash.each { |x| 
##                              # puts "#{x.inspect}\n"
##                              $command_result_record_hash[x['id']] = x['command_result']}
#                        end
#                        if $vm_name_record_hash == nil || $vm_name_record_hash.size == 0 then
##                            vm_name_record_hash = ShVmName.find(:all)
#                        ShVmName.find(:all).each do |x|
#                          $vm_name_record_hash[x.id] = x.vm_name
#                        end
##                            vm_name_record_hash.each { |x| 
##                              # puts "#{x.inspect}\n"
##                              $vm_name_record_hash[x['id']] = x['vm_name']
##                              
##                            }
#                        end
#                        if $command_parm_record_hash == nil || $command_parm_record_hash.size == 0 then
##                            command_parm_record_hash = ShCommandParm.find(:all)
#                        ShCommandParm.find(:all).each do |x| 
#                          $command_parm_record_hash[x.id] = x.command_parm
#                        end
##                            command_parm_record_hash.each { |x| 
##                              puts "#{x.inspect}\n"
##                              $command_parm_record_hash[x['id']] = x['command_parm']
##                              }
#                        end
#                        command_summary_record = ShCommandHistory.new
#                        if $agent_name_record_hash.has_value?(normalized_cmd_start[AGENT_NAME]) then 
#                          agent_name_id = $agent_name_record_hash.index(normalized_cmd_start[AGENT_NAME])
#                        else
#                          ShAgentName.find_or_create_by_agent_name(normalized_cmd_start[AGENT_NAME]) do |x|
#                            $agent_name_record_hash[x.id] = x.agent_name
#                            agent_name_id = $agent_name_record_hash.index(x.agent_name)
#                          end
#                        end
##                        agent_name_record = ShAgentName.find_or_create_by_agent_name(normalized_cmd_start[AGENT_NAME]) 
##                        process_id_record = ShProcessId.find_or_create_by_process_id(normalized_cmd_start[PROCESS_ID])
#                        
##                        thread_id_record = ShThreadId.find_or_create_by_thread_id(normalized_cmd_start[THREAD_ID])
##                        command_name_record = ShCommandName.find_or_create_by_command_name(normalized_cmd_start[CMD_NAME])
##                        command_parms_record = ShCommandParm.find_or_create_by_command_parm(normalized_cmd_start[CMD_PARMS])
##                        command_result_record = ShCommandResult.find_or_create_by_command_result(normalized_cmd_start[CMD_COMPLETION_STATUS])
##                        vm_name_record = ShVmName.find_or_create_by_vm_name(normalized_cmd_start[CMD_TARGET_VM])
#                        command_summary_record.log_duration_seconds = normalized_cmd_start[CMD_DURATION]
#                        command_summary_record.sh_error_message_id = 
#                              $error_message_record_hash.index(normalized_cmd_start[ERROR_REASON])
#                        command_summary_record.sh_process_id_id = 
#                              $process_id_record_hash.index(normalized_cmd_start[PROCESS_ID]) #process_id_record.id
#                        command_summary_record.sh_thread_id_id = 
#                              $thread_id_record_hash.index(normalized_cmd_start[THREAD_ID]) #thread_id_record.id
#                        command_summary_record.sh_command_name_id = 
#                               $command_name_record_hash.index(normalized_cmd_start[CMD_NAME])   #command_name_record.id
#                        command_summary_record.sh_command_result_id = 
#                                $command_result_record_hash.index(normalized_cmd_start[CMD_COMPLETION_STATUS])  #command_result_record.id
#                        command_summary_record.sh_command_parm_id = 
#                                $command_parm_record_hash.index(normalized_cmd_start[CMD_PARMS]) #command_parms_record.id
#                        command_summary_record.sh_vm_name_id = 
#                                $vm_name_record_hash.index(normalized_cmd_start[CMD_TARGET_VM])    #vm_name_record.id
#                        command_summary_record.sh_log_file_name_id = db_log_file.id
#                        gm_time_input = (normalized_cmd_start[LOG_START_DATE].tr("/",",").to_s + "," )
#                        gm_time_input = ( gm_time_input  + normalized_cmd_start[LOG_START_TIME].tr(":",",").to_s + ",")
#                        gm_time_input = (gm_time_input  + normalized_cmd_start[LOG_START_MICRO_SECONDS].to_s)
#                        command_summary_record.log_start_time = Time.gm(gm_time_input)
#                        result = command_summary_record.save
                      end
      
      
          # this is probably the last "command" to be processed in this log
          next
        end
        case payload_words[0]
                  when /Error/    then  (

      ) # catch "Error Trace:" here and ignore it
                   
                  when /taskLoop:/  then ( ) # catch "taskLoop:" here and ignore it
                  when /Running/ then (
                      puts "#{line}"
                      if /Running Command:\s*\[(\w*)\s(.*)\]/ =~ payload_string then
                         normalized_cmd_start[CMD_NAME] = $1
                         normalized_cmd_start[CMD_PARMS] = $2
                         case $1
                         when /GetAgentLogs/ then 
                           normalized_cmd_start[THREAD_ID] = "GAL"
                           
                         when /GetAgent/ then normalized_cmd_start[THREAD_ID] = "GAB"
                          end
                         normalized_cmd_start[UNIQUE_TASKCMD_KEY] = normalized_cmd_start[PROCESS_ID]+
                             normalized_cmd_start[THREAD_ID]+normalized_cmd_start[CMD_NAME]                  
                         pending_cmds[pending_cmds_index] = normalized_cmd_start
                         pending_cmds_index += 1    
                        # processing should be completed                         
                      end
      
      )
                  when /Command/ then (
#                    Command [GetAgentLogs] completed successfully   

                    case payload_words[1]
                    when /\[GetAgentLogs\]|\[GetAgent\]/ then 
                      completed_cmd = payload_words[1].tr("\[\]","  ").strip
                      case completed_cmd
                      when /GetAgentLogs/ then normalized_cmd_start[THREAD_ID] = "GAL"
                      when/GetAgent/  then normalized_cmd_start[THREAD_ID] = "GAB"
                      end
                      #search for cmd initiation on array
                     initiating_cmd_line = pending_cmds.assoc(normalized_cmd_start[PROCESS_ID] +
                             normalized_cmd_start[THREAD_ID] + completed_cmd )
                     if initiating_cmd_line 
                     pending_cmds.delete(initiating_cmd_line)
                     pending_cmds_index -= 1   
                     end
                     if initiating_cmd_line == nil   # come here if there is no match in pending_cmds array
                     puts "unable to find command initiation\n #{line}" 
                     next # this can't go to a good place, lets terminate processing for now
                     end
                     initiating_cmd_line[LOG_STOP_DATE] = normalized_cmd_start[LOG_START_DATE] 
                     initiating_cmd_line[LOG_STOP_TIME] = normalized_cmd_start[LOG_START_TIME] 
                     initiating_cmd_line[LOG_STOP_MICRO_SECONDS] = normalized_cmd_start[LOG_START_MICRO_SECONDS] 
                     
                     initiating_cmd_line[CMD_COMPLETION_STATUS] = payload_words[2]
                     case completed_cmd  #this code block is trying to get or manufacture command duration
                     when "GetAgent" then initiating_cmd_line[CMD_DURATION]= payload_words[-2].tr('[]','  ').strip
                     when "GetAgentLogs" then (
                         # CALCULATE START DATE TIME
                         _y_m_d = initiating_cmd_line[LOG_START_DATE].tr("/",",").split(",")
                         _h_m_s = initiating_cmd_line[LOG_START_TIME].tr(":",",").split(",")

                        _gm_time_start = Time.gm(_y_m_d[0].to_i,_y_m_d[1].to_i,_y_m_d[2].to_i,_h_m_s[0].to_i,_h_m_s[1].to_i,_h_m_s[2].to_i,
                        initiating_cmd_line[LOG_START_MICRO_SECONDS].to_i)
                        
                          #CALCULATE STOP DATE TIME 
                         _y_m_d = initiating_cmd_line[LOG_STOP_DATE].tr("/",",").split(",")
                         _h_m_s = initiating_cmd_line[LOG_STOP_TIME].tr(":",",").split(",")

                       _gm_time_end = Time.gm(_y_m_d[0].to_i,_y_m_d[1].to_i,_y_m_d[2].to_i,_h_m_s[0].to_i,_h_m_s[1].to_i,_h_m_s[2].to_i,
                        initiating_cmd_line[LOG_STOP_MICRO_SECONDS].to_i)
              
                        initiating_cmd_line[CMD_DURATION] = _gm_time_end - _gm_time_start  
                       )
                     end
   
                          completed_cmds << initiating_cmd_line   
                          completed_commands_count += 1 

                                if $generatedb then 
                                  
                                create_command_history(initiating_cmd_line)
                                end
          
          
          
                    end
      
      )

                    
                  when /Creating/   then (
                      if /.*for\s\[(.*)\][\.|\s]/ =~ payload_string then
                        normalized_cmd_start[CMD_TARGET_VM]= $1
                      end
                      normalized_cmd_start[CMD_NAME] = payload_words[0..1].join("_")
                      case payload_words[2]
                      when /started/ then
                        # all of the information for this command should now be collected and the start sequence placed 
                        # the pending completion queue
                       normalized_cmd_start[THREAD_ID] = " "
                       normalized_cmd_start[UNIQUE_TASKCMD_KEY] = normalized_cmd_start[PROCESS_ID]+
                                   normalized_cmd_start[THREAD_ID]+normalized_cmd_start[CMD_NAME]                  
                        pending_cmds[pending_cmds_index] = normalized_cmd_start
                        pending_cmds_index += 1    
                        # processing should be completed  
                        
                        when /completed|failed/ then
                          normalized_cmd_start[THREAD_ID] = " "
                          completed_cmd = payload_words[0..1].join("_")
 
                           # if non-nil is returned from the *.assoc method, then remove the array element
                           # and decrement the counter
                           pending_cmds_index -= 1                          
                          
                          initiating_cmd_line[CMD_COMPLETION_STATUS] = payload_words[2]
                          initiating_cmd_line[CMD_DURATION]= payload_words[-2].tr('[]','  ').strip
                          #following lines populates log line as command end time
                          initiating_cmd_line[LOG_STOP_DATE] = normalized_cmd_start[LOG_START_DATE] 
                          initiating_cmd_line[LOG_STOP_TIME] = normalized_cmd_start[LOG_START_TIME] 
                          initiating_cmd_line[LOG_STOP_MICRO_SECONDS] = normalized_cmd_start[LOG_START_MICRO_SECONDS]   
                          # consistent output to open output files
#                          prefix_file.puts initiating_cmd_line.inspect    
                          completed_cmds << initiating_cmd_line   
                          completed_commands_count += 1 

                                if $generatedb then 
                                  
                                create_command_history(initiating_cmd_line)
                        
#                        if $error_message_record_hash == nil || $error_message_record_hash.size == 0 then
#                          ShErrorMessage.find(:all).each do |x|
#                            $error_message_record_hash[x.id] = x.error_message
#                          end              
#                        end
#                        if $error_message_record_hash.has_value?(initiating_cmd_line[ERROR_REASON]) then 
##                          agent_name_id = $agent_name_record_hash.index(initiating_cmd_line[AGENT_NAME])
#                        else
#                          ShErrorMessage.find_or_create_by_error_message(initiating_cmd_line [ERROR_REASON]) do |x|
#                            $error_message_record_hash[x.id] = x.error_message
##                            agent_name_id = $agent_name_record_hash.index(x.agent_name)
#                          end
#                        end                  
#              
#                        if $agent_name_record_hash == nil || $agent_name_record_hash.size == 0 then
#                          
##                         agent_name_record_hash = ShAgentName.find(:all)
#                         ShAgentName.find(:all).each do |_agent_name|
#                           $agent_name_record_hash[_agent_name.id] = _agent_name.agent_name
#                         end
##                         end
##                         agent_name_record_hash.each {|x| puts "#{x.class} #{x.inspect}" 
##                           puts "x['id'}= #{x['id']} - y['agent_name'] = #{x['agent_name']}"
##                           $agent_name_record_hash[x['id']] = x['agent_name']
##                         }
#                        end
#                        if $process_id_record_hash == nil || $process_id_record_hash.size == 0 then
##                          process_id_record_hash = ShProcessId.find(:all)
#                          ShProcessId.find(:all).each do |x|
#                            $process_id_record_hash[x.id] = x.process_id
#                          end
##                          process_id_record_hash.each { |x| 
##                            $process_id_record_hash[x['id']] = x['process_id']
##                          }
#                        end
#                        if $command_name_record_hash == nil || $command_name_record_hash.size == 0 then
##                          command_name_record_hash = ShCommandName.find(:all)
#                            ShCommandName.find(:all).each do |x|
#                              $command_name_record_hash[x.id] = x.command_name
#                            end
##                          command_name_record_hash.each { |x| 
##                            # puts "#{x.inspect}\n"
##                          $command_name_record_hash[x['id']] = x['command_name'] }
#                        end
#                        if $command_result_record_hash == nil || $command_result_record_hash.size == 0 then
##                            command_result_record_hash = ShCommandResult.find(:all)
#                         ShCommandResult.find(:all).each do |x|
#                           $command_result_record_hash[x.id] = x.command_result
#                         end
##                           
##                            command_result_record_hash.each { |x| 
##                              # puts "#{x.inspect}\n"
##                              $command_result_record_hash[x['id']] = x['command_result']}
#                        end
#                        if $vm_name_record_hash == nil || $vm_name_record_hash.size == 0 then
##                            vm_name_record_hash = ShVmName.find(:all)
#                        ShVmName.find(:all).each do |x|
#                          $vm_name_record_hash[x.id] = x.vm_name
#                        end
##                            vm_name_record_hash.each { |x| 
##                              # puts "#{x.inspect}\n"
##                              $vm_name_record_hash[x['id']] = x['vm_name']
##                              
##                            }
#                        end
#                        if $command_parm_record_hash == nil || $command_parm_record_hash.size == 0 then
##                            command_parm_record_hash = ShCommandParm.find(:all)
#                        ShCommandParm.find(:all).each do |x| 
#                          $command_parm_record_hash[x.id] = x.command_parm
#                        end
##                            command_parm_record_hash.each { |x| 
##                              puts "#{x.inspect}\n"
##                              $command_parm_record_hash[x['id']] = x['command_parm']
##                              }
#                        end
#                        command_summary_record = ShCommandHistory.new
#                        if $agent_name_record_hash.has_value?(initiating_cmd_line[AGENT_NAME]) then 
#                          agent_name_id = $agent_name_record_hash.index(initiating_cmd_line[AGENT_NAME])
#                        else
#                          ShAgentName.find_or_create_by_agent_name(initiating_cmd_line[AGENT_NAME]) do |x|
#                            $agent_name_record_hash[x.id] = x.agent_name
#                            agent_name_id = $agent_name_record_hash.index(x.agent_name)
#                          end
#                        end
##                        agent_name_record = ShAgentName.find_or_create_by_agent_name(initiating_cmd_line[AGENT_NAME]) 
##                        process_id_record = ShProcessId.find_or_create_by_process_id(initiating_cmd_line[PROCESS_ID])
#                        
##                        thread_id_record = ShThreadId.find_or_create_by_thread_id(initiating_cmd_line[THREAD_ID])
##                        command_name_record = ShCommandName.find_or_create_by_command_name(initiating_cmd_line[CMD_NAME])
##                        command_parms_record = ShCommandParm.find_or_create_by_command_parm(initiating_cmd_line[CMD_PARMS])
##                        command_result_record = ShCommandResult.find_or_create_by_command_result(initiating_cmd_line[CMD_COMPLETION_STATUS])
##                        vm_name_record = ShVmName.find_or_create_by_vm_name(initiating_cmd_line[CMD_TARGET_VM])
#                        command_summary_record.log_duration_seconds = initiating_cmd_line[CMD_DURATION]
#                        command_summary_record.sh_error_message_id = 
#                              $error_message_record_hash.index(initiating_cmd_line[ERROR_REASON])
#                        command_summary_record.sh_process_id_id = 
#                              $process_id_record_hash.index(initiating_cmd_line[PROCESS_ID]) #process_id_record.id
#                        command_summary_record.sh_thread_id_id = 
#                              $thread_id_record_hash.index(initiating_cmd_line[THREAD_ID]) #thread_id_record.id
#                        command_summary_record.sh_command_name_id = 
#                               $command_name_record_hash.index(initiating_cmd_line[CMD_NAME])   #command_name_record.id
#                        command_summary_record.sh_command_result_id = 
#                                $command_result_record_hash.index(initiating_cmd_line[CMD_COMPLETION_STATUS])  #command_result_record.id
#                        command_summary_record.sh_command_parm_id = 
#                                $command_parm_record_hash.index(initiating_cmd_line[CMD_PARMS]) #command_parms_record.id
#                        command_summary_record.sh_vm_name_id = 
#                                $vm_name_record_hash.index(initiating_cmd_line[CMD_TARGET_VM])    #vm_name_record.id
#                        command_summary_record.sh_log_file_name_id = db_log_file.id
#                        gm_time_input = (initiating_cmd_line[LOG_START_DATE].tr("/",",").to_s + "," )
#                        gm_time_input = ( gm_time_input  + initiating_cmd_line[LOG_START_TIME].tr(":",",").to_s + ",")
#                        gm_time_input = (gm_time_input  + initiating_cmd_line[LOG_START_MICRO_SECONDS].to_s)
#                        command_summary_record.log_start_time = Time.gm(gm_time_input)
#                        result = command_summary_record.save
                      end

                      end
                           )
                 
                  when /pid:/ then (
              normalized_cmd_start[THREAD_ID] = payload_words[0].tr!('[]:','"" ').split.pop
#              set the thread id
#              next if payload[1].strip != "Running"
              case payload_words[1]
                    when  /Running/ then (                           
                      normalized_cmd_start[CMD_NAME] = payload_words[3].tr('[]','  ').strip
#   command name                      
#                      normalized_cmd_start[CMD_PARMS] = payload_words[4..payload_words.size].join(" ") if , 
 #                     normalized_cmd_start[CMD_NAME] !~ /hostheartbeat|agentregister|gethostconfig/
                      case normalized_cmd_start[CMD_NAME] 
                         when /monitoremsevents/ then normalized_cmd_start[CMD_PARMS] = payload_words[4..payload_words.size].join(" ")
                         when   /gethostconfig/  then normalized_cmd_start[CMD_PARMS] = nil 
                         when   /agentregister/  then normalized_cmd_start[CMD_PARMS] = nil 
                         when   /agentregister/  then normalized_cmd_start[CMD_PARMS] = nil 
                         when   /hostheartbeat|savehostmetadata/  then normalized_cmd_start[CMD_PARMS] = payload_words[4] 
                         when   /fleecemetadata|extractmetadata|scanmetadata|syncmetadata|stopvm|startvm/  then 
                           normalized_cmd_start[CMD_PARMS] = payload_words[4..payload_words.size].join(" ").tr(","," ") 
                           if /--taskid\=\".*\"\s*(.*)\]/ =~ normalized_cmd_start[CMD_PARMS] then
                             normalized_cmd_start[CMD_TARGET_VM] = $1
                           end
                         when /getvmconfig|getvmstate/   then 
                           work_string, normalized_cmd_start[CMD_TARGET_VM],  = payload_words[4..payload_words.size].join(" ")
                           normalized_cmd_start[CMD_PARMS] = work_string
                           if work_string[work_string.length-1,1] == "]" then   
                            normalized_cmd_start[CMD_TARGET_VM]= work_string[0,work_string.length-1] 
                           elsif normalized_cmd_start[CMD_TARGET_VM]= work_string
                           end

                         when /sendvmstate|registerid/   then 
                           normalized_cmd_start[CMD_PARMS] = payload_words[4..payload_words.size].join(" ")
                           normalized_cmd_start[CMD_TARGET_VM] = payload_words[4..(payload_words.size - 2)].join(" ")
#                            if /(.*)[ off\]| on\]]/ =~ work_string  then
#                              normalized_cmd_start[CMD_TARGET_VM] = $1 
#                            end
                         else normalized_cmd_start[CMD_PARMS] = payload_words[4..payload_words.size].join(" ")
                         
                      end
#   command parameters    
                      normalized_cmd_start[UNIQUE_TASKCMD_KEY] = normalized_cmd_start[PROCESS_ID]+
                                   normalized_cmd_start[THREAD_ID]+normalized_cmd_start[CMD_NAME]                  
 #                     puts "Normalized Command Start object is : => #{normalized_cmd_start.inspect}\n\n"
 #                     puts normalized_cmd_start.inspect
                      pending_cmds[pending_cmds_index] = normalized_cmd_start
                      pending_cmds_index += 1 
 #                     pending_cmds.each { |x| puts "   pending_cmds element #{x.inspect}\n\n " }

 #       puts "PENDING_CMDS VALUES = #{pending_cmds}"
 #       puts  "<><><><><><><><><><><>"
 #       puts "pending_cmds number of elements:=> #{pending_cmds.size}"                      
 #                     puts pending_cmds.inspect                    
#                     exit  
                    )
                    when  /Command/ then (
                      completed_cmd = payload_words[2].tr('[]','  ').strip.to_s
                      initiating_cmd_line = pending_cmds.assoc(normalized_cmd_start[PROCESS_ID]+
                                   normalized_cmd_start[THREAD_ID]+completed_cmd )
                       if initiating_cmd_line then pending_cmds.delete(initiating_cmd_line)
                       else puts "line number #{__LINE__} of input log '#{file_name}' with value :"
                            puts "      '#{line}' has no corresponding start record in this log and is being dropped"
                            next
                       end        
                       pending_cmds.delete(initiating_cmd_line) if initiating_cmd_line
                       # if non-nil is returned from the *.assoc method, then remove the array element
                       # and decrement the counter
                       pending_cmds_index -= 1
                                   
#                     puts normalized_cmd_start[PROCESS_ID].inspect
#                     puts normalized_cmd_start[THREAD_ID].inspect
#                      puts " Completed Command => #{completed_cmd} \n\n  "          
#                      puts " returned 'initiating_cmd_line' #{initiating_cmd_line}"
#                         puts "DATA LINE CONTENTS '#{line}' \n\n"
#                         puts "LOG_STOP_DATE #{LOG_STOP_DATE}\n\n"
#                         puts "LOG_START_DATE #{LOG_START_DATE}\n"
#                         puts "normalized_cmd_start[LOG_START_DATE] = #{normalized_cmd_start[LOG_START_DATE]}\n"
                       initiating_cmd_line[LOG_STOP_DATE] = normalized_cmd_start[LOG_START_DATE] 
                       initiating_cmd_line[LOG_STOP_TIME] = normalized_cmd_start[LOG_START_TIME] 
                       initiating_cmd_line[LOG_STOP_MICRO_SECONDS] = normalized_cmd_start[LOG_START_MICRO_SECONDS] 

#                      break                                   
                      initiating_cmd_line[CMD_COMPLETION_STATUS] = payload_words[3]
                      if payload_words[3].strip == "failed" then
                        # need to read next sequential record in log file
                        # so save current position 
                        _remember_position = input_file.pos
                        # then read the record
                        _error_info_check = input_file.gets
                        # parse it to make sure that it belongs to this error
                        if /Error Trace:\s*\[*(.*)\]*^/ =~ _error_info_check then
                          initiating_cmd_line[ERROR_REASON] = $1
                        end
                        # inject error into array
                        # restore log prior position like nothing ever happened
                        input_file.pos = _remember_position
                        # and end code block
                      end
#                      case completed_cmd
#                        when /extractmetadata/ then initiating_cmd_line[CMD_DURATION] = payload_words[payload_words.size - 3].tr('[]','  ').strip
#                        when /fleecemetadata/ then initiating_cmd_line[CMD_DURATION] = payload_words[payload_words.size - 3].tr('[]','  ').strip                          
#                        else initiating_cmd_line[CMD_DURATION] = payload_words[payload_words.size - 2].tr('[]','  ').strip
#                      end
                      case payload_string
                      when /taskid|TaskId/ then initiating_cmd_line[CMD_DURATION] = payload_words[payload_words.size - 3].tr('[]','  ').strip
                      else initiating_cmd_line[CMD_DURATION] = payload_words[payload_words.size - 2].tr('[]','  ').strip
                      end
#                       if completed_cmd == "hostheartbeat"
#                      initiating_cmd_line[CMD_DURATION] = payload_words[payload_words.size - 3].tr('[]','  ').strip if completed_cmd == "extractmetadata"                      
#                     completed_command = running_cmds.with_id(log_line_process_id, threadid, terminating_command)
 #                     puts initiating_cmd_line.class
 #                     puts "#{initiating_cmd_line}"
#                      prefix_file.puts initiating_cmd_line.inspect    
#                  puts "lines read is #{loglinecnt}\n input line is '#{line}\n initiating_cmd_line is #{initiating_cmd_line.inspect}"
                      completed_cmds << initiating_cmd_line 
                      completed_commands_count += 1
                      if $generatedb then
                        create_command_history(initiating_cmd_line)
#                        
#                        if $error_message_record_hash == nil || $error_message_record_hash.size == 0 then
#                          ShErrorMessage.find(:all).each do |x|
#                            $error_message_record_hash[x.id] = x.error_message
#                          end              
#                        end
#                        if $error_message_record_hash.has_value?(initiating_cmd_line[ERROR_REASON]) then 
##                          agent_name_id = $agent_name_record_hash.index(initiating_cmd_line[AGENT_NAME])
#                        else
#                          ShErrorMessage.find_or_create_by_error_message(initiating_cmd_line [ERROR_REASON]) do |x|
#                            $error_message_record_hash[x.id] = x.error_message
##                            agent_name_id = $agent_name_record_hash.index(x.agent_name)
#                          end
#                        end                  
#              
#                        if $agent_name_record_hash == nil || $agent_name_record_hash.size == 0 then
#                          
##                         agent_name_record_hash = ShAgentName.find(:all)
#                         ShAgentName.find(:all).each do |_agent_name|
#                           $agent_name_record_hash[_agent_name.id] = _agent_name.agent_name
#                         end
##                         end
##                         agent_name_record_hash.each {|x| puts "#{x.class} #{x.inspect}" 
##                           puts "x['id'}= #{x['id']} - y['agent_name'] = #{x['agent_name']}"
##                           $agent_name_record_hash[x['id']] = x['agent_name']
##                         }
#                        end
#                        if $process_id_record_hash == nil || $process_id_record_hash.size == 0 then
##                          process_id_record_hash = ShProcessId.find(:all)
#                          ShProcessId.find(:all).each do |x|
#                            $process_id_record_hash[x.id] = x.process_id
#                          end
##                          process_id_record_hash.each { |x| 
##                            $process_id_record_hash[x['id']] = x['process_id']
##                          }
#                        end
#                        if $command_name_record_hash == nil || $command_name_record_hash.size == 0 then
##                          command_name_record_hash = ShCommandName.find(:all)
#                            ShCommandName.find(:all).each do |x|
#                              $command_name_record_hash[x.id] = x.command_name
#                            end
##                          command_name_record_hash.each { |x| 
##                            # puts "#{x.inspect}\n"
##                          $command_name_record_hash[x['id']] = x['command_name'] }
#                        end
#                        if $command_result_record_hash == nil || $command_result_record_hash.size == 0 then
##                            command_result_record_hash = ShCommandResult.find(:all)
#                         ShCommandResult.find(:all).each do |x|
#                           $command_result_record_hash[x.id] = x.command_result
#                         end
##                           
##                            command_result_record_hash.each { |x| 
##                              # puts "#{x.inspect}\n"
##                              $command_result_record_hash[x['id']] = x['command_result']}
#                        end
#                        if $vm_name_record_hash == nil || $vm_name_record_hash.size == 0 then
##                            vm_name_record_hash = ShVmName.find(:all)
#                        ShVmName.find(:all).each do |x|
#                          $vm_name_record_hash[x.id] = x.vm_name
#                        end
##                            vm_name_record_hash.each { |x| 
##                              # puts "#{x.inspect}\n"
##                              $vm_name_record_hash[x['id']] = x['vm_name']
##                              
##                            }
#                        end
#                        if $command_parm_record_hash == nil || $command_parm_record_hash.size == 0 then
##                            command_parm_record_hash = ShCommandParm.find(:all)
#                        ShCommandParm.find(:all).each do |x| 
#                          $command_parm_record_hash[x.id] = x.command_parm
#                        end
##                            command_parm_record_hash.each { |x| 
##                              puts "#{x.inspect}\n"
##                              $command_parm_record_hash[x['id']] = x['command_parm']
##                              }
#                        end
#                        command_summary_record = ShCommandHistory.new
#                        if $agent_name_record_hash.has_value?(initiating_cmd_line[AGENT_NAME]) then 
#                          agent_name_id = $agent_name_record_hash.index(initiating_cmd_line[AGENT_NAME])
#                        else
#                          ShAgentName.find_or_create_by_agent_name(initiating_cmd_line[AGENT_NAME]) do |x|
#                            $agent_name_record_hash[x.id] = x.agent_name
#                            agent_name_id = $agent_name_record_hash.index(x.agent_name)
#                          end
#                        end
##                        agent_name_record = ShAgentName.find_or_create_by_agent_name(initiating_cmd_line[AGENT_NAME]) 
##                        process_id_record = ShProcessId.find_or_create_by_process_id(initiating_cmd_line[PROCESS_ID])
#                        
##                        thread_id_record = ShThreadId.find_or_create_by_thread_id(initiating_cmd_line[THREAD_ID])
##                        command_name_record = ShCommandName.find_or_create_by_command_name(initiating_cmd_line[CMD_NAME])
##                        command_parms_record = ShCommandParm.find_or_create_by_command_parm(initiating_cmd_line[CMD_PARMS])
##                        command_result_record = ShCommandResult.find_or_create_by_command_result(initiating_cmd_line[CMD_COMPLETION_STATUS])
##                        vm_name_record = ShVmName.find_or_create_by_vm_name(initiating_cmd_line[CMD_TARGET_VM])
#                        command_summary_record.log_duration_seconds = initiating_cmd_line[CMD_DURATION]
#                        command_summary_record.sh_error_message_id = 
#                              $error_message_record_hash.index(initiating_cmd_line[ERROR_REASON])
#                        command_summary_record.sh_process_id_id = 
#                              $process_id_record_hash.index(initiating_cmd_line[PROCESS_ID]) #process_id_record.id
#                        command_summary_record.sh_thread_id_id = 
#                              $thread_id_record_hash.index(initiating_cmd_line[THREAD_ID]) #thread_id_record.id
#                        command_summary_record.sh_command_name_id = 
#                               $command_name_record_hash.index(initiating_cmd_line[CMD_NAME])   #command_name_record.id
#                        command_summary_record.sh_command_result_id = 
#                                $command_result_record_hash.index(initiating_cmd_line[CMD_COMPLETION_STATUS])  #command_result_record.id
#                        command_summary_record.sh_command_parm_id = 
#                                $command_parm_record_hash.index(initiating_cmd_line[CMD_PARMS]) #command_parms_record.id
#                        command_summary_record.sh_vm_name_id = 
#                                $vm_name_record_hash.index(initiating_cmd_line[CMD_TARGET_VM])    #vm_name_record.id
#                        command_summary_record.sh_log_file_name_id = db_log_file.id
#                        gm_time_input = (initiating_cmd_line[LOG_START_DATE].tr("/",",").to_s + "," )
#                        gm_time_input = ( gm_time_input  + initiating_cmd_line[LOG_START_TIME].tr(":",",").to_s + ",")
#                        gm_time_input = (gm_time_input  + initiating_cmd_line[LOG_START_MICRO_SECONDS].to_s)
#                        command_summary_record.log_start_time = Time.gm(gm_time_input)
#                        result = command_summary_record.save
                      end
                        
#                      puts agent_name_record.inspect
#                      command_summary.

                      
#                      completed_command.add_stop_time(log_line_date, log_line_time,log_line_micro_seconds, terminating_command_duration,terminating_command_status)
#                      puts  "&*&*&*&*&* pulled from Active_Commands class is => "
#                      puts " #{completed_command.inspect}"
#                      puts  "&*&*&*&*&*& \n"
#                      command_payloads.puts #{initiating_cmd_line}
#                      exit
                    )   
                  when /Starting/ then (      #for the time being, we'll skip "Starting" processing
                  )           
                  when/Adding/ then ( 
                  ) 
                else 
                      next
                end
                
              ) # end                
            when /Miqhost\:/ then (
              case payload_words[1]
                when /Shutdown/ then (
                  # logic needs to be inserted here to clear out all queued work & any commands pending completion!!!
                  # we may also need to distinguish between shutdown initiation and shutdown completion!!!
                  puts "processing has reached miqhost shutdown logic at input line #{loglinecnt}"
                  log_status, log_host_check_status, log_initialization_status = nil
                  # reset all of the log status flags to allow a following restart to initialize correctly
                  )
                else
                 end 
                )     
            when /Adding/ then ( 
 #             puts line
 #              the adding log line has a queue type, a command, that may have a task/jobid and may have one or more parms.
 #              consider the "immediate.csv" to be created using these as columns with the other static stuff of course....
              if /extractmetadata --category\=\"(.*?)\" --from_time\=\"(.*)\" --.*id\=\"(.*)\" (.*) to queue \[(\w*)\]/ =~ line then
#                puts "extractmetadata info =' #{$1}'  \n     from time= #{$2} \n taskid = '#{$3}' \n    info following taskid is ' #{$4}' \n     added to queue' #{$5}'"
              next 
              end 
              if /savehostmetadata (.*) \<\?.*\?\>\<(.*)\] to queue \[(\w*)\]$/ =~ line then
 #               puts "savehostmetadata for host ='#{$1}'\n     with parms '#{$2}'\n     added to queue'#{$3}'"
              next
            end  
              if /registerid (.*) --.*id\=(.*)\] to queue \[(\w*)\]/ =~ line then
#                puts "registerid for host ='#{$1}'\n     with id ='#{$2}'\n     added to queue'#{$3}'"
              next
            end  
              if /getvmconfig (.*)\] to queue \[(\w*)\]$/ =~ line then
#                puts "getvmconfig for vmhost ='#{$1}'\n     added to queue'#{$2}'"
              next
            end  
              if /[fleecemetadata|scanmetadata] (.*) --.*id\=\"(.*)\" (.*)\] to queue \[(\w*)\]/ =~ line then
#                puts "scanmetadata for data ='#{$1}'\n     from machine #{$3}\n     taskid = '#{$2}'\n     added to queue'#{$4}'"
              next
            end  
              if /sendvmstate (.*)\] to queue \[(\w*)\]/ =~ line then
#                puts "sendvmstate for VM ='#{$1}'\n     added to queue'#{$2}'"
              next
              end                
#              if /Adding task \[(\w*) (.*\s)(.*)\] to queue \[(\w*)\]/ =~ line then
#                puts "Command name is #{$1}"
#                puts  "first parm is #{$2}" 
#                puts "following parm(s) is #{$3}"
#                puts "added to #{$4} queue"
#                end
              )
            when /Starting:/ then ( 
 #             puts line
              if /Sending vm data for \[(\w*)\] to server.  Size:\[(\d*)\]  TaskId:\[(.*)\]  VM:(.*)$/ =~ line then
#                puts "Command name is #{$1}"
#                puts  "length of data is  #{$2} bytes" 
#                puts "taskid is  #{$3}  and source of data is #{$4} VM"
                end
              )              
#        break        
        end
      end
    #~ end
  #~ end
  #~ end
  
         if $generatedb then
#          result = db_log_file.update_attributes({:host_ip_address  => host_ip_address})
#         puts result.inspect
          result = db_log_file.update_attributes({:host_ip_address => host_ip_address,
            :host_memory_value => host_memory,
            :host_available_memory_value => available_memory,
            :host_os => host_OS_value,
            :host_os_version => host_OS_version_value,
            :host_id => agent_registered_id,
            :start_date_time => log_file_start_time,
            :sh_log_file_size => File.size(file_name),
            :end_date_time => File.mtime(file_name),
            :evm_server_build => server_build_level,
            :evm_server_appliance => appliance_identifier,
            :completed_commands_count => completed_commands_count,
            :log_terminate_reason => $log_terminate_reason,
            :pending_commands_count => pending_cmds.size
          })
          puts "Result of update to db_log_file at end of log processing is: #{result} "
          end
          puts "completed commands count is: #{completed_commands_count}\nidentified errors count is #{errors_identified}"
          if pending_cmds.size > 0 then
          puts "****\n****\nNumber of pending commands at log file end is #{pending_cmds.size}\n****\n****\n"
           # this code should create a new file with the info about pending commands
            pending_cmds_file = File.new(input_file_basename + "-pending_cmds.csv", "w+")
            pending_cmds_file.puts "Unique key, process id, thread id, cmd name, cmd parms, cmd duration, cmd completion , cmd start date, cmd start time, cmd start microseconds, cmd stop date, cmd stop time, cmd stop microseconds,agent name,agent version,host OS,host name,host ip address,host os version,appliance ip address,log msg id,log msg type,log msg type text,HOST ID,VM CMD Target,Host Memory,Available memory"
            pending_cmds.each do |x| 
              # inject each command as a csv-type line into pending_cmds.csv
                         _y_m_d = x[LOG_START_DATE].tr("/",",").split(",")
                         _h_m_s = x[LOG_START_TIME].tr(":",",").split(",")

                        _gm_time_start = Time.gm(_y_m_d[0].to_i,_y_m_d[1].to_i,_y_m_d[2].to_i,_h_m_s[0].to_i,_h_m_s[1].to_i,_h_m_s[2].to_i,
                        x[LOG_START_MICRO_SECONDS].to_i)
                        
                          #CALCULATE STOP DATE TIME using last good log line as end-time
                         _y_m_d = normalized_cmd_start[LOG_START_DATE].tr("/",",").split(",")
                         _h_m_s = normalized_cmd_start[LOG_START_TIME].tr(":",",").split(",")

                       _gm_time_end = Time.gm(_y_m_d[0].to_i,_y_m_d[1].to_i,_y_m_d[2].to_i,_h_m_s[0].to_i,_h_m_s[1].to_i,_h_m_s[2].to_i,
                        normalized_cmd_start[LOG_START_MICRO_SECONDS].to_i)
              
                        x[CMD_DURATION] = _gm_time_end - _gm_time_start    
                        x[LOG_STOP_DATE] = normalized_cmd_start[LOG_START_DATE]
                        x[LOG_STOP_TIME] = normalized_cmd_start[LOG_START_TIME]
                        x[LOG_STOP_MICRO_SECONDS] = normalized_cmd_start[LOG_START_MICRO_SECONDS]
                          
              pending_cmds_file.puts(x.join(",")) 
            end    
#            pp pending_cmds
          end
          
#      prefix_file.close
#      immediate_cmds.close
#      completed_cmds.close
end  
puts "total files passed in for processing = #{parm_count}"
puts " new records created = #{$records_created} "
puts " invalid names not processed = #{$invalid_log_name_format}"
puts " previously processed file count = #{$previously_processed_file}"
puts "cross check\n total in      total processed\n   #{parm_count}               #{$records_created + $invalid_log_name_format + $previously_processed_file}"
exit


#end