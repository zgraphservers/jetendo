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
  ADD COLUMN `site_google_search_console_domain` VARCHAR(100) NOT NULL AFTER `site_semrush_domain`,
  ADD COLUMN `site_google_search_console_last_import_datetime` DATETIME NOT NULL AFTER `site_google_search_console_domain`,
  ADD COLUMN `site_google_analytics_keyword_last_import_datetime` DATETIME NOT NULL AFTER `site_google_search_console_last_import_datetime`,
  ADD COLUMN `site_google_analytics_organic_last_import_datetime` DATETIME NOT NULL AFTER `site_google_analytics_keyword_last_import_datetime`")){
		return false;
	}   

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>