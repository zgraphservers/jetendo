<cfcomponent> 
<cfoutput>
<cffunction name="importComplete" localmode="modern" roles="serveradministrator">
	<cfscript> 
	if(not request.zos.isDeveloper){
		application.zcore.functions.z404("Only developer can run this.");
	} 
	</cfscript>
	Done. <a href="/z/event/tasks/project-events/index?sid=#request.zos.globals.id#&forceAll=1" target="_blank">Force project recurring event dates</a>
</cffunction>

<cffunction name="importFilter" localmode="modern" roles="serveradministrator">
<cfargument name="struct" type="struct" required="yes">
	<cfscript> 
	var struct=arguments.struct;
	if(not request.zos.isDeveloper){
		application.zcore.functions.z404("Only developer can run this.");
	}  
	ts={};  
	ts.event_calendar_id=application.zcore.functions.zso(form, 'event_calendar_id', true, 0);
	ts["event_name"]=struct.summary;
	ts["event_description"]=struct.description;
	ts["event_start_datetime"]=struct.startdate;
	ts["event_end_datetime"]=struct.enddate;
	if(ts["event_end_datetime"] EQ "" or not isdate(ts["event_end_datetime"])){
		ts["event_end_datetime"]=ts["event_start_datetime"];
	}
	ts["event_end_datetime"]=dateformat(ts["event_end_datetime"], 'yyyy-mm-dd')&' '&timeformat(ts["event_end_datetime"], 'HH:mm:ss');
	if(timeformat(ts["event_end_datetime"], 'HH:mm:ss') EQ "00:00:00" and timeformat(ts["event_start_datetime"], 'HH:mm:ss') EQ "00:00:00"){
		ts["event_start_datetime"]=dateformat(ts["event_start_datetime"], 'yyyy-mm-dd');
		ts["event_end_datetime"]=dateformat(ts["event_end_datetime"], 'yyyy-mm-dd');
		ts.event_allday=1;
	}
	if(ts["event_end_datetime"] EQ ""){
		ts["event_end_datetime"]=ts["event_start_datetime"];
	}
	ts["event_end_datetime"]=struct.enddate;

	if(timeformat(ts["event_start_datetime"], "HHmmss") EQ "000000" and timeformat(ts["event_end_datetime"], "HHmmss") EQ "000000"){
		ts.event_allday=1;
	}else{
		ts.event_allday=0;
	} 
	ts["event_address"]=struct.location;

	ts.site_id=request.zos.globals.id;
	ts.event_uid=struct.uid;
	ts.event_status=1;
	ts.event_timezone="US/Eastern";

	ts.site_id=request.zos.globals.id;
	ts.event_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	ts.event_deleted=0; 
	t9={
		table:"event",
		datasource:request.zos.zcoredatasource,
		struct:ts
	}; 
	t9.struct.event_recur_ical_rules=struct.recurRules;

	t9.struct.event_excluded_date_list=arrayToList(struct.arrExDate, ",");
	
	if(struct.recurRules NEQ ""){
		//writedump(struct);

		t9.struct.event_recur_count=struct.event_recur_count;
		t9.struct.event_recur_interval=struct.event_recur_interval; 
		t9.struct.event_recur_ical_rules=struct.event_recur_ical_rules; 
		t9.struct.event_recur_until_datetime=struct.event_recur_until_datetime; 
		t9.struct.event_recur_frequency=struct.event_recur_frequency;
		if(t9.struct.event_recur_until_datetime NEQ ""){
			if(isdate(t9.struct.event_recur_until_datetime)){
				t9.struct.event_recur_until_datetime=dateformat(t9.struct.event_recur_until_datetime, 'yyyy-mm-dd')&' '&timeformat(t9.struct.event_recur_until_datetime, 'HH:mm:ss');
			}else{
				savecontent variable="out"{
					echo('<h2>Invalid until date format</h2>');
					writedump(struct);
				}
				throw(out);
			}
		} 
	}
	t92={
		table:"event_recur",
		datasource:request.zos.zcoreDatasource,
		struct:{
			event_id:0,
			site_id:request.zos.globals.id,
			event_recur_deleted:0,
			event_recur_datetime:ts.event_updated_datetime,
			event_recur_updated_datetime:ts.event_updated_datetime,
			event_recur_start_datetime:ts.event_start_datetime,
			event_recur_end_datetime:ts.event_end_datetime
		}
	};
	/*writedump(struct);
	writedump(t9); 
	writedump(t92); 
	abort;*/
	event_id=application.zcore.functions.zInsert(t9); 
	t92.struct.event_id=event_id;
	event_recur_id=application.zcore.functions.zInsert(t92);  


	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>