=begin rdoc
the objective of this section of code is to create a csv file that contains a summary of the miq_cmds just processed

$Id: miq_cmds_summary.rb 17490 2009-12-02 20:38:41Z thennessy $

=end
def miq_cmds_summary(in_hash,base_file_name)
# this code expects a hash to be passed in, and if it isn't it will simply return with a msg to stdout
# the second parm is the "base file name" either "evm" or "production".  Only do the write for the "evm" file type

if in_hash.class.to_s != "Hash" && in_hash.class.to_s != "Dictionary" then
  puts "miq_cmds_summary expecting Hash or Dictionary as passed parm, recieved #{in_hash.class.to_s},\n\t returning without creating summary file"
  return
end

return if base_file_name != "evm"                     # only build the output file for "evm" file processing

miq_cmd_summary_file = File.new($diag_dir + $directory_separator + "miq_cmds_summary_#{base_file_name}\.csv","w")
miq_cmd_summary_file.puts "file location,miq cmd,count"
in_hash.each do |key, element|
  miq_cmd_summary_file.puts "#{$diag_dir},#{key},#{element}"
  end
  miq_cmd_summary_file.close
end