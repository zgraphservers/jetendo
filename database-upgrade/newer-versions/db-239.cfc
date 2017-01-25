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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `form_capture`   
  ADD COLUMN `form_capture_form_name` VARCHAR(100) NOT NULL AFTER `form_capture_deleted`")){
		return false;
	}     
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>