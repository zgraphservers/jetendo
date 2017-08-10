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

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_feedback`   
  ADD COLUMN `contact_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_feedback_draft`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_autoresponder_subscriber`   
  ADD COLUMN `contact_id` INT(11) UNSIGNED NOT NULL AFTER `inquiries_autoresponder_subscriber_fail_count`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_comment`   
  ADD COLUMN `contact_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `blog_comment_deleted`")){		return false;	}

  if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_autoresponder_drip_log`   
  ADD COLUMN `contact_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_type_id`")){		return false;	}
 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_x_contact`(  
	  `inquiries_x_contact_id` INT(11) UNSIGNED NOT NULL,
	  `contact_id` INT(11) UNSIGNED NOT NULL,
	  `inquiries_id` INT(11) UNSIGNED NOT NULL,
	  `site_id` INT(11) UNSIGNED NOT NULL,
	  `inquiries_x_contact_deleted` INT(11) UNSIGNED NOT NULL,
	  PRIMARY KEY (`inquiries_x_contact_id`, `site_id`),
	  INDEX `NewIndex1` (`site_id`, `inquiries_id`),
	  UNIQUE INDEX `NewIndex2` (`site_id`, `inquiries_id`, `contact_id`)
	)")){		return false;	}
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_x_contact", "inquiries_x_contact_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>