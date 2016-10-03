<cfcomponent>
<cfoutput>
<!--- A geocode caching system, that uses the javascript method the real estate system does, but for the non-real estate clients, so we can queue map coordinate lookup async from when the record is created.  it will execute callback url to update the record when the geocode is complete.  It also tries to secure itself by making it compare 3 different lookups for same address, but from different ips, so it can't be easily abused. --->

<!--- 
/z/misc/geocode/getAjaxGeocode
/z/misc/geocode/saveGeocode?address=123%20Main%20St,%20Daytona%20Beach,%20FL


// TODO: if a site option group is not active, the geocode will never happen because the record doesn't exist in memory.
	// need to directly update database even if record doesn't exist.   need to do this without hardcoding query in client site.


geocodeCom=createobject("component", "zcorerootmapping.mvc.misc.controller.geocode");

// run this to start javascript geocoding
geocodeCom.processGeocodeQueue();

ts={
	callbackURL:request.zos.globals.domain&"place/updateCoordinates?id=
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
 		echo('Success');
 		return;
 	}else{
 		throw("Failed to update coordinates for place");
 	}
	</cfscript>
</cffunction>
 --->

<cffunction name="getAjaxGeocode" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("disabled for now");
	}
	rs={};
	db=request.zos.queryObject;
	db.sql="select count(geocode_cache_id) count from #db.table("geocode_cache")# WHERE 
	geocode_cache_deleted=#db.param(0)# and 
	geocode_cache_client1_ip_address <> #db.param(request.zos.cgi.remote_addr)# and
	geocode_cache_client2_ip_address <> #db.param(request.zos.cgi.remote_addr)# and 
	geocode_cache_client3_ip_address <> #db.param(request.zos.cgi.remote_addr)# and  
	geocode_cache_confirm_count <> #db.param(3)# ";
	qCount=db.execute("qCount");
	
	db.sql="select * from #db.table("geocode_cache")# 
	WHERE geocode_cache_deleted=#db.param(0)# and 
	geocode_cache_client1_ip_address <> #db.param(request.zos.cgi.remote_addr)# and
	geocode_cache_client2_ip_address <> #db.param(request.zos.cgi.remote_addr)# and 
	geocode_cache_client3_ip_address <> #db.param(request.zos.cgi.remote_addr)# and  
	geocode_cache_confirm_count <> #db.param(3)# 
	LIMIT ";
	if(qCount.count LT 10){
		db.sql&=db.param(0);
	}else{
		db.sql&=db.param(randrange(0,10)*10);
	}
	db.sql&=", #db.param(10)#";
	qGeocode=db.execute("qGeocode"); 
	if(qGeocode.recordcount EQ 0){
		rs.success=false;
	}else{
		rs.arrAddress=[];
		rs.arrKey=[];
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
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		ts={
			id:"zGeocodeQueue",
			method:"get",
			url:"/z/misc/geocode/getAjaxGeocode",
			callback:function(r){
				var r=JSON.parse(r);
				if(r.success){
					zGeocode.arrAddress=r.arrAddress;
					zGeocode.arrKey=r.arrKey;
					zGeocodeCacheAddress();

				}
			},
			cache:false
		};  
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
	db.sql="select * from #db.table("geocode_cache")# 
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
		application.zcore.functions.zReturnJson({success:false, "Invalid request"});
	}
	db.sql="select * from #db.table("geocode_cache")# 
	WHERE geocode_cache_deleted=#db.param(0)# and 
	geocode_cache_address = #db.param(form.address)# and  
	geocode_cache_confirm_count <> #db.param(3)# and 
	geocode_cache_key=#db.param(form.key)#";
	qGeocode=db.execute("qGeocode");
	if(qGeocode.recordcount EQ 0){
		application.zcore.functions.zReturnJson({success:false, "Non-existent address or invalid key"});
	}
	if(qGeocode.recordcount EQ 3){
		application.zcore.functions.zReturnJson({success:false, "Already completed"});
	}
	for(row in qGeocode){
		whichClient=1;
		if(row.geocode_cache_confirm_count EQ 0){
			row.geocode_cache_confirm_count=1;
			row.geocode_cache_client1_ip_address=request.zos.cgi.remote_addr;
			whichClient=1;
		}else if(row.geocode_cache_confirm_count EQ 1){
			if(row.geocode_cache_client1_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, "Not a unique IP Address"});
			}
			row.geocode_cache_confirm_count=2;
			row.geocode_cache_client2_ip_address=request.zos.cgi.remote_addr;
			whichClient=2;
		}else if(row.geocode_cache_confirm_count EQ 2){
			if(row.geocode_cache_client1_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, "Not a unique IP Address"});
			}
			if(row.geocode_cache_client2_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, "Not a unique IP Address"});
			}
			row.geocode_cache_confirm_count=3;
			row.geocode_cache_client3_ip_address=request.zos.cgi.remote_addr;
			whichClient=3;
		}

		// find if the current whichClient is the non-matching one
		finalize=false;
		if(row.geocode_cache_confirm_count EQ 3){
			// This logic is incomplete.
			if(row.geocode_cache_client1_latitude EQ row.geocode_cache_client2_latitude and row.geocode_cache_client1_longitude EQ row.geocode_cache_client2_longitude){
				if(row.geocode_cache_client2_latitude EQ row.geocode_cache_client3_latitude and row.geocode_cache_client2_longitude EQ row.geocode_cache_client3_longitude){
					// all 3 match
					finalize=true;
				}else{
					// only first 2 match, invalid 3rd record - need to redo it
					if(whichClient EQ 3){
						// return and ignore this save request
						application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching third geocode"});
					}
				}
			}else{
				if(row.geocode_cache_client2_latitude EQ row.geocode_cache_client3_latitude and row.geocode_cache_client2_longitude EQ row.geocode_cache_client3_longitude){
					// last 2 match
					if(whichClient EQ 1){
						// return and ignore this save request
						application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching third geocode"});
					}
				}else{
					if(row.geocode_cache_client1_latitude EQ row.geocode_cache_client3_latitude and row.geocode_cache_client1_longitude EQ row.geocode_cache_client3_longitude){
						// first and last match 
						if(whichClient EQ 2){
							// return and ignore this save request
							application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching third geocode"});
						}
					}else{
						// none match - strange - lets throw developer error to see why
						throw("None of the geocode results match");
						// application.zcore.functions.zReturnJson({success:false, errorMessage:"None of the geocode results match"});
					}
				}
			}
		}

		if(finalize){

			arrLink=listToArray(row.geocode_cache_callback_url, chr(10));
			for(link in arrLink){
				// TODO: finish posting the latitude/longitude to this url
				abort;
				rs2=application.zcore.functions.zDownloadLink(link, 10);
				if(rs2.success){

				}
			}
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
	}
	application.zcore.functions.zReturnJson({success:true});
	</cfscript>

