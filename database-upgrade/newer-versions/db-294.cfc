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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
  ADD COLUMN `site_plus_email_domain` VARCHAR(100) NOT NULL AFTER `site_drip_campaign_subscribe_index`,
  ADD COLUMN `site_enable_plus_email_routing` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_plus_email_domain`")){		return false;	}

	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_feedback`   
  DROP COLUMN `inquiries_feedback_from`, 
  DROP COLUMN `inquiries_feedback_to`, 
  DROP COLUMN `inquiries_feedback_bcc`, 
  CHANGE `inquiries_feedback_subject` `inquiries_feedback_subject` TEXT CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `inquiries_feedback_comments` `inquiries_feedback_comments` LONGTEXT NOT NULL,
  ADD COLUMN `inquiries_feedback_created_datetime` DATETIME NOT NULL AFTER `user_id_siteIDType`,
  ADD COLUMN `inquiries_feedback_message_json` LONGTEXT NOT NULL AFTER `inquiries_feedback_deleted`,
  ADD COLUMN `inquiries_feedback_draft` CHAR(1) DEFAULT '0' NOT NULL AFTER `inquiries_feedback_message_json`, 
  ADD  INDEX `NewIndex1` (`site_id`),
  ADD  INDEX `NewIndex2` (`site_id`, `inquiries_id`, `inquiries_feedback_datetime`)")){		return false;	}
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  ADD COLUMN `inquiries_cc` LONGTEXT NOT NULL AFTER `inquiries_last_contact_datetime`,
  ADD COLUMN `inquiries_bcc` LONGTEXT NOT NULL AFTER `inquiries_cc`")){		return false;	}
   
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `imap_account`(  
  `imap_account_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `imap_account_host` VARCHAR(100) NOT NULL,
  `imap_account_user` VARCHAR(100) NOT NULL,
  `imap_account_pass` VARCHAR(100) NOT NULL,
  `imap_account_port` INT UNSIGNED NOT NULL,
  `imap_account_ssl` CHAR(1) NOT NULL DEFAULT '0',
  `imap_account_require_auth` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`, `imap_account_id`),
  INDEX `NewIndex1` (`site_id`),
  UNIQUE INDEX `NewIndex2` (`site_id`, `imap_account_host`, `imap_account_user`)
)")){		return false;	}
	 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `queue_pop` (
  `queue_pop_id` INT(11) NOT NULL,
  `site_id` INT(11) NOT NULL,
  `queue_pop_message_uid` TEXT NOT NULL,
  `queue_pop_created_datetime` DATETIME NOT NULL,
  `queue_pop_updated_datetime` DATETIME NOT NULL,
  `queue_pop_last_run_datetime` DATETIME NOT NULL,
  `queue_pop_header_data` LONGTEXT NOT NULL,
  `queue_pop_subject` LONGTEXT NOT NULL,
  `queue_pop_body_text` LONGTEXT NOT NULL,
  `queue_pop_body_html` LONGTEXT NOT NULL,
  `queue_pop_file_json` LONGTEXT NOT NULL,
  `queue_pop_fail_count` INT(11) NOT NULL,
  `queue_pop_response` LONGTEXT NOT NULL,
  `queue_pop_timeout` INT(11) NOT NULL,
  `queue_pop_retry_interval` INT(11) NOT NULL,
  `queue_pop_deleted` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`queue_pop_id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ")){		return false;	}
	 
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "imap_account", "imap_account_id");
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "queue_pop", "queue_pop_id");
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>