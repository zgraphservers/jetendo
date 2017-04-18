<cfcomponent>
<cfoutput>  
<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0; 
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#
	WHERE inquiries_autoresponder_id= #db.param(application.zcore.functions.zso(form,'inquiries_autoresponder_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)#  ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Autoresponder doesn''t exist or was already removed', false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#');
	} 
	db.sql="DELETE FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# WHERE 
	inquiries_autoresponder_id= #db.param(application.zcore.functions.zso(form, 'inquiries_autoresponder_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)#   ";
	q=db.execute("q");
	application.zcore.status.setStatus(Request.zsid, 'Autoresponder deleted');
	application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#');
	</cfscript> 
</cffunction>

<cffunction name="sendTest" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject; 
	form.email=application.zcore.functions.zso(form, 'email');
	form.format=application.zcore.functions.zso(form, 'format', true, 1);
 	form.inquiries_autoresponder_id=application.zcore.functions.zso(form, 'inquiries_autoresponder_id');

 	if(not application.zcore.functions.zEmailValidate(form.email)){
		application.zcore.status.setStatus(request.zsid, "You must enter a valid email.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/test?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#");
 	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# 
	WHERE  
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");
	if(qAutoresponder.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Autoresponder doesn't exist.");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#");
	}

	ts={
		// required
		inquiries_type_id:qAutoresponder.inquiries_type_id,
		inquiries_type_id_siteidtype:qAutoresponder.inquiries_type_id_siteidtype,
		to:request.zos.developerEmailTo,
		from:request.officeEmail,
		dataStruct:{
			firstName:"John",
			lastName:"Doe",
			interestedInModel:"abc123",
			email:request.zos.developerEmailTo
		},
		preview:false
		// optional
		//cc:""
	};
	rs=sendAutoresponder(ts);
	if(rs.success EQ false){
		rCom.setStatusErrors(request.zsid);
		application.zcore.status.setStatus(request.zsid, "Autoresponder test failed");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#"); 
	}
	application.zcore.status.setStatus(request.zsid, "Autoresponder test sent");
	application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#"); 
	</cfscript> 
</cffunction> 

<cffunction name="test" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject;  
	form.email=application.zcore.functions.zso(form, 'email');
	form.format=application.zcore.functions.zso(form, 'format', true, 1);
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_id') EQ ''){
		form.inquiries_autoresponder_id = -1;
	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#  
	WHERE  
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");
	application.zcore.functions.zQueryToStruct(qAutoresponder);
	application.zcore.functions.zStatusHandler(request.zsid,true); 
	</cfscript>
	<h2>Test Autoresponder</h2>
	<p>You can preview the autoresponder by sending it to your email address with this form.</p>
	<p>If the variables fail to insert during testing, there may be html tags in between the % and the keyword which must be manually fixed in the code.</p>
	<p>Subject: #form.inquiries_autoresponder_subject#</p>

	<h2>Send Test Email</h2>
	<form action="/z/inquiries/admin/autoresponder/sendTest" method="get">
		<input type="hidden" name="inquiries_autoresponder_id" value="#htmleditformat(form.inquiries_autoresponder_id)#">
		<p>Your Email: <input type="text" name="email" style="width:500px; max-width:100%;" value="#htmleditformat(form.email)#"></p>
		<!--- <p>HTML Format? #application.zcore.functions.zInput_Boolean("format")#</p> --->
		<p><input type="submit" name="Submit1" value="Send"> <input type="button" name="cancel" value="Cancel" onclick="window.location.href='/z/inquiries/admin/autoresponder/index';"></p>
	</form>
 
	<h2>or Preview as HTML below</h2> 
	<cfscript>
	ts={
		// required
		inquiries_type_id:qAutoresponder.inquiries_type_id,
		inquiries_type_id_siteidtype:qAutoresponder.inquiries_type_id_siteidtype,
		to:request.officeEmail,
		from:request.officeEmail,
		dataStruct:{
			firstName:"John",
			lastName:"Doe",
			interestedInModel:"abc123",
			email:request.officeEmail
		},
		preview:true
		// optional
		//cc:""
	};
	rs=sendAutoresponder(ts);
	if(rs.success){
		echo('<p>Subject: #rs.data.subject#</p><hr>');

		// convert to absolute links
		echo(rs.data.html);
	}else{
		echo('Failed to generate preview');
	}
	</cfscript>


</cffunction> 


<!--- 
ts={
	// required
	inquiries_type_id:"1",
	inquiries_type_id_siteidtype:"1",
	to:request.zos.developerEmailTo,
	from:request.officeEmail,
	dataStruct:{
		firstName:"John",
		email:"someone@somewhere.com",
		interestedInModel:"abc123"
	}
	// optional
	// cc:""
	//preview:false
};
autoResponderCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.autoresponder");
rs=autoResponderCom.sendAutoresponder(ts);
if(rs.success){

}else{

}
 --->
<cffunction name="sendAutoresponder" localmode="modern" access="public" roles="administrator">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	ss=arguments.ss;
	var db=request.zos.queryObject;  
	if(not structkeyexists(ss, 'to')){
		throw("arguments.ss.to is required");
	}
	if(not structkeyexists(ss, 'from')){
		throw("arguments.ss.from is required");
	}
	if(not structkeyexists(ss, 'inquiries_type_id')){
		throw("arguments.ss.inquiries_type_id is required");
	}
	if(not structkeyexists(ss, 'inquiries_type_id_siteidtype')){
		throw("arguments.ss.inquiries_type_id_siteidtype is required");
	}
	if(not structkeyexists(ss, 'preview')){
		ss.preview=false;
	}
	if(not structkeyexists(ss, 'dataStruct')){
		ss.dataStruct={};
	} 
	defaultStruct={
		firstName:"Customer",
		interestedInModel:"Unspecified Model",
		email:ss.to
	};
	structappend(ss.dataStruct, defaultStruct, false);

	db.sql="SELECT * FROM 
	#db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#,
	#db.table("inquiries_type", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_type.inquiries_type_id = inquiries_autoresponder.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_autoresponder.inquiries_type_id_siteidtype"))# and 
	inquiries_autoresponder.site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)# and 
	inquiries_type_deleted = #db.param(0)# and 
	inquiries_autoresponder.inquiries_type_id=#db.param(ss.inquiries_type_id)# and 
	inquiries_autoresponder.inquiries_type_id_siteidtype=#db.param(ss.inquiries_type_id_siteidtype)# "; 
	if(not ss.preview){
		db.sql&=" and inquiries_autoresponder_active=#db.param(1)# ";
	}
	qAutoresponder=db.execute("qAutoresponder"); 

	if(qAutoresponder.recordcount EQ 0){  
		return {success:false}; 
	}

	ts={};
	ts.subject=qAutoresponder.inquiries_autoresponder_subject;
	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getAutoresponderTemplate')){
		rs=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getAutoresponderTemplate(qAutoresponder.inquiries_type_name);
		if(ss.preview){ 
			if(structkeyexists(rs, 'defaultStruct')){
				structappend(ss.dataStruct, rs.defaultStruct, true);
			}	
			ss.dataStruct.email=ss.to;
		}
	}else{
		rs={
			htmlStart:'#application.zcore.functions.zHTMLDoctype()#
				<head>
				<meta charset="utf-8" />
				<title></title>
				</head> 
				<body>',
			htmlEnd:'</body>
			</html>'
		};

	}
	ts.html=rs.htmlStart&qAutoresponder.inquiries_autoresponder_html&rs.htmlEnd;

	ts.html=application.zcore.email.forceAbsoluteURLs(ts.html);
 
	// replace variables
	for(field in ss.dataStruct){
		value=ss.dataStruct[field];
		ts.html=replaceNoCase(ts.html, "%"&field&"%", value, "all");
	}
	ts.html=rereplace(ts.html, '%[^%]+%', '', 'all');
	ts.html=replace(ts.html, '%%', '%', 'all');


	ts.to=ss.to;
	ts.from=ss.from;
	if(application.zcore.functions.zso(ss, 'cc') NEQ ""){
		ts.cc=ss.cc;
	}
	if(ss.preview){
		return {success:true, data:ts};
	}
 
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rCom.setStatusErrors(request.zsid);
		application.zcore.status.setStatus(request.zsid, "Autoresponder test failed");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#"); 
	}
	return {success:true, data:ts};
	</cfscript> 
