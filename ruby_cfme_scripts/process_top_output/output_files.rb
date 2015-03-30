# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

#top_summary_stats = File.new("top_summary_stats.csv","w")
$top_summary_stats_flag = nil
$enhanced_top_summary_stats_flag = nil
$process_detail_stats_flag = nil
$enhanced_process_detail_stats_flag = nil
$reboot_date = nil
$last_time = nil

#top_summary_stats = File.new("top_summary_stats.csv","w") 
#process_detail_stats = File.new("process_details.csv","w")

$Top_Summary = Array.new
$PID_array = Array.new
#Summary Array Constants as index
TOD = 0
UP_TIME = 1
USER_CNT = 2
LOAD1 = 3
LOAD2 = 4
LOAD3 = 5
TASK_CNT = 6
RUNNING_TASKS = 7
SLEEPING_TASKS = 8
STOPPED_TASKS = 9
ZOMBIE_TASKS = 10
CPU_USER = 11
CPU_SYSTEM = 12
CPU_NI = 13
CPU_IDLE = 14
CPU_WAIT = 15
CPU_HI = 16
CPU_SI = 17
CPU_ST = 18
MEMORY_TOTAL = 19
MEMORY_USED = 20
MEMORY_FREE = 21
MEMORY_BUFFERS = 22
SWAP_TOTAL = 23
SWAP_USED = 24
SWAP_FREE = 25
SWAP_CACHED = 26
PID_ID = 1
PID_USER = 2
PID_PR = 3
PID_NI = 4
PID_VIRT = 5
PID_RES = 6
PID_SHR = 7
PID_S = 8
PID_CPU = 9
PID_MEM = 10
PID_TIME = 11
PID_COMMAND = 12
PID_UP_TIME = 13
PPID = 14

def write_summary_stats(input_array,fileout)
  if $reboot_date.split("/")[2].to_i < 2009 then         # if the reboot date is not > 2008 then skip until good date is found
    return
  end
if $top_summary_stats_flag == nil then
  $top_summary_stats_flag = true
  $summary_count += 1
#  top_summary_stats = File.new("top_summary_stats.csv","w")  
  fileout.puts "time of day,up time, user count,load1,load2,load3," +
    "task count,running tasks,sleeping tasks,stopped tasks,zombie tasks," +
    "% cpu user,%cpu system,%cpu ni,%cpu idle,%cpu wait,%cpu hi,%cpu si,%cpu st," +
    "memory total,memory used,memory free,memory buffers," +
    "total swap,used swap,free swap,cached swap"
end
  fileout.puts "#{input_array.join(",")}"
  $summary_count += 1
end
def write_enhanced_summary_stats(input_array,fileout)
  if $reboot_date.split("/")[2].to_i < 2009 then         # if the reboot date is not > 2008 then skip until good date is found
    return
  end
if $enhanced_top_summary_stats_flag == nil then
  $enhanced_top_summary_stats_flag = true
  $enhanced_summary_count += 1
#  top_summary_stats = File.new("top_summary_stats.csv","w")
  fileout.puts "server guid,server hostname,appliance name,time of day,up time, user count,load1,load2,load3," +
    "task count,running tasks,sleeping tasks,stopped tasks,zombie tasks," +
    "% cpu user,%cpu system,%cpu ni,%cpu idle,%cpu wait,%cpu hi,%cpu si,%cpu st," +
    "memory total,memory used,memory free,memory buffers," +
    "total swap,used swap,free swap,cached swap"
end
  fileout.puts "#{$preamble_string}#{input_array.join(",")}"
  $enhanced_summary_count += 1
end
def write_process_stats(x,fileout)
    if $reboot_date.split("/")[2].to_i < 2009 then         # if the reboot date is not > 2008 then skip until good date is found
    return
  end
  if $process_detail_stats_flag == nil then
      $process_detail_stats_flag = true
#    process_detail_stats = File.new("process_details.csv","w")
    fileout.puts "time of day,pid,user,pr,ni,virt,res,shr,s,cpu,mem,time,command,elapsed time,PPID"
  end
  fileout.puts "#{x.join(",")}"
end
def write_enhanced_process_stats(x,fileout)
    if $reboot_date.split("/")[2].to_i < 2009 then         # if the reboot date is not > 2008 then skip until good date is found
    return
  end
  if $enhanced_process_detail_stats_flag == nil then
      $enhanced_process_detail_stats_flag = true
#    process_detail_stats = File.new("process_details.csv","w")
    fileout.puts "server guid,server hostname,appliance name,time of day,pid,user,pr,ni,virt,res,shr,s,cpu,mem,time,command,elapsed time,PPID"
  end
  fileout.puts "#{$preamble_string}#{x.join(",")}"
end
def adjust_scale(input_string)
  case input_string.strip
  when /^(\d*)$/ then input_string
  when /^(\d*)k$/ then input_string = $1.to_i
  when /^(\d*|\d*.\d*)m$/ then input_string = ($1.to_f*1024).to_i
  when /^(\d*\.\d*|\d*)g$/ then input_string = ($1.to_f*1024*1024).to_i
  else 
    puts "string isn't recognised for adjustment #{input_string}"
    input_string
#    exit
  end
end

