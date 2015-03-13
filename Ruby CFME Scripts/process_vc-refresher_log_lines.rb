=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_vc-refresher_log_lines.rb 24591 2010-11-08 15:45:16Z thennessy $
=end
$Hosts = Hash.new
$VMs = Hash.new
$Folders = Hash.new
$EMSs = Hash.new
$ResourcePools = Hash.new
$Storages = Hash.new
$DataCenters = Hash.new
$Clusters = Hash.new
$EMS_inventory = Array.new

class EMS_inventory
  attr_accessor :emsname, :server_guid, :server_name, :inventory_type, :count, :log_time, :startup, :pid, :zone, :emsid
  @emsname = nil
  @emsid = nil
  @server_guid = nil
  @server_name = nil
  @inventory_type = nil
  @log_time = nil
  @count = nil
  @pid = nil
  @zone = nil
  def initialize(log_line)
# MIQ(VcRefresher.get_vc_data) EMS: [Virtual Center (10.200.16.206)] Retrieving Storage inventory...Complete - Count: [83]
case log_line
    when /MIQ\(VcRefresher\.get_vc_data\)\s*EMS\:\s*\[(.*?)\]\,\s*id\:\s*\[(\d*)\]\s*Retrieving\s*(\S*)\s*inventory...Complete\s*\-\s*Count\:\s*\[(\d*)\]/ then
      @emsname = $1
      @emsid = $2
      @inventory_type = $3
      @count = $4
#      @log_time = $Parsed_log_line.log_datetime_string.split(".")[0]
#      @server_guid = $Startups[$startup_cnt]["server_guid"]
#      @server_name = $Startups[$startup_cnt]["hostname"]
#      @zone = $Startups[$startup_cnt]["zone"]
#      @startup = $startup_cnt
#      @pid = $Parsed_log_line.log_pid  
    when /MIQ\(VcRefresher\.get_vc_data\)\s*EMS\:\s*\[(.*?)\]\s*Retrieving\s*(\S*)\s*inventory...Complete\s*\-\s*Count\:\s*\[(\d*)\]/ then
      @emsname = $1
      @inventory_type = $2
      @count = $3
#      @log_time = $Parsed_log_line.log_datetime_string.split(".")[0]
#      @server_guid = $Startups[$startup_cnt]["server_guid"]
#      @server_name = $Startups[$startup_cnt]["hostname"]
#      @zone = $Startups[$startup_cnt]["zone"]
#      @startup = $startup_cnt
#      @pid = $Parsed_log_line.log_pid

    end
      @log_time = $Parsed_log_line.log_datetime_string.split(".")[0]
      @server_guid = $Startups[$startup_cnt]["server_guid"]
      @server_name = $Startups[$startup_cnt]["hostname"]
      @zone = $Startups[$startup_cnt]["zone"]
      @startup = $startup_cnt
      @pid = $Parsed_log_line.log_pid
end
end
def process_vc_refresher_log_lines(log_line)
#  if /Count\:/ =~ log_line then
#    puts "#{__FILE__}:#{__LINE__}"
#  end
#[----] I, [2009-04-08T01:34:00.593497 #4723]  INFO -- : Q-task_id([vc-refresher])
#MIQ(Vm-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating VM [RHEL-i386-Temp_2008.1.0] id: [39] location: [RHEL-i386-Temp_2008.1.0/RHEL-i386-Temp_2008.1.0.vmx] datastore id: [13] uuid: [502123d4-fcdd-662b-5f56-ac31f6879cd6]
#[----] I, [2009-04-08T01:34:04.214335 #4723]  INFO -- : Q-task_id([vc-refresher])
#MIQ(EmsFolder-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Folder [SI] id: [1]
#[----] I, [2009-04-08T01:34:04.884458 #4723]  INFO -- : Q-task_id([vc-refresher])
#MIQ(EmsCluster-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Cluster [TIC] id: [3]
#[----] I, [2009-04-08T01:34:05.753699 #4723]  INFO -- : Q-task_id([vc-refresher])
#MIQ(ResourcePool-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating ResourcePool [Tier2] id: [9]
#[----] I, [2009-04-08T01:34:16.504605 #4723]  INFO -- : Q-task_id([vc-refresher])
#MIQ(Storage-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Storage [ENGN-DMX0611-0C63] id: [16] location: [48dcb6d9-65688d9a-daee-001a6435f7ba]
#[----] I, [2009-04-08T01:34:16.602869 #4723]  INFO -- : Q-task_id([vc-refresher])
#MIQ(Host-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Host [cnwdcesxe007.tic.ca.kp.org] id: [6] hostname: [cnwdcesxe007.tic.ca.kp.org] IP: [10.233.39.239]
#[----] I, [2009-04-08T01:29:39.138995 #4723]  INFO -- : Q-task_id([vc-refresher])
#MIQ(EmsFolder-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Datacenter [HP Blades - Virtual Connect] id: [29]
# objective of this code is to capture all of the inventoried elements from VC so that it can be used to
# simplify analysis
# Inventory types: Datacenter,folders,clusters, resourcepool, storage, host  and VM
# data elements:
# type,EMS name, emsid,element name, element id, location, datastore id, uuid