</cffunction> 

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	db=request.zos.queryObject;
	var ts={}; 
	init(); 
	form.typeId=application.zcore.functions.zso(form, 'typeId', false, ""); 
	ts.inquiries_autoresponder_subject.required=true;
	error = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);

	arrType=listToArray(form.typeId, "|");
	if(arrayLen(arrType) EQ 2){
		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE  
		inquiries_type_deleted=#db.param(0)# and 
		inquiries_type_id=#db.param(arrType[1])# and 
		site_id=#db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(arrType[2]))# ";
		qType=db.execute("qType"); 
		if(qType.recordcount EQ 0){
			error=true;
			application.zcore.status.setStatus(request.zsid, "Lead type is required.", form, true);
		}else{
			form.inquiries_type_id=arrType[1];
			form.inquiries_type_id_siteidtype=arrType[2];
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Lead type is required", form, true);
		error=true;
	}
	if(error){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/edit?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
		}
	}  
	form.inquiries_autoresponder_deleted=0;
	form.inquiries_autoresponder_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table='inquiries_autoresponder';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
 
	if(form.method EQ 'insert'){
		form.inquiries_autoresponder_id = application.zcore.functions.zInsert(ts);
		if(form.inquiries_autoresponder_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save autoresponder.  Note: there can only be 1 autoresponder per lead type.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Autoresponder saved.'); 
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save autoresponder.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/edit?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Autoresponder updated.');
		} 
	} 
	application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject; 
	var currentMethod=form.method; 
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_id') EQ ''){
		form.inquiries_autoresponder_id = -1;
	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# inquiries_autoresponder 
	WHERE  
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");
	application.zcore.functions.zQueryToStruct(qAutoresponder);
	application.zcore.functions.zStatusHandler(request.zsid,true);

	if(form.inquiries_autoresponder_active EQ ""){
		form.inquiries_autoresponder_active=1;
	}

	</cfscript>
	<h2><cfif currentMethod EQ "add">
		Add
		<cfscript>
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		</cfscript>
	<cfelse>
		Edit
	</cfif>
	Autoresponder</h2>
	 
	<cfscript>
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
			tabCom.init();
	tabCom.setTabs(["Basic"]);
	tabCom.setMenuName("admin-list"); 
	cancelURL="/z/inquiries/admin/autoresponder/index"; 
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();

	variableStruct={
		firstName:"John",
		interestedInModel:"Model",
		email:"test@test.com"
	};

	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getAutoresponderTemplate')){
		rs=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getAutoresponderTemplate("");
		if(structkeyexists(rs, 'defaultStruct')){
			structappend(variableStruct, rs.defaultStruct, true);
		}
	}
	
	</cfscript>

	<p>Be sure to use a simple one column plain text layout with no embedded assets to ensure users can read your content in any email client.  Colors/tables/videos/images may fail to load in an autoresponder.  Be sure to test the autoresponder after you make changes to it.</p>
	<p>The following variables can be included in the Body text. They will be replaced with the user's personal information when the autoresponder is sent.</p>
	<p>If the data for the variable is not available, a default value will be shown such as "Customer" for %firstName%</p>
	<ul>
		<cfscript>
		arrKey=structkeyarray(variableStruct);
		arraySort(arrKey, "text", "asc");
		for(field in arrKey){
			echo('<li>%#field#%</li>');
		}
		</cfscript>
	</ul>
	<p>If you need to insert a literal percent sign in the email, like 100%, you must type it twice so that it is not removed.  For example: 100%%.</p>

	<form id="listForm1" action="/z/inquiries/admin/autoresponder/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#" method="post">
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Basic")#

	<table style="width:100%;" class="table-list">  
		<cfscript>
		if(application.zcore.functions.zso(form, 'typeId') EQ ""){
			form.typeId=form.inquiries_type_id&"|"&form.inquiries_type_id_siteidtype;
		} 
		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		inquiries_type_deleted=#db.param(0)#";
		if(not application.zcore.app.siteHasApp("listing")){
			db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
		}
		if(not application.zcore.app.siteHasApp("rental")){
			db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
		}
		db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
		qType=db.execute("qType");
		arrLabel=[];
		arrValue=[];
		for(row in qType){
			arrayAppend(arrLabel, row.inquiries_type_name);
			arrayAppend(arrValue, row.inquiries_type_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id));
		}
		</cfscript>
		<tr>
			<th>Lead Type</th>
			<td>
				<cfscript> 
				selectStruct = StructNew();
				selectStruct.name = "typeId";
				selectStruct.listValuesDelimiter=chr(9);
				selectStruct.listLabelsDelimiter=chr(9);
				selectStruct.listLabels=arrayToList(arrLabel, chr(9));
				selectStruct.listValues=arrayToList(arrValue, chr(9));   
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
			</td>
		</tr>
		<tr>
			<th>Subject</th>
			<td><input type="text" name="inquiries_autoresponder_subject" id="inquiries_autoresponder_subject" value="#htmleditformat(form.inquiries_autoresponder_subject)#" /></td>
		</tr>
		<tr>
			<th>Body</th>
			<td>
				<p><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.html-editor");
				htmlEditor.instanceName	= "inquiries_autoresponder_html";
				htmlEditor.value			= form.inquiries_autoresponder_html;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "100%";
				htmlEditor.height		= 300;
				htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
				htmlEditor.create();
				</cfscript></p>

			</td>
		</tr>
		<!--- <tr>
			<th>Text Version</th>
			<td><textarea type="text" cols="50" rows="5" name="inquiries_autoresponder_text" id="inquiries_autoresponder_text">#htmleditformat(form.inquiries_autoresponder_text)#</textarea></td>
		</tr> --->
		<tr>
			<th>Active</th>
			<td>No <input type="hidden" name="inquiries_autoresponder_active" value="0"> 
				<!--- #application.zcore.functions.zInput_Boolean("inquiries_autoresponder_active")# --->
			</td>
		</tr> 
	</table> 
	#tabCom.endFieldSet()#  
	#tabCom.endTabMenu()#    
	</form>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="administrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Autoresponders");	 
	</cfscript>
