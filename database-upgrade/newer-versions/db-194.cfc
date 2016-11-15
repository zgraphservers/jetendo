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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `jetendo`.`user`   
  CHANGE `office_id` `office_id` VARCHAR(255) DEFAULT '0' NOT NULL, 
  ADD  INDEX `newindex3` (`site_id`),
  ADD  INDEX `newindex4` (`site_id`, `office_id`)")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>