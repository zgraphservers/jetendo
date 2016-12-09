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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `short_link`(  
  `short_link_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `short_link_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `short_link_url` VARCHAR(2048) NOT NULL,
  `short_link_updated_datetime` DATETIME NOT NULL,
  PRIMARY KEY (`site_id`, `short_link_id`),
  INDEX `NewIndex2` (`site_id`, `short_link_url`),
  INDEX `NewIndex1` (`site_id`)
)")){
		return false;
	}  
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "short_link", "short_link_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>