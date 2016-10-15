<cfcomponent>

<!--- 
for recovering deleted files:
/z/_com/zos/cloudFile?method=listDeletedFiles

// setup cfml task job once per day:
/z/_com/zos/cloudFile?method=purgeOldFiles


make new rewrite that direct downloads from files that are publicly available.
/zcf/path/to/file 
cloud_vendor
	cloud_vendor_id
	cloud_vendor_name (local / rackspace cloud files)
	 
cloud_file
	cloud_file_id
	cloud_file_is_local char(1) 0
	cloud_file_is_online char(1) 0

	// prevent direct download - only scripted downloads allowed
	cloud_file_is_secure char(1) 0

	// might want this to track which server the file was stored on.   Each developer machine and server must have a unique id to do this.  Perhaps in a new file.  We could force developer machines to store locally only, to simplify and then we only need a test/live check
	cloud_file_server_id


	cloud_file_name varchar(255)
	cloud_file_local_path varchar(255)
	cloud_file_url varchar(255)
	cloud_file_hash varchar(64)
	cloud_file_remote_path varchar(255)
	cloud_file_size int
	cloud_file_created_datetime
	cloud_file_deleted_datetime
	cloud_file_last_modified_datetime
	cloud_file_updated_datetime
	cloud_file_deleted
	cloud_file_width
	cloud_file_height

	// rackspace , microsoft and google have object "name", which is url encoded if you want slashes, etc



	// allows bulk downloading only certain containers for site backup/import
	cloud_file_container_local_name (i.e. user files, site options, events, etc)
	cloud_vendor_id
	site_id
	
	index on site_id
	unique index on site_id + cloud_file_path + cloud_file_deleted
	primary index on site_id + cloud_file_id

user_dir
	user_dir_id
	user_dir_name
	user_dir_hash varchar 64 sha256
	user_dir_cloud_url
	user_dir_updated_datetime
	user_dir_deleted
	site_id
user_file
	user_file_id
	user_file_name
	user_file_hash varchar 64 sha256
	user_file_cloud_url
	user_file_updated_datetime
	user_file_deleted
	site_id

// make a function that migrates files from one vendor to another automatically.

// site backup/import will be much slower / inaccurate / dangerous if all the files are stored in cloud.
	// site backup has to exclude cloud_file table OR clone it fully to local copy first.
	// add feature to download cloud file backup.
	// must guarantee all files are unique for local site and not connected to cloud


// these need vendor specific implementations
	storeOnline
	purgeFile

cloudFileCom=createObject("component", "zcorerootmapping.com.zos.cloudFile");
cloudFileCom.isOnline(path);
cloudFileCom.isLocal(path);
cloudFileCom.getFileByPath(path);
cloudFileCom.getFileById(path);
cloudFileCom.getTemporaryFile(path);
cloudFileCom.setOnlineOnly(path, true);
cloudFileCom.deleteFile(path);
cloudFileCom.fileExists(path);
cloudFileCom.purgeFile(path);
cloudFileCom.downloadFile(path);
ts={
	// remoteFilePath:"/path/to/file",
	localFilePath:"/path/to/file",
	onlineOnly:false,
	secure:false,
	async:false
}
rs=cloudFileCom.putFile(ts);
if(not rs.success){
	throw(rs.errorMessage);
}
--->
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("Access denied");
	}
	echo('<h2>Testing Cloud File</h2>');

	path=request.zos.globals.homedir&"testFile.txt";

	cloudFileCom=this;
	/*
	cloudFileCom.isOnline(path);
	cloudFileCom.isLocal(path);
	cloudFileCom.getFileByPath(path);
	cloudFileCom.getFileById(path);
	cloudFileCom.getTemporaryFile(path);
	cloudFileCom.setOnlineOnly(path, true);
	cloudFileCom.deleteFile(path);
	cloudFileCom.fileExists(path);
	cloudFileCom.purgeFile(path);
	cloudFileCom.downloadFile(path);
	*/
	</cfscript>
</cffunction>

