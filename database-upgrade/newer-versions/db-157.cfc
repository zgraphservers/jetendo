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

	sql = "CREATE TABLE `job_x_category` (
  `job_x_category_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `job_category_id` int(11) unsigned NOT NULL DEFAULT '0',
  `job_x_category_updated_datetime` datetime NOT NULL,
  `job_x_category_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  `job_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`job_x_category_id`),
  UNIQUE KEY `NewIndex1` (`site_id`,`job_category_id`,`job_id`,`job_x_category_deleted`),
  KEY `NewIndex2` (`site_id`,`job_category_id`),
  KEY `NewIndex3` (`site_id`,`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin";

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, sql)){
		return false;
	}    


     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "job_x_category", "job_x_category_id");

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>