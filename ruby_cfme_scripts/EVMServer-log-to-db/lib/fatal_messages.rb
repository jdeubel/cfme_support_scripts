=begin rdoc
Copyright 2008 ManageIQ, Inc
$Id: fatal_messages.rb 16597 2009-10-12 15:36:47Z thennessy $
=end
def fatal_messages(fatal_group)
  $Fatal_log.puts("****\n")
  fatal_group.each do|x|
    $Fatal_log.puts(x)
  end
  $Fatal_log.puts("****\n\n")
  log_line_summarize(fatal_group[0])
end
