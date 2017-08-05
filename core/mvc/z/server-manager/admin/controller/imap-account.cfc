<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript> 
		if ( structKeyExists( form, 'zid' ) EQ false ) {
			form.zid = application.zcore.status.getNewId();
			if ( structKeyExists( form, 'sid' ) ) {
				application.zcore.status.setField( form.zid, 'site_id', form.sid );
			}
		}
		form.sid = application.zcore.status.getField( form.zid, 'site_id' );
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
		var db = request.zos.queryObject;
		application.zcore.user.requireAllCompanyAccess();
		application.zcore.adminSecurityFilter.requireFeatureAccess( 'Server Manager' );

		db.sql = 'SELECT *
			FROM #db.table( 'imap_account', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND imap_account_id = #db.param( application.zcore.functions.zso( form, 'imap_account_id' ) )#
				AND imap_account_deleted = #db.param( 0 )#';
		qCheck = db.execute( 'qCheck' );

		if ( qCheck.recordcount EQ 0 ) {
			application.zcore.status.setStatus( request.zsid, 'IMAP Account no longer exists', false, true );
			application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/index?zsid=#request.zsid#&zid=#form.zid#&sid=#request.zos.globals.id#' );
		}
	</cfscript>
	<cfif structKeyExists( form, 'confirm' )>
		<cfscript>
			db.sql = 'DELETE FROM #db.table( 'imap_account', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND imap_account_id = #db.param( application.zcore.functions.zso( form, 'imap_account_id' ) )#
					AND imap_account_deleted = #db.param( 0 )#';
			q = db.execute( 'q' );

			application.zcore.status.setStatus( request.zsid, 'IMAP Account deleted' );
			application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/index?zsid=#request.zsid#&zid=#form.zid#&sid=#request.zos.globals.id#' );
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this IMAP Account?<br />
			<br />
			#qCheck.imap_account_host#<br />
			<br />
			<a href="/z/server-manager/admin/imap-account/delete?confirm=1&imap_account_id=#form.imap_account_id#&zid=#form.zid#&sid=#request.zos.globals.id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/imap-account/index?zid=#form.zid#&sid=#request.zos.globals.id#">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
		this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
		var db = request.zos.queryObject;
		application.zcore.user.requireAllCompanyAccess();
		application.zcore.adminSecurityFilter.requireFeatureAccess( 'Server Manager' );

		var ts = {};
		var result = 0;

		if ( form.method EQ 'insert' ) {
			form.imap_account_id = '';
		}

		form.imap_account_ssl = application.zcore.functions.zso( form, 'imap_account_ssl' );
		form.imap_account_require_auth = application.zcore.functions.zso( form, 'imap_account_require_auth' );

		var errors = false;

		ts.imap_account_host.required = true;
		ts.imap_account_user.required = true;
		ts.imap_account_pass.required = true;
		ts.imap_account_port.required = true;

		result = application.zcore.functions.zValidateStruct( form, ts, request.zsid, true );


		if ( result ) {
			application.zcore.status.setStatus( request.zsid, false, form, true );
			if ( form.method EQ 'insert' ) {
				application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/add?zsid=#request.zsid#&zid=#form.zid#&sid=#request.zos.globals.id#' );
			} else {
				application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/edit?imap_account_id=#form.imap_account_id#&zsid=#request.zsid#&zid=#form.zid#&sid=#request.zos.globals.id#' );
			}
		}



		ts = StructNew();
		ts.table = 'imap_account';
		ts.datasource = request.zos.zcoreDatasource;
		ts.struct = form;

		if ( form.method EQ 'insert' ) {
			form.imap_account_id = application.zcore.functions.zInsert( ts );
			if ( form.imap_account_id EQ false ) {
				application.zcore.status.setStatus( request.zsid, 'Failed to save IMAP Account.', form, true );
				application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/add?zid=#form.zid#&sid=#request.zos.globals.id#&zsid=#request.zsid#' );
			} else {
				application.zcore.status.setStatus( request.zsid, 'IMAP Account saved.' );
				application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/index?zid=#form.zid#&sid=#request.zos.globals.id#&zsid=#request.zsid#' );
			}
		} else {
			if ( application.zcore.functions.zUpdate( ts ) EQ false ) {
				application.zcore.status.setStatus( request.zsid, 'Failed to save IMAP Account.', form, true );
				application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/edit?imap_account_id=#form.imap_account_id#&zid=#form.zid#&sid=#request.zos.globals.id#&zsid=#request.zsid#' );
			} else {
				application.zcore.status.setStatus(request.zsid, 'IMAP Account updated.');
				application.zcore.functions.zRedirect( '/z/server-manager/admin/imap-account/index?zid=#form.zid#&sid=#request.zos.globals.id#&zsid=#request.zsid#' );
			}
		}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
		this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
		var db = request.zos.queryObject;
		var currentMethod = form.method;

		application.zcore.user.requireAllCompanyAccess();
		application.zcore.adminSecurityFilter.requireFeatureAccess( 'Server Manager' );

		if ( application.zcore.functions.zso( form, 'imap_account_id' ) EQ '' ) {
			form.imap_account_id = -1;
		}

		db.sql = 'SELECT *
			FROM #db.table( 'imap_account', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND imap_account_id = #db.param( application.zcore.functions.zso( form, 'imap_account_id' ) )#
				AND imap_account_deleted = #db.param( 0 )#';
		qIMAP = db.execute( 'qIMAP' );

		application.zcore.functions.zQueryToStruct( qIMAP, form, 'imap_account_id' );

		if ( currentMethod EQ 'add' ) {
			form.imap_account_id = '';
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		}
		application.zcore.functions.zStatusHandler( request.zsid, true );

		echo( '<h2>' );

		action = '/z/server-manager/admin/imap-account/';
		if ( currentMethod EQ 'add' ) {
			action &= 'insert?zid=#form.zid#&sid=#request.zos.globals.id#';
			echo( 'Add' );
		} else {
			action &= 'update?imap_account_id=#form.imap_account_id#&zid=#form.zid#&sid=#request.zos.globals.id#';
			echo ( 'Edit' );
		}
		echo ( ' IMAP Account</h2>' );
	</cfscript>
	<p>* denotes required field.</p>
	<form class="zFormCheckDirty" action="#action#" method="post" enctype="multipart/form-data">
		<table style="width: 100%;" class="table-list">
			<tr>
				<th style="width: 1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/server-manager/admin/imap-account/index';">Cancel</button>
				</td>
			</tr>
			<tr>
				<th>Host</th>
				<td><input type="text" name="imap_account_host" style="width:40%;" value="#htmlEditFormat( form.imap_account_host )#" /> *</td>
			</tr>
			<tr>
				<th>Username</th>
				<td><input type="text" name="imap_account_user" style="width:40%;" value="#htmlEditFormat( form.imap_account_user )#" /> *</td>
			</tr>
			<tr>
				<th>Password</th>
				<td><input type="text" name="imap_account_pass" style="width:40%;" value="#htmlEditFormat( form.imap_account_pass )#" /> *</td>
			</tr>
			<tr>
				<th>Port</th>
				<td><input type="text" name="imap_account_port" style="width:40%;" value="#htmlEditFormat( form.imap_account_port )#" /> *</td>
			</tr>
			<tr>
				<th>SSL?</th>
				<cfscript>
					if ( form.imap_account_ssl EQ '' ) {
						form.imap_account_ssl = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'imap_account_ssl', application.zcore.functions.zso( form, 'imap_account_ssl' ) )#</td>
			</tr>
			<tr>
				<th>Require Auth?</th>
				<cfscript>
					if ( form.imap_account_require_auth EQ '' ) {
						form.imap_account_require_auth = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'imap_account_require_auth', application.zcore.functions.zso( form, 'imap_account_require_auth' ) )#</td>
			</tr>
			<tr>
				<th style="width: 1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/server-manager/admin/imap-account/index?zid=#form.zid#&sid=#request.zos.globals.id#';">Cancel</button>
				</td>
			</tr>
		</table>
	</form>

