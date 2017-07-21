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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   ADD COLUMN `site_allow_duplicate_drip_subscription` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_enable_lead_reminder_office_manager_cc`")){		return false;	}
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>