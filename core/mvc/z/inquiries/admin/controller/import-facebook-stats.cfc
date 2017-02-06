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
	throw("not implemented");
	db=request.zos.queryObject;

	// for debugging only:
	//processMoz(application.zcore.functions.zVar("privateHomeDir", 298)&"seo-report-download/298-moz-keyword-report.csv", 298); abort;
	//processSemrush(application.zcore.functions.zVar("privateHomeDir", 298)&"seo-report-download/298-semrush-keyword-report.csv", 298); abort;
	/*mozStatus=application.zcore.functions.zso(application, 'mozImportStatus');
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
	}*/
	db.sql="select *, replace(replace(site_short_domain, #db.param("."&request.zos.testDomain)#, #db.param('')#), #db.param('www.')#, #db.param('')#) shortDomain from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# 
	ORDER BY shortDomain ASC"; 
	qSite=db.execute("qSite"); 
	</cfscript>
	<h2>Import Keyword Ranking</h2>
	<!--- there will be at least 2 different imports for facebook --->
	<!--- <p><a href="/z/inquiries/admin/import-newsletter-stats/webposition" target="_blank">Test Webposition.com Backup Import</a> (Status: #webpositionStatus#)</p>
	<p><a href="/z/inquiries/admin/import-newsletter-stats/moz" target="_blank">Test Moz.com Import</a> (Status: #mozStatus#)</p>
	<p><a href="/z/inquiries/admin/import-newsletter-stats/semrush" target="_blank">Test SEMRush.com Import</a> (Status: #semrushStatus#)</p> --->
 
</cffunction>

	

<cffunction name="downloadFacebook" access="remote" localmode="modern">

	<cfscript>
	init();
	db=request.zos.queryobject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and  
	site_seomoz_id_list<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
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
 

<cffunction name="processFacebook" access="remote" localmode="modern"> 
	<cfscript> 
	db=request.zos.queryObject;
 
 
	arrColumn=listToArray(arrLine[1], ",", true);
	arrayDeleteAt(arrLine, 1);
  

	requiredFields={
		keyword:true,
		volume:true,
		date:true,
		position:true
	};

	count=0;
	for(n=1;n<=lineCount;n++){
		cs = dataImportCom.getRow();  

		if(n EQ 1){
			fail=false;
			for(i2 in requiredFields){
				if(not structkeyexists(cs, i2)){
					echo(i2&" is a required column | line #n#<br>");
					fail=true;
				}
			}
			if(fail){
				echo('You must go back and upload a valid file.');

				echo('<br><br>Example record<br>');
				writedump(cs);
				abort;
			}
		}
		count++; 

		// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
		db.sql="select * from #db.table("keyword_ranking", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(form.sid)# and 
		keyword_ranking_deleted=#db.param(0)# and 
		keyword_ranking_position=#db.param(cs["Position"])# and
		keyword_ranking_run_datetime=#db.param(dateformat(cs["Date"], "yyyy-mm-dd")&" 00:00:00")# and 
		keyword_ranking_keyword=#db.param(cs.keyword)# and
		keyword_ranking_source=#db.param("4")#";
		qRank=db.execute("qRank");
		//writedump(qRank);


/*
1 table
  		echo('<tr><th>Total Fans</th><td>#numberformat(row.facebook_month_fans, "_")#</td></tr>');
  		echo('<tr><th>Paid Likes</th><td>#numberformat(row.facebook_month_paid_likes, "_")#</td></tr>');
  		echo('<tr><th>Organic Likes</th><td>#numberformat(row.facebook_month_organic_likes, "_")#</td></tr>');
  		echo('<tr><th>Unlikes</th><td>#numberformat(row.facebook_month_unlikes, "_")#</td></tr>');
  		echo('<tr><th>Reach</th><td>#numberformat(row.facebook_month_reach, "_")#</td></tr>');
  		echo('<tr><th>Page Views</th><td>#numberformat(row.facebook_month_views, "_")#</td></tr>');
  		echo('<tr><th>Followers</th><td>#numberformat(row.facebook_month_followers, "_")#</td></tr>'); 


another table
					<td style="width:1%; white-space:nowrap;">#row.facebook_post_text#</td>
					<td>#dateformat(row.facebook_post_created_datetime, "m/d/yyyy")#</td> 
					<td>#numberformat(row.facebook_post_clicks, "_")#</td>
					<td>#numberformat(row.facebook_post_reactions, "_")#</td>
					<td>#numberformat(row.facebook_post_impressions, "_")#</td>
					<td>#numberformat(row.facebook_post_comments, "_")#</td>
					<td>#numberformat(row.facebook_post_reach, "_")#</td> 
					<td>#numberformat(row.facebook_post_shares, "_")#</td>
					<td>#numberformat(row.facebook_post_video_views, "_")#</td>
					*/

		ts={
			table:"keyword_ranking",
			datasource:request.zos.zcoreDatasource,
			struct:{
				keyword_ranking_source:"4", // 1 is moz.com, 2 is webposition.com, 3 is semrush.com, 4 is manual
				site_id:form.sid,
				keyword_ranking_position:cs["Position"],
				keyword_ranking_run_datetime:dateformat(cs["Date"], "yyyy-mm-dd")&" 00:00:00",
				keyword_ranking_keyword:cs.keyword,
				keyword_ranking_updated_datetime:request.zos.mysqlnow,
				keyword_ranking_deleted:0,
				keyword_ranking_search_volume:cs.volume
			}
		};
		if(qRank.recordcount EQ 0){ 
			keyword_ranking_id=application.zcore.functions.zInsert(ts);  
			echo('insert:'&keyword_ranking_id&'<br>');
		}else{
			ts.struct.keyword_ranking_id=qRank.keyword_ranking_id;
			result=application.zcore.functions.zUpdate(ts);
			echo('update:'&result&'<br>');

		}
	}
	echo('processed #count# records<br>'); 
	abort;
	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>