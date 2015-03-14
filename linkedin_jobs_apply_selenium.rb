require 'selenium-webdriver'
require './linkedin.rb'

jobs_arr = []

setup_arr = [
  # {city: "Boston, MA", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "Washington, DC", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "Portland, OR", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  {city: "San Francisco, CA", keywords: "Sales", days_ago: 30, country_code: "us"},
  # {city: "San Jose, CA", keywords: "Ruby on Rails", days_ago: 30, country_code: "us"},
  # {city: "San Jose, CA", keywords: "JavaScript", days_ago: 30, country_code: "us"},
  {city: "San Francisco, CA", keywords: "Marketing", days_ago: 30, country_code: "us"},
  # {city: "Los Angeles", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "San Diego, CA", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "Rochester, NY", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "Chicago, IL", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "Seattle, WA", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "Denver, CO", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "Austin, TX", keywords: "Ruby on Rails", days_ago: 1, country_code: "us"},
  # {city: "New York City, NY", keywords: "Ruby on Rails", days_ago: 1, country_code: "us", zip_code: 10004},
  # {city: "Atlanta, GA", keywords: "Ruby on Rails", days_ago: 1, country_code: "us", zip_code: 30334},
  # {city: "Philadelphia, PA", keywords: "Ruby on Rails", days_ago: 1, country_code: "us", zip_code: 19123},
  # {city: "Melbourne, AUS", keywords: "Ruby on Rails", days_ago: 1, country_code: "au", zip_code: 3050},
  # {city: "Sydney, AUS", keywords: "Ruby on Rails", days_ago: 1, country_code: "au", zip_code: 2052},
  # {city: "London, UK", keywords: "Ruby on Rails", days_ago: 1, country_code: "gb", zip_code: "SE1"},
  # {city: "Toronto, Canada", keywords: "Ruby on Rails", days_ago: 1, country_code: "ca", zip_code: "M5H 3L5"},
  # {city: "Montreal, Canada", keywords: "Ruby on Rails", days_ago: 1, country_code: "ca", zip_code: "H2X 2S8"},
  # {city: "Vancouver, Canada", keywords: "Ruby on Rails", days_ago: 1, country_code: "ca", zip_code: "V5Z 3V6"},
  # {city: "Auckland, NZ", keywords: "Ruby on Rails", days_ago: 1, country_code: "nz", zip_code: "1023"}
]

setup_arr.each do |query_options_hash|
  puts "Now inspecting city: " + query_options_hash[:city]
  jobs_arr = jobs_arr + get_all_jobs(query_options_hash)
  puts "New jobs_arr length: " + jobs_arr.length.to_s
  puts "last element of jobs_arr: "
  puts jobs_arr.last
  sleep 10
end

# puts jobs_arr.last

# puts jobs_arr
puts jobs_arr.length

# sleep 150

#for 1-13-15 testing purposes only
93.times do
  jobs_arr.shift
end

keys = get_credentials('config.txt')

username = keys[:linkedin_username]
pword = keys[:linkedin_password]

browser = Selenium::WebDriver.for :firefox
browser.get 'https://linkedin.com'
wait = Selenium::WebDriver::Wait.new(:timeout => 10)

input_username = wait.until do
  element = browser.find_element(:id, "session_key-login")
  element if element.displayed?
end
input_username.send_keys(username)

input_password = wait.until do
  element = browser.find_element(:id, "session_password-login")
  element if element.displayed?
end
input_password.send_keys(pword)
sleep 2

signin = wait.until do
  element = browser.find_element(:id, "signin")
  element if element.displayed?
end
signin.click
sleep 2

jobs_arr.each_with_index do |job_hash, idx|

  browser.get("https://www.linkedin.com/" + job_hash["link_viewJob"])

  sleep 2
  begin
    apply = wait.until do
      element = browser.find_element(:class, "onsite-apply")
      element if element.displayed?
    end
  rescue
    #can't apply on linkedin, log this fact and go to next job
    jobs_arr[idx]["applied"] = false
    puts "can't apply via linkedin"
    next
    sleep 2
  else
    puts "about to click!"
    apply.click
    sleep 3
    apply.click
    sleep 1
  end
  
  sleep 3
  
  upload_link = wait.until do
    element = browser.find_element(:class, "upload-button")
    element if element.displayed?
  end

  sleep 2

  upload_link.click
  # upload_link = browser.find_element(:class, "upload-button")
  # upload_link.send_keys("/Users/jcombs/Desktop/JobaScripts/Joseph_Combs_Resume.pdf")
  
  res_file_link = wait.until do
    element = browser.find_element(:class, "resume-file-input")
    element
  end
  resume = File.open("sherry_zhou_resume.pdf")
  sleep 1
  res_file_link.send_keys(File.expand_path(File.dirname(resume)) + "/" + resume.path)
  sleep 1
    
  # resume_upload_button.click
  #####brings up the osx filepicker dialog
  # resume_upload_button = browser.find_element(:class, "resume-file-input")
  # resume_upload_button.send_keys("Joseph_Combs_Resume.pdf")
  
  # send browser the correct filename
  # resume_input_field = browser.find_element(:id, "resume-file-name")
  sleep 3
  # browser.execute_script("arguments[0].type = 'visible'", resume_input_field)
  sleep 2
  
  # don't follow the company
  begin
    follow_check_box = wait.until do 
      element = browser.find_element(:id, "follow-company")
      # element if element.displayed?
      element
    end    
  rescue
    puts "no 'follow company' link"
  else
    follow_check_box.click
  end

  sleep 2

  i = 0
  while final_submit_button = browser.find_elements(:class, "apply-button")[1]
    final_submit_button.click
    i += 1
    puts "just clicked submit button, times clicked = " + i.to_s
    sleep 5
  end
  
  sleep 1
  # final_submit_button = browser.find_elements(:class, "apply-button")[1]
  jobs_arr[idx]["applied"] = true  
  #log some information about successful execution

  sleep 9
end

process_results(jobs_arr)


