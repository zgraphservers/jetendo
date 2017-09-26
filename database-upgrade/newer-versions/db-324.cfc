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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_directory_instance` (
  `zdir_directory_instance_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `zdir_directory_instance_name` varchar(100) NOT NULL,
  `zdir_directory_instance_grid_size` int(11) unsigned NOT NULL,
  `zdir_directory_instance_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`zdir_directory_instance_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_directory_instance_name`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_datasource` (
  `zdir_datasource_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `zdir_datasource_name` varchar(100) NOT NULL,
  `zdir_datasource_countable` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_cfc_path` varchar(255) NOT NULL,
  `zdir_datasource_saved_search_enable_saved_search` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_saved_search_table` varchar(100) NOT NULL,
  `zdir_datasource_saved_search_datasource` varchar(100) NOT NULL,
  `zdir_datasource_data_table` varchar(100) NOT NULL,
  `zdir_datasource_data_datasource` varchar(100) NOT NULL,
  `zdir_datasource_add_user_group_id_list` varchar(255) NOT NULL,
  `zdir_datasource_enable_multiple_select` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_multiple_enabled_user_group_id_list` varchar(255) NOT NULL,
  `zdir_datasource_multiple_limit_user_group_id_list` varchar(255) NOT NULL,
  `zdir_datasource_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`zdir_datasource_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_datasource_name`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_datasource_relationship` (
  `zdir_datasource_relationship_id` int(10) unsigned NOT NULL,
  `site_id` int(10) unsigned NOT NULL,
  `zdir_datasource_relationship_parent_id` int(10) unsigned NOT NULL,
  `zdir_datasource_relationship_child_id` int(10) unsigned NOT NULL,
  `zdir_datasource_relationship_combine_title` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_breadcrumbs_enabled` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_sidebar` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_track_count` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_hide_empty_children` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_featured_enabled` char(1) NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_sort` int(11) unsigned NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_column_count` int(11) unsigned NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_layout` int(11) unsigned NOT NULL DEFAULT '0',
  `zdir_datasource_relationship_parent_primary_field` varchar(100) NOT NULL,
  `zdir_datasource_relationship_child_primary_field` varchar(100) NOT NULL,
  `zdir_datasource_relationship_child_search_field_list` text NOT NULL,
  `zdir_datasource_relationship_cfc_path` varchar(255) NOT NULL,
  `zdir_datasource_relationship_cfc_get_by_id_method` varchar(100) NOT NULL,
  `zdir_datasource_relationship_cfc_search_children_method` varchar(100) NOT NULL,
  `zdir_datasource_relationship_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`zdir_datasource_relationship_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_datasource_relationship_parent_id`,`zdir_datasource_relationship_child_id`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_datasource_relationship_filter_map` (
  `zdir_datasource_relationship_filter_map_id` int(10) unsigned NOT NULL,
  `site_id` int(10) unsigned NOT NULL,
  `zdir_datasource_relationship_id` int(10) unsigned NOT NULL,
  `zdir_datasource_relationship_filter_map_source_field` varchar(100) NOT NULL,
  `zdir_datasource_relationship_filter_map_destination_field` varchar(100) NOT NULL,
  `zdir_datasource_relationship_filter_map_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`zdir_datasource_relationship_filter_map_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_datasource_relationship_id`,`zdir_datasource_relationship_filter_map_source_field`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_datasource_relationship_page` (
  `zdir_datasource_relationship_page_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `zdir_datasource_relationship_id` int(11) unsigned NOT NULL,
  `zdir_datasource_relationship_page_parent_id` int(11) unsigned NOT NULL,
  `zdir_datasource_relationship_page_child_id` int(11) unsigned NOT NULL,
  `zdir_datasource_relationship_page_parent_id_list` varchar(255) NOT NULL,
  `zdir_datasource_relationship_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`zdir_datasource_relationship_page_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_datasource_relationship_id`,`zdir_datasource_relationship_page_parent_id`,`zdir_datasource_relationship_page_child_id`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_listing` (
  `zdir_listing_id` int(11) unsigned NOT NULL,
  `zdir_listing_type_id` int(11) unsigned NOT NULL,
  `user_id` int(11) unsigned NOT NULL,
  `user_id_siteIDType` char(1) NOT NULL,
  `zdir_listing_title` varchar(255) NOT NULL,
  `zdir_listing_unique_url` varchar(255) NOT NULL,
  `zdir_listing_summary` text,
  `zdir_listing_body_text` text,
  `zdir_listing_thumbnail` varchar(255) NOT NULL,
  `zdir_listing_image_library_id` int(11) unsigned NOT NULL,
  `zdir_listing_featured` char(1) NOT NULL DEFAULT '0',
  `zdir_listing_status` char(1) NOT NULL DEFAULT '0',
  `zdir_listing_expiration_date` datetime DEFAULT NULL,
  `zdir_listing_external_id` varchar(255) NOT NULL,
  `zdir_listing_created_datetime` datetime DEFAULT NULL,
  `zdir_listing_activated_datetime` datetime DEFAULT NULL,
  `zdir_listing_status_updated_datetime` datetime DEFAULT NULL,
  `zdir_listing_updated_datetime` datetime DEFAULT NULL,
  `zdir_listing_deleted_datetime` datetime DEFAULT NULL,
  `zdir_listing_deleted` char(1) NOT NULL,
  `zdir_listing_address` varchar(255) NOT NULL,
  `zdir_listing_address2` varchar(255) NOT NULL,
  `zdir_listing_city` varchar(255) NOT NULL,
  `zdir_listing_state` varchar(2) NOT NULL,
  `zdir_listing_zip` varchar(20) NOT NULL,
  `zdir_listing_country` varchar(2) NOT NULL,
  `zdir_listing_latitude` decimal(11,7) NOT NULL,
  `zdir_listing_latitude_integer` int(11) NOT NULL,
  `zdir_listing_longitude` decimal(11,7) NOT NULL,
  `zdir_listing_longitude_integer` int(11) NOT NULL,
  `zdir_listing_contact_name` varchar(255) NOT NULL,
  `zdir_listing_phone1` varchar(30) NOT NULL,
  `zdir_listing_phone2` varchar(30) NOT NULL,
  `zdir_listing_toll_free` varchar(30) NOT NULL,
  `zdir_listing_fax` varchar(30) NOT NULL,
  `zdir_listing_website` varchar(255) NOT NULL,
  `zdir_listing_email` varchar(255) NOT NULL,
  `zdir_listing_file_1` varchar(255) NOT NULL,
  `zdir_listing_file_1_label` varchar(255) NOT NULL,
  `zdir_listing_file_2` varchar(255) NOT NULL,
  `zdir_listing_file_2_label` varchar(255) NOT NULL,
  `zdir_renewal_subscription_type_id` int(11) unsigned NOT NULL DEFAULT '0',
  `zdir_subscription_id` int(10) unsigned NOT NULL DEFAULT '0',
  `zdir_listing_price` decimal(11,2) NOT NULL DEFAULT '0.00',
  `zdir_listing_receive_payment` text NOT NULL,
  `zdir_listing_payment_html` longtext NOT NULL,
  `zdir_listing_paypal` varchar(50) NOT NULL,
  `zdir_listing_squaretrade` varchar(50) NOT NULL,
  `zdir_listing_social_facebook` varchar(255) NOT NULL,
  `zdir_listing_social_twitter` varchar(255) NOT NULL,
  `zdir_listing_social_youtube` varchar(255) NOT NULL,
  `zdir_listing_social_google` varchar(255) NOT NULL,
  `zdir_listing_social_instagram` varchar(255) NOT NULL,
  `zdir_listing_social_linkedin` varchar(255) NOT NULL,
  `zdir_listing_key` varchar(128) NOT NULL DEFAULT '',
  `zdir_listing_google_autocomplete_json` text NOT NULL,
  `zdir_listing_search` longtext NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`zdir_listing_id`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_listing_type` (
  `zdir_listing_type_id` int(11) unsigned NOT NULL,
  `zdir_listing_type_name` varchar(100) NOT NULL,
  `zdir_listing_type_deleted` int(11) NOT NULL DEFAULT '0',
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`zdir_listing_type_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_listing_type_name`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_city` (
  `zdir_city_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `zdir_city_name` varchar(98) NOT NULL DEFAULT '',
  `zdir_state_abbr` char(2) NOT NULL DEFAULT '',
  `zdir_country_code` char(2) NOT NULL DEFAULT '',
  `zdir_city_latitude` decimal(11,7) NOT NULL,
  `zdir_city_longitude` decimal(11,7) NOT NULL,
  `zdir_city_latitude_integer` int(11) NOT NULL,
  `zdir_city_longitude_integer` int(11) NOT NULL,
  `zdir_city_updated_datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`site_id`,`zdir_city_id`),
  UNIQUE KEY `city_name` (`site_id`,`zdir_country_code`,`zdir_state_abbr`,`zdir_city_name`),
  KEY `country_code2` (`site_id`,`zdir_country_code`,`zdir_city_name`),
  KEY `NewIndex1` (`site_id`,`zdir_city_name`),
  KEY `NewIndex2` (`site_id`,`zdir_city_latitude_integer`,`zdir_city_longitude_integer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_ad` (
  `zdir_ad_id` int(11) unsigned NOT NULL,
  `zdir_ad_type_id` int(11) unsigned NOT NULL,
  `zdir_listing_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `zdir_ad_name` varchar(100) NOT NULL,
  `zdir_ad_start_date` date NOT NULL,
  `zdir_ad_end_date` date NOT NULL,
  `zdir_ad_url` varchar(255) NOT NULL,
  `zdir_ad_image_desktop` varchar(255) NOT NULL,
  `zdir_ad_image_tablet` varchar(255) NOT NULL,
  `zdir_ad_image_mobile` varchar(255) NOT NULL,
  `zdir_ad_heading1` varchar(255) NOT NULL,
  `zdir_ad_heading2` varchar(25) NOT NULL,
  `zdir_ad_heading3` varchar(255) NOT NULL,
  `zdir_ad_text1` varchar(255) NOT NULL,
  `zdir_ad_text2` varchar(255) NOT NULL,
  `zdir_ad_text3` varchar(255) NOT NULL,
  `zdir_ad_image_desktop_original` varchar(255) NOT NULL,
  `zdir_ad_image_tablet_original` varchar(255) NOT NULL,
  `zdir_ad_image_mobile_original` varchar(255) NOT NULL,
  `zdir_ad_views` int(11) unsigned NOT NULL,
  `zdir_ad_clicks` int(11) unsigned NOT NULL,
  `zdir_ad_target` varchar(15) NOT NULL,
  `zdir_ad_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`zdir_ad_id`),
  UNIQUE KEY `NewIndex1` (`site_id`,`zdir_ad_name`),
  KEY `NewIndex2` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_ad_placement` (
  `zdir_ad_placement_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `zdir_ad_placement_parent_id` int(10) unsigned NOT NULL,
  `zdir_ad_placement_name` varchar(100) NOT NULL,
  `zdir_ad_placement_type` varchar(20) NOT NULL,
  `zdir_ad_placement_sub_type` varchar(30) NOT NULL,
  `zdir_ad_placement_rotation_method` varchar(30) NOT NULL,
  `zdir_ad_placement_slideshow_slide_milliseconds` int(11) unsigned NOT NULL,
  `zdir_ad_placement_code_name` varchar(100) NOT NULL,
  `zdir_ad_placement_variable1_label` varchar(50) NOT NULL,
  `zdir_ad_placement_variable1_code_name` varchar(50) NOT NULL,
  `zdir_ad_placement_variable2_label` varchar(50) NOT NULL,
  `zdir_ad_placement_variable2_code_name` varchar(50) NOT NULL,
  `zdir_ad_placement_variable3_label` varchar(50) NOT NULL,
  `zdir_ad_placement_variable3_code_name` varchar(50) NOT NULL,
  `zdir_ad_placement_variable4_label` varchar(50) NOT NULL,
  `zdir_ad_placement_variable4_code_name` varchar(50) NOT NULL,
  `zdir_ad_placement_variable5_label` varchar(50) NOT NULL,
  `zdir_ad_placement_variable5_code_name` varchar(50) NOT NULL,
  `zdir_ad_placement_deleted` int(11) unsigned NOT NULL,
  PRIMARY KEY (`site_id`,`zdir_ad_placement_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_ad_placement_parent_id`,`zdir_ad_placement_name`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `zdir_count_cache` (
  `zdir_count_cache_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `zdir_datasource_relationship_parent_id` int(11) unsigned NOT NULL,
  `zdir_datasource_relationship_child_id` int(11) unsigned NOT NULL,
  `zdir_count_cache_parent_page_id` int(11) unsigned NOT NULL,
  `zdir_count_cache_child_page_id` int(11) unsigned NOT NULL,
  `zdir_count_cache_child_count` int(11) unsigned NOT NULL DEFAULT '0',
  `zdir_count_cache_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`zdir_count_cache_id`),
  UNIQUE KEY `NewIndex2` (`site_id`,`zdir_datasource_relationship_parent_id`,`zdir_datasource_relationship_child_id`,`zdir_count_cache_parent_page_id`,`zdir_count_cache_child_page_id`),
  KEY `NewIndex1` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	 

     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_listing", "zdir_listing_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_listing_type", "zdir_listing_type_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_city", "zdir_city_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_ad", "zdir_ad_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_ad_placement", "zdir_ad_placement_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_count_cache", "zdir_count_cache_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_datasource_relationship_page", "zdir_datasource_relationship_page_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_datasource_relationship_filter_map", "zdir_datasource_relationship_filter_map_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_datasource_relationship", "zdir_datasource_relationship_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_datasource", "zdir_datasource_id");
	
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "zdir_directory_instance", "zdir_directory_instance_id");
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>