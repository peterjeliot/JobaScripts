require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'faker'
require 'date'

# jobs2/view/38265883?trk=vsrp_jobs_res_name&trkInfo=VSRPsearchId%3A753023581420485345435%2CVSRPtargetId%3A38265883%2CVSRPcmpt%3Aprimary

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

# login_page = a.get("https://www.linkedin.com")

# splash_page = login_page.form_with(action: 'https://www.linkedin.com/uas/login-submit') do |f|
#   f.session_key = keys[:linkedin_username]
#   f.session_password = keys[:linkedin_password]
# end.click_button

def linkedin_job_apply(job_url, agent)
  #assume a headless agent has already been instantiated, assume correct linkedin job url, assume agent has already logged into linkedin
  # agent.get(job_url) do |page|
  agent.get('http://www.josephecombs.com/pages/specific_job_page.html') do |page|
    # apply-button onsite-apply
    apply_button = page.at(".apply-button")
    puts apply_button.class
    
    job_specific_modal_page = agent.click(apply_button)
    puts job_specific_modal_page.body
    #works, kind of:
    # job_button = page.search("/html[@class='os-mac']/body[@id='pagekey-jobs_view_job']/div[@id='body']/div[@class='wrapper hp-nus-wrapper']/div[@class='job-desc']/div[@class='main']/div[@id='top-card']/div[@class='top-row']/div[@class='content']/div[@id='apply-container']/div[@class='actions']/button[@class='apply-button onsite-apply']")
    # puts job_button.class
    # the allegedly correct query from xpath helper
    # puts page.search("/div[@class='actions']/button[@class='apply-button onsite-apply']").first.class
    # puts page.body
    # puts job_modal_page.body
    # #only 2 forms on the page, don't use forms method
    # page.forms.each do |form|
    #   puts form.name
    # end
    
    # #there are no frames, don't use frames method
    # page.frames.each do |frame|
    #   puts frame
    # end
    
    File.open('specific_job_page.html', 'w') { |file| file.write(page.body) }
    
    # puts page.links
    # page.forms.each do |form|
      # puts (form.button.methods - "a".methods).sort
      # puts form
      # puts form.button.name
    # end

    # application_modal_page = page.form_with(class: 'onsite-apply') do |search|
    #
    # end.submit

    # puts application_modal_page.body
  end
  
  # application_modal_page = agent.get(job_url)
  # application_modal_page = agent.get(job_url).form_with(class: 'apply-button').submit
  # puts (application_modal_page.methods - "a".methods).sort
  
  # puts application_modal_page.body

end

linkedin_job_apply("https://linkedin.com/jobs2/view/38265883?trk=vsrp_jobs_res_name&trkInfo=VSRPsearchId%3A753023581420485345435%2CVSRPtargetId%3A38265883%2CVSRPcmpt%3Aprimary", a)

