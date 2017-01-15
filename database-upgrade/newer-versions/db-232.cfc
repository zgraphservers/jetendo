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
  ADD COLUMN `site_monthly_email_campaign_count` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `site_campaign_monitor_last_import_datetime`,
  ADD COLUMN `site_monthly_email_campaign_alert_day_delay` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `site_monthly_email_campaign_count`")){
		return false;
	}    
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>