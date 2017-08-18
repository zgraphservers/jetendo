<cfcomponent>
<cfoutput>


<!--- 
ts={
	inquiries_id:,
	dataStruct:inquiryDataStruct,
	site_id:request.zos.globals.id
};
rs=storeContactForInquiry(ts);
if(rs.success){
	// associate to record
	// form.contact_id=rs.data.contact_id;
}
 --->
<cffunction name="storeContactForInquiry" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		site_id:request.zos.globals.id
	};
	ss=arguments.ss;
	ds=ss.dataStruct;
	structappend(ss, ts, false);
	db=request.zos.queryObject;


	phone=trim(application.zcore.functions.zFormatInquiryPhone(ds.inquiries_phone1));
	email=trim(ds.inquiries_email);

	if(len(phone) < 7 and len(email) < 5){
		// can't make a contact record without a unique phone or email.
		return { success:false};
	}

	db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# where 
	(";
	if(phone NEQ ""){
		db.sql&=" contact_phone1 = #db.param(phone)# or contact_phone2 = #db.param(phone)# or contact_phone3 = #db.param(phone)# ";
	}
	if(email NEQ ""){
		if(phone NEQ ""){
			db.sql&=" or ";
		}
		db.sql&=" contact_email=#db.param(arguments.email)# ";
	}
	db.sql&=" ) and 
	contact_deleted=#db.param(0)# and 
	site_id=#db.param(arguments.site_id)# 
	ORDER BY contact_parent_id ASC
	LIMIT #db.param(0)#, #db.param(1)# ";
	qContact=db.execute("qContact");

	cs={};
	for(row in qContact){
		cs=row;
	}

	cs=mapInquiryDataToContactData(ts.dataStruct, cs);


	t2={
		struct:cs,
		datasource:request.zos.zcoreDatasource,
		table:"contact"
	};
	if(qContact.recordcount EQ 0){
		// setup fields

		contact_id=application.zcore.functions.zInsert(t2);
	}else{
		t2.struct.contact_id=qContact.contact_id;
		application.zcore.functions.zUpdate(t2);
	}

	return {success:true, contact_id:contact_id};
	// user / contact / track_user are all the same, but different code writes to them.  If i add contact, i will still need to connect the other ones eventually.
	</cfscript>
</cffunction>

<cffunction name="mapInquiryDataToContactData" localmode="modern" access="public">
	<cfargument name="inquiryData" type="struct" required="yes">
	<cfargument name="contactData" type="struct" required="yes">
	<cfscript>
	ds=arguments.inquiryData;
	cs=arguments.contactData;
 
	cs.site_id=ss.site_id; 
	// need phone to be formatted here to guarantee a match
 
	if(cs.contact_phone1_formatted EQ phone or cs.contact_phone2_formatted EQ phone or cs.contact_phone3_formatted EQ phone){
		// leave as is
	}else if(cs.contact_phone1_formatted EQ ""){
		cs.contact_phone1=ds.inquiries_phone1;
		cs.contact_phone1_formatted=phone;
	}else if(cs.contact_phone2_formatted EQ ""){
		cs.contact_phone2=ds.inquiries_phone1;
		cs.contact_phone2_formatted=phone;
	}else if(cs.contact_phone3_formatted EQ ""){
		cs.contact_phone3=ds.inquiries_phone1;
		cs.contact_phone3_formatted=phone;		
	}
	if(cs.contact_email NEQ email){
		cs.contact_email=email;
	}

	cs.contact_deleted=0;
	cs.office_id=application.zcore.functions.zso(ds, 'office_id'); 

	cs.contact_company=application.zcore.functions.zso(ds, 'inquiries_company');
	//cs.contact_salutation
	cs.contact_first_name=application.zcore.functions.zso(ds, 'inquiries_first_name');
	cs.contact_last_name=application.zcore.functions.zso(ds, 'inquiries_last_name');
	cs.contact_address=application.zcore.functions.zso(ds, 'inquiries_address');
	cs.contact_city=application.zcore.functions.zso(ds, 'inquiries_city');
	cs.contact_state=application.zcore.functions.zso(ds, 'inquiries_state');
	cs.contact_country=application.zcore.functions.zso(ds, 'inquiries_country');
	cs.contact_postal_code=application.zcore.functions.zso(ds, 'inquiries_zip');

	cs.contact_interested_in_model=application.zcore.functions.zso(ds, 'inquiries_interested_in_model');
	cs.contact_interest_level=application.zcore.functions.zso(ds, 'inquiries_interest_level');
	cs.contact_interested_in_category=application.zcore.functions.zso(ds, 'inquiries_interested_in_category');

	cs.contact_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	cs.contact_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	cs.contact_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256');
	cs.contact_des_key=GenerateSecretKey("des"); 

	// don't need these yet
	//cs.contact_suffix
	//cs.contact_job_title
	//cs.contact_birthday  
	//cs.contact_spouse_first_name
	//cs.contact_spouse_suffix
	//cs.contact_spouse_job_title
	//cs.contact_lead_source
	//cs.contact_form_name
	//cs.contact_received_date
	//cs.contact_interests
	/*cs.contact_interested_in_type
	cs.contact_interested_in_year
	cs.contact_interested_in_make
	cs.contact_interested_in_model
	cs.contact_interested_in_category
	cs.contact_interested_in_name
	cs.contact_interested_in_hin_vin
	cs.contact_interested_in_stock
	cs.contact_interested_in_length
	cs.contact_interested_in_currently_owned_type
	cs.contact_interested_in_read
	cs.contact_interested_in_age
	cs.contact_interested_in_email
	cs.contact_interested_in_email_alternate
	cs.contact_interested_in_bounce_reason
	cs.contact_interested_in_home_phone
	cs.contact_interested_in_work_phone
	cs.contact_interested_in_mobile_phone
	cs.contact_interested_in_fax
	cs.contact_interested_in_buying_horizon
	cs.contact_interested_in_status
	cs.contact_interested_in_interest_level
	cs.contact_interested_in_sales_stage
	cs.contact_interested_in_date_added
	cs.contact_interested_in_date_updated
	cs.contact_interested_in_contact_source
	cs.contact_interested_in_dealership
	cs.contact_interested_in_assigned_to
	cs.contact_interested_in_bounced_email
	cs.contact_interested_in_owners_magazine
	cs.contact_interested_in_purchased
	cs.contact_interested_in_service_date
	cs.contact_interested_in_date_delivered
	cs.contact_interested_in_date_sold
	cs.contact_interested_in_warranty_date
	cs.contact_interested_in_lead_comments
	*/
	return cs;
	</cfscript>
</cffunction>


<!--- 
contactCom.updateContactEmail(oldEmail, newEmail, site_id);
 --->
<cffunction name="updateContactEmail" localmode="modern" access="public">
	<cfargument name="oldEmail" type="string" required="yes">
	<cfargument name="newEmail" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	// we can't automatically eliminate old contact_id without possibly losing data or breaking the from addresses already distributed.
	// this code links all contact records together so that we can keep old contact_id forever, and still have a main record for the purposes of consolidating views of contacts.
	db.sql="SELECT contact_id from #db.table("contact", request.zos.zcoreDatasource)# 
	WHERE 
	contact_email = #db.param(arguments.newEmail)# and 
	site_id = #db.param(arguments.site_id)# and 
	contact_parent_id=#db.param(0)# and
	contact_deleted=#db.param(0)# ";
	qContact=db.execute("qContact");
	if(qContact.recordcount EQ 0){
		// update contact email 
		db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
		contact_email = #db.param(arguments.newEmail)#, 
		contact_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		site_id = #db.param(arguments.site_id)# and 
		contact_email=#db.param(arguments.oldEmail)# and 
		contact_deleted=#db.param(0)# ";
		db.execute("qUpdate");
	}else{ 
		db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
		contact_email = #db.param(arguments.newEmail)#, 
		contact_parent_id=#db.param(qContact.contact_id)#, 
		contact_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		site_id = #db.param(arguments.site_id)# and  
		contact_email = #db.param(arguments.oldEmail)# and 
		contact_deleted=#db.param(0)# ";
		db.execute("qUpdate");
	}
	</cfscript>
</cffunction>

<!---  
ts={ 
	// contact_id or user_id is required
	contact_id:"",
	user_id:"",		
	inquiries_id:"", 
	validHash:true, 
	messageStruct:{}, // queue_pop struct
	jsonStruct:{} // decoded json queue_pop_message_json
};
contactCom.processMessage(ts);
 --->
<cffunction name="processMessage" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>	
	db=request.zos.queryObject;
	ss=arguments.ss;
	//echo('processMessage');
	//writedump(ss);
 
 	debug=true;
 	debugCount=0;
	// remember, we must individual address each email because from address must be different for each one

	//	get inquiries record
	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(ss.messageStruct.site_id)# and 
	inquiries_deleted=#db.param(0)# and 
	inquiries_id=#db.param(ss.inquiries_id)#";
	qInquiry=db.execute("qInquiry");
	if(qInquiry.recordcount EQ 0){
		// invalid request, we can store this as a new lead, or discard the message.
		// for now, we discard the message by returning true
		if(debug){
			echo('inquiry missing<br>');
		}
		return {success:true};
	}
	emailStruct={};

	// get the from contact data
	fromContactId=ss.contact_id;
	fromContact = this.getContactById( fromContactId, ss.messageStruct.site_id );
	skipEmail="";
	if(structcount(fromContact) EQ 0){
		// we discard the message for now since this is a non-existant contact.
		if(debug){
			echo('from contact missing<br>');
		}
		return {success:true};
	}else{
		// tested successfully
		skipEmail=fromContact.contact_email;
		if(ss.jsonStruct.from.name NEQ ""){
			if(debug){
				echo('From contact id #fromContact.contact_id# From name is: #ss.jsonStruct.from.name# from email: #fromContact.contact_email# |  db version: #fromContact.contact_first_name# #fromContact.contact_last_name#<br>');
			}
			if(fromContact.contact_first_name EQ "" and fromContact.contact_last_name EQ ""){
				firstName="";
				lastName=""; 
				if(ss.jsonStruct.from.name CONTAINS " "){
					firstName=listGetAt(ss.jsonStruct.from.name, 1, " ");
					lastName=trim(listDeleteAt(ss.jsonStruct.from.name, 1, " "));
				}else{
					firstName=ss.jsonStruct.from.name;
				}  
				fromContact.contact_first_name=firstName;
				fromContact.contact_last_name=lastName;
				db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
				contact_first_name=#db.param(fromContact.contact_first_name)#, 
				contact_last_name=#db.param(fromContact.contact_last_name)#, 
				contact_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
				WHERE 
				contact_id = #db.param(fromContact.contact_id)# and 
				contact_deleted=#db.param(0)# and 
				site_id=#db.param(ss.messageStruct.site_id)#";
				db.execute("qUpdate"); 
				if(debug){
					echo('Fixed missing name on from contact<br>');
				}

			}
		}
	}
	// get the main contact who sent original message
	// tested successfully
	if(qInquiry.contact_id EQ 0){
		// convert inquiries_email into contact_id
		mainContact=getContactByEmail(qInquiry.inquiries_email, trim(qInquiry.inquiries_first_name&" "&qInquiry.inquiries_last_name), ss.messageStruct.site_id);
		if(structcount(mainContact) NEQ 0){
			db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# SET 
			contact_id=#db.param(mainContact.contact_id)#, 
			inquiries_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
			WHERE 
			inquiries_id = #db.param(ss.inquiries_id)# and 
			inquiries_deleted=#db.param(0)# and 
			site_id=#db.param(ss.messageStruct.site_id)#";
			db.execute("qUpdate"); 
			if(debug){
				echo('added contact_id, #mainContact.contact_id#, to inquiries for the main contact<br>');
			}
		}
	}else{
		mainContact = this.getContactById(qInquiry.contact_id, ss.messageStruct.site_id );
	}
	// tested successfully
	// send to main contact if they are not the current message sender.
	if(structcount(mainContact) EQ 0){ 
		if(mainContact.contact_id NEQ fromContactId){
			ts={
				site_id:ss.messageStruct.site_id,
				contact_id:mainContact.contact_id,
				contact_des_key:mainContact.contact_des_key,
				contact_email:mainContact.contact_email,
				contact_first_name:mainContact.contact_first_name,
				contact_last_name:mainContact.contact_last_name,
				addressType:"to" // to, cc, bcc (bcc is visible only to internal users)
			};
			emailStruct[mainContact.contact_email]=ts;
			if(debug){
				echo('Added main contact, #mainContact.contact_email#, to outgoing email<br>');
			}
		}
	}
 

	// get all the contacts subscribed to the current inquiry
	// tested successfully
	db.sql="SELECT * FROM 
	#db.table("contact", request.zos.zcoreDatasource)#, 
	#db.table("inquiries_x_contact", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_x_contact.site_id = contact.site_id and 
	inquiries_x_contact.contact_id = contact.contact_id and 
	inquiries_x_contact.inquiries_x_contact_deleted=#db.param(0)# and 
	contact.site_id = #db.param(ss.messageStruct.site_id)# and 
	contact_deleted=#db.param(0)# and 
	inquiries_x_contact.inquiries_id=#db.param(ss.inquiries_id)#";
	qContact=db.execute("qContact"); 
	for(row in qContact){
		if(not structkeyexists(emailStruct, row.contact_email)){
			ts={
				site_id:ss.messageStruct.site_id,
				contact_id:row.contact_id,
				contact_des_key:row.contact_des_key,
				contact_email:row.contact_email,
				contact_first_name:row.contact_first_name,
				contact_last_name:row.contact_last_name,
				addressType:row.inquiries_x_contact_type // to, cc, bcc (bcc is visible only to internal users)
			};
			emailStruct[row.contact_email]=ts;
			if(debug){
				echo('Added contact id, #row.contact_id# | #row.contact_email#, to outgoing email<br>');
			}
		}
	}

	// not tested
	if(qInquiry.office_id NEQ 0){
		db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(ss.messageStruct.site_id)# and 
		office_deleted=#db.param(0)# and 
		office_manager_email_list <> #db.param('')# and 
		office_id=#db.param(qInquiry.office_id)#";
		qOffice=db.execute("qOffice"); 
		for(row in qOffice){
			arrEmail=listToArray(row.office_manager_email_list, ",");
			for(email in arrEmail){
				contact=getContactByEmail(trim(email), "", ss.messageStruct.site_id);
				if(structcount(contact) NEQ 0){
					ts={
						site_id:ss.messageStruct.site_id,
						contact_id:contact.contact_id,
						contact_des_key:contact.contact_des_key,
						contact_email:contact.contact_email,
						contact_first_name:contact.contact_first_name,
						contact_last_name:contact.contact_last_name,
						addressType:"cc"
					};
					emailStruct[contact.contact_email]=ts;
					if(debug){
						echo('Added office manager email list contact, #contact.contact_email#, to outgoing email<br>');
					}
				}
			}
		}
	}
	// not tested
	if(qInquiry.inquiries_assign_email EQ ""){ 
		arrEmail=listToArray(qInquiry.inquiries_assign_email, ",");
		for(email in arrEmail){
			contact=getContactByEmail(trim(email), qInquiry.assign_name, ss.messageStruct.site_id);
			if(structcount(contact) NEQ 0){
				ts={
					site_id:ss.messageStruct.site_id,
					contact_id:contact.contact_id,
					contact_des_key:contact.contact_des_key,
					contact_email:contact.contact_email,
					contact_first_name:contact.contact_first_name,
					contact_last_name:contact.contact_last_name,
					addressType:"to"
				};
				emailStruct[contact.contact_email]=ts;
				if(debug){
					echo('Added inquiries assign email contact, #contact.contact_email#, to outgoing email<br>');
				}
			}
		}
	}
	// tested successfully
	if(qInquiry.user_id NEQ "0"){ 
		// get assigned user, and their user_alternate_email
		db.sql="select contact.*, user_alternate_email, user_username, user_first_name, user_last_name from 
		#db.table("user", request.zos.zcoreDatasource)# 
		LEFT JOIN #db.table("contact", request.zos.zcoreDatasource)# ON 
		user_username=contact_email and  
		contact.site_id=#db.param(ss.messageStruct.site_id)# and 
		contact_deleted=#db.param(0)# 
		where 
		user.site_id = #db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(qInquiry.user_id_siteIDType, ss.messageStruct.site_id))# and 
		user.user_id = #db.param(qInquiry.user_id)# and 
		user_active=#db.param(1)# and  
		user_deleted=#db.param(0)#"; // write query
		qUser=db.execute("qUser"); 
		for(row in qUser){
			if(row.user_alternate_email NEQ ""){
				arrTempEmail=listToArray(row.user_alternate_email, ",");
				for(email in arrTempEmail){
					contact=getContactByEmail(trim(email), trim(row.contact_first_name&" "&row.contact_last_name), ss.messageStruct.site_id);
					if(structcount(contact) NEQ 0){
						ts={
							site_id:ss.messageStruct.site_id,
							contact_id:contact.contact_id,
							contact_des_key:contact.contact_des_key,
							contact_email:contact.contact_email,
							contact_first_name:contact.contact_first_name,
							contact_last_name:contact.contact_last_name,
							addressType:"to"
						};
						emailStruct[contact.contact_email]=ts;
						if(debug){
							echo('Added inquiry assigned user alternate cc contact, #contact.contact_email#, to outgoing email<br>');
						}
					}
				}
			}
			if(row.contact_id EQ ""){ 
				// tested successfully
				contact=getContactByEmail(trim(email), trim(row.user_first_name&" "&row.user_last_name), ss.messageStruct.site_id);
				if(structcount(contact) NEQ 0){ 
					ts={
						site_id:ss.messageStruct.site_id,
						contact_id:contact.contact_id,
						contact_des_key:contact.contact_des_key,
						contact_email:contact.contact_email,
						contact_first_name:contact.contact_first_name,
						contact_last_name:contact.contact_last_name,
						addressType:"to"
					};
					emailStruct[contact.contact_email]=ts; 
					row.contact_email=contact.contact_email;
				}
			}else{
				ts={
					site_id:ss.messageStruct.site_id,
					contact_id:row.contact_id,
					contact_des_key:row.contact_des_key,
					contact_email:row.contact_email,
					contact_first_name:row.contact_first_name,
					contact_last_name:row.contact_last_name,
					addressType:"to"
				};
				emailStruct[row.contact_email]=ts; 
			}
			if(debug){
				echo('Added inquiry assigned user contact, #row.contact_email#, to outgoing email<br>');
			}
		}
	}

	// anyone missing still who was addressed in the email? force creation of a new "contact" record, and add that email here. 
	// tested successfully
	for(row in ss.jsonStruct.to){
		if(not structkeyexists(emailStruct, row.email)){
			// insert to inquiries_x_contact as to
			contact=getContactByEmail(row.email, row.name, ss.messageStruct.site_id);
			ts={
				table:"inquiries_x_contact",
				datasource:request.zos.zcoreDatasource,
				struct:{
					contact_id:contact.contact_id, 
					inquiries_id:ss.inquiries_id, 
					site_id:ss.messageStruct.site_id, 
					inquiries_x_contact_type:'to', 
					inquiries_x_contact_deleted:0,
					inquiries_x_contact_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss")
				}
			};
			application.zcore.functions.zInsert(ts);
			ts={
				site_id:ss.messageStruct.site_id,
				contact_id:contact.contact_id,
				contact_des_key:contact.contact_des_key,
				contact_email:contact.contact_email,
				contact_first_name:contact.contact_first_name,
				contact_last_name:contact.contact_last_name,
				addressType:"to"
			};
			emailStruct[contact.contact_email]=ts; 
			if(debug){
				echo('Added email "to" contact, #contact.contact_email#, to outgoing email<br>');
			}
		}
	}

	// tested successfully
	for(row in ss.jsonStruct.cc){
		if(not structkeyexists(emailStruct, row.email)){
			// insert to inquiries_x_contact as cc
			contact=getContactByEmail(row.email, row.name, ss.messageStruct.site_id);
			ts={
				table:"inquiries_x_contact",
				datasource:request.zos.zcoreDatasource,
				struct:{
					contact_id:contact.contact_id, 
					inquiries_id:ss.inquiries_id, 
					site_id:ss.messageStruct.site_id, 
					inquiries_x_contact_type:'cc', 
					inquiries_x_contact_deleted:0,
					inquiries_x_contact_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss")
				}
			};
			application.zcore.functions.zInsert(ts);
			ts={
				site_id:ss.messageStruct.site_id,
				contact_id:contact.contact_id,
				contact_des_key:contact.contact_des_key,
				contact_email:contact.contact_email,
				contact_first_name:contact.contact_first_name,
				contact_last_name:contact.contact_last_name,
				addressType:"cc"
			};
			emailStruct[contact.contact_email]=ts; 
			if(debug){
				echo('Added email "cc" contact, #contact.contact_email#, to outgoing email<br>');
			}
		}
	}
 

	// remove the person who sent the current message
	structdelete(emailStruct, skipEmail);
	if(debug){
		echo('Removed sender email contact, #skipEmail#, from outgoing email<br>');
	}



	// loop all recipients
	emailSendStruct={
		to:[],
		cc:[],
		bcc:[]
	}; 
	for(i in emailStruct){
		contact=emailStruct[i]; 
		// generate unique from address 
		idString=contact.contact_id&"."&ss.inquiries_id;
		tempEmail=getFromAddressForContactByStruct(contact, idString); 
		if(debug){
			writedump(contact);
		}
		if(not structkeyexists(emailSendStruct, contact.addressType)){
			throw("Invalid contact.addressType: ""#contact.addressType#"".  Only to, cc, and bcc are valid values.");
		}
		if(debug){
			echo('#contact.contact_email# changed to #tempEmail#<br>');
		}
		name=trim(contact.contact_first_name&" "&contact.contact_last_name);
		if(name NEQ ""){
			arrayAppend(emailSendStruct[contact.addressType], application.zcore.email.formatEmailWithName(tempEmail, name));
		}else{
			arrayAppend(emailSendStruct[contact.addressType], tempEmail);
		} 
		//arrayAppend(emailSendStruct[contact.addressType], { email:tempEmail, name: trim(contact.contact_first_name&" "&contact.contact_last_name)});
	}

	if(debug){
		echo('Final email list for outgoing email<br>');
		writedump(emailSendStruct);
	}
	abort;


	// insert to inquiries_feedback
	ts={
		table:"inquiries_feedback",
		datasource:request.zos.zcoreDatasource,
		struct:{
			inquiries_feedback_subject:ss.jsonStruct.subject,
			inquiries_feedback_comments:"", // leave empty because this is an email message.
			inquiries_feedback_datetime:ss.jsonStruct.date,
			inquiries_id:ss.inquiries_id,
			//user_id:user_id,
			contact_id:fromContactId,
			inquiries_id:ss.inquiries_id,
			site_id:ss.messageStruct.site_id,
			//user_id_siteIDType:user_id_siteIDType,
			inquiries_feedback_created_datetime:ss.jsonStruct.date,
			inquiries_feedback_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
			inquiries_feedback_deleted:0,
			inquiries_feedback_message_json:serializeJSON(ss.jsonStruct),
			inquiries_feedback_draft:0,
			inquiries_feedback_type:1 // 0 is note, 1 is external email, 2 is internal email
		}
	}
	//writedump(ts);	abort; 
	inquiries_feedback_id=application.zcore.functions.zInsert(ts);
	if(not inquiries_feedback_id){
		if(debug){
			echo('Failed to insert feedback record<br>');
		}
		return {success:false, errorMessage:"Failed to save to inquiries_feedback"};
	}
	if(debug){
		echo('Inserted feedback record<br>');
	} 
	// build email html


	// send email

	// Send email? 
	/*
	var ts = {
		forceUniqueType: true, // prevent multiple scheduled emails of the same type
		// required
		data: {
			inquiries_type_id: '',
			inquiries_type_id_siteIDType: '',
			email_queue_unique: '1', // 1 is unique and 0 allows multiple entries for this type for the same email_queue_to address.
			email_queue_from: jsonStruct.from.name & ' <' & jsonStruct.from.email & '>',
			email_queue_to: to,
			email_queue_subject: jsonStruct.subject,
			email_queue_html: jsonStruct.html,
			email_queue_send_datetime: dateAdd( 'm', 30, now() ),
			// optional
			email_queue_cc: cc,
			email_queue_bcc: '',
			email_queue_text: jsonStruct.text,
			site_id: request.zos.globals.id
		}
	};

	writedump( ts );
	abort;

	// var rs = request.contactCom.scheduleLeadEmail( ts );

	var rs = {
		success: false
	};

	if ( rs.success ) {

	} else { 
	}
	*/
	cs={
		success:true
	};
	return cs;
	</cfscript>
</cffunction>	


<cffunction name="emailArrayToList" localmode="modern" access="private">
	<cfargument name="emailArray" type="array" required="yes">
	<cfscript>
	var arrEmail=[];
	for(email in arguments.emailArray){
		if ( email.name EQ '' ) {
			arrayAppend(arrEmail, email.email);
		} else {
			arrayAppend(arrEmail, email.name & ' <' & email.email & '>');
		}
	}
	return arrayToList(arrEmail, ', ');
	</cfscript>
</cffunction>

<!--- 
// Probably not going to do this: The idea in delaying emails may allow the person to improve / fix their email before it goes to the group if they notice a mistake real quick.

// This api only works for leads that are generated from our system.  CRM / API integrations may need additional custom programming.
ts={
	forceUniqueType:true, // prevent multiple scheduled emails of the same type

	// required
	data:{
		inquiries_type_id:"",
		inquiries_type_id_siteIDType:"",
		email_queue_unique:"1", // 1 is unique and 0 allows multiple entries for this type for the same email_queue_to address.
		email_queue_from:"",
		email_queue_to:"",
		email_queue_subject:"",
		email_queue_html:"",
		email_queue_send_datetime:dateadd("m", 30, now())
		// optional
		email_queue_cc:"",
		email_queue_bcc:"",
		email_queue_text:"",
		site_id:request.zos.globals.id
	}
};
scheduleLeadEmail(ts);
 --->
<cffunction name="scheduleLeadEmail" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject;
	throw("this is incomplete - pseudocode - lets not implement this one");
	// add email to an email queue table that will go out at specific time.  
	// table has full html. 

	ss.email_queue_send_datetime=dateformat(ss.email_queue_send_datetime, "yyyy-mm-dd")&" "&timeformat(ss.email_queue_send_datetime, "HH:mm:ss");

	ts={
		table:"email_queue",
		datasource:request.zos.zcoreDatasource,
		struct:ss
	};

	update=false;
	if(ss.forceUniqueType){
		// if email already exists, run update instead of insert
		update=true;
	}
	if(update){
		ts.struct.email_queue_id=qCheck.email_queue_id;
		application.zcore.functions.zUpdate(ts);
	}else{
		email_queue_id=application.zcore.functions.zInsert(ts);
	}

	return {success:true, email_queue_id:email_queue_id};
	</cfscript>
</cffunction>


<cffunction name="rescheduleLeadEmail" localmode="modern" access="public">
	<cfscript>
	// the scheduled time should be relative to session expiration, not the initial entry.

	</cfscript>
</cffunction>

<cffunction name="cancelScheduledLeadEmail" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;

	// delete email from email queue table whether it exists or not 
	</cfscript>
</cffunction>	

<!--- getContactByEmail(email, name, site_id); --->
<cffunction name="getContactByEmail" localmode="modern" access="public">
	<cfargument name="email" type="string" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arguments.email=trim(arguments.email);
	arguments.name=trim(arguments.name);
	db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# WHERE 
	contact_email = #db.param(arguments.email)# and 
	contact_deleted = #db.param(0)# and
	site_id = #db.param(arguments.site_id)# 
	ORDER BY contact_parent_id ASC 
	LIMIT #db.param(0)#, #db.param(1)#";
	qContact=db.execute("qContact");
	if(qContact.recordcount EQ 0){ 
		firstName="";
		lastName="";
		if(arguments.name CONTAINS " "){
			firstName=listGetAt(arguments.name, 1, " ");
			lastName=trim(listDeleteAt(arguments.name, 1, " "));
		}else{
			firstName=arguments.name;
		}  
		ts={
			table:"contact",
			datasource:request.zos.zcoreDatasource,
			struct:{
				site_id:arguments.site_id,
				contact_email:arguments.email,
				contact_deleted:0,
				contact_first_name:firstName,
				contact_first_name:lastName,
				contact_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				contact_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				contact_key:hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256'),
				contact_des_key:GenerateSecretKey("des")
			}
		};
		result=application.zcore.functions.zInsert(ts); 
		db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# WHERE 
		contact_email = #db.param(arguments.email)# and 
		contact_deleted = #db.param(0)# and
		site_id = #db.param(arguments.site_id)# 
		ORDER BY contact_parent_id ASC 
		LIMIT #db.param(0)#, #db.param(1)#";
		qContact=db.execute("qContact");
	}
	for(row in qContact){
		return row;
	}
	throw("Failed to force creation of contact: #arguments.email# | site_id:#arguments.site_id#");
	</cfscript>
</cffunction>

<cffunction name="getContactById" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# WHERE 
	contact_id = #db.param(arguments.contact_id)# and 
	contact_deleted = #db.param(0)# and
	site_id = #db.param(arguments.site_id)#";
	qContact=db.execute("qContact");
	row={};
	if(not structkeyexists(request.zos, 'contactIDCache')){
		request.zos.contactIDCache={};
	}
	if(structkeyexists(request.zos.contactIDCache, arguments.contact_id&"."&arguments.site_id)){
		return request.zos.contactIDCache[arguments.contact_id&"."&arguments.site_id];
	}
	if(qContact.recordcount){
		for(row2 in qContact){
			row=row2;
			request.zos.contactIDCache[arguments.contact_id&"."&arguments.site_id]=row;
		}
	}
	return row;
	</cfscript>
</cffunction>

<!---  
<!--- getKeyByUserId --->
<cffunction name="getDESKeyByUserId" localmode="modern" access="public">
	<cfargument name="user_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(structkeyexists(request.zsession, 'user') and structkeyexists(request.zsession.user, 'user_des_key')){
		return {success:true, user_des_key:request.zsession.user.user_des_key}; 
	}
	userStruct=application.zcore.user.getUserById(arguments.user_id, arguments.site_id);
	if(structcount(userStruct) EQ 0){
		return {success:false, errorMessage:"User doesn't exist."};
	}else{
		if(userStruct.user_des_key EQ ""){
			user_des_key=GenerateSecretKey("des");
			db.sql="update #db.table("user", request.zos.zcoreDatasource)# SET 
			user_des_key=#db.param(user_des_key)# , 
			user_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE
			user_id = #db.param(arguments.user_id)# and 
			site_id = #db.param(arguments.site_id)# and 
			user_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}else{
			user_des_key=userStruct.user_des_key;
		}
		return {success:true, user_des_key:user_des_key};
	}
	</cfscript>
