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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `imap_account`   
  ADD COLUMN `imap_account_deleted` INT(11) DEFAULT 0 NOT NULL AFTER `imap_account_require_auth`,
  ADD COLUMN `imap_account_updated_datetime` DATETIME NOT NULL AFTER `imap_account_deleted`")){		return false;	}
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>