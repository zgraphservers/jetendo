
var zContentTransition=new Object();

if(typeof zLocalDomains === "undefined"){
	var zLocalDomains=[];
}

(function($, window, document, undefined){
	"use strict";
	zContentTransition.transitionOverrideId=false;
	zContentTransition.processManually=false;
	zContentTransition.processManuallyResult="{}";
	zContentTransition.processManuallyRan=false;
	zContentTransition.manuallyProcessTransition=function(){
		zContentTransition.processManuallyRan=true;
		if(zContentTransition.processResultStored){
			zContentTransition.processResultStored=false;
			zContentTransition.processAjaxPageTransition(zContentTransition.processManuallyResult);
		}
	};
	// the problem is that animation is finishing before the ajax complete is called.
	zContentTransition.processAjaxPageTransition=function(d){
		if(zContentTransition.processManually && zContentTransition.processManuallyRan === false){
			zContentTransition.processResultStored=true;
			zContentTransition.processManuallyResult=d;
			return;	
		}
		var d2=document.body || document.documentElement;
		d2.style.overflow="auto";
		var d1={};
		try{
			d1=eval("("+d+")");
			if(typeof d1.forceReload === "undefined" || d1.forceReload){
				window.location.href=zContentTransition.lastURL;
			}
			$("#zContentTransitionContentDiv").html(d1.content);
		}catch(e){ 
			window.location.href=zContentTransition.lastURL;
		}
		var $target;
		if(zContentTransition.transitionOverrideId !== false){
			$target = $("#"+zContentTransition.transitionOverrideId);
		}else{
			$target = $("#zContentTransitionTitleSpan");
		}
		var pageNavElement = $("#zContentTransitionPageNavSpan");
		if(d1.pagenav ===''){
			pageNavElement.html('');
			$("#zpagenav").hide();
		}else{
			$("#zpagenav").show();
			pageNavElement.html(d1.pagenav);
		}
		//n.innerHTML=d1.content;
		zContentTransition.load();
		//n.style.display="block";
		if(!zContentTransition.disableNextAnimation){
			if(zContentTransition.lastJumpHash!==""){
				$('#zContentTransitionContentDiv').css("display","block");
				var $target = $("#"+zContentTransition.lastJumpHash);
				//alert('test'+$target+"\n"+$target.offset().top);
				if ($target && $target.length) {
					var targetOffset = Math.max(0,Math.max(0,$target.offset().top-50));
						$(window).scrollTop(targetOffset);
					/*if (zIsTouchscreen()) {
						$(window).scrollTop(targetOffset);
					}else{
						if($("html").scrollTop() !== targetOffset){
							$('html,body').animate({scrollTop: targetOffset}, 200);
						}
					}*/
				}
				zContentTransition.lastJumpHash="";
			}else{
				var doingTheScrollAnimation=false;
				if ($target.length) {
					var targetOffset = Math.max(0,Math.max(0,$target.offset().top-50));
						$(window).scrollTop(targetOffset);
						/*
					if (zIsTouchscreen()) {
						$(window).scrollTop(targetOffset);
					}else{
						if($("html").scrollTop() !== targetOffset){
							doingTheScrollAnimation=true;
							$('html,body').animate({scrollTop: targetOffset}, 200);
						}
					}*/
				}
				if(doingTheScrollAnimation){
					setTimeout(function(){$('#zContentTransitionContentDiv').fadeIn(200,function(){});},200);
				}else{
					$('#zContentTransitionContentDiv').fadeIn(200,function(){});
				}
			}
		}
		zContentTransition.disableNextAnimation=false;
		var c=document.getElementById("zContentTransitionTitleSpan");
		if(c){
			c.innerHTML=d1.pagetitle;
		}
		if(zContentTransition.popNextStateChange){
			zContentTransition.popNextStateChange=false;
		}else{
			History.pushState({rand:Math.random()}, d1.title , zContentTransition.lastURL, false);//Math.random()
			History.Adapter.trigger(window,'statechange');
			History.busy(false);
		}
		if(zMSIEBrowser!==-1 && zMSIEVersion<=9){
		}else{
			zContentTransition.skipNextStateChange=false;
		}
		zLoadAllLoadFunctions();
				
	};
	zContentTransition.processFailedAjaxPageTransition=function(d){
		zContentTransition.processManuallyRan=true;
		zContentTransition.skipNextStateChange=false;
		zContentTransition.processResultStored=true;
		window.location.href=zContentTransition.lastURL;
		// alert("Failed to load url, please try again or contact the webmaster.");//+d);
	};
	zContentTransition.urlHistory=new Array();
	zContentTransition.lastURL="";
	zContentTransition.skipNextStateChange=true;
	zContentTransition.requestAjaxPageTransition=function(theURL, dontPush){
		
		zContentTransition.skipNextStateChange=true;
		if(theURL.substr(0,4) === "http"){
			for(var n=0;n<zLocalDomains.length;n++){
				if(theURL.substr(0,zLocalDomains[n].length) === zLocalDomains[n]){
					theURL=theURL.replace(zLocalDomains[n],"");
					break;
				}
			}
		}
		var p=theURL.indexOf("#");
		if(p !== -1){
			var p2=theURL.indexOf("&_suid=");
			if(p2 !== -1){
				var n=theURL.substr(p+1, p2-(p+1));
				if(n.length>0){
					theURL=n;
				}
			}
		}
		zContentTransition.processManuallyRan=false;
		zContentTransition.processResultStored=false;
		zContentTransition.onPageChange(theURL);
		if(dontPush===false){
			zContentTransition.urlHistory.push(theURL);
		}
		zContentTransition.lastURL=theURL;
		var q=theURL.indexOf("?");
		if(q!==-1){
			theURL+="&";
		}else{
			theURL+="?";
		}
		theURL+="zajaxdownloadcontent=1";
		var tempObj={};
		tempObj.id="zAjaxPageTransition";
		tempObj.url=theURL;
		tempObj.callback=zContentTransition.processAjaxPageTransition;
		tempObj.errorCallback=zContentTransition.processFailedAjaxPageTransition;
		tempObj.cache=false; 
		tempObj.ignoreOldRequests=true; 
		zAjax(tempObj);
	};
	zContentTransition.checkHashChange=function(){
		// zContentTransitionLog.value+="\nhashchangeout url: "+window.location.href+"\n";
		if(!zContentTransition.skipNextStateChange){
			var u="";
			if(zContentTransition.urlHistory.length > 1){
				// zContentTransitionLog.value+="hashchangein \n";
				var u2=zContentTransition.urlHistory.pop();
				// zContentTransitionLog.value+=u2+" | cur \n";
				u=zContentTransition.urlHistory[zContentTransition.urlHistory.length-1];
				var p=u.indexOf("#");
				if(p !== -1){
					var p2=u.indexOf("&_suid=");
					if(p2 !== -1){
						var n=u.substr(p+1, p2-(p+1));
						if(n.length>0){
							u=n;
						}
					}
				}
				zContentTransition.popNextStateChange=true;
				zContentTransition.requestAjaxPageTransition(u, true);
				//zContentTransitionLog.value+=u+" | prev \n";
			}
		}
		zContentTransition.skipNextStateChange=false;
	};
	zContentTransition.stateChange=function(){ 

		// zContentTransitionLog.value+="\nstatechangeout ";
		if(!zContentTransition.skipNextStateChange){
			//zContentTransitionLog.value+=zContentTransition.urlHistory.join("\n");
			//var State = History.getState();
			if(zContentTransition.urlHistory.length > 1){
				// zContentTransitionLog.value+="statechangein \n";
				if(zMSIEBrowser!==-1 && zMSIEVersion<=9){
				}else{
					var u2=zContentTransition.urlHistory.pop();
					// zContentTransitionLog.value+=u2+" | cur \n";
				}
				var u=zContentTransition.urlHistory[zContentTransition.urlHistory.length-1];
				zContentTransition.popNextStateChange=true;
				//zContentTransition.skipNextStateChange=false;
				// zContentTransitionLog.value+=u+" | prev \n";
				zContentTransition.requestAjaxPageTransition(u, true);
			}
		}
	};
	zContentTransition.arrIgnoreURLs=["/z/listing/search-form/index"];
	zContentTransition.arrIgnoreURLContains=["mailto:",
	"/z/misc/system/ext",
	"/z/listing/sl/index",
	"/z/_a/member/",
	"/z/listing/search-js/index",
	"/z/user/preference/",
	".xml"];
	zContentTransition.disable=function(){
		zContentTransition.enabled=false;
	};

	zContentTransition.gotoURL=function(url){
		var newA= document.createElement('a');
		newA.href=url;
		zContentTransition.linkOnClick(false, newA);
	};
	zContentTransition.doLinkOnClick=function(obj){
		if(zContentTransition.enabled){
			zContentTransition.linkOnClick(false, obj);
			return false;
		}else{
			return true;
		}
	};
	zContentTransition.linkOnClick=function(e, obj){
		var thisObj=false;
		if(typeof obj !== "undefined"){
			thisObj=obj;
		}else{
			thisObj=this;
		}
		if(thisObj.target==="_parent"){
			parent.zContentTransition.gotoURL(thisObj.href);
			return false;
		}else if(thisObj.target==="_top"){
			top.zContentTransition.gotoURL(thisObj.href);
			return false;	
		}
		zHideMenuPopups();
		var m=false;
		var shortUrl=thisObj.href;
		for(var n=0;n<zLocalDomains.length;n++){
			if(thisObj.href.substr(0,zLocalDomains[n].length) === zLocalDomains[n]){
				m=true;
				var shortUrl=thisObj.href.replace(zLocalDomains[n],"");
				var a9_2=shortUrl.split("#");
				if(a9_2.length > 1){
					shortUrl=a9_2[0];
				}
				for(var g=0;g<zContentTransition.arrIgnoreURLs.length;g++){
					if(shortUrl === zContentTransition.arrIgnoreURLs[g]){
						window.location.href=thisObj.href;
						return false;
					}
				}
				for(var g=0;g<zContentTransition.arrIgnoreURLContains.length;g++){
					if(shortUrl.indexOf(zContentTransition.arrIgnoreURLContains[g]) !== -1){
						window.location.href=thisObj.href;
						return false;
					}
				}
			}
		}
		if(!m){
			window.location.href=thisObj.href;
			return false;	
		}
		var a9=thisObj.href.split("#");
		if(a9.length > 1){
			var a92=window.location.href.split("#");
			if(a92[0] === a9[0]){
				if(a9.length > 1){
					var $target = $("#"+a9[1]);
					if ($target && $target.length) {
						var targetOffset = Math.max(0,Math.max(0,$target.offset().top-50));
						if(zIsTouchscreen()){
							$(window).scrollTop(targetOffset);
						}else{
							$('html,body').animate({scrollTop: targetOffset}, 200);
						}
					}
					zContentTransition.lastJumpHash="";
					/*History.pushState({rand:Math.random()}, document.title , a9[0], false);//Math.random()
					History.Adapter.trigger(window,'statechange');
					History.busy(false);*/
					//zContentTransition.stateChange();
					return false;
				}else{
					return true;	
				}
			}
			zContentTransition.lastJumpHash=a9[1];
			thisObj.href=a9[0];
		}else{
			zContentTransition.lastJumpHash="";
		}
		zContentTransition.skipNextStateChange=true;
		if(typeof _gaq !== "undefined"){
			_gaq.push(['_trackPageview', shortUrl]);
		}else if(typeof pageTracker !== "undefined"){
			pageTracker._trackPageview(shortUrl);
		}
		//console.log("link clicked:"+thisObj.href);
		zContentTransition.requestAjaxPageTransition(thisObj.href, false); 
		
		return false;	
	};
	//var zContentTransitionLog=false;
	zContentTransition.disableNextAnimation=false;
	zContentTransition.enabled=true;
	zContentTransition.firstLoad=true;
	zContentTransition.popNextStateChange=false;
	zContentTransition.lastJumpHash="";
	zContentTransition.load=function(){
		
		if(zContentTransition.enabled===false) return;
		//zContentTransitionLog=document.getElementById("log");
		if(zContentTransition.firstLoad){
			zContentTransition.firstLoad=false;
			if(zMSIEBrowser!==-1 && zMSIEVersion<=9){
				if(History !== "undefined" && History.Adapter !== "undefined"){
					History.Adapter.bind(window,'hashchange',zContentTransition.checkHashChange);
				}
				var p=window.location.href.indexOf("#");

				if(p !== -1){
					var p2=window.location.href.indexOf("&_suid=");
					if(p2 !== -1){
						var n=window.location.href.substr(p+1, p2-(p+1));
						var p3=window.location.href.indexOf("/",8);
						var n2=window.location.href.substr(p3, p-p3);
						//alert('me\n'+n2+"\n"+n);
						if(n2 !== n){
							zContentTransition.requestAjaxPageTransition(n, false);	
						}
					}
				}
			}else{
				History.Adapter.bind(window,'statechange',zContentTransition.stateChange);
				if(History.storedStates.length>1){
					var s=History.getState();
					zContentTransition.requestAjaxPageTransition(s.url, false);	
				}
			}
			var theURL=window.location.href;
			if(theURL.substr(0,4) === "http"){
				//alert(i+" | "+zContentTransition.lastURL);
				for(var n=0;n<zLocalDomains.length;n++){
					if(theURL.substr(0,zLocalDomains[n].length) === zLocalDomains[n]){
						theURL=theURL.replace(zLocalDomains[n],"");
						break;
					}
				}
			}
			zContentTransition.urlHistory.push(theURL);
		}
		var a=document.getElementsByTagName("a");//zGetElementsByClassName("zContentTransition");
		var clone =[]; // need clone because the array automatically changes when removing the class name
		for(var i=0;i<a.length;i++){
			var targetCheck=false;
			if(window.location.href+"#" === a[i].href){
				continue;
			}
			if(a[i].target !== ""){
				if(a[i].target==="_parent"){
					try{
						if(typeof parent.zContentTransition === "undefined"){
							targetCheck=true;
						}
					}catch(e){
						targetCheck=true;
					}
				}else if(a[i].target==="_top"){
					try{
						if(typeof top.zContentTransition === "undefined"){
							targetCheck=true;
						}
					}catch(e){
						targetCheck=true;
					}
				}else{
					targetCheck=true;
				}
			}
			try{
				if(typeof a[i].onclick !== "function" && !targetCheck){
					if(a[i].id === "" && a[i].name !== ""){
						a[i].id=a[i].name;
					}
					if(a[i].className.indexOf("zNoContentTransition")!==-1){
						continue;	
					}
					clone.push(a[i]);	
				}
			}catch(e){
				throw("The onclick code was invalid for a link on this page.  Onclick code:"+a[i].getAttribute("onclick"));
			}
		}
		for(var i=0;i<clone.length;i++){
			//clone[i].className=clone[i].className.replace("zContentTransition","");
			clone[i].onclick=zContentTransition.linkOnClick;
		}
		zLoadAndCropImagesDefer();
	};

	zContentTransition.bind=function(obj, func){
		if(typeof func !== "undefined"){
			zContentTransition.arrPageChangeObjs.push(obj);
			zContentTransition.arrPageChangeFunctions.push(func);
		}else{
			zContentTransition.arrPageChangeObjs.push(false);
			zContentTransition.arrPageChangeFunctions.push(obj);
		}
	};
	zContentTransition.arrPageChangeObjs=[];
	zContentTransition.arrPageChangeFunctions=[];
	zContentTransition.pageChangeUrl="";
	zContentTransition.onPageChange=function(newUrl){
		
		if(newUrl === zContentTransition.pageChangeUrl) return;
		zContentTransition.pageChangeUrl=newUrl;
		for(var i=0;i<zContentTransition.arrPageChangeObjs.length;i++){
			if(typeof zContentTransition.arrPageChangeObjs[i] === "boolean"){
				zContentTransition.arrPageChangeFunctions[i](newUrl);
			}else{
				zContentTransition.arrPageChangeObjs[i][zContentTransition.arrPageChangeFunctions[i]](newUrl);
			}
		}
	};
	zContentTransition.checkLoad=function(){
		if(typeof zContentTransitionEnabled !== "undefined" && zContentTransitionEnabled && typeof zContentTransitionDisabled === "undefined"){
			if(zWindowIsLoaded){
				zContentTransition.load();
			}else{
				zArrLoadFunctions.push({functionName:zContentTransition.load});
			}
		}
	};
 
			
})(jQuery, window, document, "undefined"); 