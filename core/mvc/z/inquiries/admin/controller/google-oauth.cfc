<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
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
	<p><a href="/z/inquiries/admin/google-oauth/revokeToken">Revoke Auth Token</a></p>
	<p><a href="#overviewLink#" target="_blank">Google Analytics Main Overview</a></p>
	<p><a href="#organicLink#" target="_blank">Google Analytics Organic Search</a></p>
	<p><a href="#keywordLink#" target="_blank">Google Analytics Keywords</a></p>
	<p><a href="#searchConsoleLink#" target="_blank">Google Webmaster Search Console Keywords</a></p>
	
	<p><a href="#goalLink#" target="_blank">Goals</a></p> 
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

<!--- <cffunction name="overview2" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>  
	js={
	  "reportRequests":
	  [
	    {
	      "viewId": request.zos.googleAnalyticsConfig.debugViewId,
	      "dateRanges": [{"startDate": "2014-11-01", "endDate": "2014-11-30"}],
	      "metrics": [{"expression": "ga:users"}]
	    }
	  ]
	}; 
 	writedump(application.googleAnalyticsAccessToken); 
	td={
	  "start-date": "2016-11-24",
	  "end-date": "2016-12-24",
	  "metrics": "ga:visits",
	  "access_token": application.googleAnalyticsAccessToken.access_token, 
	  "ids": "ga:14001862",
	  "dimensions": "ga:date"
	};
	link="https://www.googleapis.com/analytics/v3/data/ga"; 
	http url="#link#" method="post" timeout="10"{
		//httpparam type="header" name="Authorization" value="#application.googleAnalyticsAccessToken.token_type# #application.googleAnalyticsAccessToken.access_token#";
		httpparam type="header" name="Content-type" value="application/json";
		httpparam type="body" value="#serializeJson(js)#"; 
	}  
	// https://analyticsreporting.googleapis.com/v4/reports:batchGet?key= 
	writedump(cfhttp);
	abort; 
	</cfscript> 
</cffunction>  --->


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

<cffunction name="searchConsole" localmode="modern" access="remote">
	<cfscript> 
	/*
	Limits:
	5 queries per second  200 queries per minute
 
 documentation: https://developers.google.com/webmaster-tools/v3/searchanalytics/query#dimensionFilterGroups.filters.dimension


response is: 
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
	tempLink="http://www.whitealuminum.com/";
	link="https://www.googleapis.com/webmasters/v3/sites/#urlencodedformat(tempLink)#/searchAnalytics/query?access_token=#application.googleAnalyticsAccessToken.access_token#&alt=json&fields=rows";
	jsonStruct={
		"startDate": "2016-10-01",
		"endDate": "2016-10-30",
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


 
	writedump(js);
	abort;
	arrData=[];
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n];
			values=ds.metrics[1].values;
			ts={};
			ts.month=ds.dimensions[1];
			for(g=1;g<=arraylen(values);g++){
				ts[arrLabel[g]]=values[g];
			}
			arrayAppend(arrData, ts);
		}
	}
	//writedump(arrKeyword); 

	for(ks in arrData){
		tempDate=dateAdd("m", ks.month-1, startDate);
		echo(dateformat(tempDate, "mmm yyyy")&" : "&ks.sessions&" : "&ks.bounces&"<br>");
	}
	</cfscript>
</cffunction>
 
<cffunction name="overview" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>  
	/*
documented here: https://developers.google.com/analytics/devguides/reporting/core/v3/common-queries

dimensions=ga:source,ga:medium
metrics=ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits
sort=-ga:sessions

or

organic search:
dimensions=ga:source
metrics=ga:pageviews,ga:sessionDuration,ga:exits
filters=ga:medium==organic
sort=-ga:pageviews

paid search:
dimensions=ga:source
metrics=ga:pageviews,ga:sessionDuration,ga:exits
filters=ga:medium==cpa,ga:medium==cpc,ga:medium==cpm,ga:medium==cpp,ga:medium==cpv,ga:medium==ppc
sort=-ga:pageviews
	*/
	startDate="2013-11-01";
	endDate=dateAdd("yyyy", 1, startDate);
	js={
	  "reportRequests":
	  [
	    {
			"viewId": request.zos.googleAnalyticsConfig.debugViewId,
			"dateRanges": [{"startDate": dateFormat(startDate, "yyyy-mm-dd"), "endDate": dateFormat(endDate, "yyyy-mm-dd")}],
	      	"dimensions": [{"name": "ga:month"}],
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
			] 
	 
	    }
	  ]
	}; 
	arrLabel=[
		"Sessions",
		"Visitors",
		"New Visits",
		"Percent New Visits",
		"Visits",
		"Bounces",
		"Pageviews",
		"Visit Bounce Rate",
		"Time On Site",
		"Average Time On Site"
	];
	js=doAPICall(js);
	//writedump(js);
	//abort;
	arrData=[];
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n];
			values=ds.metrics[1].values;
			ts={};
			ts.month=ds.dimensions[1];
			for(g=1;g<=arraylen(values);g++){
				ts[arrLabel[g]]=values[g];
			}
			arrayAppend(arrData, ts);
		}
	}
	//writedump(arrKeyword); 

	for(ks in arrData){
		tempDate=dateAdd("m", ks.month-1, startDate);
		echo(dateformat(tempDate, "mmm yyyy")&" : "&ks.sessions&" : "&ks.bounces&"<br>");
	}
  
	/*
 	link="https://analyticsreporting.googleapis.com/v4/reports:batchGet"; 
	http url="#link#" method="post" timeout="10"{
		httpparam type="header" name="Authorization" value="#application.googleAnalyticsAccessToken.token_type# #application.googleAnalyticsAccessToken.access_token#";
		httpparam type="header" name="Content-type" value="application/json";
		httpparam type="body" value="#serializeJson(js)#"; 
	}  
	*/  
	</cfscript> 
