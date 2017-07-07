=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: capture_evm_startup_config.rb 17314 2009-11-20 18:04:15Z thennessy $
=end
$startup_config = nil
require "vmdb_config_to_yaml_to_csv"
def capture_evm_startup_config(log_line)
  line_array = log_line.split("-- :")
  _payload = line_array[1]
  if $startup_config then
    $startup_config.puts "#{_payload}"
    vmdb_config_to_yaml_to_csv(_payload)
  end
end
