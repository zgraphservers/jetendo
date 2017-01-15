<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>

		facebook = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.facebook-api' );

		facebookConfig = request.zos.facebookConfig;
		facebook.init( facebookConfig );

		// PAGE
		pageId = request.zos.facebookConfig.debugPageId;
		videoId = request.zos.facebookConfig.debugVideoId; // has views, reactions, shares
		photoId = request.zos.facebookConfig.debugPhotoId; // has comments & likes
		linkId  = request.zos.facebookConfig.debugLinkId; // has like
		postId  = request.zos.facebookConfig.debugPostId; // has likes

		// Get a list of all pages this account manages
		// facebook.addBatchRequest( 'GET', '/me/accounts' );

		// Get page insight metrics
		// facebook.addBatchRequest( 'GET', '/#pageId#/insights?metric=page_fans,page_engaged_users,page_impressions' );

		startDate="2016-12-01";

		endDate="2017-01-10"; 
		startDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), startDate);
		endDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), endDate); 


		facebook.addBatchRequest( 'GET', '/' & pageId & '/insights?metric=page_fans,page_fan_adds_by_paid_non_paid_unique,page_fan_removes,page_views_total&period=day&since=' & startDateRemote & '&until=' & endDateRemote );

		// POST
		// Get a single post (<page id>_<post id>)

		facebook.addBatchRequest( 'GET', '/' & videoId & '?fields=id,type,created_time,updated_time,permalink_url,message,comments.limit(0).summary(total_count),shares,
			reactions.type(LIKE).summary(total_count).limit(0).as(like),
			reactions.type(LOVE).summary(total_count).limit(0).as(love),
			reactions.type(WOW).summary(total_count).limit(0).as(wow),
			reactions.type(HAHA).summary(total_count).limit(0).as(haha),
			reactions.type(SAD).summary(total_count).limit(0).as(sad),
			reactions.type(ANGRY).summary(total_count).limit(0).as(angry)'
		);
		facebook.addBatchRequest( 'GET', '/' & videoId & '/insights?metric=post_video_views,post_impressions,post_engaged_users,post_fan_reach' );

		responses = facebook.sendBatchRequests();

		writeDump( responses );
		abort;

	</cfscript>

</cffunction>
</cfoutput>
</cfcomponent>
