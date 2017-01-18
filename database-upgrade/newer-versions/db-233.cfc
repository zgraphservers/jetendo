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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `exchange_rate`(  
	  `exchange_rate_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `exchange_rate_source_abbr` VARCHAR(2) NOT NULL,
	  `exchange_rate_destination_abbr` VARCHAR(2) NOT NULL,
	  `exchange_rate_amount` DECIMAL(11,2) UNSIGNED NOT NULL,
	  `exchange_rate_updated_datetime` DATETIME NOT NULL,
	  `exchange_rate_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`exchange_rate_id`)
	)")){
		return false;
	}    
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>