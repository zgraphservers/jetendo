<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var hCom=0;

	if(form.method EQ "userView"){

	}else{
	    application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");
		form.zPageId=application.zcore.functions.zso(form, 'zPageId');
		if(structkeyexists(form, 'inquiries_id') EQ false){
			application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index');
		}
	}
	if(request.cgi_script_name CONTAINS "/z/inquiries/admin/feedback/"){
		hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		hCom.displayHeader();
	}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zRedirect("/z/inquiries/admin/index");
	</cfscript>
</cffunction>

<cffunction name="deleteFeedback" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	variables.init();
	db.sql="SELECT * from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
	WHERE inquiries_feedback_id = #db.param(form.inquiries_feedback_id)# and 
	inquiries_id=#db.param(form.inquiries_id)# and 
	inquiries_feedback_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'Feedback doesn''t exist');
		application.zcore.functions.zRedirect('/z/inquiries/admin/feedback/view?zsid=#request.zsid#&inquiries_id=#form.inquiries_id#');	
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.site_id=request.zos.globals.id;
		application.zcore.functions.zDeleteRecord("inquiries_feedback","inquiries_feedback_id,site_id",request.zos.zcoreDatasource);
		application.zcore.status.setStatus(request.zsid, 'Feedback deleted');
		application.zcore.functions.zRedirect('/z/inquiries/admin/feedback/view?zsid=#request.zsid#&inquiries_id=#form.inquiries_id#');	
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this feedback?<br />
			<br />
			#qCheck.inquiries_feedback_subject# 			<br />
			#qCheck.inquiries_feedback_comments# 			<br />
			<br />
			<a href="/z/inquiries/admin/feedback/deleteFeedback?inquiries_feedback_id=#form.inquiries_feedback_id#&amp;inquiries_id=#form.inquiries_id#&amp;confirm=1">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/feedback/view?inquiries_id=#form.inquiries_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var inputStruct=0;
	var myForm={};
	var qCheck=0;
	var result=0;
	var r=0;
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id', true, 1);
	variables.init();
	db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.user_deleted=#db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))#
	WHERE inquiries.inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_deleted=#db.param(0)# and
	inquiries.site_id = #db.param(request.zos.globals.id)# ";
	qCheck = db.execute("qCheck"); 
	if(form.method EQ "insert"){
		errorReturnURL="/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&zsid=#Request.zsid#&inquiries_id=#form.inquiries_id#";
	}else{
		errorReturnURL="/z/inquiries/admin/manage-inquiries/userView?zPageId=#form.zPageId#&zsid=#Request.zsid#&inquiries_id=#form.inquiries_id#";
	}

	// form validation struct
	myForm.inquiries_id.required = true;
	myForm.inquiries_id.friendlyName = "Inquiry ID";
	myForm.inquiries_feedback_datetime.createDateTime = true;
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true); 
		application.zcore.functions.zRedirect(errorReturnURL); 
	}
	if(form.inquiries_status_id EQ 4 or form.inquiries_status_id EQ 5 or form.inquiries_status_id EQ 7){		
		// ignore validation
	}else if(application.zcore.functions.zso(form, 'inquiries_feedback_comments') EQ '' and application.zcore.functions.zso(form, 'inquiries_feedback_subject') EQ ''){
		application.zcore.status.setStatus(Request.zsid, 'Please type a subject or message in the Add Note form.',form,true); 
		application.zcore.functions.zRedirect(errorReturnURL); 
	
	}
	form.user_id = request.zsession.user.id;
	form.user_id_siteIdType = application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	form.site_id = request.zOS.globals.id;
	
	//	Insert Into Inquiry Database
	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "inquiries_feedback";
	inputstruct.datasource=request.zos.zcoreDatasource;
	form.inquiries_feedback_id = application.zcore.functions.zInsert(inputStruct); 
	if(form.inquiries_feedback_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be updated.", false,true);
		application.zcore.functions.zRedirect(errorReturnURL); 
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead updated.");
		if(structkeyexists(form,'inquiries_status_id') and (form.inquiries_status_id EQ 4 or form.inquiries_status_id EQ 5 or form.inquiries_status_id EQ 7)){								 
		}else if(qCheck.inquiries_status_id EQ 2){
			form.inquiries_status_id=3;		
		}else if(qCheck.inquiries_status_id EQ 1){
			form.inquiries_status_id=6;		
		}else{
			form.inquiries_status_id=3;
		}
		db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries SET 
		inquiries_updated_datetime = #db.param(form.inquiries_feedback_datetime)#, 
		inquiries_status_id = #db.param(form.inquiries_status_id)# 
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)# ";
		r=db.execute("r");
	}
	if(form.user_id NEQ qCheck.user_id and qCheck.user_email NEQ ""){
		if(qCheck.recordcount NEQ 0){
			mail  to="#qCheck.user_email#" from="#request.fromemail#" subject="Your lead has been updated by the administrator."{
writeoutput('The administrator has added feedback to your lead.

Please login in and view your lead by clicking the following link: #request.zos.currentHostName#/z/inquiries/admin/feedback/view?inquiries_id=#form.inquiries_id# Do not reply to this email. ');
			}
		}
	}
	if(form.method EQ "insert"){
		application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid='&request.zsid);
	}else{
		application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid='&request.zsid);
	}
	</cfscript>
</cffunction>

<cffunction name="sendEmail" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var myForm={};
	var qCheck=0;
	var result=0;
	var inputStruct=0;
	var q=0;
	variables.init();
	db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_id = #db.param(form.inquiries_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qCheck = db.execute("qCheck");
	if(qCheck.recordcount EQ 0 or qCheck.inquiries_status_id EQ 4 or qCheck.inquiries_status_id EQ 5 or qCheck.inquiries_status_id EQ 7){
		application.zcore.status.setStatus(Request.zsid, 'This inquiry can no longer be updated.',false,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid=#Request.zsid#");
	}
	form.leadEmailUseSubmission=true;
	// form validation struct
	myForm.inquiries_id.required = true;
	myForm.inquiries_id.friendlyName = "Inquiry ID";
	myForm.lead_email_from.required = true;
	myForm.lead_email_from.email=true;
	myForm.lead_email_to.required = true;
	myForm.lead_email_to.email=true;
	myForm.lead_email_bcc.allownull = true;
	myForm.lead_email_bcc.email=true;
	myForm.lead_email_subject.required = true;
	myForm.lead_email_subject.allownull = false;
	myForm.lead_email_message.required = true;
	myForm.inquiries_feedback_datetime.createDateTime = true;
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&zsid=#Request.zsid#&inquiries_id=#form.inquiries_id#");
	}
	form.user_id = request.zsession.user.id;
	form.site_id = request.zOS.globals.id;
	
	form.inquiries_feedback_from=form.lead_email_from;
	form.inquiries_feedback_to=form.lead_email_to;
	form.inquiries_feedback_bcc=form.lead_email_bcc;
	form.inquiries_feedback_subject=form.lead_email_subject;
	form.inquiries_feedback_comments=form.lead_email_message;
	
	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "inquiries_feedback";
	inputstruct.datasource=request.zos.zcoreDatasource;
	form.inquiries_feedback_id = application.zcore.functions.zInsert(inputStruct); 
	if(form.inquiries_feedback_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Email send failed.", form,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&zsid=#request.zsid#&inquiries_id=#form.inquiries_id#");
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Email sent.");
		if(qCheck.inquiries_status_id EQ 2){
			form.inquiries_status_id=3;		
		}else if(qCheck.inquiries_status_id EQ 1){
			form.inquiries_status_id=6;		
		}else{
			form.inquiries_status_id=3;
		}
		db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries SET 
		inquiries_updated_datetime = #db.param(form.inquiries_feedback_datetime)#, 
		inquiries_status_id = #db.param(form.inquiries_status_id)# 
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)#";
		q=db.execute("q");
	}
	mail to="#form.lead_email_to#" from="#form.lead_email_from#" bcc="#form.lead_email_bcc#" subject="#form.lead_email_subject#"{
		writeoutput(form.lead_email_message);
	}
	application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid='&request.zsid);
	</cfscript>
