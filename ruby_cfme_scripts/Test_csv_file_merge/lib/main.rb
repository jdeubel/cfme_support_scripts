require "csv"
require "fileutils"
require "rubygems"
def save_merged_record()
  _temp_string = ""
  _loop_cnt = 0
#   puts "save merged record element count = #{$Save_row.size}"
  $Save_row.size.times {|x|
      _loop_cnt += 1
      if $Save_row[_loop_cnt].to_s.index(",") then
        _temp_string << '"' + $Save_row[_loop_cnt].to_s + '",'
      else
        _temp_string << $Save_row[_loop_cnt].to_s + ','
      end

  }
  $Writer.puts _temp_string
  $Save_row.clear
  $write_count += 1
#  puts $Save_row[3]
end
#reader = CSV.open("sorted__evm_msg_info.csv",mode="rb",{:headers => true, :row_sep=> "\r\n"}  )
reader = File.new("sorted__evm_msg_info.csv","r")
$Writer = File.new("sorted_merged_evm_msg_info.csv","w")
$write_count = 0
header = reader.gets.chomp.split(",")
_temp_outfile_header = ""
puts "#{header.inspect}"

loop_cnt = 0
(header.size-1).times {|item|
                          loop_cnt += 1
#                          puts loop_cnt
                        _temp_string =  '"' + header[loop_cnt].to_s + '",'
                        _temp_outfile_header << _temp_string.to_s
                        }
puts _temp_outfile_header
$Writer.puts _temp_outfile_header

$Save_row = Array.new
reader.each {|line|
  line.chomp!
  row = line.split(",")
#  puts $Save_row.size
#  puts "input line has #{row.size} elements"
  if $Save_row.size == 0 then
#    row.delete_at(0)
    $Save_row = row
    next
  end

  if row[0] != $Save_row[0] then
#    row.delete_at(0)
    save_merged_record
    $Save_row = row
    next
  end

  if row[0] == $Save_row[0] then
#    row.delete_at(0)
    element_count = 0
    (row.size).times {|x|

                    if $Save_row[element_count] == nil ||
                       $Save_row[element_count].class.to_s == "NilClass" ||
                       $Save_row[element_count] == " "  ||
                       $Save_row[element_count] == "" then
                          $Save_row[element_count] = row[element_count]
#                          puts "for #{row[0]} copying element #{element_count} "
                    else
#                      puts "not copying element #{element_count}"
#                      puts "$Save_row[#{element_count}] = #{$Save_row[element_count]} - row[#{element_count}] = #{row[element_count]}"
                    end
                    element_count += 1
    }
  end
}
save_merged_record if $Save_row.size > 0
$Writer.close
puts "Total records created in output file is #{$write_count}"
exit


