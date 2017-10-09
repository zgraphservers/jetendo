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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
  ADD COLUMN `site_report_sent_datetime` DATETIME NOT NULL AFTER `site_share_with_friend_thank_you_url`,
  ADD COLUMN `site_report_auto_send_enable` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_report_sent_datetime`,
  ADD COLUMN `site_report_auto_send_email_list` TEXT NOT NULL AFTER `site_report_auto_send_enable`")){		return false;	}
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `company`   
  ADD COLUMN `company_report_email_list` TEXT NOT NULL AFTER `company_updated_datetime`,
  ADD COLUMN `company_report_autosend_current_date` DATE NOT NULL AFTER `company_report_email_list`,
  ADD COLUMN `company_report_from_email` TEXT NOT NULL AFTER `company_report_autosend_current_date`")){		return false;	}
 

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>