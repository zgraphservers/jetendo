<cfcomponent>
<cfoutput>
<!--- 
https://gist.github.com/cosenary/7267139
https://github.com/cosenary/Instagram-PHP-API/blob/master/README.md

getUserFollower() has scope and api call stuff burried somewhere in this project:

code in this file:
https://github.com/cosenary/Instagram-PHP-API/blob/master/src/Instagram.php
 
you can add security here: https://www.instagram.com/developer/secure-api-requests/

when auth expires, it will return this for api responses : error_type=OAuthAccessTokenError
there is no expiration for auth token otherwise.

you can retrieve user ids like this: https://www.instagram.com/THE_INSTAGRAM_USERNAME/?__a=1

the new account is in sandbox mode - we'd have to expose it for approval it seems:
	https://www.instagram.com/developer/sandbox/
	has a lot of extra limits that will prevent deep crawling and high # of requests

	we comply with their use cases since we are just grabbing analytics: "Don't use follower information for anything other than analytics without our prior permission. For example, don't display these relationships in your app."

 
The API limit is 5000 requests per hour per access_token or client_id. Every user has their own access_token, so as long as the requests from the third party application uses each individual access token, they will be hard pressed to exceed 5000 per user per hour.

Criteria for getting out of sandbox mode:
https://www.instagram.com/developer/review/
	need video screencast
	need working app
	for showing followed_by count, we need minimum scope of basic public_content
	in developer url: Go to manage clients -> manage -> permissions to submit app review


Need these new columns
ALTER TABLE `jetendo`.`site`   
  ADD COLUMN `site_instagram_user_id_list` VARCHAR(255) NOT NULL AFTER `site_enable_lead_reminder_office_manager_cc`,
  ADD COLUMN `site_instagram_last_import_datetime` DATETIME NOT NULL AFTER `site_instagram_user_id_list`,
  ADD COLUMN `site_instagram_access_token_list` TEXT NOT NULL AFTER `site_instagram_last_import_datetime`;


  need to associate token to each user id using json or something with longtext.


*/
 --->

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	setting requesttimeout="10000"; 

	// is it possible to return to a private url?
 
	variables.returnLink=request.zos.globals.domain&"/z/inquiries/admin/instagram-oauth/return"; 
	</cfscript>
</cffunction> 

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	application.zcore.functions.zStatusHandler(request.zsid);
	scope="basic";//follower_list basic follower_list likes comments relationships";
 
	link="https://api.instagram.com/oauth/authorize"; 

	firstAuthLink="#link#?response_type=code&client_id=#request.zos.instagramConfig.clientId#&redirect_uri=#urlencodedformat(variables.returnLink)#&scope=#urlencodedformat(scope)#";
   
	</cfscript>
	<!--- will i need to authenticate with each client separately? --->
	<p><a href="#firstAuthLink#">Authenticate with Instagram</a></p> 
	<p>Link: #firstAuthLink#</p>
</cffunction>

 

