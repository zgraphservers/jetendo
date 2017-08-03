<cfcomponent>
<cfoutput> 
<!--- 
in addition to working for manager users, it must work for external users (i.e. userIndex)



index (including search)
	same stuff as inquiry, but not assignee
edit / update
	allow changing the basic fields
	no custom fields yet
view
	shows basic fields
	shows inquiries attached

userView & userIndex - Allow non-manager users to view only the customers they have leads for.   This requires a slower join on inquiries table.

when a new lead comes in, we should apply the newest mapped data to the customer record, i.e. product of interest, phone number, address, augmenting it.

later:
export
 --->

<cffunction name="init" localmode="modern" access="private" roles="user">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript>
		// application.zcore.functions.z404("handle security");

		index();
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
		var db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'customer', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND customer_id = #db.param( form.customer_id )#
				AND customer_deleted = #db.param( 0 )#';
		qCheck = db.execute( 'qCheck' );

		if ( qCheck.recordcount EQ 0 ) {
			application.zcore.status.setStatus( request.zsid, 'Customer no longer exists', false, true );
			application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/index?zsid=#request.zsid#' );
		}
	</cfscript>
	<cfif structKeyExists( form, 'confirm' )>
		<cfscript>
			db.sql = 'DELETE FROM #db.table( 'customer', request.zos.zcoreDatasource )#
				WHERE site_id = #db.pram( request.zos.globals.id )#
					AND customer_id = #db.param( form.customer_id )#
					AND customer_deleted = #db.param( 0 )#';
			q = db.execute( 'q' );

			application.zcore.status.setStatus( request.zsid, 'Customer deleted' );
			application.zcore.functions.zRedirect( '/z/inquiries/admin/manager-customer/index?zsid=#request.zsid#' );
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this Customer?<br />
			<br />
			#qCheck.customer_first_name# #qCheck.customer_last_name#<br />
			#qCheck.customer_email#<br />
			<br />
			<a href="/z/inquiries/admin/manage-customer/delete?confirm=1&customer_id=#form.customer_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/manage-customer/index">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
		this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
		var db = request.zos.queryObject;

		var ts = {};
		var result = 0;

		if ( form.method EQ 'insert' ) {
			form.customer_id = '';
		}

		var errors = false;

		ts.customer_first_name.required = true;
		ts.customer_last_name.required = true;
		ts.customer_email.required = true;

		result = application.zcore.functions.zValidateStruct( form, ts, request.zsid, true );

		if ( result ) {
			application.zcore.status.setStatus( request.zsid, false, form, true );
			if ( form.method EQ 'insert' ) {
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/add?zsid=#request.zsid#' );
			} else {
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/edit?customer_id=#form.customer_id#&zsid=#request.zsid#' );
			}
		}

		ts = StructNew();
		ts.table = 'customer';
		ts.datasource = request.zos.zcoreDatasource;
		ts.struct = form;

		if ( form.method EQ 'insert' ) {
			form.customer_id = application.zcore.functions.zInsert( ts );
			if ( form.customer_id EQ false ) {
				application.zcore.status.setStatus( request.zsid, 'Failed to save Customer.', form, true );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/add?zsid=#request.zsid#' );
			} else {
				application.zcore.status.setStatus( request.zsid, 'Customer saved.' );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/index?zsid=#request.zsid#' );
			}
		} else {
			if ( application.zcore.functions.zUpdate( ts ) EQ false ) {
				application.zcore.status.setStatus( request.zsid, 'Failed to save Customer.', form, true );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/edit?customer_id=#form.customer_id#&zsid=#request.zsid#' );
			} else {
				application.zcore.status.setStatus( request.zsid, 'Customer updated.' );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/index?zsid=#request.zsid#' );
			}
		}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
		this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript>
		var db = request.zos.queryObject;
		var currentMethod = form.method;

		if ( application.zcore.functions.zso( form, 'customer_id' ) EQ '' ) {
			form.customer_id = -1;
		}

		db.sql = 'SELECT *
			FROM #db.table( 'customer', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND customer_id = #db.param( application.zcore.functions.zso( form, 'customer_id' ) )#
				AND customer_deleted = #db.param( 0 )#';
		qCustomer = db.execute( 'qCustomer' );

		application.zcore.functions.zQueryToStruct( qCustomer, form, 'customer_id' );

		if ( currentMethod EQ 'add' ) {
			form.customer_id = '';
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		}
		application.zcore.functions.zStatusHandler( request.zsid, true );

		echo( '<h2>' );

		action = '/z/inquiries/admin/manage-customer/';
		if ( currentMethod EQ 'add' ) {
			action &= 'insert';
			echo( 'Add' );
		} else {
			action &= 'update?customer_id=#form.customer_id#';
			echo( 'Edit' );
		}
		echo( ' Customer</h2>' );
	</cfscript>
	<p>* denotes required field.</p>
	<form class="zFormCheckDirty" action="#action#" method="post" enctype="multipart/form-data">
		<table style="width: 100%;" class="table-list">
			<tr>
				<th style="width: 25%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/inquiries/admin/manage-customer/index';">Cancel</button>
				</td>
			</tr>
			<tr>
				<th>Office ID</th>
				<td><input type="text" name="office_id" style="width:40%;" value="#htmlEditFormat( form.office_id )#" /></td>
			</tr>
			<tr>
				<th>Salutation</th>
				<td><input type="text" name="customer_salutation" style="width:40%;" value="#htmlEditFormat( form.customer_salutation )#" /></td>
			</tr>
			<tr>
				<th>First Name</th>
				<td><input type="text" name="customer_first_name" style="width:40%;" value="#htmlEditFormat( form.customer_first_name )#" /> *</td>
			</tr>
			<tr>
				<th>Last Name</th>
				<td><input type="text" name="customer_last_name" style="width:40%;" value="#htmlEditFormat( form.customer_last_name )#" /> *</td>
			</tr>
			<tr>
				<th>Suffix</th>
				<td><input type="text" name="customer_suffix" style="width:40%;" value="#htmlEditFormat( form.customer_suffix )#" /></td>
			</tr>
			<tr>
				<th>Company</th>
				<td><input type="text" name="customer_company" style="width:40%;" value="#htmlEditFormat( form.customer_company )#" /></td>
			</tr>
			<tr>
				<th>Job Title</th>
				<td><input type="text" name="customer_job_title" style="width:40%;" value="#htmlEditFormat( form.customer_job_title )#" /></td>
			</tr>
			<tr>
				<th>Email Address</th>
				<td><input type="text" name="customer_email" style="width:40%;" value="#htmlEditFormat( form.customer_email )#" /> *</td>
			</tr>
			<tr>
				<th>Birthday</th>
				<td>#application.zcore.functions.zDateSelect( 'customer_birthday', 'customer_birthday', 1900, year( now() ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Phone 1</th>
				<td><input type="text" name="customer_phone1" style="width:40%;" value="#htmlEditFormat( form.customer_phone1 )#" /></td>
			</tr>
			<tr>
				<th>Phone 2</th>
				<td><input type="text" name="customer_phone2" style="width:40%;" value="#htmlEditFormat( form.customer_phone2 )#" /></td>
			</tr>
			<tr>
				<th>Phone 3</th>
				<td><input type="text" name="customer_phone3" style="width:40%;" value="#htmlEditFormat( form.customer_phone3 )#" /></td>
			</tr>
			<tr>
				<th>Spouse First Name</th>
				<td><input type="text" name="customer_spouse_first_name" style="width:40%;" value="#htmlEditFormat( form.customer_spouse_first_name )#" /></td>
			</tr>
			<tr>
				<th>Spouse Suffix</th>
				<td><input type="text" name="customer_spouse_suffix" style="width: 40%;" value="#htmlEditFormat( form.customer_spouse_suffix )#" /></td>
			</tr>
			<tr>
				<th>Spouse Job Title</th>
				<td><input type="text" name="customer_spouse_job_title" style="width: 40%;" value="#htmlEditFormat( form.customer_spouse_job_title )#" /></td>
			</tr>
			<tr>
				<th>Address</th>
				<td><input type="text" name="customer_address" style="width: 40%;" value="#htmlEditFormat( form.customer_address )#" /></td>
			</tr>
			<tr>
				<th>City</th>
				<td><input type="text" name="customer_city" style="width: 40%;" value="#htmlEditFormat( form.customer_city )#" /></td>
			</tr>
			<tr>
				<th>State</th>
				<td><input type="text" name="customer_state" style="width: 40%;" value="#htmlEditFormat( form.customer_state )#" /></td>
			</tr>
			<tr>
				<th>Country</th>
				<td><input type="text" name="customer_country" style="width: 40%;" value="#htmlEditFormat( form.customer_country )#" /></td>
			</tr>
			<tr>
				<th>Postal Code</th>
				<td><input type="text" name="customer_postal_code" style="width: 40%;" value="#htmlEditFormat( form.customer_postal_code )#" /></td>
			</tr>
			<tr>
				<th>Interests</th>
				<td><input type="text" name="customer_interests" style="width: 40%;" value="#htmlEditFormat( form.customer_interests )#" /></td>
			</tr>
			<tr>
				<th>Interested in Type</th>
				<td><input type="text" name="customer_interested_in_type" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_type )#" /></td>
			</tr>
			<tr>
				<th>Interested in Year</th>
				<td><input type="text" name="customer_interested_in_year" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_year )#" /></td>
			</tr>
			<tr>
				<th>Interested in Make</th>
				<td><input type="text" name="customer_interested_in_make" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_make )#" /></td>
			</tr>
			<tr>
				<th>Interested in Model</th>
				<td><input type="text" name="customer_interested_in_model" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_model )#" /></td>
			</tr>
			<tr>
				<th>Interested in Category</th>
				<td><input type="text" name="customer_interested_in_category" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_category )#" /></td>
			</tr>
			<tr>
				<th>Interested in Name</th>
				<td><input type="text" name="customer_interested_in_name" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_name )#" /></td>
			</tr>
			<tr>
				<th>Interested in HIN VIN</th>
				<td><input type="text" name="customer_interested_in_hin_vin" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_hin_vin )#" /></td>
			</tr>
			<tr>
				<th>Interested in Stock</th>
				<td><input type="text" name="customer_interested_in_stock" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_stock )#" /></td>
			</tr>
			<tr>
				<th>Interested in Length</th>
				<td><input type="text" name="customer_interested_in_length" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_length )#" /></td>
			</tr>
			<tr>
				<th>Interested in Currently Owned Type</th>
				<td><input type="text" name="customer_interested_in_currently_owned_type" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_currently_owned_type )#" /></td>
			</tr>
			<tr>
				<th>Interested in Read</th>
				<td><input type="text" name="customer_interested_in_read" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_read )#" /></td>
			</tr>
			<tr>
				<th>Interested in Age</th>
				<td><input type="text" name="customer_interested_in_age" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_age )#" /></td>
			</tr>
			<tr>
				<th>Interested in Bounce Reason</th>
				<td><input type="text" name="customer_interested_in_bounce_reason" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_bounce_reason )#" /></td>
			</tr>
			<tr>
				<th>Interested in Home Phone</th>
				<td><input type="text" name="customer_interested_in_home_phone" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_home_phone )#" /></td>
			</tr>
			<tr>
				<th>Interested in Work Phone</th>
				<td><input type="text" name="customer_interested_in_work_phone" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_work_phone )#" /></td>
			</tr>
			<tr>
				<th>Interested in Mobile Phone</th>
				<td><input type="text" name="customer_interested_in_mobile_phone" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_mobile_phone )#" /></td>
			</tr>
			<tr>
				<th>Interested in Fax</th>
				<td><input type="text" name="customer_interested_in_fax" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_fax )#" /></td>
			</tr>
			<tr>
				<th>Interested in Buying Horizon</th>
				<td><input type="text" name="customer_interested_in_buying_horizon" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_buying_horizon )#" /></td>
			</tr>
			<tr>
				<th>Interested in Status</th>
				<td><input type="text" name="customer_interested_in_status" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_status )#" /></td>
			</tr>
			<tr>
				<th>Interested in Interest Level</th>
				<td><input type="text" name="customer_interested_in_interest_level" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_interest_level )#" /></td>
			</tr>
			<tr>
				<th>Interested in Sales Stage</th>
				<td><input type="text" name="customer_interested_in_sales_stage" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_sales_stage )#" /></td>
			</tr>
			<tr>
				<th>Interested in Customer Source</th>
				<td><input type="text" name="customer_interested_in_customer_source" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_customer_source )#" /></td>
			</tr>
			<tr>
				<th>Interested in Dealership</th>
				<td><input type="text" name="customer_interested_in_dealership" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_dealership )#" /></td>
			</tr>
			<tr>
				<th>Interested in Assigned To</th>
				<td><input type="text" name="customer_interested_in_assigned_to" style="width: 40%;" value="#htmlEditFormat( form.customer_interested_in_assigned_to )#" /></td>
			</tr>
			<tr>
				<th>Interested in Bounced Email</th>
				<cfscript>
					if ( form.customer_interested_in_bounced_email EQ '' ) {
						form.customer_interested_in_bounced_email = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'customer_interested_in_bounced_email', application.zcore.functions.zso( form, 'customer_interested_in_bounced_email' ) )#</td>
			</tr>
			<tr>
				<th>Interested in Owners Magazine</th>
				<cfscript>
					if ( form.customer_interested_in_owners_magazine EQ '' ) {
						form.customer_interested_in_owners_magazine = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'customer_interested_in_owners_magazine', application.zcore.functions.zso( form, 'customer_interested_in_owners_magazine' ) )#</td>
			</tr>
			<tr>
				<th>Interested in Purchased</th>
				<cfscript>
					if ( form.customer_interested_in_purchased EQ '' ) {
						form.customer_interested_in_purchased = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'customer_interested_in_purchased', application.zcore.functions.zso( form, 'customer_interested_in_purchased' ) )#</td>
			</tr>
			<tr>
				<th>Interested in Service Date</th>
				<td>#application.zcore.functions.zDateSelect( 'customer_interested_in_service_date', 'customer_interested_in_service_date', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Date Delivered</th>
				<td>#application.zcore.functions.zDateSelect( 'customer_interested_in_date_delivered', 'customer_interested_in_date_delivered', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Date Sold</th>
				<td>#application.zcore.functions.zDateSelect( 'customer_interested_in_date_sold', 'customer_interested_in_date_sold', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Warranty Date</th>
				<td>#application.zcore.functions.zDateSelect( 'customer_interested_in_warranty_date', 'customer_interested_in_warranty_date', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Lead Comments</th>
				<td><textarea name="customer_interested_in_lead_comments" cols="100" rows="10">#htmlEditFormat( form.customer_interested_in_lead_comments )#</textarea></td>
			</tr>
			<tr>
				<th style="width: 25%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/inquiries/admin/manage-customer/index';">Cancel</button>
				</td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
		var db = request.zos.queryObject; 
		// application.zcore.functions.z404("handle security");
		variables.init();