#assume that log_line is identical to the already parsed $Parsed_log_line global variable
  _vmuuid = "_vmuuid"
  _vmdatastore ="_vmdatastore"
  _vmid = "_vmid"
  _vmlocation = "_vmlocation"
  _vmuuid = "_vmuuid"
  _emsname = "_emsname"
  _hostname = "_hostname"
  _hostid = "_hostid"
  _emsid = nil
#  if /Vm\-disconnect/ =~ $Parsed_log_line.payload then
#    puts "#{__FILE__}:#{__LINE__}- "
#  end
  case $Parsed_log_line.payload
  when /Duplicate unique values/ then return
  when /Since failures occurred/ then return

    # MIQ(VcRefresher.get_vc_data) EMS: [Virtual Center (10.200.16.206)] Retrieving Storage inventory...Complete - Count: [83]
  when /VcRefresher\.get_vc_data\)\s*EMS\:\s*\[(.*)?\]\s*Retrieving\s*(\S*)\s*inventory...Complete\s*.\s*Count\:\s*\[(\d*)\]/ then
    _temp = EMS_inventory.new($Parsed_log_line.payload)
    $EMS_inventory <<_temp
#    puts "#{__FILE__}:#{__LINE__}- #{_temp.inspect}"
  when /Vm\-disconnect_ems\)\s*Disconnecting Vm\s*\[(.*?)\]\s*id\s*\[(\d*)\]\s*from EMS\s*\[(.*?)\]\s*id\s*\[(\d*)\]/ then
#[----] I, [2009-04-30T03:56:55.369803 #11363]  INFO -- : Q-task_id([vc-refresher])
#MIQ(Vm-disconnect_ems) Disconnecting Vm [prod_test2] id [48] from EMS [Virtual Center (192.168.252.88)] id [1]
    _refresh_type = "disconnect_ems"
    _emsname = $3
    _vmname = $1
    _vmid = $2
    _emsid = $4
#            if _vmuuid == nil || _vmdatastore == nil || _vmlocation == nil || _vmid == nil ||
#            _vmuuid.size == 0 || _vmdatastore.size == 0  || _vmlocation.size == 0 || _vmid.size == 0  then
#          puts "missing key data from following VM\n\t#{log_line}"
#        else
#          if $VMs.has_key?(_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid) then
#            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
#            #if we have captured this, then we are done
#          else
            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $Parsed_log_line.log_datetime_string] =  {
              "servername" => $Startups[$startup_cnt]["hostname"],
              "server_guid" => $Startups[$startup_cnt]["server_guid"],
              "startup" => $startup_cnt,
              "vmname" =>_vmname,
              "emsname" => _emsname,
              "emsid" => _emsid,
              "vmid" => _vmid,
              "vmlocation" => _vmlocation,
              "vmdatastore" => _vmdatastore,
              "vmuuid" => _vmuuid,
              "first_seen" => $Parsed_log_line.log_datetime_string,
              "last_seen" =>  $Parsed_log_line.log_datetime_string,
              "action" => _refresh_type,
              "hostname" => _hostname,
              "hostid" => _hostid
            }

#          end
#        end

    
  when /Vm\-disconnect_host\)\s*Disconnecting Vm\s*\[(.*?)\]\s*id\s*\[(\d*)\]\s*from Host\s*\[(.*?)\]\s*id\s*\[(\d*)\]/ then
 #[----] I, [2009-04-30T03:56:55.680030 #11363]  INFO -- : Q-task_id([vc-refresher]) 
#MIQ(Vm-disconnect_host) Disconnecting Vm [prod_test2] id [48] from Host [PE2.demo.manageiq.com] id [2]
      _vmname = $1
      _vmid = $2
      _hostname = $3
      _hostid = $4
      _refresh_type = "disconnect_host"
            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $Parsed_log_line.log_datetime_string] =  {
              "servername" => $Startups[$startup_cnt]["hostname"],
              "server_guid" => $Startups[$startup_cnt]["server_guid"],
              "startup" => $startup_cnt,
              "vmname" =>_vmname,
              "emsname" => _emsname,
              "emsid" => _emsid,
              "vmid" => _vmid,
              "vmlocation" => _vmlocation,
              "vmdatastore" => _vmdatastore,
              "vmuuid" => _vmuuid,
              "first_seen" => $Parsed_log_line.log_datetime_string,
              "last_seen" =>  $Parsed_log_line.log_datetime_string,
              "action" => _refresh_type,
              "hostname" => _hostname,
              "hostid" => _hostid
            }
   
