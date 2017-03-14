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
  ADD COLUMN `keyword_ranking_source_label` VARCHAR(100) NOT NULL AFTER `keyword_ranking_search_volume`")){		return false;	}            

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`
  ADD COLUMN `site_semrush_label_primary` VARCHAR(100) NOT NULL AFTER `site_facebook_insights_start_date`,
  ADD COLUMN `site_semrush_label_list` TEXT NOT NULL AFTER `site_semrush_label_primary`")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>