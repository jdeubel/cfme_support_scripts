=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: archive_active_process.rb 16920 2009-10-30 04:25:26Z thennessy $
=end


def archive_active_process(pid)
  if pid != nil then
        _pid_file = $active_processes[pid]["file_handle"]
        _pid_file.close if _pid_file
        $active_processes[pid]["file_handle"] = nil
        $active_processes[pid]["file_status"] = "closed"
        $all_process_archive << $active_processes[pid]
  end
        $active_processes.delete(pid)
end
