<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "update content set content_thumbnail_crop='0' where content_thumbnail_crop=''")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "update content_version set content_thumbnail_crop='0' where content_thumbnail_crop=''")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>