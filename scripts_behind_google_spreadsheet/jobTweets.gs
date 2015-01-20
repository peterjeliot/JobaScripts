function getJobTweets() {
  var consumerKey = 'XXXXX'; // Register your app with Twitter.
  var consumerSecret = 'XXXXX'; // Register your app with Twitter.
  
  var oauthConfig = UrlFetchApp.addOAuthService('twitter');
  oauthConfig.setAccessTokenUrl(
      'https://api.twitter.com/oauth/access_token');
  oauthConfig.setRequestTokenUrl(
      'https://api.twitter.com/oauth/request_token');
  oauthConfig.setAuthorizationUrl(
      'https://api.twitter.com/oauth/authorize');
  oauthConfig.setConsumerKey(consumerKey);
  oauthConfig.setConsumerSecret(consumerSecret);
  
  // "twitter" value must match the argument to "addOAuthService" above.
  var options = {
      'oAuthServiceName' : 'twitter',
      'oAuthUseToken' : 'always'
  };
  
  var url = 'https://api.twitter.com/1.1/statuses/user_timeline.json';
  var response = UrlFetchApp.fetch(url, options);
  var tweets = JSON.parse(response.getContentText());
}