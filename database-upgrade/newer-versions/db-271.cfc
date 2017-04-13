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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  ADD COLUMN `inquiries_interested_in_model` VARCHAR(150) NOT NULL AFTER `office_id`,
  ADD COLUMN `inquiries_interest_level` VARCHAR(50) NOT NULL AFTER `inquiries_interested_in_model`,
  ADD COLUMN `inquiries_interested_in_category` VARCHAR(100) NOT NULL AFTER `inquiries_interest_level`,
  ADD COLUMN `inquiries_last_contact_datetime` DATETIME NOT NULL AFTER `inquiries_interested_in_category`")){		return false;	}
    
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>