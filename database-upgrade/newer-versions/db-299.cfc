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
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `customer`   
  ADD COLUMN `customer_des_key` VARCHAR(15) NOT NULL AFTER `customer_deleted`")){		return false;	}
	   
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `user`   
  ADD COLUMN `user_des_key` VARCHAR(15) NOT NULL AFTER `user_last_login_datetime`")){		return false;	}
   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>