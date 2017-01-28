<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	request.facebook = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.facebook-api' );
	facebookConfig = request.zos.facebookConfig;
	request.facebook.init( facebookConfig );
	request.debug=true;
	if(request.debug){
		facebookDebug=createObject("component", "zcorerootmapping.facebook-debug");
		request.debugRS=facebookDebug.getDebugResponses();
	}
	</cfscript>
</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	setting requesttimeout="10000";
	init();

	// PAGE
	pageId = request.zos.facebookConfig.debugPageId;
	videoId = request.zos.facebookConfig.debugVideoId; // has views, reactions, shares
	photoId = request.zos.facebookConfig.debugPhotoId; // has comments & likes
	linkId  = request.zos.facebookConfig.debugLinkId; // has like
	postId  = request.zos.facebookConfig.debugPostId; // has likes
 
	startDate="2016-12-01"; 
	endDate="2017-01-01"; 
	startDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), startDate);
	endDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), endDate); 
	/*
	addBatchRequest // adds to queue
	sendBatchRequests // executes api calls and returns array of response object
	sendRequest // does 1 api call and returns response object
	getAllPages
	getAllPostsByPageId
	getFeedByPageId

	// not needed
	getResponse // just does deserialize on filecontent
	getPageLikes // not needed
	getPageEngagements// not needed
	getPageReach // not needed 
	getPageImpressions // not needed
	*/ 

	// get list of all accounts
	ts={
		method:'GET',
		link:'/me/accounts',
		throwOnError:true
	}
	if(request.debug){
		rs=request.debugRS.accounts;
	}else{
		rs=request.facebook.sendRequest(ts);
	}
	//echo(serializeJson(rs)); abort;
 
	ageLookup={
		"F.13-17":"Female 13-17",
		"F.18-24":"Female 18-24",
		"F.25-34":"Female 25-34",
		"F.35-44":"Female 35-44",
		"F.45-54":"Female 45-54",
		"F.55-64":"Female 55-64",
		"F.65+":"Female 65+",
		"F.13-17":"Female 18-24",
		"M.18-24":"Male 18-24",
		"M.25-34":"Male 25-34",
		"M.35-44":"Male 35-44",
		"M.45-54":"Male 45-54",
		"M.55-64":"Male 55-64",
		"M.65+":"Male 65+",
		"U.25-34":"Unspecified 25-34",
		"U.35-44":"Unspecified 35-44",
		"U.45-54":"Unspecified 45-54",
		"U.55-64":"Unspecified 55-64",
		"U.65+":"Unspecified 65+"
	};
 	arrPage=[];
	for(i=1;i<=arraylen(rs.response.data);i++){
		page=rs.response.data[i];
		ps={
			page:page,
			arrPost:[]
		};
		limitCount=300;
		pageOffset=0;

		// grab page fans and age groups separately on the last day of the month only
		ts={
			method:'GET',
			link:'/#page.id#/insights?metric=page_fans,page_fans_gender_age,page_views_total&period=lifetime&since=' & endDateRemote & '&until=' & endDateRemote,
			throwOnError:true
		};
		if(request.debug){
			rs2=request.debugRS.pageInsights;
		}else{
			rs2=request.facebook.sendRequest(ts);
		} 
		//echo(serializeJson(rs2));abort;
		//writedump(rs2);abort;

		pageInfo={
			"pageViewsTotal":0,
			"pageTotalFans":0,
			"pageFanAgeStruct":{},
			"newPagePaidFans":0,
			"newPageUnpaidFans":0,
			"newPageRemoveFanTotal":0,
			"pageViews":0,
		};
		for(i in ageLookup){
			pageInfo.pageFanAgeStruct[ageLookup[i]]=0;
		}
		for(i=1;i<=arraylen(rs2.response.data);i++){
			ds=rs2.response.data[i];
			if(ds.name EQ "page_fans_gender_age"){
				ag=ds.values[arraylen(ds.values)].value;
				for(n in ag){
					if(structkeyexists(ageLookup, n)){
						pageInfo.pageFanAgeStruct[ageLookup[n]]=ag[n];
					}else{
						throw("Invalid facebook age group: #n#");
					}
				}
			}else if(ds.name EQ "page_fans"){
				pageInfo.pageTotalFans=ds.values[arraylen(ds.values)].value;
			}else if(ds.name EQ "page_views_total"){
				pageInfo.pageViewsTotal=ds.values[arraylen(ds.values)].value;
			} 
		}
		//echo(serializeJson(rs2));abort;
		//writedump(rs2);abort;
		//writedump(pageInfo);abort;
		ts={
			method:'GET',
			link:'/#page.id#/insights?metric=page_fan_adds_by_paid_non_paid_unique,page_fan_removes,page_views_total&period=day&since=' & startDateRemote & '&until=' & endDateRemote,
			throwOnError:true
		};
		if(request.debug){
			rs2=request.debugRS.pageInsightsDaily;
		}else{
			rs2=request.facebook.sendRequest(ts);
		} 
		for(i=1;i<=arraylen(rs2.response.data);i++){
			ds=rs2.response.data[i];
			// loop the days
			for(n=1;n<=arraylen(ds.values);n++){
				vs=ds.values[n];
				if(ds.name EQ "page_fan_adds_by_paid_non_paid_unique"){
					pageInfo.newPagePaidFans+=vs.value.paid;
					pageInfo.newPageUnpaidFans+=vs.value.unpaid;
				}else if(ds.name EQ "page_fan_removes"){
					pageInfo.newPageRemoveFanTotal+=vs.value;
				}else if(ds.name EQ "page_views_total"){
					//total=0;
					pageInfo.pageViews+=vs.value;
				}
			}
		}
		//writedump(pageInfo); 

		db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE 
		facebook_page_external_id=#db.param(page.id)# and 
		facebook_page_deleted=#db.param(0)#";
		qPage=db.execute("qPage");
		if(qPage.recordcount EQ 0){
			ts={
				table:"facebook_page",
				datasource:request.zos.zcoreDatasource,
				struct:{
					facebook_page_external_id:page.id,
					facebook_page_datetime:startDate,
					facebook_page_paid_likes:0,
					facebook_page_organic_likes:0,
					facebook_page_unlikes:0,
					facebook_page_reach:0,
					facebook_page_views:pageInfo.pageViewsTotal,
					facebook_page_fans:pageInfo.pageTotalFans,
					facebook_page_followers:0,
					facebook_page_updated_datetime:request.zos.mysqlnow,
					facebook_page_deleted:0
				}
			};
			facebook_page_id=application.zcore.functions.zInsert(ts);
		}else{
			ts={
				table:"facebook_page",
				datasource:request.zos.zcoreDatasource,
				struct:{
					facebook_page_id:qPage.facebook_page_id, 
					facebook_page_external_id:page.id, 
					facebook_page_views:pageInfo.pageViewsTotal,
					facebook_page_fans:pageInfo.pageTotalFans, 
					facebook_page_updated_datetime:request.zos.mysqlnow,
					facebook_page_deleted:0
				}
			};
			facebook_page_id=qPage.facebook_page_id;
			application.zcore.functions.zUpdate(ts);
		}

		db.sql="select * from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE 
		facebook_page_id=#db.param(facebook_page_id)# and 
		facebook_post_deleted=#db.param(0)#";
		qPagePosts=db.execute("qPagePosts");
		postStruct={};
		for(post in qPagePosts){
			postStruct[post.facebook_post_external_id]={facebook_post_id:post.facebook_post_id};
		}

		db.sql="select * from #db.table("facebook_page_month", request.zos.zcoreDatasource)# WHERE 
		facebook_page_external_id=#db.param(page.id)# and 
		facebook_page_month_deleted=#db.param(0)#";
		qPageMonth=db.execute("qPageMonth");
		ts={
			table:"facebook_page_month",
			datasource:request.zos.zcoreDatasource,
			struct:{
				facebook_page_external_id:page.id,
				facebook_page_id:facebook_page_id,
				facebook_page_month_datetime:startDate,
				facebook_page_month_paid_likes:pageInfo.newPagePaidFans,
				facebook_page_month_organic_likes:pageInfo.newPageUnpaidFans,
				facebook_page_month_unlikes:pageInfo.newPageRemoveFanTotal,
				facebook_page_month_reach:0, // no such thing, or have to sum the posts
				facebook_page_month_views:pageInfo.pageViews,
				facebook_page_month_fans:pageInfo.pageTotalFans,
				facebook_page_month_followers:0, // no such thing?
				facebook_page_month_updated_datetime:request.zos.mysqlnow,
				facebook_page_month_deleted:0
			}
		}; 
		if(qPageMonth.recordcount EQ 0){
			facebook_page_month_id=application.zcore.functions.zInsert(ts);
		}else{
			ts.struct.facebook_page_month_id=qPageMonth.facebook_page_month_id;
			application.zcore.functions.zUpdate(ts);
		}

		// everything but reactions is possible:
		ts={
			method:'GET',
			link:'/#page.id#/posts?fields=id,type,object_id,created_time,updated_time,permalink_url,message,comments.limit(0).summary(total_count),shares',
			throwOnError:true
		};
		while(true){ 

			if(request.debug){
				rs2=request.debugRS.pagePosts;
			}else{
				rs2=request.facebook.sendRequest(ts);
			}
			//echo(serializeJson(rs2));abort;
			//writedump(rs2);abort;
			if(rs2.success){
				//writedump(rs2);
				count=arraylen(rs2.response.data); 
				for(n=1;n<=count;n++){
					post=rs2.response.data[n]; 
					created_time=replace(post.created_time, "T", " "); 
					updated_time=replace(post.updated_time, "T", " "); 
 					
					ts2={
						table:"facebook_post",
						datasource:request.zos.zcoreDatasource,
						struct:{
							facebook_post_external_id:post.id,
							facebook_post_created_datetime:dateformat(created_time, "yyyy-mm-dd")&" "&timeformat(created_time, "HH:mm:ss"), 
							facebook_post_updated_datetime:request.zos.mysqlnow,
							facebook_post_deleted:0,
							facebook_post_text:post.message,
							facebook_page_id:facebook_page_id,
							facebook_post_type:post.type,
							facebook_post_permalink:post.permalink_url, 
							facebook_post_changed_datetime:dateformat(updated_time, "yyyy-mm-dd")&" "&timeformat(updated_time, "HH:mm:ss"), 
							facebook_post_comments:post.comments.summary.total_count, 
							facebook_post_updated_datetime:request.zos.mysqlnow,
							facebook_post_deleted:0,
							facebook_post_object_id:"",
							facebook_post_text:post.message,
							facebook_page_id:facebook_page_id
						}
					};
					if(structkeyexists(post, 'object_id')){
						ts2.struct.facebook_post_object_id=post.object_id;
					}
					if(structkeyexists(post, 'shares')){
						ts2.struct.facebook_post_shares=post.shares.count;
					}  
					if(structkeyexists(postStruct, post.id)){
						// update if we get full data?
						ts2.struct.facebook_post_id=postStruct[post.id].facebook_post_id; 
						application.zcore.functions.zUpdate(ts2);
					}else{
						facebook_post_id=application.zcore.functions.zInsert(ts2);
					}

					arrayAppend(ps.arrPost, ts2);
				} 
			}
			if(pageOffset NEQ 0){
				// most efficient way to page through all data according to: https://developers.request.facebook.com/docs/graph-api/using-graph-api/#paging 
				if(structkeyexists(rs2.response.paging, 'next')){
					//writedump(rs2);
					ts.link=rs2.response.paging.next;
				}else{
					echo('Reached the end at pageOffset: #pageOffset# for page id: #page.id#<br>');
					break;
				} 
			}
			pageOffset++;
			if(request.zos.isTestServer){
				if(pageOffset > 2){
					echo('stopped for fast debug<br>');
					break;
				}
			}
		}
		arrayAppend(arrPage, ps);
		//writedump(arrPage);	abort;

		if(request.zos.isTestServer){
			// only download first account on test server
			break;
		}
	}
 	
 	/*
 	writedump(arrPage);
	abort;  
*/
	echo('done');abort;

