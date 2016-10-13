<cfcomponent>
<cfoutput>
<!--- A geocode caching system, that uses the javascript method the real estate system does, but for the non-real estate clients, so we can queue map coordinate lookup async from when the record is created.  it will execute callback url to update the record when the geocode is complete.  It also tries to secure itself by making it compare 3 different lookups for same address, but from different ips, so it can't be easily abused. --->



<!--- 
Usage:
geocodeCom.processGeocodeQueue(); is called in zRequireGoogleMaps which means any site that uses that function will allow geocoding to occur.


A table needs these 4 fields:
	latitude:"zipcode_latitude",
	longitude:"zipcode_longitude",
	// the integer fields are the latitude/longtude * 100000 rounded off allow mysql range index to speed up performance
	latitudeInteger:"zipcode_latitude_integer",
	longitudeInteger:"zipcode_longitude_integer",
and then you can query it for distance with code similar to this function: searchZipcode

these are the remote calls:
/z/misc/geocode/getAjaxGeocode
/z/misc/geocode/saveGeocode?address=123%20Main%20St,%20Daytona%20Beach,%20FL

these are for testing only:
/z/misc/geocode/searchZipcode
/z/misc/geocode/testGeocode

TODO: make a script that auto-geocodes all the "map picker" fields that are blank if there is a valid address entered in the other address fields.

// TODO: if a site option group is not active, the geocode will never happen because the record doesn't exist in memory.
	// need to directly update database even if record doesn't exist.   need to do this without hardcoding query in client site.


geocodeCom=createobject("component", "zcorerootmapping.mvc.misc.controller.geocode");

// run this to start javascript geocoding
geocodeCom.processGeocodeQueue();

ts={
	// id, latitude & longitude will be passed in the query string to the callbackURL when the geocode has been completed.
	callbackURL:request.zos.globals.domain&"place/updateCoordinates",
	address:"", // in this exact format: address, city state zip

	// or preferably separated to guarantee formatting:
	address:"",
	address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
	city:"",
	state:"",
	country:"",
	zip:""
};
rs=geocodeCom.getGeocode(ts);
if(rs.status EQ "error"){
	// handle error
	throw(rs.errorMessage);
}else if(rs.status EQ "queued"){
	// do nothing
}else if(rs.status EQ "complete"){
	// store the latitude/longitude
	latitude=rs.latitude;
	longitude=rs.longitude;
}

 --->

<!--- 
<!--- Example of callbackURL function for client site --->
<cffunction name="updateCoordinates" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	siteOptionCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");

	form.id=application.zcore.functions.zso(form, 'id');
	form.latitude=application.zcore.functions.zso(form, 'latitude');
	form.longitude=application.zcore.functions.zso(form, 'longitude');

	// lookup record
	ts=duplicate(application.zcore.siteOptionCom.getOptionGroupSetById(["Place"], form.id));  

	// update record
	ts["Map Coordinates"]=form.latitude&","&form.longitude;
	application.zcore.siteOptionCom.setOptionGroupImportStruct(["Place"], 0, 0, ts, form);  

	form.site_x_option_group_set_id=ts.__setId;
	rs=siteOptionCom.internalGroupUpdate(); 

 	if(rs.success){
 		// Note: you don't have to return anything
 		echo('Success');
 		return;
 	}else{
 		throw("Failed to update coordinates for place");
 	}
	</cfscript>
</cffunction>
 --->

<cffunction name="testGeocode" localmode="modern" access="remote"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	geocodeCom=this;

	application.zcore.functions.zRequireGoogleMaps();  
	ts={
		callbackURL:request.zos.globals.domain&"/z/misc/geocode/testUpdateCoordinates",
		//address:"300 Main St, Daytona Beach, FL 32118", // in this exact format: address, city state zip

		// or preferably separated to guarantee formatting:
		address:"300 Main St",
		address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
		city:"Daytona Beach",
		state:"FL",
		country:"US",
		zip:"32118"
	};
	rs=geocodeCom.getGeocode(ts);
	writedump(rs);

	latitude="";
	longitude="";
	if(rs.status EQ "error"){
		// handle error
		throw(rs.errorMessage);
	}else if(rs.status EQ "queued"){
		// do nothing
	}else if(rs.status EQ "complete"){
		// store the latitude/longitude
		latitude=rs.latitude;
		longitude=rs.longitude;
	}
	echo('status:'&rs.status&"<br>");
	echo('latitude:'&latitude&"<br>");
	echo('longitude:'&longitude&"<br>");
	</cfscript>