</cffunction>
 --->

<cffunction name="getDESKeyByContactId" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	var db = request.zos.queryObject;
	contactStruct=this.getContactById(arguments.contact_id, arguments.site_id);
	if(structcount(contactStruct) EQ 0){
		return {success:false, errorMessage:"Contact doesn't exist."};
	}else{
		if(contactStruct.contact_des_key EQ ""){
			contact_des_key=GenerateSecretKey("des");
			db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
			contact_des_key=#db.param(contact_des_key)#, 
			contact_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE
			contact_id = #db.param(arguments.contact_id)# and 
			site_id = #db.param(arguments.site_id)# and 
			contact_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}else{
			contact_des_key=contactStruct.contact_des_key;
		}
		return {success:true, contact_des_key:contact_des_key}
	}
	</cfscript>
</cffunction>

 
<!--- 
ts={ 
     email: "someone@somewhere.com", 
     phone: "badly formatted number" 
}; 
contactCom=createobject("component", "zcorerootmapping.com.app.contact");
rs=contactCom.getContact(ts); 
if(rs.success){ 
     // do stuff with rs.contactStruct; 
}else{ 
     // fail 
}
 --->
<cffunction name="getContact" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var db = request.zos.queryObject;
	var ss = arguments.ss;
	var response = structNew();
	response.success = false;

	if ( NOT structKeyExists( ss, 'email' ) ) {
		throw( 'ss.email is missing for getContact' );
	}

	if ( NOT structKeyExists( ss, 'phone' ) ) {
		throw( 'ss.phone is missing for getContact' );
	}

	if ( NOT application.zcore.functions.zEmailValidate( ss.email ) ) {
		return response;
	}

	ss.phone = application.zcore.functions.zFormatInquiryPhone( ss.phone );

	db.sql = 'SELECT *
		FROM #db.table( 'contact', request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( request.zos.globals.id )#
			AND contact_email = #db.param( ss.email )#
			AND (
				contact_phone1_formatted = #db.param( ss.phone )#
				OR contact_phone2_formatted = #db.param( ss.phone )#
				OR contact_phone3_formatted = #db.param( ss.phone )#
			)
			AND contact_deleted = #db.param( 0 )#
		LIMIT #db.param( 1 )#';
	qContact = db.execute( 'qContact' );

	contactStruct = structNew();

	for ( row in qContact ) {
		response.success = true;
		response.contactStruct = row;
		return response;
	}

	return response;
	</cfscript>
