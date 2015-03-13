$:.push("#{File.dirname(__FILE__)}")  # force the directory with initial code to be on the search path
$:.push("C:\\dev\\miq\\tools\\qawatcher\\app\\models\\")  # location where all of the models are stored     
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

def increment_date(date_array)
#  puts "#{__FILE__}:#{__LINE__}->#{linein}"
#    _modulus= date_array[0]%4                           # simple check for non-century leap year
#    if _modulus == 0 then
#      $month_limit[1] = 29                              # positive assertion for feb number of  days
#    else
#      $month_limit[1] = 28                              # positive assertion for feb number of days
#    end
#    date_array[2] = date_array[2] + 1
#    _month = date_array[1]
#    if $month_limit[_month-1] >= date_array[2] then     # if day within month boundaries then do nothing
#    else
#      date_array[1] += 1                                # increment month by 1
#      if date_array[1] > 12 then                        # check to see if we rolled to next year
#        date_array[1] = 1                               # set month to january
#        date_array[0] += 1                              # increment year by 1
#      end
#      date_array[2] = 1                                 # set day of month value to 1
#    end
    $last_date += 1
    date_array = $last_date.to_s.split("-")
    $reboot_date = date_array[1].to_s + "/" + date_array[2].to_s + "/" + date_array[0].to_s 
end
 
require "output_files.rb"
# require "parsedate"
require "date"
$server_guid = nil
$server_hostname = nil
$server_appliance_name = nil
$preamble_string = nil
$month_limit = Array.[](31,28,31,30,31,30,31,31,30,31,30,31)
$summary_count = 0
$enhanced_summary_count = 0
top_summary_stats = File.new("top_summary_stats.csv","w") 
process_detail_stats = File.new("top_process_details.csv","w")
$reboot_date = ""
_reboot_array = Array.new
_reboot_array[0] = 2000
_reboot_array[1] = 1
_reboot_array[2] = 1
$Top_form = 0
$reboot_date = "1/1/2000"
$last_time = "00:00:00"
#include "output_files.rb"
parm_count = ARGV.size     
if parm_count == 0 || parm_count == nil then
  puts "no input file found"
  exit
end
if File.exists?("last_startup_config.csv") then
  puts "process 'last_startup_config.csv'"
  sleep(10)                           # wait 10 seconds for last_startup.txt to complete processing
  last_startup_config = File.new("last_startup_config.csv","r")
  _last_startup_config_line = last_startup_config.gets  # skip the headings line
  _last_startup_config_line = last_startup_config.gets  # get first data line with guid, hostname and appliance name
  _server_id_array = _last_startup_config_line.split(",")
  $server_guid = _server_id_array[0]
  $server_hostname = _server_id_array[1]
  $server_appliance_name = _server_id_array[2]
  $preamble_string = $server_guid + "," + $server_hostname +"," + $server_appliance_name + ","
  # preamble will be used as prefix for top output csv files
  enhanced_top_summary_stats = File.new("enhanced_top_summary_stats.csv","w")
  enhanced_process_detail_stats = File.new("enhanced_top_process_details.csv","w")
end
_linecnt = 0
puts "#{ARGV}"
input_file = ARGV
read_loop_start = Time.new
#consider a loop here to process multiple input files
ARGV.each do |arg_file_in|
input_file = File.new(arg_file_in,"r")
  while linein = input_file.gets
#    _linecnt += 1
#    puts "linecnt = #{_linecnt}"
#    if _linecnt == 104138 then
#      puts "#{__FILE__}:#{__LINE__}"
#    end

    if /top \- 00\:00\:/ =~ linein then
    puts "#{__FILE__}:#{__LINE__}"
    end
#  end
#if _linecnt == 24589 then
#  puts "#{__FILE__}:#{__LINE__}"
#end
  next if linein.size <4 || linein.strip.size < 10 || linein.split.size <5
  if /timesync/ =~ linein then
    puts "#{__FILE__}:#{__LINE__}=>#{linein}"
  end
  case linein
#    miqtop: start: date time is->
  when /[reboot|miqtop\:\s*start\:]\s*date time is\-\>\s*(.*)/ then
    _text_datetime = $1    
    if /timesync/ =~ linein && /UTC/ =~ linein then
     next
    end

