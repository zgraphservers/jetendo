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
	  ADD COLUMN `inquiries_phone1_formatted` VARCHAR(50) NOT NULL AFTER `customer_id`,
	  ADD COLUMN `inquiries_phone2_formatted` VARCHAR(50) NOT NULL AFTER `inquiries_phone1_formatted`,
	  ADD COLUMN `inquiries_phone3_formatted` VARCHAR(50) NOT NULL AFTER `inquiries_phone2_formatted`")){		return false;	}            


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>