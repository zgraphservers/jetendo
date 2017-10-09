<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	checkSecurity();
	form.company_id=application.zcore.functions.zso(form, 'company_id', true);
	db=request.zos.queryObject;
	db.sql="SELECT *, if(site.site_id IS NULL, #db.param(0)#, #db.param(1)#) hasSites
	FROM #db.table("company", request.zos.zcoreDatasource)# `company` 
	LEFT JOIN #db.table("site", request.zos.zcoreDatasource)# site on 
	site.company_id = company.company_id and 
	site.site_id <> #db.param(-1)# and 
	site_deleted=#db.param(0)# 
	WHERE 
	company.company_id = #db.param(form.company_id)# and 
	company_deleted = #db.param(0)#
	GROUP BY company.company_id ";
	variables.qcompany=db.execute("qcompany");
	if(form.method EQ "edit" or form.method EQ "update" or form.method EQ "delete"){
		if(variables.qcompany.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"Company doesn't exist.");
			application.zcore.functions.zRedirect("/z/server-manager/admin/company/index?zsid=#request.zsid#");
		}

		if(form.method EQ "delete" and variables.qcompany.hasSites EQ "1"){
			application.zcore.status.setStatus(request.zsid,"Company still has sites associated with it.  You must re-assign those sites first.");
			application.zcore.functions.zRedirect("/z/server-manager/admin/company/index?zsid=#request.zsid#");
		}
	}
	</cfscript>
</cffunction>


<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	init();
	qCheck=variables.qCompany;
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'company no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/company/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		form.company_deleted=0;
		application.zcore.functions.zDeleteRecord("company", "company_id,company_deleted", request.zos.zcoreDatasource);
		application.zcore.status.setStatus(Request.zsid, 'Company deleted');

		application.zcore.functions.zRedirect('/z/server-manager/admin/company/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this Company?<br />
			<br />
			#qCheck.company_name#<br />
			<br />
			<a href="/z/server-manager/admin/company/delete?confirm=1&amp;company_id=#form.company_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/company/index">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	update();
	</cfscript>
</cffunction>
	
<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	init();
	form.company_updated_datetime=request.zos.mysqlnow;
	myform={};
	myform.company_name.required=true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		if(form.method EQ "insert"){
			application.zcore.functions.zRedirect("/z/server-manager/admin/company/add?zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/server-manager/admin/company/edit?zsid="&request.zsid&"&company_id="&form.company_id);
		}
	}
	ts=StructNew();
	ts.table="company";
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;

	if(form.company_report_autosend_current_date NEQ ""){
		form.company_report_autosend_current_date=dateformat(form.company_report_autosend_current_date, "yyyy-mm");
	}
	
	if(form.method EQ "insert"){
		form.company_id=application.zcore.functions.zInsert(ts);
		if(not form.company_id){
			application.zcore.status.setStatus(request.zsid, 'Failed to save company Certificate due to duplicate certificate.',form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/company/add?company_id=#form.company_id#&zsid=#request.zsid#");
		}
		application.zcore.status.setStatus(request.zsid, 'Company Saved.');
	}else{
		if(application.zcore.functions.zUpdate(ts)){
			application.zcore.status.setStatus(request.zsid, 'Company Updated.');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Failed to update company.',form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/company/edit?company_id=#form.company_id#&zsid=#request.zsid#");
		}
	}
	application.zcore.functions.zRedirect("/z/server-manager/admin/company/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	edit();
	</cfscript>
</cffunction>
	

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	backupMethod=form.method;
	//application.zcore.functions.zSetPageHelpId("8.1.1.9");
	init();
	qcompany=variables.qcompany;
	if(backupMethod EQ "edit" and qcompany.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Company doesn't exist.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/company/index?zsid=#request.zsid#");
	} 
	application.zcore.functions.zQueryToStruct(qcompany, form);
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>	
	<p><a href="/z/server-manager/admin/company/index?sid=#form.sid#">Manage Companies</a> /</p>
	<h2><cfif backupMethod EQ "add">
		<cfset newAction="insert">
		Add
	<cfelse>
		<cfset newAction="update">
		Edit
	</cfif> Company</h2>
	<form class="zFormCheckDirty" name="editForm" action="/z/server-manager/admin/company/#newAction#?company_id=#form.company_id#" method="post" style="margin:0px;">
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Name:</td>
			<td class="table-white"><input type="text" name="company_name" value="#htmleditformat(form.company_name)#" /></td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Report Email List:</td>
			<td class="table-white"><input type="email" multiple="multiple" name="company_report_email_list" value="#htmleditformat(form.company_report_email_list)#" /><br>Comma separated list of emails</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Report Auto-Send Current Date:</td>
			<td class="table-white"><input type="month" name="company_report_autosend_current_date" value="#htmleditformat(dateformat(form.company_report_autosend_current_date,"yyyy-mm"))#" /><br>You must update this date once per month to be the current month after importing of all report is complete.  No reports will be auto-sent otherwise.</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Report Auto-Send From Email:</td>
			<td class="table-white"><input type="email" name="company_report_from_email" value="#htmleditformat(form.company_report_from_email)#" /></td>
		</tr>
		<tr>
			<td class="table-list" style="width:120px;">&nbsp;</td>
			<td class="table-white">
			<button type="submit" name="submit" value="Save">Save</button> <button type="button" name="cancel" value="Cancel" onClick="window.location.href = '/z/server-manager/admin/company/index?sid=#form.sid#';">Cancel</button></td>
		</tr>
	</table>	
	</form>
</cffunction>
	
<cffunction name="checkSecurity" localmode="modern" access="private">
	<cfscript>
	if(not application.zcore.user.checkAllCompanyAccess()){
		application.zcore.status.setStatus(request.zsid, "No access granted to add/edit companies.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index");
	}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	checkSecurity();
	//application.zcore.functions.zSetPageHelpId("8.1.1.9.1");
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	db.sql="SELECT *, if(site.site_id IS NULL, #db.param(0)#, #db.param(1)#) hasSites 
	FROM #db.table("company", request.zos.zcoreDatasource)# company
	LEFT JOIN #db.table("site", request.zos.zcoreDatasource)# site on 
	site.company_id = company.company_id and 
	site.site_id <> #db.param(-1)# and 
	site_deleted=#db.param(0)# 
	WHERE company_deleted = #db.param(0)# 
	GROUP BY company.company_id
	ORDER BY company_name ASC";
	qcompany=db.execute("qcompany");
	</cfscript> 
	<h2 style="display:inline;">Manage Companies</h2> 
	| <a href="/z/server-manager/admin/company/add?sid=#form.sid#">Add Company</a> 
	<br /><br />
	<p>Adding a company and associating a user with it allows you to designate a server administrator that can only add and access server manager features within their company.</p>
	<cfif qcompany.recordcount EQ 0>
		<p>No companies added yet.</p>

	<cfelse>
		<table class="table-list">
			<tr>
				<th>Name</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qcompany">
				<tr>
					<td>#qcompany.company_name#</td>
					<td>
						<a href="/z/server-manager/admin/company/edit?company_id=#qcompany.company_id#">Edit</a>
						<cfif qcompany.hasSites EQ 0>
							 | 
							<a href="/z/server-manager/admin/company/delete?company_id=#qcompany.company_id#">Delete</a>
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>