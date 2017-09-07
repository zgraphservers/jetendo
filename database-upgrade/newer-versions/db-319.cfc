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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
  ADD COLUMN `site_enable_user_office_assign` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_public_user_manager_domain`,
  ADD COLUMN `site_enable_user_assign` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_enable_user_office_assign`")){		return false;	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>