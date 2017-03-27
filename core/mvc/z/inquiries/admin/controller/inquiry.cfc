<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zRedirect("/z/inquiries/admin/inquiry/add");
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var myForm={};
	var r=0;
	var result=0;
	var inputStruct=0;
	variables.init();
	myForm.inquiries_email.allowNull = true;
	myForm.inquiries_email.friendlyName = "Email Address";
	myForm.inquiries_email.email = true;
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.friendlyName = "First Name";
	myForm.inquiries_datetime.createDateTime = true;
	if(application.zcore.functions.zso(form,'inquiries_type_id') EQ '' and application.zcore.functions.zso(form,'inquiries_type_other') EQ ''){
		application.zcore.status.setStatus(Request.zsid, 'Referred From is required',form,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/inquiry/add?zPageId=#form.zPageId#&zsid=#Request.zsid#");
	}
	if(application.zcore.functions.zso(form,'inquiries_type_other') NEQ ''){
		form.inquiries_type_id=0;
		form.inquiries_type_id_siteIdType=4;
	}else{
		local.arrType=listToArray(form.inquiries_type_id,"|");
		form.inquiries_type_id=local.arrType[1];
		form.inquiries_type_id_siteIDType=local.arrType[2];
	}
	form.inquiries_status_id = application.zcore.functions.zso(form, 'inquiries_status_id', true);
	if(form.inquiries_status_id EQ 0){
		form.inquiries_status_id=1;
	} 

	if(not structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		form.user_id=request.zsession.user.id;
		form.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
		form.inquiries_status_id=2;
	}

	result = application.zcore.functions.zValidateStruct(form, myForm,request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/inquiry/add?zPageId=#form.zPageId#&zsid=#Request.zsid#");
	} 
	form.site_id = request.zOS.globals.id;
	
	form.inquiries_session_id=application.zcore.session.getSessionId();
	form.inquiries_primary=1;
	db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	SET inquiries_primary=#db.param(0)#, 
	inquiries_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE inquiries_email=#db.param(form.inquiries_email)# and 
	inquiries_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	r=db.execute("r"); 
	if(form.method EQ 'insert'){
		form.inquiries_status_id = 1;

		form.inquiries_id=application.zcore.functions.zInsertLead(); 
		if(form.inquiries_id EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be added.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/inquiry/add?zPageId=#form.zPageId#&zsid="&request.zsid);
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead Added.");
		}
	}else{
		result=application.zcore.functions.zUpdateLead();  
		if(result EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be updated.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/inquiry/update?zPageId=#form.zPageId#&inquiries_id=#form.inquiries_id#&zsid="&request.zsid);
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead Updated.");
		}
	}
	/*if(structkeyexists(request.zos.userSession.groupAccess, "administrator") and form.user_id NEQ '0' and form.user_id NEQ ''){
		application.zcore.functions.zRedirect('/z/inquiries/admin/assign/assign?zPageId=#form.zPageId#&inquiries_id=#form.inquiries_id#&user_id=#form.user_id#&zsid=#request.zsid#');
	}*/
	application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zsid='&request.zsid);
	</cfscript>
</cffunction>


<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qAgents=0;
	var userGroupCom=0;
	var selectStruct=0;
	var qTypes=0;
	var qInquiries=0;
	var qInquiryStatus=0;
	var hCom=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.2");
	form.inquiries_id = application.zcore.functions.zso(form, 'inquiries_id',false,-1);
	</cfscript>
	<cfsavecontent variable="db.sql"> SELECT *
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	WHERE inquiries_id = #db.param(form.inquiries_id)# and site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted = #db.param(0)# 
	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false>
		and user_id = #db.param(request.zsession.user.id)# and user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
	</cfif>
	</cfsavecontent>
	<cfscript>
	qInquiries=db.execute("qInquiries");
	if(currentMethod EQ 'edit'){
		application.zcore.template.setTag("title","Edit Lead");
	}else{
		application.zcore.template.setTag("title","Add Lead");
	}
	application.zcore.functions.zQueryToStruct(qInquiries, form);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	
	hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	</cfscript>
	<span class="form-view">
	<h2>
		<cfif currentMethod EQ 'edit'>
			Edit
		<cfelse>
			Add
		</cfif>
		Lead</h2>
	Be sure to always ask the lead what kind of advertising referred them to your office.<br />
	<br />
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/inquiries/admin/inquiry/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?zPageId=#form.zPageId#&amp;inquiries_id=#form.inquiries_id#" method="post">
	<table style="border-spacing:0px;" class="table-list">

			<tr>
				<th style="width:70px;">Source:</th>
				<td>
					<cfscript>
					form.inquiries_type_id=form.inquiries_type_id&"|"&form.inquiries_type_id_siteIDType;
					db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
					WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
					inquiries_type_deleted = #db.param(0)# ";
					if(not application.zcore.app.siteHasApp("listing")){
						db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
					}
					if(not application.zcore.app.siteHasApp("rental")){
						db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
					}
					db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
					qTypes=db.execute("qTypes");
					selectStruct = StructNew();
					selectStruct.name = "inquiries_type_id";
					selectStruct.query = qTypes;
					selectStruct.queryLabelField = "inquiries_type_name";
					selectStruct.queryParseValueVars=true;
					selectStruct.queryValueField = "##inquiries_type_id##|##inquiries_type_id_siteIDType##";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					or Other:
					<input type="text" name="inquiries_type_other" style="min-width:auto; max-width:300px; " value="#application.zcore.functions.zso(form,'inquiries_type_other')#" />
					<span class="highlight"> * Required</span></td>
			</tr>
			<tr>
				<th style="width:70px;">First Name:</th>
				<td><input name="inquiries_first_name" type="text" size="30" maxlength="50" value="#form.inquiries_first_name#" />
					<span class="highlight"> * Required</span></td>
			</tr>
			<tr>
				<th>Last Name:</th>
				<td><input name="inquiries_last_name" type="text" size="30" maxlength="50" value="#form.inquiries_last_name#" /></td>
			</tr>
			<tr>
				<th>Email:</th>
				<td><input name="inquiries_email" type="text" size="30" maxlength="50" value="#form.inquiries_email#" /></td>
			</tr>
			<tr>
				<th>Phone:</th>
				<td><input name="inquiries_phone1" type="text" size="15" maxlength="50" value="#form.inquiries_phone1#" /></td>
			</tr>
			<tr>
				<th>Phone 2:</th>
				<td class="table-white"><input name="inquiries_phone2" type="text" size="15" maxlength="50" value="#form.inquiries_phone2#" />
					(Cell)&nbsp;</td>
			</tr>
			<cfif structkeyexists(form, 'inquiries_phone3')>
				<tr>
					<th>Phone 3:</th>
					<td class="table-white"><input name="inquiries_phone3" type="text" size="15" maxlength="50" value="#form.inquiries_phone3#" />
						(Home)&nbsp;</td>
				</tr>
			</cfif>
			<tr>
				<th>Address:</th>
				<td class="table-white"><input name="inquiries_address" type="text" size="50" maxlength="50" value="#form.inquiries_address#" />
					&nbsp;</td>
			</tr>
			<tr>
				<th>Address 2:</th>
				<td class="table-white"><input name="inquiries_address2" type="text" size="50" maxlength="50" value="#form.inquiries_address2#" />
					&nbsp;</td>
			</tr>
			<tr>
				<th>City:</th>
				<td class="table-white"><input name="inquiries_city" type="text" size="50" maxlength="50" value="#form.inquiries_city#" />
					&nbsp;</td>
			</tr>
			<tr>
				<th>State:</th>
				<td class="table-white"><input name="inquiries_state" type="text" size="20" maxlength="50" value="#form.inquiries_state#" />
					&nbsp;</td>
			</tr>
			<tr>
				<th>Zip Code:</th>
				<td class="table-white"><input name="inquiries_zip" type="text" size="10" maxlength="50" value="#form.inquiries_zip#" />
					&nbsp;</td>
			</tr>
			<tr>
				<th>Country:</th>
				<td class="table-white"><input name="inquiries_country" type="text" size="20" maxlength="50" value="#form.inquiries_country#" />
					&nbsp;</td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">Comments:</th>
				<td><textarea name="inquiries_comments" cols="50" rows="5">#form.inquiries_comments#</textarea></td>
			</tr>
			<!--- <cfif form.inquiries_status_id NEQ 4 and form.inquiries_status_id NEQ 5> --->
				<tr>
					<th>Change Status:</th>
					<td>
						<cfscript>
						db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status 
						WHERE inquiries_status_deleted = #db.param(0)#
						ORDER BY inquiries_status_name ";
						qInquiryStatus=db.execute("qInquiryStatus");
						selectStruct = StructNew();
						selectStruct.name = "inquiries_status_id";
						selectStruct.query = qInquiryStatus;
						selectStruct.queryLabelField = "inquiries_status_name";
						selectStruct.queryValueField = 'inquiries_status_id';
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript>
					</td>
				</tr>
			<!--- </cfif> --->
			<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
				<tr>
					<th>Assign to:</th>
					<td><cfscript>
						userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
						db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
						WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
						user_deleted = #db.param(0)# and
						user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and (user_server_administrator=#db.param(0)# )
						ORDER BY member_first_name ASC, member_last_name ASC ";
						qAgents=db.execute("qAgents");
						selectStruct = StructNew();
						selectStruct.name = "user_id";
						selectStruct.query = qAgents;
						selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
						selectStruct.queryParseLabelVars = true;
						selectStruct.queryValueField = 'user_id';
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript>
						(Optional) </td>
				</tr><!---  --->
				<tr>
					<th style="vertical-align:top;" colspan="2">Office Administrative Comments: (Optional)</th>
				</tr>
				<tr>
					<td colspan="2"><textarea name="inquiries_admin_comments" cols="100" rows="6">#form.inquiries_admin_comments#</textarea></td>
				</tr>

			</cfif>
			<tr>
				<th>&nbsp;</th>
				<td>

	
					<button type="submit" name="submitForm">
					<cfif currentMethod EQ 'add'>
						Add
					<cfelse>
						Update
					</cfif>
					Lead</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#';">Cancel</button></td>
			</tr>
		</table>
	</form>
	</span>
</cffunction>
</cfoutput>
</cfcomponent>
