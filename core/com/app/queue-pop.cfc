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

				for ( queuePop in qQueuePop ) {
					// Get email message JSON
					var message = deserializeJSON( queuePop.queue_pop_message_json );

					/*

					process and route based on message.plusId
					if(message.plusId EQ ""){
						
					}else{
						validate plusId against database
							create from address with qUser.user_des_salt and 
							getFromAddressForCustomer
							customer_des_key
							getFromAddressForUser
							user_des_key

						arrPlus=listToArray(message.plusId, ".");
						// inquiriesApp.userId.inquiriesId
						if(arrPlus[1] EQ "1"){
							if(arraylen(arrPlus) EQ 3){
								// route to inquiries_feedback
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

					*/
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

</cfoutput>
</cfcomponent>
