<cfcomponent>
<cfoutput>
	<!--- 
<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var q=0;
	var i=0;
	var ts=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Content Permissions", true); 
	if(structkeyexists(form, 'groupcount')){
		db.sql="DELETE FROM #request.zos.queryObject.table("content_permissions", request.zos.zcoreDatasource)#  
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		content_permissions_deleted = #db.param(0)#";
		q=db.execute("q");
		for(i=1;i LTE form.groupcount;i=i+1){			
			ts=StructNew();
			ts.table="content_permissions";
			ts.datasource=request.zos.zcoreDatasource;
			ts.struct.site_id=request.zos.globals.id;
			ts.struct.content_permissions_content_id = application.zcore.functions.zso(form, 'content_id'&i);
			ts.struct.content_permissions_only_owner = application.zcore.functions.zso(form, 'content_permissions_only_owner'&i);
			ts.struct.user_group_id = application.zcore.functions.zso(form, 'user_group_id'&i);
			application.zcore.functions.zInsert(ts);
		}
	}
	application.zcore.status.setStatus(request.zsid,"Content Permissions Updated.");
	application.zcore.functions.zRedirect("/z/content/admin/permissions/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>
		
<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var local={};
	var qpages=0;
	var qgroups=0;
	var selectStruct=0;
	application.zcore.functions.zSetPageHelpId("2.1.2");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Content Permissions"); 
	db=request.zos.queryObject;
	if(structcount(application.zcore.app.getAppData("content")) EQ 0){
		application.zcore.status.setStatus(request.zsid,"Access denied");
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
		application.zcore.status.setStatus(request.zsid,"Access denied");
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	</cfscript>
	<cfif application.zcore.user.checkSiteAccess()>
		<a href="/z/content/admin/content-admin/index">Manage Content</a> | <a href="/z/content/admin/permissions/index">Manage Permissions</a> <br />
		<br />
	</cfif>
	<h2>Content Permissions</h2>
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	Use this form to set the editable home page for each user group. <span style="color:##FF0000;">WARNING:</span> Please note that they will automatically be given permission to add, edit and delete the selected page and all pages associated with it.<br />
	<br />
	<cfsavecontent variable="db.sql"> SELECT * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content
	WHERE  content.site_id = #db.param(request.zos.globals.id)# and 
	content_deleted=#db.param('0')# 
	ORDER BY content.content_name ASC </cfsavecontent>
	<cfscript>
	qPages=db.execute("qPages");
	</cfscript>
	<cfsavecontent variable="db.sql"> SELECT * FROM #request.zos.queryObject.table("user_group", request.zos.zcoreDatasource)# user_group 
	LEFT JOIN #request.zos.queryObject.table("content_permissions", request.zos.zcoreDatasource)# content_permissions ON 
	user_group.user_group_id = content_permissions.user_group_id and content_permissions.site_id = user_group.site_id and 
	content_permissions_deleted = #db.param(0)#
	WHERE user_group.site_id = #db.param(request.zos.globals.id)# and 
	user_group_name NOT IN #db.trustedsql("('administrator','member','user')")# and 
	user_group_deleted = #db.param(0)#
	ORDER BY user_group_name </cfsavecontent>
	<cfscript>
	qgroups=db.execute("qGroups");
	</cfscript>
	Checking "Owner Only" allows that group to only change content that they create and not other people's.<br />
	<form class="zFormCheckDirty" action="/z/content/admin/permissions/update" method="post">
		<input type="hidden" name="groupcount" value="#qgroups.recordcount#" />
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th>Group</th>
				<th>Content</th>
				<th>Owner Only</th>
			</tr>
			<cfloop query="qgroups">
			<tr>
				<td style="vertical-align:top; ">
					<cfif qgroups.user_group_friendly_name NEQ ''>
						#qgroups.user_group_friendly_name#
					<cfelse>
						#qgroups.user_group_name#
					</cfif></td>
				<td style="vertical-align:top; ">
				<cfscript>
				selectStruct = StructNew();
				selectStruct.name = "content_id#qgroups.currentRow#";
				selectStruct.query = qPages;
				selectStruct.selectLabel="-- All content --";
				selectStruct.defaultValue=qgroups.content_permissions_content_id;
				selectStruct.onChange="submitContentId();";
				selectStruct.queryLabelField = "##content_name##";
				selectStruct.queryParseLabelVars=true;
				selectStruct.queryValueField = "content_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
					<input type="hidden" name="user_group_id#qgroups.currentRow#" value="#qgroups.user_group_id#" /></td>
				<td><input type="checkbox" name="content_permissions_only_owner#qgroups.currentrow#" value="1" style="border:none; background:none;" <cfif qgroups.content_permissions_only_owner EQ 1>checked="checked"</cfif> /></td>
			</tr>
			</cfloop>
		</table>
		<br />
		<input type="submit" name="submitForm" value="Update content permissions" />
	</form>
</cffunction> --->
</cfoutput>
</cfcomponent>