</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db = request.zos.queryObject; 
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	//application.zcore.functions.zSetPageHelpId("8.1.1.9.1");
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript> 
	<h2>Manage IMAP Accounts</h2>
	<cfscript>
	db.sql="SELECT * FROM #db.table("imap_account", request.zos.zcoreDatasource)# 
	WHERE imap_account_deleted = #db.param(0)# and 
	site_id = #db.param(form.sid)#
	ORDER BY imap_account_host asc";
	qIMAP=db.execute("qIMAP");
	</cfscript>

	<p><a href="/z/server-manager/admin/imap-account/add?zid=#form.zid#&sid=#request.zos.globals.id#">Add IMAP Account</a></p>

	<cfif qIMAP.recordcount EQ 0>
		<p>There are no IMAP Accounts attached to this site.</p>
	<cfelse>
		<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>Host</th>
			<th>Port</th>
			<th>User</th>
			<th>SSL</th>
			<th>Require Auth</th>
			<th>Last Updated</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qIMAP"> 
			<tr>
				<td>#qIMAP.imap_account_host#</td>
				<td>#qIMAP.imap_account_port#</td>
				<td>#qIMAP.imap_account_user#</td>
				<cfif qIMAP.imap_account_ssl EQ 1>
					<td>Yes</td>
				<cfelse>
					<td>No</td>
				</cfif>
				<cfif qIMAP.imap_account_require_auth EQ 1>
					<td>Yes</td>
				<cfelse>
					<td>No</td>
				</cfif>
				<td>#application.zcore.functions.zGetLastUpdatedDescription( qIMAP.imap_account_updated_datetime )#</td>
				<td>
					<a href="/z/server-manager/admin/imap-account/edit?imap_account_id=#qIMAP.imap_account_id#">Edit</a> | 
					<a href="/z/server-manager/admin/imap-account/delete?imap_account_id=#qIMAP.imap_account_id#">Delete</a>
				</td>
			</tr>
		</cfloop>
		</table>
	</cfif>

</cffunction>
</cfoutput>
</cfcomponent>
