#Process vmstat output
ruby  "/home/jdeubel/projects/cfme_support_scripts/ruby_cfme_scripts/process_vmstat_output/vmstat_output.rb" vmstat_output.log 1>vmstat_output_sstdout.lst 2>&1