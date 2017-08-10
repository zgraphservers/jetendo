<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){ 
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips."); 
	}
	</cfscript>
</cffunction>
<cffunction name="cancel" localmode="modern" access="remote">
	<cfscript>
	init();
	var db = request.zos.queryObject;

	application.queuePopCancel=true;
	</cfscript>	
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	init();
	var db = request.zos.queryObject;
	setting requesttimeout="100";

	numberOfQueuePops = 5; // process X emails at a time.
	// doesn't work yet
	/*
 	ts={
 		from:'Horrible Slacker <bruce+testid2@skyflare.com>',
 		to:'Custom Label2 <bruce.kirkpatrick@zgraph.com>',
 		subject:"Test Subject",
 		text:"Simple text email",
 		spoolenable:false
 	} 
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rCom.setStatusErrors(request.zsid);
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zabort();
	}
 	abort;*/
 	request.contactCom = createObject( 'component', 'zcorerootmapping.com.app.contact' ); 
	/*
	// 1.U15.123123123.123213123
	rs=request.contactCom.getFromAddressForUser(15, 298, 16318); 
	writedump(rs);
	abort;*/
	// inquiries_id is 16318
	/*rs=request.contactCom.getFromAddressForUser(15, 298, "16318"); 
	writedump(rs);
	abort;*/
	processCount=0;
	startTime=gettickcount();
	if(structkeyexists(application, 'queuePopRunning')){
		echo('queue-pop is already running, please wait or <a href="##">Cancel it</a>');
		abort;
	}
	application.queuePopRunning=true;
	try{
		while ( true ) {
			if(structkeyexists(application, 'queuePopCancel')){
				echo('queuePopCancelled');
				structdelete(application, 'queuePopCancel');
				break;
			}
			if(gettickcount()-startTime GT 55){
				break;
			}
			nowDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
			// only process ones that were scheduled in the past, this avoids the use of LIMIT statement as long as we ALWAYS mark them with a new scheduled date if there is a failure.
			// process emails for all sites at once based on scheduling
			db.sql = 'SELECT *
			FROM #db.table( 'queue_pop', request.zos.zcoreDatasource )#
			WHERE site_id <> #db.param(-1)#	and 
			queue_pop_deleted = #db.param( 0 )# and 
			queue_pop_process_fail_count < #db.param(3)# and 
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
					//writedump(row);
					//writedump(jsonStruct);
					//abort;

					// TODO: implement the robot and security filters here - Jake started these already
					// we want all processing to occur before the specific application does its own processing.


					// to debug, this is a valid plusId with des limit 16 applied and a real inquiries_id on test site
					jsonStruct.plusId="1.U15.0B0D3C80B74E4B0E.16318";
					rs=processPlusId(row, jsonStruct);
					if(not rs.success){
						if(row.queue_pop_process_retry_interval_seconds EQ 0){
							// prevent 0
							row.queue_pop_process_retry_interval_seconds=60;
						}
						scheduledDatetime=dateAdd("s", row.queue_pop_process_retry_interval_seconds, nowDate);
						scheduledDatetime=dateformat(scheduledDatetime, 'yyyy-mm-dd')&' '&timeformat(scheduledDatetime, 'HH:mm:ss'); 
						// the from address was tampered with, may be spam.
						echo('reschedule queue_pop:#row.queue_pop_id#<br>');
						/*
						db.sql = 'UPDATE #db.table( 'queue_pop', request.zos.zcoreDatasource )# 
						SET queue_pop_scheduled_processing_datetime = #db.param(scheduledDatetime)#, 
						queue_pop_process_fail_count=#db.param(row.queue_pop_process_fail_count+1)#, 
						queue_pop_updated_datetime=#db.param(nowDate)# 
						WHERE site_id = #db.param(row.site_id)# and 
						queue_pop_deleted = #db.param( 0 )# and 
						queue_pop_scheduled_processing_datetime < #db.param(nowDate)# ';
						db.execute( 'qUpdate' );
						*/
					}else{
						echo('delete queue_pop:#row.queue_pop_id#<br>');
						/*
						// This message was successfully processed, and we can safely delete the queue_pop record now.
						db.sql="delete from #db.table( 'queue_pop', request.zos.zcoreDatasource )#  
						WHERE site_id = #db.param(row.site_id)# and 
						queue_pop_deleted = #db.param( 0 )# and 
						queue_pop_id = #db.param(row.queue_pop_id)# ';
						db.execute( 'qDelete' );

						*/
					} 
					processCount++;

				}  
				// uncomment break; for debugging only - because we aren't running real delete / update above, we have to force a break at the end of the loop
				break;
			}
		}
	}catch(Any e){
		structdelete(application, 'queuePopRunning'); 
	}
	structdelete(application, 'queuePopRunning');
	echo('Processed #processCount# emails.');
	abort;
	</cfscript>
</cffunction>

<cffunction name="processPlusId" localmode="modern" access="public">
	<cfargument name="messageStruct" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	jsonStruct=arguments.jsonStruct;
	rs={
		success:true,
		messageStruct:arguments.messageStruct,
		jsonStruct:arguments.jsonStruct
	}; 
	// process and route based on jsonStruct.plusId
	if(jsonStruct.plusId EQ ""){
		// this will be routed to default location instead
		request.contactCom.processNewMessage(rs); 

	}else{
		arrPlus=listToArray(jsonStruct.plusId, ".");

		if(arrPlus[1] EQ "1"){
			request.contactCom = createObject( 'component', 'zcorerootmapping.com.app.contact' );

			if(jsonStruct.plusId EQ ""){
				// this will be routed to default location instead
				request.contactCom.processNewMessage(rs); 
			}
			if(arraylen(arrPlus) NEQ 4){
				return {success:false, errorMessage:"Plus address must have 4 parts for appId=1."};
			}
			rs.inquiries_id=arrPlus[4];
			// route to inquiries_feedback
			if(len(arrPlus[2]) EQ 0){
				// invalid message
				return {success:false, errorMessage:"Contact/user id was empty"};
			}
			if(left(arrPlus[2], 1) EQ "C"){
				// contact
				rs.contact_id=removeChars(arrPlus[2],1,1);
				rs.contact_des_key=arrPlus[3];

				// we store the validation boolean and let the application decide whether to continue routing the message or not
				rs.validHash=request.contactCom.verifyDESLimit16FromAddressForContact(rs.contact_id, rs.messageStruct.site_id, arrPlus[4], arrPlus[3]);
 
			}else if(left(arrPlus[2], 1) EQ "U"){
				// user
				rs.user_id=removeChars(arrPlus[2],1,1);
				rs.user_des_key=arrPlus[3];

				// we store the validation boolean and let the application decide whether to continue routing the message or not
				rs.validHash=request.contactCom.verifyDESLimit16FromAddressForUser(rs.user_id, rs.messageStruct.site_id, arrPlus[4], arrPlus[3]);
			}else{
				return {success:false, errorMessage:"Expected contact/user id to start with C or U"};
			}
			// inquiriesApp.userId.inquiriesId 

			return request.contactCom.processMessage(rs); 
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
