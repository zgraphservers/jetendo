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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_autoresponder` ADD `inquiries_autoresponder_from` VARCHAR(255)  NOT NULL  DEFAULT ''  AFTER `inquiries_autoresponder_subject`")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_autoresponder_drip` ADD `inquiries_autoresponder_drip_from` VARCHAR(255)  NOT NULL  DEFAULT ''  AFTER `inquiries_autoresponder_drip_subject`")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>