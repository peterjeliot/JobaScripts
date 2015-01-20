function linkedinTest() {
  //var response = UrlFetchApp.fetch("http://www.linkedin.com/‎");
  
  //var headers = { "Authorization" : "Basic " + Utilities.base64Encode(USERNAME + ':' + PASSWORD) };
  //var headers = { "Authorization" : "Basic " + Utilities.base64Encode('jec68@georgetown.edu' + ':' + '=S.236Ut') };
  var payload = { 'session_key': 'jec68@georgetown.edu', 
                  'session_password': '=S.236Ut'
                  //'loginCsrfParam': '584d7c6d-fe83-4e65-80fb-bd593c217774'
                  //'csrfToken': 'ajax:3566915378081060214',
                  //'sourceAlias': '0_7r5yezRXCiA_H0CRD8sf6DhOjTKUNps5xGTqeX8EEoi',
                  //'client_ts': '1420175941099',
                  //'client_r': 'jec68@georgetown.edu:760868129:607596873:182780148',
                  //'client_output': '-403438012',
                  //'client_n': '760868129:607596873:182780148',
                  //'client_v': '1.0.1'
                };

  var params = {
    "method":"POST",
    "payload": payload
  };
  var response = UrlFetchApp.fetch("https://www.linkedin.com/uas/login-submit", params);
  //in here will be some token you can use to as part of payload to send request to undocumented search api
  var loginRespHeaders = response.getAllHeaders();
  //Logger.log(loginRespHeaders);
  
  var response2 = UrlFetchApp.fetch("https://www.linkedin.com/vsearch/j?keywords=Ruby%20on%20Rails&countryCode=us&postalCode=94103&orig=ADVS&distance=50&locationType=I&rsid=753023581420172248465&openFacets=L,C&sortBy=DD&");
  //Logger.log(response2.getAllHeaders());
  Logger.log(response2.getContentText())
}
