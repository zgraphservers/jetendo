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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_autoresponder_drip_log` (
  `inquiries_autoresponder_drip_log_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_drip_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_drip_log_datetime` datetime NOT NULL,
  `inquiries_autoresponder_drip_log_email` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_log_status` varchar(20) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_log_deleted` int(11) NOT NULL,
  PRIMARY KEY (`site_id`, `inquiries_autoresponder_drip_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_autoresponder_drip` (
  `inquiries_autoresponder_drip_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_drip_subject` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_days_to_wait` tinyint(3) unsigned NOT NULL,
  `inquiries_autoresponder_drip_header_image` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_header_link` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_main_image` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_main_link` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_body_content` longtext NOT NULL,
  `inquiries_autoresponder_drip_footer_image` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_footer_link` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_drip_footer_text` text NOT NULL,
  `inquiries_autoresponder_drip_sort` int(10) unsigned NOT NULL DEFAULT '0',
  `inquiries_autoresponder_drip_active` char(1) NOT NULL DEFAULT '0',
  `inquiries_autoresponder_drip_updated_datetime` datetime NOT NULL,
  `inquiries_autoresponder_drip_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`inquiries_autoresponder_drip_id`),
  KEY `site_id` (`site_id`,`inquiries_autoresponder_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_autoresponder_subscriber` (
  `inquiries_autoresponder_subscriber_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_last_drip_id` int(11) unsigned NOT NULL,
  `inquiries_autoresponder_last_drip_datetime` datetime NOT NULL,
  `inquiries_autoresponder_subscriber_email` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_subscriber_first_name` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_subscriber_last_name` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_subscriber_interested_in_model` varchar(255) NOT NULL DEFAULT '',
  `inquiries_autoresponder_subscriber_subscribed` char(1) NOT NULL DEFAULT '0',
  `inquiries_autoresponder_subscriber_completed` char(1) NOT NULL DEFAULT '0',
  `inquiries_autoresponder_subscriber_updated_datetime` datetime NOT NULL,
  `inquiries_autoresponder_subscriber_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`inquiries_autoresponder_subscriber_id`),
  KEY `site_id` (`site_id`,`inquiries_autoresponder_id`),
  KEY `site_id_2` (`site_id`,`inquiries_autoresponder_subscriber_completed`,`inquiries_autoresponder_subscriber_subscribed`),
  KEY `site_id_3` (`site_id`,`inquiries_autoresponder_subscriber_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_autoresponder_drip", "inquiries_autoresponder_drip_id");
	 
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_autoresponder_subscriber", "inquiries_autoresponder_subscriber_id");
	 
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_autoresponder_drip_log", "inquiries_autoresponder_drip_log_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>