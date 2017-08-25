<cfcomponent>
<cfoutput>
<!--- 
/z/misc/weather/index?zip=32174&forecastLink=1&currentOnly=0&overrideStyles=0
 --->
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	application.zcore.tracking.backOneHit();
	ts=StructNew();
	ts.zip=application.zcore.functions.zso(form, 'zip'); 
	if(ts.zip EQ "" or not isnumeric(ts.zip)){
		application.zcore.functions.z404("Invalid zip code format");
	}
	if(application.zcore.functions.zso(form, 'forecastLink', true, 0) EQ 1){
		ts.forecastLink=true;
	}else{
		ts.forecastLink=false;
	}
	if(application.zcore.functions.zso(form, 'currentOnly', true, 0) EQ 1){
		ts.currentOnly=true;
	}else{
		ts.currentOnly=false;
	}
	if(application.zcore.functions.zso(form, 'overrideStyles', true, 0) EQ 1){
		ts.overrideStyles=true;
	}else{
		ts.overrideStyles=false;
	}
	weatherHTML=application.zcore.functions.zGetWeather(ts);

	rs={
		html:weatherHTML,
		data:request.zLastWeatherLookup
	};
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>

<cffunction name="current" localmode="modern" access="remote">
	<cfscript>
	
</cfscript>
	<h2>Current Weather in 32174</h2>
	<div class="zGetWeather" data-zip="32174" data-currentonly="" data-override-styles="" data-forecast-link=""></div>
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		$(".zGetWeather").each(function(){

			/*
			var ts={
				id:"zGeocodeQueue",
				method:"get",
				url:"/z/misc/geocode/getAjaxGeocode",
				callback:function(r){
					var r=JSON.parse(r);
					if(r.success){
						zGeocode.arrAddress=r.arrAddress;
						zGeocode.arrKey=r.arrKey;
						zGeocodeCacheAddress(); 
					}else{
						echo('getAjaxGeocode: fail');
					}
				},
				cache:false
			};  
			zAjax(ts);
							ts=StructNew();
							ts.zip="32746";
							//ts.forecastLink=true;
							ts.currentOnly=true;
							//ts.overrideStyles=false;
							weatherHTML=request.zos.functions.zGetWeather(ts);
							if(structkeyexists(request,'zLastWeatherLookup') and structkeyexists(request.zLastWeatherLookup, 'temperature')){
								writeoutput(request.zLastWeatherLookup.temperature&'&deg;');	
							}else{
								writeoutput(weatherHTML); 
							}*/
		});
	});
	</script>
</cffunction>
</cfoutput>
</cfcomponent>