puts "Ruby version is '#{RUBY_VERSION}'\n\tRuby release date is '#{RUBY_RELEASE_DATE}'\n\tRuby Platform is '#{RUBY_PLATFORM}'"
$:.push("#{File.dirname(__FILE__)}")  # force the directory with initial code to be on the search path
$:.push("C:\\evmserver_log_analyzer\\app\\models\\")  # location where all of the models are stored
# 
# this module is the main component of the ruby code to process EVM Server logs into a SQL DB 
# for later analysis.  At the initial creation of this module the EVM Server log is being split into 
# two separate logs, one for the Rails application and one for EVM Server application logging
# This module is likely to evolve rapidly as fequtre requests for changes to the logs are entered into 
# Fogbugz to make it easier to correlate information from the logs into real-world operation
# experience.
# April 2008 - Tom Hennessy
# 
=begin rdoc
$Id: main.rb 17490 2009-12-02 20:38:41Z thennessy $

=end
# SVN Doc Info
$SVN_rev = "$Revision$ "
$SVN_author = "$Author$ "
$SVN_changed = "$Date: 2009-12-02 15:38:41 -0500 (Wed, 02 Dec 2009) $"
$SVN_id = "$Id: main.rb 17490 2009-12-02 20:38:41Z thennessy $"
puts "SVN EVM Server log to db module info\n\t#{$SVN_id}"
#=============
$:.push("#{File.dirname(__FILE__)}")  # force the directory with initial code to be on the search path

$create_modified = nil   # to create modified output files (modified_evm, modified_production) set to true

$special_debug = nil   # when true, suppresses file name check for evm.log & production.log
                        # to allow debug processing on small selected log files
$generatedb = nil
$create_pid_files = true

       #if  you want to have this generate a db with related tables then set the $generatedb to "true"
require 'profiler'          #this includes a profiler with output to stdout. comment when not using
require "rubygems"
require "stringio"          # required for advanced log processing for certain errors
#      require "pp"
#      require 'rubygems'
    if $generatedb then
      $:.push("C:\\evmserver_to_db\\app\\models\\")  # location where all of the models are stored
      require "activerecord"

       

# =============================================      
      ActiveRecord::Base.establish_connection( 
        :adapter => "mysql", 
        :host => "localhost", 
        :username => "root",
        :password => "root",
        :database => "evmserver_log_analyzer_development")
#=============
      require "evmserver_to_db_models.rb"
      end
require "English"
#require "zliby"                              # compression routines for pid file output
#                                            # and reading gz'ed log files

require "fileutils"
# needed to refer to global regex variables as english-like var names
require "MIQ_cmd_handler"
require "msg_data_finalize"
require "rubygems"
require "date"
require "Parsedate"
require "prettyprint"
require "pp"
require "for_excel"
require "job_payload_class"
require "no_summary_instances"
require "examine_log_line"
require "examine_payload"
require "log_line_summarize"
require "not_normal"
require "fatal_messages"
require "process_single_line"
require "process_multiline_group"
require "process_line_group"
require "process_input_line"
require "Job_step_define_and_capture"
require "capture_soap_data"
require "log_line_of_interest"
require "capture_ems_performance_interval_metrics"
require "capture_ems_performance_realtime_metrics"
require "dump_and_clear_performance_metrics"
require "capture_evm_startup_config"
require "application_global_regex_strings"
require "process_miqworker_status_update"
require "process_miqserver_status_update"
require "process_vc-refresher_log_lines"
require "ems_event"
require "initialize_evm_startups_config"
require "parse_proxy_call_ws_parms"
require "archive_active_process"
require "capture_miqserver_heartbeat_duration"
require "dump_and_clear_miqserver_heartbeats"
require "capture_vcrefresher_refresh_timings"
require "dump_and_clear_vcrefresher_timings"
require "capture_db_statistics"
require "miq_cmds_summary"

   
parm_count = 0 # set default count of passed in paramaters
$Linux_era = 25569 # this is the Excel day count for Jan 1, 1970
$gross_logfile_line_cnt = 0
$logfile_line_group_cnt = 0
$processed_single_line_groups = 0
$processed_multi_line_groups = 0
$processing_lines = 0
$debug_line_count = 0
$job_step_togle = nil
_xml_restart_key = nil                 #try to control processing of xml log records

$Caught_event = Array.new              # Array of hashes to capture all recognized events

$heartbeats = Hash.new                 # capture heartbeat info
$active_processes = Hash.new           #when a new pid is recognized create a new entry
                                       #key is PID
$miqserver_heartbeats_array = Array.new # establish array for miqserver heartbeats to be saved
$vcrefresher_refresh_array = Array.new  # establish array for vc_refresh timings
$current_miqserver_heartbeat = MiqServer_Heartbeat.new
$all_process_archive = Array.new        # intended to contain all pids, active and inactive
                                       #originally was has with key = GUID but changted to array
                                       #since each of the evmstartups use the appliance guid
                                       # and I was loosing all but the last startup process
$guid_process_xref = Hash.new          #cross reference guid as key to process id to access $active_processes
$Parsed_log_line = Hash.new
$Saved_parsed_log_line = Hash.new
$delay_limit = 180                     # set initial max inter-log line time interval
$pid_cycle = 0                         # used to count the number of times PID recycle to keep pid txt files unique
$last_pid = 0                          # used to track last found new process PID.
                                       # if new PID is less than current "last_pid" then increment $pid_cycle
                                       # and make $last_pid = new pid value
$startup_cnt = nil

$active_job_cnt = 0                     # count of active (not queued) jobs at any given time
$rails_transaction_cnt = 0
$miqserver_termination_msg = nil        # define as nil before it is referenced

  #$startup_cnt is used in msg data csv, jobs csv, job steps csv,
  # in the error summary report and elsewhere
