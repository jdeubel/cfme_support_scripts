#Process top output
for i in $(ls top_output* | grep "gz$"); do gunzip $i; done; cat top_output.log* >> top_output_full.log
grep -iE "^(miqtop|top|swap|mem|cpu\(s\)|  PID|tasks)" top_output.log >top_summary_output.log
ruby "/home/jdeubel/projects/cfme_support_scripts/ruby_cfme_scripts/process_top_output/lib/process_top_output.rb" top_summary_output.log 1>top_output_sstdout.lst 2>top_output_stderr.lst
