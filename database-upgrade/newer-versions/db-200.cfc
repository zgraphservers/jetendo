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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `virtual_file`  
  ADD COLUMN `virtual_file_user_group_list` VARCHAR(255) NOT NULL AFTER `virtual_file_updated_datetime`,
  ADD COLUMN `virtual_file_size` INT(11) UNSIGNED NOT NULL AFTER `virtual_file_user_group_list`,
  ADD COLUMN `virtual_file_last_modified_datetime` DATETIME NOT NULL AFTER `virtual_file_size`,
  ADD  INDEX `NewIndex4` (`site_id`, `virtual_file_path`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `virtual_folder`   
  ADD COLUMN `virtual_folder_user_group_list` VARCHAR(255) NOT NULL AFTER `virtual_folder_updated_datetime`,
  ADD  INDEX `NewIndex3` (`site_id`, `virtual_folder_path`)")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>