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
  ADD COLUMN `site_seomoz_id_list` VARCHAR(100) NOT NULL AFTER `site_administrator_enable_force_delete`,
  ADD COLUMN `site_semrush_id_list` VARCHAR(100) NOT NULL AFTER `site_seomoz_id_list`,
  ADD COLUMN `site_webposition_id_list` VARCHAR(100) NOT NULL AFTER `site_semrush_id_list`")){
		return false;
	}   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>