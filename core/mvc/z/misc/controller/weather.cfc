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
	ts.timeout=10;
	weatherHTML=application.zcore.functions.zGetWeather(ts);

	rs={
		success:true,
		html:weatherHTML,
		data:request.zLastWeatherLookup
	};
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>

<cffunction name="current" localmode="modern" access="remote"> 
	<h2>Current Weather in 32174</h2>
	<div class="z-float zGetWeather" data-zip="32174" data-currentonly="" data-override-styles="" data-forecast-link=""></div>
	 
</cffunction>
</cfoutput>
</cfcomponent>