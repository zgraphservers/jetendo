<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var rateCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Amenities");
	form.start=application.zcore.functions.zso(form, 'start',false,'');
	if(not application.zcore.app.siteHasApp("rental")){
		application.zcore.status.setStatus(request.zsid,"Access denied");
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	if(structkeyexists(form,'return') and structkeyexists(form,'rental_amenity_id')){
		StructInsert(request.zsession, "rental_amenity_return"&form.rental_amenity_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	variables.queueSortStruct = StructNew();
	variables.queueSortStruct.tableName = "rental_amenity";
	variables.queueSortStruct.sortFieldName = "rental_amenity_sort";
	variables.queueSortStruct.primaryKeyName = "rental_amenity_id";

	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/rental/admin/rental-amenity/index';
	variables.queueSortStruct.datasource = request.zos.zcoreDatasource;
	variables.queueSortStruct.where ="  site_id = '#application.zcore.functions.zescape(request.zOS.globals.id)#' and rental_amenity_deleted='0'  ";
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom.init(variables.queueSortStruct);
	variables.queueSortCom.returnJson();
	</cfscript>
	<h2 style="display:inline;">Manage Rental Amenities | </h2>
	<cfscript>
	rateCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.rental.admin.controller.rates");
	rateCom.displayNavigation();
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qProp=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("7.6");
	db.sql="SELECT *  FROM #request.zos.queryObject.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
	WHERE
	rental_amenity.site_id = #db.param(request.zOS.globals.id)# and 
	rental_amenity_deleted = #db.param(0)#
	order by rental_amenity.rental_amenity_sort ASC, rental_amenity.rental_amenity_name ASC";
	qProp=db.execute("qProp");
	</cfscript>
	<table id="sortRowTable" style="border-spacing:0px;" class="table-list">
		<thead>
		<tr>
			<th>Rental Amenity</th>
			<th>Sort</th>
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="qProp">
			<cfscript>
			variables.queueSortCom.getRowStruct(qProp.rental_amenity_id);
			</cfscript>
			<tr #variables.queueSortCom.getRowHTML(qProp.rental_amenity_id)# <cfif qProp.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
				<td>#qProp.rental_amenity_name#</td>
				<td>#variables.queueSortCom.getAjaxHandleButton(qProp.rental_amenity_id)#</td>
				<td><!--- #variables.queueSortCom.getLinks(qProp.recordcount, qProp.currentrow, '/z/rental/admin/rental-amenity/index?rental_amenity_id=#qProp.rental_amenity_id#', "vertical-arrows")#  --->
				<a href="/z/rental/admin/rental-amenity/edit?rental_amenity_id=#qProp.rental_amenity_id#&amp;return=1">Edit</a> | 
				<a href="/z/rental/admin/rental-amenity/delete?rental_amenity_id=#qProp.rental_amenity_id#&amp;return=1">Delete</a></td>
			</tr>
		</cfloop>
		</tbody>
	</table>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var tempLink=0;
	var result=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Amenities", true);
	form.rental_amenity_id=application.zcore.functions.zso(form, 'rental_amenity_id');
	db.sql="SELECT * FROM #request.zos.queryObject.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
	WHERE rental_amenity_id = #db.param(form.rental_amenity_id)# and 
	site_id = #db.param(request.zOS.globals.id)#";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "Rental amenity is missing");
        application.zcore.functions.zRedirect("/z/rental/admin/rental-amenity/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
        result = db.sql="DELETE FROM #request.zos.queryObject.table("rental_x_amenity", request.zos.zcoreDatasource)#  
		WHERE  rental_amenity_id=#db.param(form.rental_amenity_id)# and 
		site_id = #db.param(request.zOS.globals.id)#";
		result=db.execute("result");
        result = db.sql="DELETE FROM #request.zos.queryObject.table("rental_amenity", request.zos.zcoreDatasource)#  
		WHERE  rental_amenity_id=#db.param(form.rental_amenity_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		result=db.execute("result");
		variables.queueSortCom.sortAll();
        application.zcore.status.setStatus(request.zsid, "Rental amenity deleted successfully.");
		if(structkeyexists(request.zsession, "rental_amenity_return"&form.rental_amenity_id)){
			var tempLink=request.zsession["rental_amenity_return"&form.rental_amenity_id];
			structdelete(request.zsession,"rental_amenity_return"&form.rental_amenity_id);
			application.zcore.functions.z301Redirect(tempLink);
		}else{
			application.zcore.functions.zRedirect("/z/rental/admin/rental-amenity/index?zsid="&request.zsid);
		}
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this rental amenity?<br />
		<br />
		Rental amenity: #qcheck.rental_amenity_name#<br />
		<br />
		<a href="/z/rental/admin/rental-amenity/delete?confirm=1&amp;rental_amenity_id=#form.rental_amenity_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/rental/admin/rental-amenity/index">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var myForm=structnew();
	var qCheck=0;
	var errors=0;
	var uniqueChanged=false;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Amenities", true);
	if(form.method EQ 'insert' and application.zcore.functions.zso(form,'rental_amenity_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ "insert"){
		db.sql="SELECT max(rental_amenity_sort) sort 
		FROM #request.zos.queryObject.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
		WHERE  site_id = #db.param(request.zOS.globals.id)# and 
		rental_amenity_deleted = #db.param(0)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0 or qCheck.sort EQ ""){
			form.rental_amenity_sort=1;
		}else{
			form.rental_amenity_sort=qCheck.sort+1;
		}
	}
	myForm.rental_amenity_name.required=true;
	myForm.rental_amenity_name.friendlyName="Name";
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rental-amenity/add?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rental-amenity/edit?rental_amenity_id=#form.rental_amenity_id#&zsid=#request.zsid#");
		}
	} 
	 
	 var redirecturl=0;
	form.site_id=request.zos.globals.id;
	var ts=StructNew();
	ts.table="rental_amenity";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.rental_amenity_id = application.zcore.functions.zInsert(ts);
		if(form.rental_amenity_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Rental amenity couldn't be added at this time.",form,true);
			application.zcore.functions.zredirect("/z/rental/admin/rental-amenity/add?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Rental amenity added successfully.");
			redirecturl=("/z/rental/admin/rental-amenity/index?zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Rental amenity failed to update.",form,true);
			application.zcore.functions.zredirect("/z/rental/admin/rental-amenity/edit?rental_amenity_id=#form.rental_amenity_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Rental amenity updated successfully.");
			redirecturl=("/z/rental/admin/rental-amenity/index?zsid="&request.zsid);
		}
	}
	
	if(structkeyexists(request.zsession, "rental_amenity_return"&form.rental_amenity_id)){
		tempLink=request.zsession["rental_amenity_return"&form.rental_amenity_id];
		structdelete(request.zsession,"rental_amenity_return"&form.rental_amenity_id);
		application.zcore.functions.z301Redirect(tempLink);
	}else{
		application.zcore.functions.zredirect(redirecturl);
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qRate=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("7.7");
	form.rental_amenity_id=application.zcore.functions.zso(form, 'rental_amenity_id',true);
	db.sql="SELECT * FROM #request.zos.queryObject.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
	WHERE rental_amenity_id = #db.param(form.rental_amenity_id)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qRate=db.execute("qRate");
	application.zcore.functions.zQueryToStruct(qRate,form,'rental_amenity_id,site_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "edit">
			Edit
			<cfelse>
			Add
		</cfif>
		Rental Amenity</h2>
	<p>Use this form to add/edit custom amenities that are used on the rental comparison and search features.</p>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/rental/admin/rental-amenity/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?rental_amenity_id=#form.rental_amenity_id#" method="post">
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Amenity Name","member.rental.amenity.edit rental_amenity_name")#</th>
				<td class="table-white"><input name="rental_amenity_name" size="50" type="text" value="#form.rental_amenity_name#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">&nbsp;</th>
				<td class="table-white"><button type="submit" class="table-shadow" value="submitForm">Save</button>
					<button type="button" class="table-shadow" name="cancel" value="Cancel" onclick="document.location = '/z/rental/admin/rental-amenity/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
