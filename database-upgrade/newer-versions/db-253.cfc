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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `listing_track`   
  ADD COLUMN `listing_track_sysid` INT(11) UNSIGNED NOT NULL AFTER `listing_track_inactive`, 
  ADD  INDEX `NewIndex5` (`listing_track_sysid`)")){
		return false;
	}            
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `listing_meta_table`(  
  `listing_meta_table_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `mls_id` INT(11) UNSIGNED NOT NULL,
  `listing_meta_table_external_id` VARCHAR(20) NOT NULL,
  `listing_meta_table_json` LONGTEXT,
  PRIMARY KEY (`listing_meta_table_id`),
  UNIQUE INDEX `NewIndex1` (`mls_id`, `listing_meta_table_external_id`),
  INDEX `NewIndex2` (`mls_id`)
)")){
		return false;
	}         
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `geoip_block` (
  `geoip_block_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_block_network_cidr` varchar(32) NOT NULL DEFAULT '',
  `geoip_location_id` int(11) unsigned NOT NULL,
  `geoip_block_registered_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_represented_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_is_anonymous_proxy` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_is_satellite_provider` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_postal_code` varchar(45) NOT NULL,
  `geoip_block_latitude` float NOT NULL,
  `geoip_block_longitude` float NOT NULL,
  `geoip_block_prefix` int(10) unsigned NOT NULL DEFAULT '0',
  `geoip_block_network` int(10) unsigned NOT NULL,
  `geoip_block_broadcast` int(10) unsigned NOT NULL,
  PRIMARY KEY (`geoip_block_id`),
  KEY `newindex1` (`geoip_block_network`,`geoip_block_broadcast`),
  KEY `newindex2` (`geoip_block_prefix`,`geoip_block_network`,`geoip_block_broadcast`)
) ENGINE=InnoDB AUTO_INCREMENT=3923665 DEFAULT CHARSET=utf8")){
		return false;
	}         
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `geoip_block_safe` (
  `geoip_block_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_block_network_cidr` varchar(32) NOT NULL DEFAULT '',
  `geoip_location_id` int(11) unsigned NOT NULL,
  `geoip_block_registered_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_represented_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_is_anonymous_proxy` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_is_satellite_provider` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_postal_code` varchar(45) NOT NULL,
  `geoip_block_latitude` float NOT NULL,
  `geoip_block_longitude` float NOT NULL,
  `geoip_block_prefix` int(10) unsigned NOT NULL DEFAULT '0',
  `geoip_block_network` int(10) unsigned NOT NULL,
  `geoip_block_broadcast` int(10) unsigned NOT NULL,
  PRIMARY KEY (`geoip_block_id`),
  KEY `newindex1` (`geoip_block_network`,`geoip_block_broadcast`),
  KEY `newindex2` (`geoip_block_prefix`,`geoip_block_network`,`geoip_block_broadcast`)
) ENGINE=InnoDB AUTO_INCREMENT=3923665 DEFAULT CHARSET=utf8")){
		return false;
	}      
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `geoip_location` (
  `geoip_location_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_location_locale_code` varchar(2) NOT NULL,
  `geoip_location_continent_code` varchar(2) NOT NULL,
  `geoip_location_continent_name` varchar(2) NOT NULL,
  `geoip_location_country_iso_code` varchar(2) NOT NULL,
  `geoip_location_country_name` varchar(45) NOT NULL,
  `geoip_location_subdivision_1_iso_code` varchar(4) NOT NULL,
  `geoip_location_subdivision_1_name` varchar(1000) NOT NULL,
  `geoip_location_subdivision_2_iso_code` varchar(4) NOT NULL,
  `geoip_location_subdivision_2_name` varchar(1000) NOT NULL,
  `geoip_location_city_name` varchar(1000) NOT NULL,
  `geoip_location_metro_code` int(11) NOT NULL,
  `geoip_location_postalCode` varchar(10) NOT NULL,
  PRIMARY KEY (`geoip_location_id`),
  KEY `geoip_location_city_name` (`geoip_location_city_name`(255))
) ENGINE=InnoDB AUTO_INCREMENT=11396062 DEFAULT CHARSET=utf8")){
		return false;
	}      
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `geoip_location_safe` (
  `geoip_location_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_location_locale_code` varchar(2) NOT NULL,
  `geoip_location_continent_code` varchar(2) NOT NULL,
  `geoip_location_continent_name` varchar(2) NOT NULL,
  `geoip_location_country_iso_code` varchar(2) NOT NULL,
  `geoip_location_country_name` varchar(45) NOT NULL,
  `geoip_location_subdivision_1_iso_code` varchar(4) NOT NULL,
  `geoip_location_subdivision_1_name` varchar(1000) NOT NULL,
  `geoip_location_subdivision_2_iso_code` varchar(4) NOT NULL,
  `geoip_location_subdivision_2_name` varchar(1000) NOT NULL,
  `geoip_location_city_name` varchar(1000) NOT NULL,
  `geoip_location_metro_code` int(11) NOT NULL,
  `geoip_location_postalCode` varchar(10) NOT NULL,
  PRIMARY KEY (`geoip_location_id`),
  KEY `geoip_location_city_name` (`geoip_location_city_name`(255))
) ENGINE=InnoDB AUTO_INCREMENT=11396062 DEFAULT CHARSET=utf8")){
		return false;
	}      


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>