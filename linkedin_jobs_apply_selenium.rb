require 'selenium-webdriver'

def get_credentials(filename)
  temp_arr = []
  i = 0
  File.readlines(filename).each do |line, idx|
    temp_arr[i] = line.gsub!("\n","")
    i += 1
  end
  
  keys = {
    linkedin_username: temp_arr[0],
    linkedin_password: temp_arr[1],
    google_username: temp_arr[2],
    google_password: temp_arr[3],
  }
  
  keys
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

jobs_arr = [{a: 1}]

jobs_arr.each do |job_hash|

  browser.get("https://www.linkedin.com/jobs2/view/12577889?trk=vsrp_jobs_res_name&trkInfo=VSRPsearchId%3A753023581421196207716%2CVSRPtargetId%3A12577889%2CVSRPcmpt%3Aprimary")

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
    puts apply.class
  end
  
  sleep 3
  
  upload_link = wait.until do
    element = browser.find_element(:class, "upload-button")
    element if element.displayed?
  end
  
  sleep 2
  
  # upload_link.click
  # upload_link = browser.find_element(:class, "upload-button")
  # upload_link.send_keys("/Users/jcombs/Desktop/JobaScripts/Joseph_Combs_Resume.pdf")
  
  resume_upload_button = wait.until do 
    element = browser.find_element(:class, "resume-file-input")
    element if element.displayed?
  end
    
  # resume_upload_button.click
  #####brings up the osx filepicker dialog
  # resume_upload_button = browser.find_element(:class, "resume-file-input")
  # resume_upload_button.send_keys("Joseph_Combs_Resume.pdf")
  
  # resume_input_field = wait.until do
  #   element = browser.find_element(:id, "resume-file-name")
  #   element if element.displayed?
  # end
  
  # send browser the correct filename
  resume_input_field = browser.find_element(:id, "resume-file-name")
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
  
  follow_check_box = browser.find_element(:id, "follow-company")
  follow_check_box.click
  
  final_submit_button = wait.until do 
    element = browser.find_element(:class, "apply-button")
    element if element.displayed?
  end
  
  final_submit_button = browser.find_elements(:class, "apply-button")[1]
  final_submit_button.click
  #signed_in

  # advanced_search = wait.until do
  #   element = browser.find_element(:id, "advanced-search")
  #   element if element.displayed?
  # end
  # advanced_search.click
  # sleep 2
  #
  #
  # # fill in search box
  # keywords = wait.until do
  #   element = browser.find_element(:id, "advs-keywords")
  #   element if element.displayed?
  # end
  # keywords.send_keys("ruby rails")
  #
  # title = wait.until do
  #   element = browser.find_element(:id, "advs-title")
  #   element if element.displayed?
  # end
  # title.send_keys("engineering")
  #
  # postal_code = wait.until do
  #   element = browser.find_element(:id, "advs-postalCode")
  #   element if element.displayed?
  # end
  # postal_code.send_keys("94103")
  #
  # distance = wait.until do
  #   element = browser.find_element(:id, "advs-distance")
  #   element if element.displayed?
  # end
  # distance.send_keys("10 ")
  #
  # search = wait.until do
  #   element = browser.find_element(:class, "submit-advs")
  #   element if element.displayed?
  # end
  # search.click
  # sleep 2
  #
  # # collect urls of all people on each page
  # profile_urls = []
  #
  # profile_links = browser.find_elements(:css, "ol#results a.title")
  # profile_links.each { |link| profile_urls << link.attribute("href") }
  #
  # # puts profile_urls
  # # do the same for the rest of the pages
  # pagination_urls = browser.find_elements(:css, ".pagination a")
  #       .map { |link| link.attribute("href") }
  #
  # pagination_urls.each do |url|
  #   browser.get url
  #   sleep 1
  #
  #   profile_links = wait.until do
  #     element = browser.find_elements(:css, "ol#results a.title")
  #     element if element.first.displayed?
  #   end
  #   profile_links.each { |link| profile_urls << link.attribute("href") }
  # end
  #
  # puts profile_urls
  #
  # profile_urls.each do |url|
  #   browser.get url
  #   sleep 2
end

