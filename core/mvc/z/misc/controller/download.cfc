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
	form.virtual_file_path=right(form.virtual_file_path, len(form.virtual_file_path)-len('/zupload/user/'));
	fileCom=createObject("component", "zcorerootmapping.mvc.z.admin.controller.files");
	fileCom.serveFileByPath(form.virtual_file_path);
	</cfscript>
</cffunction> 

<!--- 
Previous version if we need to revert files.cfc
<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	form.fp=application.zcore.functions.zso(form, 'fp');
	if(not isSimpleValue(form.fp)){
		application.zcore.functions.z404("Invalid request");
	}
	if(left(form.fp, 15) EQ "/zuploadsecure/" and not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.user.requireLogin("administrator");
	} 
	downloadFile(form.fp); 
	</cfscript> 
</cffunction>

<cffunction name="downloadFile" localmode="modern" access="public" output="yes">
	<cfargument name="rootRelativeURL" type="string" required="yes">
	<cfscript>
	var filepath=0;
	var fp=arguments.rootRelativeURL;
	var fp_backup=fp;
	var ext=application.zcore.functions.zGetFileExt(fp);
	ext=replacelist(ext,"cfm,php,cfc,ini,xml,htm,html,asp,aspx,cgi,pl,htaccess,httpd","");
	fp=replacenocase(fp,"../","","ALL");
	fp=replacenocase(fp,"..\","","ALL");
	fp=replacenocase(fp,":","","ALL"); 
	if(fp EQ "" or ext EQ "" or fp NEQ fp_backup or (left(fp, 9) NEQ "/zupload/" and left(fp, 15) NEQ "/zuploadsecure/")){
		application.zcore.functions.z404("File location was insecure");
	}



	filepath=application.zcore.functions.zvar('privatehomedir')&removechars(fp,1,1);
	if(fileexists(filepath)){
		header name="Content-Disposition" value="attachment; filename=#getfilefrompath(fp)#" charset="utf-8";
		content type="application/binary" deletefile="no" file="#filepath#";
		abort;
	}else{
		application.zcore.functions.z404("File doesn't exist");
	}
	</cfscript>
</cffunction> --->
</cfoutput>
</cfcomponent>