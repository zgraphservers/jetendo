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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option`   
  ADD COLUMN `site_option_label_on_top` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_option_user_group_id_list`,
  ADD COLUMN `site_option_add_to_previous_row` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_option_label_on_top`,
  ADD COLUMN `site_option_character_width` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `site_option_add_to_previous_row`")){
		return false;
	}    
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>