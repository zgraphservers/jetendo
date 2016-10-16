<cfcomponent>
<cffunction name="listContainers" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.cloudFile.listContainers();
	</cfscript>
</cffunction>

<cffunction name="processContainers" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.cloudFile.processContainers();
	</cfscript>
</cffunction>
</cfcomponent>