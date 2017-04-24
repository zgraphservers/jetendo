<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	setting requesttimeout="10000";
	// you must preregister the returnLink at the oauth2 vendor's web site.
	// /z/inquiries/admin/google-oauth/return

	variables.returnLink=request.zos.globals.domain&"/z/inquiries/admin/google-oauth/return"; 
	</cfscript>
</cffunction> 

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	application.zcore.functions.zStatusHandler(request.zsid);
	scope="https://www.googleapis.com/auth/analytics.readonly https://www.googleapis.com/auth/webmasters.readonly";

	//link='https://accounts.google.com/o/oauth2/auth'; 
	link="https://accounts.google.com/o/oauth2/v2/auth"; 

	firstAuthLink="#link#?response_type=code&client_id=#request.zos.googleAnalyticsConfig.clientId#&redirect_uri=#urlencodedformat(variables.returnLink)#&scope=#urlencodedformat(scope)#&prompt=consent&access_type=offline";

	// issuer=#urlencodedformat(sc.client_email)#&signingAlgorithm=RS256&signingKey=#urlencodedformat(ss.private_key)#

	//jwt.encode( somePayload, "RS256", "publicKey", "privateKey" );
	//jwt.decode( jwtToken, "RS256", "publicKey", "privateKey" );

	sc=request.zos.googleAnalyticsConfig.serverLogin;
	// this is for JOT later:
	//firstAuthLink="#link#?response_type=code&client_id=#sc.client_id#&redirect_uri=#urlencodedformat(variables.returnLink)#&scope=#urlencodedformat(scope)#&access_type=offline&assertion=#urlencodedformat(jsonWebToken)#";// &prompt=consent
/*
        $this->auth = new OAuth2([
            'audience' => self::TOKEN_CREDENTIAL_URI,
            'issuer' => $jsonKey['client_email'],
            'scope' => $scope,
            'signingAlgorithm' => 'RS256',
            'signingKey' => $jsonKey['private_key'],
            'sub' => $sub,
            'tokenCredentialUri' => self::TOKEN_CREDENTIAL_URI,
        ]);
	 ts.zos.googleAnalyticsConfig.serverLogin={
        "type": "service_account",
        "project_id": "",
        "private_key_id": "",
        "private_key": "",
        "client_email": "",
        "client_id": "",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://accounts.google.com/o/oauth2/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/jetendo-google-analytics%40jetendo-153519.iam.gserviceaccount.com"
    };*/

	</cfscript>
	<p><a href="#firstAuthLink#">Authenticate with Google Analytics</a></p>
	<!--- <p><a href="/z/inquiries/admin/google-oauth/passwordLogin">Login with password</a></p> --->
	<!--- 
todo: add search console api: POST https://www.googleapis.com/webmasters/v3/sites/http%3A%2F%2Fwww.boomerpower.info%2F/searchAnalytics/query?fields=rows&key=


Google Analytics:
		
	Finding data:
		Search for client 
			Search date range on reporting tab - also notice the date range compare feature on date range.
			Audience -> Overview
					This gives you total sessions, pageviews, bounce rate, time on site and more.
			Acquistion -> All Traffic -> Source/Medium
				In the middle of the page, click Keyword
					Click advanced
						Set to Exclude Keyword, change Contained to Matching RegExp
							Type in pipe delimited list of client name / company / person's name to exclude them.
								Now you have a report of the top organic search keywords.
			Conversions -> Goals -> Overview 
				You can see each lead type here.  Note, the web site database is more accurate since google analytics can be blocked.
	 --->
</cffunction>


<!--- <cffunction name="passwordLogin" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	http url="https://api.oauth2server.com/token" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="password";
		httpparam type="formfield" name="username" value="#request.zos.googleAnalyticsConfig.username#";
		httpparam type="formfield" name="password" value="#request.zos.googleAnalyticsConfig.password#";
		httpparam type="formfield" name="client_id" value="#request.zos.googleAnalyticsConfig.serverLogin.client_id#";
	} 

	writedump(cfhttp);

	if(not isJson(cfhttp.filecontent)){
		writedump(cfhttp.filecontent);
		return;
	}

	js=deserializeJson(cfhttp.filecontent);
	if(structkeyexists(js, 'error')){
		echo("Error:"&js.error);
		return;
	}	
	if(structkeyexists(js, 'access_token')){
		js.access_token;
		application.googleAnalyticsAccessToken=js.access_token;
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/reportIndex");
	}else{
		echo('Unknown response:');
		writedump(js);
		abort;
	}
	
    </cfscript>
	
</cffunction> --->

