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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `cloud_file`(  
  `cloud_file_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `cloud_file_name` VARCHAR(255) NOT NULL,
  `cloud_file_local_path` VARCHAR(255) NOT NULL,
  `cloud_file_url` VARCHAR(255) NOT NULL,
  `cloud_file_hash` VARCHAR(64) NOT NULL,
  `cloud_file_remote_path` VARCHAR(255) NOT NULL,
  `cloud_file_is_local` CHAR(1) NOT NULL DEFAULT '0',
  `cloud_file_is_online` CHAR(1) NOT NULL DEFAULT '0',
  `cloud_file_is_secure` CHAR(1) NOT NULL DEFAULT '0',
  `cloud_file_server_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `cloud_file_size` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `cloud_file_created_datetime` DATETIME NOT NULL,
  `cloud_file_deleted_datetime` DATETIME NOT NULL,
  `cloud_file_last_modified_datetime` DATETIME NOT NULL,
  `cloud_file_updated_datetime` DATETIME NOT NULL,
  `cloud_file_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `cloud_file_width` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `cloud_file_height` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `cloud_file_container_local_name` VARCHAR(100) NOT NULL,
  `cloud_vendor_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `cloud_file_id`),
  UNIQUE INDEX `NewIndex1` (`site_id`, `cloud_file_name`, `cloud_file_deleted`),
  INDEX `NewIndex2` (`site_id`)
)")){
		return false;
	}         
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `cloud_vendor`(  
  `cloud_vendor_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cloud_vendor_name` VARCHAR(50) NOT NULL,
  `cloud_vendor_updated_datetime` DATETIME NOT NULL,
  `cloud_vendor_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`cloud_vendor_id`),
  UNIQUE INDEX `NewIndex1` (`cloud_vendor_name`)
)")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `cloud_vendor` SET 
	cloud_vendor_name='Local Filesystem', cloud_vendor_deleted='0', cloud_vendor_updated_datetime='#request.zos.mysqlnow#' ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `cloud_vendor` SET 
	cloud_vendor_name='Rackspace Cloud Files', cloud_vendor_deleted='0', cloud_vendor_updated_datetime='#request.zos.mysqlnow#' ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `cloud_vendor` SET 
	cloud_vendor_name='Google Storage', cloud_vendor_deleted='0', cloud_vendor_updated_datetime='#request.zos.mysqlnow#' ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `cloud_vendor` SET 
	cloud_vendor_name='Microsoft Azure', cloud_vendor_deleted='0', cloud_vendor_updated_datetime='#request.zos.mysqlnow#' ")){
		return false;
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `cloud_vendor` SET 
	cloud_vendor_name='Amazon S3', cloud_vendor_deleted='0', cloud_vendor_updated_datetime='#request.zos.mysqlnow#' ")){
		return false;
	}

     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "cloud_file", "cloud_file_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>