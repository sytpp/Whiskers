var dex;

$(document).ready(function(){

    $.ajax({

    	//the url for a feed
        url      : "http://api.nytimes.com/svc/search/v2/articlesearch.json?q=climate+change&sort=newest&api-key=39267edb3f0f924fb0ba75519790529d%3A18%3A71716214",

        dataType : "json", //json or jsonp
    }).success(function(d){
	

    	dex = d;

	console.log(dex);
     var arrayLength = d.response.docs.length;

for (var i = 0; i < arrayLength; i++) {
   // alert(myStringArray[i]);
    
    console.log(dex.response.docs[i].pub_date);
    $('#articles').append('<div class="col-md-3">' + '<img src="http://static01.nyt.com/' + dex.response.docs[i].multimedia[0].url + '" />'
    	+'<h4>' + dex.response.docs[i].headline.main +'</h4>' + '<p>' + dex.response.docs[i].snippet + '</p>' + '</div>' );
    //Do something
}  

    })

});

