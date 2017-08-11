<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfscript>	
	var db=request.zos.queryObject;
	setting requesttimeout="100000";
	if(not request.zos.istestserver){
		echo('You can only run this command on the test environment.');
		abort;
	}
	form.sid=application.zcore.functions.zso(form, 'sid');
	form.selectedWritable=application.zcore.functions.zso(form, 'selectedWritable');
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(form.sid)# and 
	site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# ";
	request.qSite=db.execute("qSite");
	if(request.qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid site selected", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	request.site_homedir=application.zcore.functions.zGetDomainInstallPath(request.qSite.site_sitename);
	request.site_privatehomedir=application.zcore.functions.zGetDomainWritableInstallPath(request.qSite.site_sitename);

	db.sql="select * from #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# site_x_deploy_server,
	#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server 
	WHERE deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
	site_x_deploy_server.site_id = #db.param(form.sid)# and 
	site_x_deploy_server_deleted = #db.param(0)# and 
	deploy_server_deleted = #db.param(0)# "; 
	var qDeploy=db.execute("qDeploy");
	if(qDeploy.recordcount EQ 0){
		throw("No deploy servers has been configured for this site: #request.qSite.site_domain#");
	}
	//form.gitCloneLink=application.zcore.functions.zso(form, 'gitCloneLink');
	form.gitCloneLink=request.qSite.site_primary_git_repository;
	deployCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.deploy");
	for(row in qDeploy){
		rs=deployCom.getSiteJson(row);
		if(not rs.success){
			throw(rs.errorMessage);
		}
		request.remotePath=rs.dataStruct.installPath;
		request.remoteWritablePath=rs.dataStruct.installPath;
		form.gitCloneLink=application.zcore.functions.zso(rs.dataStruct, 'primaryGitRepository');
		writedump("request.remotePath:"&request.remotePath);
		writedump("request.remoteWritablePath:"&request.remoteWritablePath);
		writedump("form.gitCloneLink:"&form.gitCloneLink);
	}
	bitbucketUserName=application.zcore.functions.zso(request.zos, 'bitbucketUsername');
	bitbucketPassword=application.zcore.functions.zso(request.zos, 'bitbucketPassword');
	if(bitbucketUserName EQ "" or bitbucketPassword EQ ""){
		throw("request.zos.bitbucketUsername and request.zos.bitbucketPassword must be defined in zcorerootmapping.config.cfc");
	}
	</cfscript>
</cffunction>


<cffunction name="cancelled" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Full Sync Operation Cancelled</h2>

</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	</cfscript>
	<h2>Full Sync</h2>
	<h3>Please Confirm Full Sync Operation</h3>
	<h3>Selected Site: #request.qSite.site_sitename# (#request.qSite.site_domain#)</h3> 
	<h2><span style="color:##900;">WARNING:</span> PERMANENT DESTRUCTION of the following information will occur if you click YES.</h2>
	<ul>
		<li>Entire database for this test site will be deleted</li>
		<li>Entire git repository will be deleted</li>
		<li>Entire local set of files for this test site will be deleted</li>
	</ul>
	<!--- TODO: show list of zupload and zuploadsecure directories to optionally rsync --->

	<h2><a href="/z/server-manager/admin/sync-download/processFullSync?sid=#form.sid#&amp;gitCloneLink=#urlencodedformat(form.gitCloneLink)#" onclick="if(window.confirm('Are you sure you want to permanently delete this test site and clone it from the live version?')){ return true; }else{return false;}">Yes, permanently delete</a>&nbsp;&nbsp;&nbsp;<a href="/z/server-manager/admin/sync-download/cancelled?sid=#form.sid#">No</a></h2>


</cffunction>


<cffunction name="formatBitbucketCloneURL" localmode="modern" access="public">
	<cfargument name="link" type="string" required="yes">
	<cfargument name="username" type="string" required="yes">
	<cfargument name="password" type="string" required="yes">
	<cfscript>
	link=arguments.link;
	if(link CONTAINS "git@bitbucket.org:"){
		// convert to https
		return "https://#urlencodedformat(arguments.username)#:#urlencodedformat(arguments.password)#@bitbucket.org/"&listGetAt(link, 2, ":");
	}else{
		arrLink=listToArray(removeChars(link, 1, 8), "/", true);
		arrayDeleteAt(arrLink, 1);
		link="https://#urlencodedformat(arguments.username)#:#urlencodedformat(arguments.password)#@bitbucket.org/"&arrayToList(arrLink, "/");
	}
	</cfscript>
</cffunction>

<cffunction name="processFullSync" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>	
	init();

	throw("not fully implemented");
	// secure and validate the paths
	arrPath=listToArray(form.selectedWritable, ",");
	arrPathFinal=[];
	for(path in arrPath){
		path=replace(path, "/zupload/", "~-~zupload~", "all");
		path=replace(path, "/zuploadsecure/", "~-~zuploadsecure~", "all");
		path=replace(path, "/", "", "all");
		path=replace(path, "\", "", "all");
		path=replace(path, chr(10), "", "all");
		path=replace(path, chr(13), "", "all");
		path=replace(path, chr(9), "", "all");
		path=replace(path, "~-~zupload~", "/zupload/", "all");
		path=replace(path, "~-~zuploadsecure~", "/zuploadsecure/", "all");
		path=trim(path);
		if(path != ""){
			arrayAppend(arrPathFinal, path);
		}
	}
	finalPaths=arrayToList(arrPathFinal, chr(10));

	// make the site api request return the official git repo from site_primary_git_repository automatically.

	// get site by id

	// get sitePath

	// TODO make the backup script able to pull only database, not site files.


	// force database to be cloned
	// run the same function as import site, but make it able to return json status instead of redirect.
	rs={success:true};

	if(not rs.success){
		// show error.
	}
	// wipe the entire local directory so that we can clone git from scratch
	application.zcore.functions.zDeleteDirectory(request.site_homedir);

	// make zSecureCommand gitClone, pass the encoded git url to it
	formattedGitCloneLink=formatBitbucketCloneURL(form.gitCloneLink, request.zos.bitbucketUsername, request.zos.bitbucketPassword);

	result=application.zcore.functions.zSecureCommand("gitClone"&chr(9)&formattedGitCloneLink&chr(9)&request.site_homedir, 1000);
	if(result EQ "0"){
		application.zcore.status.setStatus(request.zsid, "Git Clone failed because site homedir is not empty.  Make sure the files are not locked.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/sync-download/cancelled?zsid=#request.zsid#");
	}

	/* 
	// have option for rsyncing the uploads (specific directories, like site-options, email_attachments, user, etc to save time...)
	//rsync the uploads directory down ONLY   #request.site_privatehomedir#
	
	if(form.selectedWritable NEQ ""){
		application.zcore.functions.zWriteFile(request.site_privatehomedir&"__deploy-full-sync.txt", finalPaths);
	}
	 


	// force some helpful fixes
	// delete zofficeemail
	// delete lead routing
	// delete visitor tracking code
	// more...
	*/
	//$cmd='rsync -rtLvz --exclude=\'.git\' --exclude=\'.DS_Store\' --exclude=\'*/.git\' --exclude=\'.git*\' --exclude=\'*/.git*\' --exclude=\'WEB-INF\' --exclude=\'_notes\' --exclude=\'*/_notes\' --delay-updates --delete -e "'.$sshCommand.'" '.$remoteUsername.'@'.$remoteHost.':'.$remotePath.$appendString.' '.$siteInstallPath; 
	</cfscript>
</cffunction>
</cfoutput>	
</cfcomponent>