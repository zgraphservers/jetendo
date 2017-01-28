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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_post`   
  ADD COLUMN `facebook_post_changed_datetime` DATETIME NOT NULL AFTER `facebook_post_created_datetime`,
  ADD COLUMN `facebook_post_permalink` VARCHAR(255) NOT NULL AFTER `facebook_page_id`,
  ADD COLUMN `facebook_post_type` VARCHAR(50) NOT NULL AFTER `facebook_post_permalink`,
  ADD COLUMN `facebook_post_object_id` VARCHAR(50) NOT NULL AFTER `facebook_page_id`")){
		return false;
	}        
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_page_month`   
  DROP COLUMN `facebook_page_month_followers`")){
		return false;
	}       
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_page`   
  DROP COLUMN `facebook_page_reach`, 
  DROP COLUMN `facebook_page_followers`")){
		return false;
	}      
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `facebook_month`   
  DROP COLUMN `facebook_month_followers`")){
		return false;
	} 


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>