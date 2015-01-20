var Indeed = {};

(function(){
  
    Indeed = function(publisher){

        this.publisher = publisher;

        this.defaults = {'v': '2', 'format': 'json', 'publisher': this.publisher};

        this.endpoint = 'http://api.indeed.com/ads/apisearch';

        this.search = function(params, success){
            this.validate_params(params);

            for(var attr in this.defaults){params[attr] = this.defaults[attr];}
            
            //var queryString = "publisher=3496951319319070&q=ruby+on+rails&l=san+francisco%2C+ca&sort=&radius=20&st=&jt=fulltime&start=&limit=&fromage=1&filter=1&latlong=1&co=us&chnl=&userip=1.2.3.4&useragent=Mozilla/%2F4.0%28Firefox%29&v=2";
            var queryString = "publisher=" + this.publisher + 
              "&q=" + params['q'] +
              "&l=" + params['l'] +
              "&sort=&radius=20&st=&jt=fulltime&start=&limit=40&fromage=" + params['age'] +
              "&filter=1&latlong=1&co=us&chnl=&userip=1.2.3.4&useragent=Mozilla/%2F4.0%28Firefox%29&v=2";
            var url = this.endpoint + "?" + queryString;
            
            var response = UrlFetchApp.fetch( url );
            //var response = UrlFetchApp.fetch( this.endpoint, params ); 
            //Logger.log(response);
            success(response.getContentText());
            
            //$.ajax({
            //    url: this.endpoint,
            //    dataType: 'jsonp',
            //    type: 'GET',
            //    data: params,
            //    success: success
            //});
        };

        this.required_fields = ['userip', 'useragent', ['q', 'l']];

        this.validate_params = function(params){
            var num_required = this.required_fields.length;

            for(var i = 0; i < num_required; i++){
                var field = this.required_fields[i];
                if(field instanceof Array){
                    var num_one_required = field.length;
                    var has_one = false;
                    for(var x = 0; x < num_one_required; x++){
                        if(field[x] in params){
                            has_one = true;
                            break;
                        }
                    }
                    if(!has_one){
                        throw "You must provide one of the following " + field.join();
                    }
                }else if(!(field in params)){
                    throw "The field "+field+" is required";
                }
            }
        };

    };

})();