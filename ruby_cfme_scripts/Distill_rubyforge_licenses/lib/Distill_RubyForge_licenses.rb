# 
# Distill_RubyForge_licenses.rb
# 
# Created on Jan 7, 2008, 1:55:50 PM
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
#NEWGEM_format = /^\s*(\d*)\.\s*([[:print:]])\s*\-\s*([[:print:]])/
require 'pp'
require 'csv'
Ruby_license_header = "Gem number,Gem name,Gem Description,Licenses,Ruby,BSD,GPLV2,GPLV3,APACHE,LGPL,ARTISTIC,OSI,PYTHON,MIT,Creative Commons"

# CONSTANTS BELOW ARE INTENDED TO ALLOW FOR SIMPLE ORDERING OF FIELDS INTO LICENSE ARRAY.
# CONVERION WILL BE THAT A NUMBER WILL BE ASSOCIATED WITH EACH CONSTANCE AS THE ARRAY INDEX
# AND THAT EACH CONSTANT NAME WILL TERMINATE WITH AN UNDERSCORE
license_array = Array.new
GEM_NAME_ = 1
GEM_DESCRIPTION_ = 2
GEM_LICENSES_ = 3
MIT_ = 13
RUBY_LICENSE_ = 4
APACHE_= 8
ARTISTIC_= 10
BSD_= 5
LGPL_ = 9
GPLV2_ = 6
GPLV3_ = 7
OSI_ = 11
PYTHON_ = 12
CREATIVE_COMMONS_ = 14
GEM_NUMBER_ = 0

NEWGEM_format = /^\s*(\d*)\.\s+(.*)\s\-\s(.*)/
Ruby_license = /Ruby License/
BSD_license = /BSD License/
Creative_common = /Creative Commons/
GPLV2 = /GNU General Public License \(GPL\) version 2/
GPLV3 = /GNU General Public License \(GPL\) version 3/
LGPL = /GNU Lesser General Public License \(LGPL\)/
Apache = /Apache Software License/
Python = /Python License/
MIT = /MIT\/X Consortium License/
Artistic = /Artistic License/
OSI = /OSI Approved/
Gem_separator = /^-----------------------------/
License_literal = /License:/

class RubyGem
#  accessor
  @@instance_count = 0
  @@partial_instance = nil
  @@license_count = nil
  def set_mit
    @MIT = 1
    @licenses += 1
  end  
  def get_MIT
    @MIT
  end
  def set_bsd
    @BSD = 1
    @licenses += 1
  end
  def get_BSD
    @BSD
  end
  def set_ruby_license
    @ruby_license = 1
    @licenses += 1
  end
  def get_RUBY
    @ruby_license   
  end
  def set_gplv2
    @GPLV2 = 1
    @licenses += 1    
  end
  def get_GPLV2
    @GPLV2
  end
  def set_gplv3
    @GPLV3= 1
    @licenses += 1    
  end
  def get_GPLV3
    @GPLV3
  end
  
  def set_lgpl
    @LGPL = 1
    @licenses += 1    
  end
  def get_LGPL
    @LGPL
  end
  def set_apache
    @Apache = 1
    @licenses += 1    
  end
  def get_APACHE
    @Apache
  end
  def set_python
    @Python = 1
    @licenses += 1    
  end
  def get_PYTHON
    @Python
  end
  def set_artistic
    @artistic = 1
    @licenses += 1    
  end
  def get_ARTISTIC
    @artistic
  end
  def set_OSI
    @OSI = 1
    @licenses += 1
  end
  def get_OSI
    @OSI
  end

  def set_creative_commons
    @creative_commons = 1
    @licenses += 1
  end
  def get_CREATIVE_COMMONS
    @creative_commons
  end
  def gem_number
    @gem_number
  end
  def licenses
    @licenses
  end
  def get_gem_name
    @gem_name
  end
  def get_gem_description
    @gem_description
  end

  def initialize(input) 
    if NEWGEM_format =~ input then
      @@instance_count += 1
      @gem_number = $1
      @gem_name = $2
      @gem_description = $3
      @licenses = 0
      @ruby_license = nil
      @GPLV2 = nil
      @GPLV3 = nil
      @Apache = nil
      @BSD = nil
      @artistic = nil
      @LGPL = nil
      @OSI = nil
      @creative_commons = nil
      @Apache = nil
      @Python = nil
      @MIT = nil
    end
    
    
  end
  def capture_license(input)
    
  end
