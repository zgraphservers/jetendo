<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>	
	</cfscript>
</cffunction>	

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group
	WHERE dns_group_id= #db.param(application.zcore.functions.zso(form,'dns_group_id'))# ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'DNS Group no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		db.sql="DELETE FROM #db.table("dns_group", request.zos.zcoreDatasource)#  
		WHERE dns_group_id= #db.param(application.zcore.functions.zso(form, 'dns_group_id'))# ";
		q=db.execute("q");
		application.zcore.status.setStatus(Request.zsid, 'DNS Group deleted');
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this dns group?<br />
			<br />
			#qCheck.dns_group_name#<br />
			<br />
			<a href="/z/server-manager/admin/dns-group/delete?confirm=1&amp;dns_group_id=#form.dns_group_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/dns-group/index">No</a> 
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
	var ts={};
	var db=request.zos.queryObject;
	var result=0;
	variables.init();
	ts.dns_group_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/edit?dns_group_id=#form.dns_group_id#&zsid=#request.zsid#');
		}
	}
	form.dns_group_updated_datetime = request.zos.mysqlnow;
	ts=StructNew();
	ts.table='dns_group';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.dns_group_id = application.zcore.functions.zInsert(ts);
		if(form.dns_group_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns group.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Group saved.');
		}

	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns group.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/edit?dns_group_id=#form.dns_group_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Group updated.');
		}
		
	}
	db.sql="select * from #db.table("dns_zone", request.zos.zcoreDatasource)# 
	WHERE dns_zone_name = #db.param('default')# and 
	dns_group_id = #db.param(form.dns_group_id)# ";
	qZone=db.execute("qZone");
	if(qZone.recordcount EQ 0){
		ts=StructNew();
		ts.table='dns_zone';
		ts.datasource=request.zos.zcoreDatasource;
		ts.struct={};
		application.zcore.functions.zQueryToStruct(qZone, ts.struct);
		ts.struct.dns_zone_name="default";
		ts.struct.dns_group_id = form.dns_group_id;
		application.zcore.functions.zInsert(ts);
	}
	application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts=0;
	var db=request.zos.queryObject;
	var qRoute=0;
	var currentMethod=form.method;
	var htmlEditor=0;	
	if(application.zcore.functions.zso(form,'dns_group_id') EQ ''){
		form.dns_group_id = -1;
	}
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute);
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
		DNS Group</h2>
	<form action="/z/server-manager/admin/dns-group/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?dns_group_id=#form.dns_group_id#" method="post">
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Name</th>
				<td><input type="text" name="dns_group_name" value="#htmleditformat(form.dns_group_name)#" /></td>
			</tr>
			<tr>
				<th style="width:1%;">Comment</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_group_comment";
				ts.multiline=false;
				ts.size=100;
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<!--- <tr>
				<th>Phone</th>
				<td><input type="text" name="dns_group_phone" value="#htmleditformat(form.dns_group_phone)#" /></td>
			</tr> --->
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/server-manager/admin/dns-group/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qdns_group=0;
	var arrImages=0;
	var ts=0;
	var i=0;
	var rs=0;
	variables.init();
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
		application.zcore.functions.zredirect('/member/');	
	}
	application.zcore.functions.zStatusHandler(request.zsid);
 
	db.sql="SELECT *
	FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	LEFT JOIN #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone 
	ON dns_zone.dns_zone_name = #db.param('default')# and 
	dns_zone.dns_group_id = dns_group.dns_group_id 
	order by dns_group_name asc";
	qdns_group=db.execute("qdns_group");
	</cfscript>
	<h2>Manage DNS Groups</h2>
	<p><a href="/z/server-manager/admin/dns-group/add">Add DNS Group</a> | 
	<a href="/z/server-manager/admin/dns-group/import">Import Nettica</a></p>
	<cfif qdns_group.recordcount EQ 0>
		<p>No dns groups have been added.</p>
	<cfelse>
		<table  class="table-list">
			<tr>
				<th>Name</th>
				<th>Default A Records</th>
				<th>Comment</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qdns_group">
				<tr <cfif qdns_group.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qdns_group.dns_group_name#</td>
					<td><!--- #replace(qdns_group.dns_group_default_a, chr(10), "<br />", "ALL")# ---></td>
					<td>#qdns_group.dns_group_comment#</td>
					<td>
						<a href="/z/server-manager/admin/dns-zone/index?dns_group_id=#qdns_group.dns_group_id#">Manage Zones</a> | 
						<a href="/z/server-manager/admin/dns-record/index?dns_zone_id=#qdns_group.dns_zone_id#&amp;dns_group_id=#qdns_group.dns_group_id#">Manage Default Records</a> | 
						<a href="/z/server-manager/admin/dns-group/edit?dns_group_id=#qdns_group.dns_group_id#">Edit</a> | 
						<a href="/z/server-manager/admin/dns-group/delete?dns_group_id=#qdns_group.dns_group_id#">Delete</a></td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>

<cffunction name="import" localmode="modern" access="remote">
	<cfscript>
	path=request.zos.globals.privatehomedir&"zgraph-all-dns-records.txt";
	arrLine=listToArray(application.zcore.functions.zreadfile(path), chr(10));
	uniqueZone={};

echo("disabled");
abort;
	defaultStruct={
		dns_zone_soa_ttl: 3600,
		dns_zone_ttl:3600,
		dns_zone_expires:3600000,
		dns_zone_refresh:7200,
		dns_zone_minimum:172800,
		dns_zone_email:"hostmaster.zgraph.com",
	};
	for(i=1;i LTE arraylen(arrLine);i++){
		arrRow=listToArray(trim(arrLine[i]), ",");
		if(not structkeyexists(uniqueZone, arrRow[1])){
			ts={
				table:"dns_zone",
				datasource:request.zos.zcoreDatasource,
				struct:{
					dns_zone_name:arrRow[1],
					dns_zone_serial:dateformat(now(), "YYYYMMDD")&"01",
					dns_group_id:"2",
					dns_record_updated_datetime:request.zos.mysqlnow
				}
			}
			structappend(ts.struct, defaultStruct, false);
			uniqueZone[arrRow[1]]=application.zcore.functions.zInsert(ts);
		}
		ts={
			table:"dns_record",
			datasource:request.zos.zcoreDatasource,
			struct:{
				dns_zone_id:uniqueZone[arrRow[1]],
				dns_record_name:arrRow[1],
				dns_record_host:arrRow[2],
				dns_record_type:arrRow[3],
				dns_record_ttl:arrRow[4],
				dns_record_value:arrRow[5],
				dns_record_updated_datetime:request.zos.mysqlnow
			}
		}
		application.zcore.functions.zInsert(ts);

		writedump(arrRow);
		abort;
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
