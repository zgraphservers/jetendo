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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `page` (
  `page_id` int(11) unsigned NOT NULL DEFAULT '0',
  `section_id` int(11) unsigned NOT NULL DEFAULT '0',
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `page_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  `page_name` varchar(150) NOT NULL DEFAULT '',
  `page_status` char(1) NOT NULL DEFAULT '0',
  `page_unique_url` varchar(150) NOT NULL DEFAULT '', 
  `page_created_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `page_updated_datetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `page_sort` int(11) unsigned NOT NULL DEFAULT '0',
  `page_image_library_id` int(11) unsigned NOT NULL DEFAULT '0',
  `page_image_library_layout` int(11) unsigned NOT NULL DEFAULT '0',
  `page_metatitle` varchar(255) NOT NULL DEFAULT '', 
  `page_metakey` text NOT NULL,
  `page_metadesc` text NOT NULL,
  `page_text` longtext NOT NULL,
  `page_text2` longtext NOT NULL,
  `page_text3` longtext NOT NULL,
  `page_summary` longtext NOT NULL,
  `page_search` LONGTEXT NOT NULL,
  PRIMARY KEY (`site_id`,`page_id`), 
  KEY `NewIndex1` (`site_id`, `section_id`),
  KEY `NewIndex2` (`page_unique_url`),
  KEY `NewIndex3` (`site_id`),
  FULLTEXT KEY `search` (`page_search`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}

	 application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(this.datasource, "page", "page_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>