/*
		form.customer_searchtext = application.zcore.functions.zso( form, 'customer_searchtext' );

		searchOn = false;
*/

		application.zcore.functions.zStatusHandler( request.zsid, true );

/*
		db.sql = 'SELECT *';

		if ( form.customer_searchtext NEQ '' ) {
			db.sql &= ', IF ( concat(customer.customer_id, #db.param(' ')#, customer_first_name, #db.param(' ')#, customer_last_name, #db.param(' ')#, customer_email, #db.param(' ')#, customer_city) LIKE #db.param( '%' & application.zcore.functions.zURLEncode( form.customer_searchtext, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `customer_search` ) AGAINST( #db.param( form.customer_searchtext )# ) relevance ';
		}
*/

		db.sql = 'SELECT *
			FROM #db.table( 'customer', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND customer_deleted = #db.param( 0 )#';
		qCustomer = db.execute( 'qCustomer' );

	</cfscript>

	<h2>Manage Customers</h2>
	<p><a href="/z/inquiries/admin/manage-customer/add">Add Customer</a></p>

<!---
	<hr />
	<div style="width: 100%; float: left;">
		<form action="/z/inquiries/admin/manage-customer/index" method="get">
			<div style="width: 220px; margin-bottom: 10px; float: left;">
				<h2>Search Customers</h2>
			</div>
			<div style="width: 170px; margin-bottom: 10px; float: left;">
				Keyword:<br />
				<input type="text" name="customer_searchtext" value="#replace( replace( form.customer_searchtext, '+', ' ', 'all' ), '%', ' ', 'all' )#" style="width: 150px;" />
			</div>
			<div style="width:150px;margin-bottom:10px;float:left;">&nbsp;<br />
				<input type="submit" name="search1" value="Search" />
				<cfif searchOn>
					<input type="button" name="search2" value="Show All" onclick="window.location.href='/z/inquiries/admin/manage-customer/index';">
				</cfif>
			</div>
		</form>
	</div>
