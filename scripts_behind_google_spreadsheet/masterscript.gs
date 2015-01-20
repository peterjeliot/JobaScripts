function bulkSend() {

  var sheet = SpreadsheetApp.getActiveSheet();
  var data = sheet.getDataRange().getValues();
  var currentDate = new Date();
  for (var i = 1; i < data.length; i++) {
    if (data[i][3] === 0 && isValidTime(currentDate.getHours()) ) {
      var dataHash = rowHashify(data[i]);
      if (dataHash['useEmailAddress'] === 1) {
        sendCompanyEmail(dataHash);
        //mark the date the email was sent out
        SpreadsheetApp.getActiveSheet().getRange("L" + (i+1)).setValue(stringifiedCurrentDate());
      } else if (dataHash['useEmailAddress'] === 0) {
        saveCoverLetter(dataHash);
      }
        
      //change cell from 0 to 1 to indicate that the company has been emailed/cover letter created
      SpreadsheetApp.getActiveSheet().getRange("D" + (i+1)).setValue("1");
      //stop execution: 
      i = 10000000000;
    } else {
      //don't send email to company you've emailed
    }
  }
}

function sendCompanyEmail(dataHash) {
  var subject = createEmailSubject(dataHash);
  var body = createEmailBody(dataHash);
  var randomBool = Math.random() >= 0.5;
  
  //A/B test for photo in resume
  
  var randomNumber = Math.random() >= 0.5;
  if (randomNumber) {
    var resume = DriveApp.getFileById(RESUME);
  } else {
    var resume = DriveApp.getFileById(RESUMEPIC);
  }
  
  MailApp.sendEmail({
    to: dataHash['recipient'], 
    subject: createEmailSubject(dataHash), 
    htmlBody: body,
    attachments: [resume.getAs(MimeType.PDF)]
  });
}

function createEmailSubject(dataHash) {
  //parse job title
  var jobTitle = dataHash['jobTitle'] || "JS/Rails Web Developer";
  var companyCity = dataHash['companyCity'];
  return(jobTitle + " - " + companyCity);
}

function createEmailBody(dataHash) {
  
  var template = getCoverTemplate();
  //replace current date
  template = template.replace('{currentdate}', stringifiedCurrentDate());
  //replace company name
  template = template.replace('{company_name}', dataHash['companyName']);
  //replace company-specific blurb
  template = template.replace('{blurb_about_company}', dataHash['companyBlurb']);
  
  return(template);
}

function saveCoverLetter(dataHash) {
  var folder = DriveApp.getFolderById(FOLDER);
  folder.createFile(dataHash['companyName'] + ' ' + dataHash['jobTitle'] + '.html', createEmailBody(dataHash));
}

function rowHashify(dataRow) {
  var dataHash = {};

  dataHash['companyName'] = dataRow[0];
  dataHash['recipient'] = dataRow[2];
  dataHash['emailState'] = dataRow[3];
  dataHash['jobTitle'] = dataRow[6];
  dataHash['companyBlurb'] = dataRow[7];
  dataHash['companyCity'] = dataRow[8];
  dataHash['useEmailAddress'] = dataRow[10];
  return(dataHash);
}

function saturateListMaster() {
  terms = [{'l': 'rochester', 'q': 'ruby on rails'}, 
           {'l': 'los angeles', 'q': 'ruby on rails'}, 
           {'l': 'san francisco', 'q': 'ruby on rails'},
           {'l': 'santa monica', 'q': 'javascript'},
           {'l': 'san jose', 'q': 'ruby on rails'}]
  
  for (var i = 0; i < terms.length; i++) {
    saturateList(terms[i]);
    Logger.log("doing " + terms[i]['q'] + ", " + terms[i]['l']);
  }
}