</cffunction>

<cffunction name="testUpdateCoordinates" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	siteOptionCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");

	form.id=application.zcore.functions.zso(form, 'id');
	form.latitude=application.zcore.functions.zso(form, 'latitude');
	form.longitude=application.zcore.functions.zso(form, 'longitude');

	throw("testUpdateCoordinates is ok");
	</cfscript>
</cffunction>

	
<cffunction name="searchZipcode" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	geocodeCom=this;
	ts={
		fields:{
			latitude:"zipcode_latitude",
			longitude:"zipcode_longitude",
			latitudeInteger:"zipcode_latitude_integer",
			longitudeInteger:"zipcode_longitude_integer",
			distance:"distance"
		},
		startPosition:{
			latitude:30.754348000000000000,
			longitude:-81.561603000000000000
		},
		miles:15
	}
	rs=geocodeCom.getSearchSQL(ts);

	/*
	address based distance search 
		geocode the address the user has typed (using google client geocoding api)
		distance to zip is not sufficient.  it has to be distance to the lat/long, which is a dynamic calculation using the full algorithm sin/cos, etc
	*/
	db=request.zos.queryObject;
	db.sql="select * 
	#db.trustedSQL(rs.selectSQL)#
	from #db.table("zipcode", request.zos.globals.datasource)#  
	where #db.param(1)# = #db.param(1)# 
	#db.trustedSQL(rs.whereSQL)# 
	having #db.trustedSQL(rs.havingSQL)#
	ORDER BY `distance`";
	qDistance=db.execute("qDistance"); 
	// going to need to order by the subscription and better if that was converted to number in change.cfc.
	for(row in qDistance){
		echo('#row.zipcode_zip# | #row.distance# miles<br />');
	}
	abort;
	</cfscript>

</cffunction>

<cffunction name="search" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	geocodeCom=this;
	ts={
		fields:{
			latitude:"place_latitude",
			longitude:"place_longitude",
			latitudeInteger:"place_latitude_integer",
			longitudeInteger:"place_longitude_integer",
			distance:"distance"
		},
		startPosition:{
			latitude:28.6660872,
			longitude:-82.6016039
		},
		miles:15
	}
	rs=geocodeCom.getSearchSQL(ts);

	/*address based distance search 
		geocode the address the user has typed (using google client geocoding api)
		distance to zip is not sufficient.  it has to be distance to the lat/long, which is a dynamic calculation using the full algorithm sin/cos, etc*/
	db=request.zos.queryObject;
	db.sql="select * 
	#db.trustedSQL(rs.selectSQL)#
	from #db.table("place", request.zos.globals.datasource)#  
	where place_active = #db.param(1)# 
	#db.trustedSQL(rs.whereSQL)# 
	having #db.trustedSQL(rs.havingSQL)#
	ORDER BY `distance`";
	qDistance=db.execute("qDistance");
	// going to need to order by the subscription and better if that was converted to number in change.cfc.
	for(row in qDistance){
		echo('#row.place_id# | #row.distance# miles<br />');
	}

	</cfscript>

</cffunction>

<cffunction name="getAjaxGeocode" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("disabled for now");
	}
	rs={};
	db=request.zos.queryObject;
	db.sql="select count(geocode_cache_id) count from #db.table("geocode_cache", request.zos.zcoreDatasource)# WHERE 
	geocode_cache_deleted=#db.param(0)# and ";
	if(not request.zos.isTestServer){
		db.sql&=" geocode_cache_client1_ip_address <> #db.param(request.zos.cgi.remote_addr)# and
		geocode_cache_client2_ip_address <> #db.param(request.zos.cgi.remote_addr)# and 
		geocode_cache_client3_ip_address <> #db.param(request.zos.cgi.remote_addr)# and  ";
	}
	db.sql&=" geocode_cache_confirm_count <> #db.param(3)# ";
	qCount=db.execute("qCount");
	
	db.sql="select * from #db.table("geocode_cache", request.zos.zcoreDatasource)# 
	WHERE geocode_cache_deleted=#db.param(0)# and ";
	if(not request.zos.isTestServer){
		db.sql&=" geocode_cache_client1_ip_address <> #db.param(request.zos.cgi.remote_addr)# and
	geocode_cache_client2_ip_address <> #db.param(request.zos.cgi.remote_addr)# and 
	geocode_cache_client3_ip_address <> #db.param(request.zos.cgi.remote_addr)# and   ";
	}
	db.sql&=" geocode_cache_confirm_count <> #db.param(3)# 
	LIMIT ";
	if(qCount.count LT 10){
		db.sql&=db.param(0);
	}else{
		db.sql&=db.param(randrange(0,10)*10);
	}
	db.sql&=", #db.param(10)#";
	qGeocode=db.execute("qGeocode"); 
	rs.arrAddress=[];
	rs.arrKey=[];
	if(qGeocode.recordcount EQ 0){
		rs.success=false;
	}else{
		for(row in qGeocode){
			arrayAppend(rs.arrAddress, row.geocode_cache_address);
			arrayAppend(rs.arrKey, row.geocode_cache_hash);
		}
	} 
	rs.success=true;
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>


