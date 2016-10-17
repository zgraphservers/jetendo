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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `queue_http`   
  ADD COLUMN `queue_http_name` VARCHAR(100) NOT NULL AFTER `queue_http_enable_parallel`, 
  ADD  INDEX `NewIndex1` (`site_id`, `queue_http_name`)")){
		return false;
	}          
	
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>