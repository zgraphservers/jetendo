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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job_category`   
  ADD COLUMN `job_category_metatitle` VARCHAR(255) NOT NULL AFTER `job_category_updated_datetime`,
  ADD COLUMN `job_category_metakey` VARCHAR(255) NOT NULL AFTER `job_category_metatitle`,
  ADD COLUMN `job_category_metadesc` VARCHAR(255) NOT NULL AFTER `job_category_metakey`")){		return false;	}
	 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job`   
  ADD COLUMN `job_metatitle` VARCHAR(255) NOT NULL AFTER `job_external_id`,
  ADD COLUMN `job_metakey` VARCHAR(255) NOT NULL AFTER `job_metatitle`,
  ADD COLUMN `job_metadesc` VARCHAR(255) NOT NULL AFTER `job_metakey`")){		return false;	}
	 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_category`   
  ADD COLUMN `event_category_metatitle` VARCHAR(255) NOT NULL AFTER `event_category_searchable`,
  ADD COLUMN `event_category_metakey` VARCHAR(255) NOT NULL AFTER `event_category_metatitle`,
  ADD COLUMN `event_category_metadesc` VARCHAR(255) NOT NULL AFTER `event_category_metakey`")){		return false;	}
	 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_calendar`   
  ADD COLUMN `event_calendar_metatitle` VARCHAR(255) NOT NULL AFTER `event_calendar_searchable`,
  ADD COLUMN `event_calendar_metakey` VARCHAR(255) NOT NULL AFTER `event_calendar_metatitle`,
  ADD COLUMN `event_calendar_metadesc` VARCHAR(255) NOT NULL AFTER `event_calendar_metakey`")){		return false;	}
	 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  ADD COLUMN `event_metatitle` VARCHAR(255) NOT NULL AFTER `event_grid_id`,
  ADD COLUMN `event_metakey` VARCHAR(255) NOT NULL AFTER `event_metatitle`,
  ADD COLUMN `event_metadesc` VARCHAR(255) NOT NULL AFTER `event_metakey`")){		return false;	}
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>