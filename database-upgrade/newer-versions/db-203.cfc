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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `virtual_folder`   
  DROP INDEX `NewIndex4`,
  ADD  UNIQUE INDEX `NewIndex4` (`site_id`, `virtual_folder_parent_id`, `virtual_folder_name`, `virtual_folder_deleted`)")){
		return false;
	} 
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `virtual_file`   
  DROP INDEX `NewIndex1`,
  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `virtual_file_folder_id`, `virtual_file_name`, `virtual_file_deleted`)")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>