</cffunction>


<!--- 
contactCom.getFromAddressForContactByStruct(contact, idString);
 --->
<cffunction name="getFromAddressForContactByStruct" localmode="modern" access="public">
	<cfargument name="contact" type="struct" required="yes"> 
	<cfargument name="idString" type="string" required="yes">
	<cfscript> 
	contact=arguments.contact;
	if(application.zcore.functions.zVar('enablePlusEmailRouting', contact.site_id) EQ 1 ){
		echo('plusEmailRouting enabled<br>')
		plusEmail=application.zcore.functions.zVar('plusEmailAddress', contact.site_id);
		if(plusEmail NEQ ""){ 
			// build plus addressing url
			arrEmail=listToArray(plusEmail, "@");
			if(contact.contact_des_key EQ ""){
				rs=getDESKeyByContactId(contact.contact_id, contact.site_id);
				if ( rs.success ) {
					contact.contact_des_key=rs.contact_des_key;
				}else{
					return contact.contact_email;
				}
			} 
			return arrEmail[1]&"+"&"1.C"&contact.contact_id&"."&dESEncryptValueLimit16("C"&contact.contact_id&"."&arguments.idString, contact.contact_des_key)&"."&arguments.idString&"@"&arrEmail[2];
		}  
	} 
	return contact.contact_email;
	</cfscript> 
