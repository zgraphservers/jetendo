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

userView & userIndex - Allow non-manager users to view only the contacts they have leads for.   This requires a slower join on inquiries table.

when a new lead comes in, we should apply the newest mapped data to the contact record, i.e. product of interest, phone number, address, augmenting it.

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
			FROM #db.table( 'contact', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND contact_id = #db.param( form.contact_id )#
				AND contact_deleted = #db.param( 0 )#';
		qCheck = db.execute( 'qCheck' );

		if ( qCheck.recordcount EQ 0 ) {
			application.zcore.status.setStatus( request.zsid, 'Contact no longer exists', false, true );
			application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/index?zsid=#request.zsid#' );
		}
	</cfscript>
	<cfif structKeyExists( form, 'confirm' )>
		<cfscript>
			db.sql = 'DELETE FROM #db.table( 'contact', request.zos.zcoreDatasource )#
				WHERE site_id = #db.pram( request.zos.globals.id )#
					AND contact_id = #db.param( form.contact_id )#
					AND contact_deleted = #db.param( 0 )#';
			q = db.execute( 'q' );

			application.zcore.status.setStatus( request.zsid, 'Contact deleted' );
			application.zcore.functions.zRedirect( '/z/inquiries/admin/manager-contact/index?zsid=#request.zsid#' );
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this Contact?<br />
			<br />
			#qCheck.contact_first_name# #qCheck.contact_last_name#<br />
			#qCheck.contact_email#<br />
			<br />
			<a href="/z/inquiries/admin/manage-contact/delete?confirm=1&contact_id=#form.contact_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/manage-contact/index">No</a> 
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
			form.contact_id = '';
		}

		var errors = false;

		ts.contact_first_name.required = true;
		ts.contact_last_name.required = true;
		ts.contact_email.email = true;
		ts.contact_email.required = true;

		form.contact_phone1_formatted = application.zcore.functions.zFormatInquiryPhone( application.zcore.functions.zso( form, 'contact_phone1' ) );
		form.contact_phone2_formatted = application.zcore.functions.zFormatInquiryPhone( application.zcore.functions.zso( form, 'contact_phone2' ) );
		form.contact_phone3_formatted = application.zcore.functions.zFormatInquiryPhone( application.zcore.functions.zso( form, 'contact_phone3' ) );

		form.contact_interested_in_home_phone   = application.zcore.functions.zFormatInquiryPhone( application.zcore.functions.zso( form, 'contact_interested_in_home_phone' ) );
		form.contact_interested_in_work_phone   = application.zcore.functions.zFormatInquiryPhone( application.zcore.functions.zso( form, 'contact_interested_in_work_phone' ) );
		form.contact_interested_in_mobile_phone = application.zcore.functions.zFormatInquiryPhone( application.zcore.functions.zso( form, 'contact_interested_in_mobile_phone' ) );
		form.contact_interested_in_fax          = application.zcore.functions.zFormatInquiryPhone( application.zcore.functions.zso( form, 'contact_interested_in_fax' ) );

		result = application.zcore.functions.zValidateStruct( form, ts, request.zsid, true );

		if ( result ) {
			application.zcore.status.setStatus( request.zsid, false, form, true );
			if ( form.method EQ 'insert' ) {
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/add?zsid=#request.zsid#' );
			} else {
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/edit?contact_id=#form.contact_id#&zsid=#request.zsid#' );
			}
		}

		if ( form.method EQ 'insert' ) {
			form.contact_datetime = request.zos.mysqlnow;
		}

		form.contact_updated_datetime = request.zos.mysqlnow;
		ts = StructNew();
		ts.table = 'contact';
		ts.datasource = request.zos.zcoreDatasource;
		ts.struct = form;

		if ( form.method EQ 'insert' ) {
			form.contact_id = application.zcore.functions.zInsert( ts );
			if ( form.contact_id EQ false ) {
				application.zcore.status.setStatus( request.zsid, 'Failed to save Contact.', form, true );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/add?zsid=#request.zsid#' );
			} else {
				application.zcore.status.setStatus( request.zsid, 'Contact saved.' );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/index?zsid=#request.zsid#' );
			}
		} else {
			if ( application.zcore.functions.zUpdate( ts ) EQ false ) {
				application.zcore.status.setStatus( request.zsid, 'Failed to save Contact.', form, true );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/edit?contact_id=#form.contact_id#&zsid=#request.zsid#' );
			} else {
				application.zcore.status.setStatus( request.zsid, 'Contact updated.' );
				application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/index?zsid=#request.zsid#' );
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

		if ( application.zcore.functions.zso( form, 'contact_id' ) EQ '' ) {
			form.contact_id = -1;
		}

		db.sql = 'SELECT *
			FROM #db.table( 'contact', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND contact_id = #db.param( application.zcore.functions.zso( form, 'contact_id' ) )#
				AND contact_deleted = #db.param( 0 )#';
		qContact = db.execute( 'qContact' );

		application.zcore.functions.zQueryToStruct( qContact, form, 'contact_id' );

		if ( currentMethod EQ 'add' ) {
			form.contact_id = '';
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		}
		application.zcore.functions.zStatusHandler( request.zsid, true );

		echo( '<h2>' );

		action = '/z/inquiries/admin/manage-contact/';
		if ( currentMethod EQ 'add' ) {
			action &= 'insert';
			echo( 'Add' );
		} else {
			action &= 'update?contact_id=#form.contact_id#';
			echo( 'Edit' );
		}
		echo( ' Contact</h2>' );
	</cfscript>
	<p>* denotes required field.</p>
	<form class="zFormCheckDirty" action="#action#" method="post" enctype="multipart/form-data">
		<table style="width: 100%;" class="table-list">
			<tr>
				<th style="width: 25%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/inquiries/admin/manage-contact/index';">Cancel</button>
				</td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Office","member.member.edit office_id")#</th>
				<td><cfscript>
					db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
					WHERE site_id = #db.param(request.zos.globals.id)# and 
					office_deleted = #db.param(0)# 
					ORDER BY office_name";
					qOffice=db.execute("qOffice");
					selectStruct = StructNew();
					selectStruct.name = "office_id";
					selectStruct.query = qOffice;
					selectStruct.hideSelect=false;
					selectStruct.queryParseLabelVars=true;
					selectStruct.queryLabelField = "##office_name##, ##office_address##";
					selectStruct.queryValueField = "office_id";
					selectStruct.multiple=false;
					// application.zcore.functions.zSetupMultipleSelect(selectStruct.name, application.zcore.functions.zso(form, 'office_id'));
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th>Salutation</th>
				<td><input type="text" name="contact_salutation" style="width:40%;" value="#htmlEditFormat( form.contact_salutation )#" /></td>
			</tr>
			<tr>
				<th>First Name</th>
				<td><input type="text" name="contact_first_name" style="width:40%;" value="#htmlEditFormat( form.contact_first_name )#" /> *</td>
			</tr>
			<tr>
				<th>Last Name</th>
				<td><input type="text" name="contact_last_name" style="width:40%;" value="#htmlEditFormat( form.contact_last_name )#" /> *</td>
			</tr>
			<tr>
				<th>Suffix</th>
				<td><input type="text" name="contact_suffix" style="width:40%;" value="#htmlEditFormat( form.contact_suffix )#" /></td>
			</tr>
			<tr>
				<th>Company</th>
				<td><input type="text" name="contact_company" style="width:40%;" value="#htmlEditFormat( form.contact_company )#" /></td>
			</tr>
			<tr>
				<th>Job Title</th>
				<td><input type="text" name="contact_job_title" style="width:40%;" value="#htmlEditFormat( form.contact_job_title )#" /></td>
			</tr>
			<tr>
				<th>Email Address</th>
				<td><input type="text" name="contact_email" style="width:40%;" value="#htmlEditFormat( form.contact_email )#" /> *</td>
			</tr>
			<tr>
				<th>Birthday</th>
				<td>#application.zcore.functions.zDateSelect( 'contact_birthday', 'contact_birthday', 1900, year( now() ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Phone 1</th>
				<td><input type="text" name="contact_phone1" style="width:40%;" value="#htmlEditFormat( form.contact_phone1 )#" /></td>
			</tr>
			<tr>
				<th>Phone 2</th>
				<td><input type="text" name="contact_phone2" style="width:40%;" value="#htmlEditFormat( form.contact_phone2 )#" /></td>
			</tr>
			<tr>
				<th>Phone 3</th>
				<td><input type="text" name="contact_phone3" style="width:40%;" value="#htmlEditFormat( form.contact_phone3 )#" /></td>
			</tr>
			<tr>
				<th>Spouse First Name</th>
				<td><input type="text" name="contact_spouse_first_name" style="width:40%;" value="#htmlEditFormat( form.contact_spouse_first_name )#" /></td>
			</tr>
			<tr>
				<th>Spouse Suffix</th>
				<td><input type="text" name="contact_spouse_suffix" style="width: 40%;" value="#htmlEditFormat( form.contact_spouse_suffix )#" /></td>
			</tr>
			<tr>
				<th>Spouse Job Title</th>
				<td><input type="text" name="contact_spouse_job_title" style="width: 40%;" value="#htmlEditFormat( form.contact_spouse_job_title )#" /></td>
			</tr>
			<tr>
				<th>Address</th>
				<td><input type="text" name="contact_address" style="width: 40%;" value="#htmlEditFormat( form.contact_address )#" /></td>
			</tr>
			<tr>
				<th>City</th>
				<td><input type="text" name="contact_city" style="width: 40%;" value="#htmlEditFormat( form.contact_city )#" /></td>
			</tr>
			<tr>
				<th>State</th>
				<td>#application.zcore.functions.zStateSelect( 'contact_state', application.zcore.functions.zso( form, 'contact_state' ) )#</td>
			</tr>
			<tr>
				<th>Country</th>
				<td>
					#application.zcore.functions.zCountrySelect( 'contact_country', application.zcore.functions.zso( form, 'contact_country' ) )#
				</td>
			</tr>
			<tr>
				<th>Postal Code</th>
				<td><input type="text" name="contact_postal_code" style="width: 40%;" value="#htmlEditFormat( form.contact_postal_code )#" /></td>
			</tr>
			<tr>
				<th>Interests</th>
				<td><input type="text" name="contact_interests" style="width: 40%;" value="#htmlEditFormat( form.contact_interests )#" /></td>
			</tr>
			<tr>
				<th>Interested in Type</th>
				<td><input type="text" name="contact_interested_in_type" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_type )#" /></td>
			</tr>
			<tr>
				<th>Interested in Year</th>
				<td><input type="text" name="contact_interested_in_year" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_year )#" /></td>
			</tr>
			<tr>
				<th>Interested in Make</th>
				<td><input type="text" name="contact_interested_in_make" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_make )#" /></td>
			</tr>
			<tr>
				<th>Interested in Model</th>
				<td><input type="text" name="contact_interested_in_model" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_model )#" /></td>
			</tr>
			<tr>
				<th>Interested in Category</th>
				<td><input type="text" name="contact_interested_in_category" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_category )#" /></td>
			</tr>
			<tr>
				<th>Interested in Name</th>
				<td><input type="text" name="contact_interested_in_name" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_name )#" /></td>
			</tr>
			<tr>
				<th>Interested in HIN VIN</th>
				<td><input type="text" name="contact_interested_in_hin_vin" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_hin_vin )#" /></td>
			</tr>
			<tr>
				<th>Interested in Stock</th>
				<td><input type="text" name="contact_interested_in_stock" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_stock )#" /></td>
			</tr>
			<tr>
				<th>Interested in Length</th>
				<td><input type="text" name="contact_interested_in_length" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_length )#" /></td>
			</tr>
			<tr>
				<th>Interested in Currently Owned Type</th>
				<td><input type="text" name="contact_interested_in_currently_owned_type" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_currently_owned_type )#" /></td>
			</tr>
			<tr>
				<th>Interested in Read</th>
				<td><input type="text" name="contact_interested_in_read" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_read )#" /></td>
			</tr>
			<tr>
				<th>Interested in Age</th>
				<td><input type="text" name="contact_interested_in_age" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_age )#" /></td>
			</tr>
			<tr>
				<th>Interested in Bounce Reason</th>
				<td><input type="text" name="contact_interested_in_bounce_reason" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_bounce_reason )#" /></td>
			</tr>
			<tr>
				<th>Interested in Home Phone</th>
				<td><input type="text" name="contact_interested_in_home_phone" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_home_phone )#" /></td>
			</tr>
			<tr>
				<th>Interested in Work Phone</th>
				<td><input type="text" name="contact_interested_in_work_phone" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_work_phone )#" /></td>
			</tr>
			<tr>
				<th>Interested in Mobile Phone</th>
				<td><input type="text" name="contact_interested_in_mobile_phone" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_mobile_phone )#" /></td>
			</tr>
			<tr>
				<th>Interested in Fax</th>
				<td><input type="text" name="contact_interested_in_fax" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_fax )#" /></td>
			</tr>
			<tr>
				<th>Interested in Buying Horizon</th>
				<td><input type="text" name="contact_interested_in_buying_horizon" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_buying_horizon )#" /></td>
			</tr>
			<tr>
				<th>Interested in Status</th>
				<td><input type="text" name="contact_interested_in_status" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_status )#" /></td>
			</tr>
			<tr>
				<th>Interested in Interest Level</th>
				<td><input type="text" name="contact_interested_in_interest_level" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_interest_level )#" /></td>
			</tr>
			<tr>
				<th>Interested in Sales Stage</th>
				<td><input type="text" name="contact_interested_in_sales_stage" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_sales_stage )#" /></td>
			</tr>
			<tr>
				<th>Interested in Contact Source</th>
				<td><input type="text" name="contact_interested_in_contact_source" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_contact_source )#" /></td>
			</tr>
			<tr>
				<th>Interested in Dealership</th>
				<td><input type="text" name="contact_interested_in_dealership" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_dealership )#" /></td>
			</tr>
			<tr>
				<th>Interested in Assigned To</th>
				<td><input type="text" name="contact_interested_in_assigned_to" style="width: 40%;" value="#htmlEditFormat( form.contact_interested_in_assigned_to )#" /></td>
			</tr>
			<tr>
				<th>Interested in Bounced Email</th>
				<cfscript>
					if ( form.contact_interested_in_bounced_email EQ '' ) {
						form.contact_interested_in_bounced_email = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'contact_interested_in_bounced_email', application.zcore.functions.zso( form, 'contact_interested_in_bounced_email' ) )#</td>
			</tr>
			<tr>
				<th>Interested in Owners Magazine</th>
				<cfscript>
					if ( form.contact_interested_in_owners_magazine EQ '' ) {
						form.contact_interested_in_owners_magazine = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'contact_interested_in_owners_magazine', application.zcore.functions.zso( form, 'contact_interested_in_owners_magazine' ) )#</td>
			</tr>
			<tr>
				<th>Interested in Purchased</th>
				<cfscript>
					if ( form.contact_interested_in_purchased EQ '' ) {
						form.contact_interested_in_purchased = 0;
					}
				</cfscript>
				<td>#application.zcore.functions.zInput_Boolean( 'contact_interested_in_purchased', application.zcore.functions.zso( form, 'contact_interested_in_purchased' ) )#</td>
			</tr>
			<tr>
				<th>Interested in Service Date</th>
				<td>#application.zcore.functions.zDateSelect( 'contact_interested_in_service_date', 'contact_interested_in_service_date', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Date Delivered</th>
				<td>#application.zcore.functions.zDateSelect( 'contact_interested_in_date_delivered', 'contact_interested_in_date_delivered', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Date Sold</th>
				<td>#application.zcore.functions.zDateSelect( 'contact_interested_in_date_sold', 'contact_interested_in_date_sold', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Warranty Date</th>
				<td>#application.zcore.functions.zDateSelect( 'contact_interested_in_warranty_date', 'contact_interested_in_warranty_date', 1900, ( year( now() ) + 1 ), '', false, true )#</td>
			</tr>
			<tr>
				<th>Interested in Lead Comments</th>
				<td><textarea name="contact_interested_in_lead_comments" cols="100" rows="10">#htmlEditFormat( form.contact_interested_in_lead_comments )#</textarea></td>
			</tr>
			<tr>
				<th style="width: 25%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/inquiries/admin/manage-contact/index';">Cancel</button>
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
		form.contact_searchtext = application.zcore.functions.zso( form, 'contact_searchtext' );

		searchOn = false;