#    _reboot_array = ParseDate.parsedate(_text_datetime,false)
     $last_date = Date.parse(_text_datetime)
     _reboot_array = Date.parse(_text_datetime).to_s.split("-")
    $reboot_date = _reboot_array[1].to_s + "/" + _reboot_array[2].to_s + "/" + _reboot_array[0].to_s
    if /(\d*:\d*:\d*)/ =~ linein then
      _hold_time = $1
      if /UTC/ =~ linein then                 # this time is supposed to be host local but somehow UTC got injecte
        $last_time = nil                      # if UTC is the format, then just null out the value and we'll get it from next top detail line
      else
       $last_time = _hold_time                       # if not UTC then grab it and use it
      end

    end

    puts "top starting date-time is => #{$reboot_date}\n\t $last_time reset to #{$last_time}"

#reboot date time is-> Mon Jan 12 14:48:44 UTC 2009
  when /^top\s*\-\s*(\d*:\d*:\d*)\s*up\s*(\d*)\s*min\,\s*(\d*)\s*user\S*,\s*load average\:\s*(\d*.\d*),\s*(\d*.\d*),\s*(\d*.\d*)/ then
    $last_time = $1 if $last_time == nil
    $Top_Summary[TOD] =  $1
    _work_up_time = (($2.to_i * 60 + $Top_Summary[TOD].slice(-2..-1).to_i)).to_f/(24*3600)
    $Top_Summary[UP_TIME] = _work_up_time
#    $Top_Summary[UP_TIME] = "00:" + $2.to_s.rjust(2,"0") + ":" + 
    $Top_Summary[USER_CNT] = $3
    $Top_Summary[LOAD1] = $4
    $Top_Summary[LOAD2] = $5
    $Top_Summary[LOAD3] = $6
    if $last_time.split(":")[0] > $Top_Summary[TOD].split(":")[0] then   #if the hour of the last log line is > current hour
      $last_time = $Top_Summary[TOD] 
      increment_date(_reboot_array)
    end
    $last_time = $Top_Summary[TOD]
    $Top_Summary[TOD] = $reboot_date + " " + $Top_Summary[TOD]

  when /^top\s*\-\s*(\d*:\d*:\d*)\s*up\s*(\d*:\d*)\,\s*(\d*)\s+user\S*,\s*load average\:\s*(\d*.\d*),\s*(\d*.\d*),\s*(\d*.\d*)/ then
    $last_time = $1 if $last_time == nil
    $Top_Summary[TOD] =  $1
    $Top_Summary[USER_CNT] = $3
    $Top_Summary[LOAD1] = $4
    $Top_Summary[LOAD2] = $5
    $Top_Summary[LOAD3] = $6
    _hours_minutes = $2.split(":")    

    _work_up_time = ((( _hours_minutes[0].to_i * 60 + _hours_minutes[1].to_i )* 60) + $Top_Summary[TOD].slice(-2..-1).to_i).to_f/(24*3600)
    $Top_Summary[UP_TIME] = _work_up_time  
#    $Top_Summary[UP_TIME] = $2.to_s + ":" + 
    if $last_time.split(":")[0] > $Top_Summary[TOD].split(":")[0] then   #if the hour of the last log line is > current hour
      $last_time = $Top_Summary[TOD]
      increment_date(_reboot_array)
    end
    $last_time = $Top_Summary[TOD]
    $Top_Summary[TOD] = $reboot_date + " " + $Top_Summary[TOD]
    
  when /^top\s*\-\s*(\d*:\d*:\d*)\s*up\s*(\d*)\s*day\S*,\s*(\d*:\d*),\s*(\d*)\s*user\S*,\s*load average\:\s*(\d*.\d*),\s*(\d*.\d*),\s*(\d*.\d*)/ then
    $last_time = $1 if $last_time == nil
    $Top_Summary[TOD] =  $1
 
    _2 = $2
    _3 = $3
    _4 = $4
    _5 = $5
    _6 = $6
    _7 = $7
    _hours_minutes = _3.split(":")
    _seconds = $Top_Summary[TOD].to_s.slice(-2..-1)
