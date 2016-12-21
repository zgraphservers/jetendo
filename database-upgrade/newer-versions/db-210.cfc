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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "TRUNCATE TABLE `image_cache`")){
		return false;
	}   
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `image_cache`   
  ADD  UNIQUE INDEX `NewIndex3` (`site_id`, `image_id`, `image_cache_width`, `image_cache_height`, `image_cache_crop`)")){
		return false;
	}   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>