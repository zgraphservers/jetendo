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
  CHANGE `site_facebook_last_import_datetime` `site_facebook_last_import_datetime` DATETIME NOT NULL,
  ADD COLUMN `site_facebook_insights_start_date` DATE NOT NULL AFTER `site_facebook_last_import_datetime`")){
		return false;
	}         


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>