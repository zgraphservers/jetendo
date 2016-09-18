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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog`   
  DROP COLUMN `blog_event`, 
  DROP COLUMN `blog_end_datetime`")){
		return false;
	}     
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_version`   
  DROP COLUMN `blog_event`, 
  DROP COLUMN `blog_end_datetime`")){
		return false;
	}         
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_category`   
  DROP COLUMN `blog_category_enable_events`")){
		return false;
	}          
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_config`   
  DROP COLUMN `blog_config_enable_event`")){
		return false;
	}        
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>