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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `facebook_page_month` (
  `facebook_page_month_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `facebook_page_month_external_id` VARCHAR(50) NOT NULL,
  `facebook_page_month_created_datetime` DATETIME NOT NULL,
  `facebook_page_month_paid_likes` INT(11) UNSIGNED NOT NULL,
  `facebook_page_month_organic_likes` INT(11) UNSIGNED NOT NULL,
  `facebook_page_month_unlikes` INT(11) UNSIGNED NOT NULL,
  `facebook_page_month_reach` INT(11) UNSIGNED NOT NULL,
  `facebook_page_month_views` INT(11) UNSIGNED NOT NULL,
  `facebook_page_month_fans` INT(11) UNSIGNED NOT NULL,
  `facebook_page_month_followers` INT(11) UNSIGNED NOT NULL,
  `facebook_page_month_updated_datetime` DATETIME NOT NULL,
  `facebook_page_month_deleted` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`facebook_page_month_id`),
  UNIQUE KEY `facebook_page_month_external_id` (`facebook_page_month_external_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8")){
		return false;
	}      
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_post`   
  CHANGE `facebook_post_datetime` `facebook_post_created_datetime` DATETIME NOT NULL")){
		return false;
	}      
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>