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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `keyword_ranking`   
  ADD COLUMN `keyword_ranking_source_id` VARCHAR(50) NOT NULL AFTER `keyword_ranking_source_label`,
  ADD COLUMN `keyword_ranking_secondary` CHAR(1) DEFAULT '0' NOT NULL AFTER `keyword_ranking_source_id`")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>