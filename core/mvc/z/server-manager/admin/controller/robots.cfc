<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript> 
	if(structkeyexists(form, 'zid') EQ false){
		form.zid = application.zcore.status.getNewId();
		if(structkeyexists(form, 'sid')){
			application.zcore.status.setField(form.zid, 'site_id', form.sid);
		}
	}
	form.sid = application.zcore.status.getField(form.zid, 'site_id');
	</cfscript>
</cffunction>

<cffunction name="updateGlobal" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var fileexisted=false;
	var qGlobal=0;
	var error=0;
	var qSite=0;
	var fileexisted=0;
	var newContents=0;
	var newZSARules=0;
	var qApps=0;
	var configCom=0;
	var i=0;
	var arrRules=0;
	var tempFile=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	db.sql="SELECT * FROM #db.table("robots_global", request.zos.zcoreDatasource)# robots_global WHERE 
	robots_global_deleted = #db.param(0)#";
	qGlobal=db.execute("qGlobal");
	fileexisted=false;
	error=false;
	if(find("##image_rules##",form.robots_global_site) EQ 0){
		application.zcore.status.setStatus(request.zsid, '##image_rules## must be part of the global robots.txt site rules.',form,true);
		error=true;
	}
	if(find("##zsa_rules##",form.robots_global_site) EQ 0){
		application.zcore.status.setStatus(request.zsid, '##zsa_rules## must be part of the global robots.txt site rules.',form,true);
		error=true;
	}
	if(find("##site_rules##",form.robots_global_site) EQ 0){
		application.zcore.status.setStatus(request.zsid, '##site_rules## must be part of the global robots.txt site rules.',form,true);
		error=true;
	}
	if(find("##image_rules##",form.robots_global_zsa) EQ 0){
		application.zcore.status.setStatus(request.zsid, '##image_rules## must be part of the global robots.txt system rules.',form,true);
		error=true;
	}
	if(find("##zsa_rules##",form.robots_global_zsa) EQ 0){
		application.zcore.status.setStatus(request.zsid, '##zsa_rules## must be part of the global robots.txt system rules.',form,true);
		error=true;
	}
	if(find("##site_rules##",form.robots_global_zsa) EQ 0){
		application.zcore.status.setStatus(request.zsid, '##site_rules## must be part of the global robots.txt system rules.',form,true);
		error=true;
	}
	
	if(error){
		application.zcore.functions.zRedirect("/z/server-manager/admin/robots/editGlobal?zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	LEFT JOIN #db.table("robots", request.zos.zcoreDatasource)# robots ON 
	site.site_id = robots.site_id and robots_deleted = #db.param(0)#
	WHERE site.site_active=#db.param('1')# and 
	site_deleted = #db.param(0)# and
	site.site_id<>#db.param('0')#";
	qSite=db.execute("qSite");
	loop query="qsite"{
		local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(qSite.site_short_domain)&"zcache/";
		if(fileexists(local.tempPath&'robots.txt')){
			fileexisted=true;
		}
		// get global rules
		if(qSite.site_domain EQ request.zOS.zcoreAdminDomain or qSite.site_domain EQ request.zOS.zcoreTestAdminDomain){
			newContents = form.robots_global_zsa;
		}else{
			newContents = form.robots_global_site;
		}
		if(newContents EQ ""){
			newContents="##image_rules##"&chr(10)&"##application.zcore.functions.zsa_rules##"&chr(10)&"##site_rules##";
		}
		
		newZSARules=qsite.robots_zsa;
		// get all the application robots.txt for this site_id
		arrRules=arraynew(1);
		db.sql="SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app, 
		#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
		WHERE app_x_site.site_id = #db.param(qsite.site_id)# and 
		app_x_site.app_x_site_status = #db.param('1')# and 
		app.app_built_in=#db.param(0)# and 
		app.app_id=app_x_site.app_id and 
		app_deleted = #db.param(0)# and 
		app_x_site_deleted = #db.param(0)# ";
		qApps=db.execute("qApps"); 
		for(i=1;i LTE qApps.recordcount;i++){
			configCom=createobject("component",application.zcore.appComPathStruct[qapps.app_id[i]].cfcPath);
			arrayappend(arrRules,configCom.getRobotsTxt(qApps.site_id[i]));
		}
		newZSARules=newzSARules&chr(10)&arraytolist(arrRules,chr(10));
		
		// replace the 3 variables
		newContents=replace(newContents,"##image_rules##",qsite.robots_image);
		newContents=replace(newContents, "##zsa_rules##",newZSARules);
		newContents=replace(newContents, "##site_rules##",qsite.robots_site);
		
		newContents=replace(replace(newContents,chr(13),"","ALL"),chr(10),chr(13)&chr(10),"ALL"); 
		application.zcore.functions.zwritefile(local.tempPath&'robots.txt',trim(newContents));
	}
	db.sql="update #db.table("robots_global", request.zos.zcoreDatasource)# robots_global 
	set robots_global_site=#db.param(form.robots_global_site)#, 
	robots_global_zsa=#db.param(form.robots_global_zsa)#,
	robots_global_updated_datetime=#db.param(request.zos.mysqlnow)#  
	where robots_global_id=#db.param('1')#";
	db.execute("q"); 
	application.zcore.status.setStatus(request.zsid, 'Global Robots.txt Updated.');
	application.zcore.functions.zRedirect("/z/server-manager/admin/robots/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qSite=0;
	var qGlobal=0;
	var qRule=0;
	var fileexisted=0;
	var ts=0;
	var newContents=0;
	var newZSARules=0;
	var arrRules=0;
	 var configCom=0;
	 var qApps=0;
	 var i=0;
	 var tempfile=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Site Selection");
		application.zcore.functions.zRedirect("/z/server-manager/admin/robots/index?zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #db.table("robots_global", request.zos.zcoreDatasource)# robots_global 
	WHERE robots_global_id = #db.param('1')#";
	qGlobal=db.execute("qGlobal");
	db.sql="SELECT * FROM #db.table("robots", request.zos.zcoreDatasource)# robots 
	WHERE site_id = #db.param(form.sid)#";
	qRule=db.execute("qRule");
	if(qglobal.recordcount EQ 0){
		application.zcore.template.fail("Robots.txt database is corrupted");
	}
	fileexisted=false;
	local.tempPath=application.zcore.functions.zGetDomainInstallPath(qSite.site_short_domain);
	if(fileexists(local.tempPath&'robots.txt')){
		fileexisted=true;
	}
	ts=StructNew();
	ts.table="robots";
	ts.datasource=request.zos.zcoreDatasource;
	ts.forceWhereFields="site_id";
	ts.struct=form;
	ts.struct.site_id=form.sid;
	ts.struct.robots_id=form.robots_id;
	
	// get global robots.txt
	if(qSite.site_domain EQ request.zOS.zcoreAdminDomain or qSite.site_domain EQ request.zOS.zcoreTestAdminDomain){
		newContents = qglobal.robots_global_zsa;
	}else{
		newContents = qglobal.robots_global_site;
	}
	if(newContents EQ ""){
		newContents="##image_rules##"&chr(10)&"##application.zcore.functions.zsa_rules##"&chr(10)&"##site_rules##";
	}
	
	newZSARules=form.robots_zsa;
	// get all the application robots.txt for this site_id
	arrRules=arraynew(1);
	 db.sql="SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app, 
	 #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	 WHERE app_x_site.site_id = #db.param(form.sid)# and 
	 app.app_built_in=#db.param(0)# and 
	app_x_site.app_x_site_status = #db.param('1')# and 
	app.app_id=app_x_site.app_id and 
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)#";
	qApps=db.execute("qApps");
	for(i=1;i LTE qApps.recordcount;i++){
		configCom=createobject("component",application.zcore.appComPathStruct[qapps.app_id[i]].cfcPath);
		arrayappend(arrRules,configCom.getRobotsTxt(qApps.site_id[i]));
	}
	newZSARules=newzSARules&chr(10)&arraytolist(arrRules,chr(10));
	
	// replace the 3 variables
	newContents=replace(newContents,"##image_rules##",form.robots_image);
	newContents=replace(newContents, "##zsa_rules##",newZSARules);
	newContents=replace(newContents, "##site_rules##",form.robots_site);
	newContents=replace(replace(newContents,chr(13),"","ALL"),chr(10),chr(13)&chr(10),"ALL");
	
	local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(qSite.site_short_domain)&'zcache/';
	application.zcore.functions.zwritefile(local.tempPath&"robots.txt",trim(newContents));
	
	if(qRule.recordcount EQ 0){
		application.zcore.functions.zInsert(ts);
	}else if(application.zcore.functions.zUpdate(ts)){
		application.zcore.status.setStatus(request.zsid, 'Robots.txt Updated.');
		application.zcore.functions.zRedirect("/z/server-manager/admin/robots/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#");
	}else{
		application.zcore.status.setStatus(request.zsid, 'Failed to updated robots.txt.',form,true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/robots/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#");
	}
	</cfscript>
</cffunction>

<cffunction name="editGlobal" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var qin=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.9.1.1");
	db.sql="SELECT * FROM #db.table("robots_global", request.zos.zcoreDatasource)# robots_global 
	WHERE robots_global_id = #db.param('1')#";
	qGroup=db.execute("qGroup");
	if(qgroup.recordcount EQ 0){
		db.sql="REPLACE INTO #db.table("robots_global", request.zos.zcoreDatasource)#  
		SET robots_global_id = #db.param('1')#, 
		robots_global_updated_datetime=#db.param(request.zos.mysqlnow)# ";
		qin=db.execute("qin");
	}
	application.zcore.functions.zQueryToStruct(qGroup, form);
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>	
	<h2>Edit Global Robots.txt</h2>
	<form class="zFormCheckDirty" name="globalForm" action="/z/server-manager/admin/robots/updateGlobal" method="post" style="margin:0px;">
		<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<td class="table-list" style="vertical-align:top; width:140px;">Global Rules:</td>
			<td class="table-white"><textarea name="robots_global_site" style="width:800px; height:500px;">#form.robots_global_site#</textarea><br />
			Must contain ##image_rules##, ##zsa_rules## and 
			##site_rules##.</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:70px;">Global Admin Domain:<br />
Rules:</td>
			<td class="table-white">These rules are only used for admin domain.<br /><textarea name="robots_global_zsa" style="width:800px; height:300px;">		
			#form.robots_global_zsa#</textarea></td>
		</tr>
	<tr>
		<td class="table-list" style="width:120px;">&nbsp;</td>
		<td class="table-white">
		<input type="submit" name="submit" value="Update Robots.txt"> <input type="button" name="cancel" value="Cancel" onClick="window.location.href = '/z/server-manager/admin/robots/index';"></td>
	</tr>
	</table>	
	</form>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var qSite=0;
	var qin=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.9");
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Site Selection");
		application.zcore.functions.zRedirect("/z/server-manager/admin/robots/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #db.table("robots", request.zos.zcoreDatasource)# robots 
	WHERE site_id = #db.param(form.sid)#";
	qGroup=db.execute("qGroup");
	if(qgroup.recordcount EQ 0){
		db.sql="INSERT IGNORE INTO #db.table("robots", request.zos.zcoreDatasource)#  
		SET site_id = #db.param(form.sid)# ";
		db.execute("qin");
	}
	application.zcore.functions.zQueryToStruct(qGroup, form);
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>	
	<cfif application.zcore.user.checkAllCompanyAccess()>
	
		<p><a href="/z/server-manager/admin/robots/index?zid=#form.zid#&amp;sid=#form.sid#">Manage Robots.txt</a> /</p>
	</cfif>
	<h2>Edit Robots.txt for #qsite.site_domain#</h2>
	<form class="zFormCheckDirty" name="editForm" action="/z/server-manager/admin/robots/update?zid=#form.zid#&amp;sid=#form.sid#&amp;robots_id=#form.robots_id#" method="post" style="margin:0px;">
		<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<td class="table-list" style="vertical-align:top; width:70px;">Image Rules:</td>
			<td class="table-white"><textarea name="robots_image" style="width:800px; height:100px;">#form.robots_image#</textarea></td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:70px;">System Override<br />
Rules:</td>
			<td class="table-white"><textarea name="robots_zsa" style="width:800px; height:100px;">#form.robots_zsa#</textarea></td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:70px;">Site Rules:</td>
			<td class="table-white"><textarea name="robots_site" style="width:800px; height:400px;">#form.robots_site#</textarea></td>
		</tr>
	<tr>
		<td class="table-list" style="width:70px;">&nbsp;</td>
		<td class="table-white">
		<input type="submit" name="submit" value="Update Robots.txt"> <input type="button" name="cancel" value="Cancel" onClick="window.location.href = '/z/server-manager/admin/robots/index?zid=#form.zid#&amp;sid=#form.sid#';"></td>
	</tr>
	</table>	
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	var qSites=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.9.1");
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript> 
	<table style="width:100%; border-spacing:0px;" class="table-white">
	<tr>
	<td><span class="large">Manage Robots.txt</span>
	<cfif application.zcore.user.checkAllCompanyAccess()>
		 | <a href="/z/server-manager/admin/robots/editGlobal">Edit Server Manager Global Robots.txt</a>
	</cfif>
	</td>
	</tr>
	<cfscript>
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site  
	WHERE site_deleted = #db.param(0)# and 
	site_id <> #db.param(-1)#
	ORDER BY site_domain asc";
	qSites=db.execute("qSites");
	</cfscript>
	<tr>
	<td class="table-white">
	Select a site to edit rules: 
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "sid";
	// options for query data
	selectStruct.onChange="var d=this.options[this.selectedIndex].value; 
	if(d != ''){
		window.location.href='/z/server-manager/admin/robots/edit?sid='+escape(d);
	}";
	selectStruct.query = qSites;
	selectStruct.queryLabelField = "site_domain";
	selectStruct.queryValueField = "site_id";	
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript></td>
	</tr>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>