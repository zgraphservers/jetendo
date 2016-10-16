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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `cloud_file`   
  ADD COLUMN `cloud_file_sync_to_remote` CHAR(1) DEFAULT '0'  NOT NULL AFTER `cloud_file_config_id`,
  ADD COLUMN `cloud_file_sync_delete_local` CHAR(1) DEFAULT '0'  NOT NULL AFTER `cloud_file_sync_to_remote`")){
		return false;
	}          
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>