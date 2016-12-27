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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `ga_month`(  
  `ga_month_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `ga_month_date` DATE NOT NULL,
  `ga_month_type` INT(11) NOT NULL, 
  `ga_month_sessions` INT(11) NOT NULL,
  `ga_month_visitors` INT(11) NOT NULL,
  `ga_month_visits` INT(11) NOT NULL,
  `ga_month_bounces` INT(11) NOT NULL,
  `ga_month_pageviews` INT(11) NOT NULL,
  `ga_month_visit_bounce_rate` DECIMAL(11,2) NOT NULL,
  `ga_month_time_on_site` INT(11) NOT NULL,
  `ga_month_average_time_on_site` DECIMAL(11,2) NOT NULL,
  `ga_month_updated_datetime` DATETIME NOT NULL,
  `ga_month_deleted` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `ga_month_id`),
  INDEX `NewIndex1` (`site_id`),
  UNIQUE INDEX `NewIndex2` (`site_id`, `ga_month_type`, `ga_month_date`)
)")){
		return false;
	}   
	
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `ga_month_keyword`(  
  `ga_month_keyword_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `ga_month_keyword_date` DATE NOT NULL,
  `ga_month_keyword_type` INT(11) NOT NULL, 
  `ga_month_keyword_keyword` varchar(255) NOT NULL,
  `ga_month_keyword_users` INT(11) NOT NULL,
  `ga_month_keyword_sessions` INT(11) NOT NULL,
  `ga_month_keyword_visitors` INT(11) NOT NULL,
  `ga_month_keyword_visits` INT(11) NOT NULL,
  `ga_month_keyword_bounces` INT(11) NOT NULL,
  `ga_month_keyword_pageviews` INT(11) NOT NULL,
  `ga_month_keyword_visit_bounce_rate` DECIMAL(11,2) NOT NULL,
  `ga_month_keyword_time_on_site` INT(11) NOT NULL,
  `ga_month_keyword_average_time_on_site` DECIMAL(11,2) NOT NULL,
  `ga_month_keyword_impressions` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `ga_month_keyword_ctr` DECIMAL(11,2) UNSIGNED NOT NULL DEFAULT 0,
  `ga_month_keyword_position` DECIMAL(11,2) UNSIGNED NOT NULL DEFAULT 0,
  `ga_month_keyword_updated_datetime` DATETIME NOT NULL,
  `ga_month_keyword_deleted` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `ga_month_keyword_id`),
  INDEX `NewIndex1` (`site_id`),
  UNIQUE INDEX `NewIndex2` (`site_id`, `ga_month_keyword_type`, `ga_month_keyword_keyword`, `ga_month_keyword_date`)
)")){
		return false;
	}   

 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
  ADD COLUMN `site_google_analytics_exclude_keyword_list` VARCHAR(500) NOT NULL AFTER `site_seomoz_last_import_datetime`,
  ADD COLUMN `site_semrush_domain` VARCHAR(100) NOT NULL AFTER `site_google_analytics_exclude_keyword_list`")){
		return false;
	}   

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>