#    puts "#{linein}"
#    puts "_hours_minutes = #{_hours_minutes.inspect}"
#    puts "_seconds = #{_seconds}"
#    puts "_3 = #{_3}"
#    puts "_2 = #{_2}"
    _work_up_time = ((((_2.to_i * 24 + _hours_minutes[0].to_i) * 60) + _hours_minutes[1].to_i) * 60 + _seconds.to_i).to_f/(24*3600)
#    puts "_work_up_time = #{_work_up_time}"
    $Top_Summary[UP_TIME] = _work_up_time  
#    $Top_Summary[UP_TIME] = $2.to_s + " days- " + $3.to_s
#    $Top_Summary[UP_TIME] = ((_2.to_i * 24).to_i + _hours_minutes[0].to_i).to_s + ":"  + _hours_minutes[1] + ":" + _seconds
    $Top_Summary[USER_CNT] = _4
    $Top_Summary[LOAD1] = _5
    $Top_Summary[LOAD2] = _6
    $Top_Summary[LOAD3] = _7
#    puts "#{__FILE__}:#{__LINE__}-> inspect last time =>#{$last_time.inspect}\n\t\tinspect $Top_Summary[TOD]=>#{$Top_Summary[TOD].inspect}"
    if $last_time.split(":")[0] > $Top_Summary[TOD].split(":")[0] then   #if the hour of the last log line is > current hour
      $last_time = $Top_Summary[TOD]
      increment_date(_reboot_array)
    end
    $last_time = $Top_Summary[TOD]
    $Top_Summary[TOD] = $reboot_date + " " + $Top_Summary[TOD]  
  when /^top \-\s*(\d*:\d*:\d*)\s*up\s*(\d*)\s*day\S*,\s*(\d*)\s*min,\s*(\d*)\s*user\S*,\s*load average\:\s*(\d*.\d*),\s*(\d*.\d*),\s*(\d*.\d*)/ then
    $last_time = $1 if $last_time == nil
    $Top_Summary[TOD] =  $1

    _work_up_time = (((($2.to_i * 24) * 60) + $3.to_i) * 60 + $Top_Summary[TOD].to_s.slice(-2..-1).to_i).to_f/(24*3600)
    $Top_Summary[UP_TIME] = _work_up_time
#    $Top_Summary[UP_TIME] = $2.to_s + " days- 00:" + $3.to_s
#    $Top_Summary[UP_TIME] = ($2.to_i * 24).to_s + ":" + $3.to_s.ljust(2,"0") + ":" + $1.slice(-2..-1)
    $Top_Summary[USER_CNT] = $4
    $Top_Summary[LOAD1] = $5
    $Top_Summary[LOAD2] = $6
    $Top_Summary[LOAD3] = $7
    if $last_time.split(":")[0] > $Top_Summary[TOD].split(":")[0] then   #if the hour of the last log line is > current hour
      $last_time = $Top_Summary[TOD]
      increment_date(_reboot_array)
    end
    $last_time = $Top_Summary[TOD]
    $Top_Summary[TOD] = $reboot_date + " " + $Top_Summary[TOD]    
  when /^Tasks:\s*(\d*)\s*total,\s*(\d*)\s*running,\s*(\d*)\s*sleeping,\s*(\d*)\s*stopped,\s*(\d*)\s*zombie/ then
    $Top_Summary[TASK_CNT] = $1
    $Top_Summary[RUNNING_TASKS] = $2  
    $Top_Summary[SLEEPING_TASKS] = $3  
    $Top_Summary[STOPPED_TASKS] = $4
    $Top_Summary[ZOMBIE_TASKS] = $5
   
    
          
  when /^Cpu\(s\):\s*(\d*\.\d*)\%us,\s*(\d*\.\d*)\%sy,\s*(\d*\.\d*)\%ni,\s*(\d*\.\d*)\%id,\s*(\d*\.\d*)\%wa,\s*(\d*\.\d*)\%hi,\s*(\d*\.\d*)\%si,\s*(\d*\.\d*)\%st/ then
    
    $Top_Summary[CPU_USER] =  $1
    $Top_Summary[CPU_SYSTEM] = $2  
    $Top_Summary[CPU_NI] = $3  
    $Top_Summary[CPU_IDLE] = $4 
    $Top_Summary[CPU_WAIT] = $5  
    $Top_Summary[CPU_HI] = $6 
    $Top_Summary[CPU_SI] = $7  
    $Top_Summary[CPU_ST] = $8  

  when /^Mem:\s*(\d*)k total,\s*(\d*)k used,\s*(\d*)k free,\s*(\d*)k buffers/ then
    $Top_Summary[MEMORY_TOTAL] =  $1
    $Top_Summary[MEMORY_USED] = $2 
    $Top_Summary[MEMORY_FREE] = $3  
    $Top_Summary[MEMORY_BUFFERS] = $4      
    

  when /^Swap:\s*(\d*)k total,\s*(\d*)k used,\s*(\d*)k free,\s*(\d*)k cached/ then
    $Top_Summary[SWAP_TOTAL] = $1
    $Top_Summary[SWAP_USED] = $2  
    $Top_Summary[SWAP_FREE] = $3  
    $Top_Summary[SWAP_CACHED] = $4      

  when /^\s*PID\s*USER\s*PR/ then
    # this is the original top output detail line
    $Top_form = 0     #0 = original form of top output
