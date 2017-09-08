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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE `jetendo`.`mls` SET `mls_filelist` = 'listings-commercial.txt,listings-land.txt,listings-multifamily.txt,listings-rental.txt,listings-residential.txt' WHERE `mls_id` = '29'")){		return false;	}
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>