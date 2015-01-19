require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'faker'
require 'date'
require 'selenium-webdriver'
require 'area'

def get_next_page_url(content_hash)
  return content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL']
end

def write_to_google_doc(jobs_hash)
  puts "writing all the information into a google spreadsheet"
end

def purify_job(job_hash)
  #take all information about the job, then select only the attributes we want and return a simplified hash
  #simplified_hash
  job_hash
end

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
    github_username: temp_arr[4],
    github_password: temp_arr[5],
  }
  
  keys
end

def get_all_jobs(options)
  a = Mechanize.new
  a.user_agent_alias= 'Mac Safari'

  keys = get_credentials('config.txt')
  cleaned_jobs = []

  a.get('https://www.linkedin.com/') do |page|
  # a.get('http://www.josephecombs.com/') do |page|
  
    # login to linkedin
  
    login_page = a.get("https://www.linkedin.com")

    splash_page = login_page.form_with(action: 'https://www.linkedin.com/uas/login-submit') do |f|
      f.session_key = keys[:linkedin_username]
      f.session_password = keys[:linkedin_password]
    end.click_button

    country_code = options[:country_code]    
    if country_code == "us"
      zip = (options[:city].to_zip.sample if options[:city]) || (options[:zip_code] if options[:zip_code])  #|| 94103
    else
      zip = options[:zip_code]
    end
    days_ago = (options[:days_ago] if options[:days_ago]) || 1
    keywords = (options[:keywords] if options[:keywords]) || "Ruby on Rails"

    
    
    # Bay Area:
    # jobs_page = a.get("https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&rsid=753023581420172248465&openFacets=L,C&sortBy=DD&")
    current_url = "https://www.linkedin.com/vsearch/j?keywords=" + keywords + 
                          "&countryCode=" + country_code + "&postalCode=" + zip.to_s + 
                          "&orig=ADVS&distance=50&locationType=I&rsid=753023581420172248465&openFacets=L,C&sortBy=DD&"
    
    puts current_url
    sleep 1
    
    jobs_page = a.get(current_url)
    
    date_limit_adhered_to = true
    pages_scraped = 1
    jobs_scraped = 0
  
    #be kind to the folks at linkedin and only look at 4 pages of job results max
    while date_limit_adhered_to && pages_scraped < 15 do
    # while pages_scraped < 6 do

      # fuck it, we'll do it live
      start_point = jobs_page.body.index("<!--{") + 4
      end_point = jobs_page.body.index("}-->")
  
      content_hash_text = jobs_page.body[start_point..end_point]
  
      content_hash = JSON.parse(content_hash_text)
    
      content_hash['content']['page']['voltron_unified_search_json']['search']['results'].each do |element|
        # puts element['job']
        puts "analyzing one job"
        # puts element['job']['fmt_postedDate']
        # puts Date.parse(element['job']['fmt_postedDate'])
        # puts "does the comparison pass? "
        # puts (Date.parse(element['job']['fmt_postedDate']) >= (Date.today - (days_ago - 1))).to_s
        
        begin
          if Date.parse(element['job']['fmt_postedDate']) >= (Date.today - (days_ago - 1))
          # if Date.parse(element['job']['fmt_postedDate']) == Date.today
            jobs_scraped += 1
            puts jobs_scraped
            puts "wrote a job to the jobs_hash"
            #cleaned_jobs.push(purify_job(element['job'])
            blacklisted_companies = get_blacklisted_companies
            if !blacklisted_companies.include?(element['job']['fmt_companyName'])
              cleaned_jobs.push(element['job'])
            end
            puts element['job']['fmt_location']
            #for testing, find the terminating job listing with 5% probability
            #write only the job information you need into some hash, then dump that into a google doc
          else
            date_limit_adhered_to = false
          end
        rescue
          puts "element['job']['fmt_postedDate'] is nil for some reason"
          # puts element
        else

        end
      end
    
      if date_limit_adhered_to
        #most likely failure point
        # puts content_hash
        begin
          if content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL']
            puts content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL']
          end
        rescue
          puts "there are fewer than 25 results in the time period specified, and thusly there is no next page to go to"
          #so break out of the loop because if I don't do this it will be an infinte loop
          date_limit_adhered_to = false
        else
          jobs_page = a.get("https://www.linkedin.com" + content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL'])
        end

        # jobs_page = jobs_page.link_with(text: "Next >").click
        pages_scraped += 1
        puts "sleeping to not cause linkedin to ban me"
        sleep 10
      end
      
      # pages_scraped += 1
      # next_url = "https://linkedin.com/" + get_next_page_url(content_hash)
      # puts "about to get jobs at: " + next_url
      # puts "current number of jobs in cleaned_jobs: " + cleaned_jobs.length.to_s
      # jobs_page = a.get(next_url)
    end
  end
  
  cleaned_jobs
end

def process_results(jobs_arr)
  #do something to log what happened during execution
  agent = Mechanize.new
  login_page = agent.get("https://accounts.google.com")
  keys = get_credentials('config.txt')

  puts "about to 2factor into google and log all the jobs you didn't apply to, press enter to continue"
  junk = gets.chomp

  second_step_login_page = login_page.form_with(id: 'gaia_loginform') do |f|
    # puts (f.methods - "f".methods).sort
    f.field_with(:type => "email").value = keys[:google_username]
    f.field_with(:type => "password").value = keys[:google_password]
  end.submit

  second_step_login_page.form_with(id: 'gaia_secondfactorform') do |f|
    puts "enter your google 2-step code that was just texted to you:"
    textcode = gets.chomp
    f.field_with(:id => "smsUserPin").value = textcode
  end.submit
  
  blacklisted_companies = get_blacklisted_companies
  
  jobs_arr.each do |job_hash|
    ##record in jobberwocky:
    if !blacklisted_companies.include?(job_hash['fmt_companyName']) && !job_hash["applied"]
      write_to_google_spreadsheet(job_hash, agent)
    end
  end
end

def get_blacklisted_companies
  return ["CyberCoders", "Worldlink"]
end

# def write_to_jobberwocky
def write_to_google_spreadsheet(job_hash, agent)
  #agent is a Mechanize object
  #come back to this later
  # page = agent.post(
  #   'http://jobberwocky.appacademy.io/api/job_applications',
  #   {
  #     # company_name: job_hash['fmt_companyName']
  #     # "company_id" => 7193
  #   },
  #   {
  #     "X-CSRF-Token"=> xcsrf_token
  #   }
  # )
  
  #MAKE GET TO CORRECT URL REQUEST TO JOBBERWOCKY
  #companyName	Link	recipient	submitted	EffortLevel	LastFollowUp	jobTitle	companyBlurb	companyCity	Comment	useEmailAddress	emailSentDate
  
  #only write records where we didnt also apply, so:
  
  # sleep 2
  
  #testing only
  #no fing clue why testing will not work 
  # agent = Mechanize.new
  # login_page = agent.get("https://accounts.google.com")
  # keys = get_credentials('config.txt')
  #
  # second_step_login_page = login_page.form_with(id: 'gaia_loginform') do |f|
  #   # puts (f.methods - "f".methods).sort
  #   f.field_with(:type => "email").value = keys[:google_username]
  #   f.field_with(:type => "password").value = keys[:google_password]
  # end.submit
  
  # puts (agent.methods - "agent".methods).sort
    
  # second_step_login_page.form_with(id: 'gaia_secondfactorform') do |f|
  #   puts f.class
  #   puts "enter your google 2-step code that was just texted to you:"
  #   textcode = gets.chomp
  #   puts f.class
  #   f.field_with(:id => "smsUserPin").value = textcode
  # end.submit
  
  # puts agent.page.body
  
  # login_button = login_page.search(".rc-button-submit")[0]
  # login_button.click_button
  
  # puts splash_page.body
                                # "https://script.google.com/macros/s/AKfycbyDbn-qjWL_ZoAx3rr36CAoAwK9xe_AeafKgwQqhsAafhTPsN0/exec"
                                # "https://script.google.com/macros/s/AKfycbypIYX9V_N7mE6dbMPwjswBiJ28FMgmPap4f0_pBUY/dev"
  # work_motherfucker = agent.get("https://script.google.com/macros/s/AKfycbypIYX9V_N7mE6dbMPwjswBiJ28FMgmPap4f0_pBUY/dev?" +
  #   "companyName=" + "Cashflow Enterprisez, LLC" +
  #   "&linkedinJobId=" + "029834234" +
  #   "&recipient=" +
  #   "&submitted=" + "1" +
  #   "&EffortLevel=" + "Low" +
  #   "&LastFollowUp=" + "1/14/15" +
  #   "&jobTitle=" + "CEO" +
  #   "&companyBlurb=" +
  #   "&companyCity=" + "NW Washington, DC" +
  #   "&Comment=" +
  #   "&useEmailAddress=" + "0"
  # )
   
  agent.get("https://script.google.com/macros/s/AKfycbypIYX9V_N7mE6dbMPwjswBiJ28FMgmPap4f0_pBUY/dev?" +
    "companyName=" + job_hash['fmt_companyName'] +
    "&linkedinJobId=" + job_hash['id'].to_s +
    "&recipient=" +
    "&submitted=" + "1" +
    "&EffortLevel=" + "Low" +
    "&LastFollowUp=" + job_hash['fmt_postedDate'].to_s +
    "&jobTitle=" + job_hash['fmt_jobTitle'].to_s +
    "&companyBlurb=" + 
    "&companyCity=" + job_hash['fmt_location'].to_s +
    "&Comment=" + 
    "&useEmailAddress=" + "0"
  )
  
  sleep 1
end

# write_to_jobberwocky
# process_results([{'fmt_companyName' => 'JOE CORP'}])

# a.get('https://www.linkedin.com/') do |page|

# LEAVE THIS FOR LATER.  F JOBBERWOCKY
# browser = Selenium::WebDriver.for :firefox
# wait = Selenium::WebDriver::Wait.new(:timeout => 10)
# browser.get 'http://jobberwocky.appacademy.io/auth/github'
# sleep 3
# input_username = wait.until do
#   element = browser.find_element(:id, "login_field")
#   element
# end
# sleep 1
# input_password = wait.until do
#   element = browser.find_element(:id, "password")
#   element
# end
# sleep 1
# signin = wait.until do
#   element = browser.find_element(:name, "commit")
#   element
# end
#
# sleep 2
#
# input_username.send_keys(keys[:github_username])
# input_password.send_keys(keys[:github_password])
#
# sleep 2
#
# signin.click
#
# sleep 2
#
# sleep 15
#
# jobs_arr = get_all_jobs
#
# jobs_arr.each do |job_hash|
#   write_to_jobberwocky(job_hash, browser)
# end