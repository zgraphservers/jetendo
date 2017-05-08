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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job_config`   
  ADD COLUMN `job_config_home_metakey` VARCHAR(255) NOT NULL AFTER `job_config_disable_apply_online`,
  ADD COLUMN `job_config_home_metatitle` VARCHAR(255) NOT NULL AFTER `job_config_home_metakey`,
  ADD COLUMN `job_config_home_metadesc` VARCHAR(255) NOT NULL AFTER `job_config_home_metatitle`")){		return false;	}
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>