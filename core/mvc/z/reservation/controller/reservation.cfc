<cfcomponent>
<cfoutput>
<cfscript>
this.app_id=16;
</cfscript>
<!--- 
Allow adding custom fields to reservation_type_id so that you can add reservation with those fields in site manager and also support other form element types.  and set default values for all records...
	

Reservation Options for a service
	must be able to set rates per reservation_type_id

	reservation_price
		reservation_price_start_datetime
		reservation_price_end_datetime
	
allowed_reservation_type_list - multiple select of reservation_type_id - which are site specific

			
	reservation_period_type_name event | hourly | nightly | weekly | monthly | yearly

if(reservation_period_type_name EQ "event"){
	use event_id for display purposes
}else if(reservation_period_type_name EQ "hourly"){
	use time in reservation_start_datetime and reservation_end_datetime
}else{
	ignore time
}


reservation_allowed_hours  - add more then one for the same day if there is lunch break, etc.
	reservation_allowed_hours_id
	reservation_type_id // 0 for global settings, otherwise it will allow overriding the settings for a specific reservation type
	reservation_allowed_hours_day_of_week (monday through sunday)
	reservation_allowed_hours_start_time
	reservation_allowed_hours_end_time
	reservation_allowed_hours_all_day char(1) 0 // allows availability search to be more efficient when time comparison is not required.
	reservation_allowed_hours_updated_datetime
	reservation_allowed_hours_deleted
	site_id
reservation_excluded_hours  - Used to disable times or entire days from being booked
	reservation_excluded_hours_id
	reservation_type_id // 0 for global settings, otherwise it will allow overriding the settings for a specific reservation type
	reservation_excluded_hours_date
	reservation_excluded_hours_start_time
	reservation_excluded_hours_end_time
	reservation_excluded_hours_all_day char(1) 0 // allows availability search to be more efficient when time comparison is not required.
	reservation_excluded_hours_updated_datetime
	reservation_excluded_hours_deleted
	site_id

reservation_payment_type
	reservation_payment_type_id
	reservation_type_id
	reservation_payment_type_amount
	reservation_payment_type_title
	reservation_payment_type_description
	reservation_payment_type_updated_datetime
	reservation_payment_type_deleted
	site_id
	
validation rules for custom fields.
	i.e. max guests, min guests, pets, adults, children, 

how could reservation be used for an event instead of letting user select any time?

reservation siteOptionType
	select fields for start / end date, date description, title, etc?

	link any record with a reservation
		type options
			Period (event/hourly etc)
			For Event Only:
				Start Date: 
				End Date: 
			Map Fields:
				Title: field
				Date Description: 
		reservation_type_id_list

	site_x_option_group_set_x_reservation
		site_x_option_group_set_x_reservation_id
		site_x_option_group_set_id
		reservation_id
		site_x_option_group_set_x_reservation_updated_datetime
		site_x_option_group_set_x_reservation_deleted
		site_id


	select * from reservation 
	left join on 
	site_x_option_group_set_x_reservation s1 ON 
	reservation.reservation_id = s1.reservation_id and 
	reservation.site_id = s1.site_id and 
	s1.site_x_option_group_set_x_reservation_deleted = #db.param(0)# 
	left join on 
	site_x_option_group_set s2 ON 
	s1.site_x_option_group_set_id = s2.site_x_option_group_set_id and 
	s2.site_id = s1.site_id and 
	s2.site_x_option_group_set_deleted = #db.param(0)# 
	
	// loop each search field as a left join
	

Where "Associate With Apps" is, add a new field called "Associate With Reservation Types" when application.zcore.app.siteHasApp("reservation")
	Add these fields:
		site_option_reservation_type_id_list
		site_option_group_reservation_type_id_list



Another idea is to let the user modify / cancel their own reservation as a feature from the email alert or reservation ID + email address.  I wouldn't do this feature yet unless required.

 --->
<cffunction name="onSiteStart" localmode="modern" output="no" access="public"  returntype="struct" hint="Runs on application start and should return arguments.sharedStruct">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	return arguments.sharedStruct;
	</cfscript>
</cffunction>

<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	ts=application.zcore.app.getInstance(this.app_id);
	db=request.zos.queryObject;
	return arguments.arrURL;
	</cfscript>
</cffunction>


<cffunction name="getReservationTypeDateRange" localmode="modern" output="no" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ss=arguments.struct;
	savecontent variable="out"{
		if(ss.reservation_type_period EQ "event"){
			throw("event date description not implemented");
		}else if(ss.reservation_type_period EQ "hourly"){
			s=dateformat(ss.reservation_type_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_type_end_datetime, "m/d/yyyy");
			echo(timeformat(ss.reservation_type_start_datetime, "h:mm tt")&" to "&timeformat(ss.reservation_type_end_datetime, "h:mm tt")&" on "&s);
			if(ss.reservation_type_forever EQ 1){
				echo(" until forever");
			}else{
				if(s NEQ e){
					echo(" through "&e);
				}
			}
		}else{
			s=dateformat(ss.reservation_type_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_type_end_datetime, "m/d/yyyy");
			echo(s&" to "&e);
		}
	}
	return out;
	</cfscript>
</cffunction>


<cffunction name="getReservationTypeByName" localmode="modern" access="public">
	<cfargument name="reservation_type_name" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="select * from #db.table("reservation_type", request.zos.zcoreDatasource)# 
	WHERE reservation_type_name = #db.param(arguments.reservation_type_name)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	reservation_type_deleted = #db.param(0)# and 
	reservation_type_status = #db.param(1)# ";
	qType=db.execute("qType"); 
	for(row in qType){
		return row;
	}
	throw("reservation_type_name=#arguments.reservation_type_name# is not available or doesn't exist.");
	</cfscript>
	
</cffunction>

<cffunction name="getReservationTypeById" localmode="modern" access="public">
	<cfargument name="reservation_type_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="select * from #db.table("reservation_type", request.zos.zcoreDatasource)# 
	WHERE reservation_type_id = #db.param(arguments.reservation_type_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	reservation_type_deleted = #db.param(0)# and 
	reservation_type_status = #db.param(1)# ";
	qType=db.execute("qType"); 
	for(row in qType){
		return row;
	}
	throw("reservation_type_id=#arguments.reservation_type_id# is not available or doesn't exist.");
	</cfscript>
</cffunction>

<!--- 

/z/reservation/reservation/ajaxCheckAvailability
 --->
