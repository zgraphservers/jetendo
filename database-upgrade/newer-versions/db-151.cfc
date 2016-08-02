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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `mls_option`   
  ADD COLUMN `mls_option_email_listing_agent_only` CHAR(1) DEFAULT '0'  NOT NULL AFTER `mls_option_max_map_distance_from_primary`")){
		return false;
	}   
	
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>