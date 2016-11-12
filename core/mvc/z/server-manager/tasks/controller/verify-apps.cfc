<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
	#db.table("site", request.zos.zcoreDatasource)# site WHERE 
	site.site_id = app_x_mls.site_id and 
	site_deleted = #db.param(0)# and 
	app_x_mls_deleted = #db.param(0)#
	LIMIT #db.param(0)#, #db.param(1)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount NEQ 0){
		application.zcore.listingCom.checkRamTables();
	}
	echo('Done');abort;
	</cfscript>
</cffunction>

<!--- /z/server-manager/tasks/verify-apps/clearOldTempData --->
<cffunction name="clearOldTempData" access="remote" localmode="modern">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	// delete 404's older then 30 days 
	if(request.zos.disable404Log){

		oldDate=dateadd("d", -30, now());
		db=request.zos.queryObject;
		db.sql="delete from #db.table("log404", request.zos.zcoreDatasource)# 
		WHERE log404_deleted=#db.param(0)# and 
		log404_datetime<=#db.param(dateformat(oldDate, "yyyy-mm-dd")&" "&timeformat(oldDate, "HH:mm:ss"))# 
		";
		db.execute("qDelete");
	}

	oldDate=dateadd("h", -2, now());
	// clear old files in temp
	tempPath=request.zos.globals.serverPrivateHomeDir&"_cache/temp_files/";
	qDir=directoryList(tempPath, true, "query");
	arrDir=[];
	deleteCount=0;
	for(row in qDir){
		path=row.directory&"/"&row.name;
		if(datecompare(row.dateLastModified, oldDate) EQ -1){
			if(row.type EQ "dir"){
				arrayAppend(arrDir, path);
			}else{
				application.zcore.functions.zDeleteFile(path);
				deleteCount++;
			}
		}
	}
	deleteDirCount=0;
	for(path in arrDir){
		directorydelete(path, true); 
		deleteDirCount++;
	}
	echo('Deleted #deleteCount# temp files and #deleteDirCount# directories.<br>');


	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>