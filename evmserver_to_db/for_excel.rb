# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

=begin rdoc
$Id: for_excel.rb 16597 2009-10-12 15:36:47Z thennessy $

=end
def for_excel(time)
  if time == nil then 
    puts "\tvalue input to 'for_excel' method is not numeric or empty, returning 0"
    ""
  else
    (time/(24*3600)+ $Linux_era)
  end
end

