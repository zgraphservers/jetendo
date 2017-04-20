<cfcomponent>
<cfoutput>

<cffunction name="mapDisplay" localmode="modern" access="remote">

	<script type="text/javascript">
	/* <![CDATA[ */ 
	zArrDeferredFunctions.push(function(){
	});
	/* ]]> */
	</script>

	<cfscript>
	/*
	map picker needs integration with address, city, state, zip fields so it can automatically geocode as they change.
		ajax system needs to be able to run validation on the fields before submitting data.
			map picker validation will do the geocode before continuing submission
				must return false when lat/long is empty.
				the geocode callback will run submit again with lat/long validation disabled.
	
	// can I use anything from real estate map features?
	
	load markers from ajax search results - require picking city or category before showing markers.
	
	mapAjaxSearch
		validate input
		run search query
		var mapCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.misc.controller.map");
		for(row in qS){
			var ts={};
			ts.uniqueId=row.unique_id;
			ts.latLong="";
			ts.overlayHTML='';
			ts.markerIcon='';
			mapCom.addMarker(ts);
		}
		mapCom.jsonResponse();
		
	// front-end callback js
	var mapClass=function(window, document, jQuery){
		var $=jQuery;
		this.config={
			fitMarkersOnResponse:true
		};
		this.data={};
		this.arrMarker=[];
		var self=this;
		this.init=function(configObj, ajaxFormId){
			for(var i in configObj){
				this.config[i]=configObj[i];
			}
			if(typeof ajaxFormId == "undefined" || $("#"+ajaxFormId").length == 0){
				alert("ajaxFormId must be a valid ajax form id");
				return;
			}
			this.form=$("#"+ajaxFormId");
			this.form.bind("submit", self.mapAjaxSearch);
			$(':input, :textarea, :select', this.form).change(this.fieldOnChange).each(initialFieldSetup);
			$('input[name=bla]', this.form).change(this.fieldOnChange).each(initialFieldSetup);
		}
		this.initialFieldSetup=function(){
			self.data[this.name]=$(this).val();
		};
		this.fieldOnChange=function(){
			self.data[this.name]=$(this).val();
			self.mapAjaxSearch();
		};
		this.mapAjaxSearchCallback=function(r){
			var d=eval(r)...
			
			for(var i=0;i<d.arrMarker.length;i++){
				var c=d.arrMarker[i];
				if(typeof this.arrMarker[c.uniqueId] == "undefined"){
					googleMapClass.addMarker(c);
				}
			}
			// pan / center / zoom to fit all the markers
		}
		this.mapAjaxSearch=function(){
			console.log("search");
			console.log(this.data);
			return;
			// validate form
			
			// get seach form data
			
			// setup ajax request
			this.mapAjaxSearchCallback
			zAjax();
		}
	}(window, document, jQuery);
	
	addMarker
		latLong
		overlayHTML
		markerIcon
		returns json
	createMapAjaxResponse(
		arrMarker (internal array of json strings)
		form.x_ajax_id
		success: true
		outputs json and aborts
	
	enableSearch
		city
		category
		keyword
		address  / radius 1, 5, 10, 20, 30, 50, 100 miles
	displayMap();
	*/
	</cfscript>
	
	
</cffunction>

