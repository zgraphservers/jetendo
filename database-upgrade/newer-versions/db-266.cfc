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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `track_user`  
  ADD COLUMN `track_user_first_visit_datetime` DATETIME NOT NULL AFTER `track_user_first_page`,
  ADD COLUMN `track_user_seconds_since_first_visit` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `track_user_first_visit_datetime`")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>