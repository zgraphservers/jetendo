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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TRIGGER IF EXISTS `facebook_post_auto_inc`")){
		return false;
	}     
	
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_post`   
  DROP COLUMN `site_id`, 
  DROP COLUMN `facebook_post_external_id`, 
  CHANGE `facebook_post_id` `facebook_post_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  ADD COLUMN `facebook_post_external_id` VARCHAR(50) NOT NULL AFTER `facebook_post_id`,
  ADD COLUMN `facebook_page_id` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_text`, 
  DROP INDEX `NewIndex2`,
  DROP INDEX `NewIndex1`,
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (`facebook_post_id`),
  ADD  INDEX `NewIndex2` (`facebook_page_id`),
  ADD  INDEX `NewIndex1` (`facebook_post_external_id`)")){
		return false;
	}      
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `facebook_page` (
  `facebook_page_id` int(11) unsigned NOT NULL AUTO_INCREMENT, 
  `facebook_page_external_id` varchar(50) NOT NULL, 
  `facebook_page_created_datetime` datetime NOT NULL,
  `facebook_page_paid_likes` int(11) unsigned NOT NULL,
  `facebook_page_organic_likes` int(11) unsigned NOT NULL,
  `facebook_page_unlikes` int(11) unsigned NOT NULL,
  `facebook_page_reach` int(11) unsigned NOT NULL,
  `facebook_page_views` int(11) unsigned NOT NULL,
  `facebook_page_fans` int(11) unsigned NOT NULL,
  `facebook_page_followers` int(11) unsigned NOT NULL,
  `facebook_page_updated_datetime` datetime NOT NULL,
  `facebook_page_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`facebook_page_id`),
  UNIQUE KEY (`facebook_page_external_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	}      
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>