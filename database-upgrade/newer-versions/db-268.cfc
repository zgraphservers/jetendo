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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE  `inquiries_autoresponder`(  
  `inquiries_autoresponder_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `inquiries_autoresponder_html` LONGTEXT NOT NULL,
  `inquiries_autoresponder_text` TEXT NOT NULL,
  `inquiries_autoresponder_subject` VARCHAR(255) NOT NULL,
  `inquiries_type_id` INT(11) UNSIGNED NOT NULL,
  `inquiries_autoresponder_updated_datetime` DATETIME NOT NULL,
  `inquiries_autoresponder_deleted` INT(11) UNSIGNED NOT NULL,
  `inquiries_autoresponder_active` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`, `inquiries_autoresponder_id`),
  INDEX `NewIndex1` (`site_id`),
  UNIQUE INDEX `NewIndex2` (`site_id`, `inquiries_type_id`)
)")){		return false;	}
  
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_autoresponder", "inquiries_autoresponder_id");
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>