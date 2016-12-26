<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private">  
	<cfscript> 
	setting requestTimeout="100000";
	variables.userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36";

	request.cancelSemRushStruct={};
	</cfscript>
	
</cffunction>
<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript> 
	db=request.zos.queryObject;

	// for debugging only:
	//processMoz(application.zcore.functions.zVar("privateHomeDir", 298)&"seo-report-download/298-moz-keyword-report.csv", 298); abort;
	//processSemrush(application.zcore.functions.zVar("privateHomeDir", 298)&"seo-report-download/298-semrush-keyword-report.csv", 298); abort;
	mozStatus=application.zcore.functions.zso(application, 'mozImportStatus');
	if(mozStatus EQ ""){
		mozStatus="Inactive";
	}
	semrushStatus=application.zcore.functions.zso(application, 'semrushImportStatus');
	if(semrushStatus EQ ""){
		semrushStatus="Inactive";
	}
	webpositionStatus=application.zcore.functions.zso(application, 'webpositionImportStatus');
	if(webpositionStatus EQ ""){
		webpositionStatus="Inactive";
	}
	</cfscript>
	<h2>Import Keyword Ranking</h2>

	<p><a href="/z/inquiries/admin/import-keyword-ranking/webposition" target="_blank">Test Webposition.com Backup Import</a> (Status: #webpositionStatus#)</p>
	<p><a href="/z/inquiries/admin/import-keyword-ranking/moz" target="_blank">Test Moz.com Import</a> (Status: #mozStatus#)</p>
	<p><a href="/z/inquiries/admin/import-keyword-ranking/semrush" target="_blank">Test SEMRush.com Import</a> (Status: #semrushStatus#)</p>
	<!--- 

		keyword ranking - last 3 months, then same months previous year - color code only the newest month
			color code: green top 5 e0ea95
				blue top 10 94dbf7
				gray blue top 20 b8cce4
				orange top 50 fbd57f
				what is difference between "top" and regular keyword ranking report? top seems to be anything <= 50
			
			top X keywords this month last year, and this month this year (configure to be 5, 10, or 20 keywords when running)
			
			also combine keyword position with traffic for that keyword (not accurate since google not set prevents 90% of traffic from being visible) - i'd like to show another column of estimated traffic which multiplies this number to see degree of accuracy by calculating the ratio of not-set to total set.   
			
	seomoz upload:
		fields: Keyword,Location,Labels,For Future Use,For Future Use,For Future Use,Bing en-US Rank,Bing en-US Change (Deprecated),Bing en-US SERP Date,Bing en-US URL,Bing en-US Verticals,Bing en-US Position of Vertical(s) in SERP,Bing en-US You Present,Bing en-US Search Volume,Bing en-US Mobile Friendly,Bing en-US For Future Use,Bing en-US For Future Use,Google en-US Rank,Google en-US Change (Deprecated),Google en-US SERP Date,Google en-US URL,Google en-US Verticals,Google en-US Position of Vertical(s) in SERP,Google en-US You Present,Google en-US Search Volume,Google en-US Mobile Friendly,Google en-US For Future Use,Google en-US For Future Use,Yahoo en-US Rank,Yahoo en-US Change (Deprecated),Yahoo en-US SERP Date,Yahoo en-US URL,Yahoo en-US Verticals,Yahoo en-US Position of Vertical(s) in SERP,Yahoo en-US You Present,Yahoo en-US Search Volume,Yahoo en-US Mobile Friendly,Yahoo en-US For Future Use,Yahoo en-US For Future Use
			make new script seomoz-downloader/index


	webposition upload - all clients in one file - that's good.
		fields: Run Date,Engine,Keyword,URL,URL Type,Position,Delta
			need to associate domains to client_id - and set type (competitor vs client)
			widget.zsite.info.127.0.0.2.nip.io/webposition-downloader/moz
			 and 
			 widget.zsite.info.127.0.0.2.nip.io/webposition-downloader/index
	 --->

</cffunction>

<cffunction name="webposition" access="remote" localmode="modern">
	<!--- build one time import of all backed up files ---> 
	<cfscript>
	init();
	db=request.zos.queryobject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and  
	site_webposition_id_list<>#db.param('')#";
	qSite=db.execute("qSite"); 
 

	for(row in qSite){
		path=request.zos.globals.serverPrivateHomeDir&"webposition-backup/";
		application.zcore.functions.zCreateDirectory(path);
		arrId=listToArray(row.site_webposition_id_list, ",");
		for(id in arrId){   
			application.webpositionImportStatus=path&id; 
			processWebposition(path&id, row.site_id);
 
		} 
	}
	structdelete(application, 'webpositionImportStatus'); 
	echo('done');
	abort;
	</cfscript> 
</cffunction>

<cffunction name="processWebposition" access="public" localmode="modern">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	filePath=arguments.filePath;
	db=request.zos.queryObject;

	/*
	columns in use when this script was written:
	Run Date,Engine,Keyword,URL,URL Type,Position,Delta
	2016-04-01,Google,attorneys daytona beach,http://www.kvplaw.com/,Primary,14,n/a
	*/
	arrLine=listToArray(application.zcore.functions.zReadFile(filePath), chr(10));
	arrColumn=listToArray(arrLine[1], ",");
	arrayDeleteAt(arrLine, 1); 
	for(n=1;n<=arraylen(arrLine);n++){
		line=trim(arrLine[n]);
		if(line EQ ""){
			continue;
		}
		arrRow=listToArray(line, ",", true); 
		if(arrayLen(arrRow) NEQ arrayLen(arrColumn)){ 
			throw("Row #n# has #arrayLen(arrRow)# columns, but it must be #arrayLen(arrColumn)#.  Please review the file structure manually: #filePath#");
		}
	}  
	for(n=1;n<=arraylen(arrLine);n++){ 
		line=trim(arrLine[n]);
		if(line EQ ""){
			continue;
		}
		arrRow=listToArray(line, ",", true);
		cs={};
		for(i=1;i<=arraylen(arrColumn);i++){
			cs[trim(arrColumn[i])]=trim(arrRow[i]);
		} 
		if(cs.engine NEQ "Google"){
			continue;
		}
		if(cs["URL Type"] NEQ "Primary"){
			continue;
		}  
		// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
		db.sql="select * from #db.table("keyword_ranking", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(arguments.site_id)# and 
		keyword_ranking_deleted=#db.param(0)# and 
		keyword_ranking_position=#db.param(cs["Position"])# and
		keyword_ranking_run_datetime=#db.param(dateformat(cs["Run Date"], "yyyy-mm-dd")&" 00:00:00")# and 
		keyword_ranking_keyword=#db.param(cs.keyword)# and
		keyword_ranking_source=#db.param("2")#";
		qRank=db.execute("qRank");
		//writedump(qRank);

		if(qRank.recordcount EQ 0){
			// only import new records
			ts={
				table:"keyword_ranking",
				datasource:request.zos.zcoreDatasource,
				struct:{
					keyword_ranking_source:"2", // 1 is moz.com, 2 is webposition.com, 3 is semrush.com
					site_id:arguments.site_id,
					keyword_ranking_position:cs["Position"],
					keyword_ranking_run_datetime:dateformat(cs["Run Date"], "yyyy-mm-dd")&" 00:00:00",
					keyword_ranking_keyword:cs.keyword,
					keyword_ranking_updated_datetime:request.zos.mysqlnow,
					keyword_ranking_deleted:0,
					keyword_ranking_search_volume:""
				}
			}; 
			keyword_ranking_id=application.zcore.functions.zInsert(ts); 
			//writedump(keyword_ranking_id);
			//abort;
		}
	}
	echo(filePath&' processed<br>'); 
	</cfscript>
</cffunction> 

<!--- 
backup if they ever come back online:
<cffunction name="index" access="remote" localmode="modern"> 

<cfhttp url="https://my.webposition.com/SignIn" useragent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36"   method="post" timeout="20">

<cfhttpparam type="header" name="referer" value="https://my.webposition.com/SignIn" /> 
<cfhttpparam type="formfield" name="email" value="">
<cfhttpparam type="formfield" name="password" value="">
<cfhttpparam type="formfield" name="rememberMe" value="false">
<cfhttpparam type="formfield" name="returnURL" value="https://my.webposition.com/Reporter/144289/Export?format=Csv"> 
</cfhttp> 

<cfscript>
	writedump(cfhttp);
objCookies=GetResponseCookies(cfhttp);
</cfscript>
<cfhttp url="https://my.webposition.com/Reporter/144289/Export?format=Csv" useragent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36" timeout="30">
<!--- 
<cfhttpparam type="header" name="referer" value="https://my.webposition.com/SignIn" /> 
<cfhttpparam type="formfield" name="email" value="">
<cfhttpparam type="formfield" name="password" value="">
<cfhttpparam type="formfield" name="rememberMe" value="false">
<cfhttpparam type="formfield" name="returnURL" value="https://my.webposition.com/Reporter/144289/Export?format=Csv">  --->

	<cfloop item="strCookie" collection="#objCookies#"> 
        <cfhttpparam type="COOKIE" name="#strCookie#" value="#objCookies[ strCookie ].Value#">
    </cfloop>
</cfhttp> 
 
<cfscript>
	writedump(cfhttp);
</cfscript>
 
</cffunction>
 --->

<cffunction name="semrush" access="remote" localmode="modern">
	<cfscript>
	init();
	db=request.zos.queryobject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_semrush_id_list<>#db.param('')#";
	qSite=db.execute("qSite");  

	http url="https://www.semrush.com/json_users/login" useragent="#variables.userAgent#" redirect="yes"   method="post" timeout="20"{ 
		httpparam type="formfield" name="event_source" value="semrush";
		httpparam type="formfield" name="user_agent_hash" value="#hash(variables.userAgent)#";
		httpparam type="formfield" name="email" value="#request.zos.semrushUsername#";
		httpparam type="formfield" name="password" value="#request.zos.semrushPassword#";
	} 
	if(left(cfhttp.statuscode,3) NEQ '200' and left(cfhttp.statuscode,3) NEQ '302'){
		savecontent variable="out"{
			echo('<h2>semrush.com login failed.</h2>');
			writedump(cfhttp);
		}
		throw(out);
	}
	objCookies2=application.zcore.functions.zGetResponseCookies(cfhttp); 
	//writedump(cfhttp);
	//writedump(objCookies2);
	//abort;
	objCookies={};
	objCookies.ref_code="__default__";
	objCookies.localization="%7B%22locale%22%3A%22en%22%7D";
	objCookies.db="us";
	objCookies.n_userid=objCookies2.n_userid.value;
	objCookies.PHPSESSID=objCookies2.PHPSESSID.value;
	objCookies.usertype="Paid-User";   

	for(row in qSite){
		if(row.site_semrush_last_import_datetime EQ ""){
			row.site_semrush_last_import_datetime=request.zos.semrushStartDate;
		}
		// go back a day to make sure we didn't miss something
		row.site_semrush_last_import_datetime=dateadd("d", -1, row.site_semrush_last_import_datetime);
		echo(row.site_domain&" : "&dateformat(row.site_semrush_last_import_datetime, "m/d/yyyy")&"<br>");
		path=application.zcore.functions.zVar("privateHomeDir", row.site_id)&"seo-report-download/";
		application.zcore.functions.zCreateDirectory(path);
		arrId=listToArray(row.site_semrush_id_list, ",");

		// TODO: We need to do a separate request for each month in the past to gather the past data, and then only gather new data once per month FOR THE PREVIOUS MONTH.  There are API limits that we must avoid.
		// Might be easier to start from now and go back in time, until we detect there is no data for that time period
		tempStartDate=row.site_semrush_last_import_datetime;
		tempEndDate=dateadd("m", 1, tempStartDate);
		count=0;
		while(true){
			count++;
			if(count > 500){
				throw("Infinite loop detected");
			} 
			if(datecompare(tempStartDate, now()) EQ 1){
				echo('Reached now<br>');
				break; 
			}
			for(id in arrId){ 
		 		id=replace(id, "/", "."); 

		 		filePath=path&row.site_id&"-semrush-keyword-report.csv";
		 		site=application.zcore.functions.zVar("shortdomain", row.site_id);
		 		site=replace(site, "."&request.zos.testDomain, "");
		 		application.zcore.functions.zDeleteFile(filePath);

		 		// TODO might need a field to configure local vs national for semrush
		 		link="https://api.semrush.com/reports/tracking/?key=#request.zos.semrushAPIKey#&campaign_id=#id#&display_hash=&action=report&type=tracking_position_rankings_overview_organic&use_volume=national&date_begin=#dateformat(tempStartDate, "yyyymmdd")#&date_end=#dateformat(tempEndDate, "yyyymmdd")#&display_limit=1000000&display_filter=&display_sort=0_pos_asc&linktype_filter=0&url=*.#site#%2F*&export_columns=Ph%2CTg%2CDt%2CNq%2CCp&export=csv";
				http url="#link#" useragent="#variables.userAgent#" path="#path#" file="#row.site_id#-semrush-keyword-report.csv" redirect="yes" method="get" timeout="30"{
					for(strCookie in objCookies){ 
						httpparam type="COOKIE" name="#strCookie#" value="#objCookies[ strCookie ]#";
					}
				} 
				if(left(cfhttp.statuscode,3) NEQ '200'){
					savecontent variable="out"{
						echo('<h2>semrush.com keyword report download failed.<br>url: #link#</h2>');
						writedump(cfhttp);
					}
					throw(out);
				} 
				application.semrushImportStatus=tempStartDate&" - "&path&row.site_id&"-moz-keyword-report.csv";
				processSemRush(path&row.site_id&"-semrush-keyword-report.csv", row.site_id); 

				sleep(randrange(1000, 3000));// wait some seconds to avoid looking abusive.
			} 
			tempStartDate=dateadd("m", 1, tempStartDate);
			tempEndDate=dateadd("m", 1, tempEndDate);

			db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
			site_semrush_last_import_datetime=#db.param(dateformat(tempStartDate, "yyyy-mm-dd")&" "&timeformat(tempStartDate, "HH:mm:ss"))#,
			site_updated_datetime=#db.param(request.zos.mysqlnow)# 
			WHERE site_id=#db.param(row.site_id)# and 
			site_deleted=#db.param(0)#";
			qUpdate=db.execute("qUpdate");

			if(request.zos.isTestServer){
			//	echo("On the test server, we only run one import per site.<br>");
			//	break;
			}
		} 
	}
	echo('done'); 
	structdelete(application, 'semrushImportStatus');
	abort;
	</cfscript>
	
    
</cffunction>

<cffunction name="processSemrush" access="public" localmode="modern">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	filePath=arguments.filePath;
	db=request.zos.queryObject;

	/*
	columns in use when this script was written:
	Keyword,Tags,*.client.com/*_20161223,*.client.com/*_20161223_type,*.client.com/*_20161223_landing,*.client.com/*_difference,Search Volume,CPC
	*/

	arrLine=listToArray(application.zcore.functions.zReadFile(filePath), chr(10));
	// delete first 5 lines because the format is non-sense
	for(i=1;i<=6;i++){
		arrayDeleteAt(arrLine, 1);
	}
	arrColumn=listToArray(arrLine[1], ",");

	rankingColumn=arrColumn[3];
	arrC=listToArray(rankingColumn, "_");
	keywordCheckDate=arrC[2];
	keywordCheckDate=left(keywordCheckDate, 4)&"/"&mid(keywordCheckDate, 5, 2)&"/"&right(keywordCheckDate, 2); 

	arrayDeleteAt(arrLine, 1);

	for(n=1;n<=arraylen(arrLine);n++){
		line=trim(arrLine[n]);
		if(line EQ ""){
			continue;
		}
		arrRow=listToArray(line, ",", true); 
		if(arrayLen(arrRow) NEQ arrayLen(arrColumn)){
			throw("Row #n# has #arrayLen(arrRow)# columns, but it must be #arrayLen(arrColumn)#.  Please review the file structure manually: #filePath#");
		}
	}
	for(n=1;n<=arraylen(arrLine);n++){
		line=trim(arrLine[n]);
		if(line EQ ""){
			continue;
		}
		arrRow=listToArray(line, ",", true);
		cs={};
		for(i=1;i<=arraylen(arrColumn);i++){
			cs[trim(arrColumn[i])]=trim(arrRow[i]);
		}
		if(not isnumeric(cs[rankingColumn])){
			cs[rankingColumn]=0;
		}

		// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
		db.sql="select * from #db.table("keyword_ranking", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(arguments.site_id)# and 
		keyword_ranking_deleted=#db.param(0)# and 
		keyword_ranking_position=#db.param(cs[rankingColumn])# and
		keyword_ranking_run_datetime=#db.param(dateformat(keywordCheckDate, "yyyy-mm-dd")&" 00:00:00")# and 
		keyword_ranking_keyword=#db.param(cs.keyword)# and
		keyword_ranking_source=#db.param("3")#";
		qRank=db.execute("qRank");
		//writedump(qRank);

		if(qRank.recordcount EQ 0){
			// only import new records
			ts={
				table:"keyword_ranking",
				datasource:request.zos.zcoreDatasource,
				struct:{
					keyword_ranking_source:"3", // 1 is moz.com, 2 is webposition.com, 3 is semrush.com
					site_id:arguments.site_id,
					keyword_ranking_position:cs[rankingColumn],
					keyword_ranking_run_datetime:dateformat(keywordCheckDate, "yyyy-mm-dd")&" 00:00:00",
					keyword_ranking_keyword:cs.keyword,
					keyword_ranking_updated_datetime:request.zos.mysqlnow,
					keyword_ranking_deleted:0,
					keyword_ranking_search_volume:cs["Search Volume"]
				}
			};
			//writedump(ts);
			//abort;
			keyword_ranking_id=application.zcore.functions.zInsert(ts); 
			//writedump(keyword_ranking_id);
			//abort;
		}
	}
	echo(filePath&' processed<br>');
	application.zcore.functions.zRenameFile(filePath, filePath&"-processed-"&dateformat(now(), "yyyy-mm-dd")&"-"&timeformat(now(), "HH-mm-ss")&".csv");
	</cfscript>
</cffunction>
	

<cffunction name="moz" access="remote" localmode="modern">

	<cfscript>
	init();
	db=request.zos.queryobject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and  
	site_seomoz_id_list<>#db.param('')#";
	qSite=db.execute("qSite"); 

	// 	https://moz.com/products/api/keys 

	http url="https://moz.com/login" useragent="#variables.userAgent#" redirect="yes"   method="post" timeout="20"{
		httpparam type="header" name="referer" value="https://moz.com/login?redirect=/home";
		httpparam type="formfield" name="data[User][redirect]" value="/home";
		httpparam type="formfield" name="data[User][login_email]" value="#request.zos.seomozUsername#";
		httpparam type="formfield" name="data[User][password]" value="#request.zos.seomozPassword#";
	}
	if(left(cfhttp.statuscode,3) NEQ '200' and left(cfhttp.statuscode,3) NEQ '302'){
		savecontent variable="out"{
			echo('<h2>moz.com login failed.</h2>');
			writedump(cfhttp);
		}
		throw(out);
	}

	objCookies=application.zcore.functions.zGetResponseCookies(cfhttp); 
	//writedump(cfhttp);
	//writedump(objCookies);

	for(row in qSite){
		path=application.zcore.functions.zVar("privateHomeDir", row.site_id)&"seo-report-download/";
		application.zcore.functions.zCreateDirectory(path);
		arrId=listToArray(row.site_seomoz_id_list, ",");
		for(id in arrId){
	 		id=replace(id, "/", ".");
	 		link="https://analytics.moz.com/delorean-api/rankings/prod.#id#/grouped-by/engine-variant/You/week.csv?date_range=#request.zos.seomozStartDate#..#dateformat(now(), "yyyy-mm-dd")#";
	 		filePath=path&row.site_id&"-moz-keyword-report.csv";
	 		application.zcore.functions.zDeleteFile(filePath);
			http url="#link#" useragent="#variables.userAgent#" path="#path#" file="#row.site_id#-moz-keyword-report.csv" timeout="30"{  
				for(strCookie in objCookies){
					httpparam type="COOKIE" name="#strCookie#" value="#objCookies[ strCookie ].Value#";
				}
			} 
			if(left(cfhttp.statuscode,3) NEQ '200'){
				savecontent variable="out"{
					echo('<h2>moz.com keyword report download failed.<br>url: #link#</h2>');
					writedump(cfhttp);
				}
				throw(out);
			}
 
			application.mozImportStatus=path&row.site_id&"-moz-keyword-report.csv";
			processMoz(path&row.site_id&"-moz-keyword-report.csv", row.site_id);

			sleep(randrange(1000, 3000));// wait some seconds to avoid looking abusive.
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_seomoz_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate");
	}
	structdelete(application, 'mozImportStatus'); 
	echo('done');
	abort;
	</cfscript> 
</cffunction>

<cffunction name="processMoz" access="public" localmode="modern">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	filePath=arguments.filePath;
	db=request.zos.queryObject;

	/*
	columns in use when this script was written:
	Keyword,Location,Labels,For Future Use,For Future Use,For Future Use,Bing en-US Rank,Bing en-US Change (vs previous date),Bing en-US SERP Date,Bing en-US URL,Bing en-US Verticals,Bing en-US Position of Vertical(s) in SERP,Bing en-US You Present,Bing en-US Search Volume,Bing en-US Mobile Friendly,Bing en-US For Future Use,Bing en-US For Future Use,Google en-US Rank,Google en-US Change (vs previous date),Google en-US SERP Date,Google en-US URL,Google en-US Verticals,Google en-US Position of Vertical(s) in SERP,Google en-US You Present,Google en-US Search Volume,Google en-US Mobile Friendly,Google en-US For Future Use,Google en-US For Future Use,Yahoo en-US Rank,Yahoo en-US Change (vs previous date),Yahoo en-US SERP Date,Yahoo en-US URL,Yahoo en-US Verticals,Yahoo en-US Position of Vertical(s) in SERP,Yahoo en-US You Present,Yahoo en-US Search Volume,Yahoo en-US Mobile Friendly,Yahoo en-US For Future Use,Yahoo en-US For Future Use
	*/

	arrLine=listToArray(application.zcore.functions.zReadFile(filePath), chr(10));
	// delete first 5 lines because the format is non-sense
	for(i=1;i<=5;i++){
		arrayDeleteAt(arrLine, 1);
	}
	arrColumn=listToArray(arrLine[1], ",", true);
	arrayDeleteAt(arrLine, 1);

	contents=arrayToList(arrLine, chr(10));

	dataImportCom = createobject( 'component', 'zcorerootmapping.com.app.dataImport' );

	dataImportCom.config.escapedBy               = "";
	dataImportCom.config.textQualifier           = '"';
	dataImportCom.config.seperator               = ",";
	dataImportCom.config.lineDelimiter           = chr(10);
	dataImportCom.config.allowUnequalColumnCount = false;

	dataImportCom.parseCSV( contents );
	dataImportCom.arrColumns = arrColumn;
	columns = dataImportCom.arrColumns;

	mappedColumns = {};

	for ( columnsIndex = 1; columnsIndex LTE arraylen( columns ); columnsIndex++ ) {
		mappedColumns[ columns[ columnsIndex ] ] = columns[ columnsIndex ];
	}

	dataImportCom.mapColumns( mappedColumns );
	/*
	for(n=1;n<=arraylen(arrLine);n++){
		line=trim(arrLine[n]);
		if(line EQ ""){
			continue;
		}
		arrRow=listToArray(line, ",", true); 
		if(arrayLen(arrRow) NEQ arrayLen(arrColumn)){
		writedump(arrRow);
		writedump(arrColumn);
		abort;
			throw("Row #n# has #arrayLen(arrRow)# columns, but it must be #arrayLen(arrColumn)#.  Please review the file structure manually: #filePath#");
		}
	} */
	lineCount = dataImportCom.getCount();

	for(n=1;n<=lineCount;n++){
		cs = dataImportCom.getRow();
		/*
		//line=trim(arrLine[n]);
		if(line EQ ""){
			continue;
		}
		arrRow=listToArray(line, ",", true);
		cs={};
		for(i=1;i<=arraylen(arrColumn);i++){
			cs[trim(arrColumn[i])]=trim(arrRow[i]);
		}*/
		//writedump(cs);abort;

		volume="";
		arrVolume=listToArray(cs["Google en-US Search Volume"], ".");
		if(arrayLen(arrVolume)){
			volume=arrVolume[arrayLen(arrVolume)];
		}
		if(not isnumeric(volume)){
			volume=0;
		}
		//writedump("volume:"&volume);abort;

		// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
		db.sql="select * from #db.table("keyword_ranking", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(arguments.site_id)# and 
		keyword_ranking_deleted=#db.param(0)# and 
		keyword_ranking_position=#db.param(cs["Google en-US Rank"])# and
		keyword_ranking_run_datetime=#db.param(dateformat(cs["Google en-US SERP Date"], "yyyy-mm-dd")&" 00:00:00")# and 
		keyword_ranking_keyword=#db.param(cs.keyword)# and
		keyword_ranking_source=#db.param("1")#";
		qRank=db.execute("qRank");
		//writedump(qRank);

		if(qRank.recordcount EQ 0){
			// only import new records
			ts={
				table:"keyword_ranking",
				datasource:request.zos.zcoreDatasource,
				struct:{
					keyword_ranking_source:"1", // 1 is moz.com, 2 is webposition.com, 3 is semrush.com
					site_id:arguments.site_id,
					keyword_ranking_position:cs["Google en-US Rank"],
					keyword_ranking_run_datetime:dateformat(cs["Google en-US SERP Date"], "yyyy-mm-dd")&" 00:00:00",
					keyword_ranking_keyword:cs.keyword,
					keyword_ranking_updated_datetime:request.zos.mysqlnow,
					keyword_ranking_deleted:0,
					keyword_ranking_search_volume:volume
				}
			};
			//writedump(ts);
			//abort;
			keyword_ranking_id=application.zcore.functions.zInsert(ts); 
			//writedump(keyword_ranking_id);
			//abort;
		}
	}
	echo(filePath&' processed<br>');
	application.zcore.functions.zRenameFile(filePath, filePath&"-processed-"&replace(request.zos.mysqlnow, ":", "-", "all")&".csv");
	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>