<cffunction name="processGeocodeQueue" localmode="modern" access="public"> 
	<cfscript>
	if(not request.zos.isTestServer){
		return;
	}
	</cfscript>
	<script type="text/javascript">
	zArrMapFunctions.push(function(){
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
					console.log(r.arrAddress);
				}else{
					echo('getAjaxGeocode: fail');
				}
			},
			cache:false
		};  
		zAjax(ts);
	});
	</script>
</cffunction>

<cffunction name="getGeocode" localmode="modern" access="remote">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("disabled for now");
	}
	ts={
		callbackURL:"",
		address:"",
		address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
		city:"",
		state:"",
		country:"",
		zip:""
	};
	ss=arguments.ss;
	structappend(ss, ts, false);
	for(i in ss){
		ss[i]=trim(ss[i]);
	}
	if(ss.address EQ ""){
		throw("arguments.ss.address is required");
	}
	if(ss.callbackURL EQ ""){
		throw("arguments.ss.callbackURL is required");
	}
	arrAddress=[ss.address];
	if(ss.city NEQ ""){
		arrayAppend(arrAddress, ", "&ss.city);
	}
	if(ss.state NEQ ""){
		arrayAppend(arrAddress, ", "&ss.state);
	}
	if(ss.zip NEQ ""){
		arrayAppend(arrAddress, " "&ss.zip);
	}
	if(ss.country NEQ "" and ss.country NEQ "US" and ss.country NEQ "USA" and ss.country NEQ "United States"){
		arrayAppend(arrAddress, " "&ss.country);
	}


	ts={
		table:"geocode_cache",
		datasource:request.zos.zcoreDatasource,
		struct:{
			geocode_cache_callback_url:ss.callbackURL,
			geocode_cache_hash:hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256'),
			geocode_cache_address:arrayToList(arrAddress, ""),
			geocode_cache_created_datetime=request.zos.mysqlnow,
			geocode_cache_updated_datetime=request.zos.mysqlnow,
			geocode_deleted:0
		}
	}


	db=request.zos.queryObject; 
	db.sql="select * from #db.table("geocode_cache", request.zos.zcoreDatasource)# 
	WHERE geocode_cache_deleted=#db.param(0)# and 
	geocode_cache_address = #db.param(ts.struct.geocode_cache_address)#";
	qGeocode=db.execute("qGeocode");
	rs={};
	if(qGeocode.recordcount EQ 0){
		geocode_cache_id=application.zcore.functions.zInsert(ts);
		if(geocode_cache_id){
			rs.status="queued";
			return rs;
		}else{
			rs.status="error";
			rs.errorMessage="Failed to queue geocode";
			return rs;
		}
	}else{
		if(qGeocode.geocode_cache_confirm_count < 3){
			arrURL=listToArray(qGeocode.geocode_cache_callback_url, chr(10))
			for(link in arrURL){
				if(link EQ ss.callbackURL){
					// already queued
					rs.status="queued";
					return rs;
				}
			} 
			arrayAppend(arrURL, ss.callbackURL);
			ts.struct.geocode_cache_callback_url=arrayToList(arrURL, chr(10));
			ts.struct.geocode_cache_id=qGeocode.geocode_cache_id;
			ts.struct.geocode_cache_hash=qGeocode.geocode_cache_hash;
			result=application.zcore.functions.zUpdate(ts);
			if(result){
				rs.status="queued";
				return rs;
			}else{
				rs.status="error";
				rs.errorMessage="Failed to queue geocode";
				return rs; 
			}
		}else{
			// already geocoded
			rs.status="complete";
			rs.latitude=qGeocode.geocode_cache_latitude;
			rs.longitude=qGeocode.geocode_cache_longitude;
			return rs;
		}
	} 
	</cfscript> 
</cffunction>

