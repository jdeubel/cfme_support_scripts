# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'net/ftp'
require 'rubygems'
require 'logger'

module Net
class FTP
    DEFAULT_BLOCKSIZE = 65000
end
end
$depth = 0
$ftp_files = Array.new
$transfer_option = 'current-only'
#$transfer_option = "current-2"

class Unix_dir
  attr_accessor :entry_type, :entry_name, :size, :file_modified_time
  @flags = nil
  @number = nil
  @user = nil
  @group = nil
  @size = nil
  @month = nil
  @day = nil
  @time = nil
  @entry_name = nil
  @entry_type = nil
  @file_modified_time = nil
  def initialize(entry)
    entry_array = entry.split
    if /^d/ =~ entry_array[0] then
      @entry_type = "dir"
    else
      @entry_type = 'not dir'
      @size = entry_array[-5]

    end
    if entry_array.size > 8 then
      @entry_name = entry_array[8..-1].join(" ")
    else
    @entry_name = entry_array[-1]      
    end

  end
end
def find_latest_current_archive(ftp_handle)

  most_recent = nil
  most_recent_current_archive = nil     # empty the current archive setting for this directory
  current_array = ftp_handle.list("Current*.zip")
  if current_array.size > 0 then
    most_recent = current_array[-1] if current_array.size
    x = Unix_dir.new(most_recent)
    most_recent_current_archive =  ftp_handle.mtime(x.entry_name,local = true)
  else
    most_recent_current_archive = nil
  end
end
def drill_down(ftp_handle,directory)
  $depth += 1
  current_directory = ftp_handle.pwd
  puts "drill_down entered at depth #{$depth} with directory '#{directory}' to drill into from current directory '#{current_directory}'"
  ftp_handle.chdir(directory)
  # see if there is a current*.zip archive in this directory and if more than one, find the latest
  most_recent_current_archive = find_latest_current_archive(ftp_handle)
  puts "archive date found is '#{most_recent_current_archive}'"
  $log.info "getting list of '#{directory}' file names"
  file_array = ftp_handle.list

  file_array.each do |entry|
#    puts "#{entry}"
    x = Unix_dir.new(entry)
#    puts "depth '#{$depth}' directory '#{directory}' file hame '#{x.entry_name}' type '#{x.entry_type}'"
#    puts "unix name is #{x.entry_name}, entry type is '#{x.entry_type}'"
    if x.entry_type == 'dir' then
      drill_down(ftp_handle,x.entry_name)
    else
      puts "'#{ftp_handle.pwd}' has file '#{x.entry_name}' of size '#{ftp_handle.size(x.entry_name)}', last modified '#{ftp_handle.mtime(x.entry_name,local = true).strftime("%m/%d/%Y %I:%Mp")}'"
      x.file_modified_time = ftp_handle.mtime(x.entry_name,local = true)
      ftp_file_hash = {"parent directory" => current_directory,"current_directory"=> directory, "ftp_file" =>x}
      if most_recent_current_archive.class.to_s != "NilClass" && x.file_modified_time.strftime("%m/%d/%Y") == most_recent_current_archive.strftime("%m/%d/%Y") then
        if /#{current_directory}#{directory}/ !~ Dir.getwd then
          # if current_directory||directory are not in the path, then we need to create the new directory and
          # then make that the current directory for file copying
          save_directory = Dir.getwd            # save current directory to restore after file copy
          # the value of the current_directory is of the form "/Logs/dir1/dir2/etc"
          # if the current working directory does not containt the "current_directory" then
          # we must parse out the individual directory names, beginning after "/Logs" and create them.
          (current_directory+directory).split("/")[2..-1].each do |directory_element|
                  Dir.mkdir(directory_element) if !File.exists?(directory_element) #make dir if not already there
                  Dir.chdir(directory_element)
                  puts "new working directory is #{Dir.getwd}"
                end
        else
          Dir.chdir((current_directory+directory).split("/")[2..-1].join("/"))
        end
        if !File.exists?(x.entry_name) || File.mtime(x.entry_name)!= x.file_modified_time then
        $log.info "starting binary transfer of '#{x.entry_name}'"
        ftp_handle.getbinaryfile(x.entry_name)             # download file from ftp
        File.utime(0,x.file_modified_time,x.entry_name)    # change date and time on local file system to match ftp time
        $log.info "transfer of '#{x.entry_name}' is complete"
        else
          $log.info "file '#{x.entry_name}' already exists, skipping unnecessary download"
          puts "file '#{x.entry_name}' already exists, skipping unnecessary download"
        end
        Dir.chdir(save_directory)                          # restore prior directory as current working directory
      end
      $ftp_files << ftp_file_hash

    end

  end
  $depth += -1
  puts "restoring '#{current_directory}' as current directory"
  ftp_handle.chdir(current_directory)
    $log.info "processing of '#{directory}' complete - #{file_array.size} instances examined"
end


#Configuration
$log = Logger.new('ftp_tranfser.log')
ftp_server = "customer.manageiq.com"
#ftp_user = 'myspace'
ftp_passwd = 'evm123'
ftp_acct = nil
#end config

if ARGV.size == nil || ARGV.size == 0 then
    $log.info "no userid specified for ftp transfer,no transfer performend"
    $log.info "usage requires up to two command line options:"
    @log.info "\tfirst value is ftp userid\n\tsecond option controls how many files to transfer"
else
    ftp_user = ARGV[0]
    transfer_option = nil
    transfer_option = ARGV[1] if ARGV.size > 1
    puts "recognized command line parms are:\n\t ftp_user = '#{ftp_user}'\n\ttransfer_option = '#{transfer_option}'"
    $log.info "recognized command line parms are:\n\t ftp_user = '#{ftp_user}'\n\ttransfer_option = '#{transfer_option}'"
end

#setup the ftp
ftp = Net::FTP.new(ftp_server)
#login to the server
$log.info "making attempt to login to ftp server, #{ftp_server} for user id '#{ftp_user}'"
puts "making attempt to login to ftp server, #{ftp_server} for user id '#{ftp_user}"
ftp.login(user = ftp_user, passwd = ftp_passwd, acct = ftp_acct)

ftp.chdir('Logs')

file_array = ftp.list
file_array.each do |name|
  puts "following #{ftp.pwd}, entry #{name}"
  name_array = name.split
  puts "#{name_array.inspect}"
  x = Unix_dir.new(name)
  if x.entry_type == 'dir' && x.entry_name != "archive" then
    drill_down(ftp,x.entry_name)
  end
end
#we don't want to loose disk space....
$log.info "logout of ftp server"
ftp.close
puts "count of files found is #{$ftp_files.size}"
$ftp_files.each do |_hash|
  parent_directory = _hash["parent directory"]
  current_directory = _hash["current_directory"]
  ftp_file = _hash["ftp_file"]
#  puts "#{ftp_file.file_modified_time.strftime("%m/%d/%Y")}"
  if ftp_file.file_modified_time.strftime("%m/%d/%Y") == "02/17/2011" then
    $log.info "would copy '#{ftp_file.entry_name}' from ftp location '#{parent_directory}#{current_directory}'"

  end
end

puts "processing of log files from '#{ftp_user}' directory on ftp_server '#{ftp_server}' is complete"
$log.info "processing of log files from '#{ftp_user}' directory on ftp_server '#{ftp_server}' is complete"
exit
