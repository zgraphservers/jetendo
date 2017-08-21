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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  CHANGE `customer_id` `contact_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL")){		return false;	}
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_feedback`   
  ADD COLUMN `inquiries_feedback_type` CHAR(1) DEFAULT '0' NOT NULL AFTER `contact_id`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE `customer` ")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT IGNORE INTO `inquiries_type` (`inquiries_type_id`, `site_id`, `inquiries_type_name`, `inquiries_type_locked`, `inquiries_type_updated_datetime`) VALUES ('19', '0', 'Email', '1', '2017-08-17 14:27:25')")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>