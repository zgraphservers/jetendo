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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_type`   
  ADD COLUMN `app_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `inquiries_type_deleted`, 
  ADD  INDEX `NewIndex2` (`site_id`, `app_id`)")){
		return false;
	}     

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `inquiries_type` (`inquiries_type_id`, `inquiries_type_name`, `inquiries_type_updated_datetime`) VALUES ('17', 'Job Resume', '0000-00-00 00:00:00')")){
		return false;
	}     

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE `inquiries_type` SET app_id='11' WHERE inquiries_type_id IN ('6', '7', '9', '10', '16', '14') AND site_id = '0'")){
		return false;
	}    

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE `inquiries_type` SET app_id='13' WHERE inquiries_type_id IN ('11') AND site_id = '0'")){
		return false;
	}     

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>