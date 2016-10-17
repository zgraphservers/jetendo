<cfcomponent interface="zcorerootmapping.interface.cloudVendor">
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
	</cfscript>
</cffunction>

<cffunction name="getDownloadLink" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	return replace(arguments.ds.cloud_file_url, "https://", "/zcf_internal/");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>