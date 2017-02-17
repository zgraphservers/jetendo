<cfcomponent>
<cfoutput> 

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="100";
	var db=request.zos.queryObject;

	
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	} 

/*
	contents=application.zcore.functions.zReadFile(request.zos.globals.serverPrivateHomeDir&"yahoo-exchange-rate.json");
	rs=contents; 
*/
	link="http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"; 
	rs=application.zcore.functions.zDownloadLink(link, 10);
	if(not rs.success){
		throw("Failed to download #link#");
	}
	contents=rs.cfhttp.filecontent; 
	try{
		js=deserializeJson(contents);
	}catch(Any e){
		savecontent variable="out"{
			echo('Response was not valid json format<br>');
			echo(link&'<br>');
			writedump(rs);
		}
		throw(out);
	} 

	db.sql="SELECT * FROM #db.table("exchange_rate", request.zos.zcoreDatasource)# WHERE  
	exchange_rate_deleted=#db.param('0')# ";
	qRate=db.execute("qRate");

	rateStruct={};
	for(row in qRate){
		rateStruct[row.exchange_rate_destination_abbr]=row;
	}
	if(not structkeyexists(js, 'list')){
		savecontent variable="out"{
			echo('Response was in an unexpected json format<br>');
			echo(link&'<br>');
			writedump(rs);
		}
		throw(out);
	}

	tz=gettimezoneinfo(); 
	count=0;

	for(k in js.list.resources){ 
		count++;
		cs=k.resource;
		if(not structkeyexists(cs.fields, 'name') or cs.fields.name DOES NOT CONTAIN "/"){
			// skip gold, etc
			continue;
		}
		arrName=listToArray(cs.fields.name, "/");
		if(arrayLen(arrName) NEQ 2){
			savecontent variable="out"{
				echo('Invalid resource name format<br>');
				echo(link&'<br>');
				writedump(resource);
			}
			throw(out);
		}

		// this is UTC date
		d=DateAdd("s", cs.fields.ts, "January 1 1970 00:00:00");

		// this is local date
		d=DateAdd("h", tz.utcHourOffset, d);

		if(structkeyexists(rateStruct, arrName[2])){
			db.sql="UPDATE #db.table("exchange_rate", request.zos.zcoreDatasource)# SET 
			exchange_rate_amount=#db.param(cs.fields.price)#,
			exchange_rate_datetime=#db.param(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"))#,
			exchange_rate_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE 
			exchange_rate_source_abbr=#db.param(arrName[1])# and 
			exchange_rate_destination_abbr=#db.param(arrName[2])# and
			exchange_rate_deleted=#db.param('0')# ";
			result=db.execute("qU"); 
		}else{
			db.sql="INSERT INTO #db.table("exchange_rate", request.zos.zcoreDatasource)# SET 
			exchange_rate_amount=#db.param(cs.fields.price)#,
			exchange_rate_datetime=#db.param(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"))#,
			exchange_rate_updated_datetime=#db.param(request.zos.mysqlnow)#,
			exchange_rate_source_abbr=#db.param(arrName[1])#,
			exchange_rate_destination_abbr=#db.param(arrName[2])#,
			exchange_rate_deleted=#db.param('0')# ";
			exchange_rate_id=db.execute("qInsert"); 
		}
	} 

	writeoutput('Updated #count# currency exchange rates.');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>