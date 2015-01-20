function doGet(e) { // change to doPost(e) if you are recieving POST data
  Logger.log("post function invoked");
  var ss = SpreadsheetApp.openById('14WPSo9XFXYpFnUEMqgrKcXh9HOEdMSdIPPyUp39RO4k');
  Logger.log(ss);
  var sheet = ss.getSheetByName("Sheet1");
  Logger.log(sheet);
  var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0]; //read headers
  Logger.log(headers)
  Logger.log(e.parameters)
  var nextRow = sheet.getLastRow(); // get next row
  var cell = sheet.getRange('a1');
  var col = 0;
  for (i in headers){ // loop through the headers and if a parameter name matches the header name insert the value
    if (headers[i] == "Timestamp"){
      val = new Date();
    } else if (headers[i] == "Link") { 
      if (e.parameter['linkedinJobId']) {
        val = "https://www.linkedin.com/jobs?viewJob=&jobId=" + e.parameter["linkedinJobId"];
      } else {
        val = e.parameter[headers[i]];
      }
    } else {
      val = e.parameter[headers[i]]; 
    }
    Logger.log(headers[i])
    cell.offset(nextRow, col).setValue(val);
    col++;
  }
  //http://www.google.com/support/forum/p/apps-script/thread?tid=04d9d3d4922b8bfb&hl=en
  var app = UiApp.createApplication(); // included this part for debugging so you can see what data is coming in
  var panel = app.createVerticalPanel();
  for( p in e.parameters){
    panel.add(app.createLabel(p +" "+e.parameters[p]));
  }
  app.add(panel);
  return app;
}