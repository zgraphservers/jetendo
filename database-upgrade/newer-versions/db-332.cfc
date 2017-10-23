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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
  ADD COLUMN `site_google_analytics_channel_goal_last_import_datetime` DATETIME NOT NULL AFTER `site_report_auto_send_email_list`,
  ADD COLUMN `site_google_adwords_channel_goal_last_import_datetime` DATETIME NOT NULL AFTER `site_google_analytics_channel_goal_last_import_datetime`")){		return false;	}
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `ga_month_channel_source_goal` (
  `ga_month_channel_source_goal_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `ga_month_channel_source_goal_name` varchar(50) NOT NULL,
  `ga_month_channel_source_goal_date` date NOT NULL,
  `ga_month_channel_source_goal_type` int(11) NOT NULL,
  `ga_month_channel_source_goal_channel` varchar(50) NOT NULL,
  `ga_month_channel_source_goal_source` varchar(255) NOT NULL,
  `ga_month_channel_source_goal_conversion_rate` decimal(10,5) unsigned NOT NULL,
  `ga_month_channel_source_goal_conversions` int(11) NOT NULL,
  `ga_month_channel_source_goal_sessions` int(11) NOT NULL,
  `ga_month_channel_source_goal_visits` int(11) NOT NULL,
  `ga_month_channel_source_goal_updated_datetime` datetime NOT NULL,
  `ga_month_channel_source_goal_deleted` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`ga_month_channel_source_goal_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`ga_month_channel_source_goal_type`,`ga_month_channel_source_goal_channel`,`ga_month_channel_source_goal_source`,`ga_month_channel_source_goal_date`,`ga_month_channel_source_goal_name`),
  KEY `NewIndex1` (`site_id`),
  KEY `NewIndex3` (`site_id`,`ga_month_channel_source_goal_type`,`ga_month_channel_source_goal_channel`,`ga_month_channel_source_goal_date`),
  KEY `NewIndex4` (`site_id`,`ga_month_channel_source_goal_type`,`ga_month_channel_source_goal_source`,`ga_month_channel_source_goal_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	return true;
	
	 application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(this.datasource, "ga_month_channel_source_goal", "ga_month_channel_source_goal_id");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>