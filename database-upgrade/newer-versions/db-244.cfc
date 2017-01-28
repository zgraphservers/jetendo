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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_page_month`   
  ADD COLUMN `facebook_page_id` INT(11) NOT NULL AFTER `facebook_page_month_id`,
  CHANGE `facebook_page_month_external_id` `facebook_page_external_id` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `facebook_page_month_created_datetime` `facebook_page_month_datetime` DATETIME NOT NULL, 
  DROP INDEX `facebook_page_month_external_id`,
  ADD  UNIQUE INDEX `newIndex1` (`facebook_page_month_datetime`, `facebook_page_id`),
  ADD  INDEX `newIndex2` (`facebook_page_id`),
  ADD  INDEX `newIndex3` (`facebook_page_id`)")){
		return false;
	}       
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>