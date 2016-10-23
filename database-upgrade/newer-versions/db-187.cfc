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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `user`   
  ADD COLUMN `user_smtp_failed` CHAR(1) DEFAULT '0'  NOT NULL AFTER `user_reset_datetime`,
  ADD COLUMN `user_smtp_reason` VARCHAR(255) NOT NULL AFTER `user_smtp_failed`,
  ADD COLUMN `user_smtp_failed_email_list` TEXT NOT NULL AFTER `user_smtp_reason`")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>