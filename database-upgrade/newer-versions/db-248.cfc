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
  ADD COLUMN `site_facebook_page_id_list` VARCHAR(255) NOT NULL AFTER `site_enable_send_to_friend`,
  ADD COLUMN `site_facebook_last_import_datetime` DATETIME NULL AFTER `site_facebook_page_id_list`")){
		return false;
	}         


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>