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

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `contact` 
  CHANGE `contact_phone` `contact_phone1` VARCHAR(30) CHARSET utf8 COLLATE utf8_general_ci NOT NULL, 
 ADD COLUMN   `office_id` int(11) unsigned NOT NULL  AFTER `contact_deleted`,
 ADD COLUMN   `contact_company` varchar(100) NOT NULL  AFTER `office_id`,
 ADD COLUMN   `contact_salutation` varchar(50) NOT NULL  AFTER `contact_company`,
 ADD COLUMN   `contact_suffix` varchar(50) NOT NULL  AFTER `contact_salutation`,
 ADD COLUMN   `contact_job_title` varchar(100) NOT NULL  AFTER `contact_suffix`,
 ADD COLUMN   `contact_birthday` datetime NOT NULL  AFTER `contact_job_title`, 
 ADD COLUMN   `contact_phone2` varchar(20) NOT NULL  AFTER `contact_birthday`,
 ADD COLUMN   `contact_phone3` varchar(20) NOT NULL  AFTER `contact_phone2`,
 ADD COLUMN   `contact_phone1_formatted` varchar(20) NOT NULL  AFTER `contact_phone3`,
 ADD COLUMN   `contact_phone2_formatted` varchar(20) NOT NULL  AFTER `contact_phone1_formatted`,
 ADD COLUMN   `contact_phone3_formatted` varchar(20) NOT NULL  AFTER `contact_phone2_formatted`,
 ADD COLUMN   `contact_spouse_first_name` varchar(50) NOT NULL  AFTER `contact_phone3_formatted`,
 ADD COLUMN   `contact_spouse_suffix` varchar(50) NOT NULL  AFTER `contact_spouse_first_name`,
 ADD COLUMN   `contact_spouse_job_title` varchar(100) NOT NULL  AFTER `contact_spouse_suffix`,
 ADD COLUMN   `contact_address` varchar(255) NOT NULL  AFTER `contact_spouse_job_title`,
 ADD COLUMN   `contact_city` varchar(100) NOT NULL  AFTER `contact_address`,
 ADD COLUMN   `contact_state` varchar(2) NOT NULL  AFTER `contact_city`,
 ADD COLUMN   `contact_country` varchar(2) NOT NULL  AFTER `contact_state`,
 ADD COLUMN   `contact_postal_code` varchar(10) NOT NULL  AFTER `contact_country`,
 ADD COLUMN   `contact_interests` varchar(100) NOT NULL  AFTER `contact_postal_code`,
 ADD COLUMN   `contact_interested_in_type` varchar(100) NOT NULL  AFTER `contact_interests`,
 ADD COLUMN   `contact_interested_in_year` varchar(50) NOT NULL  AFTER `contact_interested_in_type`,
 ADD COLUMN   `contact_interested_in_make` varchar(100) NOT NULL  AFTER `contact_interested_in_year`,
 ADD COLUMN   `contact_interested_in_model` varchar(100) NOT NULL  AFTER `contact_interested_in_make`,
 ADD COLUMN   `contact_interested_in_category` varchar(100) NOT NULL  AFTER `contact_interested_in_model`,
 ADD COLUMN   `contact_interested_in_name` varchar(100) NOT NULL  AFTER `contact_interested_in_category`,
 ADD COLUMN   `contact_interested_in_hin_vin` varchar(100) NOT NULL  AFTER `contact_interested_in_name`,
 ADD COLUMN   `contact_interested_in_stock` varchar(100) NOT NULL  AFTER `contact_interested_in_hin_vin`,
 ADD COLUMN   `contact_interested_in_length` varchar(100) NOT NULL  AFTER `contact_interested_in_stock`,
 ADD COLUMN   `contact_interested_in_currently_owned_type` varchar(100) NOT NULL  AFTER `contact_interested_in_length`,
 ADD COLUMN   `contact_interested_in_read` varchar(100) NOT NULL  AFTER `contact_interested_in_currently_owned_type`,
 ADD COLUMN   `contact_interested_in_age` varchar(100) NOT NULL  AFTER `contact_interested_in_read`,
 ADD COLUMN   `contact_interested_in_bounce_reason` varchar(100) NOT NULL  AFTER `contact_interested_in_age`,
 ADD COLUMN   `contact_interested_in_home_phone` varchar(20) NOT NULL  AFTER `contact_interested_in_bounce_reason`,
 ADD COLUMN   `contact_interested_in_work_phone` varchar(20) NOT NULL  AFTER `contact_interested_in_home_phone`,
 ADD COLUMN   `contact_interested_in_mobile_phone` varchar(20) NOT NULL  AFTER `contact_interested_in_work_phone`,
 ADD COLUMN   `contact_interested_in_fax` varchar(20) NOT NULL  AFTER `contact_interested_in_mobile_phone`,
 ADD COLUMN   `contact_interested_in_buying_horizon` varchar(100) NOT NULL  AFTER `contact_interested_in_fax`,
 ADD COLUMN   `contact_interested_in_status` varchar(50) NOT NULL  AFTER `contact_interested_in_buying_horizon`,
 ADD COLUMN   `contact_interested_in_interest_level` varchar(100) NOT NULL  AFTER `contact_interested_in_status`,
 ADD COLUMN   `contact_interested_in_sales_stage` varchar(100) NOT NULL  AFTER `contact_interested_in_interest_level`,
 ADD COLUMN   `contact_interested_in_contact_source` varchar(100) NOT NULL  AFTER `contact_interested_in_sales_stage`,
 ADD COLUMN   `contact_interested_in_dealership` varchar(100) NOT NULL  AFTER `contact_interested_in_contact_source`,
 ADD COLUMN   `contact_interested_in_assigned_to` varchar(100) NOT NULL  AFTER `contact_interested_in_dealership`,
 ADD COLUMN   `contact_interested_in_bounced_email` char(1) NOT NULL DEFAULT '0'  AFTER `contact_interested_in_assigned_to`,
 ADD COLUMN   `contact_interested_in_owners_magazine` char(1) NOT NULL DEFAULT '0'  AFTER `contact_interested_in_bounced_email`,
 ADD COLUMN   `contact_interested_in_purchased` char(1) NOT NULL DEFAULT '0'  AFTER `contact_interested_in_owners_magazine`,
 ADD COLUMN   `contact_interested_in_service_date` datetime NOT NULL  AFTER `contact_interested_in_purchased`,
 ADD COLUMN   `contact_interested_in_date_delivered` datetime NOT NULL  AFTER `contact_interested_in_service_date`,
 ADD COLUMN   `contact_interested_in_date_sold` datetime NOT NULL  AFTER `contact_interested_in_date_delivered`,
 ADD COLUMN   `contact_interested_in_warranty_date` datetime NOT NULL  AFTER `contact_interested_in_date_sold`,
 ADD COLUMN   `contact_interested_in_lead_comments` text NOT NULL  AFTER `contact_interested_in_warranty_date`, 
 ADD COLUMN   `contact_des_key` varchar(15) NOT NULL  AFTER `contact_interested_in_lead_comments`")){		return false;	}
	
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>