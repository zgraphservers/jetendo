<cfcomponent>
<cfoutput> 

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("spf_domain", request.zos.zcoreDatasource)# 
	WHERE spf_domain_id= #db.param(application.zcore.functions.zso(form,'spf_domain_id'))# and 
	spf_domain_deleted = #db.param(0)# ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'SPF Domain no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/spf-validation/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 

		form.spf_domain_deleted=0;
		application.zcore.functions.zDeleteRecord("spf_domain", "spf_domain_id,spf_domain_deleted", request.zos.zcoreDatasource);
		if(application.zcore.functions.zso(form, 'returnJson', true, 0) EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'SPF Domain deleted'); 
			application.zcore.functions.zRedirect('/z/server-manager/admin/spf-validation/index?zsid=#request.zsid#');
		}
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this SPF Domain?<br />
			<br />
			Root Domain: #qCheck.spf_domain_name#<br />
			<br />
			<a href="/z/server-manager/admin/spf-validation/delete?confirm=1&amp;spf_domain_id=#form.spf_domain_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/spf-validation/index">No</a> 
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
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true); 

	form.spf_domain_updated_datetime=request.zos.mysqlnow; 
	if(form.method EQ "insert"){ 
		myform={};
		myform.spf_domain_name.required=true; 
		errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
		if(errors){
			application.zcore.status.setStatus(request.zsid, false,form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/spf-validation/add?zsid="&request.zsid);
		} 
	}else if(form.method EQ "update"){
		myform={};
		myform.spf_domain_name.required=true; 
		errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
		if(errors){
			application.zcore.status.setStatus(request.zsid, false,form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/spf-validation/edit?spf_domain_id=#form.spf_domain_id#&zsid="&request.zsid);
		} 
	} 
	ts=StructNew();
	ts.table="spf_domain";
	ts.datasource=request.zos.zcoreDatasource; 
	ts.struct=form;
	 
	if(form.method EQ "insert"){
		form.spf_domain_id=application.zcore.functions.zInsert(ts);
		if(not form.spf_domain_id){ 
			application.zcore.status.setStatus(request.zsid, 'Failed to save SPF Domain.  This domain already exists.',form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/spf-validation/add?spf_domain_id=#form.spf_domain_id#&zsid=#request.zsid#");
		}
		application.zcore.status.setStatus(request.zsid, 'SPF Domain Saved.');
	}else if(application.zcore.functions.zUpdate(ts)){
		application.zcore.status.setStatus(request.zsid, 'SPF Domain Saved.');
	}else{ 
		application.zcore.status.setStatus(request.zsid, 'Failed to update SPF Domain.',form,true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/spf-validation/edit?spf_domain_id=#form.spf_domain_id#&zsid=#request.zsid#");
	}  
	application.zcore.functions.zRedirect("/z/server-manager/admin/spf-validation/index?zsid=#request.zsid#");
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
	var qGroup=0;
	var qSite=0;
	var qin=0;
	form.spf_domain_id=application.zcore.functions.zso(form, 'spf_domain_id');
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager"); 
	backupMethod=form.method; 
	db.sql="SELECT * FROM #db.table("spf_domain", request.zos.zcoreDatasource)#  
	WHERE  
	spf_domain_id = #db.param(form.spf_domain_id)# and 
	spf_domain_deleted = #db.param(0)# ";
	qSPF=db.execute("qSPF");
	if(backupMethod EQ "edit" and qSPF.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"SPF Domain doesn't exist.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/spf-validation/index?zsid=#request.zsid#");
	} 
	tempStruct={};
	application.zcore.functions.zQueryToStruct(qSPF, tempStruct);
	structappend(form, tempStruct, false);
 
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>	
	<p><a href="/z/server-manager/admin/spf-validation/index?sid=#form.sid#">Manage SPF Domains</a> /</p>
	<h2><cfif backupMethod EQ "add">
		Add 
	<cfelse>
		Edit
	</cfif> SPF Domain</h2>
	<form class="zFormCheckDirty" name="editForm" action="/z/server-manager/admin/spf-validation/<cfif backupMethod EQ "add">insert<cfelse>update</cfif>?spf_domain_id=#form.spf_domain_id#" method="post" style="margin:0px;">
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Root Domain:</td>
			<td class="table-white"><input type="text" name="spf_domain_name" value="#htmleditformat(form.spf_domain_name)#" /><br />
			(i.e. domain.com, not www.domain.com)</td>
		</tr> 
		<cfscript>
		arrVendor=listToArray(form.spf_domain_vendor_list, ",");
		vendorStruct={};
		for(i=1;i<=arrayLen(arrVendor);i++){
			vendorStruct[arrVendor[i]]=true;
		}
		</cfscript>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Vendor:</td>
			<td class="table-white">
				Select 1 or more built-in email vendors:<br />
				<input type="checkbox" id="vendor1" name="spf_domain_vendor_list" value="sendgrid" <cfif structkeyexists(vendorStruct, 'sendgrid')><cfscript>structdelete(vendorStruct, 'sendgrid'); </cfscript>checked="checked"</cfif>> <label for="vendor1">Sendgrid</label> 
				<input type="checkbox" id="vendor2" name="spf_domain_vendor_list" value="mailchimp" <cfif structkeyexists(vendorStruct, 'mailchimp')><cfscript>structdelete(vendorStruct, 'mailchimp'); </cfscript>checked="checked"</cfif>> <label for="vendor2">Mailchimp</label> 
				<input type="checkbox" id="vendor3" name="spf_domain_vendor_list" value="mailgun" <cfif structkeyexists(vendorStruct, 'mailgun')><cfscript>structdelete(vendorStruct, 'mailgun'); </cfscript>checked="checked"</cfif>> <label for="vendor3">Mailgun</label> 
				<input type="checkbox" id="vendor4" name="spf_domain_vendor_list" value="google" <cfif structkeyexists(vendorStruct, 'google')><cfscript>structdelete(vendorStruct, 'google'); </cfscript>checked="checked"</cfif>> <label for="vendor4">Google Apps</label>  
				<input type="checkbox" id="vendor5" name="spf_domain_vendor_list" value="yahoo" <cfif structkeyexists(vendorStruct, 'yahoo')><cfscript>structdelete(vendorStruct, 'yahoo'); </cfscript>checked="checked"</cfif>> <label for="vendor5">Yahoo</label>  
				<input type="checkbox" id="vendor6" name="spf_domain_vendor_list" value="rackspace" <cfif structkeyexists(vendorStruct, 'rackspace')><cfscript>structdelete(vendorStruct, 'rackspace'); </cfscript>checked="checked"</cfif>> <label for="vendor6">Rackspace</label>  
				<input type="checkbox" id="vendor7" name="spf_domain_vendor_list" value="outlook" <cfif structkeyexists(vendorStruct, 'outlook')><cfscript>structdelete(vendorStruct, 'outlook'); </cfscript>checked="checked"</cfif>> <label for="vendor7">Outlook365</label> <br /><br />
				<h3>Vendor not listed above or need a custom configuration?</h3>
				Enter a comma separated list of custom SPF phrases to validate:<br />
				<input type="text"  name="spf_domain_vendor_list" value="#htmleditformat(structkeylist(vendorStruct, ", "))#" <cfif structkeyexists(vendorStruct, 'sendgrid')>checked="checked"</cfif>><br />
				I.e. ipv4:1.2.3.4 or include:whitelabel.yourdomain.com
			</td>
		</tr>
		<tr>
			<td class="table-list" style="vertical-align:top; width:120px;">Valid:</td>
			<td class="table-white"><cfscript>
			form.spf_domain_valid=application.zcore.functions.zso(form, 'spf_domain_valid', true, 1);
			echo(application.zcore.functions.zInput_Boolean("spf_domain_valid", form.spf_domain_valid));
			</cfscript></td>
		</tr> 
		<tr>
			<td class="table-list" style="width:120px;">&nbsp;</td>
			<td class="table-white">
			<button type="submit" name="submit" value="Save">Save</button> <button type="button" name="cancel" value="Cancel" onClick="window.location.href = '/z/server-manager/admin/spf-validation/index?sid=#form.sid#';">Cancel</button></td>
		</tr>
	</table>	
	</form>
</cffunction>
 
	

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager"); 
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	db.sql="SELECT * FROM #db.table("spf_domain", request.zos.zcoreDatasource)#   
	WHERE spf_domain_deleted = #db.param(0)# 
	ORDER BY spf_domain_valid ASc, spf_domain_name ASC ";
	qSPF=db.execute("qSPF");
 
	</cfscript> 
	<h2 style="display:inline;">Manage SPF Domains</h2> 
	| <a href="/z/server-manager/admin/spf-validation/add">Add SPF Domain</a> 
	<br /><br /> 
	This list of domains should include all domains for the entire company which are used to send email regardless of whether we host their web site on this system or not.  All domains should have an SPF record defined according to email compliance standards established by all major ISPs.  These domains are validated once per day and the current DNS SPF record is cached at that time.  <br /><br />If you need to run validation manually, use this shell command:<br />
	php #request.zos.installPath#scripts/spf-validation.php<br /><br />
	To validate only the invalid records:<br />
	php #request.zos.installPath#scripts/spf-validation.php onlyinvalid=1

	<br /><br />  Examples of valid SPF TXT records include: <br /><br /> 

	v=spf1 mx ptr include:sendgrid.net include:_spf.google.com ?all<br /> 
	v=spf1 mx ptr include:sendgrid.net include:emailsrvr.com ?all<br /> 
	v=spf1 mx ptr include:sendgrid.net include:_spf.mail.yahoo.com ?all<br /> 
	v=spf1 mx ptr include:sendgrid.net include:spf.protection.outlook.com ?all
	<br /><br /> 
	Be sure not to use the SPF dns record type.  It is not valid with many ISPs<br /><br />
	<cfif qSPF.recordcount EQ 0>
		<p>No SPF Domains added yet.</p>

	<cfelse>
		<table class="table-list">
			<tr>
				<th>SPF Domain</th>
				<th>Current SPF Record</th> 
				<th>MX Record</th>
				<th>Valid</th> 
				<th>Admin</th>
			</tr>
			<cfloop query="qSPF">
				<tr>
					<td><a href="http://#qSPF.spf_domain_name#" target="_blank" <cfif qSPF.spf_domain_valid NEQ 1>style="color:##F00;"</cfif>>#qSPF.spf_domain_name#</a></td>
					<td>#qSPF.spf_domain_dns_record#</td>
					<td>#paragraphformat(qSPF.spf_domain_mx_dns_record)#</td>
					<td><cfif qSPF.spf_domain_valid EQ 1>
						Yes
					<cfelse>
						No
					</cfif>
					</td>
					<td>
						<a href="/z/server-manager/admin/spf-validation/edit?spf_domain_id=#qSPF.spf_domain_id#">Edit</a> | 
						<a href="##" onclick="zDeleteTableRecordRow(this, '/z/server-manager/admin/spf-validation/delete?spf_domain_id=#qSPF.spf_domain_id#&amp;confirm=1&amp;returnJson=1'); return false;">Delete</a>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>