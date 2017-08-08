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

		customerCom = createObject( 'component', 'zcorerootmapping.com.app.customer' );

		haveQueuePops = true;
		queuePopOffset = 0;
		numberOfQueuePops = 30;

		while ( haveQueuePops ) {
			// Add date to WHERE statement
			db.sql = 'SELECT *
				FROM #db.table( 'queue_pop', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND queue_pop_deleted = #db.param( 0 )#
				LIMIT #db.param( queuePopOffset )#, #db.param( numberOfQueuePops )#';
			qQueuePop = db.execute( 'qQueuePop' );

			if ( qQueuePop.recordcount EQ 0 ) {
				haveQueuePops = false;
				break;
			} else {
				queuePopOffset = ( queuePopOffset + numberOfQueuePops );

				failedQueuePopArray = [];

				for ( messageStruct in qQueuePop ) {
					// Get email message JSON
					var jsonStruct = deserializeJSON( messageStruct.queue_pop_message_json );
 
					rs=validatePlusId(queuePop, message);
					if(not rs.success){
						// the from address was tampered with, may be spam.
					} 

					writedump(rs);
					abort;
					// Send email - don't think i want to use scheduleLeadEmail anymore.
/*
					var ts = {
						forceUniqueType: true, // prevent multiple scheduled emails of the same type
						// required
						data: {
							inquiries_type_id: '',
							inquiries_type_id_siteIDType: '',
							email_queue_unique: '1', // 1 is unique and 0 allows multiple entries for this type for the same email_queue_to address.
							email_queue_from: '',
							email_queue_to: '',
							email_queue_subject: message.subject,
							email_queue_html: message.html,
							email_queue_send_datetime: dateAdd( 'm', 30, now() ),
							// optional
							email_queue_cc: '',
							email_queue_bcc: '',
							email_queue_text: '',
							site_id: request.zos.globals.id
						}
					};

					var rs = customerCom.scheduleLeadEmail( ts );
*/

					var rs = {
						success: false
					};

					if ( rs.success ) {

					} else {
						arrayAppend( failedQueuePopArray, queuePop );
					}
				}

				if ( arrayLen( failedQueuePopArray ) GT 0 ) {
					// Loop through failedQueuePop
					var queuePopIdList = '';
					for ( failedQueuePop in failedQueuePopArray ) {
						queuePopIdList &= failedQueuePop.queue_pop_id & ',';
					}

					// Remove trailing comma
					queuePopIdList = left( queuePopIdList, ( len( queuePopIdList ) - 1 ) );

					db.sql = 'UPDATE #db.table( 'queue_pop', request.zos.zcoreDatasource )#
						SET queue_pop_process_fail_count = ( queue_pop_process_fail_count + #db.param( 1 )# ),
							queue_pop_updated_datetime = #db.param( request.zos.mysqlnow )#,
							queue_pop_scheduled_processing_datetime = #db.param( request.zos.mysqlnow )#,
							queue_pop_process_retry_interval_seconds = #db.param( 3600 )#
						WHERE site_id = #db.param( request.zos.globals.id )#
							AND queue_pop_id IN ( #db.param( queuePopIdList )# )';
					q = db.execute( 'q' );

					echo( 'FAILED' );
					writedump( failedQueuePopArray );
					abort;
				}
			}
		}

		abort;
	</cfscript>
</cffunction>


<cffunction name="validatePlusId" localmode="modern" access="public">
	<cfargument name="messageStruct" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	rs={
		success:true
	};
	process and route based on messageStruct.plusId
	if(message.plusId EQ ""){
		
	}else{
		arrPlus=listToArray(message.plusId, ".");

		/*
		// inquiries reply format: 1.C#customer_id#.#desHashLimit16#.#inquiries_id# or U#user_id#.#desHashLimit16#.#inquiries_id#
		validate plusId against database
			get qUser.user_des_key from database
			getFromAddressForCustomer
			customer_des_key
			getFromAddressForUser
			user_des_key
			*/
		if(arrPlus[1] EQ "1"){
			if(arraylen(arrPlus) NEQ 4){
				return {success:false, errorMessage:"Plus address must have 4 parts for appId=1."};
			}
			// route to inquiries_feedback
			if(len(arrPlus[2]) EQ 0){
				// invalid message
				return {success:false};
			}
			if(left(arrPlus[2], 1) EQ "C"){
				// customer
				rs.customer_id=removeChars(arrPlus[1],1,1);
			}else if(left(arrPlus[2], 1) EQ "U"){
				// user
				rs.user_id=removeChars(arrPlus[2],1,1);
			}
			// inquiriesApp.userId.inquiriesId 
				ts={
					message:message,
					user_id:arrPlus[2],
					inquiries_id:arrPlus[3]
				};
				customerCom.processMessage(ts);
				continue;
			}
		}
		// haven't implemented this routing yet
		// route to default or discard...
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
