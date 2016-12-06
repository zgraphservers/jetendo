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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `form_log`(  
  `form_log_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `form_log_url` VARCHAR(255) NOT NULL,
  `form_log_field1_label` VARCHAR(255) NOT NULL,
  `form_log_first_search` CHAR(1) NOT NULL DEFAULT '0',
  `form_log_datetime` DATETIME NOT NULL,
  `form_log_ip_address` VARCHAR(30) NOT NULL,
  `form_log_user_agent` VARCHAR(255) NOT NULL,
	`form_log_field1_value` VARCHAR(255) NOT NULL,
	`form_log_field2_label` VARCHAR(255) NOT NULL,
	`form_log_field2_value` VARCHAR(255) NOT NULL,
	`form_log_field3_label` VARCHAR(255) NOT NULL,
	`form_log_field3_value` VARCHAR(255) NOT NULL,
	`form_log_field4_label` VARCHAR(255) NOT NULL,
	`form_log_field4_value` VARCHAR(255) NOT NULL,
	`form_log_field5_label` VARCHAR(255) NOT NULL,
	`form_log_field5_value` VARCHAR(255) NOT NULL,
	`form_log_field6_label` VARCHAR(255) NOT NULL,
	`form_log_field6_value` VARCHAR(255) NOT NULL,
	`form_log_field7_label` VARCHAR(255) NOT NULL,
	`form_log_field7_value` VARCHAR(255) NOT NULL,
	`form_log_field8_label` VARCHAR(255) NOT NULL,
	`form_log_field8_value` VARCHAR(255) NOT NULL,
	`form_log_field9_label` VARCHAR(255) NOT NULL,
	`form_log_field9_value` VARCHAR(255) NOT NULL,
	`form_log_field10_label` VARCHAR(255) NOT NULL,
	`form_log_field10_value` VARCHAR(255) NOT NULL,
	`form_log_field11_label` VARCHAR(255) NOT NULL,
	`form_log_field11_value` VARCHAR(255) NOT NULL,
	`form_log_field12_label` VARCHAR(255) NOT NULL,
	`form_log_field12_value` VARCHAR(255) NOT NULL,
	`form_log_field13_label` VARCHAR(255) NOT NULL,
	`form_log_field13_value` VARCHAR(255) NOT NULL,
	`form_log_field14_label` VARCHAR(255) NOT NULL,
	`form_log_field14_value` VARCHAR(255) NOT NULL,
	`form_log_field15_label` VARCHAR(255) NOT NULL,
	`form_log_field15_value` VARCHAR(255) NOT NULL,
	`form_log_field16_label` VARCHAR(255) NOT NULL,
	`form_log_field16_value` VARCHAR(255) NOT NULL,
	`form_log_field17_label` VARCHAR(255) NOT NULL,
	`form_log_field17_value` VARCHAR(255) NOT NULL,
	`form_log_field18_label` VARCHAR(255) NOT NULL,
	`form_log_field18_value` VARCHAR(255) NOT NULL,
	`form_log_field19_label` VARCHAR(255) NOT NULL,
	`form_log_field19_value` VARCHAR(255) NOT NULL,
	`form_log_field20_label` VARCHAR(255) NOT NULL,
	`form_log_field20_value` VARCHAR(255) NOT NULL,
  `form_log_updated_datetime` DATETIME NOT NULL,
  `form_log_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`site_id`, `form_log_id`),
  INDEX `NewIndex1` (`site_id`),
  INDEX `NewIndex2` (`site_id`, `form_log_url`)
)")){
		return false;
	} 
 
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "form_log", "form_log_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>