end

# csv output file for ruby gems and license info
ruby_license_csv = CSV.open("ruby_gem_license.csv","w")
ruby_license_csv << Ruby_license_header.split(",")

gem = nil
line_cnt = 0
empty_line = 0
gems = Array.new
not_eof = true
active_gem = nil
parm_file_in = ARGV[0]
puts parm_file_in
gems_file = File.new(parm_file_in,'r')

gems_file.each do |inline|
#while inline = gems_file.gets # and gem.gem_number <> 522

#  if gem.instance_of?(RubyGem) and gem.gem_number == "522" then 
#    a = a
#  end
 inline.strip! # strip off trainling blanks
# next if inline.size < 5
#  inline.chomp!.strip if inline.size > 2
  if inline.size < 5 then 
    empty_line += 1
    if empty_line > 5 then not_eof = nil
    else
        empty_line = 0
     end
  end
  line_cnt += 1
  if Gem_separator =~ inline and active_gem then 
    gems.push(gem)
    active_gem = nil
#    gem.delete
    next
  end
  puts inline
   if NEWGEM_format =~ inline then
     gems.push(gem) if active_gem # if prior object not colledted then collect it now
     gem = RubyGem.new(inline)
     active_gem = true
   end
  if License_literal =~ inline then
    _split_line = Array.new
    _split_line = inline.split(":")
    _license_type = _split_line[1].split(",")
    if _license_type.size > 1 then
    puts _license_type.inspect
    end
    _license_type.each {|_x| 
      case _x
      when Ruby_license then gem.set_ruby_license
      when BSD_license then gem.set_bsd  
      when GPLV2 then gem.set_gplv2
      when GPLV3 then gem.set_gplv3
      when LGPL then gem.set_lgpl
      when Apache then gem.set_apache
      when MIT then gem.set_mit
      when Artistic then gem.set_artistic
      when OSI then gem.set_OSI
#      when Artistic then gem.set_artistic
      when Creative_common then gem.set_creative_commons
      when Python then gem.set_python
      else puts _x #{"unknown license =" #{_x}}
      end
    }
    if gem.licenses > 2 then
      a = a
    end
  end
end
# Make sure that all of the gems have been injected into the Gems array
  if active_gem then 
    gems.push(gem)
    active_gem = nil
#    gem.delete
  end
# now process each gem instance into a CSV file
gems.each { |egem|
  license_array[GEM_NAME_] = egem.get_gem_name
  license_array[GEM_DESCRIPTION_] = egem.get_gem_description
  license_array[GEM_LICENSES_] = egem.licenses
  license_array[MIT_] = egem.get_MIT  
  license_array[RUBY_LICENSE_] = egem.get_RUBY
  license_array[APACHE_] = egem.get_APACHE
  license_array[ARTISTIC_] = egem.get_ARTISTIC
  license_array[BSD_] = egem.get_BSD  
  license_array[LGPL_] = egem.get_LGPL
  license_array[GPLV2_] = egem.get_GPLV2
  license_array[GPLV3_] = egem.get_GPLV3
  license_array[OSI_] = egem.get_OSI
  license_array[PYTHON_] = egem.get_PYTHON
  license_array[GEM_NUMBER_] = egem.gem_number
  license_array[CREATIVE_COMMONS_] = egem.get_CREATIVE_COMMONS
#  license_array[CREATIVE_COMMONS_] = egem.
#  license_array[GEM_NAME] 
  ruby_license_csv << license_array
}
#pp gems