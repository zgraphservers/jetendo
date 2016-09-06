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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_config`  CHANGE `blog_config_url_author_id` `blog_config_url_author_id` INT(11) DEFAULT 0  NOT NULL")){
		return false;
	}    

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>