/* 
	ts={
		method:'GET',
		link:'/me/accounts'
	}
	request.facebook.addBatchRequest(ts);
	request.facebook.addBatchRequest( 'GET', '/' & pageId & '/insights?metric=page_fans,page_fan_adds_by_paid_non_paid_unique,page_fan_removes,page_views_total&period=day&since=' & startDateRemote & '&until=' & endDateRemote );


	request.facebook.addBatchRequest( 'GET', '/' & pageId & '/posts&since=' & startDateRemote & '&until=' & endDateRemote );
	// /{page-id}/posts
	// /{page-id}/feed

	// POST
	// Get a single post (<page id>_<post id>)

	request.facebook.addBatchRequest( 'GET', '/' & videoId & '?fields=id,type,created_time,updated_time,permalink_url,message,comments.limit(0).summary(total_count),shares,
		reactions.type(LIKE).summary(total_count).limit(0).as(like),
		reactions.type(LOVE).summary(total_count).limit(0).as(love),
		reactions.type(WOW).summary(total_count).limit(0).as(wow),
		reactions.type(HAHA).summary(total_count).limit(0).as(haha),
		reactions.type(SAD).summary(total_count).limit(0).as(sad),
		reactions.type(ANGRY).summary(total_count).limit(0).as(angry)'
	);
	request.facebook.addBatchRequest( 'GET', '/' & videoId & '/insights?metric=post_video_views,post_impressions,post_engaged_users,post_fan_reach' );
	// Each request counts as 1 api call, even when batched
	ts={
		throwOnError:false
	};
	rs = request.facebook.sendBatchRequests(ts); 
*/


	</cfscript>

