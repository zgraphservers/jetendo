<cfcomponent>
<cfoutput>
<!--- 

// TODO: possibly support file attachments someday.  We would need to protect it slightly from abuse through size and file type filters.
 --->

<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	application.zcore.functions.zSetModalWindow(); 
	// decided i shouldn't call init
	//feedbackCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
	//feedbackCom.init();



	form.contact_id=application.zcore.functions.zso(form, 'contact_id');
	form.inquiries_from=application.zcore.functions.zso(form, 'inquiries_from');
	form.inquiries_to=application.zcore.functions.zso(form, 'inquiries_to');
	form.inquiries_bcc=application.zcore.functions.zso(form, 'inquiries_bcc');
	form.inquiries_cc=application.zcore.functions.zso(form, 'inquiries_cc');
	form.inquiries_subject=application.zcore.functions.zso(form, 'inquiries_subject');
	form.inquiries_message=application.zcore.functions.zso(form, 'inquiries_message'); 

	// convert the to/cc/bcc addresses to contact id if they aren't already.


	variables.contactCom=createobject("component", "zcorerootmapping.com.app.contact");
	variables.contact = variables.contactCom.getContactById(form.contact_id, request.zos.globals.id);
	if(structcount(variables.contact) EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid contact selected.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/manage-contact/index?zsid=#request.zsid#");
	}

	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id', true, 0);

	variables.manageInquiryCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	if(form.method EQ "userSend" or form.method EQ "userIndex"){
		variables.manageInquiryCom.userInit();
	}

	if(form.inquiries_id EQ 0){
		// ok to add lead
	}else{

		// test if user has access to inquiries_id
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)# ";
		if(form.method EQ "userSend"){ 
			db.sql&=variables.manageInquiryCom.getUserLeadFilterSQL(db); 
		}
		variables.qCheck = db.execute("qCheck");
		if(variables.qCheck.recordcount EQ 0 or variables.qCheck.inquiries_status_id EQ 4 or variables.qCheck.inquiries_status_id EQ 5 or variables.qCheck.inquiries_status_id EQ 7){
			echo('<h2>This inquiry can no longer be updated.</h2>
			<p>Closing this window in 3 seconds.</p>
				<script type="text/javascript">
			zArrDeferredFunctions.push(function(){
				setTimeout(function(){
					window.parent.zCloseModal();
				}, 3000);
			});
			</script>');
			return false;
		}
	}
	return true;
	</cfscript>
</cffunction>


<cffunction name="userSend" localmode="modern" access="remote" roles="user">
	<cfscript>
	send();
	</cfscript>
</cffunction>

