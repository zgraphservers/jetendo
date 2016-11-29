<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	// for legacy path based urls only
	rootRelativeURL=application.zcore.functions.zso(form, 'fp');
	if(left(rootRelativeURL, len('/zupload/user/')) EQ '/zupload/user/'){
		rootRelativeURL=removeChars(rootRelativeURL, 1, len('/zupload/user/'));
	}
	if(left(rootRelativeURL, len('/zuploadsecure/user/')) EQ '/zuploadsecure/user/'){
		rootRelativeURL=removeChars(rootRelativeURL, 1, len('/zuploadsecure/user/'));
	} 
	fileCom=createObject("component", "zcorerootmapping.mvc.z.admin.controller.files");
	fileCom.downloadFileByPath(rootRelativeURL);
	</cfscript>
</cffunction> 

<cffunction name="viewFile" localmode="modern" access="remote">
	<!--- <cfargument name="rootRelativeURL" type="string" required="yes"> --->
	<cfscript>
	form.virtual_file_path=application.zcore.functions.zso(form, 'virtual_file_path'); 
	if(form.virtual_file_path EQ ""){
		application.zcore.functions.z404("Invalid request");
	}
	if(len(form.virtual_file_path) LTE len('/zupload/user/')){
		application.zcore.functions.z404("Invalid path");
	}
	form.virtual_file_path=right(form.virtual_file_path, len(form.virtual_file_path)-len('/zupload/user/'));
	fileCom=createObject("component", "zcorerootmapping.mvc.z.admin.controller.files");
	fileCom.serveFileByPath(form.virtual_file_path);
	</cfscript>
</cffunction> 

<cffunction name="downloadFile" localmode="modern" access="public">
	<cfargument name="rootRelativeURL" type="string" required="yes">
	<cfscript>
	// for legacy path based urls only
	rootRelativeURL=arguments.rootRelativeURL;
	if(left(rootRelativeURL, len('/zupload/user/')) EQ '/zupload/user/'){
		rootRelativeURL=removeChars(rootRelativeURL, 1, len('/zupload/user/'));
	}
	if(left(rootRelativeURL, len('/zuploadsecure/user/')) EQ '/zuploadsecure/user/'){
		rootRelativeURL=removeChars(rootRelativeURL, 1, len('/zuploadsecure/user/'));
	} 
	fileCom=createObject("component", "zcorerootmapping.mvc.z.admin.controller.files");
	fileCom.downloadFileByPath(rootRelativeURL);
	</cfscript>
</cffunction> 

<cffunction name="serveFileById" localmode="modern" access="remote">
	<cfscript>  
	request.zos.siteVirtualFileCom.serveVirtualFile();
	</cfscript>
</cffunction>

<cffunction name="downloadFileById" localmode="modern" access="remote">
	<cfscript>  
	request.zos.siteVirtualFileCom.downloadVirtualFile();
	</cfscript>
</cffunction> 
</cfoutput>
</cfcomponent>