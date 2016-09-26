<cfcomponent>
<cfoutput>
<cffunction name="viewErrors" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	} 
	queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
	queueHttpCom.displayHTTPQueueErrors(); 
	</cfscript>
</cffunction>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	} 
	setting requesttimeout="605";
	queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
 
	lock type="exclusive" timeout="600" throwontimeout="no" name="#request.zos.installPath#-zExecuteHttpQueue"{
		for(i=1;i<590;i++){
			queueHttpCom.executeQueuedTasks();
			sleep(1000);
		}
	}
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>