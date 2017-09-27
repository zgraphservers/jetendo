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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_feedback_x_user`(  
  `inquiries_feedback_x_user_id` INT UNSIGNED NOT NULL,
  `site_id` INT UNSIGNED NOT NULL,
  `inquiries_feedback_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  `user_id_siteidtype` INT UNSIGNED NOT NULL,
  `inquiries_feedback_x_user_read` CHAR(1) NOT NULL,
  `inquiries_feedback_x_user_updated_datetime` DATETIME NOT NULL,
  `inquiries_feedback_x_user_deleted` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`site_id`, `inquiries_feedback_x_user_id`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `inquiries_feedback_id`, `user_id`, `user_id_siteidtype`)
);
")){		return false;	}
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_feedback_x_user", "inquiries_feedback_x_user_id");
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>