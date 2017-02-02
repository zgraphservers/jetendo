
(function($, window, document, undefined){
"use strict";
function zLoadListingSavedSearches(){
	var arrMap=[];
	$(".zls-listingSavedSearchMapSummaryDiv").each(function(){
		var ssid=$(this).attr("data-ssid");
		if(ssid == ""){
			return;
		}
		arrMap[ssid]=this;
	});

	$(".zls-listingSavedSearchDiv").each(function(){
		var currentDiv=this;
		var ssid=$(this).attr("data-ssid");
		if(ssid == ""){
			return;
		}
		var tempObj={};
		tempObj.id="zListingSavedSearchAjax"+ssid;
		tempObj.cache=false;
		tempObj.method="get"; 
		
		tempObj.callback=function(d){   
			try{
				var r=JSON.parse(d); 
				if(r.success){ 
					$(currentDiv).html(r.listingOutput);
					if(ssid in arrMap){
						$(".contentPropertySummaryDiv", arrMap[ssid]).html(r.mapSummaryOutput);
						$(".mapContentDiv", arrMap[ssid]).html('<iframe id="embeddedmapiframe" src="/z/listing/map-embedded/index?ssid='+ssid+'" width="100%" height="340" style="border:none; overflow:auto;" seamless="seamless"></iframe>');
					}
					zlsEnableImageEnlarger();
					zLoadAndCropImages();
				}else{
					$(currentDiv).html("Listings not available at this time. Please try again later. Error Code ##1");
				}
			}catch(e){
				$(currentDiv).html("Listings not available at this time. Please try again later. Error Code ##2");
				throw e;
			} 
		};

		tempObj.errorCallback=function(d){
			$(currentDiv).html("Listings not available at this time. Please try again later.");
		};
		tempObj.ignoreOldRequests=false;
		tempObj.url="/z/listing/ajax-listing/index?ssid="+ssid; 
		if(ssid in arrMap){
			tempObj.url+="&getMapSummary=1";
		}
		zAjax(tempObj); 
	});
}
zArrLoadFunctions.push({functionName:zLoadListingSavedSearches});

function zListingLoadSavedCart(){
	if(typeof zIsModalWindow != "undefined"){
		return;
	}
	var listingCount=zGetCookie("SAVEDLISTINGCOUNT"); 
	var enabled=true;
	if(listingCount=="0" || listingCount==""){
		enabled=false; 
	} 
	if(enabled){
		var tempObj={};
		tempObj.id="zListingLoadSavedCart";
		tempObj.cache=false;
		tempObj.method="get"; 
		tempObj.callback=function(d){  
			var r=JSON.parse(d);
			if(r.success){ 
				if($("#sl894nsdh783").length==0){
					$("#zTopContent").append('<div id="sl894nsdh783" style="width:100%; float:left; clear:both;"></div>');
				}
				var listingCount=zGetCookie("SAVEDLISTINGCOUNT"); 
				if(listingCount=="0" || listingCount==""){
					$("#sl894nsdh783").html("").hide(); 
				}else{
					$("#sl894nsdh783").show().html(r.output);   
				}
			} 
		}; 
		tempObj.ignoreOldRequests=false;
		tempObj.url="/z/listing/sl/index";  
		zAjax(tempObj);  
	}else{
		$("#sl894nsdh783").html("").hide(); 
	}
}



zArrDeferredFunctions.push(zListingLoadSavedCart);


function zSetupListingCartButtons(){

	$(document).on("click", ".zls-saveListingButton", function(e){
		e.preventDefault();
		var tempObj={};
		tempObj.id="zListingLoadSavedCart";
		tempObj.cache=false;
		tempObj.method="get"; 
		tempObj.callback=function(d){  
			var r=JSON.parse(d); 
			if(r.success){ 
				zListingLoadSavedCart();
			}else{
				alert('Listing saved');
			} 
		}; 
		tempObj.ignoreOldRequests=false;
		var id=$(e.target).attr("data-listing-id");

		tempObj.url="/z/listing/sl/add?listing_id="+id;  
		zAjax(tempObj);   
	}); 


	$(document).on("click", ".zls-removeListingButton", function(e){
		e.preventDefault();
		var tempObj={};
		tempObj.id="zListingLoadSavedCart";
		tempObj.cache=false;
		tempObj.method="get"; 
		tempObj.callback=function(d){  
			var r=JSON.parse(d); 
			if(r.success){ 
				zListingLoadSavedCart();
			} 
		}; 
		tempObj.ignoreOldRequests=false;
		var id=$(e.target).attr("data-listing-id");
		tempObj.url="/z/listing/sl/delete?listing_id="+id;  
		zAjax(tempObj);   
	});
	$(document).on("click", ".zls-removeAllListingButton", function(e){
		e.preventDefault();
		var tempObj={};
		tempObj.id="zListingLoadSavedCart";
		tempObj.cache=false;
		tempObj.method="get"; 
		tempObj.callback=function(d){  
			var r=JSON.parse(d);
			if(r.success){ 
				zListingLoadSavedCart();
			} 
		}; 
		tempObj.ignoreOldRequests=false;
		tempObj.url="/z/listing/sl/deleteAll";  
		zAjax(tempObj);   
	});
}
zArrLoadFunctions.push({functionName:zSetupListingCartButtons});




})(jQuery, window, document, "undefined"); 