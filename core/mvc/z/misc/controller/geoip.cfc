<cfcomponent>
<cfoutput>
<!--- 
This doesn't support ipv6 yet.
Google shows 16% of users are using ipv6 as of february 2017.
https://www.google.com/intl/en/ipv6/statistics.html

A study found maxmind ipv6 database to be 2-3 times less accurate
http://referaat.cs.utwente.nl/conference/24/paper/7519/comparing-the-accuracy-of-ipv4-and-ipv6-geolocation-databases.pdf

The usa owns around 36% of all ip addresses.

geoip might be useful for making users less anonymous for simple leads and abuse / spam detection.  For example, the user's network location information could be attached to leads, and logged in access logs to help us identify abuse patterns or automatically distrust certain behavior more because of what it came from.

The db also tells me if the ip is known to be anonymous proxy or satellite on some of them.  It would be interesting to determine if abuse through proxies is more common or not.  I could run a report to see the network locations of all the spam inquiries.

all inquiries 

SELECT geoip_location_city_name, COUNT(DISTINCT inquiries.inquiries_id) `count`  FROM jetendo.inquiries, jetendo.track_user, task.geoip, task.geoip_block, task.geoip_location
WHERE inquiries.inquiries_id=track_user.inquiries_id AND 
inquiries.site_id = track_user.site_id AND 
 geoip_ip_number =INET_ATON(track_user_ip) AND 
 inquiries_spam=1 AND 
 geoip.geoip_block_id=geoip_block.geoip_block_id AND 
 geoip_location.geoip_location_id = geoip_block.geoip_location_id 
GROUP BY geoip_location_city_name
  ;

  #spam by country
SELECT geoip_location_country_name, COUNT(DISTINCT inquiries.inquiries_id) `count`  FROM jetendo.inquiries, jetendo.track_user, task.geoip, task.geoip_block, task.geoip_location
WHERE inquiries.inquiries_id=track_user.inquiries_id AND 
inquiries.site_id = track_user.site_id AND 
 geoip_ip_number =INET_ATON(track_user_ip) AND 
 inquiries_spam=1 AND 
 geoip.geoip_block_id=geoip_block.geoip_block_id AND 
 geoip_location.geoip_location_id = geoip_block.geoip_location_id 
GROUP BY geoip_location_country_name
  ;


  ip count by country:

SELECT geoip_location_country_name, COUNT(geoip_block.geoip_block_id) `count`  FROM  task.geoip, task.geoip_block, task.geoip_location  
WHERE
 geoip.geoip_block_id=geoip_block.geoip_block_id AND 
 geoip_location.geoip_location_id = geoip_block.geoip_location_id 
GROUP BY geoip_location_country_name 
LIMIT 0,1000
  ;
 --->
<!--- <cffunction name="importIpStatus" localmode="modern" access="remote">
	<cfscript>
	echo('Insert Count:'&application.zcore.functions.zso(application, 'geoipInsertCount')&" | Offset:"&application.zcore.functions.zso(application, 'geoipInsertOffset'));
	</cfscript>
</cffunction>

<cffunction name="importIp" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	setting requesttimeout="100000";
	throw("this uses too much space - need to do partial import or not at all");

	application.geoipInsertOffset=10000;
	application.geoipInsertCount=0; 
	while(true){
		db.sql="SELECT  *
		FROM #db.table("geoip_block", request.zos.zcoreDatasource)#
		LIMIT #db.param(application.geoipInsertOffset)#, #db.param(10000)#";
		qIp=db.execute("qIp");
		if(qIp.recordcount EQ 0){
			break;
		}
		arrFile=[];
		for(row in qIp){
			ip=row.geoip_block_network;
			for(i=ip;i<=row.geoip_block_broadcast;i++){ 
				application.geoipInsertCount++; 
				arrayAppend(arrFile, "('#i#','#row.geoip_block_id#')"); 
				if(arrayLen(arrFile) GT 3000){
					query name="qInsert" datasource=request.zos.zcoreDatasource{
					echo("INSERT IGNORE INTO geoip (geoip_ip_number, geoip_block_id) VALUES "&arrayToList(arrFile, ", "));
					} 
					arrFile=[]; 
				}
			}
		}
		query name="qInsert" datasource=request.zos.zcoreDatasource{
		echo("INSERT IGNORE INTO geoip (geoip_ip_number, geoip_block_id) VALUES "&arrayToList(arrFile, ", "));
		} 
		application.geoipInsertOffset+=10000;
	} 
	echo('#application.geoipInsertCount# inserted | Offset: #application.geoipInsertOffset#');
	</cfscript>	
</cffunction>   --->

