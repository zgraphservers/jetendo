<cfcomponent>
<cfoutput>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
		// Need to do something else here so that things like privy signup modals don't come up on this page.
		application.zcore.skin.disableGlobalHTMLHeadCode();
		application.zcore.template.setTemplate( 'root.templates.empty', true, true );

		if ( NOT structKeyExists( form, 'email' ) ) {
			throw( 'Email address required.' );
		}
		if ( NOT structKeyExists( form, 'autoresponder_id' ) ) {
			throw( 'Autoresponder ID required.' );
		}

	</cfscript>
	<div class="z-pv-40 z-text-center">
		<p>Are you sure that you want to unsubscribe from #request.zos.globals.sitename# emails?</p>
		<p><a href="/z/inquiries/autoresponder-unsubscribe/confirm?email=#form.email#&autoresponder_id=#form.autoresponder_id#" style="text-decoration: underline;">Unsubscribe</a> &nbsp; &nbsp; <a href="/" style="text-decoration: underline;">Cancel</a></p>
	</div>
</cffunction>

<cffunction name="confirm" localmode="modern" access="remote">
	<cfscript>
		var db = request.zos.queryObject;

		application.zcore.template.setTemplate( 'root.templates.empty', true, true );

		if ( NOT structKeyExists( form, 'email' ) ) {
			throw( 'Email address required.' );
		}
		if ( NOT structKeyExists( form, 'autoresponder_id' ) ) {
			throw( 'Autoresponder ID required.' );
		}

		db.sql = 'UPDATE #db.table( 'mail_user', request.zos.zcoreDatasource )#
			SET mail_user_opt_in = #db.param( 0 )#,
				mail_user_updated_datetime = #db.param( request.zOS.mysqlnow )#
			WHERE site_id = #db.param( request.zOS.globals.id )#
				AND mail_user_email = #db.param( form.email )#
				AND mail_user_deleted = #db.param( 0 )#';

		// Verify unsubscribed.
		if ( NOT db.execute( 'qMailUser' ) ) {
			throw( 'Failed to unsubscribe mail user' );
		}

		db.sql = 'UPDATE #db.table( 'inquiries_autoresponder_subscriber', 'jetendo_dev' )#
			SET inquiries_autoresponder_subscriber_subscribed = #db.param( 0 )#,
				inquiries_autoresponder_subscriber_completed = #db.param( 1 )#
			WHERE site_id = #db.param( request.zOS.globals.id )#
				AND inquiries_autoresponder_subscriber_email = #db.param( form.email )#
				AND inquiries_autoresponder_id = #db.param( form.autoresponder_id )#
				AND inquiries_autoresponder_subscriber_deleted = #db.param( 0 )#';

		// Verify unsubscribed.
		if ( NOT db.execute( 'qAutoresponderSubscriber' ) ) {
			throw( 'Failed to unsubscribe autoresponder subscriber' );
		}

		logStruct = {
			'inquiries_autoresponder_id': form.autoresponder_id,
			'inquiries_autoresponder_drip_id': 0,
			'inquiries_autoresponder_drip_log_email': form.email,
			'inquiries_autoresponder_drip_log_status': 'unsubscribed'
		};

		this.logEmailStatus( logStruct );
	</cfscript>

	<div class="z-pv-40 z-text-center">
		<p>You have been unsubscribed from #request.zos.globals.sitename# emails.</p>
		<p><a href="/" style="text-decoration: underline;">Go to Homepage</a></p>
	</div>
</cffunction>

<cffunction name="logEmailStatus" localmode="modern" access="private">
	<cfargument name="logStruct" type="struct" required="yes">
	<cfscript>
		logStruct = arguments.logStruct;

		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_id' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_id is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_id' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_id is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_log_email' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_log_email is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_log_status' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_log_status is required' );
		}

		logStruct.inquiries_autoresponder_drip_log_id = null;
		logStruct.site_id = request.zos.globals.id;
		logStruct.inquiries_autoresponder_drip_log_datetime = request.zOS.mysqlnow;

		ts = structNew();

		ts.table      = 'inquiries_autoresponder_drip_log';
		// ts.datasource = request.zos.zcoreDatasource;
		ts.datasource = 'jetendo_dev';
		ts.struct     = logStruct;

		rs = application.zcore.functions.zInsert( ts );

		if ( rs EQ false ) {
			throw( 'Failed to log ' & logStruct.inquiries_autoresponder_drip_log_status & ' status' );
		}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>