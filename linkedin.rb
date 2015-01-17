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
    
    
    zip = (options[:city].to_zip.sample if options[:city]) || (options[:zip_code] if options[:zip_code])  #|| 94103
    days_ago = (options[:days_ago] if options[:days_ago]) || 1
    keywords = (options[:keywords] if options[:keywords]) || "Ruby on Rails"
    
    
    # Bay Area:
    # jobs_page = a.get("https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&rsid=753023581420172248465&openFacets=L,C&sortBy=DD&")
    current_url = "https://www.linkedin.com/vsearch/j?keywords=" + keywords + 
                          "&countryCode=us&postalCode=" + zip.to_s + 
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
            cleaned_jobs.push(element['job'])
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
        puts content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL']
        jobs_page = a.get("https://www.linkedin.com" + content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL'])
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
  target = File.open("execution_log.log", 'w')
  
  a = Mechanize.new
  a.user_agent_alias= 'Mac Safari'

  keys = get_credentials('config.txt')
  
  #arrange your agent
  a.get('http://www.josephecombs.com/') do |page|

    # login to jobberwocky
    login_page = a.get("http://jobberwocky.appacademy.io/auth/github")

    # login_page.search("#login_field")
    splash_page = login_page.form_with(action: '/session') do |f|
      f.set_fields(:login => keys[:github_username])
      f.set_fields(:password => keys[:github_password])
    end.click_button
    
    # puts (a.methods - "a".methods).sort
    # puts a.cookies
    # puts splash_page.body
    
    xcsrf_token = splash_page.at('meta[@name="csrf-token"]')[:content]
    puts xcsrf_token
    
    jobs_arr.each do |job_hash|
      ##record in jobberwocky:
      write_to_jobberwocky(job_hash, xcsrf_token, a)
    end
  end
end

def write_to_jobberwocky(job_hash, xcsrf_token, agent)
  #agent is a Mechanize object

  page = agent.post(
    'http://jobberwocky.appacademy.io/api/job_applications', 
    {
      # company_name: job_hash['fmt_companyName']
      # "company_id" => 7193
    }, 
    {
      "X-CSRF-Token"=> xcsrf_token
    }
  )
end
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