require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'json'
require 'open-uri'

a = Mechanize.new
a.user_agent_alias= 'Mac Safari'

# a.get('https://www.linkedin.com/') do |page|
a.get('http://www.josephecombs.com/') do |page|

  # Submit the login form

  # login_page = a.get("https://www.linkedin.com")
  #
  # splash_page = login_page.form_with(action: 'https://www.linkedin.com/uas/login-submit') do |f|
  #   f.session_key = 'jec68@georgetown.edu'
  #   f.session_password = 'XXXXXXXXXXXX'
  # end.click_button
  
  #jobs_page = a.get("https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&rsid=753023581420172248465&openFacets=L,C&sortBy=DD&")
  # jobs_page = a.get("https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&openFacets=L,C&sortBy=DD&")

  #puts jobs_page.links
  #voltron = jobs_page.search("#voltron_srp_main-content")
  doc = Nokogiri::HTML(open('voltron.html'))
  voltron = doc.css('#voltron_srp_main-content').to_s

  start_point = voltron.index("<!--{") + 4
  end_point = voltron.index("}-->")
  
  content_hash_text = voltron[start_point..end_point]
  # puts content_hash_text
  
  content_hash = JSON.pretty_generate(JSON.parse(content_hash_text))
  
  puts content_hash[]
  #File.open('voltron.html', 'w') { |file| file.write(voltron) }
  # puts jobs_page.body
  #jobs_page.links.each do |link|
  #  text = link.text.strip
  #  next unless text.length > 0
  #  # puts text
  #  # puts link.href
  #end
end