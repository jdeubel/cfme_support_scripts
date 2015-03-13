# To change this template, choose Tools | Templates
# and open the template in the editor.
=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: parse_proxy_call_ws_parms.rb 16597 2009-10-12 15:36:47Z thennessy $
the intent of this routine is to capture the host name of the ems and its
ip address so that it can be injected into the job_step records and later
used to identify the esx or evm server which is performing the scanning
input: string from (proxy-call_ws) used as paramater for web services call
output: updates -> needs to be defined.
=end
def parse_proxy_call_ws_parms(in_string)
  return_string = ""
  split_char = "\\n"
#  in_string = gets.in_file
   _index_string = in_string.index('vmScanProfiles:')
   if _index_string then
     in_string = in_string[1,_index_string]
   end
#   in_string = in_string
  _tmp_array1 = in_string.split(split_char)
  _ems_found = ''
  _host_found = ''
#  _skip_remainder = ''

  _tmp_array1.each do |n|

    case n.strip!
    when /ems\:/ then _ems_found = 1
    when /host\:/ then _host_found = 1
    when /\:hostname\:/ then
      _tmp_str1 = n.split
      if _host_found == 1 then
        return_string  = return_string + ",hostname: " + _tmp_str1[1]
      else
        if _ems_found == 1 then
          return_string = ",vmname: " + _tmp_str1[1]
#          $vmname = _tmp_str1[1]
        end
      end
    when /\:ipaddress\:/  then
       _tmp_str1 = n.split
       if _host_found == 1 then
         return_string = return_string + ",host_ipaddress: " + _tmp_str1[1]
#         $host_address = _tmp_str1[1]
       else
         if _ems_found == 1 then
           return_string = return_string + ",vm_ipaddress: " + _tmp_str1[1]
#           $vmaddress = _tmp_str1[1]
         end
       end
     end
    end
    return_string = return_string
  end

#  end
#in_file = File.open("full_marshalla.txt")
##File.open("full_marshalla.txt") do |f|
#  $hostname = ''
#  $host_address = ''
#  $vmname = ''
#  $vmaddress = ''
#  in_string = in_file.gets
#  puts "length of input line is #{in_string.size}"
#  parse_ws_call_parms(in_string)
#  puts "hostname is #{$hostname}\n host ip address is #{$host_address}\nvmname is #{$vmname}\nvm ip address is #{$vmaddress}"

#end