<cffunction name="ajaxCheckAvailability" localmode="modern" access="remote">
	<cfscript>
	form.reservation_type_id=application.zcore.functions.zso(form, 'reservation_type_id');
	form.reservation_type_name=application.zcore.functions.zso(form, 'reservation_type_name');
	form.reservation_start_datetime=application.zcore.functions.zso(form, 'reservation_start_datetime');
	form.reservation_end_datetime=application.zcore.functions.zso(form, 'reservation_end_datetime');
	form.event_id=application.zcore.functions.zso(form, 'event_id');
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	
	t1=isDateRangeAvailable(form);
	application.zcore.functions.zReturnJson(t1);
	</cfscript>
</cffunction>


<!--- 
ts={
	reservation_type_id=application.zcore.functions.zso(form, 'reservation_type_id'),
	// or 
	reservation_type_name=application.zcore.functions.zso(form, 'reservation_type_name'),

	reservation_start_datetime=application.zcore.functions.zso(form, 'reservation_start_datetime'),
	reservation_end_datetime=application.zcore.functions.zso(form, 'reservation_end_datetime'),

	event_id=application.zcore.functions.zso(form, 'event_id')
	// or
	site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id')
}
if(not application.zcore.app.getAppCFC("reservation").checkAvailability(ts)){
	application.zcore.status.setStatus(request.zsid, "Not available", form, true);
	application.zcore.functions.zRedirect();
}
 --->
<cffunction name="checkAvailability" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ss=arguments.struct;
	ss.reservation_type_id=application.zcore.functions.zso(ss, 'reservation_type_id');
	ss.reservation_type_name=application.zcore.functions.zso(ss, 'reservation_type_name');
	ss.reservation_start_datetime=application.zcore.functions.zso(ss, 'reservation_start_datetime');
	ss.reservation_end_datetime=application.zcore.functions.zso(ss, 'reservation_end_datetime');
	ss.event_id=application.zcore.functions.zso(ss, 'event_id');
	ss.site_x_option_group_set_id=application.zcore.functions.zso(ss, 'site_x_option_group_set_id');

	t1=isDateRangeAvailable(ss);
	return t1;
	</cfscript>
</cffunction>

<cffunction name="isDateRangeAvailable" localmode="modern" access="public" returntype="struct">
	<cfargument name="searchStruct" type="struct" required="yes">

	<cfscript>
	os=application.zcore.app.getAppData("reservation").optionStruct;
	ss=arguments.searchStruct;
	ssDefault={
		site_x_option_group_set_id:"",
		event_id:"",
		reservation_type_id:"",
		reservation_type_name:""
	}
	structappend(ss, ssDefault, false);
	if(not structkeyexists(ss, 'reservation_start_datetime') or not isdate(ss.reservation_start_datetime)){
		t1={
			errorMessage:"Reservation start date/time is not a valid date.",
			success:false
		};
		return t1;
	}
	if(not structkeyexists(ss, 'reservation_end_datetime') or not isdate(ss.reservation_end_datetime)){
		t1={
			errorMessage:"Reservation end date/time is not a valid date.",
			success:false
		};
		return t1;
	}
	try{
		if(ss.reservation_type_id NEQ ""){
			ts=getReservationTypeById(ss.reservation_type_id);
		}else if(ss.reservation_type_name NEQ ""){
			ts=getReservationTypeByName(ss.reservation_type_name);
		}else{
			throw("Missing reservation type");
		}
	}catch(Any e){
		t1={
			errorMessage:"Reservation Type doesn't exist.",
			success:false
		};
		return t1;
	}
	if(ts.reservation_type_minimum_hours_before_reservation NEQ 0 and datecompare(dateadd("h", ts.reservation_type_minimum_hours_before_reservation, now()), ss.reservation_start_datetime) EQ 1){
		return {
			errorMessage:"The reservation must be at least #ts.reservation_type_minimum_hours_before_reservation# hours in the future.",
			success:false
		};
	}else if(os.reservation_config_soonest_reservation_days NEQ 0 and datecompare(dateadd("d", os.reservation_config_soonest_reservation_days, now()), ss.reservation_start_datetime) EQ 1){
		return {
			errorMessage:"The reservation must be at least #os.reservation_config_soonest_reservation_days# days in the future.",
			success:false
		};
	}
	if(os.reservation_config_furthest_reservation_days NEQ 0 and datecompare(ss.reservation_start_datetime, dateadd("d", os.reservation_config_furthest_reservation_days, now())) GTE 0){
		return {
			errorMessage:"The reservation must be less then #os.reservation_config_furthest_reservation_days# days in the future.",
			success:false
		};
	}
	if(datecompare(ss.reservation_start_datetime, ts.reservation_type_start_datetime) LTE 0){
		return {
			errorMessage:"The reservation start date must be on or after #dateformat(ts.reservation_type_start_datetime, "m/d/yyyy")#.",
			success:false
		};
	}
	if(ts.reservation_type_forever EQ 0 and datecompare(ss.reservation_end_datetime, ts.reservation_type_end_datetime) GTE 0){
		return {
			errorMessage:"The reservation end date must be on or before #dateformat(ts.reservation_type_end_datetime, "m/d/yyyy")#.",
			success:false
		};
	}
	if(ts.reservation_type_max_guests NEQ 0 and ss.reservation_guests GT ts.reservation_type_max_guests){
		return {
			errorMessage:"There can be no more then #ts.reservation_type_max_guests# guests per reservation.",
			success:false
		};
	}
	if(ts.reservation_type_period EQ "hourly"){
		return isDateRangeAvailableHourly(ts, ss);
	}else if(ts.reservation_type_period EQ "event"){
		throw("not implemented");
	}else{
		// nightly/weekly/monthly
		throw("not implemented");
	}
	</cfscript>
</cffunction>

<cffunction name="getAvailabilityStruct" localmode="modern" access="public" returntype="struct">
	<cfscript>
	ds=application.zcore.app.getAppData("reservation");
	if(not structkeyexists(ds, 'availabilityStruct')){
		ds.availabilityStruct={
			eventCache:{},
			siteOptionGroupCache:{}
		};
	}
	return ds;
	</cfscript>
</cffunction>
	
<cffunction name="isDateRangeAvailableEvent" localmode="modern" access="private" returntype="struct">
	<cfargument name="reservationTypeStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	os=application.zcore.app.getAppData("reservation").optionStruct;
	ts=arguments.reservationTypeStruct;
	ss=arguments.searchStruct;
	ds=getAvailabilityStruct();
	throw("not implemented");
	</cfscript>
</cffunction>

