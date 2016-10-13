
(function($, window, document, undefined){
	"use strict";

	function zCreateMap(mapDivId, optionsObj) {
		
		var mapOptions = { 
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		for(var i in optionsObj){
			mapOptions[i]=optionsObj[i];
		}
		var eventObj={};
		if(typeof mapOptions.bindEvents !== "undefined"){
			eventObj=mapOptions.bindEvents;
			delete mapOptions.bindEvents;
		}
		document.getElementById(mapDivId).style.display="block";
		var map = new google.maps.Map(document.getElementById(mapDivId), mapOptions);
		for(var i in eventObj){
			google.maps.event.addListener(map, i, eventObj[i]);
		}
		return map;
	}
	var globalInfoWindow=null;
	function zCreateMapMarker(markerObj){
		if(typeof markerObj === 'undefined'){
			markerObj={};
		}
		var eventObj={};
		var infoWindowHTML="";
		if(typeof markerObj.infoWindowHTML !== "undefined"){
			infoWindowHTML=markerObj.infoWindowHTML;
			delete markerObj.infoWindowHTML;
		}
		if(typeof markerObj.bindEvents !== "undefined"){
			eventObj=markerObj.bindEvents;
			delete markerObj.bindEvents;
		}
		var marker = new google.maps.Marker(markerObj);
		for(var i in eventObj){
			google.maps.event.addListener(marker	, i, eventObj[i]);
		} 
		if(!globalInfoWindow){
			globalInfoWindow = new google.maps.InfoWindow({
				content: ""
			});
		}
		if(infoWindowHTML !== ""){
			marker.infoWindowHTML=infoWindowHTML; 
			google.maps.event.addListener(marker	, 'click', function(){ 
				globalInfoWindow.close();
				globalInfoWindow.setPosition(marker.getPosition());
				globalInfoWindow.setContent(marker.infoWindowHTML);
				globalInfoWindow.open(marker.getMap(), marker);
			});
		}
		return marker;
	}

	function zMapFitMarkers(mapObj, arrMarker){ 
		if(arrMarker.length === 0){
			return;
		}else if(arrMarker.length === 1){
			if(arrMarker[0].getPosition().lat() !== 0){
				mapObj.setCenter(arrMarker[0].getPosition());
				// Use the zoom level from 'mapObj' if provided.
				if ( typeof( mapObj.zoom ) !== 'undefined' ) {
					mapObj.setZoom( mapObj.zoom );
				} else {
					mapObj.setZoom( 10 );
				}
			}
			return;
		}
		var bounds = new google.maps.LatLngBounds ();
		var extended=false;
		for (var i = 0, LtLgLen = arrMarker.length; i < LtLgLen; i++) {
			if(typeof arrMarker[i].getPosition() !== "undefined" && arrMarker[i].getPosition().lat() !== 0){
				bounds.extend(arrMarker[i].getPosition());
				extended=true;
			}
		} 
		if(extended){
			mapObj.fitBounds(bounds);
		} 
	} 
	function zAddMapMarkerByLatLng(mapObj, markerObj, latitude, longitude, successCallback){ 
		var marker=zCreateMapMarker(markerObj); 
		var location=new google.maps.LatLng( latitude, longitude);
		marker.setPosition(location);
		marker.setMap(mapObj);
		if(typeof successCallback !== "undefined"){
			setTimeout(function(){ successCallback(marker, location); }, 10);
		}
		return marker;
	}
	function zGetLatLongByAddress(address, successCallback, delayMilliseconds){ 
		var geocoder = new google.maps.Geocoder(); 
		if(typeof delayMilliseconds === 'undefined'){
			delayMilliseconds=0;
		}
		setTimeout(function(){
			geocoder.geocode( { 'address': address}, function(results, status) {
				if (status === google.maps.GeocoderStatus.OK) { 
					successCallback(results[0].geometry.location);
				} else {
					console.log('Geocode was not successful for address, "'+address+'", for the following reason: ' + status);
				}
			});
		}, delayMilliseconds);
	}
	function zAddMapMarkerByAddress(mapObj, markerObj, address, successCallback, delayMilliseconds){ 
		var marker=zCreateMapMarker(markerObj);
		var geocoder = new google.maps.Geocoder(); 
		if(typeof delayMilliseconds === 'undefined'){
			delayMilliseconds=0;
		}
		setTimeout(function(){
			geocoder.geocode( { 'address': address}, function(results, status) {
				if (status === google.maps.GeocoderStatus.OK) { 
					marker.setPosition(results[0].geometry.location);
					marker.setMap(mapObj);
					if(typeof successCallback !== "undefined"){
						successCallback(marker, results[0].geometry.location);
					}
				} else {
					console.log('Geocode was not successful for address, "'+address+'", for the following reason: ' + status);
				}
			});
		}, delayMilliseconds);
		return marker;
	}
	function zCreateMapWithAddress(mapDivId, address, optionsObj, successCallback, markerObj) {
		var marker=zCreateMapMarker(markerObj); 
		var geocoder = new google.maps.Geocoder(); 
		if(address.length === ""){ 
			if(typeof optionsObj.defaultAddress !== "undefined"){
				address=optionsObj.defaultAddress;
			}else{
				return;
			}
		}
		var mapOptions = {
			zoom: 8,
	   		center: new google.maps.LatLng(0, 0),
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		for(var i in optionsObj){
			mapOptions[i]=optionsObj[i];
		} 
		var map=zCreateMap(mapDivId, mapOptions); 
		geocoder.geocode( { 'address': address}, function(results, status) {
			if (status === google.maps.GeocoderStatus.OK) {
				setTimeout(function(){
					google.maps.event.trigger(map, 'resize');
					map.setCenter(results[0].geometry.location); 
				}, 1);
				marker.setPosition(results[0].geometry.location);
				marker.setMap(map);
				if(typeof mapOptions.triggerEvents !== "undefined"){
					for(var i in mapOptions.triggerEvents){
						google.maps.event.trigger(map, i);
					}
				} 
				successCallback(marker); 
			} else {
				console.log('Geocode was not successful for the following reason: ' + status);
				$("#"+mapDivId).html("The location was not able to be mapped.");
			}
		});
		return { map: map, marker: marker};
	}
	
	function zCreateMapWithLatLng(mapDivId, latitude, longitude, optionsObj, successCallback, markerObj) {  
		var mapOptions = {
			zoom: 8,
	   		center: new google.maps.LatLng(latitude, longitude),
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		for(var i in optionsObj){
			mapOptions[i]=optionsObj[i];
		} 
		var map=zCreateMap(mapDivId, mapOptions); 
		if(typeof markerObj === "undefined"){
			markerObj={};
		}
		markerObj.position=mapOptions.center;
		markerObj.map=map;
		var marker=zCreateMapMarker(markerObj);  
		if(typeof mapOptions.triggerEvents !== "undefined"){
			for(var i in mapOptions.triggerEvents){
				google.maps.event.trigger(map, i);
			}
		} 
		successCallback(marker); 
		return { map: map, marker: marker};
	}


	var stopCacheGeocoding=false;
	var zGeocode={
		arrAddress:[],
		arrKey:[]
	};
	var firstRun=true;
	var geocodeOffset=0;
	var geocoderAvailable=false; 
	var geocoder = false;
	function zIsGeocoderAvailable(){
		if(typeof google!=="undefined" && typeof google.maps!=="undefined" && typeof google.maps.Geocoder!=="undefined"){
			if(typeof geocoder == "boolean"){
				geocoder = new google.maps.Geocoder();   
			}
			geocoderAvailable=true;
		}

		if(!geocoderAvailable){
			return false;
		}
		if(firstRun){
			var active=zGetCookie("zGeocodeActive");
			if(active == "1"){
				// another browser window is already running the geocoder for this ip - lets avoid hitting limits and cancel this request.
				stopCacheGeocoding=true;
				return false;
			}
			firstRun=false;
			zSetCookie({key:"zGeocodeActive",value:"1",futureSeconds:40,enableSubdomains:false});  
		}
		var count=zGetCookie("zGeocodeCount");
		if(count==""){
			count=0;
		}else{
			count=parseInt(count);
		}
		if(count > 2300){
			return false;
		}
		count++;
		zSetCookie({key:"zGeocodeCount",value:count,futureSeconds:60 * 60 * 24,enableSubdomains:false});  
		return true;
	}
	function zGeocodeCacheAddress() {
		if(!zIsGeocoderAvailable()){
			return;
		} 
		if(zGeocode.arrAddress.length <= geocodeOffset) return;
		//if(debugajaxgeocoder) f1.value+="run geocode: "+zGeocode.arrAddress[geocodeOffset]+"\n";
 
		geocoder.geocode( { 'address': zGeocode.arrAddress[geocodeOffset]}, function(results, status) {
			var r="";
			var data={
				latitude:"",
				longitude:"",
				accuracy:"",
				status:""
			};
			var match=false;
			if (status == google.maps.GeocoderStatus.OK) {
				var a1=new Array();
				for(var i=0;i<results.length;i++){
					var a2=new Array();
					a2[0]=results[i].types.join(",");
					if(a2[0]=="street_address"){  
						data.status="OK";
						data.latitude=results[i].geometry.location.lat();
						data.longitude=results[i].geometry.location.lng();
						data.accuracy=results[i].geometry.location_type; 
						match=true;
						break;	
					}
				}
				if(!match){
					return;
				} 
				//if(debugajaxgeocoder) f1.value+="Result:"+r+"\n";
			} else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT || status == google.maps.GeocoderStatus.REQUEST_DENIED){
				// serious error condition
				stopCacheGeocoding=true; 
			}
			var curStatus="";
			if(status == google.maps.GeocoderStatus.OK){
				curStatus="OK";
			}else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT){
				curStatus="OVER_QUERY_LIMIT";
				stopGeocoding=true;
				return;
			}else if(status == google.maps.GeocoderStatus.REQUEST_DENIED){
				curStatus="REQUEST_DENIED";
			}else if(status == google.maps.GeocoderStatus.ZERO_RESULTS){
				curStatus="ZERO_RESULTS";
			}else if(status == google.maps.GeocoderStatus.INVALID_REQUEST){
				curStatus="INVALID_REQUEST";
			}else if(status == 'ERROR'){
				stopCacheGeocoding=true;
				// This is an undocumented problem with google's API. We must stop geocoding and wait for a new user with a fresh copy of google's API downloaded that hopefully works.
				return;
			}else{
				curStatus=status;
			}
			//if(debugajaxgeocoder) f1.value+='geocode done for address='+zGeocode.arrAddress[geocodeOffset]+" with status="+curStatus+"\n";
			var debugurlstring="";
			/*if(debugajaxgeocoder){
				debugurlstring="&debugajaxgeocoder=1";
			}*/
			data.address=zGeocode.arrAddress[geocodeOffset];
			data.key=zGeocode.arrKey[geocodeOffset];
			var ts={};
			ts.id="zSaveGeocode";
			ts.postObj=data;
			ts.cache=false;
			ts.method="post";
			ts.url="/z/misc/geocode/saveGeocode";
			ts.callback=function(r){
				var r=JSON.parse(r);
				if(r.success){
					//console.log('saveGeocode '+geocodeOffset+' status: true');
				}else{
					console.log('saveGeocode error:'+r.errorMessage);
				}
			}
			zAjax(ts); 
			geocodeOffset++;
			if(geocodeOffset<zGeocode.arrAddress.length && !stopCacheGeocoding){
				setTimeout('zTimeoutGeocodeCache();',1500);
			}
		});
	}
	function zTimeoutGeocodeCache(){
		if(stopCacheGeocoding) return;
		zGeocodeCacheAddress();
	}
	window.zGeocode=zGeocode;
	window.zIsGeocoderAvailable=zIsGeocoderAvailable;
	window.zGeocodeCacheAddress=zGeocodeCacheAddress;
	window.zCreateMap=zCreateMap;
	window.zCreateMapMarker=zCreateMapMarker;
	window.zMapFitMarkers=zMapFitMarkers;
	window.zAddMapMarkerByLatLng=zAddMapMarkerByLatLng;
	window.zGetLatLongByAddress=zGetLatLongByAddress;
	window.zAddMapMarkerByAddress=zAddMapMarkerByAddress;
	window.zCreateMapWithAddress=zCreateMapWithAddress;
	window.zCreateMapWithLatLng=zCreateMapWithLatLng;
})(jQuery, window, document, "undefined"); 