--->

	<cfif qCustomer.recordcount EQ 0>
		<p>There are no Customers attached to this site.</p>
	<cfelse>
		<table style="border-spacing: 0px;" class="table-list">
			<tr>
				<th>Name</th>
				<th>Company</th>
				<th>Email</th>
				<th>Phone</th>
				<th>City</th>
				<th>Last Updated</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qCustomer">
				<tr>	
					<td><a href="/z/inquiries/admin/manage-customer/view?customer_id=#qCustomer.customer_id#">#qCustomer.customer_first_name# #qCustomer.customer_last_name#</a></td>
					<td>#qCustomer.customer_company#</td>
					<td>#qCustomer.customer_email#</td>
					<td>#qCustomer.customer_phone1#</td>
					<cfif qCustomer.customer_city EQ ''>
						<td>&nbsp;</td>
					<cfelse>
						<td>#qCustomer.customer_city#, #qCustomer.customer_state#</td>
					</cfif>
					<td>#application.zcore.functions.zGetLastUpdatedDescription( qCustomer.customer_updated_datetime )#</td>
					<td>
						<a href="/z/inquiries/admin/manage-customer/view?customer_id=#qCustomer.customer_id#">View</a> | 
						<a href="/z/inquiries/admin/manage-customer/edit?customer_id=#qCustomer.customer_id#">Edit</a> | 
						<a href="/z/inquiries/admin/manage-customer/delete?customer_id=#qCustomer.customer_id#">Delete</a>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>

