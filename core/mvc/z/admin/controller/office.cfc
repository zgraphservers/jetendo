<cfcomponent>
<cfoutput> 
<!--- 
TODO: route by inquiry type
route future leads only
stop routing.
send a copy to (for each type)

route by property type, cities or possibly entire Saved Search.

group agents by offices.   assign leads to an office based on location or zip codes and then allow separate routing per office.

enable round robin for offices - need a new option to disable for staff.
 --->

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Offices", true);	
	db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office
	WHERE office_id= #db.param(application.zcore.functions.zso(form,'office_id'))# and 
	office_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Office no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/office/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.office_image_library_id);
		db.sql="DELETE FROM #db.table("office", request.zos.zcoreDatasource)#  
		WHERE office_id= #db.param(application.zcore.functions.zso(form, 'office_id'))# and 
		office_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
		variables.queueSortCom.sortAll();
		application.zcore.status.setStatus(Request.zsid, 'Office deleted');
		application.zcore.functions.zRedirect('/z/admin/office/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this office?<br />
			<br />
			#qCheck.office_name# (Address: #qCheck.office_address#) 			<br />
			<br />
			<a href="/z/admin/office/delete?confirm=1&amp;office_id=#form.office_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/admin/office/index">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var ts={}; 
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Offices", true);	
	form.site_id = request.zos.globals.id;
	ts.office_name.required = true;
	fail = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);

	form.office_manager_email_list=application.zcore.functions.zso(form, 'office_manager_email_list');
	arrEmail=listToArray(form.office_manager_email_list, ",");
	arrNewEmail=[];
	for(email in arrEmail){
		email=trim(email);
		if(email EQ ""){
			// skip
		}else if(not application.zcore.functions.zEmailValidate(email)){
			fail=true;
			application.zcore.status.setStatus(request.zsid, "You must enter valid email address list for the manager email list.", form, true);
		}else{
			arrayAppend(arrNewEmail, trim(email));
		}
	}
	form.office_manager_email_list=arrayToList(arrNewEmail, ",");

	metaCom=createObject("component", "zcorerootmapping.com.zos.meta");
	arrError=metaCom.validate("office", form);
	if(arrayLen(arrError)){
		fail=true;
		for(e in arrError){
			application.zcore.status.setStatus(request.zsid, e, form, true);
		}
	}
	if(fail){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/office/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/office/edit?office_id=#form.office_id#&zsid=#request.zsid#');
		}
	} 
	form.office_meta_json=metaCom.save("office", form); 
	ts=StructNew();
	ts.table='office';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.office_id = application.zcore.functions.zInsert(ts);
		if(form.office_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save office.',form,true);
			application.zcore.functions.zRedirect('/z/admin/office/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Office saved.');
			variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save office.',form,true);
			application.zcore.functions.zRedirect('/z/admin/office/edit?office_id=#form.office_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Office updated.');
		}
		
	}
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'office_image_library_id'));
	application.zcore.functions.zRedirect('/z/admin/office/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var ts=0;
	var db=request.zos.queryObject;
	var qRoute=0;
	var currentMethod=form.method;
	var htmlEditor=0;
	application.zcore.functions.zSetPageHelpId("5.5");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Offices");	
	if(application.zcore.functions.zso(form,'office_id') EQ ''){
		form.office_id = -1;
	}
	db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	office_deleted = #db.param(0)# and 
	office_id=#db.param(form.office_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute);

	metaCom=createObject("component", "zcorerootmapping.com.zos.meta");

	structappend(form, metaCom.getData("office", form), false); 
	application.zcore.functions.zStatusHandler(request.zsid,true);

	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif>
		Office</h2>
	<form class="zFormCheckDirty" action="/z/admin/office/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?office_id=#form.office_id#" method="post">
		<table style="width:100%;" class="table-list">
			#metaCom.displayForm("office", "Basic", "first")#
			<tr>
				<th>Office Name</th>
				<td><input type="text" name="office_name" value="#htmleditformat(form.office_name)#" /></td>
			</tr>
			<cfif application.zcore.functions.zso(request.zos.globals, 'enableLeadReminderOfficeManagerCC', true, 0) EQ 1> 
				<tr>
					<th>Manager Email List</th>
					<td><input type="text" name="office_manager_email_list" value="#htmleditformat(form.office_manager_email_list)#" />
					<br>
					Note: Managers are CC'd on lead notifications if this feature is enabled.	
					</td>
				</tr>
			</cfif>
			<tr>
				<th style="width:1%; white-space:nowrap;" class="table-white">Photos:</th>
				<td colspan="2" class="table-white"><cfscript>
				ts=structnew();
				ts.name="office_image_library_id";
				ts.value=form.office_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;">Description</th>
				<td><cfscript>
    
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "office_description";
				htmlEditor.value			= form.office_description;
					htmlEditor.basePath		= '/';
				htmlEditor.width			= "100%";
				htmlEditor.height		= 300;
				htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<tr>
				<th>Phone</th>
				<td><input type="text" name="office_phone" value="#htmleditformat(form.office_phone)#" /></td>
			</tr>
			<tr>
				<th>Phone 2</th>
				<td><input type="text" name="office_phone2" value="#htmleditformat(form.office_phone2)#" /></td>
			</tr>
			<tr>
				<th>Fax</th>
				<td><input type="text" name="office_fax" value="#htmleditformat(form.office_fax)#" /></td>
			</tr>
			<tr>
				<th>Address&nbsp;</th>
				<td><input type="text" name="office_address" value="#htmleditformat(form.office_address)#" /></td>
			</tr>
			<tr>
				<th>Address 2&nbsp;</th>
				<td><input type="text" name="office_address2" value="#htmleditformat(form.office_address2)#" /></td>
			</tr>
			<tr>
				<th>City&nbsp;</th>
				<td><input type="text" name="office_city" value="#htmleditformat(form.office_city)#" /></td>
			</tr>
			<tr>
				<th>State&nbsp;</th>
				<td><cfscript>
				writeoutput(application.zcore.functions.zStateSelect("office_state", application.zcore.functions.zso(form,'office_state')));
				</cfscript></td>
			</tr>
			<tr>
				<th>Country&nbsp;</th>
				<td><cfscript>
				writeoutput(application.zcore.functions.zCountrySelect("office_country", application.zcore.functions.zso(form,'office_country')));
				</cfscript></td>
			</tr>
			<tr>
				<th>Zip Code</th>
				<td><input type="text" name="office_zip" value="#htmleditformat(form.office_zip)#" /></td>
			</tr>
			
			#metaCom.displayForm("office", "Basic", "last")#
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save Office</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/admin/office/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Offices");	
	var queueSortStruct = StructNew();
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	queueSortStruct.tableName = "office";
	queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	queueSortStruct.sortFieldName = "office_sort";
	queueSortStruct.primaryKeyName = "office_id";
	queueSortStruct.where="site_id = '#request.zos.globals.id#' and office_deleted='0' ";
	queueSortStruct.ajaxURL="/z/admin/office/index";
	queueSortStruct.ajaxTableId="sortRowTable";
	variables.queueSortCom.init(queueSortStruct);
	variables.queueSortCom.returnJson();
	</cfscript>
</cffunction>	

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qOffice=0;
	var arrImages=0;
	var ts=0;
	var i=0;
	var rs=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("5.4");
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
		application.zcore.functions.zredirect('/member/');	
	}
	application.zcore.functions.zStatusHandler(request.zsid);
 
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="office.office_image_library_id";
	ts.count = 1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT * #db.trustedsql(rs.select)# 
	FROM #db.table("office", request.zos.zcoreDatasource)# office 
	#db.trustedsql(rs.leftJoin)# 
	WHERE office.site_id = #db.param(request.zos.globals.id)# and 
	office_deleted = #db.param(0)# 
	GROUP BY office.office_id 
	order by office_sort, office_name";
	qOffice=db.execute("qOffice");
	</cfscript>
	<h2>Manage Offices</h2>
	<p><a href="/z/admin/office/add">Add Office</a></p>
	<cfif qOffice.recordcount EQ 0>
		<p>No offices have been added.</p>
		<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>Photo</th>
				<th>Office Name</th>
				<th>Address</th>
				<th>Phone</th>
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfloop query="qOffice">
				<tr #variables.queueSortCom.getRowHTML(qOffice.office_id)# <cfif qOffice.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td style="vertical-align:top; width:100px; ">
					<cfscript>
					ts=structnew();
					ts.image_library_id=qOffice.office_image_library_id;
					ts.output=false;
					ts.query=qOffice;
					ts.row=qOffice.currentrow;
					ts.size="100x70";
					ts.crop=0;
					ts.count = 1; // how many images to get
					//zdump(ts);
					arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts); 
					for(i=1;i LTE arraylen(arrImages);i++){
						writeoutput('<img src="'&arrImages[i].link&'">');
					} 
					</cfscript></td>
					<td>#qOffice.office_name#</td>
					<td>#qOffice.office_address#<br />
						#qOffice.office_address#<br />
						#qOffice.office_city#, #qOffice.office_state# 
						#qOffice.office_zip# #qOffice.office_country#
						</td>
					<td>#qOffice.office_phone#</td>
					<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(qOffice.office_id)#</td>
					<td><!--- #variables.queueSortCom.getLinks(qOffice.recordcount, qOffice.currentrow, "/z/admin/office/index?office_id=#qOffice.office_id#", "vertical-arrows")#  --->
					<a href="/z/inquiries/admin/manage-inquiries/index?search_office_id=#qOffice.office_id#">Manage Leads</a> | 
					<a href="/z/admin/office/edit?office_id=#qOffice.office_id#">Edit</a> | 
					<a href="/z/admin/office/delete?office_id=#qOffice.office_id#">Delete</a></td>
				</tr>
				</cfloop>
			</tbody>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
