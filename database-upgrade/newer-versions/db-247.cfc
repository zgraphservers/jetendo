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
  ADD COLUMN `facebook_post_video_play` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_type`,
  ADD COLUMN `facebook_post_photo_view` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_video_play`,
  ADD COLUMN `facebook_post_link_click` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_photo_view`,
  ADD COLUMN `facebook_post_other_click` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_link_click`,
  ADD COLUMN `facebook_post_stories` INT(11) UNSIGNED NOT NULL AFTER `facebook_post_other_click`")){
		return false;
	}         


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>