<cffunction name="saveGeocode" localmode="modern" access="remote"> 
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("disabled for now");
	}
	db=request.zos.queryObject; 
	form.address=application.zcore.functions.zso(form, 'address');
	form.latitude=application.zcore.functions.zso(form, 'latitude');
	form.longitude=application.zcore.functions.zso(form, 'longitude');
	form.accuracy=application.zcore.functions.zso(form, 'accuracy');
	form.status=application.zcore.functions.zso(form, 'status');
	form.key=application.zcore.functions.zso(form, 'key');
	if(form.address EQ ""){ 
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Invalid request"});
	}
	db.sql="select sql_no_cache * from #db.table("geocode_cache", request.zos.zcoreDatasource)# 
	WHERE geocode_cache_deleted=#db.param(0)# and 
	geocode_cache_address = #db.param(form.address)# and 
	geocode_cache_hash=#db.param(form.key)#";
	qGeocode=db.execute("qGeocode");
	if(qGeocode.recordcount EQ 0){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-existent address or invalid key"});
	}
	if(qGeocode.geocode_cache_confirm_count EQ 3){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Already completed"});
	} 
	for(row in qGeocode){
		whichClient=1;
		//echo(row.geocode_cache_confirm_count&":"&whichClient&"<br>");
		if(row.geocode_cache_confirm_count EQ 0){
			row.geocode_cache_confirm_count=1;
			row.geocode_cache_client1_ip_address=request.zos.cgi.remote_addr;
			whichClient=1;
		}else if(row.geocode_cache_confirm_count EQ 1){
			if(not request.zos.isTestServer and row.geocode_cache_client1_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, errorMessage:"Not a unique IP Address"});
			}
			row.geocode_cache_confirm_count=2;
			row.geocode_cache_client2_ip_address=request.zos.cgi.remote_addr;
			whichClient=2;
		}else if(row.geocode_cache_confirm_count EQ 2){
			if(not request.zos.isTestServer and row.geocode_cache_client1_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, errorMessage:"Not a unique IP Address"});
			}
			if(not request.zos.isTestServer and row.geocode_cache_client2_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, errorMessage:"Not a unique IP Address"});
			}
			row.geocode_cache_confirm_count=3;
			row.geocode_cache_client3_ip_address=request.zos.cgi.remote_addr;
			whichClient=3;
		}
		row["geocode_cache_client#whichClient#_latitude"]=numberformat(form.latitude, '_._______');
		row["geocode_cache_client#whichClient#_longitude"]=numberformat(form.longitude, '_._______');
		row["geocode_cache_client#whichClient#_accuracy"]=form.accuracy;
		row["geocode_cache_client#whichClient#_status"]=form.status;
		//echo(row.geocode_cache_confirm_count&":"&whichClient);abort;
		// find if the current whichClient is the non-matching one 
		finalize=false;
		if(row.geocode_cache_confirm_count EQ 3){ 
			if(compare(row.geocode_cache_client1_latitude, row.geocode_cache_client2_latitude) EQ 0 and compare(row.geocode_cache_client1_longitude, row.geocode_cache_client2_longitude) EQ 0){
				if(compare(row.geocode_cache_client2_latitude, row.geocode_cache_client3_latitude) EQ 0 and compare(row.geocode_cache_client2_longitude, row.geocode_cache_client3_longitude) EQ 0){
					// all 3 match
					finalize=true;
				}else{
					// only first 2 match, invalid 3rd record - need to redo it
					if(whichClient EQ 3){
						// return and ignore this save request
						application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching third geocode #row.geocode_cache_client2_latitude# EQ #row.geocode_cache_client3_latitude# and #row.geocode_cache_client2_longitude# EQ #row.geocode_cache_client3_longitude#"});
					}
				}
			}else{
				if(compare(row.geocode_cache_client2_latitude, row.geocode_cache_client3_latitude) EQ 0 and compare(row.geocode_cache_client2_longitude, row.geocode_cache_client3_longitude) EQ 0){
					// last 2 match
					if(whichClient EQ 1){
						// return and ignore this save request
						application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching first geocode: #row.geocode_cache_client2_latitude# EQ #row.geocode_cache_client3_latitude# and #row.geocode_cache_client2_longitude# EQ #row.geocode_cache_client3_longitude#"});
					}
				}else{
					if(compare(row.geocode_cache_client1_latitude, row.geocode_cache_client3_latitude) EQ 0 and compare(row.geocode_cache_client1_longitude, row.geocode_cache_client3_longitude) EQ 0){
						// first and last match 
						if(whichClient EQ 2){
							// return and ignore this save request
							application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching second geocode: #row.geocode_cache_client1_latitude# EQ #row.geocode_cache_client3_latitude# and #row.geocode_cache_client1_longitude# EQ #row.geocode_cache_client3_longitude#"});
						}
					}else{
						// none match - strange - lets throw developer error to see why
						structappend(form, row, true);
						throw("None of the geocode results match");
						// application.zcore.functions.zReturnJson({success:false, errorMessage:"None of the geocode results match"});
					}
				}
			}
		}

		if(finalize){
			if(row.geocode_cache_client1_accuracy EQ "ROOFTOP"){
				row.geocode_cache_latitude=row["geocode_cache_client#whichClient#_latitude"];
				row.geocode_cache_longitude=row["geocode_cache_client#whichClient#_longitude"];
			}else{
				row.geocode_cache_latitude="";
				row.geocode_cache_longitude="";
			}
			row.geocode_cache_accuracy=row["geocode_cache_client#whichClient#_accuracy"];
			row.geocode_cache_status=row["geocode_cache_client#whichClient#_status"];
		}
		row.geocode_cache_updated_datetime=request.zos.mysqlnow;
		row.geocode_cache_deleted=0;
		ts={
			table:"geocode_cache",
			datasource:request.zos.zcoreDatasource,
			struct:row
		} 
		result=application.zcore.functions.zUpdate(ts);  
		if(not result){
			application.zcore.functions.zReturnJson({success:false, errorMessage:'Failed to update record'});
		}
		if(finalize){
			arrLink=listToArray(row.geocode_cache_callback_url, chr(10));
			for(link in arrLink){
				rs2=application.zcore.functions.zDownloadLink(application.zcore.functions.zURLAppend(link, 'latitude='&row.geocode_cache_latitude&'&longitude='&row.geocode_cache_longitude), 10);
				if(rs2.success){
					// ignore success
				}
			}
		}
	}
	application.zcore.functions.zReturnJson({success:true});
	</cfscript>

