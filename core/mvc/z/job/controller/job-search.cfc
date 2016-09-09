<cfcomponent>
<cfoutput> 

<cffunction name="ajaxJobSearch" access="remote" localmode="modern">
	<cfscript> 
	form.startdate=application.zcore.functions.zso(form, 'startdate');
	form.enddate=application.zcore.functions.zso(form, 'enddate');
	form.calendarids=application.zcore.functions.zso(form, 'calendarids');
	form.categories=application.zcore.functions.zso(form, 'categories');
	form.keyword=application.zcore.functions.zso(form, 'keyword');

	ts={
		categories:form.categories,
		keyword:form.keyword,
		onlyFutureJobs:1,
		startDate:form.startdate,
		endDate:form.enddate,
		calendarids:form.calendarids,
	 	offset=min(application.zcore.functions.zso(form, 'offset', true, 0), 1000),
 		perpage=min(application.zcore.functions.zso(form, 'perpage', true, 15),50)
	};
	if(ts.startDate NEQ ""){
		ts.onlyFutureJobs=false;
	}

 	jobCom=application.zcore.app.getAppCFC("job");
 	rs=jobCom.searchJobs(ts); 
 	rs.offset=ts.offset;
 	rs.perpage=ts.perpage;
 	rs.link="/z/job/job-search/ajaxJobSearch?startdate=#urlencodedformat(form.startdate)#&enddate=#urlencodedformat(form.enddate)#&calendarids=#urlencodedformat(form.calendarids)#&categories=#urlencodedformat(form.categories)#&keyword=#urlencodedformat(form.keyword)#";
	calendarCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.job.controller.job-calendar");
	calendarCom.returnListViewCalendarJson(rs);
	</cfscript>	

</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	request.zos.currentURLISAJobPage=true;
	application.zcore.template.setTag("title", "Job Search");
	application.zcore.template.setTag("pagetitle", "Job Search");
	</cfscript>

	<cfscript>
	
	ts={
		searchCalendars:true,
		searchCategories:true,
		searchKeyword:true
	};
	application.zcore.app.getAppCFC("job").displayJobSearchForm(ts);
 
	</cfscript> 
	<div id="zJobSearchResults">
	<div id="zCalendarTab_List"></div>
	</div>

</cffunction>
</cfoutput>
</cfcomponent>