</cffunction>

<cffunction name="view" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.1.1"); 
	if(application.zcore.functions.zso(form, 'inquiries_id') EQ ''){
		if(form.method EQ "userView"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex");
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index");
		}
	}
	inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");

	db.sql="SELECT *, if(inquiries.inquiries_status_id IN #db.trustedSQL("('4','5', '7'),1,0")#) closed 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status
	ON inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	inquiries_status_deleted = #db.param(0)#
	WHERE inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#";
	if(form.method EQ "userView"){
	    db.sql&=inquiriesCom.getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, 'administrator') EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
	}
	qInquiry=db.execute("qInquiry");
	if(qinquiry.recordcount EQ 0){		
		request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
		if(form.method EQ "userView"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
		}
	}
	application.zcore.functions.zQueryToStruct(qInquiry, form);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>

	<div class="z-float">
		<div class="z-3of5 z-ph-0">
		<!--- <cfif form.closed EQ 0> --->
			<!--- <table style="width:100%; border-spacing:0px;">
			<tr>
			<td style="vertical-align:top; width:70%;padding-left:0px;"> --->
		<!--- </cfif> --->
		<cfscript>
		var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
		hCom.view(); 
		</cfscript>
		</div>
		<div class="z-2of5 z-ph-0">
		<!--- <td style="vertical-align:top; width:30%;padding-left:10px; padding-right:0px;"> --->
			<cfsavecontent variable="db.sql"> SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_id = #db.param(request.zsession.user.id)# and 
			#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL("user", request.zos.globals.id))# and 
			user_server_administrator=#db.param('0')# and 
			user_deleted = #db.param(0)# </cfsavecontent>
			<cfscript>
			qAgent=db.execute("qAgent");
			</cfscript>
			<cfsavecontent variable="db.sql"> 
			SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template
			LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
			inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
			inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# and 
			inquiries_lead_template_x_site_deleted = #db.param(0)#
			WHERE inquiries_lead_template_x_site.site_id IS NULL and
			inquiries_lead_template_deleted = #db.param(0)# and  
			inquiries_lead_template_type = #db.param('2')# and 
			inquiries_lead_template.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#)
			<cfif application.zcore.app.siteHasApp("listing") EQ false>
				and inquiries_lead_template_realestate = #db.param('0')#
			</cfif>
			ORDER BY inquiries_lead_template_sort ASC, inquiries_lead_template_name ASC </cfsavecontent>
			<cfscript>
			qTemplate=db.execute("qTemplate");

			</cfscript>
			<!--- <h2 style="display:inline;">
			Send Email
			<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
				|
				</h2>
				<a href="/z/inquiries/admin/lead-template/index">Edit Templates</a> | 
				<a href="/z/inquiries/admin/lead-template/add?inquiries_lead_template_type=2&amp;siteIDType=1">Add Email Template</a>
			<cfelse>
				</h2>
			</cfif>
			<br />
			<br />
			<cfscript>
			tags=StructNew();
			</cfscript>
			<cfif qAgent.recordcount NEQ 0>
				<cfif qAgent.member_signature NEQ ''>
					<cfset signature=qAgent.member_signature>
				<cfelse>
					<cfsavecontent variable="signature">#qAgent.member_first_name# #qAgent.member_last_name##chr(10)##qAgent.member_title##chr(10)##qAgent.member_phone##chr(10)##qAgent.member_website#</cfsavecontent>
				</cfif>
				<cfscript>
				tags['{agent name}']=qAgent.member_first_name&' '&qAgent.member_last_name;
				tags["{agent's company}"]=qAgent.member_company;
				</cfscript>
			<cfelse>
				<cfset signature="">
			</cfif>
			<script type="text/javascript">
			/* <![CDATA[ */
			var arrEmailTemplate=[];
			var greeting="#JSStringFormat('Hello '&trim(application.zcore.functions.zFirstLetterCaps(form.inquiries_first_name))&','&chr(10)&chr(10)&chr(9))#";
			<cfloop query="qTemplate">
				<cfscript>
				tm=qTemplate.inquiries_lead_template_message;
				for(i in tags){
					tm=replaceNoCase(tm,i,tags[i],'ALL');
				}
				</cfscript>
			arrEmailTemplate[#qTemplate.inquiries_lead_template_id#]={};
			arrEmailTemplate[#qTemplate.inquiries_lead_template_id#].subject="#jsstringformat(qTemplate.inquiries_lead_template_subject)#";
			arrEmailTemplate[#qTemplate.inquiries_lead_template_id#].message="#jsstringformat(tm)#";
			</cfloop>
			<cfscript>
			originalMessage=inquiryHTML;
			// remove admin comments
			originalMessage=rereplace(originalMessage,"<!-- startadmincomments -->.*?<!-- endadmincomments -->","","ALL");
			links="";
			badTagList="style|link|head|script|embed|base|input|textarea|button|object|iframe|form";
			originalMessage=rereplacenocase(originalMessage,"<(#badTagList#)[^>]*?>.*?</\1>", " ", 'ALL');			
			//originalMessage=rereplacenocase(originalMessage,"<a.*?href=""(.*)?"".*?>.*?</a>", " \1 ", 'ALL');	
			originalMessage=rereplacenocase(originalMessage,"<a.*?>(.*)?</a>", " \1 ", 'ALL');
			originalMessage=replacenocase(originalMessage,"last 2 pages:", " ", 'ALL');
			originalMessage=replacenocase(originalMessage,chr(10), " ", 'ALL');
			originalMessage=replacenocase(originalMessage,chr(13), "", 'ALL');
			originalMessage=replacenocase(originalMessage,chr(9), " ", 'ALL');
			originalMessage=replacenocase(originalMessage,"</tr>",chr(10),"ALL");
			originalMessage=rereplacenocase(originalMessage," +", " ", 'ALL');
			originalMessage=replacenocase(originalMessage,"| |", " ", 'ALL');
			
			originalMessage=rereplacenocase(originalMessage,"<.*?>", " ", 'ALL');
			originalMessage=rereplacenocase(originalMessage,"&[^\s]*?;", " ", 'ALL');
			originalMessage=replacenocase(originalMessage,"&nbsp;"," ","ALL");
			originalMessage=replacenocase(originalMessage,chr(10)&chr(10),chr(10),"ALL");
			if(form.inquiries_referer NEQ "" or form.inquiries_referer2 NEQ ""){
				originalMessage&=chr(10)&"Last 2 Pages Visited: "&chr(10)&form.inquiries_referer&chr(10)&chr(10)&form.inquiries_referer2;
			}
			arrM=listtoarray(originalMessage,chr(10),true);
			for(i=1;i LTE arrayLen(arrM);i++){
				arrM[i]=trim(arrM[i]);
			}
			originalMessage=arraytolist(arrM,chr(10));
			// put the full original message here with 
			originalMessage=chr(10)&chr(10)&"----------------------"&chr(10)&"This message was in response your original inquiry ###form.inquiries_id#:"&chr(10)&chr(10)&(originalMessage);
			</cfscript>
			var originalMessage="#jsstringformat(originalMessage)#";
			var signature="#jsstringformat(chr(10)&chr(10)&'---------------------------------------'&chr(10)&trim(signature))#";
			function updateEmailForm(v){
				if(v!=""){
					document.myForm2.lead_email_subject.value=arrEmailTemplate[v].subject;
					document.myForm2.lead_email_message.value=greeting+arrEmailTemplate[v].message+signature+originalMessage;
				}else{
					document.myForm2.lead_email_subject.value="";
					document.myForm2.lead_email_message.value=greeting+signature+originalMessage;
				}
			}
			/* ]]> */
			</script>
			<table class="table-list" style="width:100%; border-left:2px solid ##999;border-right:1px solid ##999;">
				<form class="zFormCheckDirty" name="myForm2" id="myForm2" action="/z/inquiries/admin/feedback/sendemail?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post">
					<tr>
						<th colspan="2"> Select a template or fill in the following fields:</th>
					</tr>
					<tr>
						<td style="width:100px;">Template:</td>
						<td><cfscript>
						selectStruct = StructNew();
						selectStruct.name = "inquiries_lead_template_id";
						selectStruct.query = qTemplate;
						selectStruct.onChange="updateEmailForm(this.options[this.selectedIndex].value);";
						selectStruct.queryLabelField = "inquiries_lead_template_name";
						selectStruct.queryValueField = 'inquiries_lead_template_id';
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript></td>
					</tr>
					<tr>
						<td>From:</td>
						<td><input name="lead_email_from" id="lead_email_from" type="text" size="50" maxlength="50" value="<cfif application.zcore.functions.zso(form, 'lead_email_from') NEQ ''>#form.lead_email_from#<cfelseif qagent.recordcount NEQ 0>#qagent.member_email#</cfif>" /></td>
					</tr>
					<tr>
						<td>To:</td>
						<td><input name="lead_email_to" id="lead_email_to" type="text" size="50" maxlength="50" value="<cfif application.zcore.functions.zso(form, 'lead_email_to') NEQ ''>#form.lead_email_to#<cfelse>#form.inquiries_email#</cfif>" /></td>
					</tr>
					<tr>
						<td>Bcc:</td>
						<td><input name="lead_email_bcc" id="lead_email_bcc" type="text" size="50" maxlength="50" value="#application.zcore.functions.zso(form, 'lead_email_bcc')#" / /></td>
					</tr>
					<tr>
						<td>Subject:</td>
						<td><input name="lead_email_subject" id="lead_email_subject" type="text" size="50" maxlength="50" value="#application.zcore.functions.zso(form, 'lead_email_subject')#" /></td>
					</tr>
					<tr>
						<td colspan="2">Message:<br />
							<textarea name="lead_email_message" id="lead_email_message" style="width:98%; height:200px; ">#application.zcore.functions.zso(form, 'lead_email_message')#</textarea></td>
					</tr>
					<tr>
						<td colspan="2"><button type="submit" name="submitForm">Send Email</button>
							<button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#';">Cancel</button></td>
					</tr>
				</form>
			</table>
			<script type="text/javascript">
			/* <![CDATA[ */<cfif application.zcore.functions.zso(form, 'leadEmailUseSubmission') EQ ''>
			updateEmailForm('');
			</cfif>/* ]]> */
			</script> 
			<br /> --->
			<cfif qagent.recordcount NEQ 0>
				<cfsavecontent variable="signature">#qAgent.member_first_name# #qAgent.member_last_name##chr(10)##qAgent.member_title##chr(10)##qAgent.member_phone##chr(10)##qAgent.member_website#</cfsavecontent>
				<cfscript>
				tags=StructNew();
				tags['{agent name}']=qAgent.member_first_name&' '&qAgent.member_last_name;
				tags["{agent's company}"]=qAgent.member_company;
				</cfscript>
			<cfelse>
				<cfset tags=structnew()>
				<cfset signature="">
			</cfif>
			<cfsavecontent variable="db.sql"> SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template
			LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
			inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
			inquiries_lead_template_x_site_deleted = #db.param(0)# and 
			inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# 
			WHERE inquiries_lead_template_x_site.site_id IS NULL and 
			inquiries_lead_template_deleted = #db.param(0)# and 
			inquiries_lead_template_type = #db.param('1')# and 
			inquiries_lead_template.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#)
			<cfif application.zcore.app.siteHasApp("listing") EQ false>
				and inquiries_lead_template_realestate = #db.param('0')#
			</cfif>
			ORDER BY inquiries_lead_template_sort ASC, inquiries_lead_template_name ASC </cfsavecontent>
			<cfscript>
			qTemplate=db.execute("qTemplate");
			</cfscript>
			<script type="text/javascript">
			/* <![CDATA[ */
			var arrNoteTemplate=[];
			<cfloop query="qTemplate">
				<cfscript>
				tm=qTemplate.inquiries_lead_template_message;
				for(i in tags){
					tm=replaceNoCase(tm,i,tags[i],'ALL');
				}
				</cfscript>
			arrNoteTemplate[#qTemplate.inquiries_lead_template_id#]={};
			arrNoteTemplate[#qTemplate.inquiries_lead_template_id#].subject="#jsstringformat(qTemplate.inquiries_lead_template_subject)#";
			arrNoteTemplate[#qTemplate.inquiries_lead_template_id#].message="#jsstringformat(tm)#";
			</cfloop>
			function updateNoteForm(v){
				if(v!=""){
					document.myForm.inquiries_feedback_subject.value=arrNoteTemplate[v].subject;
					document.myForm.inquiries_feedback_comments.value=arrNoteTemplate[v].message;
				}else{
					document.myForm.inquiries_feedback_subject.value='';
					document.myForm.inquiries_feedback_comments.value='';
				}
			}
			/* ]]> */
			</script>
			
			<div style="" class="z-inquiry-note-box">
				<h2 style="display:inline;">
				Add Note
				<cfif application.zcore.user.checkGroupAccess("administrator")>
					|
					</h2>
					<a href="/z/inquiries/admin/lead-template/index">Edit Templates</a> | 
					<a href="/z/inquiries/admin/lead-template/add?inquiries_lead_template_type=1&amp;siteIDType=1">Add Note Template</a>
				<cfelse>
					</h2>
				</cfif>
				<br />
				<br />
				<cfsavecontent variable="db.sql"> SELECT * from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
				WHERE inquiries_id = #db.param(form.inquiries_id)# and 
				inquiries_feedback_id = #db.param(application.zcore.functions.zso(form, 'inquiries_feedback_id',false,''))# and 
				site_id = #db.param(request.zos.globals.id)# and 
				inquiries_feedback_deleted=#db.param(0)#</cfsavecontent>
				<cfscript>
				qFeedback=db.execute("qFeedback");
				application.zcore.functions.zQueryToStruct(qFeedback,form,'inquiries_id');
				</cfscript>
				<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/inquiries/admin/<cfif form.method EQ "userView">manage-inquiries/userInsertStatus<cfelse>feedback/insert</cfif>?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post">
					<table class="table-list" style="width:100%; ">
						<tr>
							<th colspan="2"> Select a template or fill in the following fields:</th>
						</tr>
						<tr>
							<td style="width:100px;">Template:</td>
							<td><cfscript>
							selectStruct = StructNew();
							selectStruct.name = "inquiries_lead_template_id";
							selectStruct.query = qTemplate;
							selectStruct.onChange="updateNoteForm(this.options[this.selectedIndex].value);";
							selectStruct.queryLabelField = "inquiries_lead_template_name";
							selectStruct.queryValueField = 'inquiries_lead_template_id';
							application.zcore.functions.zInputSelectBox(selectStruct);
							</cfscript></td>
						</tr>
						<tr>
							<td>Subject:</td>
							<td><input name="inquiries_feedback_subject" id="inquiries_feedback_subject" type="text" maxlength="50" value="" style="min-width:100%; width:100%; max-width:100%;" /></td> 
						</tr>
						<tr>
							<td colspan="2">Message:<br />
								<textarea name="inquiries_feedback_comments" id="inquiries_feedback_comments" style="width:98%; height:120px; min-width:100%; max-width:100%; ">#form.inquiries_feedback_comments#</textarea></td>
						</tr>
						<tr>
							<td colspan="2">Change lead status:<br />
								<!--- <input type="radio" name="inquiries_status_id" value="1" class="input-plain" <cfif form.inquiries_status_id EQ 1>checked="checked"</cfif>>
								New
								<input type="radio" name="inquiries_status_id" value="2" class="input-plain" <!--- <cfif form.inquiries_status_id EQ 2>checked="checked"</cfif> --->>
								Assigned --->
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id3" value="3" class="input-plain" <cfif form.inquiries_status_id EQ 2 or application.zcore.functions.zso(form, 'inquiries_status_id',false,3) EQ 3>checked="checked"</cfif>>
									<label for="inquiries_status_id3">Contacted</label>
								</div>
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id4" value="4" class="input-plain" <cfif application.zcore.functions.zso(form, 'inquiries_status_id') EQ 4>checked="checked"</cfif>>
									<label for="inquiries_status_id4">Closed with No Sale</label>
								</div>
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id5" value="5" class="input-plain"<cfif application.zcore.functions.zso(form, 'inquiries_status_id') EQ 5>checked="checked"</cfif>>
									<label for="inquiries_status_id5">Closed with Sale</label>
								</div>
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id7" value="7" class="input-plain"<cfif application.zcore.functions.zso(form, 'inquiries_status_id') EQ 7>checked="checked"</cfif>>
									<label for="inquiries_status_id7">Spam/Fake</label>
								</div>
								 </td>
						</tr>
						<tr>
							<td colspan="2"><button type="submit" name="submitForm">Add Note</button>
								<button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/manage-inquiries/<cfif form.method EQ "userView">userIndex<cfelse>index</cfif>?zPageId=#form.zPageId#';">Cancel</button></td>
						</tr>
					</table>
				</form>
			</div>
		</div><!--- 
		</td>
		</tr>
		</table>  --->
	</div> 
	<cfif form.inquiries_email NEQ "">
		<cfscript>
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_email = #db.param(form.inquiries_email)# and 
		inquiries_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		if(form.method EQ "userView"){
	    	db.sql&=inquiriesCom.getUserLeadFilterSQL(db);
		}else if(structkeyexists(request.zos.userSession.groupAccess, 'administrator') EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
			db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
		}
		db.sql&=" ORDER BY inquiries_id DESC ";
		qOther=db.execute("qOther");

		db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# ";
		qstatus=db.execute("qstatus");
		statusName=structnew();
		loop query="qstatus"{
			statusName[qstatus.inquiries_status_id]=qstatus.inquiries_status_name;
		}
		</cfscript>
		<cfif qOther.recordcount GTE 2>
			<h2>Other inquiries from this email address</h2>
			<table class="table-list" style="border-spacing:0px; width:100%; font-size:11px; border:1px solid ##CCCCCC;">
				<tr>
					<td>Date</td>
					<td class="z-hide-at-767">Comments</td>
					<td>Assigned To</td>
					<td>Admin</td>
				<cfloop query="qOther">
					<cfscript>
					savecontent variable="local.assignedHTML"{
						currentStatusName = application.zcore.functions.zso(statusName, qOther.inquiries_status_id, false, 'Unknown Status');
						if(qOther.user_id NEQ 0){
							db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user
							WHERE user_id = #db.param(qOther.user_id)# and 
							site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL(qOther.user_id_siteIDType))# and 
							user_deleted=#db.param(0)# ";
							local.qUserTemp=db.execute("qUserTemp");
							if(local.qUserTemp.recordcount NEQ 0){
								if(local.qUserTemp.user_first_name NEQ ""){
									echo(replace(currentStatusName, 'Assigned', 'Assigned to <a href="mailto:#local.qUserTemp.user_username#">#local.qUserTemp.user_first_name# #local.qUserTemp.user_last_name#</a>'));
								}else{
									echo(replace(currentStatusName, 'Assigned', 'Assigned to <a href="mailto:#local.qUserTemp.user_username#">#local.qUserTemp.user_username#</a>'));
								}
							}
						}else{
							writeoutput('#qOther.inquiries_assign_name# #qOther.inquiries_assign_email# ');
						}
					}
					</cfscript>
				<cfif qOther.inquiries_id EQ form.inquiries_id>
					<tr class="zCurrentInquiry">
						<td>#DateFormat(qOther.inquiries_datetime, "m/dd/yyyy")#</td>
						<td class="z-hide-at-767">Current Inquiry</td>
						<td>#local.assignedHTML#</td>
						<td>&nbsp;</td>
					</tr>
				<cfelse>
					<tr style="<cfif qOther.currentrow mod 2 EQ 0>background-color:##ECECEC;</cfif>">
						<td style="border-bottom:1px solid ##CCCCCC;width:80px;">#DateFormat(qOther.inquiries_datetime, "m/dd/yyyy")#</td>
						<td class="z-hide-at-767" style="border-bottom:1px solid ##CCCCCC;">
							<cfscript>
							cm2=qOther.inquiries_comments;
							cm2=trim(rereplace(cm2,"<[^>]*?>"," ","ALL"));
							if(cm2 NEQ ""){
								writeoutput(left(cm2,350));
								if(len(cm2) GT 350){
									writeoutput("...");
								}
							}
							</cfscript>&nbsp;</td>
						<td style="border-bottom:1px solid ##CCCCCC;">
						#local.assignedHTML#
						</td>
						<td style="border-bottom:1px solid ##CCCCCC; ">
							<cfscript>
							if(form.method EQ "userView"){
								echo('<a href="/z/inquiries/admin/manage-inquiries/userView?zPageId=#form.zPageId#&amp;zsid=#request.zsid#&amp;inquiries_id=#qOther.inquiries_id#">View</a>');
							}else{
								echo('<a href="/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&amp;zsid=#request.zsid#&amp;inquiries_id=#qOther.inquiries_id#">View</a>');
							}
							</cfscript>
						</td>
					</tr>
				</cfif>
				</cfloop>
			</table>
		</cfif>
	</cfif> 
	<cfscript>
	db.sql="SELECT * from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries_feedback.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_feedback.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE 
	inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_feedback.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_feedback_deleted=#db.param(0)# 
	ORDER BY inquiries_feedback_datetime DESC ";
	qFeedback=db.execute("qFeedback");
	</cfscript>
	<cfif qFeedBack.recordcount NEQ 0>
		<hr />
		<h2>Emails &amp; Notes</h2>
		<table class="table-list">
			<cfloop query="qFeedback">
				<cfif qFeedback.inquiries_feedback_subject NEQ ''>
					<tr>
						<td style="border:1px solid ##999999; background-color:##EFEFEF; ">#qFeedback.inquiries_feedback_subject#</td>
					</tr>
				</cfif>
				<cfif qFeedback.inquiries_feedback_comments NEQ ''>
					<tr>
						<td style=" border:1px solid ##999999;">#application.zcore.functions.zParagraphFormat(qFeedback.inquiries_feedback_comments)#</td>
					</tr>
				</cfif>
				<tr>
					<td style="border:1px solid ##999999; border-top:0px; ">By <a href="mailto:#qFeedback.user_email#">#qFeedback.user_first_name# #qFeedback.user_last_name#</a> on 
					#DateFormat(qFeedback.inquiries_feedback_datetime, 'm/d/yyyy')&' at '&TimeFormat(qFeedback.inquiries_feedback_datetime, 'h:mm tt')#
					<cfif form.method EQ "view">
	
						 | 
						<a href="/z/inquiries/admin/feedback/deleteFeedback?inquiries_feedback_id=#qFeedback.inquiries_feedback_id#&amp;inquiries_id=#qFeedback.inquiries_id#">Delete</a>
					</cfif>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