</cffunction>


<cffunction name="organic" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>   
	startDate="2013-11-01";
	endDate=dateAdd("yyyy", 1, startDate);
	js={
	  "reportRequests":
	  [
	    {
			"viewId": request.zos.googleAnalyticsConfig.debugViewId,
			"dateRanges": [{"startDate": dateFormat(startDate, "yyyy-mm-dd"), "endDate": dateFormat(endDate, "yyyy-mm-dd")}],
	      	"dimensions": [
	      		{"name": "ga:source"},
	      		{"name": "ga:month"}
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
			  "operator": "AND", // need this, because default with multiple filters is "OR"
	          "filters": [
				{
					"dimensionName":"ga:medium",
					"operator":"EXACT",
					"expressions":["organic"]
				},
				{
					"dimensionName":"ga:source",
					"operator":"EXACT",
					"expressions":["google"]
				}
				]
			}
			],
			"orderBys":[
			{
				"fieldName":"ga:pageviews",
				"orderType":"VALUE",
				"sortOrder":"DESCENDING"
			}]
	    }
	  ]
	}; 
	arrLabel=[
		"Sessions",
		"Visitors",
		"New Visits",
		"Percent New Visits",
		"Visits",
		"Bounces",
		"Pageviews",
		"Visit Bounce Rate",
		"Time On Site",
		"Average Time On Site"
	];
 /*

 	link="https://analyticsreporting.googleapis.com:443/v4/reports:batchGet?access_token=#application.googleAnalyticsAccessToken.access_token#"; 

	http url="#link#" method="post" timeout="10"{
		//httpparam type="header" name="Host" value="analyticsreporting.googleapis.com";
		//httpparam type="header" name="Authorization" value="#application.googleAnalyticsAccessToken.token_type# #application.googleAnalyticsAccessToken.access_token#";
		httpparam type="header" name="Content-type" value="application/json";
		httpparam type="body" value="#serializeJson(js)#"; 
	}  
	writedump(cfhttp);abort;*/
	js=doAPICall(js);
	writedump(js);
	abort;
	// TODO: need to handle the dimensions better - i.e. only get google, etc
	arrData=[];
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n];
			values=ds.metrics[1].values;
			ts={};
			ts.month=ds.dimensions[1];
			for(g=1;g<=arraylen(values);g++){
				ts[arrLabel[g]]=values[g];
			}
			arrayAppend(arrData, ts);
		}
	}
	//writedump(arrKeyword); 

	for(ks in arrData){
		tempDate=dateAdd("m", ks.month-1, startDate);
		echo(dateformat(tempDate, "mmm yyyy")&" : "&ks.sessions&" : "&ks.bounces&"<br>");
	}
  
	/*
 	link="https://analyticsreporting.googleapis.com/v4/reports:batchGet"; 
	http url="#link#" method="post" timeout="10"{
		httpparam type="header" name="Authorization" value="#application.googleAnalyticsAccessToken.token_type# #application.googleAnalyticsAccessToken.access_token#";
		httpparam type="header" name="Content-type" value="application/json";
		httpparam type="body" value="#serializeJson(js)#"; 
	}  
	*/  
	</cfscript> 
</cffunction>


<cffunction name="keyword" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	// TODO: need unique manually created exclude list for each client to filter out their own brand 

	//startDate=request.zos.googleAnalyticsConfig.startDate;
	//endDate=dateAdd("d", -1, dateAdd("m", 1, request.zos.googleAnalyticsConfig.startDate));
/*
dimensions=ga:source,ga:medium
metrics=ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits
sort=-ga:sessions
*/
	startDate="2014-11-01";
	endDate="2014-11-30";
	js={
	  "reportRequests":
	  [
	    {
	      "viewId": request.zos.googleAnalyticsConfig.debugViewId,
	      "dateRanges": [{"startDate": startDate, "endDate": endDate}],
	      "dimensions": [{"name": "ga:keyword"}],
	      "metrics": [
	      	// limited to 10 metrics
	      	{"expression": "ga:users"}, // unique user
  			{"expression": "ga:sessions"},
			{"expression": "ga:visitors"},
			//{"expression": "ga:newVisits"},
			//{"expression": "ga:percentNewVisits"},
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
	writedump(js);abort;
	arrKeyword=[];
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n];
			ts={
				keyword:ds.dimensions[1],
				visits:ds.metrics[1]
			};
			arrayAppend(arrKeyword, ts);
		}
	}
	//writedump(arrKeyword); 
	for(ks in arrKeyword){
		echo(ks.keyword&":"&ks.visits&"<br>");
	}
	</cfscript>
</cffunction>

<cffunction name="goal" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 

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
		  ]
	    }
	  ]
	}; 
	js=doAPICall(js); 
	writedump(js);abort;
	arrKeyword=[];
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n];
			ts={
				keyword:ds.dimensions[1],
				visits:ds.metrics[1]
			};
			arrayAppend(arrKeyword, ts);
		}
	}
	//writedump(arrKeyword); 
	for(ks in arrKeyword){
		echo(ks.keyword&":"&ks.visits&"<br>");
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
