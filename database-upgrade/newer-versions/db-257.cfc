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
  ADD COLUMN `inquiries_session_id` VARCHAR(35) NOT NULL AFTER `inquiries_spam_description`,
  ADD COLUMN `customer_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_session_id`")){		return false;	}            


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>