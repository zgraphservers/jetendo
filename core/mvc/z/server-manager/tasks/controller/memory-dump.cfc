<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var s=0;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	} 
	setting requesttimeout="350";
	// lock all requests so that the object dumps are consistent
	lock type="exclusive" timeout="300" throwontimeout="no" name="#request.zos.installPath#-zDeployExclusiveLock"{
		application.zcore.functions.zCreateDirectory(request.zos.zcoreRootCachePath&"scripts/memory-dump/");
		local.coreDumpFile=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server[request.zos.cfmlServerKey].version&"-zcore.bin";
		local.tempCoreDumpFile=local.coreDumpFile&"."&gettickcount();
		objectsave(application.zcore, local.tempCoreDumpFile);
		application.zcore.functions.zdeletefile(local.coreDumpFile);
		application.zcore.functions.zRenameFile(local.tempCoreDumpFile, local.coreDumpFile);
		local.coreDumpFile=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server[request.zos.cfmlServerKey].version&"-sitestruct.bin";
		local.tempCoreDumpFile=local.coreDumpFile&"."&gettickcount();
		objectsave(application.sitestruct, local.tempCoreDumpFile);
		application.zcore.functions.zdeletefile(local.coreDumpFile);
		application.zcore.functions.zRenameFile(local.tempCoreDumpFile, local.coreDumpFile);
	};
	writeoutput('dump complete');
	abort;
	</cfscript>
</cffunction>


<cffunction name="logRecentRequestsError" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isdeveloper and not request.zos.istestserver and not request.zos.isserver){
		application.zcore.functions.z404("Only for servers / developers to run");
	}
	t9=duplicate(application.zcore.runningScriptStruct); 
	savecontent variable="out"{
		writeoutput('<h2>High CPU Alert - Dumping log of Running CFML Requests Below</h2>
		<table style="border-spacing:0px; padding:5px;">
		<tr><td>Running Time (seconds)</td><td>URL</td></tr>');
		
		for(i in t9){ 
			seconds=datediff("s",t9[i].startTime, now()); 
			if(structkeyexists(form, 'clearOldRunning') and seconds GT 3600){
				structdelete(application.zcore.runningScriptStruct,i);	
			}else{
				writeoutput('<tr><td>'&seconds&'</td><td>'&t9[i].url&'</td></tr>'); 
			} 
		}
		writeoutput('</table>');
	}

	ts={
		type:"Custom",
		errorHTML:out,
		scriptName:'/z/server-manager/admin/recent-requests/logRecentRequestsError',
		url:request.zos.originalURL,
		exceptionMessage:'High CPU Alert - Dumping log of Running CFML Requests Below',
		// optional
		lineNumber:'1'
	}
	application.zcore.functions.zLogError(ts);
	echo('Error logged');
	abort;
	</cfscript>	
</cffunction>
</cfoutput>
</cfcomponent>