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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content`   
  ADD COLUMN `content_text2` LONGTEXT NOT NULL AFTER `content_grid_id`,
  ADD COLUMN `content_text3` LONGTEXT NOT NULL AFTER `content_text2`")){		return false;	}
	 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content_version`   
  ADD COLUMN `content_text2` LONGTEXT NOT NULL AFTER `content_version_deleted`,
  ADD COLUMN `content_text3` LONGTEXT NOT NULL AFTER `content_text2`")){		return false;	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>