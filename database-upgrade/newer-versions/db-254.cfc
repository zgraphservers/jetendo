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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `listing_meta_table`   
  ADD COLUMN `listing_meta_table_resource_id` INT(11) UNSIGNED NOT NULL AFTER `mls_id`, 
  DROP INDEX `NewIndex1`,
  ADD  UNIQUE INDEX `NewIndex1` (`mls_id`, `listing_meta_table_resource_id`, `listing_meta_table_external_id`),
  ADD  INDEX `NewIndex3` (`mls_id`, `listing_meta_table_resource_id`)")){
		return false;
	}      


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>