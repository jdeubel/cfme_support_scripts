# 
# Read_URL.rb
# 
# Created on Jan 8, 2008, 5:04:43 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
output = File.new("url_out.txt","w")
puts "Hello World"
require 'net/http'
page = "rubyforge.org"
h = Net::HTTP.start(page,80) do |http|
  response = http.get("/softwaremap/trove_list.php?form_cat=306")
  puts "Code = #{response.code}"
  puts "Message = #{response.message}"
  response.each {|key, val| printf "%-14s = %-40.40s\n", key, val }
#   puts response.body.inspect 
   output.puts(response.body)
#end
(2..127).each do |xx|
  response = http.get("/softwaremap/trove_list.php?form_cat=306&page=" + xx.to_s)
  output.puts(response.body)
end
end
#resp = h.get('/', nil)
#puts "#{resp.message}"