#    puts "$Top_form set to 0"
    write_summary_stats($Top_Summary,top_summary_stats)
    write_enhanced_summary_stats($Top_Summary,enhanced_top_summary_stats) if $preamble_string != nil
  when /PID\s*PPID\s*USER\s*PR/ then
    # this is the Nov 2011 updated top output detail line
    $Top_form = 1     #0 = original form of top output  , 1 = Nov 2011 updated form
#    puts "$Top_form set to 1"
    write_summary_stats($Top_Summary,top_summary_stats)
    write_enhanced_summary_stats($Top_Summary,enhanced_top_summary_stats) if $preamble_string != nil

      #  when /^\s*(\d*)\s*(\S*)\s*(\d*)\s*(\d*)\s*([\d*|\d*k|\d*m])\s*([\d*|\d*k|\d*m])\s*([\d*|\d*k|\d*m])\s*(\S)\s*(\d*)\s*(\d*\.\d*)\s*(\d*:\d*:\d*)\s*(.*)/  then
  when /^\s*(\d*)/ then
    if /^top/ =~ linein then 
      puts "#{linein}\n stopping at first parse line failure"
#      exit
      next
    end

    linein_array = linein.split
    if /\d*:\d*/ =~ linein_array[4] || /\d*:\d*/ =~ linein_array[5] || /\d*:\d*/ =~ linein_array[6] then
      puts "interval time is #{$Top_Summary[0]}\n\t#{linein}"
    end
    case $Top_form

    when 0 then
#      puts "$Top_form = 0, #{linein}"
        $PID_array[0] = $Top_Summary[0] #time of day field
        $PID_array[PID_ID] = linein_array[0]
        $PID_array[PID_USER] = linein_array[1]
        $PID_array[PID_PR] = linein_array[2]
        $PID_array[PID_NI] = linein_array[3]
        $PID_array[PID_VIRT] = adjust_scale(linein_array[4])
        $PID_array[PID_RES] = adjust_scale(linein_array[5])
        $PID_array[PID_SHR] = adjust_scale(linein_array[6])

        $PID_array[PID_S] = linein_array[7]
        $PID_array[PID_CPU] = linein_array[8]
        $PID_array[PID_MEM] = linein_array[9]
    #    $PID_array[PID_TIME] = linein_array[10]
          _temp_array = linein_array[10].split(":")                  # separate time elements
          _temp_duration = 0                                         # set temp work variable
          _temp_array.each do |tt|                                   # process each component
    #        puts "value of 'tt' is #{tt}   value of _temp_duration is #{_temp_duration}"
            _temp_duration = _temp_duration.to_f*60 + tt.to_f                   # finally resulting in duration in seconds
                           end
        $PID_array[PID_TIME] = _temp_duration
        $PID_array[PID_COMMAND] = linein_array[11]
        $PID_array[PID_UP_TIME] = $Top_Summary[UP_TIME]