*/

		application.zcore.functions.zStatusHandler( request.zsid, true );

/*
		db.sql = 'SELECT *';

		if ( form.contact_searchtext NEQ '' ) {
			db.sql &= ', IF ( concat(contact.contact_id, #db.param(' ')#, contact_first_name, #db.param(' ')#, contact_last_name, #db.param(' ')#, contact_email, #db.param(' ')#, contact_city) LIKE #db.param( '%' & application.zcore.functions.zURLEncode( form.contact_searchtext, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `contact_search` ) AGAINST( #db.param( form.contact_searchtext )# ) relevance ';
		}
*/

		db.sql = 'SELECT *
			FROM #db.table( 'contact', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND contact_deleted = #db.param( 0 )#';
		qContact = db.execute( 'qContact' );

	</cfscript>

	<h2>Manage Contacts</h2>
	<p><a href="/z/inquiries/admin/manage-contact/add">Add Contact</a></p>

<!---
	<hr />
	<div style="width: 100%; float: left;">
		<form action="/z/inquiries/admin/manage-contact/index" method="get">
			<div style="width: 220px; margin-bottom: 10px; float: left;">
				<h2>Search Contacts</h2>
			</div>
			<div style="width: 170px; margin-bottom: 10px; float: left;">
				Keyword:<br />
				<input type="text" name="contact_searchtext" value="#replace( replace( form.contact_searchtext, '+', ' ', 'all' ), '%', ' ', 'all' )#" style="width: 150px;" />
			</div>
			<div style="width:150px;margin-bottom:10px;float:left;">&nbsp;<br />
				<input type="submit" name="search1" value="Search" class="z-manager-search-button" />
				<cfif searchOn>
					<input type="button" name="search2" value="Show All" class="z-manager-search-button" onclick="window.location.href='/z/inquiries/admin/manage-contact/index';">
				</cfif>
			</div>
		</form>
	</div>
