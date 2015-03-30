# To change this template, choose Tools | Templates
# and open the template in the editor.


#require "parsedate"
require "date"
$month_limit = Array.[](31,28,31,30,31,30,31,31,30,31,30,31)
$reboot_date = ""
_reboot_array = Array.new
_reboot_array[0] = 2000
_reboot_array[1] = 1
_reboot_array[2] = 1
$reboot_date = "1/1/2000"
$last_time = "00:00:00"
$record_time = nil
infile = File.new("vmstat_output.log","r")

 $vmstat_csv = File.new("vmstat_output.csv","w")
 $vmstat_csv.puts("date time,ready run queue,blocked,swap memory,free memory,inactive memory,active memory,swap in rate, swap out rate,blk input rate,blk output rate,interrupts,context switches,cpu user,cpu system,cpu idle,cpu wait,cpu stolen")
 in_record_array = Array.new 
 while in_record = infile.gets
    in_record_array = in_record.strip.split(" ")
    case in_record
      when /miqtop\:\s*start\:\s*date time is\-\>\s*(.*)/ then
    _text_datetime = $1
    _reboot_string = DateTime.parse(_text_datetime)
    _reboot_string_date = _reboot_string.to_s.split("T")
    _reboot_string_date_array = _reboot_string_date[0].split("-")
    _reboot_array = _reboot_string_date_array
#    _reboot_array = ParseDate.parsedate(_text_datetime,false)
    $reboot_date = _reboot_array[1].to_s + "/" + _reboot_array[2].to_s + "/" + _reboot_array[0].to_s
#    $reboot_time = Time.gm(_reboot_array[0],_reboot_array[1],_reboot_array[2],_reboot_array[3],_reboot_array[4],_reboot_array[5])
    $record_time = Time.gm(_reboot_string.cwyear,_reboot_string.month,_reboot_string.day,_reboot_string.hour,_reboot_string.min,_reboot_string.sec)
    $record_time = $record_time - 60
    if /(\d*:\d*:\d*)/ =~ in_record then $last_time = $1 end
    puts "vmstat starting date-time is => #{$reboot_date}\n\t $last_time reset to #{$last_time}"
    next
      when /miqtop\:\s*timesync\:\s*date time is\-\>\s*(.*)/ then
#miqtop: timesync: date time is-> Sun Jul 12 12:17:01 EDT 2009
    _text_datetime = $1
    _reboot_string = DateTime.parse(_text_datetime)
    _reboot_string_date = _reboot_string.to_s.split("T")
    _reboot_string_date_array = _reboot_string_date[0].split("-")
    _reboot_array = _reboot_string_date_array
#    _reboot_array = ParseDate.parsedate(_text_datetime,false)
#    $record_time = Time.gm(_reboot_array[0],_reboot_array[1],_reboot_array[2],_reboot_array[3],_reboot_array[4],_reboot_array[5])
     $record_time = Time.gm(_reboot_string.cwyear,_reboot_string.month,_reboot_string.day,_reboot_string.hour,_reboot_string.min,_reboot_string.sec)
#    $record_time = $record_time - 60                    #decrement by one minute since it will be incremented before printing
     $record_time = $record_time - 60

#    $reboot_date = _reboot_array[1].to_s + "/" + _reboot_array[2].to_s + "/" + _reboot_array[0].to_s
    $reboot_date = _reboot_string.month.to_s + "/" + _reboot_string.day.to_s + "/" + _reboot_string.cwyear.to_s
#    [3..5].each do |index|                                      # ensure hour minute and seconds of array are two digits
#      if _reboot_array[index].to_s.size = 1 then
#        _reboot_array[index] = "0" + _reboot_array[index].to_s
#      end
#    end
    # now inject as last time the sync time but keep the reboot seconds, in any
#    $last_time = _reboot_array[3] + ":" + _reboot_array[4] + ":" + $last_time.split(":")[-1]
      next
    when /miqtop\:\s*stop\:/ then next    # skip the stop records, if any
    end
    next if $record_time == nil
    case in_record_array[0]
    when /procs/ then
    when /r/ then

    else
      _temp_string = in_record_array.join(",")
      $record_time = $record_time + 60
      _t = $record_time.strftime("%m/%d/%Y %H:%M:%S")
      _temp_string =  _t +  "," + _temp_string
      $vmstat_csv.puts(_temp_string)
    end
 end
 $vmstat_csv.close 
def write_vmstat(string)

end