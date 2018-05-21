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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `ecommerce_config`   
  ADD COLUMN `ecommerce_config_merchant_account` VARCHAR(20) NOT NULL AFTER `ecommerce_config_disable_physical_shipping`")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>