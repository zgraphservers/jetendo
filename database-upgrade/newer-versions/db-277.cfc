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
  ADD COLUMN `inquiries_autoresponder_interested_in_model` VARCHAR(100) NOT NULL AFTER `inquiries_autoresponder_active`,
  ADD COLUMN `inquiries_autoresponder_main_image` VARCHAR(255) NOT NULL AFTER `inquiries_autoresponder_interested_in_model`")){		return false;	}
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>