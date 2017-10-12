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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_lead_template_x_site`   
  ADD COLUMN `inquiries_lead_template_x_site_siteidtype` INT(11) UNSIGNED NOT NULL AFTER `inquiries_lead_template_x_site_deleted`")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>