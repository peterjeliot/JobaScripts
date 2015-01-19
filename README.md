JobaScripts
===========

Some Google Drive scripts which greatly reduce the pain of the job hunt.

Note
===========
The linkedin stuff you see is completely experimental.  The setup should still work in exactly the same way to get things working in Google scripts.

Setup
===========
1.  Create a directory in Google Drive for this project.
2.  Create a spreadsheet with columns roughly corresponding to what is being done in the rowHashify function.
3.  Create a generic cover letter in a google doc.  Take note of the way interpolation is performed in *createEmailBody()*
4.  Convert the google doc to html: File --> Download as --> HTML.
5.  Convert that html file into one that uses all inline styling (gmail strips out style tags).  Use <http://premailer.dialect.ca/>.
6.  In the spreadsheet created in step 2: Tools --> Script Editor --> New Project.
7.  Copy and paste the contents of the .gs files in this repo to the same relative paths (painful, I know see here if you also find this painful. <http://stackoverflow.com/a/13427099/1730388>).
8.  Upload a pdf of your resume to Google Drive.
9.  Change the global variables in helpers.gs to the correct values to refer to your file.
10. Add some test data to the spreadsheet.  **Start out by making yourself the recipient.**
11. Back in the code editor, Run --> bulkSend.  You should get an email with your coverletter and resume attached!
12. When testing is complete and everything has been thoroughly proofread, click the clock icon to create an hourly trigger for bulkSend.  Now you can focus on finding job postings and customizing your cover letter.

Use at your own discretion!!