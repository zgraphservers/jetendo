<cfcomponent>
<cffunction name="executeCacheReset" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	// this function is here as a placeholder for a "executeCacheReset" function that is exactly executed in onRequestStart.
	</cfscript>
</cffunction>

<cffunction name="getConfig" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	var ts={
		installPath: request.zos.installPath, 
		arrSite:[],
		success:true
	};
	db=request.zos.queryObject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active = #db.param(1)# and 
	site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)#
	ORDER BY site_short_domain ASC ";
	qSite=db.execute("qSite");
	for(row in qSite){
		ss={
			id:row.site_id,
			shortDomain:row.site_short_domain,
			primaryGitRepository:row.site_primary_git_repository,
			installPath: application.zcore.functions.zGetDomainInstallPath(row.site_short_domain),
			installWritablePath: application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain)
		}
		arrayAppend(ts.arrSite, ss);
	}
	
	application.zcore.functions.zReturnJson(ts);
	</cfscript>
</cffunction>
</cfcomponent>