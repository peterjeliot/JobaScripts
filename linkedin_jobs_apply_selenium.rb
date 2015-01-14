require 'selenium-webdriver'
require './linkedin.rb'

jobs_arr = get_all_jobs
puts jobs_hash.last

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

  apply = wait.until do
    element = browser.find_element(:class, "onsite-apply")
    element if element.displayed?
  end
  
  sleep 3
  
  puts apply.class
  
  if apply
    puts "about to click!"
    apply.click
    sleep 2
    apply.click
  else
    #can't apply on linkedin, log this fact and go to next job
    jobs_arr[idx]["applied"] = false
    puts "can't apply via linkedin"
    next
    sleep 2
  end
  
  # upload_link = wait.until do
  #   element = browser.find_element(:class, "upload-button")
  #   element if element.displayed?
  # end
  
  # sleep 2
  
  # upload_link.click
  # upload_link = browser.find_element(:class, "upload-button")
  # upload_link.send_keys("/Users/jcombs/Desktop/JobaScripts/Joseph_Combs_Resume.pdf")
  
  # resume_upload_button = wait.until do
  #   element = browser.find_element(:class, "resume-file-input")
  #   element if element.displayed?
  # end
    
  # resume_upload_button.click
  #####brings up the osx filepicker dialog
  # resume_upload_button = browser.find_element(:class, "resume-file-input")
  # resume_upload_button.send_keys("Joseph_Combs_Resume.pdf")
  
  resume_input_field = wait.until do
    element = browser.find_element(:id, "resume-file-name")
    element if element.displayed?
  end
  
  # send browser the correct filename
  # resume_input_field = browser.find_element(:id, "resume-file-name")
  sleep 3
  browser.execute_script("arguments[0].type = 'visible'", resume_input_field)
  sleep 3
  resume_input_field.send_keys("Joseph_Combs_Resume.pdf")
  sleep 2
  
  # don't follow the company
  follow_check_box = wait.until do 
    element = browser.find_element(:id, "follow-company")
    element if element.displayed?
  end
  
  sleep 2
  
  # follow_check_box = browser.find_element(:id, "follow-company")
  follow_check_box.click
  
  final_submit_button = wait.until do 
    element = browser.find_element(:class, "apply-button")
    element if element.displayed?
  end
  
  sleep 2
  
  final_submit_button = browser.find_elements(:class, "apply-button")[1]
  final_submit_button.click
  
  sleep 1
  #log some information about successful execution
  jobs_arr[idx]["applied"] = false
  sleep 15
end

#do something to log what happened during execution
#ex: process_results(jobs_arr)