<cffunction name="send" localmode="modern" access="remote" roles="member">
	<cfscript>
	result=init(); 
	if(not result){
		return;
	}
	debug=false;

	form.inquiries_from = form.inquiries_from;
	db 			= request.zos.queryObject;
	myForm		= {};
	qCheck		= 0;
	result		= 0;
	inputStruct = 0;
	q=0;   
	myForm.inquiries_subject.required = true; 
	myForm.inquiries_message.required = true; 
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.status.displayReturnJson(request.zsid); 
	} 
	form.site_id = request.zOS.globals.id; 
	form.user_id=request.zsession.user.id;
	form.user_id_siteidtype=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	if(debug){
	 	writedump(request.zsession.user);
		writedump(form);
	}

 	if(request.zsession.user.first_name&request.zsession.user.last_name EQ ""){
		name=request.zsession.user.email;
	}else{
		name=request.zsession.user.first_name&' '&request.zsession.user.last_name;
	} 
	savecontent variable="customNote"{ 
		echo('<p>#name# replied to lead ###form.inquiries_id#:</p>
		<h3>#form.inquiries_subject#</h3>
		#form.inquiries_message#');
	}

	if(application.zcore.functions.zvar("enablePlusEmailRouting", request.zos.globals.id, 0) EQ 1){
		// this should be happening on live server when the new lead interface is all done
		request.noleadsystemlinks=true;
	} 
	backupForm=duplicate(form);
	savecontent variable="emailHTML"{
		iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	    iemailCom.getEmailTemplate(customNote, false);
	} 
	// need this for compose message since there is no inquiries record yet
	structappend(form, backupForm, true);
	ts={  
		contact_id:request.zsession.user.contact_id,  
		debug:false,
		inquiries_id:form.inquiries_id,
		privateMessage:false,
		enableCopyToSelf:true, 
		validHash:true, 
		jsonStruct:{
		   "headers":{
		      "raw":"",
		      "parsed":{ 
		      }
		   },
		   "from":{
		      "name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
		      "email":request.zsession.user.email
		   },
		   "to":[
		      {
		         "name":variables.contact.contact_first_name&" "&variables.contact.contact_last_name,
		         "email":variables.contact.contact_email,
		         "plusId":"",
		         "originalEmail":variables.contact.contact_email
		      }
		   ],
		   "cc":[],
		   "bcc":[],
		   "subject":form.inquiries_subject,
		   "html":emailHTML,
		   "htmlWeb":form.inquiries_message,
		   "files":[/*
		      {
		         "size":2715,
		         "filePath":"elkdgjicjkbkdbjf2.jpg",
		         "fileName":"elkdgjicjkbkdbjf.jpg"
		      }*/
		   ],
		   "plusId":"", // nothing for internal mail
		   "size":0, // measure below
		   "date":request.zos.mysqlnow,
		   "version":1,
		   "humanReplyStruct":{
		      "isHumanReply":true,
		      "humanTriggers":[],
		      "roboScore":0,
		      "roboTriggers":[],
		      "score":1,
		      "humanScore":1
		   },
			"htmlProcessed":""
		},
		messageStruct:{
			site_id:request.zos.globals.id
		}
	};

	ts2={
		inquiries_to:"to",
		inquiries_cc:"cc",
		inquiries_bcc:"bcc"
	};
	fail=false;
	for(field in ts2){
		if(form[field] NEQ ""){
			arrTemp=listToArray(form[field], ",");
			for(email in arrTemp){
				arrEmail=listToArray(email, "`");
				ts3={
					name:"",
					plusId:""
				};
				if(arrayLen(arrEmail) EQ 2){
					ts3.name=arrEmail[1];
					ts3.email=arrEmail[2];
				}else{
					ts3.email=email;
				}
				if(not application.zcore.functions.zEmailValidate(ts3.email)){
					application.zcore.status.setStatus(request.zsid, '"#ts3.email#" is not a valid email address', form, true);
					fail=true;
				}
				ts.originalEmail=email; 
				arrayAppend(ts.jsonStruct[ts2[field]], ts3);
			}
		}
	} 
	if(fail){
		application.zcore.status.displayReturnJson(request.zsid);
	}
	if(form.inquiries_id EQ 0){
		// store new inquiries_id with very basic information and no lead routing alerts.
		ts3={ 
			inquiries_first_name:variables.contact.contact_first_name,
			inquiries_last_name:variables.contact.contact_last_name,
			inquiries_phone1:variables.contact.contact_phone1,
			contact_id:form.contact_id,

			inquiries_type_id:19, // type: Email
			inquiries_type_id_siteIdType:4, 

			user_id:form.user_id,
			user_id_siteidtype:form.user_id_siteidtype, 

			inquiries_email:variables.contact.contact_email,
			inquiries_status_id:3,
			inquiries_datetime:request.zos.mysqlnow,
			inquiries_updated_datetime:request.zos.mysqlnow, 
			site_id:request.zos.globals.id,
			inquiries_priority:5
		}; 
		if(structkeyexists(request.zsession, 'selectedOfficeId')){
			ts3.office_id = request.zsession.selectedOfficeId;
		}
		if(debug){
			writedump(ts3); 
		}else{
			form.inquiries_id=application.zcore.functions.zImportLead(ts3); 

			if(form.inquiries_id EQ false){
				application.zcore.status.setStatus(request.zsid, "Failed to send email. Please try again later.", form, true);
				application.zcore.status.displayReturnJson(request.zsid);
			}
			ts.inquiries_id=form.inquiries_id
		}
	}

	if(debug){
		writedump(ts);
		abort;
	}

	ts.jsonStruct.size=len(ts.jsonStruct.subject&ts.jsonStruct.html);  
	ts.filterContacts={};
	rs=variables.contactCom.processMessage(ts);
	if(not rs.success){
		// TODO: might want to delete the lead that was just inserted if the emails never went out to avoid clutter / confusion.  Be sure not to delete existing leads though.
		application.zcore.status.setStatus(request.zsid, "Failed to send email. Please try again later.", form, true);
		application.zcore.status.displayReturnJson(request.zsid);
	}
 
	application.zcore.status.setStatus(request.zsid, "Email sent");
	if(form.method EQ "send"){
		application.zcore.functions.zReturnJson({success:true, redirect:1, redirectLink:"/z/inquiries/admin/manage-inquiries/index?zsid=#request.zsid#"});
	}else{
		application.zcore.functions.zReturnJson({success:true, redirect:1, redirectLink:"/z/inquiries/admin/manage-inquiries/userIndex?zsid=#request.zsid#"});
	}
	</cfscript>
</cffunction> 

<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript> 
	index();
	</cfscript>
</cffunction>



<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
	result=init(); 
	if(not result){
		return;
	}
	db=request.zos.queryObject;  
 
	tags=StructNew(); 
	signature="";
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(request.zsession.user.id)# and 
	site_id=#db.param(request.zsession.user.site_id)# and	 
	user_deleted = #db.param(0)# ";
	qAgent=db.execute("qAgent"); 

	db.sql="SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
	inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
	inquiries_lead_template_x_site_siteidtype=#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_lead_template.site_id"))# and  
	inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_lead_template_x_site_deleted = #db.param(0)#
	WHERE inquiries_lead_template_x_site.site_id IS NULL and
	inquiries_lead_template_deleted = #db.param(0)# and  
	inquiries_lead_template_type = #db.param('2')# and 
	inquiries_lead_template.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) ";
	if(application.zcore.app.siteHasApp("listing") EQ false){
		db.sql&=" and inquiries_lead_template_realestate = #db.param('0')# ";
	}
	db.sql&=" ORDER BY inquiries_lead_template_sort ASC, inquiries_lead_template_name ASC ";
	qTemplate=db.execute("qTemplate"); 
 
	if(qagent.recordcount NEQ 0){
		savecontent variable="signature"{
			if(qAgent.member_signature NEQ ""){
				echo(qAgent.member_signature); 
			}else{
				echo('#request.zsession.user.first_name# #request.zsession.user.last_name#<br>');
				if(qAgent.member_title NEQ ""){
					echo('#qAgent.member_title#<br>');
				}
				if(qAgent.member_company NEQ ""){
					echo('#qAgent.member_company#<br>');
				}
				if(qAgent.member_phone NEQ ""){
					echo('#qAgent.member_phone#<br>');
				}
				if(request.zsession.user.email NEQ ""){
					echo('#request.zsession.user.email#<br>');
				}
				if(qAgent.member_website NEQ ""){
					echo('#qAgent.member_website#<br>');
				}
			}
		}
		tags=StructNew();
		tags['{agent name}']="#request.zsession.user.first_name# #request.zsession.user.last_name#";
		tags["{agent's company}"]=qAgent.member_company;
	}else{
		tags=structnew();
		signature="";
	}  
	// TODO: might need to have some or all of the inquiry details in the reply someday.
	originalMessage="";//inquiryHTML;
	// remove admin comments
	/*
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
	*/
	// put the full original message here with 
	defaultSubject="";
	if(form.inquiries_id NEQ 0){
		originalMessage="<br><br>This message was in response to lead ###form.inquiries_id#.<br><br>"&originalMessage;

		// get lead type of inquiry
		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE inquiries_type_deleted=#db.param(0)# and 
		inquiries_type_id=#db.param(variables.qCheck.inquiries_type_id)# and 
		site_id=#db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(variables.qCheck.inquiries_type_id_siteidtype))# ";
		qType=db.execute("qType");
		if(qType.recordcount NEQ 0){
			defaultSubject="RE: #qType.inquiries_type_name# submission on #request.zos.globals.shortDomain#";
		}else{
			defaultSubject="RE: Your submission on #request.zos.globals.shortDomain#";
		} 
	}else{
		originalMessage="";
	}
	if(form.inquiries_subject EQ ""){
		form.inquiries_subject=defaultSubject;
	}

	// get the contacts associated with an inquiry, but if this is a new message, it won't need to do that
	db.sql = 'SELECT inquiries_x_contact.inquiries_x_contact_id, 
		inquiries_x_contact.inquiries_x_contact_type, 
		contact.contact_id, contact.contact_email, 
		concat(contact.contact_first_name, #db.param(" ")#, contact.contact_last_name) fullName
		FROM (#db.table( 'contact', request.zos.zcoreDatasource )#, 
		#db.table("inquiries", request.zos.zcoreDatasource)#) 
		LEFT JOIN #db.table( 'inquiries_x_contact', request.zos.zcoreDatasource )# ON 
			(inquiries_x_contact.inquiries_x_contact_deleted = #db.param( 0 )#
			AND contact.contact_id = inquiries_x_contact.contact_id
			AND contact.site_id = inquiries_x_contact.site_id)
		WHERE
		inquiries.site_id = contact.site_id 
		AND inquiries.contact_id = contact.contact_id
		AND inquiries_deleted=#db.param(0)# 
		AND inquiries_x_contact.inquiries_x_contact_type IS NOT NULL 
		AND contact.contact_email <> #db.param("")# ';
		//IF COMING FROM CONTACT INQUIRIES_ID ALWAYS 0
		if(form.inquiries_id GT 0){
			db.sql &= " AND inquiries.inquiries_id = #db.param(form.inquiries_id)# "; 
		}
		if(form.method EQ "userIndex"){
			db.sql&=variables.manageInquiryCom.getUserLeadFilterSQL(db); 
		}else{
			if(not application.zcore.user.checkGroupAccess("administrator")){
				// has to be limited to leads assigned to this user only or other users who have member or higher access.
				db.sql&=" and (inquiries.user_id = #db.param(request.zsession.user.id)# and inquiries.user_id_siteidtype=#db.param(application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id))#) ";
			}
		}
		db.sql&=' and contact.site_id = #db.param( request.zos.globals.id )#
		AND contact.contact_deleted = #db.param( 0 )# 
		GROUP BY contact.contact_id 
		ORDER BY contact.contact_first_name ASC, contact.contact_last_name ASC, contact.contact_email ASC';
	qContact = db.execute( 'qContact' );  
	//writeDump(qContact); 
	arrContactQuery=[qContact];

	arrContact=[];
	arrTo=[];
	uniqueStruct={};
	arrLabelTo=[];
	if(application.zcore.user.checkGroupAccess("member")){
		// do a second query to get the member and higher contacts (easier)
		// need a list of the groups that have access to member
		qUser=application.zcore.user.getUsersWithGroupAccess("member", false, true);

		arrContactId=[]; 
		if(arrayLen(arrContactId) NEQ 0){
			db.sql = 'SELECT inquiries_x_contact.inquiries_x_contact_id, 
			inquiries_x_contact.contact_id,		
			inquiries_x_contact.inquiries_x_contact_type, 
			contact.contact_id, contact.contact_email, 
			concat(contact.contact_first_name, #db.param(" ")#, contact.contact_last_name) fullName
			FROM #db.table( 'contact', request.zos.zcoreDatasource )# 
			LEFT JOIN #db.table( 'inquiries_x_contact', request.zos.zcoreDatasource )# ON 
				inquiries_x_contact.inquiries_x_contact_deleted = #db.param( 0 )#
				AND contact.contact_id = inquiries_x_contact.contact_id
				AND contact.site_id = inquiries_x_contact.site_id
				AND inquiries_x_contact.inquiries_id = #db.param(form.inquiries_id)#
			WHERE 
			contact.contact_id IN (#db.trustedSQL(arrayToList(arrContactId, ","))#) and 
			contact.site_id = #db.param( request.zos.globals.id )# AND 
			contact.contact_deleted = #db.param( 0 )#
			GROUP BY contact.contact_id 
			ORDER BY contact.contact_first_name ASC, contact.contact_last_name ASC, contact.contact_email ASC';
			qContactMember = db.execute( 'qContactMember' ); 
			arrayAppend(arrContactQuery, qContactMember);
		}
 	}
 	arrCCSelected=[];
 	arrBCCSelected=[];
 	for(q in arrContactQuery){
		for ( row in q ) {
			ts={};
			if(row.fullName NEQ ''){
				ts.label=row.fullName&" <"&row.contact_email&">";
			}else{
				ts.label=row.contact_email;
			}
			ts.value=replace(row.fullName, "`", "'", "all")&"`"&row.contact_email;
			if(row.inquiries_x_contact_id NEQ ""){
				if(structKeyExists(uniqueStruct, ts.value)){
					continue;
				}
				uniqueStruct[ts.value] = true;
				if(row.inquiries_x_contact_type EQ "to" AND row.contact_id EQ form.contact_id){
					arrayAppend(arrTo, ts.value);
					arrayAppend(arrLabelTo, ts.label); 
				}else if(row.inquiries_x_contact_type EQ "cc"){
					arrayAppend(arrCCSelected, ts.value);
				}else if(row.inquiries_x_contact_type EQ "bcc"){
					arrayAppend(arrBCCSelected, ts.value);
				}
			}
			arrayAppend(arrContact, ts);
		}
	} 
	// salesperson can probably share contact with another salesperson by accident.  we don't want that 
	// need to allow salesperson to create new contact if they type one that exists already they don't have access to.
	// isolate which contact should appear:
	// test with salesperson
	// test with agent
	// test with administrator
	// test dealer manager - make sure he can see the contacts of the salespeople
	//writedump(arrTo);

	if(form.method EQ "index"){
		action="send";
	}else{
		action="userSend";
	}
	</cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */
	var arrEmailTemplate=[];
	var greeting="#JSStringFormat(trim('Hello '&application.zcore.functions.zFirstLetterCaps(variables.contact.contact_first_name))&',<br><br>')#";
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
	var originalMessage="#jsstringformat(originalMessage)#";
	var signature="#jsstringformat('<br><br>--<br>#trim(signature)#')#";
	function updateEmailForm(v){
		if(v!=""){
			if(arrEmailTemplate[v].subject != ""){
				document.sendEmailForm.inquiries_subject.value=arrEmailTemplate[v].subject;
			}
			if(arrEmailTemplate[v].message != ""){ 
				tinymce.get('inquiries_message').setContent(greeting+arrEmailTemplate[v].message+signature+originalMessage);  
			}
		}else{
			document.sendEmailForm.inquiries_subject.value="";
			tinymce.get('inquiries_message').setContent(greeting+signature+originalMessage);  
		}
	}
	/* ]]> */
	</script>
	<!--- <div class="z-manager-edit-head">
		<h2 style="display:inline;font-weight:normal; color:##369;">New Message</h2>  
		<cfif application.zcore.user.checkGroupAccess("administrator")> 
			<a href="/z/inquiries/admin/lead-template/index" class="z-manager-search-button" target="_blank">Edit Templates</a> 
			<a href="/z/inquiries/admin/lead-template/add?inquiries_lead_template_type=2&amp;siteIDType=1" class="z-manager-search-button" target="_blank">Add Template</a> 
		</cfif>
	</div>  ---> 
	<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/send-message/#action#" method="post" enctype="multipart/form-data">
		<input type="hidden" name="contact_id" value="#htmleditformat(form.contact_id)#">
		<input type="hidden" name="inquiries_id" value="#htmleditformat(form.inquiries_id)#">
		<input type="hidden" name="inquiries_to" value="#htmleditformat(arrayToList(arrTo, ','))#">
		<div class="z-float z-p-10 z-bg-white z-index-3" style="visibility:hidden;">
			<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Send</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button>
			<cfif application.zcore.user.checkGroupAccess("administrator")> 
				<a href="/z/inquiries/admin/lead-template/index" class="z-manager-search-button" target="_blank">Templates</a> 
			</cfif> 
		</div> 
		<div class="z-float z-p-10 z-bg-white z-index-3" style="position:fixed;">
			<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Send</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button>
			<cfif application.zcore.user.checkGroupAccess("administrator")> 
				<a href="/z/inquiries/admin/lead-template/index" class="z-manager-search-button" target="_blank">Templates</a> 
			</cfif>
		</div> 
		<div class="z-manager-edit-errors z-float"></div>
		<table class="table-list z-index-1" style="width:100%; ">  
			<tr>
				<th colspan="2"><cfif form.inquiries_id EQ 0>New Message<cfelse>Replying to Inquiry ###form.inquiries_id#</cfif>
				</th>
			</tr>
			<cfif application.zcore.user.checkGroupAccess("member") and qTemplate.recordcount NEQ 0>
				<tr>
					<th colspan="2"> Select a template or fill in the following fields:</th>
				</tr>
				<tr>
					<th>Template:</th>
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
			</cfif>
			<tr>
				<th>From:</th>
				<td>#request.zsession.user.first_name# #request.zsession.user.last_name# (#request.zsession.user.email#)
				</td>
			</tr> 
			<tr>
				<th>To:</th>
				<td>#variables.contact.contact_first_name# #variables.contact.contact_last_name# (#variables.contact.contact_email#) 
					<cfif arrayLen(arrLabelTo) GT 1>
						and <span title="#arrayToList(arrLabelTo, chr(10))#">#arrayLen(arrLabelTo)# other<cfif arrayLen(arrLabelTo) GT 1>s</cfif></span>
					</cfif>
				</td>
			</tr>
			<tr>
				<th>Cc:</th>
				<td> 
					<cfscript> 
					form.inquiries_cc=arrayToList(arrCCSelected, ",");
					ts={
						field:"inquiries_cc",
						arrData:arrContact
					}
					echo(application.zcore.functions.zEmailTokenAutocompleteInput(ts));
					</cfscript> 
				</td>
			</tr>
			<tr>
				<th>Bcc:</th>
				<td> 
					<cfscript> 
					form.inquiries_bcc=arrayToList(arrBCCSelected, ",");
					ts={
						field:"inquiries_bcc",
						arrData:arrContact
					}
					echo(application.zcore.functions.zEmailTokenAutocompleteInput(ts));
					</cfscript> 
				</td>
			</tr>
			<tr>
				<th>Subject:</th>
				<td><input name="inquiries_subject" id="inquiries_subject" type="text" size="50" maxlength="255" value="#htmleditformat(form.inquiries_subject)#" /></td>
			</tr>
			<tr>
				<th>Message:</th>
				<td>
					
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "inquiries_message";
					htmlEditor.value			= form.inquiries_message;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 150;
					htmlEditor.createSimple();
					</cfscript> 

					<div class="z-float z-pv-10">
						<p>Note: You can edit your email signature in your profile. &nbsp;&nbsp;
						<a href="/z/user/preference/form" class="z-manager-search-button" target="_blank" title="Click here to edit your profile in a new window.">Edit Profile</a></p>
					</div>
				</td>
			</tr>
		</table>
		
	</form>

	<script type="text/javascript">
	zArrDeferredFunctions.push( function() {
		$('##inquiries_subject').keypress(function(e) { 
			// detect ENTER key 
			if (e.keyCode == 13) { 
				e.stopImmediatePropagation();
				e.preventDefault();
				return false;
			}
		});  
		function emailSentCallback(r){
			window.parent.location.reload();
		}
		$("##sendEmailForm").on("submit", function(e){
			//e.preventDefault();
			/*var valid=true;
			var valid2=true;
			var valid3=true;
			$(".inquiriesCCContainer .token-search input").each(function(){
				valid=forceSetEmail(this, "##inquiries_cc", true);
			});
			$(".inquiriesBCCContainer .token-search input").each(function(){
				valid2=forceSetEmail(this, "##inquiries_bcc", true);
			}); 
			if($("##inquiries_subject").val()=="" || $("##inquiries_message").val()==""){
				alert("Subject and message are required.");
				valid3=false;
			}
			if(!valid || !valid2 || !valid3){
				return false;
			}*/
			var valid3=true;
			if($("##inquiries_subject").val()=="" || $("##inquiries_message").val()==""){
				alert("Subject and message are required.");
				valid3=false;
			}
			if(!valid3){
				return false;
			}
			return zSubmitManagerEditForm(this, emailSentCallback); 
		});
	});
	</script> 
	<br />
</cffunction>
</cfoutput>
</cfcomponent>			