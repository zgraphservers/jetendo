<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
		arr1 = [];
		return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>

		// Create the `job` database table.
		sql_create_job_table = "CREATE TABLE `job` (
				`job_id`  int(11) UNSIGNED NOT NULL ,
				`site_id`  int(11) UNSIGNED NOT NULL ,
				`user_id`  int(11) UNSIGNED NOT NULL ,
				`user_id_siteIDType`  int(11) UNSIGNED NOT NULL ,
				`job_category_id`  int(11) UNSIGNED NOT NULL ,
				`job_title`  varchar(255) NOT NULL ,
				`job_status`  int(11) UNSIGNED NOT NULL ,
				`job_location`  varchar(255) NOT NULL ,
				`job_company_name`  varchar(255) NOT NULL ,
				`job_company_name_hidden`  char(1) NOT NULL DEFAULT '0' ,
				`job_type`  smallint(2) UNSIGNED NOT NULL ,
				`job_posted_date`  datetime NOT NULL ,
				`job_close_date`  datetime NOT NULL ,
				`job_position_title`  varchar(255) NOT NULL ,
				`job_overview`  text NOT NULL ,
				`job_deleted`  int(11) UNSIGNED NOT NULL DEFAULT 0 ,
				`job_updated_datetime`  datetime NOT NULL ,
				PRIMARY KEY (`job_id`, `site_id`),
				INDEX `NewIndex1` (`job_posted_date`) USING BTREE ,
				INDEX `NewIndex2` (`site_id`) USING BTREE ,
				INDEX `NewIndex3` (`site_id`, `job_category_id`, `job_posted_date`, `job_close_date`) USING BTREE 
			)
			ENGINE=InnoDB
			DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci";

		if ( ! arguments.dbUpgradeCom.executeQuery( this.datasource, sql_create_job_table ) ) {
			return false;
		}

		// Create the `job_category` database table.
		sql_create_job_category_table = "CREATE TABLE `job_category` (
				`job_category_id`  int(11) UNSIGNED NOT NULL ,
				`site_id`  int(11) UNSIGNED NOT NULL ,
				`job_category_name`  varchar(255) NOT NULL ,
				`job_category_unique_url`  varchar(255) NOT NULL ,
				`job_category_description`  text NOT NULL ,
				`job_category_sort`  int(11) UNSIGNED NOT NULL ,
				`job_category_deleted`  int(11) UNSIGNED NOT NULL ,
				`job_category_updated_datetime`  datetime NOT NULL ,
				PRIMARY KEY (`job_category_id`, `site_id`),
				INDEX `NewIndex1` (`site_id`, `job_category_name`, `job_category_deleted`) USING BTREE 
			)
			ENGINE=InnoDB
			DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci";

		if ( ! arguments.dbUpgradeCom.executeQuery( this.datasource, sql_create_job_category_table ) ) {
			return false;
		}

		// Create the `job_config` database table.
		sql_create_job_cnofig_table = "CREATE TABLE `job_config` (
				`job_config_id`  int(11) UNSIGNED NOT NULL ,
				`site_id`  int(11) UNSIGNED NOT NULL ,
				`job_config_job_index_url`  varchar(255) NOT NULL ,
				`job_config_this_company`  char(1) NOT NULL DEFAULT '1' ,
				`job_config_comapny_names_hidden`  char(1) NOT NULL DEFAULT '0' ,
				`job_config_deleted`  char(1) NOT NULL DEFAULT '0' ,
				`job_config_updated_datetime`  datetime NOT NULL ,
				PRIMARY KEY (`job_config_id`, `site_id`)
			)
			ENGINE=InnoDB
			DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci";

		if ( ! arguments.dbUpgradeCom.executeQuery( this.datasource, sql_create_job_cnofig_table ) ) {
			return false;
		}

		// Insert the application ID into the `app` table.
		sql_insert_application_id = "INSERT INTO `app` (`app_id`, `app_name`, `app_updated_datetime`) VALUES ('18', 'Job Board', '2016-08-26 00:00:00')";

		if ( ! arguments.dbUpgradeCom.executeQuery( this.datasource, sql_insert_application_id ) ) {
			return false;
		}

		return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
