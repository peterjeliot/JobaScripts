/*   
   Copyright 2011 Martin Hawksey

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
 
/* Usage
1. Run the setup function (you'll need to do this twice - 1st time to grant acces to Script Properties)
2. Share > Publish as service ... set security level and enable service
3. Copy the service URL and post this in your form/script action  
4. Insert column names on the DATA sheet matching the parameter names of the data you are passing
*/
 
function doPost(e) { // change to doPost(e) if you are recieving POST data
  var ss = SpreadsheetApp.openById('14WPSo9XFXYpFnUEMqgrKcXh9HOEdMSdIPPyUp39RO4k');
  var sheet = ss.getSheetByName("Sheet1");
  var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0]; //read headers
  var nextRow = sheet.getLastRow(); // get next row
  var cell = sheet.getRange('a1');
  var col = 0;
  for (i in headers){ // loop through the headers and if a parameter name matches the header name insert the value
    if (headers[i] == "Timestamp"){
      val = new Date();
    } else {
      val = e.parameter[headers[i]]; 
    }
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



function doGet(e) { // change to doPost(e) if you are recieving POST data
  var ss = SpreadsheetApp.openById(ScriptProperties.getProperty('active'));
  var sheet = ss.getSheetByName("DATA");
  var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0]; //read headers
  var nextRow = sheet.getLastRow(); // get next row
  var cell = sheet.getRange('a1');
  var col = 0;
  for (i in headers){ // loop through the headers and if a parameter name matches the header name insert the value
    if (headers[i] == "Timestamp"){
      val = new Date();
    } else {
      val = e.parameter[headers[i]]; 
    }
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
//http://www.google.sc/support/forum/p/apps-script/thread?tid=345591f349a25cb4&hl=en
function setUp() {
  ScriptProperties.setProperty('active', SpreadsheetApp.getActiveSpreadsheet().getId());
}
