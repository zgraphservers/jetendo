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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `login_log`   
  DROP INDEX `NewIndex1`,
  ADD  INDEX `NewIndex1` (`site_id`, `login_log_username`)")){
		return false;
	}  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>