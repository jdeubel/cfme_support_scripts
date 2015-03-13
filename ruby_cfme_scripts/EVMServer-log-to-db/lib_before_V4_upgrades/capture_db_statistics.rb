=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_db_statistics.rb 19061 2010-02-10 21:08:27Z thennessy $
=end
class DB_statistics
  attr_accessor :server_guid, :host_name, :appliance_name, :log_datetime, :startup, :pid, :db_type,:process_type, :actual_interval, :interval_size
  attr_accessor :total_db_seconds, :max_db_seconds, :request_count,:request_max_size,:request_total_size
  attr_accessor :response_count,:response_max_size,:response_total_size
  attr_accessor :connection_pool_size, :established_connections, :reserved_connections
    def initialize(payload)
    @server_guid = nil
    @host_name = nil
    @appliance_name = nil
    @log_datetime = nil
    @startup = nil
    @server_guid = $Startups[$startup_cnt]["server_guid"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["server_guid"].class.to_s != "NilClass"
    @host_name = $Startups[$startup_cnt]["hostname"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["hostname"].class.to_s != "NilClass"
    @appliance_name = $Startups[$startup_cnt]["appliance name"] if $Startups.class.to_s != "NilClass" && $Startups[$startup_cnt]["appliance name"].class.to_s != "NilClass"
    @log_datetime = $Parsed_log_line.log_datetime_string.split(".")[0] if $Parsed_log_line.class.to_s != "NilClass"
    @startup = $startup_cnt
    @db_type = nil
    @interval_size = nil
    @pid = nil
    @process_type = nil
    @actual_interval = nil
    @total_db_seconds = nil
    @max_db_seconds = nil
    @request_count = nil
    @request_max_size = nil
    @request_total_size = nil
    @response_count = nil
    @response_max_size = nil
    @response_total_size = nil
    @reserved_connections = nil
    @established_connections = nil
    @connection_pool_size = nil
    if /MIQ\((\S*)(\-|\.)log_db_stats\)/ =~ payload then
      @db_type = $1
    end
    @pid = $Parsed_log_line.log_pid
    @process_type = $active_processes[@pid]["process type"]
    if /interval\:\s*(\d*)\s*seconds,/ =~ payload then
      @interval_size = $1
    end
    if /last logged\:\s*(.*)\s*seconds ago/ =~ payload
      @actual_interval = $1
    end
    if /\(Sizes are estimated\)\s*(.*)/ =~ payload then
      _workstring = $1.tr("\{\}","  ")
      _work_array = _workstring.split(",")
      if _work_array.size > 0 then
        _work_array.each do |key_value|
          _split = key_value.split("=>")
            case _split[0]
            when /\:requests_total_size/ then @request_total_size  =_split[1]             
            when /\:response_max_size/ then @response_max_size  =_split[1]
            when /\:responses_total_size/   then @response_total_size  =_split[1]
            when /\:max_db_seconds/ then @max_db_seconds  =_split[1]
            when /\:db_seconds/   then @total_db_seconds  =_split[1]
            when /\:request_max_size/ then @request_max_size  =_split[1]
            when /\:responses/ then @response_count  =_split[1]
            when /\:requests/ then @request_count  =_split[1]
            when /\:connection_pool_size/ then @connection_pool_size = _split[1]
            when /\:reserved_connections/ then @reserved_connections = _split[1]
            when /\:established_connections/ then @established_connections = _split[1]
            else puts "#{__FILE__}:#{__LINE__}- unrecognized db_stats fragment '#{key_value}'"
            end
          end
        end
      end
    end
  end
#end
def capture_db_statistics(payload)
  #[----] I, [2009-11-03T20:12:24.651559 #5474]  INFO -- : 
  #MIQ(PostgreSQL-log_db_stats) interval: 60 seconds, last logged: 61.025588 seconds ago: (Sizes are estimated) 
  #{:requests_total_size=>63605, :request_max_size=>669, :responses=>347, :db_seconds=>0.23484468460083, :responses_total_size=>159385, 
  #:max_db_seconds=>0.0141680240631104, :response_max_size=>3156, :requests=>347}
  captured_stats = DB_statistics.new(payload)
  write_db_stats(captured_stats)
end
def write_db_stats(db_stats)
  x = db_stats
  if $db_stats == nil then
    db_stats_header = "server guid,hostname,appliance name,startup,log time,pid,worker type," +
                      "db type,interval size,actual interval,total db seconds, max db seconds," +
                      "request count,response count,request max size,response max size,request total size,response total size," +
                      "connection pool size,reserved connections,establishted connections"
    $db_stats = File.new($diag_dir  + "\\" + "db_statistics_"+ $base_file_name + ".csv","w")
    $db_stats.puts db_stats_header
  end
  $db_stats.puts "#{x.server_guid},#{x.host_name},#{x.appliance_name},#{x.startup},#{x.log_datetime},#{x.pid},#{x.process_type}," +
                 "#{x.db_type},#{x.interval_size},#{x.actual_interval},#{x.total_db_seconds},#{x.max_db_seconds}," +
                 "#{x.request_count},#{x.response_count},#{x.request_max_size},#{x.response_max_size},#{x.request_total_size},#{x.response_total_size}," +
                 "#{x.connection_pool_size},#{x.reserved_connections},#{x.established_connections}"
end