</cffunction>

<!--- 
contactCom.getFromAddressForContactById(contact_id, site_id, idString);
 --->
<cffunction name="getFromAddressForContactById" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="idString" type="string" required="yes">
	<cfscript> 
	if(application.zcore.functions.zVar('enablePlusEmailRouting', arguments.site_id) EQ 1 ){
		plusEmail=application.zcore.functions.zVar('plusEmailAddress', arguments.site_id);
		if(plusEmail NEQ ""){
			// build plus addressing url
			arrEmail=listToArray(plusEmail, "@");
			rs=getDESKeyByContactId(arguments.contact_id, arguments.site_id);
			if ( rs.success ) {
				return arrEmail[1]&"+"&"1.C"&arguments.contact_id&"."&dESEncryptValueLimit16("C"&arguments.contact_id&"."&arguments.idString, rs.contact_des_key)&"."&arguments.idString&"@"&arrEmail[2];
			}
		} 
	}

	contact = this.getContactById( arguments.contact_id, arguments.site_id );

	return contact.contact_email;
	</cfscript>
	
</cffunction>

<cffunction name="verifyDESLimit16FromAddressForContact" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="idString" type="string" required="yes">
	<cfargument name="desHashLimit16" type="string" required="yes">
	<cfscript>  
	rs=getDESKeyByContactId(arguments.contact_id, arguments.site_id);
	if ( rs.success ) {
		if(arguments.desHashLimit16 EQ dESEncryptValueLimit16("C"&arguments.contact_id&"."&arguments.idString, rs.contact_des_key)){
			return true;
		}
	}
	return false;
	</cfscript>
	
