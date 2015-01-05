require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'faker'
require 'date'

def goto_next_page
  puts "clicked next page"
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
  }
  
  keys
end

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
  
  jobs_page = a.get("https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&rsid=753023581420172248465&openFacets=L,C&sortBy=DD&")
  # jobs_page = Nokogiri::HTML(open('https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&rsid=753023581420172248465&openFacets=L,C&sortBy=DD&'))

  # puts content_hash['content']['page']['voltron_unified_search_json']['search']['results']
  all_jobs_posted_today = true
  pages_scraped = 1
  jobs_scraped = 0
  
  #be kind to the folks at linkedin and only look at 4 pages of job results max
  while all_jobs_posted_today && pages_scraped < 3 do

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
      
      if Date.parse(element['job']['fmt_postedDate']) == Date.today
      # if true
        puts "writing job to jobs hash"
        jobs_scraped += 1
        puts jobs_scraped
        #cleaned_jobs.push(purify_job(element['job'])
        cleaned_jobs.push(element['job'])
        #for testing, find the terminating job listing with 5% probability
        #write only the job information you need into some hash, then dump that into a google doc
      else
        all_jobs_posted_today = false
      end
    end
    
    if all_jobs_posted_today
      #most likely failure point
      # puts content_hash
      puts content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL']
      jobs_page = a.get("https://www.linkedin.com" + content_hash['content']['page']['voltron_unified_search_json']['search']['baseData']['resultPagination']['nextPage']['pageURL'])
      # jobs_page = jobs_page.link_with(text: "Next >").click
      pages_scraped += 1
      puts "sleeping to not cause linkedin to ban me"
      sleep 10
    end
  end
end

puts cleaned_jobs[0]
puts cleaned_jobs.last
puts "logged this many jobs into jobs hash: " + cleaned_jobs.length.to_s