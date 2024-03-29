=begin rdoc
$Id: initialize_evm_startups_config.rb 17314 2009-11-20 18:04:15Z thennessy $

=end
def initialize_evm_startups_config
    if $startup_cnt == nil then 
      $startup_cnt = 0
    else 
      $startup_cnt += 1 if !$Parsed_log_line.startup_incremented
      $Parsed_log_line.startup_incremented = true
    end
#    if $Parsed_log_line.class.to_s != "Hash" then
#      puts "#{__FILE__}:#{__LINE__}->#{$Parsed_log_line.inspect}"
#    end
    if $Parsed_log_line.class.to_s == "Parsed_log_line" then
      _log_time = $Parsed_log_line.log_datetime
      _work_time_string = $Parsed_log_line.log_datetime_string.split(".")[0]
    else 
      _log_time = ""
      _work_time_string = ""
    end
#    $Startups[$startup_cnt] = {"count" => $startup_cnt, "log_time" => _log_time,
#      "display_time" => "",
##      "category" => "uninitialized",
##      "subcategory"=> "uninitialized",
##      "ip_address"=> "uninitialized",
#      "role" => "uninitialized",
#      "zone" => "uninitialized",
#      "host" => "uninitialized",
#      "hostname" => "uninitialized",
#      "company" => "uninitialized",
#      "db username" => "uninitialized",
#      "server_guid" => "uninitialized",
#      "db mode" => "uninitialized",
#      "db adapter" => "uninitialized",
#      "db database" => "uninitialized",
#      "db dsn" => "uninitialized",
#      "db max_connections" => "uninitialized",
#    }
    $Startups[$startup_cnt] = {"appliance name" => "uninitialized" ,
      "count" => $startup_cnt, 
      "company" => "uninitialized",       
      "db username" => "uninitialized", 
      "db mode" => "uninitialized",
      "db adapter" => "uninitialized", 
      "db database" => "uninitialized", 
      "db dsn" => "uninitialized",
      "db max_connections" => "uninitialized", 
      "display_time" => "uninitialized",
      "evmserver_table_startup_id" => "uninitialized",
      "evm_version" => "uninitialized",
      "host" => "uninitialized", 
      "hostname" => "uninitialized",
      "log_time" => _log_time,
      "log_datetime_string" => _work_time_string,
      "rails environment" => "uninitialized",      
      "rails version" => "uninitialized",
      "role" => "uninitialized",
      "server_guid" => "uninitialized",
      "zone" => "uninitialized",
      "processor count" => 0,
      "real memory" => 0,
      "swap memory" => 0,
      "processor speed" => 0,
      "Server id" => nil,
      "host ipaddress" => nil
    }
end