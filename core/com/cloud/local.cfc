<cfcomponent interface="zcorerootmapping.interface.cloudVendor" extends="zcorerootmapping.com.cloud.cloudBase">
<cfoutput>
<cffunction name="storeOnline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	ds=arguments.ds;
	destinationPath=ds.config.remotePath;
	application.zcore.functions.zCreateDirectory(destinationPath); 

	destinationFilePath=destinationPath&ds.cloud_file_remote_path;
	newPath=application.zcore.functions.zCopyFile(ds.config.localPath&removeChars(ds.cloud_file_local_path, 1, 1), destinationFilePath); 
	if(newPath EQ false){
		return {success:false, errorMessage: Request.zCopyFileError};
	}
	return {success:true, cloud_file_url:ds.config.remoteURL&replace(destinationFilePath, ds.config.remotePath, "")};
	</cfscript>
</cffunction>


<cffunction name="purgeFile" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// issue real delete command to remote system
	newPath=ds.config.remotePath&ds.cloud_file_remote_path;
	//echo('Record deleted for: #ds.cloud_file_local_path# path: #newPath#<br>');
	application.zcore.functions.zdeletefile(newPath); 
	return true;
	</cfscript>
</cffunction>

<cffunction name="makeFileAvailableOffline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// download online to local path (force replace)
	newPath=ds.config.localPath&removeChars(ds.cloud_file_local_path,1,1); 
	source=replace(ds.cloud_file_url, ds.config.remoteURL, ds.config.remotePath); 
	result=application.zcore.functions.zCopyFile(source, newPath, true); 
	if(not fileexists(newPath)){
		return {success:false, errorMessage:"Failed to copy file, #source#, to #newPath#"};
	}
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="getDownloadLink" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	link=replace(ds.cloud_file_url, ds.config.remoteURL, ds.config.remoteRelativeURL);
	return link;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>