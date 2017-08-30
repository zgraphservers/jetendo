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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `statistic` (
	  `statistic_id` int(11) unsigned NOT NULL,
	  `site_id` int(11) unsigned NOT NULL,
	  `statistic_datetime` datetime NOT NULL,
	  `statistic_type_id` int(11) unsigned NOT NULL,
	  `statistic_event` varchar(50) NOT NULL DEFAULT '',
	  `statistic_label` varchar(200) NOT NULL,
	  `statistic_count` int(11) unsigned NOT NULL,
	  `statistic_session_id` varchar(35) NOT NULL DEFAULT '',
	  PRIMARY KEY (`site_id`, `statistic_id`),
	  UNIQUE KEY `NewIndex1` (`site_id`,`statistic_session_id`,`statistic_type_id`,`statistic_event`,`statistic_label`),
	  KEY `NewIndex2` (`site_id`,`statistic_type_id`),
	  KEY `NewIndex3` (`statistic_datetime`)
	)  ENGINE=InnoDB, CHARSET=utf8 COLLATE=utf8_general_ci")){		return false;	}
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `statistic_type` (
	  `statistic_type_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	  `statistic_type_name` varchar(100) DEFAULT NULL,
	  PRIMARY KEY (`statistic_type_id`)
	)  ENGINE=InnoDB, CHARSET=utf8 COLLATE=utf8_general_ci")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "insert  into `statistic_type`(`statistic_type_id`,`statistic_type_name`) values 
	(1,'Listing'),
	(2,'Profile'),
	(3,'Ad'),
	(4,'Link'),
	(5,'Phone Link')")){		return false;	}
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "statistic", "statistic_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>