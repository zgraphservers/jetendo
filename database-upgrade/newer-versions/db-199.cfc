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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `virtual_file` (
  `virtual_file_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `virtual_file_name` varchar(255) NOT NULL,
  `virtual_file_path` varchar(255) NOT NULL,
  `virtual_file_image_width` smallint(5) unsigned NOT NULL DEFAULT '0',
  `virtual_file_image_height` smallint(5) unsigned NOT NULL DEFAULT '0',
  `virtual_file_folder_id` int(11) unsigned NOT NULL,
  `virtual_file_secure` char(1) NOT NULL DEFAULT '0',
  `virtual_file_deleted` int(11) NOT NULL DEFAULT '0',
  `virtual_file_updated_datetime` datetime NOT NULL,
  PRIMARY KEY (`site_id`,`virtual_file_id`),
  KEY `NewIndex1` (`site_id`,`virtual_file_folder_id`,`virtual_file_name`),
  KEY `NewIndex2` (`site_id`,`virtual_file_folder_id`),
  KEY `NewIndex3` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	} 
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `virtual_folder` (
  `virtual_folder_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `virtual_folder_parent_id` int(11) unsigned NOT NULL,
  `virtual_folder_name` varchar(255) NOT NULL,
  `virtual_folder_path` varchar(255) NOT NULL,
  `virtual_folder_secure` char(1) NOT NULL DEFAULT '0',
  `virtual_folder_deleted` int(11) NOT NULL DEFAULT '0',
  `virtual_folder_updated_datetime` datetime NOT NULL,
  PRIMARY KEY (`site_id`,`virtual_folder_id`),
  KEY `NewIndex1` (`site_id`,`virtual_folder_parent_id`),
  KEY `NewIndex2` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>