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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_config`   
  ADD COLUMN `blog_config_url_author_id` CHAR(1) DEFAULT '0'  NOT NULL AFTER `blog_config_enable_event`,
  ADD COLUMN `blog_config_show_parent_site_authors` CHAR(1) DEFAULT '0'  NOT NULL AFTER `blog_config_url_author_id`")){
		return false;
	}    

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>