</cffunction>

<!--- 
ts={
	fields:{
		latitude:"place_latitude",
		longitude:"place_longitude",
		latitudeInteger:"place_latitude_integer",
		longitudeInteger:"place_longitude_integer",
		distance:"distance"
	},
	startPosition:{
		latitude:28.6660872,
		longitude:-82.6016039
	},
	miles:15
}
rs=geocodeCom.getSearchSQL(ts);
 --->
<cffunction name="getSearchSQL" localmode="modern" access="remote">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	// build a box to limit how many records are searched
	latDistanceInMiles=abs(ss.miles);
	longDistanceInMiles=abs(ss.miles);
	latDegrees=latDistanceInMiles/68; 
	longDegrees=longDistanceInMiles/68; 
  
	if(ss.startPosition.latitude > 90 or ss.startPosition.latitude < -90){
		return { success:false};
	}
	latitudeField="`#application.zcore.functions.zEscape(ss.fields.latitude)#`";
	longitudeField="`#application.zcore.functions.zEscape(ss.fields.longitude)#`";
	latitudeIntegerField="`#application.zcore.functions.zEscape(ss.fields.latitudeInteger)#`";
	longitudeIntegerField="`#application.zcore.functions.zEscape(ss.fields.longitudeInteger)#`";
	distanceField="`#application.zcore.functions.zEscape(ss.fields.distance)#`";
   	rs={};
   	rs.selectSQL=", ( 3959 * acos( cos( radians(#latitudeField#) )
      * cos( radians( #latitudeField# ) ) 
      * cos( radians( #longitudeField# ) - radians(#longitudeField#) ) 
      + sin( radians(#latitudeField#) ) 
      * sin( radians( #latitudeField# ) ) ) ) AS `#application.zcore.functions.zEscape(ss.fields.distance)#` ";
    rs.whereSQL=" and 
	#latitudeIntegerField# between #application.zcore.functions.zEscape(int((ss.startPosition.latitude-latDegrees)*100000))# and #application.zcore.functions.zEscape(ceiling((ss.startPosition.latitude+latDegrees)*100000))# and 
	#longitudeIntegerField# between #application.zcore.functions.zEscape(int((ss.startPosition.longitude-longDegrees)*100000))# and #application.zcore.functions.zEscape(ceiling((ss.startPosition.longitude+longDegrees)*100000))# ";
	rs.havingSQL=" #distanceField# <= #application.zcore.functions.zEscape(ss.miles)# ";
	return rs;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote"> 
</cffunction>

</cfoutput>
</cfcomponent>