<cffunction name="putFile" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		onlineOnly:false,
		secure:false,
		async:false
	}
	ss=arguments.ss;
	structappend(ss, ts);
	
	// delete existing file if any exist for this path - guarantees cloud file record is immutable
	deleteFile(ss.localFilePath);
	
	fileInfo=getFileInfo(ss.localFilePath);


	// in order to recover previous versions of files, cloud_file MUST delete existing files inside putFile

	t9={
		table:"cloud_file",
		datasource:request.zos.zcoreDatasource,
		struct:{
			cloud_file_name:getFileFromPath(ss.localFilePath),
			cloud_file_path:ss.localFilePath,
			cloud_file_server_id:1,
			cloud_vendor_id:1, // TODO: set vendor per site or globally somehow with a variable somewhere else.  for now, 1 is local, 2 is rackspace and the driver for put/get/delete will be created as separate objects per vendor to separate vendor from application
			cloud_file_created_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
			cloud_file_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
			cloud_file_deleted:0,
			cloud_file_is_local:1,
			cloud_file_hash:hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256'),
			cloud_file_is_online:0,
			cloud_file_is_secure:0,
			cloud_file_size:fileInfo.size,
			cloud_file_width:0,
			cloud_file_height:0,
			cloud_file_last_modified_datetime:dateformat(fileInfo.lastModified, "yyyy-mm-dd")&" "&timeformat(fileInfo.lastModified, "HH:mm:ss"),
			site_id:request.zos.globals.id
		}
	}
	ext=application.zcore.functions.zGetFileExt(ss.localFilePath);
	if(ext EQ "png" or ext EQ "gif" or ext EQ "jpg" or ext EQ "jpeg"){
		// get width/height
		imageInfoStruct=application.zcore.functions.zGetImageSize(ss.localFilePath);
		if(imageInfoStruct.success){
			t9.struct.cloud_file_width=imageInfoStruct.width;
			t9.struct.cloud_file_height=imageInfoStruct.height;
		}
	}
	if(ss.secure){
		t9.struct.cloud_file_is_secure=1;
	}
	if(ss.async){
		cloud_file_id=application.zcore.functions.zInsert(t9);
		if(cloud_file_id EQ false){
			return {success:false, errorMessage:"Failed to insert file"};
		}
		t9.struct.cloud_file_id=cloud_file_id;
	}else{
		rs=storeOnline(t9.struct);
		if(rs.success){
			t9.struct.cloud_file_is_online=1;
			t9.struct.cloud_file_url=rs.cloud_file_url;
			cloud_file_id=application.zcore.functions.zInsert(t9);
			if(cloud_file_id EQ false){
				return {success:false, errorMessage:"Failed to insert file"};
			}
			t9.struct.cloud_file_id=cloud_file_id;
			if(ss.onlineOnly){
				application.zcore.functions.zDeleteFile(ss.localFilePath);
				t9.struct.cloud_file_is_local=0; 
				cloud_file_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				application.zcore.functions.zUpdate(t9);
			}
		}
	}
	return {success:true, data:t9.struct};
	</cfscript>
</cffunction>

<cffunction name="isOnline" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		throw("File doesn't exist: #arguments.path#");
	}
	if(rs.data.cloud_file_is_online EQ 1){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="isLocal" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		throw("File doesn't exist: #arguments.path#");
	}
	if(rs.data.cloud_file_is_local EQ 1){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="setOnlineOnly" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="onlineOnly" type="boolean" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		return rs;
	}
	if(arguments.onlineOnly){
		if(rs.data.cloud_file_is_online EQ 1){
			return {success:true};
		}else{
			rs=storeOnline(rs.data);
			if(not rs.success){
				return rs;
			}
			application.zcore.functions.zDeleteFile(rs.data.cloud_file_path);
			db.sql="update #db.param("cloud_file", request.zos.zcoreDatasource)# SET 
			cloud_file_is_online=#db.param(1)#, 
			cloud_file_is_local=#db.param(0)#, 
			cloud_file_url=#db.param(rs.cloud_file_url)#,
			cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE cloud_file_id=#db.param(rs.data.cloud_file_id)# and 
			cloud_file_deleted=#db.param(0)#";
			db.execute("qUpdate");
		}
	}else{
		if(rs.data.cloud_file_is_local EQ 0){
			if(rs.data.cloud_file_is_online EQ 0){
				throw("The file doesn't exist online or locally: #arguments.path#");
			}else{
				// download online to local path (force replace)
				newPath=request.zos.globals.privateHomeDir&rs.data.cloud_file_path; 

				// allow 10 seconds per megabyte to download file
				seconds=round(10*(rs.data.cloud_file_size/1024/1024));
				application.zcore.functions.zSetRequestTimeout(seconds+5);

				application.zcore.functions.zHTTPToFile(rs.data.cloud_file_url, newPath, seconds);
				if(not fileexists(newPath)){
					throw("Failed to download file: #rs.data.cloud_file_url# for path: #arguments.path#");
				}
				return {success:true};
			}
		}else{
			return {success:true};
		}
	}
	
	</cfscript>
</cffunction>