<cffunction name="return" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	form.code=application.zcore.functions.zso(form, 'code'); 
	link="https://api.instagram.com/oauth/access_token";
 
	http url="#link#" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="authorization_code";
		httpparam type="formfield" name="code" value="#form.code#";
		httpparam type="formfield" name="redirect_uri" value="#variables.returnLink#";
		httpparam type="formfield" name="client_id" value="#request.zos.instagramConfig.clientId#";
		httpparam type="formfield" name="client_secret" value="#request.zos.instagramConfig.clientSecret#"; 
	}


	/*
	response json is:
	{
		"access_token": "...", 
		"user": {
			"id": "id", 
			"username": "username", 
			"profile_picture": "url to picture", 
			"full_name": "User Name", 
			"bio": "", 
			"website": ""
		}
	}
	*/ 

	// because there is no central account, i'd have to cache the access tokens in the site table, and then read it back out to do all future api requests automatically.
	if(not isJson(cfhttp.filecontent)){
		writedump(cfhttp.filecontent);
		return;
	}
	// 401 is expired token
	// 403 is no access to "view"

	js=deserializeJson(cfhttp.filecontent);
	/*writedump(form);
	writedump(cfhttp); 
	writedump(js);
	abort;*/
	if(structkeyexists(js, 'error')){
		writedump(js.error);
		return;
	}	

	// we can't store this in application scope anymore, since each login is more of a permanent login and we need to rewrite to use db field instead.
	if(structkeyexists(js, 'access_token')){
		application.instagramAccessToken=js;
		application.instagramAccessToken.loginDatetime=now();
		//application.instagramAccessToken.expiresDatetime=dateadd("s", js.expires_in, application.instagramAccessToken.loginDatetime);
		application.zcore.functions.zRedirect("/z/inquiries/admin/instagram-oauth/reportIndex");
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
	if(structkeyexists(form, 'instagramUserFollowCancel')){
		application.instagramUserFollowCancel=1; 
	} 
	if(not structkeyexists(application, 'instagramAccessToken')){
		application.zcore.status.setStatus(request.zsid, "Invalid access token", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/instagram-oauth/index?zsid=#request.zsid#");
	}
	echo("Access Token:<br>");
	writedump(application.instagramAccessToken);

	userFollowLink="/z/inquiries/admin/instagram-oauth/userFollows"; 
	//refreshLink="/z/inquiries/admin/instagram-oauth/refreshToken"; 
	</cfscript>
	<p>You can add sid=SITEID&amp;reimport=1 to pull the data again for a specific site.</p>
 
	<!--- <p><a href="/z/inquiries/admin/instagram-oauth/revokeToken">Revoke Auth Token</a></p> --->
	<p><a href="/z/inquiries/admin/instagram-oauth/index">Authenticate Again</a> 
	<p><a href="#userFollowLink#" target="_blank">Instagram User Follows</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'instagramUserFollowStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/instagram-oauth/reportIndex?instagramUserFollowCancel=1">Cancel</a>)
		</cfif></p> 
	<!--- <p><a href="#goalLink#" target="_blank">instagram Goals</a></p>  --->
	<!--- <p><a href="#refreshLink#">Refresh Token</a></p> --->
</cffunction>
<!--- 
<cffunction name="revokeToken" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	http url="https://accounts.google.com/o/oauth2/revoke?token=#application.instagramAccessToken.access_token#" method="get" timeout="10"{ 
	}

	//writedump(cfhttp);

	application.zcore.functions.zRedirect("/z/inquiries/admin/instagram-oauth/index");
	abort;
	</cfscript>
</cffunction> --->
<!--- 
<cffunction name="refreshToken" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	form.code=application.zcore.functions.zso(form, 'code');
	if(not structkeyexists(application, 'instagramAccessToken')){
		application.zcore.status.setStatus(request.zsid, "You must authenticate with instagram first.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/instagram-oauth/index?zsid=#request.zsid#");
	}
	http url="https://api.instagram.com/oauth/access_token" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="refresh_token";
		httpparam type="formfield" name="refresh_token" value="#application.instagramAccessToken.refresh_token#"; 
		httpparam type="formfield" name="client_id" value="#request.zos.instagramConfig.clientId#";
		httpparam type="formfield" name="client_secret" value="#request.zos.instagramConfig.clientSecret#"; 
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
		application.instagramAccessToken.loginDatetime=now();
		application.instagramAccessToken.expiresDatetime=dateadd("s", js.expires_in, application.instagramAccessToken.loginDatetime);

		// TODO: don't need to redirect when this is done
		application.zcore.functions.zRedirect("/z/inquiries/admin/instagram-oauth/reportIndex");
	}else{
		echo('Unknown response:');
		writedump(js);
		abort;
	}
	</cfscript>
</cffunction>
  --->
 

<cffunction name="doRESTAPICall" localmode="modern" access="public">
	<cfargument name="requestURL" type="string" required="yes">
	<cfargument name="disableAccessToken" type="boolean" required="yes">
	<cfscript> 

	if(arguments.disableAccessToken){
		link=arguments.requestURL;
	}else{
		link='#arguments.requestURL#?access_token=#application.instagramAccessToken.access_token#'
	}
	echo(link&"<br>");  
	rs=application.zcore.functions.zDownloadLink(link, 20);   
    if(rs.cfhttp.statusCode EQ "200 OK"){
    	jsonString=rs.cfhttp.filecontent;
		if(jsonString EQ false or not isJson(jsonString)){
			throw(jsonString);
		}
	    js=deserializeJson(rs.cfhttp.filecontent); 
		if(structkeyexists(js, 'meta') and structkeyexists(js.meta, 'error_type')){ 
			savecontent variable="out"{
				echo('API Call Failure.  Input:');
				writedump(link);
				echo('Response:');
				writedump(js);
			}
			throw(out);
		} 
	}else{
		savecontent variable="out"{
			echo('API Call Failure.  Input:');
			writedump(link);
			echo('Response:');
			writedump(rs);
		}
		throw(out);
	} 
 	writedump(rs);
	return js;
	</cfscript>
</cffunction>


<cffunction name="publicUserFollows" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>  
	init();
	db=request.zos.queryObject; 
	if(request.zos.isTestServer){
		form.sid=528;
	}else{
		//form.sid=422;
	} 
 	
 	// each authentication gives us data for only one user.
    userId=application.instagramAccessToken.user.id;// set to the user id we want the follower count for.
    userId="self";
    js=doRESTAPICall("https://www.instagram.com/jeaneperezzgraph/?__a=1", true); ///follows

    /* response is: 
    {"user": 
    {
	    "biography": null, 
	    "blocked_by_viewer": false, 
	    "country_block": false, 
	    "external_url": null, 
	    "external_url_linkshimmed": null, 
	    "followed_by": {"count": 1}, 
	    "followed_by_viewer": false, 
	    "follows": {"count": 3}, 
	    "follows_viewer": false, 
	    "full_name": "", 
	    "has_blocked_viewer": false, 
	    "has_requested_viewer": false, 
	    "id": "", 
	    "is_private": false, 
	    "is_verified": false, 
	    "profile_pic_url": "url", 
	    "profile_pic_url_hd": "", 
	    "requested_by_viewer": false, 
	    "username": "", 
	    "connected_fb_page": null, 
	    "media": {
	    	"nodes": [], 
	    	"count": 0, 
	    	"page_info": {
	    		"has_next_page": false, 
	    		"end_cursor": null
	    	}
	    }
    }, 
    "logging_page_id": ""}
    */  
    followCount=js.user.followed_by.count;
    echo(followCount);
    abort; 
	application.instagramUserFollowStatus="";
	echo('done: #count#');

	abort;
	</cfscript> 
</cffunction>
 
<cffunction name="userFollows" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>  
	init();
	db=request.zos.queryObject; 
	if(request.zos.isTestServer){
		form.sid=528;
	}else{
		//form.sid=422;
	} 
 	
 	// each authentication gives us data for only one user.
    userId=application.instagramAccessToken.user.id;// set to the user id we want the follower count for.
    userId="self";
    js=doRESTAPICall("https://api.instagram.com/v1/users/#userId#", false); ///follows

    /* response is: 
    {
    	"pagination": {}, 
    	"data": [
    		// each record returns is the list of followers?
			{
				"id": "", 
				"username": "", 
				"full_name": "", 
				"profile_picture": "url", 
				"counts": {
					"media": 0, 
					"follows": 4, 
					"followed_by": 2
				}
			}
    	], 
    	"meta": {
    		"code": 200
    	}
    }
    */ 
    followCount=js.data.counts.followed_by;
    echo(followCount);
    abort;
 
 	/*
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
			if(structkeyexists(application, 'instagramUserFollowCancel')){
				application.instagramUserFollowStatus="";
				structdelete(application, 'instagramUserFollowCancel');
				echo('Cancelled');
				abort;
			} 
			application.instagramUserFollowStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
	 		count++;
			//	"dateRanges": [{"startDate": dateFormat(tempStartDate, "yyyy-mm-dd"), "endDate": dateFormat(tempEndDate, "yyyy-mm-dd")}],
			// user id 
 
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
			// only import new records
			ts2={
				table:"ga_month",
				datasource:request.zos.zcoreDatasource,
				struct:ts 
			};   
			ga_month_id=application.zcore.functions.zInsert(ts2);  

			ds={}; 
			ds.site_short_domain=row.site_short_domain;
			ds.site_id=row.site_id;
			ds.startDate=tempStartDate;
			ds.ga_month_type=1; 
			result=processGASummary(ds);
			if(result EQ false){
				echo('stopped instagram user follows for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			}
			echo('processed instagram user follows for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
			tempStartDate=dateformat(dateadd("yyyy", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("yyyy", -1, tempEndDate), "yyyy-mm-dd"); 
			sleep(1000); // sleep to avoid hitting google's api limit
			if(dateformat(tempStartDate, "yyyymmdd") < 20050101){
				echo('stopped instagram user follows for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
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
	*/	
	application.instagramUserFollowStatus="";
	echo('done: #count#');

	abort;
	</cfscript> 
</cffunction>

</cfoutput>
</cfcomponent>
