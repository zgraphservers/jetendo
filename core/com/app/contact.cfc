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
	ss=arguments.ss;
	//echo('processMessage');
	//writedump(ss);
 
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
		return {success:true};
	}
	// TODO: inquiries_feedback MUST have contact_id and be able to display contact_name wherever inquiries_feedback is displayed throughout application.

	contact_id=0;
	user_id=0;
	user_id_siteIDType=1;
	if(structkeyexists(ss, 'user_id')){
		user_id=ss.user_id;
		user_id_siteIDType=1; // TODO need to make this correct if user id not on current site.
		throw("user_id_siteIDType not implemented");
	}else{
		contact_id=ss.contact_id;
	}
	// insert to inquiries_feedback
	// build ts with inquiries_feedback fields
	ts={
		table:"inquiries_feedback",
		datasource:request.zos.zcoreDatasource,
		struct:{
			inquiries_feedback_subject:ss.jsonStruct.subject,
			inquiries_feedback_comments:"",
			inquiries_feedback_datetime:ss.jsonStruct.date,
			user_id:user_id,
			contact_id:contact_id,
			inquiries_id:ss.inquiries_id,
			site_id:ss.messageStruct.site_id,
			user_id_siteIDType:user_id_siteIDType,
			inquiries_feedback_created_datetime:ss.jsonStruct.date,
			inquiries_feedback_updated_datetime:request.zos.mysqlnow,
			inquiries_feedback_deleted:0,
			inquiries_feedback_message_json:ss.jsonStruct,
			inquiries_feedback_draft:0
		}
	}
	inquiries_feedback_id=application.zcore.functions.zInsert(ts);
	if(not inquiries_feedback_id){
		return {success:false, errorMessage:"Failed to save to inquiries_feedback"};
	}

	/*
get user
if(user doesn't exist){
	get contact
	if(contact doesn't exist){
		create contact
	}
}

if inquiries_id
inquiries_from (could be contact_id)
inquiries_x_contact
inquiries_x_contact_type to, cc, bcc (visible only to internal users)

TODO: even inquiries_assign_email could be converted to a list of contact_ids and stores in inquiries_x_contact

TODO: if a user's email is changed, the contact table would be automatically updated as well

benefits of redesign: user's email can be edited in one place.   Can merge contacts and consolidate all of the leads more easily via simple queries.

inquiries_cc
inquiries_bcc
	*/

	// TODO: build list of recipients from to, cc of the message and all the alternates, plus the office_manager_email_list emails for qInquiry.office_id
	// TODO: plus add anyone already subscribing to the ticket even if they weren't individually addressed.
	// TODO: all of the recipients receive the same email contents, but the from address is different from all of them.
	// TODO: we need either an inquiries_x_contact or a field in inquiries_subscriber_list (LONGTEXT) to store all of the people subscribed to an inquiry. 
	arrEmail=[]; 

	// it seems like contact should be contact, and everyone should be a "contact", even yourself to simplify some of this.   this record would have to be updated separately from the "user" record and automatically mapped when a user tries to use a function that requires a contact record to exist.

	db.sql="select * from contact where contact_id = and site_id = and contact_deleted=0"; // write query
	qContact=db.execute("qContact");
	for(row in qContact){
		arrayAppend(arrEmail, row.contact_email);
	}

	db.sql="select * from user where user_id = and site_id = and user_deleted=0"; // write query
	qUser=db.execute("qUser");
	for(row in qUser){
		if(row.user_alternate_email NEQ ""){
			arrTempEmail=listToArray(row.user_alternate_email, ",");
			for(email in arrTempEmail){
				// TODO: this should have same from address as the main user email to avoid creating unnecessary contacts for these alternate emails
				arrayAppend(arrEmail, email);
			}
		}
		arrayAppend(arrEmail, row.user_username);		
	}
	// anyone missing still who was addressed in the email? force creation of a new "contact" record, and add that email here.


	// loop all recipients
	arrEmailFinal=[];
	for(i=1;i LTE arraylen(arrEmail);i++){
		email=arrEmail[i];
		if(ss.jsonStruct.from.email EQ email){
			// don't send email back to the same person who sent this email.
			continue;
		}
		// generate unique from address
		tempEmail=email; // need to encode it for contact or user
		arrayAppend(arrEmailFinal, tempEmail);
	}
	// Send email?
	/*
	// this code can't be used
	var to = emailArrayToList( ss.jsonStruct.from );
	var to = emailArrayToList( ss.jsonStruct.to );
	var cc = emailArrayToList( ss.jsonStruct.cc );

	writedump( to );
	writedump( cc );
	abort;
	*/

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
	if(qContact.recordcount){
		for(row2 in qContact){
			row=row2;
		}
	}
	return row;
	</cfscript>
</cffunction>

 
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

 --->
<cffunction name="getFromAddressForContact" localmode="modern" access="public">
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
</cffunction>

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