<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	
	if(not request.zos.istestserver){
		application.zcore.functions.z404("Invalid request");
	}
	</cfscript>
</cffunction>

<cffunction name="viewCategory" localmode="modern" access="remote">
	<cfscript>
	request.zos.currentURLISAJobPage=true;
    db=request.zos.queryObject;  
	application.zcore.functions.zRequireJqueryUI();

	form.job_category_id=application.zcore.functions.zso(form, 'job_category_id', true);


	db.sql="select * from #db.table("job_category", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	job_category_deleted=#db.param(0)# and 
	job_category_id = #db.param(form.job_category_id)# ";
	qCategory=db.execute("qCategory");
	application.zcore.functions.zQueryToStruct(qCategory, form);
	if(qCategory.recordcount EQ 0){
		application.zcore.functions.z404("form.job_category_id, #form.job_category_id#,  doesn't exist.");
	}
	if(not application.zcore.app.getAppCFC("job").userHasAccessToJobCalendarID(qCategory.job_cal_id)){
		application.zcore.status.setStatus(request.zsid, "You must login to view the calendar");
		application.zcore.functions.zRedirect("/z/user/preference/index?zsid=#request.zsid#&returnURL=#urlencodedformat(request.zos.originalURL)#");
	}
	categoryStruct={};
	for(row in qCategory){
		categoryStruct=row;
	} 
	application.zcore.template.setTag("title", qCategory.job_category_name);
	application.zcore.template.setTag("pagetitle", qCategory.job_category_name);
	echo(qCategory.job_category_description);
	if(structkeyexists(form, 'zUrlName')){
		if(categoryStruct.job_category_unique_url EQ ""){

			curLink=application.zcore.app.getAppCFC("job").getCategoryURL(categoryStruct); 
			urlId=application.zcore.app.getAppData("job").optionstruct.job_config_category_url_id;
			actualLink="/"&application.zcore.functions.zURLEncode(form.zURLName, '-')&"-"&urlId&"-"&categoryStruct.job_category_id&".html";

			if(compare(curLink,actualLink) neq 0){
				application.zcore.functions.z301Redirect(curLink);
			}
		}else{
			if(compare(categoryStruct.job_category_unique_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(categoryStruct.job_category_unique_url);
			}
		}
	} 

	form.zview=application.zcore.functions.zso(form, 'zview');
	arrView=listToArray(qCategory.job_category_list_views, ",");

	ss={};
	ss.viewStruct={};
	for(i=1;i<=arrayLen(arrView);i++){
		ss.viewStruct[arrView[i]]=true;
	}
	ss.defaultView=form.job_category_list_default_view;
	if(form.zview NEQ ""){
		ss.defaultView=form.zview;
	}
	ss.jsonFullLink="/z/job/job-calendar/getFullCalendarJson?categories=#form.job_category_id#";
	ss.jsonListLink="/z/job/job-calendar/getListViewCalendarJson?categories=#form.job_category_id#";

	calendarCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.job.controller.job-calendar");
	calendarCom.displayCalendar(ss);
	</cfscript> 

</cffunction>
</cfoutput>
</cfcomponent>