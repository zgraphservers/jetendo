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
  ADD COLUMN `blog_config_layout_mode` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `blog_config_show_parent_site_authors`,
  ADD COLUMN `blog_config_enable_image_box_layout` CHAR(1) NOT NULL AFTER `blog_config_layout_mode`")){		return false;	}            


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>