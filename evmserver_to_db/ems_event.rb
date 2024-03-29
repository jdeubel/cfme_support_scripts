=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: ems_event.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
class EMS_Event
	attr_accessor :event_type, :event_chainid, :event_process
	attr_accessor :event_ems_ip_address, :event_ems_userid, :event_server_name
	attr_accessor :event_server_guid, :event_server_startup, :event_log_time

  def initialize
    @event_type = nil
    @event_chainid = nil
    @event_process = nil
    @event_ems_ip_address = nil
    @event_ems_userid = nil
    @event_server_name = $Startups[$startup_cnt]["hostname"]
    @event_server_guid = $Startups[$startup_cnt]["server_guid"]
    @event_server_startup = $startup_cnt
    @event_log_time = $Parsed_log_line.log_datetime_string.split(".")[0]  # truncate fractional seconds

  end
end