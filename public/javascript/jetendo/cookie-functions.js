
(function($, window, document, undefined){
	"use strict";
	var zCookieTrackingObj={};
	var zCookieTrackingCount=0;
	var zCookieTrackingEnabled=false;
	function zTrackCookieChanges(){
		for(var i in zCookieTrackingObj){
			var t=zCookieTrackingObj[i];
			var value=zGetCookie(i);
			if(value !== t.value){
				t.value=value;
				t.callback(value);
			}
		}
	}

	function zWatchCookie(key, callback){
		zCookieTrackingObj[key]={
			callback:callback,
			value:zGetCookie(key)
		};
		zCookieTrackingCount++;
		if(!zCookieTrackingEnabled){
			zCookieTrackingEnabled=setInterval(zTrackCookieChanges, 1000);
		}
	}
	function zDeleteWatchCookie(key){
		delete zCookieTrackingObj[key];
		zCookieTrackingCount--;
		if(zCookieTrackingCount===0){
			clearInterval(zCookieTrackingEnabled);
			zCookieTrackingEnabled=false;
		}
	}
	function zGetCookie(key){
	    var currentcookie = document.cookie;
	    if (currentcookie.length > 0)
	    {
	        var firstidx = currentcookie.indexOf(key + "=");
	        if (firstidx !== -1)
	        {
	            firstidx = firstidx + key.length + 1;
	            var lastidx = currentcookie.indexOf(";",firstidx);
	            if (lastidx === -1)
	            {
	                lastidx = currentcookie.length;
	            }
	            return unescape(currentcookie.substring(firstidx, lastidx));
	        }
	    }
	    return "";
	}

	function zDeleteCookie(key,path){
		var path = ( typeof path != 'undefined' ) ? path : '';

		zSetCookie({key:key, value:"", path: path, futureSeconds:-1, enableSubdomains:false});
	}
	/* zSetCookie({key:"cookie",value:"value",futureSeconds:3600,enableSubdomains:false}); */
	function zSetCookie(obj){
		if(typeof obj !== "object"){
			throw("zSetCookie requires an obj like {key:'cookie'',value:'value',futureSeconds:60,enableSubdomains:false}.");
		}
		var dObj={futureSeconds:0,enableSubdomains:false,path:''};
		for(var i in obj){
			dObj[i]=obj[i];	
		}
		var newC=dObj.key+"="+escape(dObj.value);
		if(dObj.futureSeconds !== 0){
			var currtime=new Date();
			currtime = new Date(currtime.getTime() + dObj.futureSeconds*1000);
	         newC+=";expires=" + currtime.toGMTString();
		}
		if(dObj.enableSubdomains){
			newC+=";domain=."+window.location.hostname.replace("www.","").replace("secure.",""); 
		}
		if(dObj.path != '') {
			newC+=";path="+dObj.path;
		}
		document.cookie=newC;
	}
	window.zTrackCookieChanges=zTrackCookieChanges;
	window.zWatchCookie=zWatchCookie;
	window.zDeleteWatchCookie=zDeleteWatchCookie;
	window.zGetCookie=zGetCookie;
	window.zDeleteCookie=zDeleteCookie;
	window.zSetCookie=zSetCookie;
})(jQuery, window, document, "undefined"); 