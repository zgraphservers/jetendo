<cfcomponent interface="zcorerootmapping.interface.cloudVendor" extends="zcorerootmapping.com.cloud.cloudBase">
<cfoutput>
<cffunction name="storeOnline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	throw("not implemented");
	link="";
	return {success:true, cloud_file_url:link};
	</cfscript>
</cffunction>

<cffunction name="purgeFile" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	throw("not implemented");
	// issue real delete command to remote system
	//arguments.ds.cloud_file_url
	//arguments.ds.cloud_file_hash
	return true;
	</cfscript>
</cffunction>

<cffunction name="makeFileAvailableOffline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	throw("not implemented");
	ds=arguments.ds;
	// download online to local path (force replace)
	newPath=ds.config.localPath&removeChars(fileData.cloud_file_local_path,1,1); 
	// allow 10 seconds per megabyte to download file
	seconds=round(10*(fileData.cloud_file_size/1024/1024));
	application.zcore.functions.zSetRequestTimeout(seconds+5); 

	application.zcore.functions.zHTTPToFile(fileData.cloud_file_url, newPath, seconds);
	if(not fileexists(newPath)){
		throw("Failed to download file: #fileData.cloud_file_url# for path: #arguments.path#");
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>