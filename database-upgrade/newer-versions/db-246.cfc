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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_post`   
  CHANGE `facebook_post_clicks` `facebook_post_consumptions` INT(11) UNSIGNED NOT NULL,
  ADD COLUMN `facebook_post_engaged_fan` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_consumptions`,
  ADD COLUMN `facebook_post_engaged_users` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_engaged_fan`,
  ADD COLUMN `facebook_post_negative_feedback` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_engaged_users`,
  ADD COLUMN `facebook_post_fan_reach` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_reach`")){
		return false;
	}         


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>