$Log_build_id = nil
$Server_GUID = "uninitialized"                      # appliance uuid
$Server_zone = "uninitialized"                      # from most current startup
$Server_role = "uninitialized"                      # from most current startup
$Server_miq_server_id = "uninitialized"             # from most current startup
#
$License_scan_active = nil             # internal flag to indicate scanning for license info in log is active
#
#$modified_log = File.new("modified_production.log","w")
#$Error_log = File.new("Errors_production.log","w")
#$Fatal_log = File.new("Fatal_production.log","w")
# summary information about Warning and Error messages in log
$Error_summary = Hash.new
$Primary_cmd = Array.new
$Job_cmds = Hash.new
$Miq_cmds = Hash.new
$Jobs = Hash.new
$Startups = Hash.new

 initialize_evm_startups_config()

$VMDB_scan_active = nil
$DATABASE_scan_active = nil
$Rails_transaction = Hash.new
$Rails_environment = Hash.new
$pid_dir = 'pid_files'
$diag_dir = 'diagnostic_data'
$SOAP_active = nil

$job_uuid= Regexp.new("[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}")
$Q_task_id_with_jobuuid = Regexp.new("Q\\-task_id\\(\\[[a-f0-9]{8}\\-[a-f0-9]{4}\\-[a-f0-9]{4}\\-[a-f0-9]{4}\\-[a-f0-9]{12}\\]\\)")
puts "#{$job_uuid.inspect}"
puts "#{$Q_task_id_with_jobuuid}"
# 8-4-4-4-12

#$Error_summary_file = File.new("Error_Summary.txt","w")


  # below is a compiled regular expression that is intended to contain the template
  # format for defined log line message beginnings.  Any other string will be treated as
  # a continuation of a previously started line and will be added into a line group for line
  # group processing