</cffunction>	

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	init();  
	
	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	application.zcore.functions.zStatusHandler(request.zsid); 
 	searchOn=false; 
	db.sql="SELECT * 
	from #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# , 
	#db.table("inquiries_type", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_type.inquiries_type_id = inquiries_autoresponder.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_autoresponder.inquiries_type_id_siteidtype"))# and 
	inquiries_autoresponder.site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)# and 
	inquiries_type_deleted = #db.param(0)# 
	ORDER BY inquiries_type_name ASC ";
	qAutoresponder=db.execute("qAutoresponder"); 
	</cfscript>
	<h2>Manage Autoresponders</h2>
	<p>This is a new feature that is not activated yet.  Currently, you can setup autoresponders for each lead type, but you can't enable them.</p>
	<p><a href="/z/inquiries/admin/autoresponder/add">Add Autoresponder</a></p> 
 
	<cfif qAutoresponder.recordcount EQ 0>
		<p>No autoresponders found.</p>
	<cfelse> 
		<table class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Lead Type</th>  
				<th>Subject</th>  
				<th>Updated Date</th>  
				<th>Active</th>  
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfloop query="qAutoresponder">
				<tr <cfif qAutoresponder.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qAutoresponder.inquiries_autoresponder_id#</td> 
					<td>#qAutoresponder.inquiries_type_name#</td> 
					<td>#qAutoresponder.inquiries_autoresponder_subject#</td> 
					<td>#dateformat(qAutoresponder.inquiries_autoresponder_updated_datetime, "m/d/yy")#</td>
					<td><cfif qAutoresponder.inquiries_autoresponder_active EQ 1>Yes<cfelse>No</cfif></td>
					<td> 
						<a href="/z/inquiries/admin/autoresponder/test?inquiries_autoresponder_id=#qAutoresponder.inquiries_autoresponder_id#">Test</a> |  
					<a href="/z/inquiries/admin/autoresponder/edit?inquiries_autoresponder_id=#qAutoresponder.inquiries_autoresponder_id#">Edit</a> |  
						<a href="/z/inquiries/admin/autoresponder/delete?inquiries_autoresponder_id=#qAutoresponder.inquiries_autoresponder_id#" onclick="return window.confirm('Are you sure you want to remove this autoresponder?');">Delete</a> 

					</td>

				</tr>
				</cfloop>
			</tbody>
		</table> 
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>