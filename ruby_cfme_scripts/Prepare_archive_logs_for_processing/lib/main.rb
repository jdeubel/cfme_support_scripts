=begin rdoc
Copyright 2008,2009, 20010, 2011 ManageIQ, Inc
$Id: main.rb 26751 2011-02-25 04:46:19Z thennessy $
=end

=begin rdoc
the intend of this program is to process all of the Archive*.zip and Current*.zip files in the following way:
1- make sure that they conform to the standard nameing form and if they don't then error out
2- make sure that there are no invalid characters in region name or appliance name and if so transform to dash
3- make sure there is only one Current*.zip file in the directory and if not, error out
4- rename the file "renameme.zip" into the expected form
  expected form is "Appliance name"_"appliance id"_"log end date"_"log end time".zip
5- more the file renamed above to its parent directory

Standard nameing form for V3 logs is:
1-elements are all separated by a single underscore to simplify parsing
2-"Archive" or "Current" as first word
3 elements as follows:
  1-"Archive" or "Current"
  2- Zone name
  3- Zone id
  4- Appliance name
  5- Appliance id
  6- log begin date (ccyymmdd)
  7- log begin time (HHmmss)
  8- log end date (ccyymmdd)
  9- log end time ( HHmmss)
and of course, ".zip"
Tom Hennessy Jan 2011

Standard naming form for V4 logs is:
1-elements are all spearated by a single underscore to simplify parsing
2-"Archive" or "Current" as first word
3- elements as follows:
  1- "Archive" or "Current"
  2- Region name
  3- Region number
  2- Zone name
  3- Zone id
  4- Appliance name
  5- Appliance id
  6- log begin date (ccyymmdd)
  7- log begin time (HHmmss)
  8- log end date (ccyymmdd)
  9- log end time ( HHmmss)

=end

require "find"
require "fileutils"
include FileUtils::Verbose
Find.find(".") do |element|
  next if /.zip/ !~ element                 # if not zip file then skip it
#  puts "#{element}"
  file_parts0 = element.split("\/")         #   separate ".zip" from rest of file name
  next if file_parts0.size > 2              # if element is below current directory skip it
  file_parts = file_parts0[-1].split(".")   # last element is the one I want
  file_name = file_parts[0...-1].join(".")
  file_name_array = file_name.split("_")
  next if /Current/ !~ file_name_array[0]
  puts "count of file name elements is #{file_name_array.size}"
  case file_name_array.size
  when 9 then file_name_type = "V3"
  when 11 then file_name_type = "V4"
  else
    puts "unrecognized file log type '#{element}'- file skipped"
    next
  end

# we need to determine if this is a V3 or a V4 log set, so I'm going to assume
# that the region # , zone # and appliance # is always less than 5 digits
# so I dont' accidentally grab the date or time as a separator
# going for this kind of split
# 'literai_region name' 1-5 digit number 'zone name' 1-5 digit number 'appliance name' 1-5 digit number and datetimes
# /(.*?)_(\d{1,5})_(.*?)_(\d{1,5})_(.*?)_\d{1,}_(.*)/
# file_name_type = nil
  case file_name_type
# use the more restrictive first to search for V4 type log name with Region
  when "V4"
    v4_file_name_array = file_name.split("_")
    v4_log_end_time = v4_file_name_array[-1]
    v4_log_end_date = v4_file_name_array[-2]
    v4_log_begin_time = v4_file_name_array[-3]
    v4_log_begin_date = v4_file_name_array[-4]
    v4_appliance_id = v4_file_name_array[-5]
    v4_appliance_name = v4_file_name_array[-6]
    v4_appliance_zone_id = v4_file_name_array[-7]
    v4_appliance_zone_name = v4_file_name_array[-8]
    v4_appliance_region_id = v4_file_name_array[-9]
    v4_appliance_region_name = v4_file_name_array[-10]
    v4_preamble = v4_file_name_array[-11]

