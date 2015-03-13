=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: process_payload_word1.rb 19061 2010-02-10 21:08:27Z thennessy $
=end
def process_handsoap(x)
  capture_soap_data(x)
end
def process_Qtask(x)
end
def process_miqvimupdate_monitorupdates(x)

end
def process_miqpostgresql_log_db_stats(x)

end
def process_miqvimdatastore(x)

end
def process_miqviminventory(x)

end
def process_q_task_id(x)
  if /Q-task_id\((.*?)\)/ =~ x.payload_word1 then
    _task_uuid = $1                                           # get the uuid
    _miq_subcmd = x.payload.split(" ")[1]                   # get the second word from the payload and use that to parse thu
    case _miq_subcmd
    when /JOB\((.*?)\)/  then
    when /VMware\(VixDiskLib\)\:/ then
    else
      puts "#{__FILE__}:#{__LINE__}:unrecognized Q-task_id sub command -> #{x.inspect}"
    end

  end
end
def process_miq_general(x)
  if /MIQ\((.*?)\)/ =~ x.payload_word1 then
    _miq_cmd = $1
    case _miq_cmd
    when /VcRefresher[\-|\.]get_vm_data/ then
    when /log_db_stats/ then
    when /EmsRefreshHelper[\-|\.]update_relats/ then
    when /VcRefresher[\-|\.]refresh/ then
    when /save[\-|\.]vmmetadata/ then
    when /MiqServer[\-|\.]status_update/ then
    when /EventCatcher/ then
    when /event[\-|\.]raise_evm_event/ then
    when /MiqQueue[\-|\.]get/ then
    when /EmsRefreshHelper[\-|\.]save_vms_inventory/ then
#    when //

    else
      puts "#{__FILE__}:#{__LINE__}:unrecognized MIQ() sub command ->#{x.inspect}"
    end
  else
  end

end
def process_automationengine(x)
  return
end
def process_policyengine(x)
  return
end
def process_miqvimbroker_getmiqvim(x)
  return
end