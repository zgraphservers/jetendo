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
	setting requesttimeout="6000";
	queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
 	
 	startTickCount=getTickCount();
 	if(structkeyexists(application, 'zExecuteHttpQueue')){
 		echo('zExecuteHttpQueue is already running.');
 		abort;
 	}
 	application.zExecuteHttpQueue=true;
	while(true){
		try{
			queueHttpCom.executeQueuedTasks();
		}catch(Any e){
			structdelete(application, 'zExecuteHttpQueue');
			rethrow;	
		}
		sleep(1000);
		if((getTickCount()-startTickCount)/1000 > 580){
			break;
		}
	}

	structdelete(application, 'zExecuteHttpQueue');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>