#  if  /(.*?)_(\d{1,5})_(.*?)_(\d{1,5})_(.*?)_(\d{1,})_(.*)/ =~ file_name then
    # if of this type then we have a V4 type log-zip file
    file_name_type = "V4"
#   _region_with_preamble = $1
    _region_with_preamble = v4_preamble + "_" + v4_appliance_region_name
#
#   _region_id = $2
    _region_id = v4_appliance_region_id
#   _zone_name = $3
    _zone_name = v4_appliance_zone_name
#   _zone_id = $4
    _zone_id = v4_appliance_zone_id
#   _appliance_name = $5
    _appliance_name = v4_appliance_name
#   _appliance_id = $6
    _appliance_id = v4_appliance_id
#   _DateTime = $7
    _DateTime = v4_log_begin_date + "_" + v4_log_begin_time + "_" + v4_log_end_date + "_" + v4_log_end_time #
#   _preamble = _region_with_preamble.split("_")[0]
    _preamble = v4_preamble #
#   _region_name = _region_with_preamble.split("_")[1]
    _region_name = v4_appliance_region_name
   _region_name = _region_name.tr(" &","-n") if file_name_type == "V4" #replace space with dash and & with "n"
   puts "file type is #{file_name_type}, region name with preamble is '#{_region_with_preamble}'" +
        "\n\tregion name is '#{_region_name}', region id is #{_region_id}, zone name is '#{_zone_name}', zone id is #{_zone_id}" +
        "\n\tappliance name is '#{_appliance_name}', appliance id is '#{_appliance_id}'" +
        "\n\t datetimes are '#{_DateTime}'"
#  end
  when "V3"
  if /(.*?)_(\d{1,5})_(.*?)_(\d{1,})_(.*)/ =~ file_name then
    # if of this type then we have a V3 type log-zip fle
    file_name_type = "V3"
   _zone_with_preamble = $1

   _zone_id = $2
   _appliance_name = $3
   _appliance_id = $4
   _DateTime = $5
   _preamble = _zone_with_preamble.split("_")[0]
   _zone_name = _zone_with_preamble.split("_")[1]
  end
  else
    puts "the file named '#{element}' does not confirm with EVM log zip file formats and is therefore being skipped"
    next
  end
    _appliance_name = _appliance_name.tr(" &","-n") # replace space with dash and & with "n"
    _zone_name = _zone_name.tr(" &","-n")       # replace space with dash and & with "n"

    _log_begin_datetime = _DateTime.split("_")[0..1].join("_") #first two fields are log begin date and time
    _log_end_datetime = _DateTime.split("_")[2..-1].join("_") #last  two fields are log end date and time

#  puts "file name for '#{element}' is '#{file_name}'"

#  archive_array = file_name.split("_")
  case _preamble
  when "Current" then
#    _zone = archive_array[1].tr(" &","-n")       # replace space with dash and & with "n"
#    _zoneid = archive_array[2]
#    _appliance_name = archive_array[3].tr(" &","-n") # replace space with dash and & with "n"
#    _appliance_id = archive_array[4]
#    _log_end_time = archive_array[-1]
#    _log_end_date = archive_array[-2]
#    _log_begin_time = archive_array[-3]
#    _log_begin_date = archive_array[-4]
#    new_name = _appliance_name +"_" + _appliance_id + "_" + _log_end_date + "_" + _log_end_time + ".zip"
    new_name = _appliance_name +"_" + _appliance_id + "_" + _log_end_datetime + ".zip"
   puts "Will rename 'rename_me.zip' to '#{new_name}'"
   _rename_results = nil
   _rename_results = File.rename("rename_me.zip", new_name) if File.exists?("rename_me.zip")
   puts "result of rename is '#{_rename_results}'"
   if File.exists?(new_name) then  # if new name exists then move it to parent directory
      mv(new_name,"../" + new_name)
      puts "#{new_name} moved to parent directory"
   else
     puts "'rename_me.zip' has not been renamed or moved to parent directory"
   end

  end
end
exit
#end