</cffunction>
<!--- 
<cffunction name="verifyDESLimit16FromAddressForUser" localmode="modern" access="public">
	<cfargument name="user_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="idString" type="string" required="yes">
	<cfargument name="desHashLimit16" type="string" required="yes">
	<cfscript>  
	rs=getDESKeyByUserId(arguments.user_id, arguments.site_id);
	if ( rs.success ) {
		if(arguments.desHashLimit16 EQ dESEncryptValueLimit16("U"&arguments.user_id&"."&arguments.idString, rs.user_des_key)){
			return true;
		}
	}
	return false;
	</cfscript>
	
</cffunction>

<cffunction name="getFromAddressForUser" localmode="modern" access="public">
	<cfargument name="user_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="idString" type="string" required="yes">
	<cfscript> 
	if(application.zcore.functions.zVar('enablePlusEmailRouting', arguments.site_id) EQ 1 ){
		plusEmail=application.zcore.functions.zVar('plusEmailAddress', arguments.site_id);
		if(plusEmail NEQ ""){
			// build plus addressing url
			arrEmail=listToArray(plusEmail, "@");
			rs=getDESKeyByUserId(arguments.user_id, arguments.site_id);
			if ( rs.success ) {
				return arrEmail[1]&"+"&"1.U"&arguments.user_id&"."&dESEncryptValueLimit16("U"&arguments.user_id&"."&arguments.idString, rs.user_des_key)&"."&arguments.idString&"@"&arrEmail[2];
			}
		} 
	}

	user = application.zcore.user.getUserById( arguments.user_id, arguments.site_id );

	// return user_email unmodified
	return user.user_email;
	</cfscript>
</cffunction> --->

<!--- desEncryptValueLimit16(id, key); --->
<cffunction name="desEncryptValueLimit16" localmode="modern" access="public">
	<cfargument name="id" type="string" required="yes"> 
	<cfargument name="key" type="string" required="yes">
	<cfscript> 
	return left(encrypt(arguments.id, arguments.key, "des", "hex"), 16);
	// echo(application.zcore.functions.zGenerateStrongPassword(16,16, true));
	</cfscript>
</cffunction> 

</cfoutput>	
</cfcomponent>