<cffunction name="deleteFile" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	// mark file as deleted in db only. / purge occurs 30 days later
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		return {success:false, errorMessage:"File already deleted"};
	}

	db.sql="select max(cloud_file_deleted) id from #db.table("cloud_file", request.zos.zcoreDatasource)# 
	WHERE cloud_file_deleted<>#db.param(0)# and 
	cloud_file_path=#db.param(arguments.path)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qId=db.execute("qId");
	db=request.zos.queryObject;
	id=qId.id;
	while(true){
		id++;
		db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET 
		cloud_file_deleted=#db.param(id)#,
		cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)# ,
		cloud_file_deleted_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		site_id=#db.param(request.zos.globals.id)# and 
		cloud_file_deleted=#db.param(0)# and 
		cloud_file_id=#db.param(rs.data.cloud_file_id)# ";
		update=db.execute("qUpdate");
		if(update){
			break;
		}
	}

	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="listDeletedFiles" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	if(not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.functions.z404("Access denied");
	}

	// if we store user_id for files, then we can let users recover deleted files, otherwise only administrators can

	db.sql="select * from #db.table("cloud_file", request.zos.zcoreDatasource)# 
	WHERE cloud_file_deleted<>#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# 
	ORDER BY cloud_file_deleted_datetime DESC  
	LIMIT #db.param(0)#, #db.param(10)# ";
	qDeleted=db.execute("qDeleted");

	echo('<h2>Deleted Files</h2>
	<p>This is a list of all the deleted files in the last 30 days.</p>');
	// todo support pagination and search here
	echo('<table class="table-list">
		<tr>
		<th>File</th>
		<th>Size</th>
		<th>Deleted Date</th>
		<th>Admin</th>
		</tr>');
	for(row in qDeleted){
		echo('<tr>
			<td>#row.cloud_file_path#</td>
			<td>#row.cloud_file_size#</td>
			<td>#dateformat(row.cloud_file_deleted_datetime, 'm/d/yy')&" at "&timeformat(row.cloud_file_deleted_datetime, "h:mm tt")#</td>
			<td><a href="/z/_com/zos/cloudFile?method=downloadDeletedFile&cloud_file_id=#row.cloud_file_id#" target="_blank">Download</a></td>
			</tr>');
	}
	echo('</table>');
	</cfscript>
</cffunction>
	
<cffunction name="downloadDeletedFile" localmode="modern" access="remote">
	<cfscript>
	if(not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.functions.z404("Access denied");
	}
	form.cloud_file_id=application.zcore.functions.zso(form, 'cloud_file_id', true);
	db=request.zos.queryObject;
	db.sql="select * from #db.table("cloud_file")# WHERE 
	cloud_file_id=#db.param(form.cloud_file_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted<>#db.param(0)#";
	qFile=db.execute("qFile");
	for(row in qFile){
		if(row.cloud_file_is_local EQ 1){
			application.zcore.functions.zheader("X-Accel-Redirect", rs.data.cloud_file_path);
		}else{
			application.zcore.functions.zheader("X-Accel-Redirect", replace(rs.data.cloud_file_url, "https://", "/zcf_internal/"));
		}
		abort;
	}
	application.zcore.functions.z404("File doesn't exist.");
	</cfscript>
</cffunction>
	

<cffunction name="fileExists" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(rs.success){
		if(rs.data.cloud_file_deleted NEQ 0){
			return false;
		}else{
			return true;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="getTemporaryFile" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		return rs;
	}
	newPath=request.zos.globals.privateHomeDir&"temp_files/";
	application.zcore.functions.zCreateDirectory(newPath);

	newFilePath=newPath&"tmp"&dateformat(now(), "yyyymmdd")&timeformat(now(), "HHmmss")&gettickcount();
	if(rs.data.cloud_file_is_local EQ 1){
		application.zcore.functions.zCopyFile(request.zos.globals.privateHomeDir&rs.data.cloud_file_path, newFilePath);

		return {success:true, path:newFilePath};
	}else{
		// downloads file to secure temporary path 
		// returns absolute path to temporary file which can be operated on

		// allow 10 seconds per megabyte to download file
		seconds=round(10*(rs.data.cloud_file_size/1024/1024));
		application.zcore.functions.zSetRequestTimeout(seconds+5);

		application.zcore.functions.zHTTPToFile(rs.data.cloud_file_url, newFilePath, seconds);
		if(not fileexists(newFilePath)){
			throw("Failed to download file: #rs.data.cloud_file_url# for path: #arguments.path#");
		}
		return {success:true, path:newFilePath};
	}
	</cfscript>

</cffunction>  

<cffunction name="directDownloadFile" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(rs.success){
		if(rs.data.cloud_file_is_secure EQ 1){
			application.zcore.functions.z404("Access denied");
		}
		application.zcore.functions.zheader("X-Accel-Redirect", replace(rs.data.cloud_file_url, "https://", "/zcf_internal/"));
		abort;
	}
	</cfscript>
</cffunction>

<cffunction name="getFileById" localmode="modern" access="public">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("cloud_file")# WHERE 
	cloud_file_id=#db.param(arguments.id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted=#db.param(0)#";
	qFile=db.execute("qFile");
	for(row in qFile){
		return { success:true, data: row };
	}
	return {success:false, errorMessage:"File doesn't exist"};
	</cfscript>
</cffunction>

<cffunction name="getFileByPath" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("cloud_file")# WHERE 
	cloud_file_path=#db.param(arguments.path)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted=#db.param(0)#";
	qFile=db.execute("qFile");
	for(row in qFile){
		return { success:true, data: row };
	}
	return {success:false, errorMessage:"File doesn't exist"};
	</cfscript>
</cffunction>

<cffunction name="purgeOldFiles" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer and server ips can access this");
	}

	oldDate=dateadd("d", -30, now());

	db.sql="select * from #db.table("cloud_file")# WHERE  
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted_datetime<#db.param(dateformat(oldDate, "yyyy-mm-dd")&" "&timeformat(oldDate, "HH:mm:ss"))# and
	cloud_file_deleted<>#db.param(0)#";
	qFile=db.execute("qFile");
	for(row in qFile){
		purgeFile(row);
	}
	echo('#qFile.recordcount# old files permanently deleted');
	abort;
	</cfscript>
</cffunction>

<!--- Internal --->

<cffunction name="downloadFile" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	// guarantees cloud_file_url is never shared publicly, so we can "delete" files, without removing them from CDN
	
	// use X-Accel-Redirect and proxy_pass like this: http://distinctplace.com/infrastructure/2013/09/18/use-nginx-to-proxy-files-from-remote-location-using-x-accel-redirect/
	// be sure to hide the headers returned from cloud vendor for added security
	// also consider passing basic authentication parameters to proxy to further protect files
	application.zcore.functions.zheader("X-Accel-Redirect", replace(arguments.ds.cloud_file_url, "https://", "/zcf_internal/"));
	abort;

	</cfscript>
</cffunction>

<!--- vendor specific --->
<cffunction name="purgeFile" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	if(arguments.ds.cloud_vendor_id EQ 1){
		return localPurgeFile(arguments.ds);
	}else if(arguments.ds.cloud_vendor_id EQ 2){
		return rackspacePurgeFile(arguments.ds);
	}
	if(arguments.ds.cloud_file_is_local EQ 1){
		application.zcore.functions.zdeletefile(request.zos.globals.privateHomeDir&removechars(arguments.ds.cloud_file_path, 1, 1)); 
	}
	db=request.zos.queryObject;
	db.sql="delete from #db.table("cloud_file", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	cloud_file_deleted=#db.param(arguments.ds.cloud_file_deleted)# and 
	cloud_file_id=#db.param(arguments.ds.cloud_file_id)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

<cffunction name="localPurgeFile" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	// issue real delete command to remote system
	newPath=request.zos.globals.privateHomeDir&"local_cloud_files"&arguments.ds.cloud_file_path;
	application.zcore.functions.zdeletefile(newPath); 
	return true;
	</cfscript>
</cffunction>

<cffunction name="rackspacePurgeFile" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	throw("not implemented");
	// issue real delete command to remote system
	//arguments.ds.cloud_file_url
	//arguments.ds.cloud_file_hash
	return true;
	</cfscript>
</cffunction>

<cffunction name="storeOnline" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	// put file to cloud vendor 
	if(arguments.ds.cloud_vendor_id EQ 1){
		return localStoreOnline(arguments.ds);
	}else if(arguments.ds.cloud_vendor_id EQ 2){
		return rackspaceStoreOnline(arguments.ds);
	} 
	</cfscript>
</cffunction>

<cffunction name="localStoreOnline" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	destinationPath=request.zos.globals.privateHomeDir&"zuploadsecure/cloud_files";
	application.zcore.functions.zCreateDirectory(destinationPath);

	newPath=application.zcore.functions.zCopyFile(request.zos.globals.privateHomeDir&arguments.ds.cloud_file_path, destinationPath); 
	if(newPath EQ false){
		return {success:false: errorMessage: Request.zCopyFileError};
	}
	return {success:true, cloud_file_url:request.zos.globals.domain&replace(newPath, request.zos.globals.privateHomeDir, "/")};
	</cfscript>
</cffunction>

<cffunction name="rackspaceStoreOnline" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	throw("not implemented");
	link="";
	return {success:true, cloud_file_url:link};
	</cfscript>
</cffunction>
</cfcomponent>