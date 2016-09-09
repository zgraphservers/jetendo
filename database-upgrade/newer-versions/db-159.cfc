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
ALTER TABLE `job_config`
ADD COLUMN `job_config_job_url_id`  int(11) NOT NULL AFTER `site_id`,
ADD COLUMN `job_config_category_url_id`  int(11) NOT NULL AFTER `job_config_job_url_id`
";

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, sql)){
		return false;
	}    

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>