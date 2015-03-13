# To change this template, choose Tools | Templates
# and open the template in the editor.

     def extract_selected_files(bundle,new_directory,selected_files)
          puts "#{__FILE__}:#{__LINE__} - #{selected_files.inspect}"
          cmd_line = '"c:\\program files\\7-zip\\7z" e ' + bundle + " -o.\\#{new_directory} #{selected_files}"
          puts "length of cmd_line is #{cmd_line.size}"
          extract_result = `#{cmd_line}`
          puts "#{__FILE__}:#{__LINE__}- #{cmd_line}\n\t#{extract_result}\n *** end of output \n\n"
     end