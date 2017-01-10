<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private">  
	<cfscript> 
	setting requestTimeout="100000";
	variables.userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36";
 
	</cfscript>
	
</cffunction>
<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript> 
	db=request.zos.queryObject;
 
	interspireStatus=application.zcore.functions.zso(application, 'interspireImportStatus');
	if(interspireStatus EQ ""){
		interspireStatus="Inactive";
	} 
	</cfscript>
	<h2>Import Keyword Ranking</h2>

	<p><a href="/z/inquiries/admin/import-newsletter-stats/interspire" target="_blank">Test Interspire Backup Import</a> (Status: #interspireStatus#)</p>
	<!--- <p><a href="/z/inquiries/admin/import-newsletter-stats/moz" target="_blank">Test Moz.com Import</a> (Status: #mozStatus#)</p>
	<p><a href="/z/inquiries/admin/import-newsletter-stats/semrush" target="_blank">Test SEMRush.com Import</a> (Status: #semrushStatus#)</p> --->
	 

</cffunction> 

<cffunction name="interspire" access="remote" localmode="modern">
	<cfscript>
	init();
	db=request.zos.queryobject;
 
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_interspire_email_owner_id_list<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite");   
	for(row in qSite){

		application.interspireImportStatus="Processing "&row.site_domain; 
		if(row.site_interspire_email_last_import_datetime EQ ""){
			// download all time
			row.site_interspire_email_last_import_datetime=request.zos.interspireStartDate;
		}else{
			// download only the last 2 months
		} 

		arrTemp=listToArray(row.site_interspire_email_owner_id_list, ",");
		arrOwner=[];
		for(ownerid in arrTemp){
			arrayAppend(arrOwner, ownerid);
		}


		ownerid=arrayToList(arrOwner, ",");

		startDate=dateadd("m", -2, dateformat(row.site_interspire_email_last_import_datetime, "yyyy-mm")&"-01");
		endDate=now(); 
		startDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), startDate);
		endDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), endDate);

		link="#request.zos.interspireExportLink#?startDate=#startDateRemote#&endDate=#endDateRemote#&secret=#request.zos.interspireSecretKey#&ownerid="&urlencodedformat(ownerid); 

/*
fields returned
statid,queueid,starttime,finishtime,htmlrecipients,textrecipients,multipartrecipients,trackopens,tracklinks,bouncecount_soft,bouncecount_hard,bouncecount_unknown,unsubscribecount,newsletterid,sendfromname,sendfromemail,bounceemail,replytoemail,charset,sendinformation,sendsize,sentby,notifyowner,linkclicks,emailopens,emailforwards,emailopens_unique,hiddenby,textopens,textopens_unique,htmlopens,htmlopens_unique,jobid,sendtestmode,sendtype,newslettername,newslettersubject,username,fullname,emailaddress
*/
		rs=application.zcore.functions.zDownloadLink(link, 1000, true);
		if(not rs.success){
			savecontent variable="out"{
				echo('<h2><a href="#link#" target="_blank">#link#</a> export failed.</h2>');
				writedump(rs);
			}
			throw(out);
		}
		/*
		http url="#link#" useragent="#variables.userAgent#" redirect="yes"   method="get" timeout="1000"{  
		} 
		if(left(cfhttp.statuscode,3) NEQ '200' and left(cfhttp.statuscode,3) NEQ '302'){
			savecontent variable="out"{
				echo('<h2>#link# export failed.</h2>');
				writedump(cfhttp);
			}
			throw(out);
		} */

		arrLine=listToArray(rs.cfhttp.filecontent, chr(10));
		arrColumn=listToArray(arrLine[1], chr(9), true);
		arrayDeleteAt(arrLine, 1);

		for(line in arrLine){
			arrRow=listToArray(line, chr(9), true);
			ts={};
			for(i=1;i<=arraylen(arrColumn);i++){
				ts[arrColumn[i]]=arrRow[i];
			}
			//writedump(ts); 

			db.sql="select * from #db.table("newsletter_email", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(row.site_id)# and 
			newsletter_email_deleted=#db.param(0)# and 
			newsletter_email_external_id=#db.param(ts.statid)#";
			qCheck=db.execute("qCheck");

			t9={
				table:"newsletter_email",
				datasource:request.zos.zcoreDatasource,
				struct:{
					newsletter_email_name:ts.newslettername,
					newsletter_email_external_id:ts.statid,
					newsletter_email_sent_datetime:dateadd("s", ts.starttime, createDateTime(1970, 1, 1, 0, 0, 0)),
					newsletter_email_sent_count:ts.htmlrecipients+ts.textrecipients+ts.multipartrecipients,
					newsletter_email_opens:ts.trackopens,
					newsletter_email_clicks:ts.tracklinks,
					newsletter_email_bounces:ts.bouncecount_soft+ts.bouncecount_hard,
					newsletter_email_unsubscribes:ts.unsubscribecount,
					site_id:row.site_id,
					newsletter_email_updated_datetime:request.zos.mysqlnow,
					newsletter_email_deleted:0
				}
			}
			t9.struct.newsletter_email_sent_datetime=dateformat(t9.struct.newsletter_email_sent_datetime, "yyyy-mm-dd")&" "&timeformat(t9.struct.newsletter_email_sent_datetime, "HH:mm:ss"); 
			if(qCheck.recordcount){
				t9.struct.newsletter_email_id=qCheck.newsletter_email_id;
				result=application.zcore.functions.zUpdate(t9);
			}else{
				newsletter_email_id=application.zcore.functions.zInsert(t9);
			}

			/* 
			echo('<p>#numberformat(row.newsletter_month_total_subscribers, "_")# Total Subscribers</p>');
			echo('<p>#numberformat(row.newsletter_month_new_subscribers, "_")# New Subscribers</p>');
			echo('<p>#numberformat(row.newsletter_month_unsubscribed, "_")# Unsubscribed</p>');
			echo('<hr>');
			*/ 
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_interspire_email_last_import_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id = #db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate");

	}  
	echo('done'); 
	structdelete(application, 'interspireImportStatus');
	abort;
	</cfscript>
	
    
</cffunction>
 
	 
</cfoutput>
</cfcomponent>