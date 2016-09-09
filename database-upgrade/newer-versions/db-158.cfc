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

	sql = "
ALTER TABLE `job`
CHANGE COLUMN `job_posted_date` `job_posted_datetime`  datetime NOT NULL AFTER `job_type`,
CHANGE COLUMN `job_close_date` `job_closed_datetime`  datetime NOT NULL AFTER `job_posted_datetime`,
MODIFY COLUMN `job_category_id`  varchar(255) NOT NULL AFTER `user_id_siteIDType`,
MODIFY COLUMN `job_overview`  longtext CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL AFTER `job_position_title`,
ADD COLUMN `job_unique_url`  varchar(255) NOT NULL AFTER `job_title`,
ADD COLUMN `job_address`  varchar(255) NOT NULL AFTER `job_location`,
ADD COLUMN `job_address2`  varchar(255) NOT NULL AFTER `job_address`,
ADD COLUMN `job_city`  varchar(255) NOT NULL AFTER `job_address2`,
ADD COLUMN `job_state`  char(2) NOT NULL AFTER `job_city`,
ADD COLUMN `job_country`  char(2) NOT NULL AFTER `job_state`,
ADD COLUMN `job_zip`  varchar(10) NOT NULL AFTER `job_country`,
ADD COLUMN `job_map_coordinates`  varchar(255) NOT NULL AFTER `job_zip`,
ADD COLUMN `job_phone`  varchar(20) NOT NULL AFTER `job_company_name_hidden`,
ADD COLUMN `job_website`  varchar(255) NOT NULL AFTER `job_phone`,
ADD COLUMN `job_featured`  char(1) NOT NULL AFTER `job_website`,
ADD COLUMN `job_suggested_by_name`  varchar(100) NOT NULL AFTER `job_overview`,
ADD COLUMN `job_suggested_by_email`  varchar(100) NOT NULL AFTER `job_suggested_by_name`,
ADD COLUMN `job_suggested_by_phone`  varchar(100) NOT NULL AFTER `job_suggested_by_email`,
ADD COLUMN `job_image_library_id`  int(11) NOT NULL AFTER `job_updated_datetime`,
ADD COLUMN `job_image_library_layout`  smallint(2) NOT NULL AFTER `job_image_library_id`
";

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, sql)){
		return false;
	}    

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>