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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `keyword_ranking`   
  DROP INDEX `NewIndex1`,
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `keyword_ranking_source`, `keyword_ranking_run_datetime`, `keyword_ranking_position`, `keyword_ranking_keyword`, `keyword_ranking_source_id`)")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>