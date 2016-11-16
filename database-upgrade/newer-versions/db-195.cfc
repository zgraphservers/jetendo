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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `user_group`   
  ADD COLUMN `user_group_manage_full_subuser_group_id_list` VARCHAR(255) NOT NULL AFTER `user_group_deleted`,
  ADD COLUMN `user_group_manage_partial_subuser_group_id_list` VARCHAR(255) NOT NULL AFTER `user_group_manage_full_subuser_group_id_list`")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>