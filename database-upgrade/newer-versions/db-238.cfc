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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `form_capture`(  
  `form_capture_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `form_capture_data` LONGTEXT NOT NULL,
  `form_capture_client_datetime` DATETIME NOT NULL,
  `form_capture_client_session` VARCHAR(64) NOT NULL,
  `form_capture_updated_datetime` DATETIME NOT NULL,
  `form_capture_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`form_capture_id`, `site_id`),
  INDEX `NewIndex1` (`site_id`),
  UNIQUE INDEX `NewIndex2` (`site_id`, `form_capture_client_session`, `form_capture_client_datetime`)
)")){
		return false;
	}    
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "form_capture", "form_capture_id");  
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>