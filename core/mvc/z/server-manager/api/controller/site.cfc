<cfcomponent>
<cffunction name="getSiteById" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	var ts={
		success:true
	};
	if(not structkeyexists(form, 'sid')){
		ts.success=false;
		ts.errorMessage="form.sid is required.";
		application.zcore.functions.zReturnJson(ts);
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active = #db.param(1)# and 
	site_id = #db.param(form.sid)# ";
	qSite=db.execute("qSite");
	for(row in qSite){
		ts.id=row.site_id;
		ts.shortDomain=row.site_short_domain;
		ts.domain=row.site_domain;
		ts.installPath=application.zcore.functions.zGetDomainInstallPath(row.site_short_domain);
	}
	if(qSite.recordcount EQ 0){
		ts.success=false;
		ts.errorMessage="Site ID, #form.sid#, is not active or doesn't exist.";
	}
	application.zcore.functions.zReturnJson(ts);
	</cfscript>
</cffunction>

<cffunction name="getActive" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zReturnJson({});
	</cfscript>
</cffunction>
</cfcomponent>