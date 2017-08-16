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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `contact`   
	  ADD COLUMN `contact_parent_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `contact_id`, 
	  DROP INDEX `NewIndex1`,
	  ADD  UNIQUE INDEX `NewIndex1` (`site_id`, `contact_parent_id`, `contact_email`, `contact_deleted`)")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  DROP COLUMN `inquiries_cc`, 
  DROP COLUMN `inquiries_bcc`")){		return false;	}
	
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>