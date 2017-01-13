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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `newsletter_email`   
  ADD COLUMN `newsletter_email_external_newsletter_id` INT(11) UNSIGNED NOT NULL AFTER `newsletter_email_deleted`")){
		return false;
	}    
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>