<cffunction name="isDateRangeAvailableHourly" localmode="modern" access="private" returntype="struct">
	<cfargument name="reservationTypeStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>

	os=application.zcore.app.getAppData("reservation").optionStruct;
	ts=arguments.reservationTypeStruct;
	ss=arguments.searchStruct;
	ds=getAvailabilityStruct();
	
	startTime=int(timeformat(ss.reservation_start_datetime, 'HHmm'));
	endTime=int(timeformat(ss.reservation_end_datetime, 'HHmm'));
	if(startTime>endTime){
		return {
			errorMessage:"The reservation start date must be before the end date.",
			success:false
		};
	}
	reservationLength=(endTime-startTime)/100;
	if(reservationLength LT ts.reservation_type_minimum_length){
		return {
			errorMessage:"The minimum reservation length is #ts.reservation_type_minimum_length# hours.",
			success:false
		};
	}else if(reservationLength GT ts.reservation_type_maximum_length){
		return {
			errorMessage:"The maximum reservation length is #ts.reservation_type_maximum_length# hours.",
			success:false
		};
	}

	if(ss.site_x_option_group_set_id EQ "" and ss.event_id EQ ""){
		return {
			errorMessage:"Invalid availability search request",
			success:true
		};
	}
	if(application.zcore.app.getAppData("reservation").optionstruct.reservation_config_availability_in_memory EQ "1"){

		if(ss.site_x_option_group_set_id NEQ ""){
			if(structkeyexists(ds.availabilityStruct.siteOptionGroupCache, ss.site_x_option_group_set_id)){
				setStruct=ds.availabilityStruct.siteOptionGroupCache[ss.site_x_option_group_set_id];
				startDay=dateformat(ss.reservation_start_datetime, 'yyyy-mm-dd');
				if(not structkeyexists(setStruct, startDay)){
					return {
						errorMessage:"",
						success:true
					};
				}else{
					reservationCount=0;
					for(i in setStruct[startDay]){
						r=setStruct[startDay][i];
						if(endTime GT r.startTime and startTime LT r.endTime){
							reservationCount++;
							if(reservationCount GTE ts.reservation_type_max_reservations){
								if(ts.reservation_type_max_reservations EQ 1){
									return {
										errorMessage:"A reservation already exists for this time. Please select another time.",
										success:false
									};
								}else{
									return {
										errorMessage:"The maximum number of reservations has been met for this time. Please select another time.",
										success:false
									};
								}
							}
						}
					}
					return {
						errorMessage:"",
						success:true
					};
				}
			}else{
				return {
					errorMessage:"",
					success:true
				};
			}
		}else if(ss.event_id NEQ ""){
			throw("in memory search not implemented yet");
		}
	}else{
		db=request.zos.queryObject; 
		if(ss.site_x_option_group_set_id NEQ ""){
			db.sql="SELECT count(site_x_option_group_set_id) count FROM 
			#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
			site_id = #db.param(request.zos.globals.id)# and 
			site_x_option_group_set_master_set_id = #db.param(0)# and 
			site_x_option_group_set_id = #db.param(ss.site_x_option_group_set_id)# and 
			site_x_option_group_set_deleted=#db.param(0)# ";
			qSet=db.execute("qSet");
			if(qSet.count EQ 0){
				return {
					errorMessage:"The associated record for this reservation doesn't exist.",
					success:false
				};
			}
		}else if(ss.event_id NEQ ""){
			throw("Not implemented");
		}else{
			throw("arguments.searchStruct.site_x_option_group_set_id or arguments.searchStruct.event_id is required.");
		}
		db=request.zos.queryObject; 
		db.sql="SELECT count(reservation_id) count FROM 
		#db.table("reservation", request.zos.zcoreDatasource)# reservation
		WHERE ";
		if(ss.site_x_option_group_set_id NEQ ""){
			db.sql&=" site_x_option_group_set_id = #db.param(ss.site_x_option_group_set_id)# and ";
		}else if(ss.event_id NEQ ""){
			db.sql&=" event_id = #db.param(ss.event_id)# and ";
		}
		db.sql&=" reservation.site_id = #db.param(request.zOS.globals.id)# and 
		reservation.reservation_deleted = #db.param(0)# and 
		reservation_end_datetime > #db.param(dateformat(ss.reservation_start_datetime, 'yyyy-mm-dd')&' '&timeformat(ss.reservation_start_datetime, "HH:mm:ss"))# and
		reservation_start_datetime < #db.param(dateformat(ss.reservation_end_datetime, 'yyyy-mm-dd')&' '&timeformat(ss.reservation_end_datetime, "HH:mm:ss"))# and 
		reservation_status = #db.param(1)#";
		qCount=db.execute("qCount");
		//writedump(qCount);
		if(qCount.count GTE ts.reservation_type_max_reservations){
			if(ts.reservation_type_max_reservations EQ 1){
				return {
					errorMessage:"A reservation already exists for this time. Please select another time.",
					success:false
				};
			}else{
				return {
					errorMessage:"The maximum number of reservations has been met for this time. Please select another time.",
					success:false
				};
			}
		}
	}
	return {
		errorMessage:"",
		success:true
	};
	</cfscript>
</cffunction>



<cffunction name="getPublicCalendarJsonForDateRange" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.zNoCache();
	form.start=application.zcore.functions.zso(form, 'start');
	form.end=application.zcore.functions.zso(form, 'end');
	form.reservation_type_name=application.zcore.functions.zso(form, 'reservation_type_name');
	form.reservation_type_id=application.zcore.functions.zso(form, 'reservation_type_id');
	form.event_id=application.zcore.functions.zso(form, 'event_id');
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	db=request.zos.queryObject;
	if(form.reservation_type_name NEQ ""){
		typeStruct=getReservationTypeByName(form.reservation_type_name);
	}else if(form.reservation_type_id NEQ ""){
		typeStruct=getReservationTypeById(form.reservation_type_id);
	}else{
		application.zcore.functions.z404("A valid active reservation type must be specified using form.reservation_type_name or form.reservation_type_id.");
	}
	
	db.sql="select * from 
	#request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation   
	WHERE reservation.site_id = #db.param(request.zOS.globals.id)# and 
	reservation.reservation_type_id = #db.param(typeStruct.reservation_type_id)# and 
	reservation.reservation_deleted = #db.param(0)# and 
	reservation_end_datetime >= #db.param(form.start)# and
	reservation_start_datetime <= #db.param(form.end)#  ";
	if(form.event_id NEQ ""){
		db.sql&=" and event_id = #db.param(form.event_id)# ";
	}else if(form.site_x_option_group_set_id NEQ ""){
		db.sql&=" and site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
	}
	qCalendar=db.execute("qCalendar");
	arrJ=[];
	for(row in qCalendar){
		ts={
			title:"Unavailable",
			start:dateformat(row.reservation_start_datetime,"yyyy-mm-dd")&"T"&timeformat(row.reservation_start_datetime, "HH:mm:ss")
		}
		if(datecompare(dateadd("h", typeStruct.reservation_type_minimum_hours_before_reservation,now()), row.reservation_start_datetime) LTE 0){
			ts.reservable=1;
			ts.date=dateformat(row.reservation_start_datetime,"yyyy-mm-dd");
		}else{
			ts.reservable=0;
		}
		if(row.reservation_start_datetime NEQ row.reservation_end_datetime){
			ts.end=dateformat(row.reservation_end_datetime,"yyyy-mm-dd")&"T"&timeformat(row.reservation_end_datetime, "HH:mm:ss");
		}
		arrayAppend(arrJ, ts);
	}
	application.zcore.functions.zReturnJson(arrJ);
	</cfscript>
