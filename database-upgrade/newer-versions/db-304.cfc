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

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `mail_user`   
  CHANGE `mail_user_id` `contact_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL,
  CHANGE `mail_user_email` `contact_email` VARCHAR(100) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `mail_user_first_name` `contact_first_name` VARCHAR(100) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `mail_user_last_name` `contact_last_name` VARCHAR(100) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `mail_user_key` `contact_key` CHAR(64) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `mail_user_confirm` `contact_confirm` CHAR(1) CHARSET utf8 COLLATE utf8_general_ci DEFAULT '0' NOT NULL,
  CHANGE `mail_user_confirm_count` `contact_confirm_count` TINYINT(3) UNSIGNED DEFAULT 0 NOT NULL,
  CHANGE `mail_user_datetime` `contact_datetime` DATETIME NOT NULL,
  CHANGE `mail_user_sent_datetime` `contact_sent_datetime` DATETIME NOT NULL,
  CHANGE `mail_user_opt_in` `contact_opt_in` CHAR(1) CHARSET utf8 COLLATE utf8_general_ci DEFAULT '1' NOT NULL,
  CHANGE `mail_user_confirm_datetime` `contact_confirm_datetime` DATETIME NOT NULL,
  CHANGE `mail_user_confirm_ip` `contact_confirm_ip` VARCHAR(15) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `mail_user_phone` `contact_phone` VARCHAR(30) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `mail_user_updated_datetime` `contact_updated_datetime` DATETIME NOT NULL,
  CHANGE `mail_user_deleted` `contact_deleted` INT(11) UNSIGNED DEFAULT 0 NOT NULL")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TRIGGER `mail_user_auto_inc`")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "RENAME TABLE `mail_user` TO `contact`")){		return false;	}
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "contact", "contact_id");
	
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>