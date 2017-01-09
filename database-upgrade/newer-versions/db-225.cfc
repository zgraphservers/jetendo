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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `newsletter_email` (
  `newsletter_email_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `newsletter_email_sent_count` int(11) unsigned NOT NULL,
  `newsletter_email_name` varchar(255) NOT NULL,
  `newsletter_email_sent_datetime` datetime NOT NULL,
  `newsletter_email_external_id` varchar(50) NOT NULL,
  `newsletter_email_opens` int(11) unsigned NOT NULL,
  `newsletter_email_clicks` int(11) unsigned NOT NULL,
  `newsletter_email_bounces` int(11) unsigned NOT NULL,
  `newsletter_email_unsubscribes` int(11) unsigned NOT NULL,
  `newsletter_email_updated_datetime` datetime NOT NULL,
  `newsletter_email_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`newsletter_email_id`),
  UNIQUE KEY `NewIndex1` (`site_id`,`newsletter_email_external_id`),
  KEY `NewIndex2` (`site_id`),
  KEY `NewIndex3` (`site_id`,`newsletter_email_sent_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	}   

 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `newsletter_month` (
  `newsletter_month_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `newsletter_month_datetime` int(11) unsigned NOT NULL,
  `newsletter_month_total_subscribers` int(11) unsigned NOT NULL,
  `newsletter_month_new_subscribers` int(11) unsigned NOT NULL,
  `newsletter_month_unsubscribed` int(11) unsigned NOT NULL,
  `newsletter_month_updated_datetime` datetime NOT NULL,
  `newsletter_month_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`newsletter_month_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`newsletter_month_datetime`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	}   

 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `facebook_month` (
  `facebook_month_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `facebook_month_datetime` datetime NOT NULL,
  `facebook_month_paid_likes` int(11) unsigned NOT NULL,
  `facebook_month_organic_likes` int(11) unsigned NOT NULL,
  `facebook_month_unlikes` int(11) unsigned NOT NULL,
  `facebook_month_reach` int(11) unsigned NOT NULL,
  `facebook_month_views` int(11) unsigned NOT NULL,
  `facebook_month_fans` int(11) unsigned NOT NULL,
  `facebook_month_followers` int(11) unsigned NOT NULL,
  `facebook_month_updated_datetime` datetime NOT NULL,
  `facebook_month_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`facebook_month_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`facebook_month_datetime`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	}   

 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `facebook_post` (
  `facebook_post_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `facebook_post_datetime` datetime NOT NULL,
  `facebook_post_clicks` int(11) unsigned NOT NULL,
  `facebook_post_reactions` int(11) unsigned NOT NULL,
  `facebook_post_comments` int(11) unsigned NOT NULL,
  `facebook_post_shares` int(11) unsigned NOT NULL,
  `facebook_post_video_views` int(11) unsigned NOT NULL,
  `facebook_post_reach` int(11) unsigned NOT NULL,
  `facebook_post_external_id` varchar(50) NOT NULL,
  `facebook_post_impressions` int(11) unsigned NOT NULL,
  `facebook_post_fans` int(11) unsigned NOT NULL,
  `facebook_post_updated_datetime` datetime NOT NULL,
  `facebook_post_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`facebook_post_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`facebook_post_datetime`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){
		return false;
	}   
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "newsletter_email", "newsletter_email_id");
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "newsletter_month", "newsletter_month_id");
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "facebook_month", "facebook_month_id");
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "facebook_post", "facebook_post_id");
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>