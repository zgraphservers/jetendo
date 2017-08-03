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
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `customer` (
  `customer_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `office_id` int(11) unsigned NOT NULL,
  `customer_company` varchar(100) NOT NULL,
  `customer_salutation` varchar(50) NOT NULL,
  `customer_first_name` varchar(50) NOT NULL,
  `customer_last_name` varchar(50) NOT NULL,
  `customer_suffix` varchar(50) NOT NULL,
  `customer_job_title` varchar(100) NOT NULL,
  `customer_birthday` datetime NOT NULL,
  `customer_email` varchar(100) NOT NULL,
  `customer_phone1` varchar(20) NOT NULL,
  `customer_phone2` varchar(20) NOT NULL,
  `customer_phone3` varchar(20) NOT NULL,
  `customer_phone1_formatted` varchar(20) NOT NULL,
  `customer_phone2_formatted` varchar(20) NOT NULL,
  `customer_phone3_formatted` varchar(20) NOT NULL,
  `customer_spouse_first_name` varchar(50) NOT NULL,
  `customer_spouse_suffix` varchar(50) NOT NULL,
  `customer_spouse_job_title` varchar(100) NOT NULL,
  `customer_address` varchar(255) NOT NULL,
  `customer_city` varchar(100) NOT NULL,
  `customer_state` varchar(2) NOT NULL,
  `customer_country` varchar(2) NOT NULL,
  `customer_postal_code` varchar(10) NOT NULL,
  `customer_created_datetime` datetime NOT NULL,
  `customer_interests` varchar(100) NOT NULL,
  `customer_interested_in_type` varchar(100) NOT NULL,
  `customer_interested_in_year` varchar(50) NOT NULL,
  `customer_interested_in_make` varchar(100) NOT NULL,
  `customer_interested_in_model` varchar(100) NOT NULL,
  `customer_interested_in_category` varchar(100) NOT NULL,
  `customer_interested_in_name` varchar(100) NOT NULL,
  `customer_interested_in_hin_vin` varchar(100) NOT NULL,
  `customer_interested_in_stock` varchar(100) NOT NULL,
  `customer_interested_in_length` varchar(100) NOT NULL,
  `customer_interested_in_currently_owned_type` varchar(100) NOT NULL,
  `customer_interested_in_read` varchar(100) NOT NULL,
  `customer_interested_in_age` varchar(100) NOT NULL,
  `customer_interested_in_bounce_reason` varchar(100) NOT NULL,
  `customer_interested_in_home_phone` varchar(20) NOT NULL,
  `customer_interested_in_work_phone` varchar(20) NOT NULL,
  `customer_interested_in_mobile_phone` varchar(20) NOT NULL,
  `customer_interested_in_fax` varchar(20) NOT NULL,
  `customer_interested_in_buying_horizon` varchar(100) NOT NULL,
  `customer_interested_in_status` varchar(50) NOT NULL,
  `customer_interested_in_interest_level` varchar(100) NOT NULL,
  `customer_interested_in_sales_stage` varchar(100) NOT NULL,
  `customer_interested_in_customer_source` varchar(100) NOT NULL,
  `customer_interested_in_dealership` varchar(100) NOT NULL,
  `customer_interested_in_assigned_to` varchar(100) NOT NULL,
  `customer_interested_in_bounced_email` char(1) NOT NULL DEFAULT '0',
  `customer_interested_in_owners_magazine` char(1) NOT NULL DEFAULT '0',
  `customer_interested_in_purchased` char(1) NOT NULL DEFAULT '0',
  `customer_interested_in_service_date` datetime NOT NULL,
  `customer_interested_in_date_delivered` datetime NOT NULL,
  `customer_interested_in_date_sold` datetime NOT NULL,
  `customer_interested_in_warranty_date` datetime NOT NULL,
  `customer_interested_in_lead_comments` text NOT NULL,
  `customer_updated_datetime` datetime NOT NULL,
  `customer_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`customer_id`),
  KEY `NewIndex1` (`site_id`),
  KEY `NewIndex2` (`site_id`,`customer_email`),
  KEY `NewIndex3` (`site_id`,`customer_email`,`customer_phone1_formatted`,`customer_phone2_formatted`,`customer_phone3_formatted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	 
     application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "customer", "customer_id");

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>