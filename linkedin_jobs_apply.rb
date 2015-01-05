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

login_page = a.get("https://www.linkedin.com")

splash_page = login_page.form_with(action: 'https://www.linkedin.com/uas/login-submit') do |f|
  f.session_key = keys[:linkedin_username]
  f.session_password = keys[:linkedin_password]
end.click_button

def linkedin_job_apply(job_url, agent)
  #assume a headless agent has already been instantiated, assume correct linkedin job url, assume agent has already logged into linkedin

  agent.get(job_url) do |page|
  
  end
end

linkedin_job_apply("https://linkedin.com/jobs2/view/38265883?trk=vsrp_jobs_res_name&trkInfo=VSRPsearchId%3A753023581420485345435%2CVSRPtargetId%3A38265883%2CVSRPcmpt%3Aprimary", a)