<cffunction name="zGetFastIpLocation" localmode="modern" access="remote">
	<cfargument name="ip" type="string" required="yes">
	<cfargument name="columnList" type="string" required="no" default="" hint="* is a valid value if you want everything">
	<cfscript>
	if(arguments.columnList EQ ""){
		arguments.columnList="geoip_location.geoip_location_country_name,
		geoip_location.geoip_location_country_iso_code,
		geoip_location.geoip_location_city_name,
		geoip_block.geoip_block_latitude,
		geoip_block.geoip_block_longitude  ";
	} 
	db=request.zos.queryObject;
	db.sql="SELECT   SQL_NO_CACHE
	#arguments.columnList# 
	FROM #db.table("geoip_block", request.zos.zcoreDatasource)# FORCE INDEX(newindex2), 
	#db.table("geoip_location", request.zos.zcoreDatasource)#  
	where geoip_block.geoip_location_id = geoip_location.geoip_location_id and 
	geoip_block_prefix=(substring_index(substring_index(#db.param(arguments.ip)#, #db.param('.')#, #db.param(1)#), #db.param('.')#, #db.param(-1)#)*#db.param(256)#)+substring_index(substring_index(#db.param(arguments.ip)#, #db.param('.')#, #db.param(2)#), #db.param('.')#, #db.param(-1)#) 
	AND inet_aton(#db.param(arguments.ip)#) >= geoip_block_network
	AND inet_aton(#db.param(arguments.ip)#) <= geoip_block_broadcast 
	LIMIT #db.param(0)#, #db.param(1)#";
	qIp=db.execute("qIp");
	ts={};
	if(qIp.recordcount EQ 0){
		ts.success=false; 
	}else{
		ts.success=true;
		for(row in qIp){
			ts.countryCode=application.zcore.functions.zso(row, 'geoip_location_country_iso_code');
			ts.cityName=application.zcore.functions.zso(row, 'geoip_location_city_name');
			ts.countryName=application.zcore.functions.zso(row, 'geoip_location_country_name');
			ts.locale=application.zcore.functions.zso(row, 'geoip_location_locale_code');
			ts.continentCode=application.zcore.functions.zso(row, 'geoip_location_continent_code');
			ts.continentName=application.zcore.functions.zso(row, 'geoip_location_continent_name');
			ts.subdivision1Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_iso_code'); // I.e. state/province
			ts.subdivision1Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_name');
			ts.subdivision2Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_iso_code');
			ts.subdivision2Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_name');
			ts.metroCode=application.zcore.functions.zso(row, 'geoip_location_metro_code');
			ts.postalCode=application.zcore.functions.zso(row, 'geoip_location_postalCode');
			if(ts.postalCode EQ ""){
				ts.postalCode=application.zcore.functions.zso(row, 'geoip_block_postal_code');
			}
			ts.latitude=application.zcore.functions.zso(row, 'geoip_block_latitude');
			ts.longitude=application.zcore.functions.zso(row, 'geoip_block_longitude');
		}
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="zGetIpLocation" localmode="modern" access="remote">
	<cfargument name="ip" type="string" required="yes">
	<cfargument name="columnList" type="string" required="no" default="" hint="* is a valid value if you want everything">
	<cfscript>
	if(arguments.columnList EQ ""){
		arguments.columnList="geoip_location.geoip_location_country_name,
		geoip_location.geoip_location_country_iso_code,
		geoip_location.geoip_location_city_name,
		geoip_block.geoip_block_latitude,
		geoip_block.geoip_block_longitude  ";
	}
	db=request.zos.queryObject; 

	db.sql="SELECT   SQL_NO_CACHE
	#arguments.columnList# 
	FROM #db.table("geoip_block", request.zos.zcoreDatasource)# FORCE INDEX(newindex1), 
	#db.table("geoip_location", request.zos.zcoreDatasource)#  
	where geoip_block.geoip_location_id = geoip_location.geoip_location_id 
	AND inet_aton(#db.param(arguments.ip)#) >= geoip_block_network
	AND inet_aton(#db.param(arguments.ip)#) <= geoip_block_broadcast 
	LIMIT #db.param(0)#, #db.param(1)#";
	qIp=db.execute("qIp");
	ts={};
	if(qIp.recordcount EQ 0){
		ts.success=false; 
	}else{
		ts.success=true;
		for(row in qIp){
			ts.countryCode=application.zcore.functions.zso(row, 'geoip_location_country_iso_code');
			ts.cityName=application.zcore.functions.zso(row, 'geoip_location_city_name');
			ts.countryName=application.zcore.functions.zso(row, 'geoip_location_country_name');
			ts.locale=application.zcore.functions.zso(row, 'geoip_location_locale_code');
			ts.continentCode=application.zcore.functions.zso(row, 'geoip_location_continent_code');
			ts.continentName=application.zcore.functions.zso(row, 'geoip_location_continent_name');
			ts.subdivision1Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_iso_code'); // I.e. state/province
			ts.subdivision1Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_name');
			ts.subdivision2Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_iso_code');
			ts.subdivision2Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_name');
			ts.metroCode=application.zcore.functions.zso(row, 'geoip_location_metro_code');
			ts.postalCode=application.zcore.functions.zso(row, 'geoip_location_postalCode');
			if(ts.postalCode EQ ""){
				ts.postalCode=application.zcore.functions.zso(row, 'geoip_block_postal_code');
			}
			ts.latitude=application.zcore.functions.zso(row, 'geoip_block_latitude');
			ts.longitude=application.zcore.functions.zso(row, 'geoip_block_longitude');
		}
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	starttime=gettickcount();
	form.ip=application.zcore.functions.zso(form, 'ip', false, request.zos.cgi.remote_addr);
	ts2=zGetIpLocation(form.ip, "");
	slowTime=(gettickcount()-starttime);
	starttime=gettickcount();
	ts=zGetFastIpLocation(form.ip, "");
	fastTime=(gettickcount()-starttime);

	echo('<h2>GeoIP Live Demo</h2>');
	echo('<div class="z-1of2">
	<form action="" method="get"><p>IP Address <input type="text" name="ip" value="#htmleditformat(form.ip)#"> <input type="submit" name="submit1" value="Submit"></p></form>');
	echo('<p>Lookup Time: #slowTime#ms (slow method) | #fastTime#ms (fast method)</p>');
	if(ts.success){
		arrK=structkeyarray(ts);
		arraySort(arrK, "text", "asc");
		for(i in arrK){
			if(i EQ "success"){
				continue;
			}
			if(ts[i] NEQ 0 and ts[i] NEQ ""){
				echo('<p>#i#:'&ts[i]&'</p>');
			}
		}
	}else{
		echo('Unable to find location for ip: #form.ip#');
	}
	</cfscript> 
	</div>
	<div class="z-1of2">
	<cfif ts.success and ts.latitude NEQ "0" and ts.latitude NEQ "">

		<cfsavecontent variable="scriptOutput">
			<cfscript>
			application.zcore.functions.zRequireGoogleMaps();
			</cfscript> 
			<script type="text/javascript">
			/* <![CDATA[ */
			var curMap=false;
			var arrAdditionalLocationLatLng=[];
			<cfscript> 
			arrLocation=[];
			ts={
				coordinates:ts.latitude&","&ts.longitude,
				info:"IP Location: #jsstringformat(form.ip)#"
			};
			arrayAppend(arrLocation, ts);   
			echo('arrAdditionalLocationLatLng=#serializeJson(arrLocation)#');
			</cfscript>  
			var markerCompleteCount=0;
			var arrMarker=[];
			function markerCallback(markerObj, location){  
				markerCompleteCount++;
				if(markerCompleteCount ==arrAdditionalLocationLatLng.length){
					zMapFitMarkers(curMap, arrMarker);
				}
			} 
			zArrMapFunctions.push(function(){ 
				if(arrAdditionalLocationLatLng.length){
					var optionsObj={ 
						zoom: 13 
					};
					var mapOptions = {
						zoom: 13,
						mapTypeId: google.maps.MapTypeId.ROADMAP
					}
					for(var i in optionsObj){
						mapOptions[i]=optionsObj[i];
					} 
					$("##mapContainerDiv").show();
					curMap=zCreateMap("mapDivId", mapOptions);  
					for(var i=0;i<arrAdditionalLocationLatLng.length;i++){ 
						var c=arrAdditionalLocationLatLng[i];
						var markerObj={};
						markerObj.infoWindowHTML=c.info;
						var arrLatLng=arrAdditionalLocationLatLng[i].coordinates.split(","); 
						var marker=zAddMapMarkerByLatLng(curMap, markerObj, arrLatLng[0], arrLatLng[1], markerCallback);  
						arrMarker.push(marker);
					}  
				}
			});
			/* ]]> */
			</script> 
		</cfsavecontent>
		<cfscript>
		request.zos.template.appendTag("scripts", scriptOutput);
		</cfscript>
		<div id="mapContainerDiv" style="width:100%; display:none; margin-bottom:20px; float:left;">
			<div style="width:100%; float:left; height:420px;" id="mapDivId"></div> 
		</div> 
	</cfif> 
	</div>
</cffunction>
</cfoutput>
</cfcomponent>