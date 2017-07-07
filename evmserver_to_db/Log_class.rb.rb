=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: Log_class.rb.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
 

class Log_file 
  
  def initialize
    @file_name = nil
    @file_begin_time = nil
    @file_end_time = nil
    @file_size = nil
    @customer = nil
    @license_points = nil
    @license_type = nil
    @license_expires = nil
    @license_owner = nil
  end
end
    
    