<cffunction name="view" localmode="modern" access="remote" roles="administrator">
	<cfscript>
		var db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'customer', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND customer_id = #db.param( form.customer_id )#
				AND customer_deleted = #db.param( 0 )#';
		qCustomer = db.execute( 'qCustomer' );

		application.zcore.functions.zQueryToStruct( qCustomer, form, 'customer_id' );

		if ( qCustomer.recordcount EQ 0 ) {
			application.zcore.status.setStatus( request.zsid, 'Customer no longer exists', false, true );
			application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-customer/index?zsid=#request.zsid#' );
		}
	</cfscript>

	<h2>Customer</h2>

	<table style="width: 100%; border-spacing: 0px;" class="table-list">
		<tr>
			<th style="width: 25%;">ID</th>
			<td>#qCustomer.customer_id#</td>
		</tr>
		<tr>
			<th>Office ID</th>
			<td>#qCustomer.office_id#</td>
		</tr>
		<tr>
			<th>Company</th>
			<td>#qCustomer.customer_company#</td>
		</tr>
		<tr>
			<th>Salutation</th>
			<td>#qCustomer.customer_salutation#</td>
		</tr>
		<tr>
			<th>First Name</th>
			<td>#qCustomer.customer_first_name#</td>
		</tr>
		<tr>
			<th>Last Name</th>
			<td>#qCustomer.customer_last_name#</td>
		</tr>
		<tr>
			<th>Suffix</th>
			<td>#qCustomer.customer_suffix#</td>
		</tr>
		<tr>
			<th>Job Title</th>
			<td>#qCustomer.customer_job_title#</td>
		</tr>
		<tr>
			<th>Birthday</th>
			<td>#qCustomer.customer_birthday#</td>
		</tr>
		<tr>
			<th>Email</th>
			<td>#qCustomer.customer_email#</td>
		</tr>
		<tr>
			<th>Phone1</th>
			<td>#qCustomer.customer_phone1#</td>
		</tr>
		<tr>
			<th>Phone2</th>
			<td>#qCustomer.customer_phone2#</td>
		</tr>
		<tr>
			<th>Phone3</th>
			<td>#qCustomer.customer_phone3#</td>
		</tr>
		<tr>
			<th>Spouse First Name</th>
			<td>#qCustomer.customer_spouse_first_name#</td>
		</tr>
		<tr>
			<th>Spouse Suffix</th>
			<td>#qCustomer.customer_spouse_suffix#</td>
		</tr>
		<tr>
			<th>Spouse Job Title</th>
			<td>#qCustomer.customer_spouse_job_title#</td>
		</tr>
		<tr>
			<th>Address</th>
			<td>#qCustomer.customer_address#</td>
		</tr>
		<tr>
			<th>City</th>
			<td>#qCustomer.customer_city#</td>
		</tr>
		<tr>
			<th>State</th>
			<td>#qCustomer.customer_state#</td>
		</tr>
		<tr>
			<th>Country</th>
			<td>#qCustomer.customer_country#</td>
		</tr>
		<tr>
			<th>Postal Code</th>
			<td>#qCustomer.customer_postal_code#</td>
		</tr>
		<tr>
			<th>Created Date Time</th>
			<td>#qCustomer.customer_created_datetime#</td>
		</tr>
		<tr>
			<th>Interests</th>
			<td>#qCustomer.customer_interests#</td>
		</tr>
		<tr>
			<th>Interested in Type</th>
			<td>#qCustomer.customer_interested_in_type#</td>
		</tr>
		<tr>
			<th>Interested in Year</th>
			<td>#qCustomer.customer_interested_in_year#</td>
		</tr>
		<tr>
			<th>Interested in Make</th>
			<td>#qCustomer.customer_interested_in_make#</td>
		</tr>
		<tr>
			<th>Interested in Model</th>
			<td>#qCustomer.customer_interested_in_model#</td>
		</tr>
		<tr>
			<th>Interested in Category</th>
			<td>#qCustomer.customer_interested_in_category#</td>
		</tr>
		<tr>
			<th>Interested in Name</th>
			<td>#qCustomer.customer_interested_in_name#</td>
		</tr>
		<tr>
			<th>Interested in HIN VIN</th>
			<td>#qCustomer.customer_interested_in_hin_vin#</td>
		</tr>
		<tr>
			<th>Interested in Stock</th>
			<td>#qCustomer.customer_interested_in_stock#</td>
		</tr>
		<tr>
			<th>Interested in Length</th>
			<td>#qCustomer.customer_interested_in_length#</td>
		</tr>
		<tr>
			<th>Interested in Currently Owned Type</th>
			<td>#qCustomer.customer_interested_in_currently_owned_type#</td>
		</tr>
		<tr>
			<th>Interested in Read</th>
			<td>#qCustomer.customer_interested_in_read#</td>
		</tr>
		<tr>
			<th>Interested in Age</th>
			<td>#qCustomer.customer_interested_in_age#</td>
		</tr>
		<tr>
			<th>Interested in Bounce Reason</th>
			<td>#qCustomer.customer_interested_in_bounce_reason#</td>
		</tr>
		<tr>
			<th>Interested in Home Phone</th>
			<td>#qCustomer.customer_interested_in_home_phone#</td>
		</tr>
		<tr>
			<th>Interested in Work Phone</th>
			<td>#qCustomer.customer_interested_in_work_phone#</td>
		</tr>
		<tr>
			<th>Interested in Mobile Phone</th>
			<td>#qCustomer.customer_interested_in_mobile_phone#</td>
		</tr>
		<tr>
			<th>Interested in Fax</th>
			<td>#qCustomer.customer_interested_in_fax#</td>
		</tr>
		<tr>
			<th>Interested in Buying Horizon</th>
			<td>#qCustomer.customer_interested_in_buying_horizon#</td>
		</tr>
		<tr>
			<th>Interested in Status</th>
			<td>#qCustomer.customer_interested_in_status#</td>
		</tr>
		<tr>
			<th>Interested in Interest Level</th>
			<td>#qCustomer.customer_interested_in_interest_level#</td>
		</tr>
		<tr>
			<th>Interested in Sales Stage</th>
			<td>#qCustomer.customer_interested_in_sales_stage#</td>
		</tr>
		<tr>
			<th>Interested in Customer Source</th>
			<td>#qCustomer.customer_interested_in_customer_source#</td>
		</tr>
		<tr>
			<th>Interested in Dealership</th>
			<td>#qCustomer.customer_interested_in_dealership#</td>
		</tr>
		<tr>
			<th>Interested in Assigned To</th>
			<td>#qCustomer.customer_interested_in_assigned_to#</td>
		</tr>
		<tr>
			<th>Interested in Bounced Email</th>
			<td>#qCustomer.customer_interested_in_bounced_email#</td>
		</tr>
		<tr>
			<th>Interested in Owners Magazine</th>
			<td>#qCustomer.customer_interested_in_owners_magazine#</td>
		</tr>
		<tr>
			<th>Interested in Purchased</th>
			<td>#qCustomer.customer_interested_in_purchased#</td>
		</tr>
		<tr>
			<th>Interested in Service Date</th>
			<td>#qCustomer.customer_interested_in_service_date#</td>
		</tr>
		<tr>
			<th>Interested in Date Delivered</th>
			<td>#qCustomer.customer_interested_in_date_delivered#</td>
		</tr>
		<tr>
			<th>Interested in Date Sold</th>
			<td>#qCustomer.customer_interested_in_date_sold#</td>
		</tr>
		<tr>
			<th>Interested in Warranty Date</th>
			<td>#qCustomer.customer_interested_in_warranty_date#</td>
		</tr>
		<tr>
			<th>Interested in Lead Comments</th>
			<td>#qCustomer.customer_interested_in_lead_comments#</td>
		</tr>
		<tr>
			<th>Updated Date Time</th>
			<td>#qCustomer.customer_updated_datetime#</td>
		</tr>
	</table>
	<button type="button" onclick="window.location.href='/z/inquiries/admin/manage-customer/edit?customer_id=#qCustomer.customer_id#';">Edit Customer</button>

</cffunction>

</cfoutput>
</cfcomponent>