</cffunction>

<!--- 
ts={
	fields:{
		latitude:"place_latitude",
		longitude:"place_longitude",
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
	latDistanceInMiles=ss.miles;
	longDistanceInMiles=ss.miles;
	latDegrees=latDistanceInMiles/68; 
	longDegrees=longDistanceInMiles/68; 
 
	if(ss.startPosition.latitude > 90 or ss.startPosition.latitude < -90){
		return { success:false};
	}
	latitudeField="`#application.zcore.functions.zEscape(ss.fields.latitude)#`";
	longitudeField="`#application.zcore.functions.zEscape(ss.fields.longitude)#`";
	distanceField="`#application.zcore.functions.zEscape(ss.fields.distance)#`";
   	rs={};
   	rs.selectSQL=", ( 3959 * acos( cos( radians(42.290763) )
      * cos( radians( #latitudeField# ) ) 
      * cos( radians( #longitudeField# ) - radians(-71.35368) ) 
      + sin( radians(42.290763) ) 
      * sin( radians( #latitudeField# ) ) ) ) AS `#application.zcore.functions.zEscape(ss.fields.distance)#` ";
    rs.whereSQL=" and 
	zipcode_latitude_integer between #application.zcore.functions.zEscape(ss.startPosition.latitude-latDegrees)# and #application.zcore.functions.zEscape(ss.startPosition.latitude+latDegrees)# and 
	zipcode_longitude_integer between #application.zcore.functions.zEscape(ss.startPosition.longitude-longDegrees)# and #application.zcore.functions.zEscape(ss.startPosition.longitude+longDegrees)# ";
	rs.havingSQL=" #distanceField# <= #application.zcore.functions.zEscape(ss.miles)# ";
	return rs;
	</cfscript>
</cffunction>
	
<cffunction name="searchZipcode" localmode="modern" access="remote">
	<cfscript>
	geocodeCom=this;
	ts={
		fields:{
			latitude:"zipcode_latitude",
			longitude:"zipcode_longitude",
			distance:"distance"
		},
		startPosition:{
			latitude:30.754348000000000000,
			longitude:-81.561603000000000000
		},
		miles:1450
	}
	rs=geocodeCom.getSearchSQL(ts);

	/*address based distance search 
		geocode the address the user has typed (using google client geocoding api)
		distance to zip is not sufficient.  it has to be distance to the lat/long, which is a dynamic calculation using the full algorithm sin/cos, etc*/
	db=request.zos.queryObject;
	db.sql="select * 
	#db.trustedSQL(rs.selectSQL)#
	from #db.table("zipcode", request.zos.globals.datasource)#  
	where #db.param(1)# = #db.param(1)# 
	#db.trustedSQL(rs.whereSQL)# 
	having #db.trustedSQL(rs.havingSQL)#
	ORDER BY `distance`";
	qDistance=db.execute("qDistance");
	writedump(qDistance);
	// going to need to order by the subscription and better if that was converted to number in change.cfc.
	for(row in qDistance){
		echo('#row.zipcode_zip# | #row.distance# miles<br />');
	}

	</cfscript>

</cffunction>

<cffunction name="search" localmode="modern" access="remote">
	<cfscript>
	geocodeCom=this;
	ts={
		fields:{
			latitude:"place_latitude",
			longitude:"place_longitude",
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

<cffunction name="index" localmode="modern" access="remote">
<!--- 
download the geocode 3 times, and compare them.  
	If they don't match, invalidate the non-matching record and try again.  
	if all 3 don't match, send as error.   
	This help prevent a client from abusing system.
geocode_cache
	 

 --->
</cffunction>

</cfoutput>
</cfcomponent>