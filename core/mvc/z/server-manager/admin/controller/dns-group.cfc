<cfcomponent>
<cfoutput> 

<!--- 

TODO: geo-location bind dns configuration:
			http://backreference.org/2010/02/01/geolocation-aware-dns-with-bind/
		
	use cronjob to automate bulk dns api change to opposite IP address
	update local nginx of remote server to call the other server while cfml server or database is down.
		location / {
				proxy_pass              http://lb;
				proxy_redirect          off;
				proxy_next_upstream     error timeout invalid_header http_500;
				proxy_connect_timeout   2;
				proxy_set_header        Host            $host;
				proxy_set_header        X-Real-IP       $remote_addr;
				proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
		}

	validate the notify_ip_list for correctness.

implement dns zone parser, instead of forcing many small fields.



 --->
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>	
	</cfscript>
</cffunction>	

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group
	WHERE dns_group_id= #db.param(application.zcore.functions.zso(form,'dns_group_id'))# and 
	dns_group_deleted = #db.param(0)# ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'DNS Group no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-group/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		db.sql="select * FROM #db.table("dns_zone", request.zos.zcoreDatasource)#  
		WHERE dns_group_id= #db.param(application.zcore.functions.zso(form, 'dns_group_id'))# and 
		dns_zone_name = #db.param('default')# and 
		dns_zone_deleted = #db.param(0)#  ";
		q=db.execute("q");
		if(q.recordcount NEQ 0){
			db.sql="UPDATE #db.table("dns_record", request.zos.zcoreDatasource)#  
			set dns_record_deleted = #db.param(1)#,
			dns_record_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE dns_zone_id= #db.param(q.dns_zone_id)# ";
			q=db.execute("q");
		}
		db.sql="UPDATE #db.table("dns_zone", request.zos.zcoreDatasource)#  
		set dns_zone_deleted = #db.param(1)#,
		dns_zone_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE dns_group_id= #db.param(application.zcore.functions.zso(form, 'dns_group_id'))# ";
		q=db.execute("q");
		db.sql="UPDATE #db.table("dns_group", request.zos.zcoreDatasource)#  
		set dns_group_deleted = #db.param(1)#,
		dns_group_updated_datetime=#db.param(request.zos.mysqlnow)#
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
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
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
	dns_group_id = #db.param(form.dns_group_id)# and 
	dns_zone_deleted = #db.param(0)#  ";
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
	zoneCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.dns-zone");
	zoneCom.publishZoneFile(0, 0, true);
	zoneCom.publishZoneIndex(0, true, true);
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
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	if(application.zcore.functions.zso(form,'dns_group_id') EQ ''){
		form.dns_group_id = -1;
	}
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)# and 
	dns_group_deleted = #db.param(0)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute);
	application.zcore.functions.zStatusHandler(request.zsid,true);


	defaultStruct={
		dns_group_default_soa_ttl: 3600,
		dns_group_default_ttl:3600,
		dns_group_default_expires:3600000,
		dns_group_default_refresh:86400,
		dns_group_default_retry:7200,
		dns_group_default_minimum:172800,
		dns_group_default_email:request.zos.developerEmailTo
	};
	if(form.dns_group_default_soa_ttl EQ 0){
		form.dns_group_default_soa_ttl=defaultStruct.dns_group_default_soa_ttl;
	}
	if(form.dns_group_default_ttl EQ 0){
		form.dns_group_default_ttl=defaultStruct.dns_group_default_ttl;
	}
	if(form.dns_group_default_expires EQ 0){
		form.dns_group_default_expires=defaultStruct.dns_group_default_expires;
	}
	if(form.dns_group_default_retry EQ 0){
		form.dns_group_default_retry=defaultStruct.dns_group_default_retry;
	}
	if(form.dns_group_default_refresh EQ 0){
		form.dns_group_default_refresh=defaultStruct.dns_group_default_refresh;
	}
	if(form.dns_group_default_minimum EQ 0){
		form.dns_group_default_minimum=defaultStruct.dns_group_default_minimum;
	}
	if(form.dns_group_default_email EQ ""){
		form.dns_group_default_email=defaultStruct.dns_group_default_email;
	}
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
	<form class="zFormCheckDirty" action="/z/server-manager/admin/dns-group/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?dns_group_id=#form.dns_group_id#" method="post">
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
			<tr>
				<th style="width:1%;">Notify IP List</th>
				<td>Enter 1 IP Address per line<br />
				Optionally add the hostname to the end like this 1.2.3.4|ns.host.name to monitor the IP for correctness.<br />
				<cfscript>
				ts=StructNew();
				ts.name="dns_group_notify_ip_list";
				ts.multiline=true;
				ts.size=130;
				ts.style="width:300px;height:100px;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			
			<tr>
				<th>SOA TTL</th>
				<td><input type="text" name="dns_group_default_soa_ttl" value="#htmleditformat(form.dns_group_default_soa_ttl)#" /> (Default: #defaultStruct.dns_group_default_soa_ttl#)</td>
			</tr>
			<tr>
				<th>Zone TTL</th>
				<td><input type="text" name="dns_group_default_ttl" value="#htmleditformat(form.dns_group_default_ttl)#" /> (Default: #defaultStruct.dns_group_default_ttl#)</td>
			</tr>
			<tr>
				<th>Retry</th>
				<td><input type="text" name="dns_group_default_retry" value="#htmleditformat(form.dns_group_default_retry)#" /> (Default: #defaultStruct.dns_group_default_retry#)</td>
			</tr>
			<tr>
				<th>Expires</th>
				<td><input type="text" name="dns_group_default_expires" value="#htmleditformat(form.dns_group_default_expires)#" /> (Default: #defaultStruct.dns_group_default_expires#)</td>
			</tr>
			<tr>
				<th>Refresh</th>
				<td><input type="text" name="dns_group_default_refresh" value="#htmleditformat(form.dns_group_default_refresh)#" /> (Default: #defaultStruct.dns_group_default_refresh#)</td>
			</tr>
			<tr>
				<th>Minimum</th>
				<td><input type="text" name="dns_group_default_minimum" value="#htmleditformat(form.dns_group_default_minimum)#" /> (Default: #defaultStruct.dns_group_default_minimum#)</td>
			</tr>
			<tr>
				<th>Email</th>
				<td><input type="text" name="dns_group_default_email" value="#htmleditformat(form.dns_group_default_email)#" /> (Default: #request.zos.developerEmailTo#)</td>
			</tr>
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
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
		application.zcore.functions.zredirect('/member/');	
	}
	application.zcore.functions.zStatusHandler(request.zsid);
 
	db.sql="SELECT *, count(distinct dns_zone2.dns_zone_id) zoneCount
	FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	LEFT JOIN #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone 
	ON dns_zone.dns_zone_name = #db.param('default')# and 
	dns_zone.dns_group_id = dns_group.dns_group_id  and 
	dns_zone.dns_zone_deleted = #db.param(0)# 
	LEFT JOIN #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone2 
	ON dns_zone2.dns_zone_name <> #db.param('default')# and 
	dns_zone2.dns_group_id = dns_group.dns_group_id  and 
	dns_zone2.dns_zone_deleted = #db.param(0)# 
	WHERE 
	dns_group_deleted = #db.param(0)#
	group by dns_group.dns_group_id 
	order by dns_group_name asc";
	qdns_group=db.execute("qdns_group");
	</cfscript>
	<h2>Manage DNS Groups</h2>
	<p><a href="/z/server-manager/admin/dns-group/add">Add DNS Group</a> | 
	<a href="/z/server-manager/admin/dns-group/import">Import Nettica</a> | 
	<a href="/z/server-manager/admin/dns-zone/listAllZones">List All Zones</a> | 
	<a href="/z/server-manager/admin/dns-zone/publishZones">Publish All Zones</a> | 
	<a href="/z/server-manager/admin/spf-validation/index">Manage SPF Domains</a></p>
	<cfif qdns_group.recordcount EQ 0>
		<p>No dns groups have been added.</p>
	<cfelse>
		<table  class="table-list">
			<tr>
				<th>Name</th>
				<th>Comment</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qdns_group">
				<tr <cfif qdns_group.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qdns_group.dns_group_name#</td>
					<td>#qdns_group.dns_group_comment#</td>
					<td>
						<a href="/z/server-manager/admin/dns-zone/index?dns_group_id=#qdns_group.dns_group_id#">Manage Zones</a> | 
						<a href="/z/server-manager/admin/dns-record/index?dns_zone_id=#qdns_group.dns_zone_id#&amp;dns_group_id=#qdns_group.dns_group_id#">Manage Default Records</a> | 
						<a href="/z/server-manager/admin/dns-group/edit?dns_group_id=#qdns_group.dns_group_id#">Edit</a>
						<cfif qdns_group.zoneCount EQ 0>
							 | 
							<a href="/z/server-manager/admin/dns-group/delete?dns_group_id=#qdns_group.dns_group_id#">Delete</a>
						</cfif>
						</td>
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
		dns_zone_refresh:86400,
		dns_zone_retry:7200,
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
