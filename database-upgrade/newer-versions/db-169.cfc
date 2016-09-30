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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `geocode_cache`   
  ADD COLUMN `geocode_cache_callback_url` longtext NOT NULL AFTER `geocode_cache_hash`")){
		return false;
	}        
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>