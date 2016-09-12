<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>
	if(structkeyexists(form, 'zid') EQ false){
		form.zid = application.zcore.status.getNewId();
		if(structkeyexists(form, 'sid')){
			application.zcore.status.setField(zid, 'site_id',form.sid);
		}
	}
	form.sid = application.zcore.status.getField(form.zid, 'site_id');
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts=0;
	var qSite=0;
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	db.sql="SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# ";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Site Selection");
		application.zcore.functions.zRedirect("/z/server-manager/admin/rewrite-rules/index?zid=#form.zid#&amp;sid=#form.sid#&zsid=#request.zsid#");
	}
	form.site_id=form.sid;
	ts=StructNew();
	ts.table="rewrite_rule";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	ts.forceWhereFields="site_id";
	if(application.zcore.functions.zUpdate(ts)){
		application.zcore.status.setStatus(request.zsid, 'Site Rules Updated for #qsite.site_domain#.');
		application.zcore.functions.zdownloadlink(application.zcore.functions.zvar("domain", form.sid)&"/z/misc/system/updateRewriteRules?zforceapplicationurlrewriteupdate=1");
		application.zcore.functions.zRedirect('/z/server-manager/admin/rewrite-rules/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#');
	}else{
		application.zcore.status.setStatus(request.zsid, 'Failed to updated site rules.',form,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/rewrite-rules/edit?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var qSite=0;
	var qGroup=0;
	var qin=0;
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.8");
	db.sql="SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted=#db.param(0)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Site Selection");
		application.zcore.functions.zRedirect("/z/server-manager/admin/rewrite-rules/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #request.zos.queryObject.table("rewrite_rule", request.zos.zcoreDatasource)# rewrite_rule 
	WHERE site_id = #db.param(form.sid)# and 
		rewrite_rule_deleted=#db.param(0)# ";
	qGroup=db.execute("qGroup");
	if(qgroup.recordcount EQ 0){
		db.sql="INSERT IGNORE INTO #request.zos.queryObject.table("rewrite_rule", request.zos.zcoreDatasource)# 
		SET site_id = #db.param(form.sid)#";
		db.execute("qin");
	}
	application.zcore.functions.zQueryToStruct(qGroup);
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
	<h2>Edit Rules for #qsite.site_domain#</h2>
	<p>There is very limited support for Apache mod_rewrite syntax below to help when migrating a web site from Apache to Nginx. URLs should not include the beginning slash.  Our system handles rewrite rules using string parsing in CFML instead of using the web server.  It may not work for certain static file types.  In that situation, you need to customize the nginx configuration on the <a href="/z/server-manager/admin/site/edit?sid=#form.sid#">globals</a> advanced tab and use valid Nginx syntax features instead.</p>
	<h3>301 Redirect Example</h3>
	<p>RewriteRule ^path/to/file.html$ / [R=301,L]</p>
	<h3>Serve content from a different URL</h3>
	<p>RewriteRule ^blank.html$ path/blank.html [L,QSA]</p>

	<h3>Rewrite rule with multiple variables</h3>
	<p>RewriteRule ^(.*)/(.*).html$ $1/$2.html$3 [L,QSA]</p>
	<form class="zFormCheckDirty" name="editForm" action="/z/server-manager/admin/rewrite-rules/update?zid=#form.zid#&amp;sid=#form.sid#" method="post" style="margin:0px;">
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<td style="vertical-align:top; width:70px;">Image Rules:</td>
				<td><textarea name="rewrite_rule_image" style="width:800px; height:100px;">#form.rewrite_rule_image#</textarea></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:70px;">System Override<br />
					Rules:</td>
				<td><textarea name="rewrite_rule_zsa" style="width:800px; height:100px;">#form.rewrite_rule_zsa#</textarea></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:70px;">Site Rules:</td>
				<td><textarea name="rewrite_rule_site" style="width:800px; height:400px;">#form.rewrite_rule_site#</textarea></td>
			</tr>
			<tr>
				<td style="width:70px;">&nbsp;</td>
				<td><input type="submit" name="submit" value="Update Rules">
					<input type="button" name="cancel" value="Cancel" onClick="window.location.href = '/z/server-manager/admin/rewrite-rules/index?zid=#form.zid#&amp;sid=#form.sid#';"></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var qSites=0;
	var selectStruct=0;
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	db.sql="SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id <> #db.param('1')# and 
	site_deleted = #db.param(0)#

	ORDER BY site_domain asc ";
	qSites=db.execute("qSites");
	</cfscript> 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<td><h2>Rewrite Rules</h2></td>
		</tr>
		<tr>
			<td class="table-white"> Select a site to edit rules:
				<cfscript>
				selectStruct = StructNew();
				selectStruct.name = "sid";
				// options for query data
				selectStruct.onChange="var d=this.options[this.selectedIndex].value; 
				if(d != ''){
					window.location.href='/z/server-manager/admin/rewrite-rules/edit?sid='+escape(d);
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
