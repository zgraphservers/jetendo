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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `keyword_ranking`(  
  `keyword_ranking_id` INT(11) UNSIGNED NOT NULL,
  `keyword_ranking_source` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `keyword_ranking_position` INT(11) UNSIGNED NOT NULL,
  `keyword_ranking_run_datetime` DATETIME NOT NULL,
  `keyword_ranking_keyword` VARCHAR(255) NOT NULL,
  `keyword_ranking_updated_datetime` DATETIME NOT NULL,
  `keyword_ranking_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `keyword_ranking_id`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `keyword_ranking_source`, `keyword_ranking_run_datetime`, `keyword_ranking_position`, `keyword_ranking_keyword`),
  INDEX `NewIndex2` (`site_id`),
  INDEX `NewIndex3` (`site_id`, `keyword_ranking_run_datetime`)
)")){
		return false;
	}   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>