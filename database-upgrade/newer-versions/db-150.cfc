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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO `mls` (`mls_id`, `mls_name`, `mls_disclaimer_name`, `mls_mls_id`, `mls_offset`, `mls_status`, `mls_update_date`, `mls_download_date`, `mls_frequency`, `mls_com`, `mls_delimiter`, `mls_csvquote`, `mls_first_line_columns`, `mls_file`, `mls_current_file_path`, `mls_primary_city_id`, `mls_login_url`, `mls_cleaned_date`, `mls_provider`, `mls_filelist`, `mls_updated_datetime`) VALUES ('28', 'NSB-RETS', 'New Smyrna Beach Board of REALTORS', 'nsbrets', '0', '1', '2016-07-01 12:10:49', '', 'hourly', 'rets28', ""\t"", '', '1', '', '', '573', 'http://www.newsmyrnabeachrealtors.com/', '2016-07-01', 'rets28', 'listings-resrental.txt,listings-residential.txt,listings-land.txt,listings-comrental.txt,listings-commercial.txt', '2016-07-01 12:12:06')")){
		return false;
	}   
	
	 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>