--->

	<cfif qContact.recordcount EQ 0>
		<p>There are no Contacts attached to this site.</p>
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
			<cfloop query="qContact">
				<tr>	
					<td><a href="/z/inquiries/admin/manage-contact/view?contact_id=#qContact.contact_id#">#qContact.contact_first_name# #qContact.contact_last_name#</a></td>
					<td>#qContact.contact_company#</td>
					<td>#qContact.contact_email#</td>
					<td>#qContact.contact_phone1#</td>
					<cfif qContact.contact_city EQ ''>
						<td>&nbsp;</td>
					<cfelse>
						<td>#qContact.contact_city#, #qContact.contact_state#</td>
					</cfif>
					<td>#application.zcore.functions.zGetLastUpdatedDescription( qContact.contact_updated_datetime )#</td>
					<td>
						<a href="/z/inquiries/admin/manage-contact/view?contact_id=#qContact.contact_id#">View</a> | 
						<a href="/z/inquiries/admin/manage-contact/edit?contact_id=#qContact.contact_id#">Edit</a> | 
						<a href="/z/inquiries/admin/manage-contact/delete?contact_id=#qContact.contact_id#">Delete</a>
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
			FROM #db.table( 'contact', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND contact_id = #db.param( form.contact_id )#
				AND contact_deleted = #db.param( 0 )#';
		qContact = db.execute( 'qContact' );

		application.zcore.functions.zQueryToStruct( qContact, form, 'contact_id' );

		if ( qContact.recordcount EQ 0 ) {
			application.zcore.status.setStatus( request.zsid, 'Contact no longer exists', false, true );
			application.zcore.functions.zRedirect( '/z/inquiries/admin/manage-contact/index?zsid=#request.zsid#' );
		}
	</cfscript>

	<h2>Contact</h2>

	<table style="width: 100%; border-spacing: 0px;" class="table-list">
		<tr>
			<th style="width: 25%;">ID</th>
			<td>#qContact.contact_id#</td>
		</tr>
		<tr>
			<th>Office ID</th>
			<td>#qContact.office_id#</td>
		</tr>
		<tr>
			<th>Company</th>
			<td>#qContact.contact_company#</td>
		</tr>
		<tr>
			<th>Salutation</th>
			<td>#qContact.contact_salutation#</td>
		</tr>
		<tr>
			<th>First Name</th>
			<td>#qContact.contact_first_name#</td>
		</tr>
		<tr>
			<th>Last Name</th>
			<td>#qContact.contact_last_name#</td>
		</tr>
		<tr>
			<th>Suffix</th>
			<td>#qContact.contact_suffix#</td>
		</tr>
		<tr>
			<th>Job Title</th>
			<td>#qContact.contact_job_title#</td>
		</tr>
		<tr>
			<th>Birthday</th>
			<td>#qContact.contact_birthday#</td>
		</tr>
		<tr>
			<th>Email</th>
			<td>#qContact.contact_email#</td>
		</tr>
		<tr>
			<th>Phone1</th>
			<td>#qContact.contact_phone1#</td>
		</tr>
		<tr>
			<th>Phone2</th>
			<td>#qContact.contact_phone2#</td>
		</tr>
		<tr>
			<th>Phone3</th>
			<td>#qContact.contact_phone3#</td>
		</tr>
		<tr>
			<th>Spouse First Name</th>
			<td>#qContact.contact_spouse_first_name#</td>
		</tr>
		<tr>
			<th>Spouse Suffix</th>
			<td>#qContact.contact_spouse_suffix#</td>
		</tr>
		<tr>
			<th>Spouse Job Title</th>
			<td>#qContact.contact_spouse_job_title#</td>
		</tr>
		<tr>
			<th>Address</th>
			<td>#qContact.contact_address#</td>
		</tr>
		<tr>
			<th>City</th>
			<td>#qContact.contact_city#</td>
		</tr>
		<tr>
			<th>State</th>
			<td>#qContact.contact_state#</td>
		</tr>
		<tr>
			<th>Country</th>
			<td>#qContact.contact_country#</td>
		</tr>
		<tr>
			<th>Postal Code</th>
			<td>#qContact.contact_postal_code#</td>
		</tr>
		<tr>
			<th>Created Date Time</th>
			<td>#qContact.contact_datetime#</td>
		</tr>
		<tr>
			<th>Interests</th>
			<td>#qContact.contact_interests#</td>
		</tr>
		<tr>
			<th>Interested in Type</th>
			<td>#qContact.contact_interested_in_type#</td>
		</tr>
		<tr>
			<th>Interested in Year</th>
			<td>#qContact.contact_interested_in_year#</td>
		</tr>
		<tr>
			<th>Interested in Make</th>
			<td>#qContact.contact_interested_in_make#</td>
		</tr>
		<tr>
			<th>Interested in Model</th>
			<td>#qContact.contact_interested_in_model#</td>
		</tr>
		<tr>
			<th>Interested in Category</th>
			<td>#qContact.contact_interested_in_category#</td>
		</tr>
		<tr>
			<th>Interested in Name</th>
			<td>#qContact.contact_interested_in_name#</td>
		</tr>
		<tr>
			<th>Interested in HIN VIN</th>
			<td>#qContact.contact_interested_in_hin_vin#</td>
		</tr>
		<tr>
			<th>Interested in Stock</th>
			<td>#qContact.contact_interested_in_stock#</td>
		</tr>
		<tr>
			<th>Interested in Length</th>
			<td>#qContact.contact_interested_in_length#</td>
		</tr>
		<tr>
			<th>Interested in Currently Owned Type</th>
			<td>#qContact.contact_interested_in_currently_owned_type#</td>
		</tr>
		<tr>
			<th>Interested in Read</th>
			<td>#qContact.contact_interested_in_read#</td>
		</tr>
		<tr>
			<th>Interested in Age</th>
			<td>#qContact.contact_interested_in_age#</td>
		</tr>
		<tr>
			<th>Interested in Bounce Reason</th>
			<td>#qContact.contact_interested_in_bounce_reason#</td>
		</tr>
		<tr>
			<th>Interested in Home Phone</th>
			<td>#qContact.contact_interested_in_home_phone#</td>
		</tr>
		<tr>
			<th>Interested in Work Phone</th>
			<td>#qContact.contact_interested_in_work_phone#</td>
		</tr>
		<tr>
			<th>Interested in Mobile Phone</th>
			<td>#qContact.contact_interested_in_mobile_phone#</td>
		</tr>
		<tr>
			<th>Interested in Fax</th>
			<td>#qContact.contact_interested_in_fax#</td>
		</tr>
		<tr>
			<th>Interested in Buying Horizon</th>
			<td>#qContact.contact_interested_in_buying_horizon#</td>
		</tr>
		<tr>
			<th>Interested in Status</th>
			<td>#qContact.contact_interested_in_status#</td>
		</tr>
		<tr>
			<th>Interested in Interest Level</th>
			<td>#qContact.contact_interested_in_interest_level#</td>
		</tr>
		<tr>
			<th>Interested in Sales Stage</th>
			<td>#qContact.contact_interested_in_sales_stage#</td>
		</tr>
		<tr>
			<th>Interested in Contact Source</th>
			<td>#qContact.contact_interested_in_contact_source#</td>
		</tr>
		<tr>
			<th>Interested in Dealership</th>
			<td>#qContact.contact_interested_in_dealership#</td>
		</tr>
		<tr>
			<th>Interested in Assigned To</th>
			<td>#qContact.contact_interested_in_assigned_to#</td>
		</tr>
		<tr>
			<th>Interested in Bounced Email</th>
			<td>#qContact.contact_interested_in_bounced_email#</td>
		</tr>
		<tr>
			<th>Interested in Owners Magazine</th>
			<td>#qContact.contact_interested_in_owners_magazine#</td>
		</tr>
		<tr>
			<th>Interested in Purchased</th>
			<td>#qContact.contact_interested_in_purchased#</td>
		</tr>
		<tr>
			<th>Interested in Service Date</th>
			<td>#qContact.contact_interested_in_service_date#</td>
		</tr>
		<tr>
			<th>Interested in Date Delivered</th>
			<td>#qContact.contact_interested_in_date_delivered#</td>
		</tr>
		<tr>
			<th>Interested in Date Sold</th>
			<td>#qContact.contact_interested_in_date_sold#</td>
		</tr>
		<tr>
			<th>Interested in Warranty Date</th>
			<td>#qContact.contact_interested_in_warranty_date#</td>
		</tr>
		<tr>
			<th>Interested in Lead Comments</th>
			<td>#qContact.contact_interested_in_lead_comments#</td>
		</tr>
		<tr>
			<th>Updated Date Time</th>
			<td>#qContact.contact_updated_datetime#</td>
		</tr>
	</table>
	<button type="button" onclick="window.location.href='/z/inquiries/admin/manage-contact/edit?contact_id=#qContact.contact_id#';">Edit Contact</button>

</cffunction>

</cfoutput>
</cfcomponent>