</cffunction>
	

<cffunction name="getStatusName" localmode="modern" access="public">
	<cfargument name="reservation_status_id" type="numeric" required="yes">
	<cfscript>
	if(arguments.reservation_status_id EQ 0){
		return "Pending Approval";
	}else if(arguments.reservation_status_id EQ 1){
		return "Approved";
	}else if(arguments.reservation_status_id EQ 2){
		return "Cancelled";
	}else{
		return "";
	}
	</cfscript>
</cffunction>
	
<cffunction name="getTypeStatusName" localmode="modern" access="public">
	<cfargument name="reservation_type_status_id" type="numeric" required="yes">
	<cfscript>
	if(arguments.reservation_type_status_id EQ 0){
		return "Inactive";
	}else if(arguments.reservation_type_status_id EQ 1){
		return "Active";
	}else{
		return "";
	}
	</cfscript>
</cffunction>

<cffunction name="rebuildMemoryCache" localmode="modern" access="private">
	<cfscript>
	
	availabilityStruct={
		eventCache:{},
		siteOptionGroupCache:{}
	};
	db.sql="SELECT count(reservation_id) count FROM 
	#db.table("reservation", request.zos.zcoreDatasource)# reservation WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	reservation_status = #db.param(1)# and 
	reservation_deleted = #db.param(0)#";
	qReserve=db.execute("qReserve");
	for(row in qReserve){
		if(not structkeyexists(availabilityStruct.siteOptionGroupCache, row.site_x_option_group_set_id)){
			availabilityStruct.siteOptionGroupCache[row.site_x_option_group_set_id]={};
		}
		if(row.reservation_period EQ "hourly"){
			availabilityStruct.siteOptionGroupCache[row.site_x_option_group_set_id][dateformat(row.reservation_start_datetime, 'yyyy-mm-dd')]={
				startTime:int(timeformat(row.reservation_start_datetime, 'HHmm')),
				endTime:int(timeformat(row.reservation_end_datetime, 'HHmm'))
			};
		}else if(row.reservation_period EQ "event"){

		}
	}
	ds=application.zcore.app.getAppData("reservation");
	ds.availabilityStruct=availabilityStruct;
	</cfscript>
</cffunction>

	
<!--- 
ts{
	reservation_type_name:"type"
	// or
	reservation_type_id:1
	struct: form,

};
rs=application.zcore.app.getAppCFC("reservation").publicNewReservation(ts);
if(not rs.success){
	application.zcore.functions.zRedirect("/error-url?zsid=#request.zsid#");
}
 --->
<cffunction name="publicNewReservation" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	var myForm=structnew(); 
	formStruct={
		reservation_first_name:"",
		reservation_last_name:"",
		reservation_email:"",
		reservation_phone:"",
		reservation_comments:"",
		reservation_start_datetime:"",
		reservation_end_datetime:"",
		reservation_updated_datetime:"",
		site_id:"",
		reservation_created_datetime:"",
		reservation_guests:"",
		reservation_search:"",
		reservation_status:"",
		reservation_type_id:"",
		reservation_custom_json:"",
		reservation_period:"",
		event_id:"",
		site_x_option_group_set_id:"",
		reservation_key:"",
		reservation_destination_title:"",
		reservation_destination_url:"",
		reservation_destination_address:"",
		reservation_destination_address2:"",
		reservation_destination_city:"",
		reservation_destination_state:"",
		reservation_destination_zip:"",
		reservation_destination_country:""
	};
	ssDefault={
		reservation_type_name:"",
		reservation_type_id:""
	};

	ss=arguments.struct;
	structappend(ss, ssDefault, false);
	structAppend(ss.struct, formStruct, false);
	try{
		if(ss.reservation_type_name NEQ ""){
			typeStruct=getReservationTypeByName(ss.reservation_type_name);
		}else if(ss.reservation_type_id NEQ ""){
			typeStruct=getReservationTypeById(ss.reservation_type_id);
		}else{
			application.zcore.functions.z404("A valid active reservation type must be specified using arguments.struct.reservation_type_name or arguments.struct.reservation_type_id.");
		}
	}catch(Any e){
		application.zcore.status.setStatus(request.zsid, "Reservation type is missing", ss.struct, true);
		return {
			zsid:request.zsid,
			success:false
		};
	}
	ss.struct.reservation_type_id=typeStruct.reservation_type_id;
	ss.struct.reservation_status=typeStruct.reservation_type_new_reservation_status;

	ss.struct.reservation_search=ss.struct.reservation_first_name&" "&ss.struct.reservation_last_name&" "&ss.struct.reservation_email&" "&ss.struct.reservation_phone&" "&ss.struct.reservation_comments;
	ss.struct.reservation_search=application.zcore.functions.zCleanSearchText(ss.struct.reservation_search, true);
	ss.struct.reservation_created_datetime=request.zos.mysqlnow;
	
	ss.struct.reservation_period=typeStruct.reservation_type_period; 
	myForm.reservation_phone.required=true;
	myForm.reservation_email.required=true;
	myForm.reservation_email.email=true;
	myForm.reservation_last_name.required=true;
	myForm.reservation_start_datetime.required=true;
	myForm.reservation_end_datetime.required=true;
	errors=application.zcore.functions.zValidateStruct(ss.struct, myForm, request.zsid, true);
	 
	ss.struct.reservation_updated_datetime=request.zos.mysqlnow;
	ss.struct.site_id=request.zos.globals.id;
	ss.struct.reservation_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256');

	ss.struct.reservation_custom_json=serializeJson(ss.struct.reservation_custom_json);

	rs=application.zcore.app.getAppCFC("reservation").checkAvailability(ss.struct);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, rs.errorMessage, ss.struct, true);
		return {
			zsid:request.zsid,
			success:false
		};
	}

	if(errors){
		application.zcore.status.setStatus(request.zsid, false, ss.struct, true);
		return {
			zsid:request.zsid,
			success:false
		};
	}
	
	ts=StructNew();
	ts.table="reservation";
	ts.struct={};
	for(i in formStruct){
		ts.struct[i]=ss.struct[i];
	}
	ts.datasource=request.zos.zcoreDatasource;
	reservation_id = application.zcore.functions.zInsert(ts);
	if(reservation_id EQ false){
		application.zcore.status.setStatus(request.zsid, "Reservation couldn't be added at this time.",ss.struct,true);
		return {
			zsid:request.zsid,
			success:false
		};
	}else{ 

		sendReservationEmail(reservation_id, "new");

		return {
			reservation_id:reservation_id,
			success:true
		};
	}
	</cfscript>