</cffunction>


<cffunction name="getPostDetails" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	setting requesttimeout="10000";

	offset=0;
	perpage=10;
	while(true){
		// pull posts from database, and get detailed post info
		db.sql="select * from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE 
		facebook_post_deleted=#db.param(0)# 
		LIMIT #db.param(offset)#, #db.param(perpage)#";
		qPost=db.execute("qPost");
		offset+=perpage;
		if(qPost.recordcount EQ 0){
			break;
		}

		for(row in qPost){ 
			if(row.facebook_post_reactions EQ 0){
				ts={
					method:"GET",
					link:'/' & row.facebook_post_external_id & '?fields=id,updated_time,comments.limit(0).summary(total_count),shares,
					reactions.type(LIKE).summary(total_count).limit(0).as(like),
					reactions.type(LOVE).summary(total_count).limit(0).as(love),
					reactions.type(WOW).summary(total_count).limit(0).as(wow),
					reactions.type(HAHA).summary(total_count).limit(0).as(haha),
					reactions.type(SAD).summary(total_count).limit(0).as(sad),
					reactions.type(ANGRY).summary(total_count).limit(0).as(angry)'
				};
				if(request.debug){
					rs2=request.debugRS.postDetails;
				}else{
					rs2=request.facebook.sendRequest(ts);
				} 
				ds=rs2.response;
				//echo(serializeJson(rs2));abort;
				//writedump(rs2);abort;

				// if post didn't exist, delete from facebook_post 
				notExist=false;
				if(notExist){
					db.sql="delete from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE 
					facebook_post_id =#db.param(row.facebook_post_id)# and 
					facebook_post_deleted=#db.param(0)#";
					db.execute("qDelete"); 
					continue;
				}

				updated_time=replace(ds.updated_time, "T", " "); 

				reactions=0;
				reactions+=ds.like.summary.total_count;
				reactions+=ds.love.summary.total_count;
				reactions+=ds.wow.summary.total_count;
				reactions+=ds.haha.summary.total_count;
				reactions+=ds.sad.summary.total_count;
				reactions+=ds.angry.summary.total_count; 

				ts={
					table:"facebook_post",
					datasource:request.zos.zcoreDatasource,
					struct:{
						facebook_post_id:row.facebook_post_id, 
						facebook_post_changed_datetime:dateformat(updated_time, "yyyy-mm-dd")&" "&timeformat(updated_time, "HH:mm:ss"),
						facebook_post_reactions:reactions,
						facebook_post_comments:ds.comments.summary.total_count, 
						facebook_post_updated_datetime:request.zos.mysqlnow,
						facebook_post_deleted:0
					}
				};
				if(structkeyexists(ds, 'shares')){
					ts.struct.facebook_post_shares=ds.shares.count;
				}
			}else{
				ts={
					table:"facebook_post",
					datasource:request.zos.zcoreDatasource,
					struct:{
						facebook_post_id:row.facebook_post_id,
						facebook_post_external_id:row.facebook_post_external_id,
						facebook_post_updated_datetime:request.zos.mysqlnow,
						facebook_post_deleted:0,
					}
				};  
			}  
			/*
			post_fan_reach // how many fans saw the post
			post_engaged_fan // this is fan creating story
			post_engaged_users // this is clicks that create story
			post_consumptions // this is clicks
			post_impressions // impressions
			post_impressions_unique // reach
			post_stories // total of write operations related to a post that users did
				checkin				Page checkins
				coupon				offer claims
				event				RSVPing to event
				fan				Page likes
				mention				Page mentions
				page post				posts by a Page
				question				question answers
				user post				posts by people on a Page
				other				other
			post_consumptions_by_type // only way to get link clicks and video plays
	            "video play": 2305,
	            "other clicks": 4774,
	            "photo view": 58,
	            "link clicks": 232
			*/
			// post clicks and others come from insight api instead - consumption was measured on page, is it measured on post too?
			ts2={
				method:"GET",
				link:'/' & row.facebook_post_external_id & '/insights?metric=post_stories,post_video_views,post_negative_feedback,post_consumptions,post_consumptions_by_type,post_impressions,post_impressions_unique,post_engaged_users,post_engaged_fan,post_fan_reach&period=lifetime'
			}; 

			// post_engaged_users-post_engaged_fan reveals how many non-fans engaged
			if(request.debug){
				rs2=request.debugRS.postInsights;
			}else{
				rs2=request.facebook.sendRequest(ts2); 
			}
			//echo(serializeJson(rs2));abort;
			//writedump(rs2);abort; 
			ds=rs2.response.data;
			ts2={};

			for(n=1;n<=arraylen(ds);n++){
				vs=ds[n];
				if(vs.name EQ "post_consumptions_by_type"){
			        ts.struct.facebook_post_video_play=application.zcore.functions.zso(vs.values[1].value, "video play", true, 0);
			        ts.struct.facebook_post_photo_view=application.zcore.functions.zso(vs.values[1].value, "photo view", true, 0);
			        ts.struct.facebook_post_link_click=application.zcore.functions.zso(vs.values[1].value, "link click", true, 0);
			        ts.struct.facebook_post_other_click=application.zcore.functions.zso(vs.values[1].value, "other click", true, 0); 
				}else if(vs.name EQ "post_consumptions"){
					ts.struct.facebook_post_consumptions=vs.values[1].value; 
				}else if(vs.name EQ "post_engaged_fan"){
					ts.struct.facebook_post_engaged_fan=vs.values[1].value;
				}else if(vs.name EQ "post_engaged_users"){
					ts.struct.facebook_post_engaged_users=vs.values[1].value;
				}else if(vs.name EQ "page_negative_feedback"){
					ts.struct.facebook_post_negative_feedback=vs.values[1].value;
				}else if(vs.name EQ "post_stories"){
					ts.struct.facebook_post_stories=vs.values[1].value;
				}else if(vs.name EQ "post_video_views"){
					ts.struct.facebook_post_video_views=vs.values[1].value;
				}else if(vs.name EQ "post_reach"){
					ts.struct.facebook_post_reach=vs.values[1].value;
				}else if(vs.name EQ "post_fan_reach"){
					ts.struct.facebook_post_fan_reach=vs.values[1].value;
				}else if(vs.name EQ "post_post_impressions"){
					ts.struct.facebook_post_impressions=vs.values[1].value;
				}
			} 
			//writedump(ts);abort;
			application.zcore.functions.zUpdate(ts);
			/*
			db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE 
			facebook_page_external_id=#db.param(page.id)# and 
			facebook_page_deleted=#db.param(0)#";
			qPage=db.execute("qPage");
			if(qPage.recordcount EQ 0){

			}*/
			if(request.zos.isTestServer){
				break;
			}
		}
	}
	echo('done');
	abort;
	</cfscript>