function saturateList(options) {
  var indeedClient = new Indeed(3496951319319070);
  indeedClient.search({
    q: options['q'],
    l: options['l'],
    age: '1',
    userip: '1.2.3.4',
    useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)',
  }, function(searchResponse){
    //Logger.log(search_response);
    //search_response will be an xml string
    //from https://developers.google.com/apps-script/reference/xml-service/xml-service
    //Logger.log(search_response);
    Logger.log("test");
    var doc = XmlService.parse(searchResponse); //creates document object
    var root = doc.getRootElement(); //creates element object
    var results = root.getChild('results'); //creates another element object
    //Logger.log(results);
    var resultsArray = results.getChildren(); //creates an array of elements, the results of the search
    //to minimize http requests, only do first element of array while testing:
    //for (var i = 0; i < 1; i++) {
    for (var i = 0; i < resultsArray.length; i++) {
      //Logger.log(resultsArray[i]);
      var deep = resultsArray[i].getChildren();
      var outHash = {};
      //hashifies junk in xmldoc
      for (var j = 0; j < deep.length; j++) {
        outHash[deep[j].getName()] = deep[j].getValue();
      }
      
      //write the cells' content into my spreadsheet, figure out implementation later; pass the outHash to this function - this represents exactly one job search record

      writeToDoc(outHash);
    }
  });
}

//takes a hash returned by the Indeed API and writes these search results to new rows in my spreadsheet
function writeToDoc(hash) {
  hash['url'] = discoverTrueUrl(hash);
  //currentUrl is now the correct URI
  var followedPost = UrlFetchApp.fetch(hash['url'], {'followRedirects': true, 'muteHttpExceptions': true});
  hash['dump'] = followedPost.getContentText();
  //companyName	Link	recipient	submitted?	Effort Level	Last FollowUp	jobTitle	companyBlurb	companyCity	Comment	useEmailAddress	emailSentDate	fullListingContent
  var prettyDate = stringifiedCurrentDate();
  Logger.log(hash['url']);
  SpreadsheetApp.getActiveSpreadsheet().getSheets()[0].appendRow([hash['company'], hash['url'], "", 1, "Low", prettyDate, hash['jobtitle'], "", hash['formattedLocation'], "", 0, "", hash['dump']]);
}

function JECtest() {
  Logger.log(SpreadsheetApp.getActiveSpreadsheet().getSheets()[0]);
  SpreadsheetApp.getActiveSpreadsheet().getSheets()[0].appendRow(['fucking work','fucking work','fucking work','fucking work','fucking work','fucking work','fucking work','fucking work','fucking work','fucking work','fucking work','fucking work']);
}

//takes the url returned by the indeed api call and "fixes" it into something more useful
function indeedUrlPurify(url, delimiter) {
  var purifiedString = "";
  purifiedString = url.replace("viewjob?", "rc/clk?");
  //find the location of this value in the url: "&utm_source"
  var loc = url.indexOf(delimiter);
  purifiedString = purifiedString.substring(0, loc);
  purifiedString = purifiedString + "&from=vj&pos=bottom";
  return(purifiedString);
}

function urlHasIndeed(url) {
  if (typeof url === 'undefined') {
    return(false);
  }
  var temp = url.substring(url.indexOf("://") + 3, url.length);
  var domain = temp.substring(0, temp.indexOf("/") - 1);
  if (domain.indexOf("indeed") > -.1) {
    return(true);
  } else {
    return(false);
  }
}

function discoverTrueUrl(hash) {
  //hash is correct, url is being accessed
  var currentUrl = indeedUrlPurify(hash['url'], "&indpubnum=");
  //while loop to travel down redirection tree
  var containsIndeed = urlHasIndeed(currentUrl);
  //Logger.log(locIndeed);
  var counter = 0;
  //If containsIndeed, you have not discovered the true url
  while (counter < 5 && containsIndeed) {
    var followedPost = UrlFetchApp.fetch(currentUrl, {'followRedirects': false, 'muteHttpExceptions': false});
    currentUrl = followedPost.getHeaders()['Location'];
    containsIndeed = urlHasIndeed(currentUrl);
    counter++;
  }
  
  return(currentUrl);
}