</cffunction>


<cffunction name="getReservationEmailHTML" localmode="modern" access="public">
	<cfargument name="reserveStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	row=arguments.reserveStruct;
	</cfscript>
	<cfsavecontent variable="out">
	<table style="width:100%; border-spacing:0px;">
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Status:</th>
			<td>#getStatusName(row.reservation_status)#</td>
		</tr>
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Period:</th>
			<td>#row.reservation_period#</td>
		</tr>
		<cfif row.reservationTypeValue NEQ "">
			<tr>
				<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">#application.zcore.functions.zFirstLetterCaps(row.reservation_type_name)#:</th>
				<td>#row.reservationTypeValue#</td>
			</tr>
		</cfif>
		<tr>
			<th style="width:1%; text-align:left;width:1%;white-space:nowrap; vertical-align:top;">Reservation:</th>
			<td>#getReservationDateRange(row)#</td>
		</tr>
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">First Name: </th>
			<td>#row.reservation_first_name#</td>
		</tr>
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Last Name: </th>
			<td>#row.reservation_last_name#</td>
		</tr>
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Email: </th>
			<td>#row.reservation_email#</td>
		</tr> 
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Phone: </th>
			<td>#row.reservation_phone#</td>
		</tr> 
		<cfif row.reservation_company NEQ "">
			<tr>
				<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Company: </th>
				<td>#row.reservation_company#</td>
			</tr> 
		</cfif>
		<cfif row.reservation_comments NEQ "">
			<tr>
				<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Comments: </th>
				<td>#row.reservation_comments#</textarea></td>
			</tr> 
		</cfif>
		<cfscript>
		customStruct=deserializeJson(row.reservation_custom_json);
		</cfscript>
		<cfif structcount(customStruct)>
			<cfscript>
			index=1;
			for(fieldName in customStruct){
				value=customStruct[fieldName];
				echo('<tr><th style="width:1%; text-align:left; white-space:nowrap; vertical-align:top;">'&application.zcore.functions.zFirstLetterCaps(fieldName)&': </th><td>');
				echo(value);
				echo('</td></tr>');
			}
			</cfscript>
		</cfif>
		<cfif row.reservation_destination_title NEQ "">
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Destination Title: </th>
			<td>#row.reservation_destination_title#</td>
		</tr>
		</cfif>
		<cfif row.reservation_destination_url NEQ "">
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Destination URL: </th>
			<td><a href="#row.reservation_destination_url#" target="_blank">#row.reservation_destination_url#</a></td>
		</tr>
		</cfif>
		<cfif row.reservation_destination_address NEQ "">
		<tr>
			<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">Destination Address: </th>
			<td>#row.reservation_destination_address#<br />
			<cfif row.reservation_destination_address2 NEQ "">
				#row.reservation_destination_address2#<br />
			</cfif>
			#row.reservation_destination_city#, #row.reservation_destination_state# #row.reservation_destination_zip# #row.reservation_destination_country#
		</td>
		</tr>
		</cfif>
		<cfif row.reservation_destination_address NEQ "">
			<tr>
				<th style="width:1%; text-align:left;white-space:nowrap; vertical-align:top;">&nbsp;</th>
				<td><a href="https://maps.google.com/maps?q=#urlencodedformat(row.mapSearchAddress)#" target="_blank">Get Directions On Google Maps</a> </td>
			</tr>
		</cfif>
	
	</table>
	<cfif row.reservation_status NEQ 2>
	
		<p><a href="#request.zos.globals.domain#/z/reservation/reservation/cancel?id=#row.reservation_id#&amp;key=#row.reservation_key#">Cancel Reservation</a></p>
	</cfif>
	</cfsavecontent>
	<cfreturn trim(out)>
</cffunction>

<cffunction name="getReservationEmailText" localmode="modern" access="public">
	<cfargument name="reserveStruct" type="struct" required="yes">
	<cfscript>
	row=arguments.reserveStruct;
	savecontent variable="out"{
		echo('Status: #getStatusName(row.reservation_status)#'&chr(10));
		echo('Period:#row.reservation_period#'&chr(10));
		if(row.reservationTypeValue NEQ ""){ 
			echo('#application.zcore.functions.zFirstLetterCaps(row.reservation_type_name)#: #row.reservationTypeValue#'&chr(10));
		}
		echo('Reservation Date: #getReservationDateRange(row)#'&chr(10));
		echo('First Name: #row.reservation_first_name#'&chr(10));
		echo('Last Name: #row.reservation_last_name#'&chr(10));
		echo('Email: #row.reservation_email#'&chr(10));
		echo('Phone: #row.reservation_phone#'&chr(10));
		if(row.reservation_company NEQ ""){
			echo('Company: #row.reservation_company#'&chr(10));
		}
		if(row.reservation_comments NEQ ""){
			echo('Comments: #row.reservation_comments#'&chr(10));
		}
		customStruct=deserializeJson(row.reservation_custom_json);
		if(structcount(customStruct)){
			for(fieldName in customStruct){
				value=customStruct[fieldName];
				echo(application.zcore.functions.zFirstLetterCaps(fieldName)&': '&value&chr(10)); 
			}
		}
		if(row.reservation_destination_title NEQ ""){
			echo('Destination Title: #row.reservation_destination_title#'&chr(10));
		}
		if(row.reservation_destination_url NEQ ""){
			echo('Destination URL: #row.reservation_destination_url#'&chr(10));
		}
		if(row.reservation_destination_address NEQ ""){
			echo('Destination Address: #row.reservation_destination_address##chr(10)#');
			if(row.reservation_destination_address2 NEQ ""){
				echo('#row.reservation_destination_address2##chr(10)#');
			}
			echo('#row.reservation_destination_city#, #row.reservation_destination_state# #row.reservation_destination_zip# #row.reservation_destination_country#'&chr(10)&chr(10));
			echo('Get Directions on Google Maps'&chr(10)&'https://maps.google.com/maps?q=#urlencodedformat(row.mapSearchAddress)#'&chr(10));
		}
		if(row.reservation_status NEQ 2){
			echo('#chr(10)#');
			echo('Cancel Reservation:#chr(10)#');
			echo('#request.zos.globals.domain#/z/reservation/reservation/cancel?id=#row.reservation_id#&key=#row.reservation_key#');
		}
	}
	return trim(out);
	</cfscript>
	
