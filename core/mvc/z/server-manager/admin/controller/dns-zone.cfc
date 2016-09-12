<cfcomponent>
<cfoutput>
<cffunction name="publishZone" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	publishZoneFile(form.dns_group_id, form.dns_zone_id, true);

	application.zcore.status.setStatus(request.zsid, "Zone published");
	application.zcore.functions.zRedirect("/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	</cfscript>
</cffunction>

<cffunction name="publishZones" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	if(structkeyexists(form, 'confirm')){
		setting requesttimeout="200";
		incrementAllZoneSerials();
		publishZoneFile(0, 0, true);

		application.zcore.status.setStatus(request.zsid, "All SOA serials were incremented, zones were re-published and bind notify messages were sent.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/dns-group/index?zsid=#request.zsid#");
	}else{
		echo('
		<div style="font-size:14px; font-weight:bold; text-align:center; "> 
			<div>Are you sure you want to publish all zones?<br />
			<br />
			It is not necessary to publish all zones in most cases since individual zone/record updates publish their changes automatically.<br />
			This feature is meant mostly to help developers republish after adding features or fixing bugs.<br />
			It may take a while for this operation to complete.  Please wait for it to complete.<br />
			<br />
			</div>
			<div class="publishDiv">
			<a href="/z/server-manager/admin/dns-zone/publishZones?confirm=1" onclick="$(''.loadPublishDiv'').show(); $(''.publishDiv'').hide();">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/dns-group/index">No</a> 
			</div>
			<div class="loadPublishDiv" style="display:none;">
			Publishing, please wait...</div>
		</div>');
	}
	</cfscript>
</cffunction>


<cffunction name="notifyZone" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="select * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# 
	WHERE dns_zone_id= #db.param(form.dns_zone_id)# and 
	dns_zone_deleted = #db.param(0)#  ";
	qZone=db.execute("qZone");
	if(request.zos.enableBind){
		r=application.zcore.functions.zSecureCommand("notifyBindZone#chr(9)##qZone.dns_zone_name#", 30);
		if(r EQ 0){
			throw("Failed to notify bind zone: #qZone.dns_zone_name#");
		}
	}
	application.zcore.status.setStatus(request.zsid, "Zone notified");
	application.zcore.functions.zRedirect("/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	</cfscript>
</cffunction>


<cffunction name="incrementAllZoneSerials" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# WHERE 
	dns_zone_deleted = #db.param(0)# 
	ORDER BY dns_zone_id ASC ";
	qZone=db.execute("qZone");
	for(row in qZone){
		if(row.dns_zone_serial EQ ""){
			serial=1;
		}else{
			serial=int(right(row.dns_zone_serial,2));
		}
		serial++;
		if(serial LT 10){
			serial=dateformat(now(), "YYYYMMDD")&"0"&serial;
		}else if(serial GT 100){
			throw("More then 100 zone serial updates in a single day is not supported.");
		}else{
			serial=dateformat(now(), "YYYYMMDD")&serial;
		}
		db.sql="update #db.table("dns_zone", request.zos.zcoreDatasource)# SET 
		dns_zone_serial= #db.param(serial)#, 
		dns_zone_updated_datetime = #db.param(request.zos.mysqlnow)# 
		WHERE dns_zone_id = #db.param(row.dns_zone_id)#  ";
		db.execute("qUpdate");
	}
	</cfscript>
</cffunction>

<cffunction name="incrementZoneSerial" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="numeric" required="yes">
	<cfargument name="publishIndex" type="boolean" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# 
	WHERE dns_zone_id= #db.param(arguments.dns_zone_id)# and 
	dns_zone_deleted = #db.param(0)#  ";
	qZone=db.execute("qZone");
	if(qZone.dns_zone_serial EQ ""){
		serial=1;
	}else{
		serial=int(right(qZone.dns_zone_serial,2));
	}
	serial++;
	if(serial LT 10){
		serial=dateformat(now(), "YYYYMMDD")&"0"&serial;
	}else if(serial GT 100){
		throw("More then 100 zone serial updates in a single day is not supported.");
	}else{
		serial=dateformat(now(), "YYYYMMDD")&serial;
	}
	db.sql="update #db.table("dns_zone", request.zos.zcoreDatasource)# SET 
	dns_zone_serial= #db.param(serial)#, 
	dns_zone_updated_datetime = #db.param(request.zos.mysqlnow)# 
	WHERE dns_zone_id = #db.param(arguments.dns_zone_id)# ";
	db.execute("qUpdate");

	publishZoneFile(qZone.dns_group_id, arguments.dns_zone_id, arguments.publishIndex);
	</cfscript>
</cffunction>

<cffunction name="formatDNSRecord" access="public" localmode="modern">
	<cfargument name="record" type="struct" required="yes">
	<cfscript>
	record=arguments.record;
	r="#record.dns_record_host# ";
	if(record.dns_record_ttl NEQ 0){
		r&=record.dns_record_ttl&" ";
	}
	r&="IN #record.dns_record_type# ";
	if(record.dns_ip_address NEQ ""){
		r&=record.dns_ip_address;
	}else if(record.dns_record_type EQ "TXT"){
		r&='"'&record.dns_record_value&'"';
	}else{
		r&=record.dns_record_value;
	}
	if(record.dns_record_type EQ "CNAME" or record.dns_record_type EQ "MX" or record.dns_record_type EQ "SRV" or record.dns_record_type EQ "NS"){
		if(right(record.dns_record_value, 1) NEQ "."){
			r&=".";
		}
	}
	r&=" ; #record.dns_record_comment#";
	return r;
	</cfscript>
</cffunction>

<cffunction name="publishZoneFile" localmode="modern" access="public">
	<cfargument name="dns_group_id" type="numeric" required="yes">
	<cfargument name="dns_zone_id" type="numeric" required="yes">
	<cfargument name="publishIndex" type="boolean" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("dns_group", request.zos.zcoreDatasource)# dns_group LEFT JOIN
	#db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone ON 
	dns_zone.dns_group_id = dns_group.dns_group_id and 
	dns_zone_deleted = #db.param(0)#  and 
	dns_zone.dns_zone_name = #db.param('default')# and 
	dns_group_deleted = #db.param(0)# ";
	if(arguments.dns_group_id NEQ 0){
		db.sql&=" WHERE dns_group.dns_group_id = #db.param(arguments.dns_group_id)# ";
	}
	db.sql&=" ORDER BY dns_group.dns_group_name ASC ";
	qGroups=db.execute("qGroups");


	defaultStruct={
		dns_group_default_soa_ttl: 3600,
		dns_group_default_ttl:3600,
		dns_group_default_expires:3600000,
		dns_group_default_refresh:86400,
		dns_group_default_retry:7200,
		dns_group_default_minimum:172800,
		dns_group_default_email:request.zos.developerEmailTo
	};
	for(group in qGroups){
		db.sql="select * from #db.table("dns_zone", request.zos.zcoreDatasource)# 
		WHERE dns_group_id = #db.param(group.dns_group_id)# and 
		dns_zone_deleted = #db.param(0)#  and 
		dns_zone_name <> #db.param('default')# ";
		if(arguments.dns_zone_id NEQ 0){
			db.sql&=" and dns_zone_id = #db.param(arguments.dns_zone_id)# ";
		}
		db.sql&=" ORDER BY dns_zone_name ASC ";
		qZones=db.execute("qZones");

		db.sql="select * from #db.table("dns_record", request.zos.zcoreDatasource)# 
		LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
		ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
		WHERE dns_zone_id = #db.param(group.dns_zone_id)#  and 
		dns_record_deleted = #db.param(0)# 
		ORDER BY dns_record_host asc, dns_record_type asc, dns_record_value asc";
		qGroupRecords=db.execute("qGroupRecords");

		for(zone in qZones){
			arrZone=[];
			if(zone.dns_zone_ttl EQ 0){
				if(group.dns_group_default_ttl EQ 0){
					zoneTTL=defaultStruct.dns_group_default_soa_ttl;
				}else{
					zoneTTL=group.dns_group_default_ttl;
				}
			}else{
				zoneTTL=zone.dns_zone_ttl;
			}
			if(zone.dns_zone_soa_ttl EQ 0){
				if(group.dns_group_default_soa_ttl EQ 0){
					soaTTL=defaultStruct.dns_group_default_soa_ttl;
				}else{
					soaTTL=group.dns_group_default_soa_ttl;
				}
			}else{
				soaTTL=zone.dns_zone_soa_ttl;
			}
			if(zone.dns_zone_refresh EQ 0){
				if(group.dns_group_default_refresh EQ 0){
					soaRefresh=defaultStruct.dns_group_default_refresh;
				}else{
					soaRefresh=group.dns_group_default_refresh;
				}
			}else{
				soaRefresh=zone.dns_zone_refresh;
			}
			if(zone.dns_zone_retry EQ 0){
				if(group.dns_group_default_retry EQ 0){
					soaretry=defaultStruct.dns_group_default_retry;
				}else{
					soaretry=group.dns_group_default_retry;
				}
			}else{
				soaretry=zone.dns_zone_retry;
			}
			if(zone.dns_zone_expires EQ 0){
				if(group.dns_group_default_expires EQ 0){
					soaexpires=defaultStruct.dns_group_default_expires;
				}else{
					soaexpires=group.dns_group_default_expires;
				}
			}else{
				soaexpires=zone.dns_zone_expires;
			}
			if(zone.dns_zone_minimum EQ 0){
				if(group.dns_group_default_minimum EQ 0){
					soaminimum=defaultStruct.dns_group_default_minimum;
				}else{
					soaminimum=group.dns_group_default_minimum;
				}
			}else{
				soaminimum=zone.dns_zone_minimum;
			}
			if(zone.dns_zone_email EQ ""){
				if(group.dns_group_default_email EQ 0){
					soaemail=defaultStruct.dns_group_default_email;
				}else{
					soaemail=group.dns_group_default_email;
				}
			}else{
				soaemail=zone.dns_zone_email;
			}
			db.sql="select * from #db.table("dns_record", request.zos.zcoreDatasource)# 
			LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
			ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
			WHERE dns_zone_id = #db.param(zone.dns_zone_id)# and 
			dns_record_deleted = #db.param(0)# 
			ORDER BY dns_record_host asc, dns_record_type asc, dns_record_value asc";
			qRecords=db.execute("qRecords");
			primaryNameserver="";
			for(record in qRecords){
				if(record.dns_record_type EQ "NS"){
					primaryNameserver=record.dns_record_value;
					break;
				}
			}
			if(primaryNameserver EQ ""){
				for(record in qGroupRecords){
					if(record.dns_record_type EQ "NS"){
						primaryNameserver=record.dns_record_value;
						break;
					}
				}
			}
			if(primaryNameserver EQ ""){
				application.zcore.status.setStatus(request.zsid, "The zone, ""#zone.dns_zone_name#"", is missing a nameserver (NS) record.  You must add at least one nameserver record before the zone can be published.", form, true);
				return false;
			}
			if(zone.dns_zone_primary_nameserver NEQ primaryNameserver){
				db.sql="update #db.table("dns_zone", request.zos.zcoreDatasource)# 
				SET dns_zone_primary_nameserver = #db.param(primaryNameserver)# 
				WHERE dns_zone_id = #db.param(zone.dns_zone_id)# ";
				db.execute("qUpdate");
			}
			arrayAppend(arrZone, "$TTL #zoneTTL# ;");
			arrayAppend(arrZone, "#zone.dns_zone_name#.  #soaTTL#  IN     SOA #primaryNameserver#.    #replace(soaemail, "@", ".")#. (");
			arrayAppend(arrZone, "	#zone.dns_zone_serial# ; serial");
			arrayAppend(arrZone, "	#soaRefresh# ; refresh");
			arrayAppend(arrZone, "	#soaretry# ; retry");
			arrayAppend(arrZone, "	#soaexpires# ; expire");
			arrayAppend(arrZone, "	#soaminimum# ; minimum");
			arrayAppend(arrZone, ")");
			arrayAppend(arrZone, "; custom resource records below");
			for(record in qRecords){
				arrayAppend(arrZone, formatDNSRecord(record));
			}
			arrayAppend(arrZone, "; default resource records below");
			customStruct={};
			if(zone.dns_zone_custom_ns EQ 1){
				customStruct["NS"]=true;
			}
			if(zone.dns_zone_custom_a EQ 1){
				customStruct["A"]=true;
			}
			if(zone.dns_zone_custom_aaaa EQ 1){
				customStruct["AAAA"]=true;
			}
			if(zone.dns_zone_custom_srv EQ 1){
				customStruct["SRV"]=true;
			}
			if(zone.dns_zone_custom_mx EQ 1){
				customStruct["MX"]=true;
			}
			if(zone.dns_zone_custom_txt EQ 1){
				customStruct["TXT"]=true;
			}
			if(zone.dns_zone_custom_cname EQ 1){
				customStruct["CNAME"]=true;
			}
			for(record in qGroupRecords){
				if(not structkeyexists(customStruct, record.dns_record_type)){
					arrayAppend(arrZone, formatDNSRecord(record));
				}
			}
			zoneOutput=arrayToList(arrZone, chr(10))&chr(10);
			application.zcore.functions.zcreatedirectory(request.zos.sharedPath&"dns-zones");
			zonePath=request.zos.sharedPath&"dns-zones/"&zone.dns_zone_name&".zone";
			application.zcore.functions.zWriteFile(zonePath, zoneOutput);


			if(arguments.dns_zone_id NEQ 0){
				publishZoneIndex(zone.dns_zone_id, false, arguments.publishIndex);
				if(request.zos.enableBind){
					r=application.zcore.functions.zSecureCommand("reloadBindZone"&chr(9)&zone.dns_zone_name, 30);
					if(r EQ 0){
						throw("Failed to reload bind zone: #zone.dns_zone_name#");
					}
				}
			}
		}
	}
	if(arguments.dns_zone_id EQ 0){
		publishZoneIndex(0, true, arguments.publishIndex);
		if(request.zos.enableBind){
			// reload all configuration files and notify the ones that changed
			r=application.zcore.functions.zSecureCommand("reloadBind", 30);
			if(r EQ 0){
				throw("Failed to reload all bind zones.");
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="publishZoneIndex" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="numeric" required="yes">
	<cfargument name="reloadBind" type="boolean" required="yes">
	<cfargument name="forcePublish" type="boolean" required="yes">
	<cfscript>
	zonePath="#request.zos.sharedPath#dns-zones/jetendo.named.conf.zones";
	if(not fileExists(zonePath)){
		arguments.dns_zone_id=0;
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone,
	#db.table("dns_group", request.zos.zcoreDatasource)# dns_group
	WHERE dns_group.dns_group_id = dns_zone.dns_group_id and 
	dns_zone_deleted = #db.param(0)#  and 
	dns_zone_name <> #db.param('default')# and 
	dns_group_deleted = #db.param(0)# ";
	if(arguments.dns_zone_id NEQ 0){
		db.sql&=" and dns_zone.dns_zone_id = #db.param(arguments.dns_zone_id)# ";
	}
	db.sql&=" ORDER BY dns_zone_name ASC ";
	qZones=db.execute("qZones");
	application.zcore.functions.zcreatedirectory("#request.zos.sharedPath#/dns-zones");
	arrZone=[];
	for(zone in qZones){
		zoneFilePath="#request.zos.sharedPath#dns-zones/#zone.dns_zone_name#.zone";
		if(not fileExists(zoneFilePath)){
			continue;
		}
		if(zone.dns_group_notify_ip_list NEQ ""){
			arrZ=listToArray(zone.dns_group_notify_ip_list, chr(10));
			arrIp=[];
			for(i=1;i LTE arraylen(arrZ);i++){
				if(arrZ[i] CONTAINS "|"){
					arrayAppend(arrIp, trim(listgetat(arrZ[i], 1, "|"))&";");
				}else{
					arrayAppend(arrIp, trim(arrZ[i])&";");
				}
			}
			notifyIPList=arrayToList(arrIp, "");
		}else{
			notifyIPList="";
		}
		arrayAppend(arrZone, '//zonestart|#zone.dns_zone_name#');
		arrayAppend(arrZone, 'zone "#zone.dns_zone_name#" in{');
		arrayAppend(arrZone, chr(9)&'type master;');
		arrayAppend(arrZone, chr(9)&'file "#zoneFilePath#";');
		arrayAppend(arrZone, chr(9)&'notify explicit;'); 
		if(notifyIPList NEQ ""){
			arrayAppend(arrZone, chr(9)&'also-notify { #notifyIPList# };');
			arrayAppend(arrZone, chr(9)&'allow-transfer { #notifyIPList# };');
		}
		arrayAppend(arrZone, '};');
		arrayAppend(arrZone, '//zoneend|#zone.dns_zone_name#');
	}
	zoneOut=arrayToList(arrZone, chr(10))&chr(10);
	if(arguments.dns_zone_id NEQ 0){
		contents=application.zcore.functions.zreadfile(zonePath);
		firstPos=find("//zonestart|#zone.dns_zone_name#", contents);
		lastPos=find("//zoneend|#zone.dns_zone_name#", contents);
		if(not arguments.forcePublish and firstPos NEQ 0){
			return;
		}
		if(firstPos EQ 0 and lastPos EQ 0){
			zoneOut=trim(contents)&chr(10)&trim(zoneOut);
		}else if(firstPos EQ 0 or lastPos EQ 0){
			throw("Zone file is formatted incorrectly.  You must go back and re-publish all zones to fix this.");
		}else{
			if(firstPos-1){
				startContent=left(contents, firstPos-1);
			}else{
				startContent="";
			}
			pos=lastPos+len("//zoneend|#zone.dns_zone_name#");
			endContent=mid(contents, pos, len(contents)-pos);
			zoneOut=trim(startContent)&chr(10)&zoneOut&chr(10)&trim(endContent);
		}
	}
	application.zcore.functions.zwritefile(zonePath, zoneOut&chr(10));
	if(request.zos.enableBind and arguments.reloadBind){
		application.zcore.functions.zSecureCommand("reloadBind", 30);
	}
	</cfscript>
</cffunction>

<cffunction name="setCustom" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="string" required="yes">
	<cfargument name="dns_record_type" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="update #db.table("dns_zone", request.zos.zcoreDatasource)# 
	SET `dns_zone_custom_#application.zcore.functions.zescape(arguments.dns_record_type)#`=#db.param(1)# WHERE 
	dns_zone_id=#db.param(arguments.dns_zone_id)#";
	db.execute("qUpdate");
	return true;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>	
	form.dns_group_id=application.zcore.functions.zso(form, 'dns_group_id', true, 0);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)# and 
	dns_group_deleted = #db.param(0)#";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "The selected dns group doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/dns-group/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#");
	}
	</cfscript>
</cffunction>	

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone
	WHERE dns_zone_id= #db.param(application.zcore.functions.zso(form,'dns_zone_id'))# and 
	dns_zone_deleted = #db.param(0)#  ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'dns zone no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		application.zcore.functions.zDeleteFile(request.zos.sharedPath&"dns-zones/"&qCheck.dns_zone_name&".zone");
		db.sql="UPDATE #db.table("dns_record", request.zos.zcoreDatasource)#  
		set dns_record_deleted = #db.param(1)#,
		dns_record_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE dns_zone_id= #db.param(application.zcore.functions.zso(form, 'dns_zone_id'))# ";
		q=db.execute("q");

		db.sql="UPDATE #db.table("dns_zone", request.zos.zcoreDatasource)#  
		set dns_zone_deleted = #db.param(1)#,
		dns_zone_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE dns_zone_id= #db.param(application.zcore.functions.zso(form, 'dns_zone_id'))# ";
		q=db.execute("q");
		publishZoneIndex(0, true, true);
		application.zcore.status.setStatus(Request.zsid, 'dns zone deleted');
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this dns zone?<br />
			<br />
			#qCheck.dns_zone_name#<br />
			<br />
			<a href="/z/server-manager/admin/dns-zone/delete?confirm=1&amp;dns_zone_id=#form.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/dns-zone/index?dns_group_id=#form.dns_group_id#">No</a> 
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
	var result=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	ts.dns_zone_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/add?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
		}else{
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/edit?dns_zone_id=#form.dns_zone_id#&dns_group_id=#form.dns_group_id#&zsid=#request.zsid#');
		}
	}
	if(form.method EQ "insert"){
		form.dns_zone_custom_ns="0";
		form.dns_zone_custom_cname="0";
		form.dns_zone_custom_a="0";
		form.dns_zone_custom_aaaa="0";
		form.dns_zone_custom_mx="0";
		form.dns_zone_custom_srv="0";
		form.dns_zone_custom_txt="0";
	}
	form.dns_zone_updated_datetime = request.zos.mysqlnow;
	ts=StructNew();
	ts.table='dns_zone';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.dns_zone_id = application.zcore.functions.zInsert(ts);
		if(form.dns_zone_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns zone.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/add?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Zone saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save dns zone.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/edit?dns_zone_id=#form.dns_zone_id#&dns_group_id=#form.dns_group_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Zone updated.');
		}
		
	}
	incrementZoneSerial(form.dns_zone_id, true);
	application.zcore.functions.zRedirect('/z/server-manager/admin/dns-zone/index?zsid=#request.zsid#&dns_group_id=#form.dns_group_id#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="getDefaultZoneStruct" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)# and 
	dns_group_deleted = #db.param(0)#";
	qGroup=db.execute("qGroup");

	defaultStruct={
		dns_zone_soa_ttl: 3600,
		dns_zone_ttl:3600,
		dns_zone_expires:3600000,
		dns_zone_refresh:86400,
		dns_zone_retry:7200,
		dns_zone_minimum:172800,
		dns_zone_email:request.zos.developerEmailTo
	};
	if(qGroup.dns_group_default_soa_ttl NEQ 0){
		defaultStruct.dns_zone_soa_ttl=qGroup.dns_group_default_soa_ttl;
	}
	if(qGroup.dns_group_default_ttl NEQ 0){
		defaultStruct.dns_zone_ttl=qGroup.dns_group_default_ttl;
	}
	if(qGroup.dns_group_default_retry EQ 0){
		defaultStruct.dns_zone_retry=qGroup.dns_group_default_retry;
	}
	if(qGroup.dns_group_default_expires NEQ 0){
		defaultStruct.dns_zone_expires=qGroup.dns_group_default_expires;
	}
	if(qGroup.dns_group_default_refresh NEQ 0){
		defaultStruct.dns_zone_refresh=qGroup.dns_group_default_refresh;
	}
	if(qGroup.dns_group_default_minimum NEQ 0){
		defaultStruct.dns_zone_minimum=qGroup.dns_group_default_minimum;
	}
	if(qGroup.dns_group_default_email NEQ ""){
		defaultStruct.dns_zone_email=qGroup.dns_group_default_email;
	}
	return defaultStruct;
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
	if(application.zcore.functions.zso(form,'dns_zone_id') EQ ''){
		form.dns_zone_id = -1;
	}
	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)# and 
	dns_group_deleted = #db.param(0)#";
	qGroup=db.execute("qGroup");
	db.sql="SELECT * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone 
	WHERE dns_zone_id=#db.param(form.dns_zone_id)# and 
	dns_zone_deleted = #db.param(0)# ";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute, form, 'dns_group_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);

	defaultStruct=getDefaultZoneStruct();
	if(form.dns_zone_soa_ttl EQ 0){
		form.dns_zone_soa_ttl="";
	}
	if(form.dns_zone_ttl EQ 0){
		form.dns_zone_ttl="";
	}
	if(form.dns_zone_expires EQ 0){
		form.dns_zone_expires="";
	}
	if(form.dns_zone_retry EQ 0){
		form.dns_zone_retry="";
	}
	if(form.dns_zone_refresh EQ 0){
		form.dns_zone_refresh="";
	}
	if(form.dns_zone_minimum EQ 0){
		form.dns_zone_minimum="";
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
		DNS Zone</h2>
	<form class="zFormCheckDirty" action="/z/server-manager/admin/dns-zone/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?dns_zone_id=#form.dns_zone_id#" method="post">
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Group</th>
				<td><cfscript>
					db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# WHERE 
					dns_group_deleted = #db.param(0)#
					ORDER BY dns_group_name";
					qGroups=db.execute("qGroups");
					selectStruct = StructNew();
					selectStruct.name = "dns_group_id";
					selectStruct.query = qGroups;
					selectStruct.queryLabelField = "dns_group_name";
					selectStruct.queryValueField = "dns_group_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr>
				<th>Name</th>
				<td><input type="text" name="dns_zone_name" size="50" value="#htmleditformat(form.dns_zone_name)#" /> (i.e. domain.com)</td>
			</tr>
			<tr>
				<th style="width:1%;">Comment</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_zone_comment";
				ts.multiline=false;
				ts.size=100;
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<tr>
				<td colspan="2">Leave the following blank to accept default values.</td>
			</tr>
			<tr>
				<th>Zone TTL</th>
				<td><input type="text" name="dns_zone_ttl" value="#htmleditformat(form.dns_zone_ttl)#" /> (Default: #defaultStruct.dns_zone_ttl#)</td>
			</tr>
			<tr>
				<th>Retry</th>
				<td><input type="text" name="dns_zone_retry" value="#htmleditformat(form.dns_zone_retry)#" /> (Default: #defaultStruct.dns_zone_retry#)</td>
			</tr>
			<tr>
				<th>Expires</th>
				<td><input type="text" name="dns_zone_expires" value="#htmleditformat(form.dns_zone_expires)#" /> (Default: #defaultStruct.dns_zone_expires#)</td>
			</tr>
			<tr>
				<th>Refresh</th>
				<td><input type="text" name="dns_zone_refresh" value="#htmleditformat(form.dns_zone_refresh)#" /> (Default: #defaultStruct.dns_zone_refresh#)</td>
			</tr>
			<tr>
				<th>Minimum</th>
				<td><input type="text" name="dns_zone_minimum" value="#htmleditformat(form.dns_zone_minimum)#" /> (Default: #defaultStruct.dns_zone_minimum#)</td>
			</tr>
			<tr>
				<th>SOA TTL</th>
				<td><input type="text" name="dns_zone_soa_ttl" value="#htmleditformat(form.dns_zone_soa_ttl)#" /> (Default: #defaultStruct.dns_zone_soa_ttl#)</td>
			</tr>
			<tr>
				<th>Email</th>
				<td><input type="text" name="dns_zone_email" value="#htmleditformat(form.dns_zone_email)#" /> (Default: #qGroup.dns_group_default_email#)</td>
			</tr>
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/server-manager/admin/dns-zone/index?dns_group_id=#form.dns_group_id#';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>



<cffunction name="listAllZones" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qdns_zone=0;
	var arrImages=0;
	var ts=0;
	var i=0;
	var rs=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zStatusHandler(request.zsid);

 
	db.sql="SELECT *
	FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone, 
	#db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group.dns_group_id=dns_zone.dns_group_id  and 
	dns_zone_deleted = #db.param(0)#  and 
	dns_group_deleted = #db.param(0)#
	GROUP BY dns_zone.dns_zone_id 
	order by dns_zone_name asc";
	qdns_zone=db.execute("qdns_zone");
	</cfscript>
	<p><a href="/z/server-manager/admin/dns-group/index">DNS Groups</a> / All Zones</p>
	<h2>All DNS Zones</h2>
	<cfif qdns_zone.recordcount EQ 0>
		<p>No dns zones have been added.</p>
	<cfelse>
		<table  class="table-list">
			<tr>
				<th>Name</th>
				<th>Group</td>
				<th>Comment</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qdns_zone">
				<tr <cfif qdns_zone.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qdns_zone.dns_zone_name#</td>
					<td>#qdns_zone.dns_group_name#</td>
					<td>#qdns_zone.dns_zone_comment#</td>
					<td>
						<a href="/z/server-manager/admin/dns-record/index?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#qdns_zone.dns_group_id#">Manage Records</a>
						<cfif qdns_zone.dns_zone_name NEQ "default">
							 | 
							<a href="/z/server-manager/admin/dns-zone/publishZone?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#qdns_zone.dns_group_id#">Publish</a> | 
							<a href="/z/server-manager/admin/dns-zone/notifyZone?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#qdns_zone.dns_group_id#">Notify</a> |
							<a href="/z/server-manager/admin/dns-zone/edit?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#qdns_zone.dns_group_id#">Edit</a>
							 | 
							<a href="/z/server-manager/admin/dns-zone/delete?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#qdns_zone.dns_group_id#">Delete</a>
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qdns_zone=0;
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

	db.sql="SELECT * FROM #db.table("dns_group", request.zos.zcoreDatasource)# dns_group 
	WHERE dns_group_id=#db.param(form.dns_group_id)# and 
	dns_group_deleted = #db.param(0)# ";
	qGroup=db.execute("qGroup");
 
	db.sql="SELECT *
	FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone 
	WHERE dns_group_id=#db.param(form.dns_group_id)# and 
	dns_zone_deleted = #db.param(0)# 
	GROUP BY dns_zone.dns_zone_id 
	order by dns_zone_name asc";
	qdns_zone=db.execute("qdns_zone");
	</cfscript>
	<p><a href="/z/server-manager/admin/dns-group/index">DNS Groups</a> / #qGroup.dns_group_name#</p>
	<h2>Manage DNS Zones</h2>
	<p><a href="/z/server-manager/admin/dns-zone/add?dns_group_id=#form.dns_group_id#">Add DNS Zone</a></p>
	<cfif qdns_zone.recordcount EQ 0>
		<p>No dns zones have been added.</p>
	<cfelse>
		<table  class="table-list">
			<tr>
				<th>Name</th>
				<th>Comment</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qdns_zone">
				<tr <cfif qdns_zone.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qdns_zone.dns_zone_name#</td>
					<td>#qdns_zone.dns_zone_comment#</td>
					<td>
						<a href="/z/server-manager/admin/dns-record/index?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Manage Records</a>
						<cfif qdns_zone.dns_zone_name NEQ "default">
							 | 
							<a href="/z/server-manager/admin/dns-zone/publishZone?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Publish</a> | 
							<a href="/z/server-manager/admin/dns-zone/notifyZone?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Notify</a> |
							<a href="/z/server-manager/admin/dns-zone/edit?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Edit</a>
							 | 
							<a href="/z/server-manager/admin/dns-zone/delete?dns_zone_id=#qdns_zone.dns_zone_id#&amp;dns_group_id=#form.dns_group_id#">Delete</a>
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
