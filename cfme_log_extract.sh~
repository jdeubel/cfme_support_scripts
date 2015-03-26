#!/bin/bash
for i in $(ls production* | grep "gz$"); do gunzip $i; done; cat production.log* >> production_full.log
for i in $(ls evm* | grep "gz$"); do gunzip $i; done; cat evm.log* >> evm_full.log
for i in $(ls automation* | grep "gz$"); do gunzip $i; done; cat automation.log* >> automation_full.log


#Process top output
for i in $(ls top_output* | grep "gz$"); do gunzip $i; done; cat top_output.log* >> top_output_full.log
grep -iE "^(miqtop|top|swap|mem|cpu\(s\)|  PID|tasks)" top_output.log >top_summary_output.log
ruby "/home/jdeubel/projects/cfme_support_scripts/ruby_cfme_scripts/process_top_output/lib/process_top_output.rb" top_summary_output.log 1>top_output_sstdout.lst 2>top_output_stderr.lst
#ruby "/home/jdeubel/projects/cfme_support_scripts/ruby_cfme_scripts/process_top_output/lib/output_files_save.rb" top_summary_output.log