</cffunction>




<cffunction name="calculatePageTotals" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	setting requesttimeout="10000";
	db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE  
	facebook_page_deleted=#db.param(0)#";
	qPage=db.execute("qPage");

	//application.zcore.functions.z404("this is not fully implemented yet - there are wrong data structures, but correct data.  trying to find more efficient loop");

	pageMonthStruct={};
	for(page in qPage){
		pageMonthStruct[page.facebook_page_external_id]={};
		db.sql="select * from #db.table("facebook_page_month", request.zos.zcoreDatasource)# WHERE 
		facebook_page_external_id=#db.param(page.facebook_page_external_id)# and 
		facebook_page_month_deleted=#db.param(0)#";
		qPageMonth=db.execute("qPageMonth"); 
		if(qPageMonth.recordcount EQ 0){
			continue;
		}
		ts={
			table:"facebook_page",
			datasource:request.zos.zcoreDatasource,
			struct:{
				facebook_page_id:page.facebook_page_id,
				facebook_page_external_id:page.facebook_page_external_id, 
				facebook_page_paid_likes:0,
				facebook_page_organic_likes:0,
				facebook_page_unlikes:0,
				//facebook_page_reach:0,
				facebook_page_views:0,  
				facebook_page_updated_datetime:request.zos.mysqlnow,
				facebook_page_deleted:0
			}
		};
		for(ms in qPageMonth){
			/*if(not structkeyexists(pageMonthStruct[page.facebook_page_external_id], dateformat(ms.facebook_page_month_datetime, "yyyy-mm-dd")){
				pageMonthStruct[page.facebook_page_external_id][dateformat(ms.facebook_page_month_datetime, "yyyy-mm-dd")]={
					facebook_month_paid_likes:0,
					facebook_month_organic_likes:0,
					facebook_month_unlikes:0,
					facebook_month_reach:0,
					facebook_month_views:0,
					facebook_month_fans:0; 
					facebook_month_followers:0,

				};
			}*/
			ms2={};
			ms2.struct.facebook_month_paid_likes=ms.facebook_page_month_paid_likes;
			ms2.struct.facebook_month_organic_likes=ms.facebook_page_month_organic_likes;
			ms2.struct.facebook_month_unlikes=ms.facebook_page_month_unlikes;
			ms2.struct.facebook_month_reach=ms.facebook_page_month_reach; 
			ms2.struct.facebook_month_views=ms.facebook_page_month_views; 
			ms2.struct.facebook_month_fans=ms.facebook_page_month_fans; 
			ms2.struct.facebook_month_followers=ms.facebook_page_month_followers; 
			pageMonthStruct[page.facebook_page_external_id][dateformat(ms.facebook_page_month_datetime, "yyyy-mm-dd")]=ms2;

			pageMonthStruct[page.facebook_page_external_id][dateformat(ms.facebook_page_month_datetime, "yyyy-mm-dd")]=[];
			ts.struct.facebook_page_paid_likes+=ms.facebook_page_month_paid_likes;
			ts.struct.facebook_page_organic_likes+=ms.facebook_page_month_organic_likes;
			ts.struct.facebook_page_unlikes+=ms.facebook_page_month_unlikes;
			ts.struct.facebook_page_views+=ms.facebook_page_month_views; 
		}
		// reach comes from post sum


		// ts.struct.facebook_page_reach+=ms.facebook_page_month_reach;
		facebook_page_id=application.zcore.functions.zUpdate(ts);
	}



	db.sql="select *, replace(replace(site_short_domain, #db.param("."&request.zos.testDomain)#, #db.param('')#), #db.param('www.')#, #db.param('')#) shortDomain from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_facebook_ad_account_list<>#db.param('')# 
	ORDER BY shortDomain ASC"; 
	qSite=db.execute("qSite"); 
	for(ss in qSite){
		arrList=listToArray(ss.site_facebook_page_id_list, ",");

		// loop each month
		ts={
			table:"facebook_month",
			datasource:request.zos.zcoreDatasource,
			struct:{
				site_id:ss.site_id,
				facebook_month_datetime:startDate,
				facebook_month_paid_likes:0,
				facebook_month_organic_likes:0,
				facebook_month_unlikes:0,
				facebook_month_reach:0,
				facebook_month_views:0,
				facebook_month_fans:0,
				facebook_month_followers:0,
				facebook_month_updated_datetime:request.zos.mysqlnow,
				facebook_month_deleted:0
			}
		};
		for(i=1;i<=arraylen(arrList);i++){
			facebook_page_id=arrList[i];

			
		}
		application.zcore.functions.zUpdate(ts);
	}

	</cfscript>

</cffunction>

</cfoutput>
</cfcomponent>