when /Vm\-disconnect_storage\)\s*Disconnecting Vm\s*\[(.*?)\]\s*id\s*\[(\d*)\]\s*from Datastore\s*\[(.*?)\]\s*id\s*\[(\d*)\]/ then
#[----] I, [2009-04-30T19:07:02.537381 #28652]  INFO -- : 
#MIQ(Vm-disconnect_storage) Disconnecting Vm [AAA-1] id [161] from Datastore [TestOpen-E0] id [8] 
   _vmname = $1
  _vmid = $2
  _datastorename = $3
  _datastoreid = $4
  _refresh_type = "disconnect_storage"
            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $Parsed_log_line.log_datetime_string] =  {
              "servername" => $Startups[$startup_cnt]["hostname"],
              "server_guid" => $Startups[$startup_cnt]["server_guid"],
              "startup" => $startup_cnt,
              "vmname" =>_vmname,
              "emsname" => _emsname,
              "emsid" => _emsid,
              "vmid" => _vmid,
              "vmlocation" => _vmlocation,
              "vmdatastore" => _vmdatastore,
              "vmuuid" => _vmuuid,
              "first_seen" => $Parsed_log_line.log_datetime_string,
              "last_seen" =>  $Parsed_log_line.log_datetime_string,
              "action" => _refresh_type,
              "hostname" => _hostname,
              "hostid" => _hostid
            }

