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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `directory_config` (
  `directory_config_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `directory_config_title` varchar(255) NOT NULL,
  `directory_config_deleted` char(1) NOT NULL DEFAULT '0',
  `directory_config_updated_datetime` datetime NOT NULL,
  PRIMARY KEY (`directory_config_id`,`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>