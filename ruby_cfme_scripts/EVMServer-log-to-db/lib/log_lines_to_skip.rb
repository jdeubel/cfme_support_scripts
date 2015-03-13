=begin rdoc
the object of this code routine is to examine each log line or line group and to determine if
there is a string in the first line of the group which indicates that the line should not be processed

there are a number of log lines which do not yield any useful information and need to be recognized and skipped
as soon as possible to allow overall processing speed to be as fast as possible

$Id: log_lines_to_skip.rb 24591 2010-11-08 15:45:16Z thennessy $

=end
def log_lines_to_skip(log_line)
  case log_line
      when /ERROR \-\-.\:/ then return false           # if the  log line is an ERROR then allow it to be processed
      when /WARN \-\-.\:/ then return false            # if the log line is a WARN type then allow it to be processed
      when /\<PolicyEngine\>/ then return true
#      when /\<AutomationEngine\>/ then return true
      when /\<AuditSuccess\>/ then return true
      when /MIQ\(MiqQueue.deliver\)/ then
        return true
#  when /MIQ\(Vm.perf_rollup/ then return true
  when /MIQ\(BottleneckEvent/ then return true
  else return false
  end
end
