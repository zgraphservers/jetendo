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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `statistic`   
  ADD COLUMN `statistic_updated_datetime` DATETIME NOT NULL AFTER `statistic_session_id`,
  ADD COLUMN `statistic_deleted` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `statistic_updated_datetime`")){		return false;	}
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `statistic_type`   
  CHANGE `statistic_type_name` `statistic_type_name` VARCHAR(100) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  ADD COLUMN `statistic_type_updated_datetime` DATETIME NOT NULL AFTER `statistic_type_name`,
  ADD COLUMN `statistic_type_deleted` INT(11) UNSIGNED NOT NULL AFTER `statistic_type_updated_datetime`")){		return false;	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>