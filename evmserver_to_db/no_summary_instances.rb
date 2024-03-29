=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: no_summary_instances.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def no_summary_instances(type,icnt,max,prnt_cnt)
  # this routine is intended to make sure that at least one message line
  # is produced in each of the severaly severity categories for log messages
  # created in the *_summary.log file.  If this is the last iteration for a severity
  # (i == max) and no print lines for this subgroup have been printed (prnt_cnt ==0)
  # then this message is printed for the severity group (type)
    $Error_summary_file.puts " No messages of type #{type} to report" if icnt == max && prnt_cnt == 0
end
