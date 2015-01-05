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

a = Mechanize.new
a.user_agent_alias= 'Mac Safari'

cleaned_jobs = []

a.get('https://www.linkedin.com/') do |page|
# a.get('http://www.josephecombs.com/') do |page|
  
  # login to linkedin
  
  login_page = a.get("https://www.linkedin.com")

  splash_page = login_page.form_with(action: 'https://www.linkedin.com/uas/login-submit') do |f|
    f.session_key = 'jec68@georgetown.edu'
    f.session_password = 'XXXXXXXXXXXX'
  end.click_button
  
  jobs_page = a.get("https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&openFacets=L,C&sortBy=DD&")

  # puts jobs_page.links

  # puts content_hash['content']['page']['voltron_unified_search_json']['search']['results']
  all_jobs_posted_today = true
  pages_scraped = 1
  
  #be kind to the folks at linkedin and only look at 4 pages of job results
  while all_jobs_posted_today && pages_scraped < 4 do
    voltron = jobs_page.search("#voltron_srp_main-content")
    # doc = Nokogiri::HTML(open('voltron.html'))
    # voltron = doc.css('#voltron_srp_main-content').to_s

    # fuck it, we'll do it live
    start_point = voltron.index("<!--{") + 4
    end_point = voltron.index("}-->")
  
    content_hash_text = voltron[start_point..end_point]
  
    content_hash = JSON.parse(content_hash_text)
    
    content_hash['content']['page']['voltron_unified_search_json']['search']['results'].each do |element|
      # puts element['job']
      puts "analyzing one job"
      # puts element['job']['fmt_postedDate']
      # puts Date.parse(element['job']['fmt_postedDate'])
      
      if Date.parse(element['job']['fmt_postedDate']) == Date.today
      # if (0..99).to_a.sample > 5
        puts "writing job to jobs hash"
        #cleaned_jobs.push(purify_job(element['job'])
        cleaned_jobs.push(element['job'])
        #for testing, find the terminating job listing with 5% probability
        #write only the job information you need into some hash, then dump that into a google doc
      else
        all_jobs_posted_today = false
      end
    end
    
    if all_jobs_posted_today
      jobs_page = jobs_page.link_with(title: "Next Page").click
      pages_scraped += 1
      puts "sleeping to not cause linkedin to ban me"
      sleep 16
    end
  end
  
  # File.open('pretty.json', 'w') { |file| file.write(content_hash) }
  # puts jobs_page.body
  #jobs_page.links.each do |link|
  #  text = link.text.strip
  #  next unless text.length > 0
  #  # puts text
  #  # puts link.href
  #end
end

puts "logged this many jobs into jobs hash: " + cleaned_jobs.length
