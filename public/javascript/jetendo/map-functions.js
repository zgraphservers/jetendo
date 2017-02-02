
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
		// limit to 300 geocodes per client per day
		if(count > 300){
			return false;
		}
		count++;
		zSetCookie({key:"zGeocodeCount",value:count,futureSeconds:60 * 60 * 24,enableSubdomains:false});  
		return true;
	}
	function zGeocodeCacheAddress() {
		if(!zIsGeocoderAvailable()){
			if(zIsDeveloper()){
				console.log('Geocoder available');
			}
			return;
		} 
		if(zGeocode.arrAddress.length <= geocodeOffset){
			if(zIsDeveloper()){
				console.log('Nothing available to geocode');
			}
			return; 
		}
 
		if(zIsDeveloper()){
			console.log('geocoding address: '+zGeocode.arrAddress[geocodeOffset]);
		}
		geocoder.geocode( { 'address': zGeocode.arrAddress[geocodeOffset]}, function(results, status) {
			var r="";
			var data={
				latitude:"",
				longitude:"",
				accuracy:"",
				status:""
			};
			if(zIsDeveloper()){
				console.log(results);
			}
			var match=false;
			if (status == google.maps.GeocoderStatus.OK) {
				var a1=new Array();
				for(var i=0;i<results.length;i++){
					//var a2=new Array();
					//a2[0]=results[i].types.join(",");
					if(results[i].geometry.location_type=="ROOFTOP"){//"street_address"){  
						data.status="OK";
						data.latitude=results[i].geometry.location.lat();
						data.longitude=results[i].geometry.location.lng();
						data.accuracy=results[i].geometry.location_type; 
						match=true;
						break;	
					}else if(data.accuracy==''){

						data.status="OK";
						data.latitude="";
						data.longitude="";
						data.accuracy=results[i].geometry.location_type; 
					}
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
			data.status=curStatus;
			if(zIsDeveloper()){
				console.log('before saveGeocode status: '+curStatus);
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
					if(zIsDeveloper()){
						console.log('saveGeocode '+geocodeOffset+' status: true');
					}
				}else{
					console.log('saveGeocode error:'+r.errorMessage);
				}
			}
			zAjax(ts);  
			geocodeOffset++;
			if(geocodeOffset<zGeocode.arrAddress.length && !stopCacheGeocoding){
				setTimeout(function(){ 
					zTimeoutGeocodeCache();
				},1500);
			}
		});
	}

	// zGetDirectionsDistance(sourceLat, sourceLong, destinationLat, destinationLong, directionsCallbackFunction);
	function zGetDirectionsDistanceByLatLng(sourceLat, sourceLong, destinationLat, destinationLong, directionsCallbackFunction){
		var source=new google.maps.LatLng(sourceLat, sourceLong);
		var destination=new google.maps.LatLng(destinationLat, destinationLong);
		zGetDirectionsDistanceByAddress(source, destination, directionsCallbackFunction)
	}

	// zGetDirectionsDistance(source, destination, directionsCallbackFunction);
	function zGetDirectionsDistanceByAddress(source, destination, directionsCallbackFunction){

		var directionsService = new google.maps.DirectionsService();
		var request = {
			origin:source,
			destination:destination,
			travelMode: google.maps.DirectionsTravelMode.DRIVING
		};
		directionsService.route(request, function(response, status){
			if (status == google.maps.DirectionsStatus.OK){
				console.log(response); 
				/*
				distance = "The distance between the two points on the chosen route is: "+response.routes[0].legs[0].distance.text;
				distance += "The aproximative driving time is: "+response.routes[0].legs[0].duration.text;
				console.log(distance);
				*/  
				var rs={
					success:true,
					response:response,
					distanceInMeters: response.routes[0].legs[0].distance.value, 
					distanceInKilometers: response.routes[0].legs[0].distance.value/1000, 
					distanceInMiles: response.routes[0].legs[0].distance.value*0.000621371, // convert meters to miles
					distanceAsString: response.routes[0].legs[0].distance.text, 
					drivingTime: response.routes[0].legs[0].duration.text
				};
			}else{
				var rs={
					success:false,
					response:response,
					errorMessage:'Unable to calculate driving distance'
				};
			}
			directionsCallbackFunction(rs); 
		});
	}
	// zDisplayDirectionsDistance(googleMapObj, directionsResponse);
	function zDisplayDirectionsDistance(googleMapObj, directionsResponse){

		var directionsDisplay = new google.maps.DirectionsRenderer({
			suppressMarkers: true,
			suppressInfoWindows: true
		});
		directionsDisplay.setMap(googleMapObj);
		directionsDisplay.setDirections(directionsResponse);
	}

	var arrRegisterAutoCompleteCallback=[];
	function zGoogleAddressAutoCompleteRegisterCallback(f){
		arrRegisterAutoCompleteCallback.push(f);
	}

	zArrMapFunctions.push(function(){ 
		if($(".zGoogleAddressAutoComplete").length){

		}
	    $(".zGoogleAddressAutoComplete").each(function(){
			var placeSearch, autocomplete;

			// Bias the autocomplete object to the user's geographical location,
			// as supplied by the browser's 'navigator.geolocation' object.
			function geolocate() {
				// only works on https in a browser that supports geolocation
				if (window.location.href.indexOf("https:") != -1 && navigator.geolocation) {
					navigator.geolocation.getCurrentPosition(function(position) {
						var geolocation = {
							lat: position.coords.latitude,
							lng: position.coords.longitude
						};
						var circle = new google.maps.Circle({
							center: geolocation,
							radius: position.coords.accuracy
						});
						autocomplete.setBounds(circle.getBounds());
					});
				}else{
					// do nothing
				}
			}

			var componentForm = {
				coordinates: $(this).attr("data-address-coordinates"),
				street_number: $(this).attr("data-address-number"),
				route: $(this).attr("data-address-street"),
				locality: $(this).attr("data-address-city"),
				administrative_area_level_1: $(this).attr("data-address-state"),
				country: $(this).attr("data-address-country"),
				postal_code: $(this).attr("data-address-zip")
			};
			var firstTimeGeocode=true;
	 		var backupAutocompleteInputValue="";
		    $(this).bind("focus", function(){
		    	backupAutocompleteInputValue=this.value;
		    	geolocate();
		    });
			function clearAddressFields() {  
				for (var component in componentForm) {
					if (typeof componentForm[component] != "undefined") {
						document.getElementById(componentForm[component]).value = '';
						document.getElementById(componentForm[component]).disabled = false;
					}
				}
			}
			function fillInAddressFields(place, fieldName) { 
				clearAddressFields();

				if (typeof componentForm["coordinates"] != "undefined"){
					document.getElementById(componentForm["coordinates"]).value=place.geometry.location.lat()+","+place.geometry.location.lng();
				}

				// Get each component of the address from the place details
				// and fill the corresponding field on the form.
				for (var i = 0; i < place.address_components.length; i++) {
					var addressType = place.address_components[i].types[0];
					if (typeof componentForm[addressType] != "undefined" && componentForm[addressType]) { 
						var val = place.address_components[i].long_name;
						document.getElementById(componentForm[addressType]).value = val; 
					}
				}
				var a=buildAddress(place, fieldName); 
				for(var i=0;i<arrRegisterAutoCompleteCallback.length;i++){
					arrRegisterAutoCompleteCallback[i](a);
				}
			}
			function buildAddress(place, fieldName) { 
				var a = {
					coordinates: "",
					street_number: "", 
					street: "", // route
					city: "", // locality
					state: "", // administrative_area_level_1
					country: "",
					postal_code: "",
					address:"",
					fieldName:fieldName
				};
				a.coordinates=place.geometry.location.lat()+","+place.geometry.location.lng();

				for (var i = 0; i < place.address_components.length; i++) {
					var addressType = place.address_components[i].types[0];
					var val = place.address_components[i].long_name;
					if(addressType == "street_number"){
						a.street_number=val;
					}else if(addressType == "street"){
						a.street=val;
					}else if(addressType == "city"){
						a.city=val;
					}else if(addressType == "state"){
						a.state=val;
					}else if(addressType == "country"){
						a.country=val;
					}else if(addressType == "postal_code"){
						a.postal_code=val; 
					}
				}
				var arrAddress=[];
				if(a.street_number != ""){
					arrAddress.push(a.street_number+" ");
				}
				if(a.street != ""){
					arrAddress.push(a.street+", ");
				}
				if(a.city != ""){
					arrAddress.push(a.city+", ");
				}
				if(a.state != ""){
					arrAddress.push(a.state+" ");
				}
				if(a.postal_code != ""){
					arrAddress.push(a.postal_code+" ");
				}
				if(a.country != ""){
					arrAddress.push(a.country);
				}
				a.address=arrAddress.join("");
				return a;
			}
 
			function fillInAddress() { 
				// Get the place details from the autocomplete object.
				var place = autocomplete.getPlace(); 
				fillInAddressFields(place, this.__fieldElement.name);
			}
			// Create the autocomplete object, restricting the search to geographical
			// location types.
			autocomplete = new google.maps.places.Autocomplete(this,	{types: ['geocode']} );
			autocomplete.__fieldElement=this; 
 
			$(this).bind("blur", function(){ 
				// if the value changed, clear the address fields until callback completes
				if(!firstTimeGeocode && backupAutocompleteInputValue != this.value){
					clearAddressFields();
				}
				// need to be able to register to autocomplete callback functions.

				var v=document.getElementById(componentForm["coordinates"]).value;  
				if(v=='' && this.value!=""){
					firstTimeGeocode=false; 
					// geocode and set form
					var geocoder = new google.maps.Geocoder();  
					geocoder.geocode( { 'address': this.value}, function(results, status) {
						if (status === google.maps.GeocoderStatus.OK) { 
							var place=results[0]; 
							clearAddressFields();  
							fillInAddressFields(place, autocomplete.__fieldElement.name); 
						} else {
							alert("Google can't map this address, please correct or remove the address and try again. (Status: "+status+")");
						}
					});  
				}
			});
			// When the user selects an address from the dropdown, populate the address
			// fields in the form.
			autocomplete.addListener('place_changed', fillInAddress);
		});
	});

	function zTimeoutGeocodeCache(){
		if(stopCacheGeocoding) return;
		zGeocodeCacheAddress();
	}
	window.zGoogleAddressAutoCompleteRegisterCallback=zGoogleAddressAutoCompleteRegisterCallback;
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
	window.zDisplayDirectionsDistance=zDisplayDirectionsDistance;
	window.zGetDirectionsDistanceByLatLng=zGetDirectionsDistanceByLatLng;
	window.zGetDirectionsDistanceByAddress=zGetDirectionsDistanceByAddress;
})(jQuery, window, document, "undefined"); 