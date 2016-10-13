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
  ADD COLUMN `geocode_cache_accuracy` VARCHAR(25) NOT NULL AFTER `geocode_cache_status`,
  CHANGE `geocode_cache_client1_accuracy` `geocode_cache_client1_accuracy` VARCHAR(25) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `geocode_cache_client2_accuracy` `geocode_cache_client2_accuracy` VARCHAR(25) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `geocode_cache_client3_accuracy` `geocode_cache_client3_accuracy` VARCHAR(25) CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){
		return false;
	}         
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>