#$MSG_ID = /^\[\-\-\-\-\]\s+[EIDFW]\,\s+\[\d4\-\d2\-\d2T\d2\:\d2\:\d2\.\d6\s+\#\d*?\]\s+\S*\s+\-\-\s\:/
$MSG_ID = /^\[----\]\s+\w\,\s+\[.{26}\s\#\d{1,5}\]\s+\S*\s+/

parm_count = ARGV.size     
if parm_count == 0 || parm_count == nil then
  puts "no input file found"
  exit
end
puts "#{ARGV.inspect}"
puts "Offered file count is #{parm_count}"
ARGV.each {|_file_instance|
    puts "file name :'#{_file_instance}'"
}
input_file = ARGV
$_line_group = Array.new
read_loop_start = Time.new
#consider a loop here to process multiple input files
ARGV.each do |arg_file_in|
    base_file_name = File.basename(arg_file_in,".log")
    $base_file_name = base_file_name                    # make it a global variable name for use in pid file output name creation
   if $base_file_name == "production" then
     puts "#{__FILE__}:#{__LINE__}=>"
   end
#    case $special_debug

      if $special_debug then    # if special_debug = true then process any input
                                # otherwise only process evm.log and production.log
      else
        if /^evm$|^production$/!~ base_file_name || base_file_name == "" || base_file_name == nil then
          # this is not an expected file, so iterate to the next one
          puts " unexpected input file name '#{arg_file_in}' is being skipped"
          next
        end
      end
#    _d1 = Dir.mkdir($pid_dir)
#    _d2 = Dir.mkdir($diag_dir)
      if !File.exist?($pid_dir)  then           #if no directory then make one
        _d1 = Dir.mkdir($pid_dir)
        puts "directory #{$pid_dir} created"
      end
      if !File.exist?($diag_dir)  then          #if no directory then make one
        _d2 =  Dir.mkdir($diag_dir)
        puts "directory #{$diag_dir} created"
      end
    # if input file meets minimum acceptability criteria, then process it
    # and adjust the output file names to reflect the input source
    $modified_log = File.new($diag_dir + '\\' +"modified_" + base_file_name + ".log","w")
    $log_lines_of_interest = File.new($diag_dir + '\\' +"log_lines_of_interest_" + base_file_name + ".log","w")
    $Error_log = File.new($diag_dir + '\\' +"Errors_" + base_file_name + ".txt", "w")
    $Fatal_log = File.new($diag_dir + '\\' +"Fatal_" + base_file_name + ".txt","w")
    $Error_summary_file = File.new($diag_dir + '\\' + base_file_name + "_Error_Summary.txt","w")
    $Jobsteps_csv = File.new($diag_dir + '\\' +"Job_steps_" + base_file_name + ".csv","w")
    $Jobsteps_csv.puts "server guid,server hostname,build,jobid,job process type,time of day,log msg type,log pid,userid,job action,action message,jobstep type"
    if base_file_name == "evm" then                 # only open output file if processing evm.log file
    $Process_statistics_csv = File.new($diag_dir + '\\' +"Process_statistics.csv","w")
    $Process_statistics_csv.puts "server guid,server hostname," + 
      "startup,log time,category,subcategory,ip address,worker type,worker pid," +
      "memory usage,memory size,memory pct,CPU time,CPU pct,Priority"
    $performance_metrics_interval_file = File.new($diag_dir + '\\' +'performance_interval.csv',"w")
    $performance_metrics_interval_file.puts  "server_guid,hostname," +
                  "log_datetime,build_vm_queries,db_processing," +
                  "interval,map_mors_to_intervals,map_mors_to_vmdb.objs," +
                  "miq_cmd,num_vim_queries,num_vim_trips," +
                  "target_class,target_element_name,target_element_id,taskid," +
                  "total_time,vim_connect,vim_execute_time,perf processing"
    $performance_metrics_realtime_file = File.new($diag_dir + '\\' +'performance_realtime.csv',"w")
    $performance_metrics_realtime_file.puts  "server_guid,hostname," +
                  "log_datetime,build_vm_queries,db_processing," +
                  "interval,map_mors_to_intervals,map_mors_to_vmdb.objs," +
                  "miq_cmd,num_vim_queries,num_vim_trips," +
                  "target_class,target_element_name,target_element_id,taskid," +
                  "total_time,vim_connect,vim_execute_time,running_vm_count,perf processing"

    $Events_csv = File.new($diag_dir + "\\" + base_file_name + "_events.csv","w")
    $Events_csv.puts "server host, server guid, startup,log datetime,event type, event processing,ems ip address,ems userid,event chainid"

    $miqserver_heartbeats_file = File.new($diag_dir + '\\' +'miqserver_heartbeats.csv',"w")
    $miqserver_heartbeats_file.puts  "server guid,host name,appliance name," +
                  "log_datetime,heartbeat duration"

       $vcrefresher_timings_file
    $vcrefresher_timings_file = File.new($diag_dir + '\\' +'vcrefresher_timings.csv',"w")
    $vcrefresher_timings_file.puts  "server guid,host name,appliance name," +
                  "log_datetime,ems name,target class,target name,target id,refresh duraton"

    end
    puts "Processing EVM log file '#{arg_file_in}'"

    input_file = File.new(arg_file_in,"r")

  # process entire log file
  # * * * * * * * * * * * * * * * * * * *
  #                                     *
  #    major read loop begins here      *
  #                                     *
  # * * * * * * * * * * * * * * * * * * *
    while linein = input_file.gets
      $job_step_togle = nil                                               # reset togle to indicate jobstep not create for this log line
      
#  if /Unable to find uuid. Skipping Vm./ =~ linein then
#    puts "#{__FILE__}:#{__LINE__}=>#{linein}"
#  end

#    if /Stopping Worker/ =~ linein then
#    puts "#{__FILE__}:#{__LINE__}->#{linein}"
#    end

#      if /2008-08-18T23:01:04.848046 #6081/ =~ linein then
#        _trace = 1
#      end
      $gross_logfile_line_cnt += 1
## ---------------------- BEGIN SPECIAL DIAGNOSTIC BLOCK ---------------------------
#      linein_array = linein.split                          #lets see if 1st word is xml
#      if linein_array.size == 0 then next end
#      if _xml_restart_key then
##          when false
#
##          when true
#            puts "'#{_xml_restart_key.inspect}'<=>'#{linein_array[0].tr("<>","  ").strip}'"
#                if _xml_restart_key == linein_array[0].tr("<>","  ").strip then      # now examine if this is the end of this xml_key block
#                  _xml_restart_key = nil                         # reset lock to allow processing
#                  next                                           # but skip this last line
#                end
#      else
#            if /\s*\<(.*)/ =~ linein_array[0] && !_xml_restart_key then               # if it is, then examine second character
#              _xml_key = $1.tr("<>","  ").strip                                      # but same word as we may need it
#              if _xml_key[0,1] != "/" then                       # if first char of key is "/" then this ends the block
#                _xml_restart_key = "/" + _xml_key                # if not, then we have our new xml end-key
#                next                                             # so lets skip all processing and get next log line
#
#              end
#            end
#
#        end
#      _temp_ = linein[0,44]
#      puts "#{$gross_logfile_line_cnt}=>#{_temp_}"
## ---------------------------- END OF SPECIAL DIAGNOSTIC BLOCK ---------------------------
#      if $gross_logfile_line_cnt == 128862 then
#        puts "#{__FILE__}:#{__LINE__}"
#      end
    #  if /ERROR --/ =~ linein then
    #    puts "#{linein}"
    #  end
        if /Processing/ =~ linein then
          $processing_lines += 1
        end

        if $gross_logfile_line_cnt.modulo(10000) == 0 then
    # every 10k emit a progress line into the output file    
        _x = Time.new - read_loop_start
          if $Saved_parsed_log_line.class.to_s == "Parsed_log_line" then
          puts " 10k lines processed in #{_x} seconds - last log line time is #{$Saved_parsed_log_line.log_raw_datetime}"
          else
                    puts " 10k lines processed in #{_x} seconds "
          end
        read_loop_start = Time.now
        end  
      #if the line is blank then skip it
      next if linein.size < 2 || linein.size > (4096 * 10)
#      if /proxy-call_ws\)\: Calling/ =~ linein then
#        puts " #{__FILE__}:#{__LINE__}->#{linein}"
#      end
      if linein.size > (4096 * 10) then
        # if the line exceeds 1k then truncate it and process what remains
        linein = linein[0,1024]
#        puts "line limit exceeded=>#{linein}"
        next
      end
      if $_line_group.empty? || $_line_group.size == 0 then
        # if the line group is empty and the input line begins with the "[---}" marker
        # then begin a new linegroup, otherwise skip the line as "unknown"
        case linein
          when $MSG_ID  then $_line_group << linein
                            $logfile_line_group_cnt += 1
                            next
    #      else puts "line with value #{linein} \n encountered in unexpected context, skipping"
    #          next
         end
        end
        if $_line_group.size > 0 && $MSG_ID =~ linein then 
          # Lets see if this line is an error line with the same pid value as the first
          # line in this group.  If it is then this MAY BE a continutation of the first error
          # and we should just append it to the error group
#  if /2009\-09\-11T09\:23\:05\.353446/ =~ $_line_group[0] then
#    puts "#{__FILE__}:#{__LINE__}=>#{$_line_group[0]}"
#  end
          if /ERROR/ =~ $_line_group[0].split[4] &&       # if this msg type same as first line of group
#              $_line_group[0].split[7] != linein.split[7] &&
              $_line_group[0].split[4] == linein.split[4] &&  #additional condition added to isolate multiple errors from the same command
              $_line_group[0].split[3] == linein.split[3] &&
              linein.split[2].split(":")[-1].to_f - $_line_group[0].split[2].split(":")[-1].to_f < 1 
            then
            $_line_group << linein                
            # add current line to array
            $logfile_line_group_cnt += 1
            # and increment line group line count
            next
            # and exit this code loop
          else
            # if this is a good log line but I already have started a line group
            # then process that line group, allow the group to be emptied
            # and restart a new line group

#            if /\#357\]/ =~ $_line_group[0] then
#              puts "#{__FILE__}:#{__LINE__}-> #{$_line_group[0]}"
#            end

            process_line_group($_line_group) 
            $_line_group.clear                # empty the array
            $_line_group << linein if linein.size > 1
            # if line length = 1 then only the line feed is here and we should ignore blank lines
            $logfile_line_group_cnt += 1   
            next
          end
            

          # 
          # 
          # if this is a good log line but I already have started a line group
          # then process that line group, allow the group to be emptied
          # and restart a new line group
#          process_line_group($_line_group) 
#          $_line_group << linein if linein.size > 1
          # if line length = 1 then only the line feed is here and we should ignore blank lines
#          $logfile_line_group_cnt += 1
        elsif  $_line_group.empty? || $_line_group.size == 0 then 
          puts "#{File.basename(__FILE__)}:#{__LINE__}=>unexpected line context for '#{linein}'"
          next
        else      
          # this is a non-log line that should be appended into the log group being accumulated
          $_line_group << linein if linein.size > 1
          # if line length = 1 then only the line feed is here and we should ignore blank lines      
        end
         $Saved_parsed_log_line = $Parsed_log_line

#        end

  # end process entire log file
  # * * * * * * * * * * * * * * * * * * *
  #                                     *
  #    major read loop ends here        *
  #                                     *
  # * * * * * * * * * * * * * * * * * * *
      end
    # end of input file has occured so we must flush the last line group for processing
    process_line_group($_line_group) if $_line_group.size > 0

   puts "total number of lines in #{arg_file_in} is #{$gross_logfile_line_cnt}" 
   puts "total number of lines within groups is #{$logfile_line_group_cnt}"
   puts " processed multi-line groups count is #{$processed_multi_line_groups}"
   puts " processed single-line groups count is #{$processed_single_line_groups}"
   puts " Count of debug and associated lines is #{$debug_line_count}"
   puts " Count of evm server startups is #{$Startups.size}"
  # $Error_summary_file <<$Error_summary
  $Error_summary_file.puts("Log Error Summary:\n\t for final log entries\n\t Appliance Build is '#{$Log_build_id}'\n\t generated by EVMServer-log-to db at revision level #{$SVN_id}")
#  sorted_startups = $Startups.sort {|a,b| a[1] <=> b[1]}
  $Startups.size.times do |i|
      _value = $Startups[i]
      if _value["log_time"] != nil  && _value["log_time"] != "" then
      $Error_summary_file.puts(" startup: #{i}\t=> UTC(#{Time.at(_value["log_time"]).gmtime.strftime("%Y-%m-%dT%H:%M:%S")})\t local time(#{_value["display_time"]})\t evm version(#{_value["evm version"]}) build(#{_value["build"]})")      
      $Error_summary_file.puts("\t\tRAILS Environment=>#{_value["rails environment"]}\t Rails version=>#{_value["rails version"]}")
      $Error_summary_file.puts("\t\tcompany=>#{_value["company"]}\tzone=>#{_value["zone"]}\trole=>#{_value["role"]}")
      $Error_summary_file.puts("\t\tServer GUID =>#{$Server_GUID},\n\t\thost=>#{_value["host"]}\thostname=>#{_value["hostname"]}\tappliance name =>#{_value["appliance name"]}")
      $Error_summary_file.puts("\t\tDATABASE INFO\tdatabase host => #{_value["database host"]}\tusername=>#{_value["db username"]}\tdatabase=>#{_value["db database"]}")
      $Error_summary_file.puts("\t\t\tdb mode=>#{_value["db mode"]}\tdb adapter=>#{_value["db adapter"]}\tdsn=>#{_value["db dsn"]}")
      $Error_summary_file.puts("\t\t\tmax connections=>#{_value["db max_connections"]}")
      else
        $Error_summary_file.puts(" No startup info available for this sequence of log errors\n\n") # if no startup info available, say so
      end

#                             "db username" => nil, "db mode" => nil,
#                            "db adapter" => nil, "db database" => nil, "db dsn" => nil,
#                            "db max_connections" => nil,      
      end
#  sorted_startups.each do |key, value|
#
#  end
  if $Startups.size > 1 then
    loop_cnt = 0
    $Startups.size.times {
          loop_cnt += 1
          if loop_cnt == 1 then
                  startups_file = File.new($diag_dir + '\\' +"startups_#{base_file_name}\.csv","w")
                  startups_file.puts "server guid,host name,host ip address,appliance name,startup time,display time,status,db dsn,db database,company,zone,rails environment,rails version," +
                                     "db username,evm version,evm build,role,db host,db max_connections,db adapter,startup time in seconds"
      #            next   # the first entry has nothing of interest, skip to next one
          end
          if startups_file then              # if the file is open, then write to it
                startups_file.puts "#{$Startups[loop_cnt]["server_guid"]},#{$Startups[loop_cnt]["hostname"]},#{$Startups[loop_cnt]["host"]},#{$Startups[loop_cnt]["appliance name"]}" +
                                   ",#{$Startups[loop_cnt]["log_datetime_string"]},#{$Startups[loop_cnt]["display_time"]},#{$Startups[loop_cnt]["status"]},#{$Startups[loop_cnt]["db dsn"]}" +
                                   ",#{$Startups[loop_cnt]["db database"]},\"#{$Startups[loop_cnt]["company"]}\",\"#{$Startups[loop_cnt]["zone"]}\",#{$Startups[loop_cnt]["rails environment"]}" +
                                   ",#{$Startups[loop_cnt]["rails version"]},#{$Startups[loop_cnt]["db username"]},#{$Startups[loop_cnt]["evm version"]},#{$Startups[loop_cnt]["build"]}" +
                                   ",\"#{$Startups[loop_cnt]["role"]}\",#{$Startups[loop_cnt]["database host"]},#{$Startups[loop_cnt]["db mqax_connections"]},#{$Startups[loop_cnt]["db adapter"]}" +
                                   ",#{$Startups[loop_cnt]["log_time"]}"
               if loop_cnt == $Startups.size - 1  then            # close the file when all elements are processed
                 startups_file.close
                 startups_file = nil                              # make sure the file reference is nil
               end
           end
     }
  end
  $Log_build_id = 'Build Info Not Found' if $Log_build_id == nil
  if $Error_summary.size == 0 || $Error_summary.empty? then
    $Error_summary_file.puts("\n No Errors reported")
  else
    $Startups.size.times do |_startup|

      _startup_string = _startup +1
#    end
    $Error_summary_file.puts("\f Sorted in descending instance count order for #{arg_file_in}\n\t for Startup number \##{_startup_string}")

  # from a readability perspective I will generate a summary dataset with the most frequent error printed first
  # and the least frequent last.  Error, Fatal and Warning messages will be intermixed.  INFO messages are omitted.
  # following sort taken from Ruby Language, sorting from low count to high count
    sorted_hash = $Error_summary.sort {|a,b| a[1] <=> b[1]}
    _process_types = ["FATAL:","ERROR:","WARN:","INFO:"]
    _print_cnt = 0
    _process_types.each {|_type|
      $Error_summary_file.puts("\n#{_type}-type log messages\n\n Count \t severity   (Build id).startup \tmessage text")
        _print_cnt = 0
    for i in 1..sorted_hash.size
      _work_string = sorted_hash[sorted_hash.size - i][0]
      # if this isn't the type being processed, then skip it
         if _work_string.index(_type) == nil || _work_string.index(_type)> 0 then
           no_summary_instances(_type, i, sorted_hash.size, _print_cnt) if i == sorted_hash.size && _print_cnt == 0
         next      
         end

  #    end

      # skip the appliance starting log line if present        
      if /\[VMDB\] started on/ =~ _work_string then
         no_summary_instances(_type, i, sorted_hash.size, _print_cnt) if i == sorted_hash.size && _print_cnt == 0      
        next 
      end
      case _work_string.split[1].split(").")[-1].to_i
      when _startup_string
#      end
  #    next if /^INFO:/ =~ sorted_hash[sorted_hash.size - i][0]
      $Error_summary_file.puts "   #{sorted_hash[sorted_hash.size - i][1]}\t    #{sorted_hash[sorted_hash.size - i][0]}"
      _print_cnt += 1
      if i == sorted_hash.size then
        # if this is the last loop thru this "each" iteration
        # and no lines were printed for this _type, then print this
        $Error_summary_file.puts " No messages of type #{_type} to report" if _print_cnt == 0      
      end
      end
    end
    }
    end
  end
    #clean out the structures to be reused
    $Error_summary.clear
    $Error_summary_file.close
    if !$Job_cmds.empty? && FALSE then
      #  if Job Cmds hash has values  then print summary
      puts "\n\nJob Command summary follows for #{$Job_cmds.size} entries\n\t"  

        $Job_cmds_csv = File.new($diag_dir + '\\' + "Jobs_CSV_" + base_file_name + ".csv","w")
        $Job_cmds_csv.puts("EVM Startup,Job ID,Job Create num, Job abend num, Job complete num," + 
                           "Job Process Type," + 
                            "Job Cmd,Job Description,Lines,Create Time," + 
                            "Ready Time,Started Time,Finished Time,DeQueue Time,Last Heard from," +
                            "Job Duration,CMD Duration,Waiting to Start Delay," + 
                            "Jobs active at CMD Start,Jobs Active at CMD End," +
                            "Deleted Time,Error Time,Error Msg")

      $Job_cmds.each do 
            |x,y| puts "\n\nJob id is #{x}" + 
                       "\n\tJob created count is #{y["created_job_count"]}" + 
                       "\n\tAbended job count is #{y["abended_job_count"]}" +
                       "\n\tCompleted job count is #{y["completed_job_count"]}" +
                       "\n\tJob Process Type is '#{y["job_process_type"]}" +
                        "\n\tJob Description is '#{y["job_description"]}'" +
                        "\n\tJob_cmd_name is #{y["job_cmd"]}" +
                        "\n\tcount is #{y["count"]}" +
                        "\n\tmodifier count is #{y.size}" +
                        "\n\tactive at start count is #{y["active_at_start"]}" +
                        "\n\tactive at end count is #{y["active_at_end"]}" +
                        "\n\tjob_vm_name is #{y["job_vm_name"]}"
                      
if /job start/ =~ y["job_cmd"]     then
  puts "#{__FILE__}:#{__LINE__}"
end
      
              y.each {|k,v|
                  if k == "job_cmd" || k == "count" || k == "err_msg" || 
                     k == "job_description" || k=="job_process_type"  ||
                     k == "completed_job_count" || k == "abended_job_count" ||
                     k == "active_at_start" || k == "active_at_end" ||
                     k == "created_job_count" || k == "job_vm_name" then
                    # the key values above are already exposed in the first print statement
                    # so skip them from the print loop perspective....
                    # 
          #             if v == nil || v == "" then puts "\t Value of #{k} is empty"
          #            else puts "\t #{k} time is #{v}"
          #            end         
                  else
  puts "#{__FILE__}:#{__LINE__}" if k == "sync_start" && /job start/ =~ y["job_cmd"]
                      if v == nil || v == "" || v == "?" then puts "\t Value of #{k} is empty"
                      else 
#                        puts "\t v = #{v}"
#                        puts "\t k = #{k}"
                        puts "\t #{k} time is #{Time.at(v)}" if v > 0 
                      end
                  end
              }
      #        " \n\t created time => #{Time.at(y["created"])}" +
      #     " \n\t ready time=> #{Time.at(y["ready"])} " +
      #     " \n\t started time => #{Time.at(y["started"])}" +
      #     " \n\t finished time => #{Time.at(y["finished"])} " 
      #   
           puts " \n\t dequeued time => #{Time.at(y["job_dequeued"])} " if y["job_dequeued"] != nil
#               y["ready"] = y["create"]  if y["ready"] == nil 
#               y["started"] = y["create"] if y["started"] == nil
               if y["finished"] != nil && y["ready"] != nil && y["started"] != nil &&y["create"] != nil then
               puts "\tcreated-to-ready delay = #{y["ready"] - y["create"]} \n\tstart-to-ready delay = #{y["started"] - y["ready"]}" +
                 "\n\t start-to-finish duration = #{y["finished"] - y["started"]}\n\t total ready-to-finished time is #{y["finished"]-y["ready"]}" +
                 "\n\t Created-to-finished time is #{y["finished"] - y["create"]}\n\n"
               end
#          if y["finished"] == nil || y["started"] == nil || y["ready"] ==nil then
#            _total_job_duration = "unknown"
#            _pre_start_queue_time = "undefined"
#            _cmd_duration = "undefined"
#          else
#           _total_job_duration =  y["finished"] - y["create"]
#           _cmd_duration = y["finished"] - y["ready"]
#           _pre_start_queue_time = y["ready"] - y["create"]
#          end
          if y["finished"] == nil || y["started"] == nil then
            _cmd_duration = "undefined"
          else _cmd_duration = y["finished"] - y["started"]
          end
          if y["finished"] == nil || y["create"] == nil then
            _total_job_duration = "unknown"
          else
           _total_job_duration =  y["finished"] - y["create"]
          end
          if y["create"] == nil || y["started"] == nil then
            _pre_start_queue_time  = "undefined"
          else
           _pre_start_queue_time = y["started"] - y["create"]
          end
        if y["started"] == nil && y["ready"] == nil && y["finished"] == nil && y["create"] == nil && y["err_msg"] == nil then
          y["err_msg"] = "Only job delete processed here"
        end
        if y["startup_cnt"] == nil || y["startup_cnt"] == "" then
          y["startup_cnt"] = "?"
        end
          $Job_cmds_csv.puts("#{y['startup_cnt']},#{x},#{y["created_job_count"]},#{y["abended_job_count"]},#{y["completed_job_count"]}," +
            "#{y["job_process_type"]},#{y["job_cmd"]},#{y["job_description"]},#{y["count"]},#{for_excel(y["create"])}," +
            "#{for_excel(y["ready"])}," +
            "#{for_excel(y["started"])}," +
            "#{for_excel(y["finished"])}," +
            "#{for_excel(y["job_dequeued"])}," +
            "#{for_excel(y["last heard from"])}," +
            "#{_total_job_duration}," +
            "#{_cmd_duration}," +
            "#{_pre_start_queue_time}," + 
            "#{y["active_at_start"]}," +
            "#{y["active_at_end"]}," +
            "#{for_excel(y["deleted"])},"  +          
            "#{for_excel(y["error"])}," +
            "#{y["err_msg"]}," 
                                )         
      end
      puts "\n\n Job command summary completed \n\n"
      $Job_cmds_csv.close
    end

  if $Performance_metrics != nil && $Performance_metrics.size != 0 then
    dump_and_clear_performance_metrics()
  end

  if $miqserver_heartbeats_array != nil && $miqserver_heartbeats_array.size != 0 then
    dump_and_clear_miqserver_heartbeats()
  end
  
  if $vcrefresher_refresh_array != nil && $vcrefresher_refresh_array.size != 0 then
    dump_and_clear_vcrefresher_timings()
  end




      if $Miq_cmds.empty? != nil then
        miq_cmds_summary($Miq_cmds,$base_file_name)
#      end
      # if Job Cmds hash has values  then print summary
      puts "\n\nMIQ  Command summary follows for #{$Miq_cmds.size} entries:"
      _miq_cmds_array = $Miq_cmds.keys.sort!
      _miq_cmds_array.each {|hash_key|
        puts "#{hash_key} count is #{$Miq_cmds[hash_key]}"
      }
#    $Miq_cmds.keys.sort.each {|x,y| puts "#{x} count is #{y}"}
      puts "\n\n MIQ command summary completed \n\n"
    end
    $Miq_cmds.clear
    $Job_cmds.clear
    # the routine below passes the base file name and the hash
    # to a moduel that will create a csv file and when finished
    # will populate a db with msg info
    msg_info_to_csv($base_file_name,$MiqQueue)
    $MiqQueue.clear

  #  _MiqQueue_count = $MiqQueue.size.to_i
  #  ii = 0
  #  while ii < $MiqQueue.size 
  #    ii += 1
  #    puts " Msg id =>#{ii} value is #{$MiqQueue[ii.to_s].inspect}"
  #  end

#  ===
        process_synopsis = File.new($diag_dir + '\\' + "process_synopsis_" + $base_file_name + ".csv","w")
        process_synopsis.puts("Server GUID,Server hostname,PID,STARTUP,GUID,total lines,lines after exit," +
                           "fatal count,error count,warning count,debug count," +
                         "worker type,role,zone,max memory,first seen,last seen,requested exit," +
                         "detected exit,killed,Duration,request exit reason")
# ===

$active_processes.each do |_process_array|
  _process = _process_array[1]
  if _process["worker type"] == nil then 
    _process["worker type"] = "EVM Server?"
  end
  _process["requested_exit_reason"] = "still running" if _process["requested_exit_reason"] == nil
                                                                          # identify processes still active when log was taken
  if  _process["last heard from seconds"] && _process["first seen seconds"] then   #if both fields are not null then do the math
    _duration = (_process["last heard from seconds"] - _process["first seen seconds"]).to_i
  else _duration = -1                                                               # if either is missing then set the duration as essentially unknown
  end
  _process["requested_exit_reason"].tr!(',"'," '")
  process_synopsis.puts "#{_process["server_guid"]},#{_process["server_hostname"]},#{_process["PID"].to_s},#{_process["startup count"]},#{_process["GUID"]},#{_process["lines"].to_s},#{_process["lines after exit"]}," +
       "#{_process["fatal_cnt"].to_s},#{_process["error_cnt"].to_s},#{_process["warn_cnt"].to_s},#{_process["debug_cnt"].to_s}," +
        "\"#{_process["worker type"]}\",\"#{_process["role"]}\",\"#{_process["zone"]}\"," +
        "#{_process["memory size"]},#{_process["first seen"]},#{_process["last heard from"]},#{_process["requested_exit"]},#{_process["detected_exit"]},#{_process["killed"]}," +
        "#{_duration},\"#{_process["requested_exit_reason"]}\""
  _file = _process["file_handle"]
#  _file.close if _process["file_status"] == "open"
  _file.close if _file                                    # if _file is non-nil then assume file is open and should be closed

end
$active_processes.clear                                   #empty the hash to prepare for next file

$all_process_archive.each do |_process_hash|
  _process = _process_hash
  if _process.class.to_s == "NilClass" then
    next
  else

  if _process["worker type"] == nil then
    _process["worker type"] = "EVM Server?"
  end
  _process["last heard from seconds"] = _process["first seen seconds"] if _process["last heard from seconds"] == nil
  # sometimes the "last heard from seconds" is empty, so just make it the same as "first seen seconds"
  
  process_synopsis.puts "#{_process["server_guid"]},#{_process["server_hostname"]},#{_process["PID"].to_s},#{_process["startup count"]},#{_process["GUID"]},#{_process["lines"].to_s},#{_process["lines after exit"]}," +
       "#{_process["fatal_cnt"].to_s},#{_process["error_cnt"].to_s},#{_process["warn_cnt"].to_s},#{_process["debug_cnt"].to_s}," +
        "\"#{_process["worker type"]}\",\"#{_process["role"]}\",\"#{_process["zone"]}\"," +
        "#{_process["memory size"]},#{_process["first seen"]},#{_process["last heard from"]},#{_process["requested_exit"]},#{_process["detected_exit"]},#{_process["killed"]}," +
        "#{(_process["last heard from seconds"]-_process["first seen seconds"]).to_i},#{_process["requested_exit_reason"]}"
  _file = _process["file_handle"]
#  _file.close if _process["file_status"] == "open"
#  _file.close if _file                                    # if _file is non-nil then assume file is open and should be closed
  end
end
$all_process_archive.clear                                   #empty the hash to prepare for next file
process_synopsis.close                                    # Close the file gracefully
process_synopsis = nil                                    # set handle to nil

  if $heartbeats then
    $heartbeats_csv = File.new($diag_dir + '\\' + $base_file_name + "_heartbeats.csv","w")
    $heartbeats_csv.puts "smartproxy name,smartproxy guid,smartproxy host id,log time,smartproxy time,exiting?,task active count," +
                         "EVM server guid,EVM server hostname,EVM appliance name,startup count"

#          $heartbeats[_smartproxy_guid] = {"hostname" => _hostname, "hostid" => _hostid, "instances" => Array.new}
#
#         _instances[$Parsed_log_line.log_datetime_string] = {"sp_time" =>_smartproxy_time, "exiting" => _exiting_smartproxy, 
#        "active_tasks"  => _active_remote_task          }    
#           $heartbeats[_smartproxy_guid]["instances"] << _instances
  $heartbeats.each do |smartproxy_guid, data|
        _sp_hostname = data["hostname"]
        _sp_hostid = data["hostid"]
        _sp_instance_array = data["instances"]
        puts "#{_sp_hostname} has #{_sp_instance_array.size} heartbeats"
        output_prefix = "#{_sp_hostname},#{smartproxy_guid},#{_sp_hostid},"
        _sp_instance_array.each do |instance_hash|
                     instance_hash.each do |log_time, instance_data|
                      output_suffix = "#{log_time.split(".")[0]},#{instance_data["sp_time"]},#{instance_data["exiting"]},#{instance_data["active_tasks"]}," +
                      "#{instance_data["EVM_appliance_guid"]},#{instance_data["EVM_appliance_hostname"]},#{instance_data["EVM appliance name"]},#{instance_data["startup"]}"
                    _heartbeat_row = output_prefix + output_suffix
                      $heartbeats_csv.puts "#{_heartbeat_row}"
#                      puts "#{_heartbeat_row}"
                                        end
                                end
                    end
       $heartbeats_csv.close
       $heartbeats.clear
  end

$SOAP_data.close if $SOAP_active
$SOAP_active = nil
$log_lines_of_interest.close if $log_lines_of_interest    #close it unless value is nil
$log_lines_of_interest = nil


if $Hosts.size > 0 then
  puts "hosts count is #{$Hosts.size}"
  $Hosts_csv = File.new($diag_dir + '\\' + $base_file_name + "_Hosts.csv","w")
  $Hosts_csv.puts "server name, server guid, startup,ems name, Action,host name, host id, external hostname,ip address,first seen, last seen"
  $Hosts.each do |key,data|
    $Hosts_csv.puts "#{data["servername"]},#{data["server_guid"]},#{data["startup"]}," +
            "#{data["emsname"]},#{data["action"]},#{data["hostname"]},#{data["hostid"]},#{data["externalhostname"]},#{data["hostipaddress"]}," + 
            "#{data["first_seen"].split(".")[0]},#{data["last_seen"].split(".")[0]}"
    end
  $Hosts.clear
  $Hosts_csv.close
else
  puts "hosts count is 0"
end


if $VMs.size > 0 then
  puts "VM inventory count is #{$VMs.size}"
  $VMs_csv = File.new($diag_dir + '\\' + $base_file_name + "_VMs.csv","w")
  $VMs_csv.puts "server name, server guid, startup,ems name, Action,VM name, VM id,host name,host id,VM location, VM datastore, VM uuid,first seen, last seen"
  $VMs.each do |key,data|
    data["emsname"] = "" if data["emsname"] == "_emsname"
    data["hostname"] = "" if data["hostname"] == "_hostname"
    data["vmid"] = "" if data["vmid"] == "_vmid"
    data["hostid"] = "" if data["hostid"] == "_hostid"
    data["vmid"] = "" if data["vmid"] == "_vmid"
    data["vmlocation"] = "" if data["vmlocation"] == "_vmlocation"
    data["vmdatastore"] = "" if data["vmdatastore"] == "_vmdatastore"
    data["vmuuid"] = "" if data["vmuuid"] == "_vmuuid"
    data["emsname"] = "" if data["emsname"] == "_emsname"
      $VMs_csv.puts "#{data["servername"]},#{data["server_guid"]},#{data["startup"]}," +
                    "#{data["emsname"]},#{data["action"]}," +
                    "#{data["vmname"]},#{data["vmid"]}," +
                    "#{data["hostname"]},#{data["hostid"]}," +
                    "#{data["vmlocation"]}," +
                    "#{data["vmdatastore"]},#{data["vmuuid"]},#{data["first_seen"].split(".")[0]},#{data["last_seen"].split(".")[0]}"

    end
  $VMs.clear
  $VMs_csv.close
   else   puts "VM inventory count is 0" 
end

if $Folders.size > 0 then
  puts "Folders count is #{$Folders.size}"
  $Folders_csv = File.new($diag_dir + '\\' + $base_file_name + "_Folderss.csv","w")
  $Folders_csv.puts "server name, server guid, startup,ems name, folder name, folder id,first seen,last seen"
  $Folders.each do |key,data|
    $Folders_csv.puts "#{data["servername"]},#{data["server_guid"]},#{data["startup"]}," +
                      "#{data["emsname"]},#{data["foldername"]},#{data["folderid"]},#{data["first_seen"].split(".")[0]},#{data["last_seen"].split(".")[0]}"

    end
  $Folders.clear
  $Folders_csv.close
  else 
    puts "Folders count is 0"
end
#$EMSs = Hash.new

if $ResourcePools.size > 0 then
  puts 
  $ResourcePools_csv = File.new($diag_dir + '\\' + $base_file_name + "_ResourcePools.csv","w")
  $ResourcePools_csv.puts "server name, server guid, startup,ems name, ResourcePool name, ResourcePool id,first seen, last seen"
  $ResourcePools.each do |key,data|
    $ResourcePools_csv.puts "#{data["servername"]},#{data["server_guid"]},#{data["startup"]}," +
                            "#{data["emsname"]},#{data["resourcepoolname"]},#{data["resourcepoolid"]},#{data["first_seen"].split(".")[0]},#{data["last_seen"].split(".")[0]}"

    end
  $ResourcePools.clear
  $ResourcePools_csv.close
  else 
    puts "RersourcePool element counts is 0"
end

if $Storages.size > 0 then

  $Storages_csv = File.new($diag_dir + '\\' + $base_file_name + "_Storages.csv","w")
  $Storages_csv.puts "server name, server guid, startup,ems name,Action,Storage name, Storage id, storage location,first seen, last seen"
  $Storages.each do |key,data|
    $Storages_csv.puts  "#{data["servername"]},#{data["server_guid"]},#{data["startup"]}," +
                        "#{data["emsname"]},#{data["action"]},#{data["storagename"]},#{data["storageid"]},#{data["storagelocation"]}," +
                        "#{data["first_seen"].split(".")[0]},#{data["last_seen"].split(".")[0]}"

    end
  $Storages.clear
  $Storages_csv.close
   else
     puts "Storage element count is 0"
end

if $DataCenters.size > 0 then
  puts "datacenter count is #{$DataCenters.size}"
end
if $Clusters.size > 0 then
  puts "cluster count is #{$Clusters.size}"
  $Clusters_csv = File.new($diag_dir + '\\' + $base_file_name + "_Clusters.csv","w")
  $Clusters_csv.puts "server name, server guid, startup,ems name, cluster name, cluster id,first seen, last seen"
  $Clusters.each do |key,data|
      $Clusters_csv.puts  "#{data["servername"]},#{data["server_guid"]},#{data["startup"]}," +
                          "#{data["emsname"]},#{data["clustername"]},#{data["clusterid"]},#{data["first_seen"].split(".")[0]},#{data["last_seen"].split(".")[0]}"

    end

  $Clusters.clear
  $Clusters_csv.close
    else
      puts "cluster count is 0"
end

#if   $Caught_event.size > 0 then                      # all captured events
#    $Events_csv = File.new($diag_dir + "\\" + base_file_name + "_events.csv","w")
#    $Events_csv.puts "server host, server guid, startup,log datetime,event type, event processing,ems ip address,ems userid,event chainid"

=begin rdoc
  @event_type = nil
    @event_chaingid = nil
    @event_process = nil
    @event_ems_ip_address = nil
    @event_ems_userid = nil
    @event_server_name = $Startups[$startup]["name"]
    @event_server_guid = $Startups[$startup]["server_GUID"]
    @event_server_startup = $startup
    @event_log_time = $Parsed_log_line.log_datetime_string
=end
#  $Caught_event.each do |element|
#    $Events_csv.puts "#{element.event_server_name},#{element.event_server_guid},#{element.event_server_startup},#{element.event_log_time}," +
#      "#{element.event_type},#{element.event_process},#{element.event_ems_ip_address},#{element.event_ems_userid},#{element.event_chainid},#{}"
##      puts "#{element.inspect}"
#  end

 $Caught_event.clear
 $Events_csv.close
#end
#end
end
