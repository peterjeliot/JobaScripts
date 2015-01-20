function bulkSend() {
  var sheet = SpreadsheetApp.getActiveSheet();
  var data = sheet.getDataRange().getValues();
  var currentDate = new Date();
  for (var i = 1; i < data.length; i++) {
    if (data[i][3] === 0 && isValidTime(currentDate.getHours()) ) {
      var dataHash = rowHashify(data[i]);
      //send email
      //sendCompanyEmail(data[i]);
      if (dataHash['useEmailAddress'] === 1) {
        sendCompanyEmail(dataHash);
        Logger.log("email sent to: " + dataHash['recipient'] + "for company " + dataHash['companyName'] );
      } else if (dataHash['useEmailAddress'] === 0) {
        saveCoverLetter(dataHash);
      }
        
      //change cell from 0 to 1 to indicate that the company has been emailed
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
  var resume = DriveApp.getFileById(RESUME);
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