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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `geocode_cache`(  
	  `geocode_cache_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `geocode_cache_address` VARCHAR(255) NOT NULL,
	  `geocode_cache_latitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_longitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_status` CHAR(1) NOT NULL DEFAULT '0',
	  `geocode_cache_client1_latitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_client1_longitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_client1_ip_address` VARCHAR(16) NOT NULL,
	  `geocode_cache_client1_status` VARCHAR(20) NOT NULL,
	  `geocode_cache_client1_accuracy` VARCHAR(15) NOT NULL,
	  `geocode_cache_client1_cached_datetime` DATETIME NOT NULL,
	  `geocode_cache_client2_latitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_client2_longitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_client2_ip_address` VARCHAR(16) NOT NULL,
	  `geocode_cache_client2_status` VARCHAR(20) NOT NULL,
	  `geocode_cache_client2_accuracy` VARCHAR(15) NOT NULL,
	  `geocode_cache_client2_cached_datetime` DATETIME NOT NULL,
	  `geocode_cache_client3_latitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_client3_longitude` DECIMAL(11,7) NOT NULL,
	  `geocode_cache_client3_ip_address` VARCHAR(16) NOT NULL,
	  `geocode_cache_client3_status` VARCHAR(20) NOT NULL,
	  `geocode_cache_client3_accuracy` VARCHAR(15) NOT NULL,
	  `geocode_cache_client3_cached_datetime` DATETIME NOT NULL,
	  `geocode_cache_confirm_count` tinyint(1) NOT NULL DEFAULT '0',
	  `geocode_cache_created_datetime` DATETIME NOT NULL,
	  `geocode_cache_updated_datetime` DATETIME NOT NULL,
	  `geocode_cache_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`geocode_cache_id`),
	  INDEX `NewIndex1` (`geocode_cache_address`),
	  INDEX `NewIndex2` (`geocode_cache_status`)
	)")){
		return false;
	}        
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>