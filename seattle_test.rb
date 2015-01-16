https://www.linkedin.com/jobs2/view/38496060?trk=vsrp_jobs_res_name&trkInfo=VSRPsearchId%3A753023581421280929284%2CVSRPtargetId%3A38496060%2CVSRPcmpt%3Aprimary

# from http://elementalselenium.com/tips/1-upload-a-file

# filename: upload.rb

require 'selenium-webdriver'
require 'rspec/expectations'
include RSpec::Matchers

def setup
  @driver = Selenium::WebDriver.for :firefox
end

def teardown
  @driver.quit
end

def run
  setup
  yield
  teardown
end

run do
  filename = 'some-file.txt'
  file = File.join(Dir.pwd, filename)

  @driver.get 'http://the-internet.herokuapp.com/upload'
  @driver.find_element(id: 'file-upload').send_keys file
  @driver.find_element(id: 'file-submit').click

  uploaded_file = @driver.find_element(id: 'uploaded-files').text
  expect(uploaded_file).to eql filename
end

# 1.) CLICK THE "UPLOAD A FILE" LINK