#        when 0 then
#        $PID_array[0] = $Top_Summary[0] #time of day field
#        $PID_array[PID_ID] = linein_array[0]
#        $PID_array[PID_USER] = linein_array[1]
#        $PID_array[PID_PR] = linein_array[2]
#        $PID_array[PID_NI] = linein_array[3]
#        $PID_array[PID_VIRT] = adjust_scale(linein_array[4])
#        $PID_array[PID_RES] = adjust_scale(linein_array[5])
#        $PID_array[PID_SHR] = adjust_scale(linein_array[6])
#
#        $PID_array[PID_S] = linein_array[7]
#        $PID_array[PID_CPU] = linein_array[8]
#        $PID_array[PID_MEM] = linein_array[9]
#    #    $PID_array[PID_TIME] = linein_array[10]
#          _temp_array = linein_array[10].split(":")                  # separate time elements
#          _temp_duration = 0                                         # set temp work variable
#          _temp_array.each do |tt|                                   # process each component
#    #        puts "value of 'tt' is #{tt}   value of _temp_duration is #{_temp_duration}"
#            _temp_duration = _temp_duration.to_f*60 + tt.to_f                   # finally resulting in duration in seconds
#                           end
#        $PID_array[PID_TIME] = _temp_duration
#        $PID_array[PID_COMMAND] = linein_array[11]
#        $PID_array[PID_UP_TIME] = $Top_Summary[UP_TIME]
     when 1 then
#       puts "tom form = 1, #{linein}"
        $PID_array[0] = $Top_Summary[0] #time of day field
        $PID_array[PID_ID] = linein_array[0]
        $PID_array[PID_USER] = linein_array[2]
        $PID_array[PID_PR] = linein_array[3]
        $PID_array[PID_NI] = linein_array[4]
        $PID_array[PID_VIRT] = adjust_scale(linein_array[5])
        $PID_array[PID_RES] = adjust_scale(linein_array[6])
        $PID_array[PID_SHR] = adjust_scale(linein_array[7])

        $PID_array[PID_S] = linein_array[8]
        $PID_array[PID_CPU] = linein_array[9]
        $PID_array[PID_MEM] = linein_array[10]
    #    $PID_array[PID_TIME] = linein_array[10]
          _temp_array = linein_array[11].split(":")                  # separate time elements
          _temp_duration = 0                                         # set temp work variable
          _temp_array.each do |tt|                                   # process each component
    #        puts "value of 'tt' is #{tt}   value of _temp_duration is #{_temp_duration}"
            _temp_duration = _temp_duration.to_f*60 + tt.to_f                   # finally resulting in duration in seconds
                           end
        $PID_array[PID_TIME] = _temp_duration
        _work_command = linein_array[12,linein_array.size].join(" ")
        _work_command_array = _work_command.split('"')               # see if there are double quotes in the command
        if _work_command_array.size > 1 then
          _work_command = _work_command_array.join('""')
        end
        $PID_array[PID_COMMAND] = '"' + _work_command + '"' # collect all of the command line info
        $PID_array[PID_UP_TIME] = $Top_Summary[UP_TIME]
        $PID_array[PPID] = linein_array[1]

    end
#    $PID_array[PID_SHR] = linein_array[12] 
    
    write_process_stats($PID_array,process_detail_stats)
    write_enhanced_process_stats($PID_array,enhanced_process_detail_stats) if $preamble_string != nil
  else 
    puts "#{linein}"
    puts "didn't match anything"
    exit
  end
  end
end
process_detail_stats.close if process_detail_stats
enhanced_process_detail_stats.close if enhanced_process_detail_stats
top_summary_stats.close if top_summary_stats
enhanced_top_summary_stats.close if enhanced_top_summary_stats
# code added to remove empty summary files to prevent top excel pdr producing batch file from choking on empty files
File.delete("top_summary_stats.csv") if $summary_count == 0 # if zero records then delete it
File.delete("enhanced_top_summary_stats.csv") if $enhanced_summary_count == 0 #if zero records then delete it