<cffunction name="modalMarkerPicker" localmode="modern" access="remote">
	<cfargument name="callback" type="string" required="no" default="">
	<cfscript>
	application.zcore.functions.zSetModalWindow();
	form.address=replace(application.zcore.functions.zso(form, 'address'), "-- select --", "", "all");
	form.coordinates=application.zcore.functions.zso(form, 'coordinates');
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true); 
	application.zcore.functions.zRequireJquery();
	</cfscript>
	<!--- 
	form.callback must be the name of a function in parent window with the following prototype:
		function mapCallback(latitude, longitude){
			alert(latitude+", "+longitude);	
		}
	
	map position picker as modal window - site option field - optionally type the lat/long ---> 
	<!--- multi-marker display system for map function --->

	<cfsavecontent variable="local.scriptOutput"> 
	<cfscript>
	application.zcore.functions.zRequireGoogleMaps();
	</cfscript>  
	<script type="text/javascript">
	/* <![CDATA[ */
	
	 var mapParentWindowCallback="#jsstringformat(arguments.callback)#";
	 var currentMapAddress="#jsstringformat(form.address)#";
	 var currentCoordinates="#jsstringformat(form.coordinates)#";
	 function executeParentCallback(latitude, longitude){ 
		if(typeof window.parent[mapParentWindowCallback] != "undefined"){
			window.parent[mapParentWindowCallback](latitude, longitude);
		}
	 }
	function markerDragEndCallback(eventData){ 
		// eventData.pixel.x eventData.pixel.y
		$("##latitude1").val(eventData.latLng.lat());
		$("##longitude1").val(eventData.latLng.lng());
		currentGoogleMap.panTo(eventData.latLng);
		executeParentCallback(eventData.latLng.lat(), eventData.latLng.lng());
	}
	var currentGoogleMap=false;
	function mapSuccessCallback2(marker){
		currentMarker=marker;  
		var p=currentMarker.getPosition(); 
		$("##latitude1").val(p.lat());
		$("##longitude1").val(p.lng());
		$("##mapContainerDiv").show();
		zArrResizeFunctions.push(setMapSize); 
		setMapSize();
		executeParentCallback(p.lat(), p.lng());
	}
	function mapSuccessCallback3(marker ){
		var arrC=currentCoordinates.split(","); 
		var lat=arrC[0];
		var lng=arrC[1];
		marker.setPosition(new google.maps.LatLng(lat, lng));
		$("##latitude1").val(lat);
		$("##longitude1").val(lng);
		$("##mapContainerDiv").show();
		zArrResizeFunctions.push(setMapSize); 
		setMapSize();
		executeParentCallback(lat, lng);
	}
	function mapUpdatePosition(results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			currentMarker.setPosition(results[0].geometry.location);
			currentGoogleMap.setCenter(results[0].geometry.location);

			$("##latitude1").val(results[0].geometry.location.lat());
			$("##longitude1").val(results[0].geometry.location.lng());
			executeParentCallback(results[0].geometry.location.lat(), results[0].geometry.location.lng());

		}else{
			alert("The address couldn't be mapped, please check your input and try again.");
		}
	}
	function markerButtonClick(){
		if(typeof currentGoogleMap != "boolean"){
			var address=$("##address1").val();
			if(address.length == ""){ 
				alert("You must enter a valid street address.");
				return; 
			}
			var geocoder = new google.maps.Geocoder();
			geocoder.geocode( { 'address': address}, mapUpdatePosition);
		}
	}
	function centerMapButtonClick(){
		if(typeof currentGoogleMap != "boolean"){
			var p=currentMarker.getPosition();
			currentGoogleMap.panTo(p);
		}
	}
	function setInterfaceSize(){
		if(zWindowSize.width < 700){
			$("##address1").css("width", Math.max(120, (zWindowSize.width-200))+"px");
		}else{
			$("##address1").css("width", "65%");
		}
		$("##mapDivId").css("height", (zWindowSize.height-140)+"px");
	}
	function setMapSize(){
		setInterfaceSize();
		if(typeof currentGoogleMap != "boolean"){
			google.maps.event.trigger(currentGoogleMap, 'resize'); 
			currentGoogleMap.panTo(currentMarker.getPosition());
		}
	}
	var currentMarker=0;
	function onGMAPLoad2(){ 
		$("##centerMapButton").bind("click", centerMapButtonClick);
		$("##setMarkerButton").bind("click", markerButtonClick);

		var optionsObj={ 
			zoom: 13,
		};
		var markerObj={ 
			draggable: true,
			bindEvents: { 
				dragend: markerDragEndCallback 
			}
		 };
		setInterfaceSize(); 

		if(currentCoordinates!="" && currentCoordinates.indexOf(",") != -1){
			var arrC=currentCoordinates.split(","); 
			var mapData=zCreateMapWithLatLng("mapDivId", arrC[0], arrC[1], optionsObj, mapSuccessCallback3, markerObj);
		}else{
			if(currentMapAddress==""){
				currentMapAddress="1st St SE Washington, D.C., DC 20004";
				$("##address1").val(currentMapAddress);
			}
			var mapData=zCreateMapWithAddress("mapDivId", currentMapAddress, optionsObj, mapSuccessCallback2, markerObj);  
		} 
		currentMarker=mapData.marker;
		currentGoogleMap=mapData.map;
	}
	zArrMapFunctions.push(function(){ 
		onGMAPLoad2();
	});
	/* ]]> */
	</script> 
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("scripts", local.scriptOutput); 
	</cfscript>
	<div style="min-width:320px; width:100%; float:left;">
		<div style="width:100%; padding-bottom:5px; float:left;">
			Directions: After confirming the map location is correct below, click close and save the record you're editing to save the new map coordinates.  If the location is not correct, you can search for a new address OR click and drag the pin to the correct location.
			<br /><input type="text" placeholder="Type Street Address" name="address" id="address1" style="width:62%;" value="#htmleditformat(form.address)#" /> <input type="button" name="submit1" id="setMarkerButton" value="Search" /> <input type="button" name="submit2" id="centerMapButton" value="Center Map" />
		</div>
		<div id="mapContainerDiv" style="width:100%; float:left;">
			<div style="width:100%; float:left;height:200px;" id="mapDivId"></div>
		</div>
		<div style="width:100%; float:left; padding-top:5px;">
		Latitude: <input type="text" name="latitude" id="latitude1" style="width:80px;" value="" /> 
		Longitude: <input type="text" name="longitude" id="longitude1" style="width:80px;" value="" />  
		</div>
	</div>
</cffunction>
</cfoutput>
</cfcomponent>