<cffunction name="return" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	form.code=application.zcore.functions.zso(form, 'code');
	//writedump(form);
	//link='https://accounts.google.com/o/oauth2/token';
	link="https://www.googleapis.com/oauth2/v4/token";
	http url="#link#" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="authorization_code";
		httpparam type="formfield" name="code" value="#form.code#";
		httpparam type="formfield" name="redirect_uri" value="#variables.returnLink#";
		httpparam type="formfield" name="client_id" value="#request.zos.googleAnalyticsConfig.clientId#";
		httpparam type="formfield" name="client_secret" value="#request.zos.googleAnalyticsConfig.clientSecret#"; 
	}

	//writedump(cfhttp); 
	/*
	response json is:
	{
	  "access_token": "...", 
	  "token_type": "Bearer", 
	  "expires_in": 3600, 
	  "refresh_token": "..."
	}
	*/ 

	if(not isJson(cfhttp.filecontent)){
		writedump(cfhttp.filecontent);
		return;
	}
	// 401 is expired token
	// 403 is no access to "view"

	js=deserializeJson(cfhttp.filecontent);
	if(structkeyexists(js, 'error')){
		writedump(js.error);
		return;
	}	
	if(structkeyexists(js, 'access_token')){
		application.googleAnalyticsAccessToken=js;
		application.googleAnalyticsAccessToken.loginDatetime=now();
		application.googleAnalyticsAccessToken.expiresDatetime=dateadd("s", js.expires_in, application.googleAnalyticsAccessToken.loginDatetime);
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/reportIndex");
	}else{
		echo('Unknown response:');
		writedump(js);
		abort;
	}
 
	</cfscript>
</cffunction>

