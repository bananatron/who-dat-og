#//////////////
#// HELPERS //
#////////////
require 'nokogiri' #Not forever
require 'open-uri'

def getServerTime
  Firebase::ServerValue::TIMESTAMP
end

def getEmployees(org)
  $fb_root.get("/#{org}/employees").body
end

def getNames(org)
  getEmployees(org).map{|ii, oo| oo['name']}
end


def generateTest
  questions = []
  employees = getEmployees('hired')
  names = getNames('hired')

  employees.each do |id, employee|
    qq = employee
    qq['options'] = []
    qq['options'] << employee['name']
    qq['index'] = id

    until qq['options'].length == 6 do #Ensure no dups
      rand_name = names.sample
      qq['options'] << rand_name if !qq['options'].include? rand_name
    end
    qq['options'].shuffle!
    
    questions << qq #Should shuffle here or handle client side?
  end
  
  questions.shuffle!
end




def syncHiredEmployees 
  getHiredEmployees.each do |employee|
    $fb_root.push('/hired/employees', employee)
  end
end

def addEmployee(org, name, position, image, gender=false)
  employee = {'name'=>name, 'position'=>position, 'image'=>image }
  employee['gender'] = gender if gender
  $fb_root.push("/#{org}/employees", employee)
end


## Destined to be thrown away

def getHiredEmployees
  # This is kind of a rediculous way to get this data
  # and should probably be done via api call or upload-esque
  # form if it's a broader service used outside of Hired
  # (or both?)
  
  employees = [] #All employees
  about_url = 'https://hired.com/about'
  doc = Nokogiri::HTML(open(about_url))

  doc.css('.layout__item').each do | lli |
    if lli.children.count == 5
      ehh = {}
      ehh[:image] = lli.css('img').attr('src')
      ehh[:name] = lli.children[2].text
      ehh[:position] = lli.children[4].text
      employees << ehh 
    end
  end
  
  return employees
end



# def generateTestUri #Garbage
#   questions = []
  
#   employees = getHiredEmployees().shuffle! #{ :image, :name, :position }
#   names = employees.map { |emp| emp[:name] }
#   employees.each do |employee|
#     qq = employee
#     qq[:options] = names.sample(3)
#     qq[:options] << employee[:name]
#     questions << qq
#   end
# end