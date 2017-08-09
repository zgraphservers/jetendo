<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>

	</cfscript>
</cffunction>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	init();
	var db = request.zos.queryObject;

	numberOfQueuePops = 5; // process X emails at a time.
	// doesn't work yet
 	ts={
 		from:'Horrible Slacker <bruce+testid2@skyflare.com>',
 		to:'Custom Label2 <bruce.kirkpatrick@zgraph.com>',
 		subject:"Test Subject",
 		text:"Simple text email",
 		spoolenable:false
 	}
 	/*
 	//works:
 	mail to="Custom Label2 <bruce.kirkpatrick@zgraph.com>" from="Horrible Slacker <bruce+testid@skyflare.com>" subject="Test subject 2"{
	 	echo('Simple text email 2');
	 } 
	// also works if contact is not in address book already:
 	mail to="Custom Label2 <bruce.kirkpatrick@zgraph.com>" from="Horrible Slacker2 <bruce@skyflare.com>" subject="Test subject 2"{
	 	echo('Simple text email 2');
	 }
	 abort;
	 */
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rCom.setStatusErrors(request.zsid);
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zabort();
	}
 	abort;
			customerCom = createObject( 'component', 'zcorerootmapping.com.app.customer' ); 
			// 1.U15.123123123.123213123
			rs=customerCom.getFromAddressForUser(15, 298, 16318); 
			writedump(rs);
			abort;
	while ( true ) {
		nowDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
		// only process ones that were scheduled in the past, this avoids the use of LIMIT statement as long as we ALWAYS mark them with a new scheduled date if there is a failure.
		// process emails for all sites at once based on scheduling
		db.sql = 'SELECT *
		FROM #db.table( 'queue_pop', request.zos.zcoreDatasource )#
		WHERE site_id <> #db.param(-1)#	and 
		queue_pop_deleted = #db.param( 0 )# and 
		queue_pop_scheduled_processing_datetime < #db.param(nowDate)# 
		ORDER BY queue_pop_scheduled_processing_datetime ASC 
		LIMIT #db.param(0)#, #db.param( numberOfQueuePops )#';
		qQueuePop = db.execute( 'qQueuePop' ); 

		if ( qQueuePop.recordcount EQ 0 ) { 
			break;
		} else {  
			for ( row in qQueuePop ) {
				nowDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
				// Get email message JSON
				jsonStruct = deserializeJSON( row.queue_pop_message_json );

				rs=processPlusId(row, jsonStruct);
				if(not rs.success){
					scheduledDatetime=dateAdd("s", row.queue_pop_process_retry_interval_seconds, nowDate);
					scheduledDatetime=dateformat(scheduledDatetime, 'yyyy-mm-dd')&' '&timeformat(scheduledDatetime, 'HH:mm:ss'); 
				writedump(rs);
					// the from address was tampered with, may be spam.
					db.sql = 'UPDATE #db.table( 'queue_pop', request.zos.zcoreDatasource )# 
					SET queue_pop_scheduled_processing_datetime = #db.param(scheduledDatetime)#, 
					queue_pop_process_fail_count=#db.param(row.queue_pop_process_fail_count+1)#, 
					queue_pop_updated_datetime=#db.param(nowDate)# 
					WHERE site_id = #db.param(row.site_id)# and 
					queue_pop_deleted = #db.param( 0 )# and 
					queue_pop_scheduled_processing_datetime < #db.param(nowDate)# ';
					db.execute( 'qUpdate' );
				} 

				writedump( jsonStruct );
				abort;

				// Send email?
				var to = emailArrayToList( jsonStruct.to );
				var cc = emailArrayToList( jsonStruct.cc );

				writedump( to );
				writedump( cc );
				abort;


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

				// var rs = customerCom.scheduleLeadEmail( ts );

				var rs = {
					success: false
				};

				if ( rs.success ) {

				} else { 
				}
				*/
			} 

		}
	}

	abort;
	</cfscript>
</cffunction>

<cffunction name="emailArrayToList" localmode="modern" access="private">
	<cfargument name="emailArray" type="array" required="yes">
	<cfscript>
	var arrEmail=[];
	for(email in arguments.emailArray){
		if ( email.name EQ '' ) {
			arrayAppend(arrEmail, email);
		} else {
			arrayAppend(arrEmail, email.name & ' <' & email.email & '>');
		}
	}
	return arrayToList(arrEmail, ', ');
	</cfscript>
</cffunction>

<cffunction name="processPlusId" localmode="modern" access="public">
	<cfargument name="messageStruct" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	rs={
		success:true,
		messageStruct:arguments.messageStruct,
		jsonStruct:arguments.jsonStruct
	}; 
	// process and route based on jsonStruct.plusId
	if(jsonStruct.plusId EQ ""){
		// this will be routed to default location instead
		customerCom.processNewMessage(rs); 

	}else{
		arrPlus=listToArray(jsonStruct.plusId, ".");

		if(arrPlus[1] EQ "1"){
			customerCom = createObject( 'component', 'zcorerootmapping.com.app.customer' );

			if(jsonStruct.plusId EQ ""){
				// this will be routed to default location instead
				customerCom.processNewMessage(rs); 
			}
			if(arraylen(arrPlus) NEQ 4){
				return {success:false, errorMessage:"Plus address must have 4 parts for appId=1."};
			}
			rs.inquiries_id=arrPlus[4];
			// route to inquiries_feedback
			if(len(arrPlus[2]) EQ 0){
				// invalid message
				return {success:false, errorMessage:"Customer/user id was empty"};
			}
			if(left(arrPlus[2], 1) EQ "C"){
				// customer
				rs.customer_id=removeChars(arrPlus[2],1,1);
				rs.customer_des_key=arrPlus[3];

				// we store the validation boolean and let the application decide whether to continue routing the message or not
				rs.validHash=verifyDESLimit16FromAddressForCustomer(rs.customer_id, rs.messageStruct.site_id, arrPlus[4], arrPlus[3]);
 
			}else if(left(arrPlus[2], 1) EQ "U"){
				// user
				rs.user_id=removeChars(arrPlus[2],1,1);
				rs.user_des_key=arrPlus[3];

				// we store the validation boolean and let the application decide whether to continue routing the message or not
				rs.validHash=verifyDESLimit16FromAddressForUser(rs.user_id, rs.messageStruct.site_id, arrPlus[4], arrPlus[3]);
			}else{
				return {success:false, errorMessage:"Expected customer/user id to start with C or U"};
			}
			// inquiriesApp.userId.inquiriesId 

			customerCom.processMessage(rs); 
		}else{
			// haven't implemented this routing yet
			// route to default or discard...
			return {success:false, errorMessage:"Plus address appId=#arrPlus[1]# is not implemented."};
		}
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
