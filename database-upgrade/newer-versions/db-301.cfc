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
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `queue_pop`   
  ADD  UNIQUE INDEX `NewIndex3` (`site_id`, `imap_account_id`, `queue_pop_message_uid`(255))")){		return false;	}
  
   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>