when /(\.|\-)save_(\S*?)\_inventory/ then
=begin
Changes to vc-refresher introduced ~ end of april - attempting to isolate and process
[----] I, [2009-04-29T22:38:53.334140 #4853]  INFO -- : Q-task_id([vc-refresher])
MIQ(EmsRefreshHelper-save_hosts_inventory) EMS: [Virtual Center (192.168.252.88)] Updating Host [PE1.demo.manageiq.com] id: [3] hostname: [PE1.demo.manageiq.com] IP: [192.168.252.90]
[----] I, [2009-04-29T23:42:34.979512 #6324]  INFO -- : Q-task_id([vc-refresher])
MIQ(EmsRefreshHelper-save_storages_inventory) EMS: [Virtual Center (192.168.252.88)] Updating Storage [DemoVHD] id: [14] location: [482a9d81-46645c8e-d26b-001ec9baeee3]
[----] I, [2009-04-29T23:42:43.856375 #6324]  INFO -- : Q-task_id([vc-refresher])
MIQ(EmsRefreshHelper-save_vms_inventory) EMS: [Virtual Center (192.168.252.88)] Updating Vm [MIQ-2.1.0.21-86] id: [47] location: [MIQ-2.1.0.7-86/MIQ-2.1.0.7-86.vmx] storage id: [] uid_ems: [5021343d-15b9-05e0-2e15-1275092873b0]
=end  
#if /\-save_(\S*?)\_inventory/ =~ $Parsed_log_line.payload then
  _refresh_type = $2
  case _refresh_type
  when /ems/ then return
  when /snapshots/ then return
  when /event/ then return
  when /advanced/ then return
  when /hosts/ then
        _emsname = "emsname"
        _hostname = "hostname"
        _hostid = "hostid"
        _hostipaddress = "hostipaddress"
        _externalhostname = "externalhostname"
        _action = ""

#Q-task_id([vc-refresher]) MIQ(EmsRefreshHelper-save_hosts_inventory)
#EMS: [Virtual Center (10.30.65.35)] Processing Host: [host-2252] failed with error [Incomplete data from EMS]. Skipping Host.
      case $Parsed_log_line.payload
       when /EMS\:\s*\[(.*?)\]\,\s*id\:\s*\[(\d*)\]\s*(\S*)\s/ then
           _emsname = $1 if $1
          _action = $3 if $3
          _emsid = $2
          _work_array = $POSTMATCH.split("]")       
      when /EMS\:\s*\[(.*?)\]\s*(\S*)\s/ then
           _emsname = $1 if $1
          _action = $2 if $2
          _work_array = $POSTMATCH.split("]")

      end
#        if /EMS\:\s*\[(.*?)\]\s*(\S*)\s/ =~ $Parsed_log_line.payload then
#          _emsname = $1 if $1
#          _action = $2 if $2
          if _action == "Processing" then
            if /Host\:\s*\[(.*)\]\s+failed with error\s*\[(.*)\]\.\s*Skipping Host\./ =~ $Parsed_log_line.payload then
              _hostname = $1
              _externalhostname = $2
              _hostid = $2
              _hostipaddress = $2
            end
          else

#          _work_array = $POSTMATCH.split("]")
          _work_array.each do |element|
            case element
              when /Host\s*\[(.*)/ then _hostname = $1
              when /id\:\s+\[(.*)/ then _hostid = $1
              when /hostname\:\s+\[(.*)/ then _externalhostname = $1
              when /IP\:\s+\[(.*)/ then _hostipaddress = $1
            end
          end
          end
#        end

#       if /EMS\:\s*\[(.*?)\]\s*(.*)\s*Host \[(.*?)\] id\: \[(\d*)\] hostname\: \[(.*)\] IP\: \[(.*?)\]/ =~ $Parsed_log_line.payload then
#          _emsname = $1 if $1
#          _action = $2 if $2
#          _hostname = $3 if $3
#          _hostid = $4 if $4
#          _externalhostname = $5 if $5
#          _hostipaddress = $6 if $6
#          _hosts_action = "Updating"
#       end
#       if /EMS\:\s*\[(.*?)\]\s*(.*)\s*Host \[(.*?)\]\s*hostname\: \[(.*)\] IP\: \[(.*?)\]/ =~ $Parsed_log_line.payload then
#          _emsname = $1 if $1
#          _action = $2 if $2
#          _hostname = $3 if $3
#          _hostid = ""
#          _externalhostname = $4 if $4
#          _hostipaddress = $5 if $5
#       end
#          if /" 2009 04 27 16 20 55 119000/ =~ $Parsed_log_line.log_raw_datetime then
#            puts "#{__FILE__}:#{__LINE__}"
#          end
#          puts "#{__FILE__}:#{__LINE__}->#{$Parsed_log_line.inspect}"
#        if _hostname == "hostname" then
#          puts "#{__FILE__}:#{__LINE__}"
#        end
        if _hostid == "hostid" then _hostid = "" end
            if $Hosts.has_key?(_emsname + _hostname +  _externalhostname + _hostipaddress + $startup_cnt.to_s + _hostid) then
              $Hosts[_emsname + _hostname +  _externalhostname + _hostipaddress + $startup_cnt.to_s + _hostid]["last_seen"] = $Parsed_log_line.log_datetime_string
            else
              save_large_integer_value(_hostid)
              $Hosts[_emsname + _hostname +  _externalhostname + _hostipaddress + $startup_cnt.to_s + _hostid] = {
                "servername" => $Startups[$startup_cnt]["hostname"],
                "server_guid" => $Startups[$startup_cnt]["server_guid"],
                "startup" => $startup_cnt,
                "emsname" => _emsname,
                "hostname" => _hostname, "hostid" => _hostid, "externalhostname" => _externalhostname, "hostipaddress" => _hostipaddress,
                "first_seen" => $Parsed_log_line.log_datetime_string,
                "last_seen" => $Parsed_log_line.log_datetime_string,
                "action" => _action
              }
            end

#        end
  when /storages/ then
       _emsname = "emsname"
       _storagename = "storagename"
       _storageid = "storageid"
       _storagelocation = "storagelocation"
       case $Parsed_log_line.payload
#      if /EMS\:\s*\[(.*)?\],\s*\id\:\s*\[(.*)?\]\s*(.*)\s*Storage\[(.*)?\]\s*id\:\s*\[(\d*)\]\s*location\:\s*\[(.*)?\]/ =~ $Parsed_log_line.payload then
       when /EMS\:\s*\[(.*?)\]\,\s*id\:\s*\[(\d*)\]\s*(.*)\s*Storage\s*\[(.*?)\]\s*id\:\s*\[(\d*)\]\s*location\:\s*\[(.*?)\]/ then
        _emsname = $1 if $1
        _action = $3 if $3
        _storagename = $4 if $4
        _storageid = $5 if $5
        _storagelocation = $6 if $6

#       if /EMS\:\s*\[(.*?)\], id: [#]\s*(.*) Storage \[(.*?)\]\s*location\: \[(.*?)\]/ =~ $Parsed_log_line.payload then
       when /EMS\:\s*\[(.*?)\]\,\s*id\:\s*\[(\d*)\]\s*(.*)\s*Storage\s*\[(.*?)\]\s*location\:\s*\[(.*?)\]/ then
        _emsname = $1 if $1
        _action = $3 if $3
        _storagename = $4 if $4
        _storageid = ""
        _storagelocation = $5 if $5
#       if /EMS\:\s*\[(.*?)\]\s*(.*) Storage \[(.*?)\]\s*location\: \[(.*?)\]/ =~ $Parsed_log_line.payload then

       when /EMS\:\s*\[(.*?)\]\s*(.*) Storage \[(.*?)\]\s*location\: \[(.*?)\]/ then
        _emsname = $1 if $1
        _action = $2 if $2
        _storagename = $3 if $3
        _storageid = ""
        _storagelocation = $4 if $4
#       end       
#       end

#       if /EMS\:\s*\[(.*?)\]\s*(.*) Storage \[(.*?)\] id\: \[(\d*)\] location\: \[(.*?)\]/ =~ $Parsed_log_line.payload then
       when /EMS\:\s*\[(.*?)\]\s*(.*) Storage \[(.*?)\] id\: \[(\d*)\] location\: \[(.*?)\]/ then
        _emsname = $1 if $1
        _action = $2 if $2
        _storagename = $3 if $3
        _storageid = $4 if $4
        _storagelocation = $5 if $5   
       end


        if $Storages.has_key?(_emsname + _storagename +  _storagelocation + $startup_cnt.to_s + _storageid) then
#          puts "_emsname is #{_emsname.class}"
#          puts "_storagename is #{_storagename.class}"
#          puts "_storageid is #{_storageid.class}"
#          puts "_storagelocation is #{_storagelocation.class}"
#          puts "$Storages is #{$Storages.class}"
#          puts "$Parsed_log_line is #{$Parsed_log_line.class}"
#          $Storages[_emsname + _storagename + _storageid + _storagelocation + $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
          $Storages[_emsname + _storagename + _storagelocation + $startup_cnt.to_s + _storageid]["last_seen"] = $Parsed_log_line.log_datetime_string
        else
          save_large_integer_value(_storageid)
          $Storages[_emsname + _storagename +  _storagelocation + $startup_cnt.to_s+ _storageid] = {
            "servername" => $Startups[$startup_cnt]["hostname"],
            "server_guid" => $Startups[$startup_cnt]["server_guid"],
            "startup" => $startup_cnt,
            "emsname" => _emsname,
            "storagename" => _storagename,
            "storageid" => _storageid,
            "storagelocation" => _storagelocation,
            "first_seen" => $Parsed_log_line.log_datetime_string,
            "last_seen" => $Parsed_log_line.log_datetime_string,
            "action" => _action
          }
        end

#      end
  when /vms/ then
    _emsname = "emsname"
    _vmname = "vmname"
    _vmid = "vmid"
    _vmlocation = "vmlocation"
    _vmdatastore = "vmdatastore"
    _vmuuid = "vmuuid"
#EMS: [Virtual Center (192.168.252.88)] Updating Vm [MIQ-2.1.0.21-86] id: [47] location: [MIQ-2.1.0.7-86/MIQ-2.1.0.7-86.vmx] storage id: [] uid_ems: [5021343d-15b9-05e0-2e15-1275092873b0]
      case $Parsed_log_line.payload
      when /EMS\:\s*\[(.*?)\]\,\s*id\:\s*\[(\d*)\]\s*(\S*)\s*(Vm|Vms)\s*/ then
        _emsname = $1 if $1
        _emsid = $2 if $2
        _refresh_action = $3 if $3
        _remainder = $POSTMATCH
        save_large_integer_value(_emsid)
      when /EMS\:\s*\[(.*?)\]\s*(\S*)\s*[Vm|Vms]\s*/ then
        _emsname = $1 if $1
        _refresh_action = $2 if $2
        _remainder = $POSTMATCH
      end
#      if /EMS\:\s*\[(.*?)\]\s*(\S*)\s*[Vm|Vms]\s*/ =~ $Parsed_log_line.payload then
#        _emsname = $1 if $1
#        _refresh_action = $2 if $2
#        _remainder = $POSTMATCH
#      end
        case _refresh_action
        when /Updating/ then
#Updating Storage [vmware_stpcx17_0112] id: [281] location: [498dbe8c-b79e238c-ba3a-0022191768dd]
          _action = "Updating"
          if /\[(.*?)\]\s*id\:\s*\[(\d*)\]\s*location\:\s*\[(.*?)\]\s*storage id\: \[(\d*)\] uid_ems\: \[(.{36})\]/ =~ _remainder then
            _vmname = $1 if $1
            _vmid = $2 if $2
            _vmlocation = $3 if $3
            _vmdatastore = $4 if $4
            _vmuuid = $5 if $5
          end
        when /Creating/ then
          _action = "Creating"
          if /\[(.*?)\]\s*location\:\s*\[(.*?)\]\s*storage id\:\s*\[(\d*)\] uid_ems\:\s*\[(.{36})\]/ =~ _remainder then
            _vmname = $1 if $1
            _vmid = "__"
            _vmlocation = $2 if $2
            _vmdatastore = $3 if $3
            _vmuuid = $4 if $4
          end
          if /\[(.*?)\]\s*location\:\s*\[(.*?)\]\s*storage id\:\s*\[(.*?)\]\s*uid_ems\:\s*\[(.*?)\]/ =~ _remainder then

            _vmname = $1 if $1 
            _vmlocation = $2 if $2 
            _storage_id = $3 if $3 
            _emsuid = $4 if $4
            save_large_integer_value(_storage_id)
          end
#Q-task_id([vc-refresher]) MIQ(EmsRefreshHelper-save_vms_inventory)
#EMS: [ChiDemo] Creating Vm [Anti-Spam1] location: [Anti-Spam_1/Anti-Spam.vmx] storage id: [] uid_ems: []
        when /Disconnecting/ then
        when /Processing/ then
          if /Incomplete data from EMS/ =~ $Parsed_log_line.payload
          then
          else 
             puts "#{__FILE__}:#{__LINE__}-> unrecognized vm action\n\t#{log_line}"
          end
       

=begin
 this begin-end block comments out the process for the Disconnecting type of log message
  if appeaers that this message may be very long and contain multiple vms which are enumerated in regular
  log messages which are exposed in the log, so trying to decypher this one is not necessary

          _action = "Disconnecting"
#          _remainder = ""
          if /\[\#\<(.*)/ =~ _remainder then
            _vm_info_vector = $1.split(",")
#<Vm id: 48, vendor: "vmware", format: nil, version: nil, name: "prod_test2",
#description: nil, location: "prod_test2/prod_test2.vmx", config_xml: nil,
#autostart: nil, last_sync_on: "2009-04-24 00:29:32", created_on: "2009-04-23 22:31:10",
#updated_on: "2009-04-29 22:37:32", storage_id: 1, guid: "721f09e0-3056-11de-a7d5-005056a12545",
#service_id: nil, ems_id: 1, last_scan_on: "2009-04-24 00:29:32", last_scan_attempt_on: "2009-04-23 23:48:45",
#host_id: 2, uid_ems: "50212ddc-4536-3b79-b4c5-3eac59f627bc", retires_on: nil, retired: false,
#boot_time: "2009-04-24 21:16:45", tools_status: "toolsNotRunning", paravirtualization: false,
#standby_action: "powerOnSuspend", custom_1: nil, custom_2: nil, custom_3: nil, custom_4: nil,
#custom_5: nil, custom_6: nil, custom_7: nil, custom_8: nil, custom_9: nil,
#power_state: "off", state_changed_on: "2009-04-29 18:26:55", previous_state: "on",
#connection_state: "connected", reserved: nil, last_perf_capture_on: "2009-04-29 22:00:43",
#blackbox_exists: nil, blackbox_validated: nil, registered: nil, busy: nil, smart: nil, owner: nil, retirement: nil
            _vm_info_vector.each do |_fragment|
                case _fragment
                when /Vm id\:\s*(\d*)/ then _vmid = $1
                when /name\:\s*\"(.*)\"/ then _vmname = $1
                when /location\:\s*\"(.*)\"/ then _vmlocation = $1
                when /storage_id\:\s*(\d*)/ then _vmdatastore = $1
                when /guid\:\s*\"(.*)\"/ then _vmuuid = $1
                when /host_id\:\s*(\d*)/ then _host_owning_id = $1

                end
            end

          end
=end
#        when /Duplicate unique values/ then        # for now take no action - not an issue in V4
        else
          puts "#{__FILE__}:#{__LINE__}-> unrecognized vm action\n\t#{log_line}"
        end
#      end
      
#      if /EMS\:\s*\[(.*?)\]\s*Updating Vm\s*\[(.*?)\]\s*id\:\s*\[(\d*)\]\s*location\:\s*\[(.*?)\]\s*storage id\: \[(\d*)\] uid_ems\: \[(.{36})\]/ =~ $Parsed_log_line.payload then
#        _emsname = $1
#        _vmname = $2
#        _vmid = $3
#        _vmlocation = $4
#        _vmdatastore = $5
#        _vmuuid = $6
#          end
        if _vmdatastore == nil || _vmdatastore.size == 0 then _vmdatastore = "__" end
        if _vmuuid == nil || _vmdatastore == nil || _vmlocation == nil || _vmid == nil ||
            _vmuuid.size == 0 || _vmdatastore.size == 0  || _vmlocation.size == 0 || _vmid.size == 0  then
          puts "missing key data from following VM\n\t#{log_line}"
        else
#          puts "#{__FILE__}:#{__LINE__}->emsname=#{_emsname.inspect},\n\tvmname =#{_vmname.inspect},\n\tvmid=#{_vmid.inspect}," +
#               "\n\tvmlocation=#{_vmlocation.inspect},\n\tvmdatastore=#{_vmdatastore.inspect},\n\tvmuuid=#{_vmuuid.inspect}," +
#               "parsed_log_line ->#{$Parsed_log_line.inspect}"
             if _vmname == nil then
               puts "#{__FILE__}:#{__LINE__} vc-refresh for vm has empty vm name"
             end
          if $VMs.has_key?(_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid) then
            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
            #if we have captured this, then we are done
          else
            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $startup_cnt.to_s] =  {
              "servername" => $Startups[$startup_cnt]["hostname"],
              "server_guid" => $Startups[$startup_cnt]["server_guid"],
              "startup" => $startup_cnt,
              "vmname" =>_vmname,
              "emsname" => _emsname,
              "vmid" => _vmid,
              "vmlocation" => _vmlocation,
              "vmdatastore" => _vmdatastore,
              "vmuuid" => _vmuuid,
              "hostname" => _hostname,
              "hostid" => _hostid,
              "first_seen" => $Parsed_log_line.log_datetime_string,     # eliminate fractional seconds as some external systems can't handle
              "last_seen"  => $Parsed_log_line.log_datetime_string,     # eliminate fractional seconds as some external systems can't handle
              "action" => _action
            }

          end
        end

#  when /EmsRefreshHelper\-save_(\S*)_inventory\) \s*/ then                         #just skip any processing for this one
  when /EmsRefresh(\.|Helper\-)save_(\S*)_inventory\)\s*/ then
    puts "found one"
  when /EmsRefreshHelper\-save_(\S*)_inventory\)\s*EMS\:\s*\[(.*?)\]\s*Updating (\S*)\s*\[(.*?)\]\s*id\:\s*\[(\d*)\]\s*(.*)/  then
   _refresh_type = $1
   _emsname = $2
   _targettype = $3
   _targetname = $4
   _targetid = $5
   case _refresh_type
   when /storages/ then
   when /vms/ then
   when /hosts/
   end
   #
#MIQ() EMS: [Virtual Center (192.168.252.6)] Saving EMS Inventory...'

#[----] I, [2010-01-24T10:28:07.971891 #18624]  INFO -- :
#MIQ(EmsRefreshHelper-save_hosts_inventory) EMS: [VI4VC] Updating Host [titan.galaxy.local] id: [7] hostname: [titan.galaxy.local] IP: [192.168.254.9]
#[----] I, [2010-01-24T10:28:08.363734 #18624]  INFO -- :
#MIQ(EmsRefreshHelper-save_vms_inventory) EMS: [VI4VC] Updating Vm [Xav Prod PG] id: [87] location: [Xav Prod PG/Xav Prod PG.vmx] storage id: [18] uid_ems: [500069f9-3788-7d21-e282-3ab46553c963]

#[----] I, [2010-01-24T10:28:07.968889 #18624]  INFO -- :
#MIQ(EmsRefreshHelper-save_storages_inventory) EMS: [VI4VC] Updating Storage [DemoVHD] id: [7] location: [4b3ac9e3-526a8d7c-6d93-000bcd6c5490]
  when /EmsRefreshHelper\-save_storages_inventory\)\s*EMS\:\s*\[(.*?)\]\s*Updating (\S*)\s*\[(.*?)\]\s*id\:\s*\[(\d*)\]\s*location\:\s*\[(.*?)\]/  then
    _refresh_type = "storages"
    _emsname = $1
    _storage_name = x

    when /EmsFolder/ then
#MIQ(EmsFolder-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Folder [SI] id: [1]
if /EMS\: \[(.*?)\] Updating Folder \[(.*?)\] id\: \[(\d*)\]/ =~ $Parsed_log_line.payload then
  _emsname = $1
  _foldername = $2
  _folderid = $3
  if $Folders.has_key?(_emsname + _foldername + _folderid + $startup_cnt.to_s) then
    $Folders[_emsname + _foldername + _folderid + $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
  else
    $Folders[_emsname + _foldername + _folderid + $startup_cnt.to_s] = {"emsname" => _emsname, "foldername" =>_foldername, "folderid" => _folderid,
      "first_seen" => $Parsed_log_line.log_datetime_string
    }
  end
end
    when /Vm/ then
      if /MIQ\(Vm\-save_ems_inventory\) EMS\:\s*\[(.*?)\]\s*Updating VM \[(.*?)\] id\: \[(\d*)\] location\: \[(.*?)\] datastore id\: \[(\d*)\] uuid\: \[(.{36})\]/ =~ $Parsed_log_line.payload then
        _emsname = $1
        _vmname = $2
        _vmid = $3
        _vmlocation = $4
        _vmdatastore = $5
        _vmuuid = $6
        if _vmuuid == nil || _vmdatastore == nil || _vmlocation == nil || _vmid == nil ||
            _vmuuid.size == 0 || _vmdatastore.size == 0  || _vmlocation.size == 0 || _vmid.size == 0  then
          puts "missing key data from following VM\n\t#{log_line}"
        end
          if $VMs.has_key?(_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $startup_cnt.to_s ) then
            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
            #if we have captured this, then we are done
          else
            $VMs[_emsname + _vmname + _vmid + _vmlocation + _vmdatastore + _vmuuid + $startup_cnt.to_s] =  {
              "servername" => $Startups[$startup_cnt]["hostname"],
              "server_guid" => $Startups[$startup_cnt]["server_guid"],
              "startup" => $startup_cnt,
              "vmname" =>_vmname,
              "emsname" => _emsname,
              "vmid" => _vmid,
              "vmlocation" => _vmlocation,
              "vmdatastore" => _vmdatastore,
              "vmuuid" => _vmuuid,
              "first_seen" => $Parsed_log_line.log_datetime_string
            }

          end
        end
#      end
    when /EmsCluster/ then
#MIQ(EmsCluster-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Cluster [TIC] id: [3]
      if /EMS\: \[(.*?)\] Updating Cluster \[(.*?)\] id\: \[(\d*)\]/ =~ $Parsed_log_line.payload then
        _emsname = $1
        _clustername = $2
        _clusterid = $3
        if $Clusters.has_key?(_emsname + _clustername + _clusterid + $startup_cnt.to_s) then
          $Clusters[_emsname + _clustername + _clusterid + $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
        else
          $Clusters[_emsname + _clustername + _clusterid + $startup_cnt.to_s] = {
          "servername" => $Startups[$startup_cnt]["hostname"],
          "server_guid" => $Startups[$startup_cnt]["server_guid"],
          "startup" => $startup_cnt,
          "emsname" => _emsname,
          "clustername" => _clustername, 
          "clusterid" => _clusterid,
          "first_seen" => $Parsed_log_line.log_datetime_string}
        end

      end
    when /Storage/ then
#MIQ(Storage-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Storage [ENGN-DMX0611-0C63] id: [16] location: [48dcb6d9-65688d9a-daee-001a6435f7ba]
#Updating Storage [vmware_stpcx17_0112] id: [281] location: [498dbe8c-b79e238c-ba3a-0022191768dd]
      if /EMS\:\s*\[(.*?)\]\s*Updating Storage \[(.*?)\] id\: \[(\d*)\] location\: \[(.*?)\]/ =~ $Parsed_log_line.payload then
        _emsname = $1
        _storagename = $2
        _storageid = $3
        _storagelocation = $4
        if $Storages.has_key?(_emsname + _storagename + _storageid + _storagelocation + $startup_cnt.to_s) then
          $Storages[_emsname + _storagename + _storageid + _storagelocation + $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
        else
          $Storages[_emsname + _storagename + _storageid + _storagelocation + $startup_cnt.to_s] = {
            "servername" => $Startups[$startup_cnt]["hostname"],
            "server_guid" => $Startups[$startup_cnt]["server_guid"],
            "startup" => $startup_cnt,
            "emsname" => _emsname,
            "storagename" => _storagename,
            "storageid" => _storageid,
            "storagelocation" => _storagelocation,
            "first_seen" => $Parsed_log_line.log_datetime_string
          }
        end

      end

    when /Host/ then
#MIQ(Host-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating Host [cnwdcesxe007.tic.ca.kp.org] id: [6] hostname: [cnwdcesxe007.tic.ca.kp.org] IP: [10.233.39.239]
if /EMS\:\s*\[(.*?)\] Updating Host \[(.*?)\] id\: \[(\d*)\] hostname\: \[(.*)\] IP\: \[(.*?)\]/ =~ $Parsed_log_line.payload then
  _emsname = $1
  _hostname = $2
  _hostid = $3
  _externalhostname = $4
  _hostipaddress = $5
  if $Hosts.has_key?(_emsname + _hostname + _hostid + _externalhostname + _hostipaddress+ $startup_cnt.to_s) then
    $Hosts[_emsname + _hostname + _hostid + _externalhostname + _hostipaddress+ $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
  else
    $Hosts[_emsname + _hostname + _hostid + _externalhostname + _hostipaddress + $startup_cnt.to_s] = {
      "servername" => $Startups[$startup_cnt]["hostname"],
      "server_guid" => $Startups[$startup_cnt]["server_guid"],
      "startup" => $startup_cnt,
      "emsname" => _emsname,
      "hostname" => _hostname,
      "hostid" => _hostid,
      "externalhostname" => _externalhostname,
      "hostipaddress" => _hostipaddress,
      "first_seen" => $Parsed_log_line.log_datetime_string
    }
  end
  
end
  when /ResourcePool/ then
#MIQ(ResourcePool-save_ems_inventory) EMS: [Virtual Center (10.233.71.130)] Updating ResourcePool [Tier2] id: [9]
    if /EMS\: \[(.*?)\] Updating ResourcePool \[(.*?)\] id\: \[(\d*)\]/ =~ $Parsed_log_line.payload then
      _emsname = $1
      _resourcepoolname = $2
      _resourcepoolid = $3
      if $ResourcePools.has_key?(_emsname + _resourcepoolname + _resourcepoolid+ $startup_cnt.to_s) then
        $ResourcePools[_emsname + _resourcepoolname + _resourcepoolid+ $startup_cnt.to_s]["last_seen"] = $Parsed_log_line.log_datetime_string
      else
        $ResourcePools[_emsname + _resourcepoolname + _resourcepoolid + $startup_cnt.to_s] = {
          "servername" => $Startups[$startup_cnt]["hostname"],
          "server_guid" => $Startups[$startup_cnt]["server_guid"],
          "startup" => $startup_cnt,
          "emsname" =>_emsname,
          "resourcepoolname" => _resourcepoolname,
          "resourcepoolid" => _resourcepoolid,
          "first_seen" => $Parsed_log_line.log_datetime_string
        }
      end

    end
  when /save_storage_files_inventory/ then  # since I don't know what to do with this, just catch it to prevent message in log
  when /save_networks_inventory/ then       # since I don't know what to do with this, just catch it to prevent message in log
  when /save_guest_applications_inventory/ then # since I don't know what to do with this, just catch it to prevent message in log
  when /save_disks_inventory/   then            # since I don't know what to do with this, just catch it to prevent message in log
  else
    puts "#{__FILE__}:#{__LINE__}-unrecognized ""vc-refresh""-type target \n\t=>'#{log_line}'"
  end

end
end
