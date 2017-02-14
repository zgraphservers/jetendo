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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option`   
  CHANGE `site_x_option_value` `site_x_option_value` LONGTEXT NOT NULL")){
		return false;
	}         

 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option_group`   
  CHANGE `site_x_option_group_value` `site_x_option_group_value` LONGTEXT NOT NULL")){
		return false;
	}         

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>