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
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `queue_pop`   
  CHANGE `queue_pop_message_uid` `queue_pop_message_uid` VARCHAR(256) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  DROP COLUMN `queue_pop_header_data`, 
  DROP COLUMN `queue_pop_subject`, 
  DROP COLUMN `queue_pop_body_html`, 
  DROP COLUMN `queue_pop_file_json`, 
  DROP COLUMN `queue_pop_response`, 
  DROP COLUMN `queue_pop_timeout`, 
  ADD COLUMN `imap_account_id` INT(11) UNSIGNED NOT NULL AFTER `site_id`,
  CHANGE `queue_pop_last_run_datetime` `queue_pop_scheduled_processing_datetime` DATETIME NOT NULL,
  CHANGE `queue_pop_body_text` `queue_pop_message_json` LONGTEXT CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `queue_pop_fail_count` `queue_pop_process_fail_count` INT(11) NOT NULL,
  CHANGE `queue_pop_retry_interval` `queue_pop_process_retry_interval_seconds` INT(11) NOT NULL, 
  ADD  INDEX `NewIndex1` (`site_id`, `queue_pop_scheduled_processing_datetime`),
  ADD  INDEX `NewIndex2` (`site_id`)")){		return false;	}
  
   
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>