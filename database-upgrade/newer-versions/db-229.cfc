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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `newsletter_month`   
  ADD COLUMN `newsletter_month_bounces` INT(11) UNSIGNED NOT NULL AFTER `newsletter_month_unsubscribed`")){
		return false;
	}    
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>