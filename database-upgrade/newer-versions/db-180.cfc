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
  ADD COLUMN `cloud_file_disable_online` CHAR(1) DEFAULT '0'  NOT NULL AFTER `cloud_file_sync_delete_local`,
  ADD COLUMN `cloud_file_sync_to_local` CHAR(1) DEFAULT '0'  NOT NULL AFTER `cloud_file_disable_online`,
  ADD COLUMN `cloud_file_sync_delete_remote` CHAR(1) DEFAULT '0'  NOT NULL AFTER `cloud_file_sync_to_local`")){
		return false;
	}          
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `queue_http`   
  ADD COLUMN `queue_http_priority` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `queue_http_deleted`,
  ADD COLUMN `queue_http_enable_parallel` CHAR(1) DEFAULT '0'  NOT NULL AFTER `queue_http_priority`")){
		return false;
	}          
	
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>