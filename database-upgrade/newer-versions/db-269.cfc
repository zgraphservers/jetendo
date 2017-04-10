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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_autoresponder`   
  ADD COLUMN `inquiries_type_id_siteidtype` INT(11) UNSIGNED NOT NULL AFTER `inquiries_type_id`")){		return false;	}
    
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>