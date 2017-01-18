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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `exchange_rate`   
  CHANGE `exchange_rate_amount` `exchange_rate_amount` DECIMAL(11,6) UNSIGNED NOT NULL,
  ADD COLUMN `exchange_rate_datetime` DATETIME NOT NULL AFTER `exchange_rate_amount`, 
  ADD  UNIQUE INDEX `NewIndex1` (`exchange_rate_source_abbr`, `exchange_rate_destination_abbr`)")){
		return false;
	}    
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>