=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: error_and_warning_assessment_table.rb 24591 2010-11-08 15:45:16Z thennessy $
=end
def error_and_warning_assessment_table(x)
  not_new = "   not_new"
  _info = "     info"
    case x
    when /undefined method \`hex\' for nil\:NilClass/ then _response = "!chunky!"
    when /MiqQueue Destroy/ then _response= "critical"
    when /vCenter may not be running/ then _response = "important"
    when /undefined method/ then _response = "important"
    when /Command \[scanmetadata\] failed after \[##.##\] seconds/ then _response = not_new
    when /timed out after #####.##### second/ then _response = not_new
    when /VM has a consolidate helper snapshot/ then _response = not_new
    when /VM already has an EVM snapshot/ then _response = not_new
    when /\<VIM\> MiqVimBroker\.getMiqVim\: failed to create new connection/ then _response = "important"
    when /Error\: No XML returned for category/ then _response = not_new
    when /has not responded in ####.### seconds, restarting worker/ then _response = not_new
    when /Uninitialized MFT Entry/ then _response = not_new
    when /Invalid MFT Entry/ then _response = not_new
    when /scan-delete_snapshot\: Operation failed due to concurrent modification by another operation/ then _response = "important"
    when /still running, skipping/ then _response = not_new
    when /Unsupported Win32 Eventlog format/ then _response = not_new
    when /Unable to process data for user account/ then _response = not_new
    when /get_file_content not supported through Virtual Center/ then _response = not_new
    when /preventing current process from proceeding due to policy failure/ then _response = not_new
    when /received 1205 response from sql server requesting a retry/ then _response = not_new
    when /being killed because it is not responding/ then _response = "important"
    when /No usage data found for specified options/ then _response = not_new
    when /Inventory data may be missing/ then _response = not_new
    when /Unable to find a root folder/  then _response = not_new
    when /Authentication failed for use/ then _response = not_new
    when /has been killed/ then _response = "important"
    when /No eligible proxies for VM/ then _response = not_new
    when /Synchronize\: No data found for/ then _response = not_new
    when /Unable to connect to data source, during reconnect!/ then _response = "important"
    when /Event Monitor Thread aborted/ then _response = "important"
    when /Connection refused/ then _response = not_new
    when /Event Type cannot be determined for TaskEvent/ then _response = not_new
    when /getaddrinfo\: Name or service not known/ then _response = not_new
    when /Queuing scan of storage \[(.*)?\] failed due to error/ then _responsse = not_new
    when /Exiting worker due to timeout error Worker exiting/ then _response = not_new
    when /Check that an EMS is running and has valid credentials/ then _response = not_new
    when /Win32EventLog: File not found/ then _response = not_new
    when /\[HTTPClient\:\:ConnectTimeoutError\]\: execution expired/ then _response = not_new
    when /The OS is in a pre-installed state/ then _response = not_new
    when /found in full directory scan/   then _response = _info
    when /File not found\:/ then _response = not_new
    when /broker is currently unavailable/ then _response = "important"
    when /signal discarded/ then _response = not_new
    when /invalid cursor/ then _response = "critical"
    when /Failed to resolve MOR/ then _response = not_new
    when /Login failed due to a bad username or password/ then _response = _info
    when /ODBC\:\:Error\: INTERN \(0\) \[RubyODBC\]Invalid handle/ then _response = not_new
    when /ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION/ then _response = not_new
    when /Action not supported for Datastore type \[NAS\]/ then _response = not_new
    when /no license data found!/ then _response = _info
    when /The EVM license is invalid, please upload a valid license file/ then _response = _info
    when /Unable to assign the following roles to a new server/ then _response = "important"
    when /failed to remove snapshot for VM/ then _response = "important"
    when /No active SmartProxies found to analyze this VM/ then _response = _info
    when /Error during disk unmounting for VM/ then _response = not_new
    when /Couldn't find MiqQueue with ID/ then _response = not_new
    when /Mongrel timed out this thread\: shutdown/ then _response = "critical"
    when /Duplicate unique value found/ then _responsse = "important"
    when / MiqBerkeleyDB\: Database header version is less than 8/ then _response = "important"
    when /dump format error \(unlinked\)/ then _response = not_new
    when /Class \[system\/process\] not found in MiqAeDatastore/ then _response = _info
    when /File is directory\:/ then _response = _info
    when /No root filesystem found/ then _response = not_new
    when /Ext4 is Not Supported/ then _response = not_new
    when /Name has already been taken/ then _response = _info
    when /execution expired  Method/ then _response = not_new
    when /No disk file/ then _response = _info
    when /Using filesystem configurations until MiqServer is known/ then _response = "  startup"
    when /Ext3 file system has errors/ then _response = not_new
    when /Reconnecting to database after error/ then _response = not_new
    when /Transaction \((.*)\) was deadlocked/ then _response = _info
    when /is larger than the maximum size supported by datastore / then _response = "datastore"
    when /MiqVimBroker is shutting down/ then _response = "!important"
    when /Connection to \[host\(via broker\)/ then _response = "important"
    when /Could not allocate space for object/ then _response = "critical"
    when /Event Type cannot be determined for TaskEvent/ then _response = _info
    when /not found in MiqAeDatastore/ then _response = _info
    when /failed credential verification with error/ then _response = "important"
    when /There are no snapshots available for this VM/ then _response = _info
    when /SSH connection failed/ then _response = "important"
    when /Could not determine RC script directory/ then _response = _info
    when /Alarm Event missing data required for evaluating Alerts, skipping. Full data/ then _response = _info
    when /scan-delete_snapshot\: execution expired/ then _response = "important"
    when /The VM does not have a valid connection state/ then _response = "important"
    when /scan-delete_snapshot: killed thread/ then _response = "critical"
    when /seconds, restarting worker/ then _response = "important"
    when /NoMethodError\: private method \`exec\' called'/ then _response = "critical"
    when /MemCacheError\: Value too large/ then _response = "critical"
    when /Stopping all workers/  then _response = "critical"
    when /Multiple rows found for the same timestamp/ then _response = not_new
    when /Disk file not found/ then _response = _info
    when /Garbage collection/ then _response = not_new
    when /Broker is not available/ then _response = "important"
    else
      _response = "        "
    end
end