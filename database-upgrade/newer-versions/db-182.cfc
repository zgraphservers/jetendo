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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `queue_http_api`(  
  `queue_http_api_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `queue_http_api_name` VARCHAR(255) NOT NULL,
  `queue_http_api_per_second_limit` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `queue_http_api_per_day_limit` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `queue_http_api_day_count` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `queue_http_api_updated_datetime` DATETIME NOT NULL,
  `queue_http_api_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`queue_http_api_id`),
  INDEX `NewIndex1` (`queue_http_api_name`)
)")){
		return false;
	}          
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `queue_http`   
  ADD COLUMN `queue_http_api_id` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `queue_http_enable_parallel`")){
		return false;
	} 

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO queue_http_api 
 SET 
 queue_http_api_name='cloud files - local',
 queue_http_api_per_second_limit='10',
 queue_http_api_per_day_limit='0',
 queue_http_api_day_count='0',
 queue_http_api_updated_datetime='#request.zos.mysqlnow#',
 queue_http_api_deleted='0' ")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO queue_http_api 
 SET 
 queue_http_api_name='cloud files - rackspace',
 queue_http_api_per_second_limit='95',
 queue_http_api_per_day_limit='0',
 queue_http_api_day_count='0',
 queue_http_api_updated_datetime='#request.zos.mysqlnow#',
 queue_http_api_deleted='0' ")){
		return false;
	} 
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>