<cffunction name="reportIndex" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	if(structkeyexists(form, 'googleSearchConsoleCancel')){
		application.googleSearchConsoleCancel=1; 
	}
	if(structkeyexists(form, 'googleAnalyticsOverviewCancel')){
		application.googleAnalyticsOverviewCancel=1; 
	}
	if(structkeyexists(form, 'googleAnalyticsOrganicCancel')){
		application.googleAnalyticsOrganicCancel=1; 
	}
	if(structkeyexists(form, 'googleAnalyticsKeywordCancel')){
		application.googleAnalyticsKeywordCancel=1; 
	}
	if(not structkeyexists(application, 'googleAnalyticsAccessToken')){
		application.zcore.status.setStatus(request.zsid, "Invalid access token", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/index?zsid=#request.zsid#");
	}
	echo("Access Token:<br>");
	writedump(application.googleAnalyticsAccessToken);

	overviewLink="/z/inquiries/admin/google-oauth/overview";
	organicLink="/z/inquiries/admin/google-oauth/organic";
	keywordLink="/z/inquiries/admin/google-oauth/keyword";
	goalLink="/z/inquiries/admin/google-oauth/goal";
	refreshLink="/z/inquiries/admin/google-oauth/refreshToken";
	searchConsoleLink="/z/inquiries/admin/google-oauth/searchConsole";
	</cfscript>
	<p>You can add sid=SITEID&amp;reimport=1 to pull the data again for a specific site.</p>

	<p><a href="/z/inquiries/admin/custom-lead-report/index" target="_blank">View Report</a></p>
	<p><a href="/z/inquiries/admin/google-oauth/revokeToken">Revoke Auth Token</a></p>
	<p><a href="#overviewLink#" target="_blank">Google Analytics Main Overview</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleAnalyticsOverviewStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleAnalyticsOverviewStatus=1">Cancel</a>)
		</cfif></p>
	<p><a href="#organicLink#" target="_blank">Google Analytics Organic Search</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleAnalyticsOrganicStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleAnalyticsOrganicCancel=1">Cancel</a>)
		</cfif></p>
	<p><a href="#keywordLink#" target="_blank">Google Analytics Keywords</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleAnalyticsKeywordStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleAnalyticsKeywordCancel=1">Cancel</a>)
		</cfif></p>
	<p><a href="#searchConsoleLink#" target="_blank">Google Webmaster Search Console Keywords</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleSearchConsoleStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleSearchConsoleCancel=1">Cancel</a>)
		</cfif> </p> 
	<!--- <p><a href="#goalLink#" target="_blank">Google Analytics Goals</a></p>  --->
	<p><a href="#refreshLink#">Refresh Token (#dateformat(application.googleAnalyticsAccessToken.expiresDatetime, "m/d/yyyy")&" "&timeformat(application.googleAnalyticsAccessToken.expiresDatetime, "h:mm tt")#)</a></p>
</cffunction>

<cffunction name="revokeToken" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	//https://accounts.google.com/o/oauth2/revoke?token=
	http url="https://accounts.google.com/o/oauth2/revoke?token=#application.googleAnalyticsAccessToken.access_token#" method="get" timeout="10"{ 
	}

	//writedump(cfhttp);

	application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/index");
	abort;
	</cfscript>
</cffunction>

<cffunction name="refreshToken" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	form.code=application.zcore.functions.zso(form, 'code');
	if(not structkeyexists(application, 'googleAnalyticsAccessToken')){
		application.zcore.status.setStatus(request.zsid, "You must authenticate with google analytics first.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/index?zsid=#request.zsid#");
	}
	http url="https://www.googleapis.com/oauth2/v4/token" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="refresh_token";
		httpparam type="formfield" name="refresh_token" value="#application.googleAnalyticsAccessToken.refresh_token#"; 
		httpparam type="formfield" name="client_id" value="#request.zos.googleAnalyticsConfig.clientId#";
		httpparam type="formfield" name="client_secret" value="#request.zos.googleAnalyticsConfig.clientSecret#"; 
	}

	writedump(cfhttp); 
	/*
	response json is:
	{
	  "access_token": "***", 
	  "token_type": "***", 
	  "expires_in": 0
	}
	*/ 

	if(not isJson(cfhttp.filecontent)){
		writedump(cfhttp.filecontent);
		return;
	}
	// 401 is expired token
	// 403 is no access to "view"

	js=deserializeJson(cfhttp.filecontent);
	if(structkeyexists(js, 'error')){
		writedump(js.error);
		return;
	}	
	if(structkeyexists(js, 'access_token')){ 
		application.googleAnalyticsAccessToken.loginDatetime=now();
		application.googleAnalyticsAccessToken.expiresDatetime=dateadd("s", js.expires_in, application.googleAnalyticsAccessToken.loginDatetime);

		// TODO: don't need to redirect when this is done
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/reportIndex");
	}else{
		echo('Unknown response:');
		writedump(js);
		abort;
	}
	</cfscript>
</cffunction>
 

<cffunction name="doAPICall" localmode="modern" access="public">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript> 
	/*
	limits for read-only:
	10 queries per second per user - can send userIp, if multiple users
	50,000 requests per day.
	*/

 	link='https://analyticsreporting.googleapis.com/v4/reports:batchGet?access_token=#application.googleAnalyticsAccessToken.access_token#&alt=json';
 	//echo(link);
 	jsonString=serializeJson(arguments.jsonStruct); 
	jsonString=application.zcore.functions.zHttpJsonPost(link, jsonString, 20);
	
	if(jsonString EQ false or not isJson(jsonString)){
		throw(jsonString);
	}
	js=deserializeJson(jsonString); 
	if(structkeyexists(js, 'error')){
		savecontent variable="out"{
			echo('API Call Failure.  Input:');
			writedump(jsonStruct);
			echo('Response:');
			writedump(js.error);
		}
		throw(out);
	}
	return js;
	</cfscript>
</cffunction>

<cffunction name="searchConsole" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	init();
	db=request.zos.queryObject;
	/*
	Limits: 5 queries per second  200 queries per minute 
	documentation: https://developers.google.com/webmaster-tools/v3/searchanalytics/query#dimensionFilterGroups.filters.dimension
	*/

	// force ricerose for now: 
	if(request.zos.isTestServer){
		form.sid=528;
	}else{
		//form.sid=422;
	} 

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_search_console_domain<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite");     

 	for(row in qSite){
		startMonthDate=dateformat(dateadd("d", -90, now()), "yyyy-mm-")&"01";
		endDate=dateformat(dateadd("d", -1, dateadd("m", 1, startMonthDate)), "yyyy-mm-dd");

		for(n2=1;n2<=3;n2++){  
			if(structkeyexists(application, 'googleSearchConsoleCancel')){
				application.googleSearchConsoleStatus="";
				structdelete(application, 'googleSearchConsoleCancel');
				echo('Cancelled');
				abort;
			}
			application.googleSearchConsoleStatus="Processing #row.site_short_domain# at #startMonthDate# to #endDate#";
			link="https://www.googleapis.com/webmasters/v3/sites/#urlencodedformat(row.site_google_search_console_domain)#/searchAnalytics/query?access_token=#application.googleAnalyticsAccessToken.access_token#&alt=json&fields=rows";
			jsonStruct={
				"startDate": startMonthDate,
				"endDate": endDate,
				"dimensions": [
					"query"
				]
			};
		 	jsonString=serializeJson(jsonStruct); 
			jsonString=application.zcore.functions.zHttpJsonPost(link, jsonString, 20);
			
			if(jsonString EQ false or not isJson(jsonString)){
				throw(jsonString);
			}
			js=deserializeJson(jsonString); 
			if(structkeyexists(js, 'error')){
				savecontent variable="out"{
					echo('API Call Failure.  Input:');
					writedump(jsonStruct);
					echo('Response:');
					writedump(js.error);
				}
				throw(out);
			} 
			// writedump(js);abort;

			//abort;
			/*
			json response is:
			{
			 "rows": [
			  {
			   "keys": [
			    "baby boomer gifts"
			   ],
			   "clicks": 0,
			   "impressions": 6,
			   "ctr": 0,
			   "position": 33.166666666666664
			  },
			  {
			   "keys": [
			    "young martin o malley"
			   ],
			   "clicks": 0,
			   "impressions": 2,
			   "ctr": 0,
			   "position": 1
			  }
			 ]
			}
			*/
			arrData=[]; 
			if(not structkeyexists(js, 'rows')){
				echo('Search console returned no data for #row.site_short_domain# | #startMonthDate# to #endDate#<br>'); 
				startMonthDate=dateFormat(dateadd("m", 1, startMonthDate), "yyyy-mm-dd");
				endDate=dateformat(dateadd("m", 1, endDate), "yyyy-mm-dd");
				continue;
			}
			for(n=1;n<=arraylen(js.rows);n++){
				ds=js.rows[n]; 
				ts={};
				ts.ga_month_keyword_keyword=ds.keys[1];
				ts.ga_month_keyword_type=2; // 1 is google analytics, 2 is webmaster tool search analytics
				ts.ga_month_keyword_visits=ds.clicks;
				ts.ga_month_keyword_impressions=ds.impressions;
				ts.ga_month_keyword_ctr=ds.ctr;
				ts.ga_month_keyword_position=ds.position;
				ts.ga_month_keyword_date=startMonthDate;
				ts.ga_month_keyword_updated_datetime=request.zos.mysqlnow;
				ts.ga_month_keyword_deleted=0;
				ts.site_id=row.site_id;
		 
				// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
				db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(ts.site_id)# and 
				ga_month_keyword_deleted=#db.param(0)# and 
				ga_month_keyword_date=#db.param(dateformat(startMonthDate, "yyyy-mm-dd"))# and 
				ga_month_keyword_keyword=#db.param(ts.ga_month_keyword_keyword)# and
				ga_month_keyword_type=#db.param(ts.ga_month_keyword_type)#";
				qRank=db.execute("qRank"); 
				/*writedump(qRank);
				writedump(ts);
				abort;*/
				// only import new records
				ts2={
					table:"ga_month_keyword",
					datasource:request.zos.zcoreDatasource,
					struct:ts 
				}; 
				if(qRank.recordcount EQ 0){
					ga_month_keyword_id=application.zcore.functions.zInsert(ts2); 
				}else{
					ts2.struct.ga_month_keyword_id=qRank.ga_month_keyword_id;
					application.zcore.functions.zUpdate(ts2);
				}   
			} 
			echo('Processed search console for #row.site_short_domain# | #startMonthDate# to #endDate#<br>'); 
			startMonthDate=dateFormat(dateadd("m", 1, startMonthDate), "yyyy-mm-dd");
			endDate=dateformat(dateadd("m", 1, endDate), "yyyy-mm-dd");
			sleep(1000); // sleep to avoid hitting google's api limit
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_search_console_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate");
	}

	application.googleSearchConsoleStatus="";
	echo('done'); 
	</cfscript>
</cffunction>

<cffunction name="processGASummary" localmode="modern" access="public">
	<cfargument name="ds2" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	ds2=arguments.ds2;  
	js=doAPICall(ds2.js);  
	arrLabel=[
		"Users",
		"Sessions",
		"Visitors", 
		"Visits",
		"Bounces",
		"Pageviews",
		"Visit Bounce Rate",
		"Time On Site",
		"Average Time On Site"
	]; 
	if(not structkeyexists(js, 'reports')){
		echo('missing reports<br>');
		return false;
	}
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		if(not structkeyexists(rs.data, 'rows')){
			echo('missing rows<br>');
			return false;
		}
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n]; 
			values=ds.metrics[1].values;
			ss={};
			if(arrayLen(ds.dimensions) EQ 2){
				tempMonth=ds.dimensions[2];
			}else{
				tempMonth=ds.dimensions[1];
			}
			ss.month=ds2.startDate;//dateformat(dateadd("m", tempMonth, ds2.startDate), "yyyy-mm-dd");
			for(g=1;g<=arraylen(values);g++){
				ss[arrLabel[g]]=values[g];
			} 
			ts={};
			ts.site_id=ds2.site_id;
			ts.ga_month_date=ss.month;
			ts.ga_month_type=ds2.ga_month_type; // 1 is google everything (overview), 2 is google organic traffic only
			ts.ga_month_users=ss.users;
			ts.ga_month_sessions=ss.sessions;
			ts.ga_month_visitors=ss.visitors;
			ts.ga_month_visits=ss.visits;
			ts.ga_month_bounces=ss.bounces;
			ts.ga_month_pageviews=ss.pageviews;
			ts.ga_month_visit_bounce_rate=ss["Visit Bounce Rate"];
			ts.ga_month_time_on_site=ss["Time On Site"];
			ts.ga_month_average_time_on_site=ss["Average Time On Site"];
			ts.ga_month_updated_datetime=0;
			ts.ga_month_deleted=0; 
	 		//writedump(ts);abort;
			// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
			db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(ts.site_id)# and 
			ga_month_deleted=#db.param(0)# and 
			ga_month_date=#db.param(dateformat(ts.ga_month_date, "yyyy-mm-dd"))# and  
			ga_month_type=#db.param(ts.ga_month_type)#";
			qRank=db.execute("qRank"); 
			/*writedump(qRank);
			writedump(ts);
			abort;*/
			// only import new records
			ts2={
				table:"ga_month",
				datasource:request.zos.zcoreDatasource,
				struct:ts 
			};  
			/*writedump(qrank);
			writedump(ts);
			abort;*/
			if(qRank.recordcount EQ 0){
				ga_month_id=application.zcore.functions.zInsert(ts2); 
			}else{
				ts2.struct.ga_month_id=qRank.ga_month_id; 
				result=application.zcore.functions.zUpdate(ts2); 
			}    
		}
	} 
	return true;
	</cfscript>
