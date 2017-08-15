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

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_x_contact`   
  ADD COLUMN `inquiries_x_contact_type` VARCHAR(3) NOT NULL AFTER `inquiries_x_contact_deleted`")){		return false;	}
	
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>