</cffunction>

<cffunction name="cancel" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.zNoCache();
	db=request.zos.queryObject;
	form.reservation_id=application.zcore.functions.zso(form, 'id');
	form.reservation_key=application.zcore.functions.zso(form, 'key');
	if(form.reservation_key EQ ""){
		application.zcore.functions.z404("Invalid request.");
	}
	db.sql="select * from #db.table("reservation", request.zos.zcoreDatasource)# reservation 
	WHERE  
	reservation.site_id = #db.param(request.zos.globals.id)# and 
	reservation.reservation_id = #db.param(form.reservation_id)# and 
	reservation.reservation_status in (#db.param(1)#, #db.param(0)#) and 
	reservation_key=#db.param(form.reservation_key)# and 
	reservation.reservation_deleted=#db.param(0)# ";
	qReservation=db.execute("qReservation");
	application.zcore.template.setTag("title", "Cancel Reservation");
	application.zcore.template.setTag("pagetitle", "Cancel Reservation");
	if(qReservation.recordcount EQ 0){
		echo('This reservation doesn''t exist or has already been cancelled.');
		return;
	}
	if(structkeyexists(form, 'confirm')){
		db.sql="update #db.table("reservation", request.zos.zcoreDatasource)# 
		set 
		reservation_status=#db.param(2)#,
		reservation_updated_datetime =#db.param(request.zos.mysqlnow)# 
		WHERE  
		site_id = #db.param(request.zos.globals.id)# and 
		reservation.reservation_id = #db.param(form.reservation_id)# and 
		reservation_key=#db.param(form.reservation_key)# and 
		reservation_status in (#db.param(1)#, #db.param(0)#) and 
		reservation_deleted=#db.param(0)# ";
		db.execute("qUpdate");

		sendReservationEmail(form.reservation_id, 'cancelled');
		application.zcore.functions.zRedirect("/z/reservation/reservation/cancelConfirm");
	}
	</cfscript>
	<h2>Are you sure you want to cancel this reservation?</h2>
	<p>ID: #qReservation.reservation_id#<br />
	Reservation: 
	<cfscript>
	for(row in qReservation){
		echo(application.zcore.app.getAppCFC("reservation").getReservationDateRange(row));
	}
	</cfscript><br />
	Your Name: #qReservation.reservation_first_name# #qReservation.reservation_last_name#<br />
	Your Email: #qReservation.reservation_email#)</p>

	<h2><a href="/z/reservation/reservation/cancel?confirm=1&amp;id=#qReservation.reservation_id#&amp;key=#qReservation.reservation_key#">Yes</a>&nbsp;&nbsp;&nbsp;
	<a href="/z/reservation/reservation/cancelAbort">No</a> </h2>
</cffunction>

<cffunction name="cancelConfirm" localmode="modern" access="remote">
	<cfscript>
	application.zcore.template.setTag("title", "Reservation cancelled.");
	application.zcore.template.setTag("pagetitle", "Reservation cancelled.");
	</cfscript>
	<p>You may close this window or continue browsing our web site.</p>
</cffunction>
	
<cffunction name="cancelAbort" localmode="modern" access="remote">
	<cfscript>
	application.zcore.template.setTag("title", "Reservation not cancelled.");
	application.zcore.template.setTag("pagetitle", "Reservation not cancelled.");
	</cfscript>
	<p>You may close this window or continue browsing our web site.</p>
</cffunction>



<cffunction name="getEmailAddressesFromList" localmode="modern" access="public" returntype="array">
	<cfargument name="emailIdList" type="string" required="yes">
	<cfargument name="reservationEmail" type="string" required="yes">
	<cfscript>
	arrId=listToArray(arguments.emailIdList, ",");
	uniqueStruct={};
	for(i=1;i LTE arraylen(arrId);i++){
		if(arrId[i] EQ "1"){
			uniqueStruct[request.zos.developerEmailTo]=true;
		}else if(arrId[i] EQ "2"){
			e=application.zcore.functions.zvarso("zofficeemail");
			if(e NEQ ""){
				uniqueStruct[e]=true;
			}
		}else if(arrId[i] EQ "3"){
			uniqueStruct[arguments.reservationEmail]=true;
		}
	}
	return structkeyarray(uniqueStruct);
	</cfscript>
</cffunction>

<cffunction name="sendReservationEmail" localmode="modern" access="public">
	<cfargument name="reservation_id" type="numeric" required="yes">
	<cfargument name="type" type="string" required="yes" hint="Can be: new, updated, or cancelled">
	<cfscript>
	db=request.zos.queryObject;

	if((request.zos.istestserver EQ false or structkeyexists(form, 'forceEmail')) and not structkeyexists(form, 'forceDebug')){
		form.debug=false;
	}else{
		form.debug=true;
	}
	form.site_id=request.zos.globals.id;

	os=application.zcore.app.getAppData("reservation").optionStruct;

	db.sql="select * from #db.table("reservation", request.zos.zcoreDatasource)# reservation, 
	#db.table("reservation_type", request.zos.zcoreDatasource)# reservation_type
	WHERE  
	reservation_type.site_id = reservation.site_id and 
	reservation.reservation_type_id = reservation_type.reservation_type_id and  
	reservation_type.reservation_type_deleted=#db.param(0)# and 
	reservation.site_id = #db.param(request.zos.globals.id)# and 
	reservation.reservation_id = #db.param(arguments.reservation_id)# and  
	reservation.reservation_deleted=#db.param(0)# ";
	qReservation=db.execute("qReservation"); 
	for(row in qReservation){
		arrOut=[];
		arrPlainOut=[];
		ts=StructNew(); 
		if(arguments.type EQ "new"){
			if(os.reservation_config_confirmation_email_list EQ ""){
				return;
			}
			arrEmail=getEmailAddressesFromList(os.reservation_config_confirmation_email_list, row.reservation_email);
			ts.subject=os.reservation_config_email_creation_subject;
			arrayAppend(arrOut, os.reservation_config_email_creation_header);
			arrayAppend(arrPlainOut, application.zcore.functions.zStripHTMLTags(os.reservation_config_email_creation_header));
		}else if(arguments.type EQ "updated"){
			if(os.reservation_config_change_email_list EQ ""){
				return;
			}
			arrEmail=getEmailAddressesFromList(os.reservation_config_change_email_list, row.reservation_email);
			ts.subject=os.reservation_config_email_change_subject;
			arrayAppend(arrOut, os.reservation_config_email_change_header);
			arrayAppend(arrPlainOut, application.zcore.functions.zStripHTMLTags(os.reservation_config_email_change_header));
		}else if(arguments.type EQ "cancelled"){
			if(os.reservation_config_change_email_list EQ ""){
				return;
			}
			arrEmail=getEmailAddressesFromList(os.reservation_config_change_email_list, row.reservation_email);
			row.reservation_status = '2';
			ts.subject=os.reservation_config_email_cancelled_subject;
			arrayAppend(arrOut, os.reservation_config_email_cancelled_header);
			arrayAppend(arrPlainOut, application.zcore.functions.zStripHTMLTags(os.reservation_config_email_cancelled_header));
		}else if(arguments.type EQ "reminder"){
			if(os.reservation_config_change_email_list EQ ""){
				return;
			}
			arrEmail=[row.reservation_email];
			ts.subject=os.reservation_config_email_reminder_subject;
			arrayAppend(arrOut, os.reservation_config_email_reminder_header);
			arrayAppend(arrPlainOut, application.zcore.functions.zStripHTMLTags(os.reservation_config_email_reminder_header));
		}else{
			throw("Type, ""#arguments.type#"", must be new, updated or cancelled");
		}

		row.reservationTypeValue="";
		if(application.zcore.app.siteHasApp("event") and row.event_id NEQ 0){
			db.sql="select event_id, event_name from 
			#db.table("event", request.zos.zcoreDatasource)# event
			WHERE
			event.site_id = #db.param(request.zos.globals.id)# and 
			event.event_deleted=#db.param(0)# and 
			event.event_id = #db.param(row.event_id)# 
			ORDER BY event_name ASC ";
			qEvent=db.execute("qEvent");
			for(row2 in qEvent){
				row.reservationTypeValue=row2.event_name;
			}
		}
		if(row.site_x_option_group_set_id NEQ 0){
			db.sql="select site_x_option_group_set_title, site_x_option_group_set.site_x_option_group_set_id from  
			#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set 
			WHERE site_x_option_group_set.site_id = #db.param(request.zos.globals.id)# and   
			site_x_option_group_set_master_set_id = #db.param(0)# and 
			site_x_option_group_set_deleted=#db.param(0)# and  
			site_x_option_group_set.site_x_option_group_set_id=#db.param(row.site_x_option_group_set_id)# ";
			qSet=db.execute("qSet"); 
			for(row2 in qSet){
				row.reservationTypeValue=row2.site_x_option_group_set_title;
			}
		}
		row.mapSearchAddress="";
		if(row.reservation_destination_address NEQ ""){
			arrAddress=[row.reservation_destination_address];
			if(row.reservation_destination_address2 NEQ ""){
				arrayAppend(arrAddress, row.reservation_destination_address2);
			}
			arrayAppend(arrAddress, row.reservation_destination_city&", "&row.reservation_destination_state&" "&row.reservation_destination_zip&" "&row.reservation_destination_country);
			row.mapSearchAddress=arrayToList(arrAddress, ", ");
		}
		arrayAppend(arrOut, getReservationEmailHTML(row));
		arrayAppend(arrPlainOut, getReservationEmailText(row));


		t1={};
		ts.site_id=request.zos.globals.id;
		
		// change this to be a custom script in the database, so that the variables read in.
		ts.zemail_template_type_name="general";
		request.zTempNewEmailHTML=arrayToList(arrOut, chr(10));
		ts.html=true;
		request.zTempNewEmailPlainText=arrayToList(arrPlainOut, chr(10));
		if(request.zos.globals.emailCampaignFrom EQ ""){
			throw("request.zos.globals.emailCampaignFrom is missing, can't send listing alerts.");
		}
		ts.from=request.zos.globals.emailCampaignFrom;
		/*if(form.debug){
			ts.preview=true;
		}else{
			ts.preview=false;
		}  */
		if(form.debug or request.zos.istestserver){
			ts.to=request.zos.developerEmailTo;
			rCom=application.zcore.email.sendEmailTemplate(ts); 
			if(rCom.isOK() EQ false){
				// user has opt out probably...
				if(form.debug){
					rCom.setStatusErrors(request.zsid);
					application.zcore.functions.zstatushandler(request.zsid); 
				}
			}
		}else{
			if(arrayLen(arrEmail)){
				for(i=1;i LTE arraylen(arrEmail);i++){
					ts.to=arrEmail[i];
					rCom=application.zcore.email.sendEmailTemplate(ts); 
					if(rCom.isOK() EQ false){
						// user has opt out probably...
						if(form.debug){
							rCom.setStatusErrors(request.zsid);
							application.zcore.functions.zstatushandler(request.zsid); 
						}
					}
				}
			}
		}
		/*if(form.debug or request.zos.istestserver){
			emailRS=rCom.getData();
			if(structkeyexists(emailRS, 'emailData')){
				writeoutput(emailRS.emailData.html);
				writeoutput('<pre>'&emailRS.emailData.text&'</pre>');
			}
			writedump(emailRS);
			application.zcore.functions.zabort(); 
		}*/
		return;
	}
	</cfscript>

</cffunction>
	

<cffunction name="getReservationDateRange" localmode="modern" output="no" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ss=arguments.struct;
	savecontent variable="out"{
		if(ss.reservation_period EQ "event"){
			throw("event date description not implemented");
		}else if(ss.reservation_period EQ "hourly"){
			s=dateformat(ss.reservation_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_end_datetime, "m/d/yyyy");
			echo(timeformat(ss.reservation_start_datetime, "h:mm tt")&" to "&timeformat(ss.reservation_end_datetime, "h:mm tt")&" on "&s);
			if(s NEQ e){
				echo(" through "&e);
			}
		}else{
			s=dateformat(ss.reservation_start_datetime, "m/d/yyyy");
			e=dateformat(ss.reservation_end_datetime, "m/d/yyyy");
			echo(s&" to "&e);
		}
	}
	return out;
	</cfscript>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"Reservation") EQ false){
			ts=structnew();
			ts.featureName="Reservations";
			ts.link='/z/reservation/admin/reservation-admin/index';
			ts.children=structnew();
			arguments.linkStruct["Reservation"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["reservation"].children,"Reservations") EQ false){
			ts=structnew();
			ts.featureName="Reservations";
			ts.link="/z/reservation/admin/reservation-admin/index";
			arguments.linkStruct["Reservation"].children["Reservations"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["reservation"].children,"Reservation Types") EQ false){
			ts=structnew();
			ts.featureName="Reservation Types";
			ts.link="/z/reservation/admin/reservation-type/index";
			arguments.linkStruct["Reservation"].children["Reservation Types"]=ts;
		}
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("reservation_config", request.zos.zcoreDatasource)# reservation_config 
	where 
	site_id = #db.param(arguments.site_id)# and 
	reservation_config_deleted = #db.param(0)#";
	qData=db.execute("qData");
	for(row in qData){
		return row;
	}
	throw("reservation_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>


<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	/*
	db.sql="SELECT * FROM #db.table("reservation_config", request.zos.zcoreDatasource)# reservation_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = reservation_config.site_id and 
	reservation_config.site_id = #db.param(arguments.site_id)# and 
	reservation_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig"); 
	loop query="qConfig"{
	}

	*/
	</cfscript>
</cffunction>
	
<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("reservation_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	reservation_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();
	df.reservation_config_confirmation_email_list="1,2,3";
	df.reservation_config_change_email_list="1,2,3";
	df.reservation_config_payment_failure_email_list=1;
	df.reservation_config_destination_on_email=1;
	df.reservation_config_email_reminder_subject='Reservation reminder';
	df.reservation_config_email_reminder_header='This is a friendly reminder regarding your reservation, which is detailed below.';
	df.reservation_config_email_creation_subject='Reservation confirmation email';
	df.reservation_config_email_creation_header='Thanks for making a reservation.  We have received the following information.  If you need to make changes, please use the cancellation link below or contact us.';
	df.reservation_config_email_change_subject='Reservation updated';
	df.reservation_config_email_change_header='We''ve updated your reservation.  The latest details are included below.';
	df.reservation_config_email_cancelled_subject='Reservation cancelled';
	df.reservation_config_email_cancelled_header='Your reservation has been cancelled. The reservation details are included below.';
	df.reservation_config_reminder_days_list="15,7,1";
	df.reservation_config_soonest_reservation_days="1";
	df.reservation_config_furthest_reservation_days="365";
	df.reservation_config_availability_in_memory="0";
	df.reservation_config_new_reservation_status=1;
	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"reservation_config_",""),"_"," ","ALL")));
				application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
			}
		}else{
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
				form[i]=df[i];
			}
		}
	}
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
	<cfscript>
	var ts=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';
	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	
	form.site_id=form.sid;
	/*
	ts=StructNew();
	ts.arrId=arrayNew(1);
	arrayappend(ts.arrId,trim(form.reservation_config_category_url_id));
	ts.site_id=form.site_id;
	ts.app_id=this.app_id;
	rCom=application.zcore.app.reserveAppUrlId(ts);
	if(rCom.isOK() EQ false){
		return rCom;
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();
	}		
	*/
	form.reservation_config_updated_datetime=request.zos.mysqlnow;
	ts.table="reservation_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'reservation_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts); 
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("reservation_config", request.zos.zcoreDatasource)# reservation_config 
		WHERE site_id = #db.param(form.sid)# and 
		reservation_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		/*

		and the email would auto-display the publicly visible fields at the bottom including the reservation info.
		Email needs to be customer specific.  I.e. for location based reservation, it should have it listed along with google map link to the address.
			store address in the reservation?

			*/
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="reservation_config_id" value="#form.reservation_config_id#" />
		<table style="border-spacing:0px;" class="table-list">
		<tr>
		<th>Email Reminder Days:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_reminder_days_list";
		application.zcore.functions.zInput_Text(ts);
		echo(' (The number of days before a reservation to send an email reminder notification.  Leave blank to disable reminder emails.  You can comma separate multiple values. i.e. 15,7,1)</td>
		</tr>
		<tr>
		<th>Soonest Reservation Allowed:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_soonest_reservation_days";
		application.zcore.functions.zInput_Text(ts);
		echo(' (## of days | 0 is unlimited)</td>
		</tr>
		<tr>
		<th>Furthest Reservation Allowed:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_furthest_reservation_days";
		application.zcore.functions.zInput_Text(ts);
		echo(' (## of days | 0 is unlimited)</td>
		</tr> 
		<tr>
			<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("New Reservation Status","member.reservation_type.edit reservation_type_new_reservation_status")#</th>
			<td>');
				selectStruct = StructNew();
				selectStruct.name = "reservation_config_new_reservation_status";
				selectStruct.hideSelect=true; 
				selectStruct.size=1;
				selectStruct.listLabels="Approved,Pending Approval";
				selectStruct.listValues = "1,0";
				application.zcore.functions.zInputSelectBox(selectStruct);
				echo('</td>
		</tr>
		<tr>
		<th>Reminder Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_reminder_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Reminder Email Header:</th>
		<td>');
        htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_reminder_header";
        htmlEditor.value			= form.reservation_config_email_reminder_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>New Reservation Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_creation_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>New Reservation Email Header:</th>
		<td>');
        htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_creation_header";
        htmlEditor.value			= form.reservation_config_email_creation_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>Change Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_change_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Change Email Header:</th>
		<td>');
        htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_change_header";
        htmlEditor.value			= form.reservation_config_email_change_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>Cancelled Email Subject:</th>
		<td>');
		ts = StructNew();
		ts.name = "reservation_config_email_cancelled_subject";
		ts.style="width:100%;";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Cancelled Email Header:</th>
		<td>');
        htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
        htmlEditor.instanceName	= "reservation_config_email_cancelled_header";
        htmlEditor.value			= form.reservation_config_email_cancelled_header;
        htmlEditor.width			= "100%";
        htmlEditor.height		= 300;
        htmlEditor.create();
		echo('</td>
		</tr>
		<tr>
		<th>Show Destination On Email?</th>
		<td>'); 
		ts = StructNew();
		ts.name = "reservation_config_destination_on_email";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' </td>
		</tr>');
		echo('<tr>
		<th>Availability Search In Memory?</th>
		<td>'); 
		ts = StructNew();
		ts.name = "reservation_config_availability_in_memory";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' </td>
		</tr>');
		echo('<tr>
		<th>Reservation Confirmation Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "reservation_config_confirmation_email_list";
		selectStruct.hideSelect=true;
		selectStruct.multiple=true;
		selectStruct.size=3;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');

		echo('<tr>
		<th>Reservation Change Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "reservation_config_change_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator,Customer";
		selectStruct.listValues = "1,2,3";
		selectStruct.multiple=true;
		selectStruct.size=3;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');
		echo('<tr>
		<th>Reservation Payment Failure Email List:</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "reservation_config_payment_failure_email_list";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Developer,Administrator";
		selectStruct.listValues = "1,2";
		selectStruct.multiple=true;
		selectStruct.size=3;
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>');
		
		
		echo('
		
		</table>');
	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>



<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
	var db=request.zos.queryObject; 
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>


</cfoutput>
</cfcomponent>