</cffunction>
 
<cffunction name="overview" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>  
	init();
	db=request.zos.queryObject;
	/*
	documented here: https://developers.google.com/analytics/devguides/reporting/core/v3/common-queries

	dimensions=ga:source,ga:medium
	metrics=ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits
	sort=-ga:sessions

	or

	paid search:
	dimensions=ga:source
	metrics=ga:pageviews,ga:sessionDuration,ga:exits
	filters=ga:medium==cpa,ga:medium==cpc,ga:medium==cpm,ga:medium==cpp,ga:medium==cpv,ga:medium==ppc
	sort=-ga:pageviews
	*/
	if(request.zos.isTestServer){
		form.sid=528;
	}else{
		//form.sid=422;
	} 


	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_analytics_view_id<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite"); 

	count=0;
	yearLimit=30; // to avoid infinite loop
	startDate=dateformat(dateadd("yyyy", -1, dateformat(now(), "yyyy-mm")&"-01"), "yyyy-mm-dd"); 
	endDate=dateformat(now(), "yyyy-mm-dd"); 
 	for(row in qSite){
		tempStartDate=startDate;
		tempEndDate=endDate; 

 		tempYearLimit=yearLimit; 
 		// uncomment to force import of all time again
 		//row.site_google_analytics_overview_last_import_datetime="";
 		if(row.site_google_analytics_overview_last_import_datetime NEQ ""){
 			tempYearLimit=1; // only pull current year if we already pulled the past.
 		} 
 		for(g=1;g<=tempYearLimit;g++){
			if(structkeyexists(application, 'googleAnalyticsOverviewCancel')){
				application.googleAnalyticsOverviewStatus="";
				structdelete(application, 'googleAnalyticsOverviewCancel');
				echo('Cancelled');
				abort;
			} 
			application.googleAnalyticsOverviewStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
	 		count++;
			js={
			  "reportRequests":
			  [
			    {
					"viewId": row.site_google_analytics_view_id,
					"dateRanges": [{"startDate": dateFormat(tempStartDate, "yyyy-mm-dd"), "endDate": dateFormat(tempEndDate, "yyyy-mm-dd")}],
			      	"dimensions": [{"name": "ga:nthMonth"}],
		      		"metrics": [ 
		      			// only 10 metrics are allowed in single call 
			      		{"expression": "ga:users"},
		      			{"expression": "ga:sessions"},
						{"expression": "ga:visitors"},
						//{"expression": "ga:newVisits"},
						//{"expression": "ga:percentNewVisits"},
						{"expression": "ga:visits"},
						{"expression": "ga:bounces"},
						{"expression": "ga:pageviews"},
						{"expression": "ga:visitBounceRate"},
						{"expression": "ga:timeOnSite"},
						{"expression": "ga:avgTimeOnSite"}
					],
					"orderBys":[
					{
						"fieldName":"ga:nthMonth",
						"orderType":"VALUE",
						"sortOrder":"ASCENDING"
					}],
					"pageToken": "0",
					"pageSize": "10000"
			    }
			  ]
			}; 
			ds={};
			ds.js=js;
			ds.site_short_domain=row.site_short_domain;
			ds.site_id=row.site_id;
			ds.startDate=tempStartDate;
			ds.ga_month_type=1; 
			result=processGASummary(ds);
			if(result EQ false){
				echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			}
			echo('processed google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
			tempStartDate=dateformat(dateadd("yyyy", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("yyyy", -1, tempEndDate), "yyyy-mm-dd"); 
			sleep(1000); // sleep to avoid hitting google's api limit
			if(dateformat(tempStartDate, "yyyymmdd") < 20050101){
				echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			} 
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_analytics_overview_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate"); 
	}

	application.googleAnalyticsOverviewStatus="";
	echo('done: #count#');
	abort;
	</cfscript> 
</cffunction>

<cffunction name="organic" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	init();
	db=request.zos.queryObject;
	/* 
	organic search:
	dimensions=ga:source
	metrics=ga:pageviews,ga:sessionDuration,ga:exits
	filters=ga:medium==organic
	sort=-ga:pageviews
	*/ 
	if(request.zos.isTestServer){
		form.sid=528;
	}else{
		//form.sid=422;
	} 

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_analytics_view_id<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	} 
	qSite=db.execute("qSite");  
	startDate=dateformat(dateadd("m", -1, dateformat(now(), "yyyy-mm")&"-01"), "yyyy-mm-dd"); 
	endDate=dateformat(dateadd("d", -1, dateformat(now(), "yyyy-mm")&"-01"), "yyyy-mm-dd");
 
 	count=0;
 	monthSinceGALaunch=datediff("m", "2005-01-01", now());  
 
 	for(row in qSite){
		tempStartDate=startDate;
		tempEndDate=endDate;   
 		// uncomment to force import of all time again
 		//row.site_google_analytics_organic_last_import_datetime="";
		if(row.site_google_analytics_organic_last_import_datetime NEQ "" and not structkeyexists(form, 'reimport')){
			monthSinceGALaunch=2; // only download last 2 months of data
		} 
 		// one month at a time in reverse until nothing is returned?
 		for(g=1;g<=monthSinceGALaunch;g++){   
			if(structkeyexists(application, 'googleAnalyticsOrganicCancel')){
				application.googleAnalyticsOrganicStatus="";
				structdelete(application, 'googleAnalyticsOrganicCancel');
				echo('Cancelled');
				abort;
			} 
			application.googleAnalyticsOrganicStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
 
 			//tempStartDate='2017-01-01';
 			//tempEndDate='2017-01-31';
 			//echo('start:'&tempStartDate&' to '&tempEndDate&'<br>');
 			count++; 
			js={
			  "reportRequests":
			  [
			    {
					"viewId": row.site_google_analytics_view_id,
					"dateRanges": [{"startDate": dateFormat(tempStartDate, "yyyy-mm-dd"), "endDate": dateFormat(tempEndDate, "yyyy-mm-dd")}],
			      	"dimensions": [
			      		{"name": "ga:medium"},
			      		//{"name": "ga:nthMonth"}
			      	],
		      		"metrics": [ 
		      			// only 10 metrics are allowed in single call 
			      		{"expression": "ga:users"},
		      			{"expression": "ga:sessions"},
						{"expression": "ga:visitors"},
						//{"expression": "ga:newVisits"},
						//{"expression": "ga:percentNewVisits"},
						{"expression": "ga:visits"},
						{"expression": "ga:bounces"},
						{"expression": "ga:pageviews"},
						{"expression": "ga:visitBounceRate"},
						{"expression": "ga:timeOnSite"},
						{"expression": "ga:avgTimeOnSite"}
					],
					"dimensionFilterClauses": [
			        {
					  //"operator": "AND", // need this, because default with multiple filters is "OR"
			          "filters": [
						{
							"dimensionName":"ga:medium",
							"operator":"EXACT",
							"expressions":["organic"]
						}
						/*,
						{
							"dimensionName":"ga:source",
							"operator":"EXACT",
							"expressions":["google"]
						}*/
						]
					}
					],
					/*"orderBys":[
					{
						"fieldName":"ga:nthMonth",
						"orderType":"VALUE",
						"sortOrder":"ASCENDING"
					}],*/
					//"pageToken": "0",
					//"pageSize": 10000
			    }
			  ]
			};  
			ds={};
			ds.js=js;
			ds.startDate=tempStartDate;
			ds.ga_month_type=2;
			ds.site_id=row.site_id;
			ds.site_short_domain=row.site_short_domain;   
			result=processGASummary(ds);  

			if(result EQ false){
				echo('stopped google analytics organic for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			}
			echo('processed google analytics organic for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>'); 
			tempStartDate=dateformat(dateadd("m", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("d", -1, dateadd("m", 1, tempStartDate) ), "yyyy-mm-dd");
			if(dateformat(tempStartDate, "yyyymmdd") < 20050101){
				echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			} 
			sleep(1000); // sleep to avoid hitting google's api limit
		} 
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_analytics_organic_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate"); 
	} 
	application.googleAnalyticsOrganicStatus=""; 
	echo('done');
	abort;
	</cfscript> 
</cffunction>


<cffunction name="keyword" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	init();
	db=request.zos.queryObject;
	// TODO: need unique manually created exclude list for each client to filter out their own brand 
	/*
	dimensions=ga:source,ga:medium
	metrics=ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits
	sort=-ga:sessions
	*/    
	/*
	Limits: 5 queries per second  200 queries per minute 
	documentation: https://developers.google.com/webmaster-tools/v3/searchanalytics/query#dimensionFilterGroups.filters.dimension
	*/

	// force ricerose for now: 
	if(request.zos.isTestServer){
		form.sid=528;
	}else{
		//form.sid=422;
	} 

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_analytics_view_id<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite");    
	// site_google_search_console_last_import_datetime
	startDate=dateformat(now(), "yyyy-mm-")&"01"; 
	endDate=dateformat(dateadd("d", -1, dateadd("m", 1, startDate) ), "yyyy-mm-dd");
 	count=0;
 	monthSinceGALaunch=datediff("m", "2005-01-01", now());
 	for(row in qSite){
		tempStartDate=startDate;
		tempEndDate=endDate; 
		// uncomment to force downloading everything again
		// row.site_google_analytics_keyword_last_import_datetime="";
		if(row.site_google_analytics_keyword_last_import_datetime NEQ "" and not structkeyexists(form, 'reimport')){
			monthSinceGALaunch=2; // only download last 2 months of data
		}
 		// one month at a time in reverse until nothing is returned?
 		for(g=1;g<=monthSinceGALaunch;g++){  
			if(structkeyexists(application, 'googleAnalyticsKeywordCancel')){
				application.googleAnalyticsKeywordStatus="";
				structdelete(application, 'googleAnalyticsKeywordCancel');
				echo('Cancelled');
				abort;
			}
			application.googleAnalyticsKeywordStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
			js={
			  "reportRequests":
			  [
			    {
			      "viewId": row.site_google_analytics_view_id,
			      "dateRanges": [{"startDate": tempStartDate, "endDate": tempEndDate}],
			      "dimensions": [{"name": "ga:keyword"}],
			      "metrics": [
			      	// limited to 10 metrics
			      	{"expression": "ga:users"}, // unique user
		  			{"expression": "ga:sessions"},
					{"expression": "ga:visitors"}, 
					{"expression": "ga:visits"},
					{"expression": "ga:bounces"},
					{"expression": "ga:pageviews"},
					{"expression": "ga:visitBounceRate"},
					{"expression": "ga:timeOnSite"},
					{"expression": "ga:avgTimeOnSite"}]
			    }
			  ]
			};   

			js=doAPICall(js); 

			nextSite=false;
			if(not structkeyexists(js, 'reports')){
				echo('Stopped google analytics organic keywords for #row.site_short_domain# at #tempStartDate# to #tempEndDate#..<br>');
				break;
			}
			for(i=1;i<=arraylen(js.reports);i++){
				rs=js.reports[i];
				if(not structkeyexists(rs.data, 'rows')){
					echo('Stopped google analytics organic keywords for #row.site_short_domain# at #tempStartDate# to #tempEndDate#.<br>');
					nextSite=true;
					break;
				}
				for(n=1;n<=arraylen(rs.data.rows);n++){
					ds=rs.data.rows[n];
					vs=ds.metrics[1].values; 
					ts={};
					ts.ga_month_keyword_keyword=ds.dimensions[1];
					ts.ga_month_keyword_type=1; // 1 is google analytics, 2 is webmaster tool search analytics
					ts.ga_month_keyword_visits=vs[4];
					ts.ga_month_keyword_impressions=0;
					ts.ga_month_keyword_ctr=0;
					ts.ga_month_keyword_position=0;
					ts.ga_month_keyword_bounces=vs[5]     
					ts.ga_month_keyword_pageviews=vs[6];
					ts.ga_month_keyword_visit_bounce_rate=vs[7];
					ts.ga_month_keyword_time_on_site=vs[8];
					ts.ga_month_keyword_average_time_on_site=vs[9];
					ts.ga_month_keyword_date=tempStartDate;
					ts.ga_month_keyword_updated_datetime=request.zos.mysqlnow;
					ts.ga_month_keyword_deleted=0;
					ts.site_id=row.site_id;
 
			 
					// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
					db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
					WHERE site_id = #db.param(ts.site_id)# and 
					ga_month_keyword_deleted=#db.param(0)# and 
					ga_month_keyword_date=#db.param(dateformat(tempStartDate, "yyyy-mm-dd"))# and 
					ga_month_keyword_keyword=#db.param(ts.ga_month_keyword_keyword)# and
					ga_month_keyword_type=#db.param(ts.ga_month_keyword_type)#";
					qRank=db.execute("qRank"); 
					/*writedump(qRank);
					writedump(ts);
					abort;*/
					// only import new records
					ts2={
						table:"ga_month_keyword",
						datasource:request.zos.zcoreDatasource,
						struct:ts 
					}; 
					if(qRank.recordcount EQ 0){
						ga_month_keyword_id=application.zcore.functions.zInsert(ts2); 
					}else{
						ts2.struct.ga_month_keyword_id=qRank.ga_month_keyword_id;
						application.zcore.functions.zUpdate(ts2);
					}   
				}
			}
			if(nextSite){
				break;
			} 
			sleep(1000); // sleep to avoid hitting google's api limit
			echo('Processed google analytics organic keywords for #row.site_short_domain# | #tempStartDate# to #tempEndDate#<br>'); 
			tempStartDate=dateformat(dateadd("m", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("d", -1, dateadd("m", 1, tempStartDate) ), "yyyy-mm-dd");
		} 
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_analytics_keyword_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate");
	}

	application.googleAnalyticsKeywordStatus="";
	echo('done'); 
	abort;
	</cfscript>
</cffunction>

<cffunction name="goal" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	init();
	throw("not implemented - the api call works, but i don't think we need this one");
	/*
dimensions=ga:source,ga:medium
metrics=ga:sessions,ga:goal1Starts,ga:goal1Completions,ga:goal1Value,ga:goalStartsAll,ga:goalCompletionsAll,ga:goalValueAll
sort=-ga:goalCompletionsAll
	*/
	startDate="2014-11-01";
	endDate="2014-11-30";
	js={
	  "reportRequests":
	  [
	    {
	      "viewId": request.zos.googleAnalyticsConfig.debugViewId,
	      "dateRanges": [{"startDate": startDate, "endDate": endDate}],
	      "dimensions": [
	      	{"name": "ga:source"},
	      	{"name": "ga:medium"}
	      ],
	      "metrics": [
	      	// limited to 10 metrics 
  			{"expression": "ga:sessions"},
			{"expression": "ga:goal1Completions"}, 
			{"expression": "ga:goal1Value"},
			{"expression": "ga:goalStartsAll"},
			{"expression": "ga:goalCompletionsAll"},
			{"expression": "ga:goalValueAll"}
		  ],
		"pageToken": "0",
		"pageSize": "10000"
	    }
	  ]
	}; 
	js=doAPICall(js);  
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n]; 
		}
	} 
	</cfscript>
</cffunction>


<!--- 

	public function getVisitsByDate($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:date',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getAudienceStatistics($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visitors,ga:newVisits,ga:percentNewVisits,ga:visits,ga:bounces,ga:pageviews,ga:visitBounceRate,ga:timeOnSite,ga:avgTimeOnSite',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByCountries($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:country',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByCities($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:city',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByLanguages($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:language',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsBySystemBrowsers($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:browser',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsBySystemOs($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:operatingSystem',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);


	}

	public function getVisitsBySystemResolutions($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:screenResolution',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByMobileOs($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:operatingSystem',
			'sort' => '-ga:visits',
			'segment' => 'gaid::-11',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByMobileResolutions($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:screenResolution',
			'sort' => '-ga:visits',
			'segment' => 'gaid::-11',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	/*
	 * CONTENT
	 *
	 */

	public function getPageviewsByDate($params=array()) {

		$defaults = array(
			'metrics' => 'ga:pageviews',
			'dimensions' => 'ga:date',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getContentStatistics($params=array()) {

		$defaults = array(
			'metrics' => 'ga:pageviews,ga:uniquePageviews',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getContentTopPages($params=array()) {

		$defaults = array(
			'metrics' => 'ga:pageviews',
			'dimensions' => 'ga:pagePath',
			'sort' => '-ga:pageviews',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	/*
	 * TRAFFIC SOURCES
	 *
	 */

	public function getTrafficSources($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:medium',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getKeywords($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:keyword',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getReferralTraffic($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:source',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}
 --->
</cfoutput>
</cfcomponent>
