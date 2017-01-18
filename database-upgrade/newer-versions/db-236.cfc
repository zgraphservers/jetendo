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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `currency`(  
	  `currency_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `currency_code` VARCHAR(3) NOT NULL,
	  `currency_name` VARCHAR(100) NOT NULL,
	  `currency_updated_datetime` DATETIME NOT NULL,
	  `currency_deleted` INT(11) UNSIGNED NOT NULL,
	  PRIMARY KEY (`currency_id`),
	  UNIQUE INDEX `NewIndex1` (`currency_code`)
	)")){
		return false;
	}    
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>