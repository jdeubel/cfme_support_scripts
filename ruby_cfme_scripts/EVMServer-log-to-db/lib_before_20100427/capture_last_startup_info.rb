=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_last_startup_info.rb 20242 2010-04-12 14:26:08Z thennessy $
=end
def capture_last_startup_info()
  good_startup_config = false
  good_input_file = false
  last_startup_config_info = File.new("last_startup.txt","r")               # instantioate last startup text file object
  input_file = File.new("evm.log","r")                                      # instantiate evm.log file object
  last_startup_config_csv = File.new("last_startup_config.csv","r")         # instantiate last startup config csv as file object

  while !good_startup_config
    log_line_in = last_startup_config_info.gets
    if /\[----\]/ =~ log_line_in then
      parsed_config_log_line = Parsed_log_line.new(log_line_in)
      config_start_time =parsed_config_log_line.log_datetime
      good_startup_config = true
#      last_startup_config_info.close
    end
  end
  while !good_input_file
    log_line_in = input_file.gets
    if /\[----\]/ =~ log_line_in then
      parsed_info_line = Parsed_log_line.new(log_line_in)
      evm_log_start_time = parsed_info_line.log_datetime
      good_input_file = true
      input_file.close
    end
  end
  puts "last_startup_txt start time is #{parsed_config_log_line.log_datetime_string}"
  puts "evm log begin time is #{parsed_info_line.log_datetime_string}"

  if evm_log_start_time + 180 < config_start_time then             #allow
    _use_evm_log_start_time = evm_log_start_time
    _using_log_start_time = true                                  # set to true if we are using the log time and not config time
#    last_startup_config_info.close                               # close las_statup.txt file - no longer needed
#    return                                                       # last startup occurs within this evm.log file - may be others before last
  else
    _use_evm_log_start_time = config_start_time
    _using_log_start_time = nil                                   # set to fals if we are using the config_start_time for this
   end

# OK, we are going to process the last_startup.txt file as the last known startup for this evm system,
  initialize_evm_startups_config                          # allocate initial $startups hash
# on return from call above the variable %startup_cnt has a value and
# can be used to index to the just created hash.  the value is probably zero,
# but use the varialbe just to be consistent

  while config_line_in = last_startup_config_csv.gets
    config_line_array = config_line_in.chomp.split(",")
    # [0] = evm server guid
    #[1]  = host name
    # [2] = appliance name
    # [3] = text string date and time
    # [4] = "|" separated configuration section identified
    # > 4 = all comma separated values of [4] above
    case config_line_in
    when /_EVM\|_Server_start_datetime,/ then
      if !_using_log_start_time then
      $Startups[$startup_cnt]["display_time"] = config_line_array[5]
      _time_parts = config_line_array[5].tr("/:","  ").split(" ")

      _worktime =  Time.gm(_time_parts[2],_time_parts[0],_time_parts[1],
              _time_parts[3],_time_parts[4],_time_parts[5]).to_f
      $Startups[$startup_cnt]["log_time"] = _worktime if $Startups[$startup_cnt]["log_time"] == nil
      else
        $Startups[$startup_cnt]["log_time"] = _use_evm_log_start_time
        $Startups[$startup_cnt]["display_time"] = Time.at(_use_evm_log_start_time).to_s
        $Startups[$startup_cnt]["log_datetime_string"] = Time.at(_use_evm_log_start_time).strftime("%m/%d/%Y %I:%M:%S")
      end
    when /_EVM\|evm_version,/ then
      if !_using_log_start_time then
      $Startups[$startup_cnt]["evm version"] =  config_line_array[5]
      $Startups[$startup_cnt]["evm_version"] = "EVM Version(" + config_line_array[5] + ") "
      else
        $Startups[$startup_cnt]["evm version"] = "unknown"
        $Startups[$startup_cnt]["evm_version"] = "unknown"
      end
    when /_EVM\|evm_build,/ then
      if !_using_log_start_time then
      $Startups[$startup_cnt]["build"] = config_line_array[5]
      $Startups[$startup_cnt]["evm_version"] = $Startups[$startup_cnt]["evm_version"] << "Build(" << config_line_array[5] << ")"
      $Log_build_id = $Startups[$startup_cnt]["build"]
    else
      $Startups[$startup_cnt]["build"] = "unknown"
      $Startups[$startup_cnt]["evm_version"] = "unknown"
      $Log_build_id = "unknown"
    end
    when /server\|role,/ then
      if !_using_log_start_time then
      $Startups[$startup_cnt]["role"] = config_line_array[5..-1].join(",")
      else
      $Startups[$startup_cnt]["role"] =  "unknown"
      end
    when /server\|zone/ then
      if !_using_log_start_time then
        $Startups[$startup_cnt]["zone"] = config_line_array[5]
      else
        $Startups[$startup_cnt]["zone"] = "unknown"
      end

    when /server\|host,/ then
      $Startups[$startup_cnt]["host"] = config_line_array[5]           # if we have a nost, then use it regardless
    when /server\|company,/ then
      $Startups[$startup_cnt]["company"] = config_line_array[5].tr('"'," ").strip        # if we have a company, then use it
                                                                                         # but strip out leading and trailing double-quotes
    when /server\|hostname,/ then
      $Startups[$startup_cnt]["hostname"] = config_line_array[5].tr('"'," ").strip       # if we have a hostname, then use it
    when /server\|name,/ then
      $Startups[$startup_cnt]["appliance name"] = config_line_array[5] # if we have an appliance name then use it
    when /_EVM\|Server_GUID,/ then
      $Server_GUID = config_line_array[5]
      $Startups[$startup_cnt]["server_guid"] = config_line_array[5]    #if we have a GUID then use it
    when /_EVM\|rails_environment/ then
      if !_using_log_start_time then
      $Startups[$startup_cnt]["rails environment"] = config_line_array[5]
      else
      $Startups[$startup_cnt]["rails environment"] = "unknown"
      end
    when /_EVM\|rails_version/ then
      if !_using_log_start_time then
      $Startups[$startup_cnt]["rails version"] = config_line_array[5]
      else
      $Startups[$startup_cnt]["rails version"] =  "unknown"
      end
=begin rdoc
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
    }
=end

    end


  end
    last_startup_config_info.close       if last_startup_config_info != nil  
end
