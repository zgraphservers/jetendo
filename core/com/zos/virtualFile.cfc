<cfcomponent>
<cfoutput>
	<!--- 
TODO:
	make secure part of download url 0.123423 and 1.2342342 so we can proxy cache and routing different for secure vs public

	#change /zupload/test to /zupload/user when virtual file is done in system/nginx-conf/jetendo-vhosts.conf on all servers
		working example: http://www.farbeyondcode.com.127.0.0.2.nip.io/zupload/test/_25_1920x352_14.jpg

	make sure to test change file and folder from secure to insecure

	consider implementing date sorting on file list (maybe do client side instead since server side is more complex)

	the html editor image cache feature must execute virtualFile, since it writes images to /zupload/user/
--->

<!--- 
ts={
	enableCache:"everything", // One of these values: disabled, folders, everything |  keeps database record in memory for all operations
	storageMethod:"localFilesystem", // localFilesystem or cloudFile

	// We allow public and secure files to be stored in different locations because it may be possible to optimize performance differently if we can expose the cloud file URLs directly. Instead of being forced to proxy requests through our server to achieve custom authentication, public requests can be redirect directly to the CDN URL (at the risk of users using the cloud URL in the CMS or elsewhere).  For the local filesystem, there is no difference if the files will not be accessible directly in web server without passing through Jetendo first.  We should also be aware that cloud / cdn charge much more for bandwidth, and we can still benefit from having a nginx proxy cache in front of the cloud to reduce our cloud bandwidth cost at the expense of wasting some memory/storage even when there are no security requirements for the public requests.

	// localFilesystem options
	publicRootAbsolutePath:request.zos.globals.privateHomeDir&"zupload/user/", 
	secureRootAbsolutePath:request.zos.globals.privateHomeDir&"zuploadsecure/user/", // this could be the same as publicRootAbsolutePath
	publicRootRelativePath:"/zupload/user/", 
	secureRootRelativePath:"/zuploadsecure/user/",

	// cloudFile options cloudFileInstance: cloud
	apiURL:"", // the relevant storage api url for your account. 
	publicContainerId:"", // cloud vendors provide container ids typically
	publicContainerPathPrefix:"", // optionally prefixed all files within the container.
	secureContainerId:"", // this could be the same
	secureContainerPathPrefix:"", // optionally prefixed all files within the container.
	accountId:"", // username or api auth id
	secretKey:"", // password or some kind of key for api
	secretKey2:"", // if another type of authentication key is required.
	exposeCloudURLs: false // Set to true to allow users to visit cloud URLs directly, false to proxy all cloud traffic through our web server.
};

// There must be a separate object per site in order to guarantee site cache loading occurs incrementally and the root path config is separate per site.
virtualFileCom=application.zcore.functions.zCreateObject("component", "zcorerootmapping.com.zos.virtualFile");
virtualFileCom.init(ts);
 --->
<cffunction name="init" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		enableCache:"disabled",
		storageMethod:"localFilesystem",

		publicRootAbsolutePath:"",
		secureRootAbsolutePath:"",
		publicRootRelativePath:"",
		secureRootRelativePath:"",

		apiURL:"", 
		publicContainerId:"", 
		publicContainerPathPrefix:"",
		secureContainerId:"", 
		secureContainerPathPrefix:"",
		accountId:"", 
		secretKey:"", 
		secretKey2:"",
		exposeCloudURLs:false
	};
	ss=arguments.ss;
	structAppend(ss, ts, false);
	if(ss.enableCache NEQ "everything" and ss.enableCache NEQ "disabled" and ss.enableCache NEQ "folders"){
		throw("Invalid value for ss.enableCache, must be: disabled, folders or everything");
	}
	if(ss.storageMethod EQ "localFilesystem"){
		if(ss.publicRootAbsolutePath EQ "" or not directoryexists(ss.publicRootAbsolutePath)){
			throw("ss.publicRootAbsolutePath must be defined and exist: Current value: ""#ss.publicRootAbsolutePath#"".");
		}
		if(ss.secureRootAbsolutePath EQ "" or not directoryexists(ss.secureRootAbsolutePath)){
			throw("ss.secureRootAbsolutePath must be defined and exist: Current value: ""#ss.secureRootAbsolutePath#"".");
		}
		if(ss.publicRootRelativePath EQ ""){
			throw("ss.publicRootRelativePath must be defined and exist: Current value: ""#ss.publicRootRelativePath#"".");
		}
		if(ss.secureRootRelativePath EQ ""){
			throw("ss.secureRootRelativePath must be defined and exist: Current value: ""#ss.secureRootRelativePath#"".");
		}
	}else if(ss.storageMethod EQ "cloudFile"){
		throw("Not implemented");
	}else{
		throw("ss.storageMethod must be cloudFile or localFilesystem. Current value: ""#ss.storageMethod#""");
	}
	if(ss.storageMethod EQ "localFilesystem"){
		ss.publicPathPrefix=ss.publicRootAbsolutePath;
		ss.securePathPrefix=ss.secureRootAbsolutePath;
	}else{
		ss.publicPathPrefix=ss.publicContainerId&ss.publicContainerPathPrefix;
		ss.securePathPrefix=ss.secureContainerId&ss.publicContainerPathPrefix;
	}
	variables.config=ss;

	// always force cache fields to exist, even if 
	if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'virtualFileCache')){
		reloadCache(application.siteStruct[request.zos.globals.id]);
	}
	</cfscript>
</cffunction>

<!--- virtualFileCom.reloadCache(application.siteStruct[request.zos.globals.id]) --->
<cffunction name="reloadCache" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	if(variables.config.enableCache EQ "disabled"){
		return;
	}
	db=request.zos.queryObject;
	ts={
		fileDataStruct:{},
		filePathStruct:{},
		folderDataStruct:{},
		folderPathStruct:{},
		treeStruct:{
		} // stores the tree structure of folders/files
	};
	ts.treeStruct[variables.config.publicPathPrefix]={
		fileStruct:{}, 
		folderStruct:{} 
	};
	// get all files and folders
	db.sql="select * from #db.table("virtual_folder", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	virtual_folder_deleted=#db.param(0)# ";
	//ORDER BY virtual_folder_path ASC";
	qFolder=db.execute("qFolder");

	for(row in qFolder){
		if(row.virtual_folder_secure EQ 1){ 
			path=variables.config.securePathPrefix&row.virtual_folder_path; 
		}else{
			path=variables.config.publicPathPrefix&row.virtual_folder_path; 
			ts.folderPathStruct[path]=row.virtual_folder_id;
		}
		if(not structkeyexists(ts.treeStruct, path)){
			ns={
				fileStruct:{},
				folderStruct:{}
			}
			ts.treeStruct[path]=ns;
		}
		ts.folderDataStruct[row.virtual_folder_id]=row;

		parentPath=getDirectoryFromPath(path);
		if(parentPath EQ "/"){
			parentPath="";
		}else{
			parentPath=left(parentPath, len(parentPath)-1); 
		}
		/*if(not structkeyexists(ts.treeStruct, parentPath)){
			ns={
				fileStruct:{},
				folderStruct:{}
			}
			ts.treeStruct[parentPath]=ns;
		}*/
		ts.treeStruct[parentPath].folderStruct[row.virtual_folder_id]=true;
	}
	if(variables.config.enableCache EQ "everything"){
		db.sql="select * from #db.table("virtual_file", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		virtual_file_deleted=#db.param(0)#"; 
		// ORDER BY virtual_file_path ASC";
		qFile=db.execute("qFile");
		for(row in qFile){
			if(row.virtual_file_secure EQ 1){ 
				path=variables.config.securePathPrefix&row.virtual_file_path; 
			}else{
				path=variables.config.publicPathPrefix&row.virtual_file_path; 
				ts.filePathStruct[path]=row.virtual_file_id;
			}
			ts.fileDataStruct[row.virtual_file_id]=row;
			parentPath=getDirectoryFromPath(path);
			if(parentPath EQ "/"){
				parentPath="";
			}else{
				parentPath=left(parentPath, len(parentPath)-1);
			}
			/*
			if(not structkeyexists(ts.treeStruct, parentPath)){
				ns={
					fileStruct:{},
					folderStruct:{}
				}
				ts.treeStruct[parentPath]=ns;
			}*/
			ts.treeStruct[parentPath].fileStruct[row.virtual_file_id]=true;
		}
	}
	arguments.ss.virtualFileCache=ts;
	</cfscript>
</cffunction>
	
<!--- rs=virtualFileCom.getFolderById(virtual_folder_id); --->
<cffunction name="getFolderById" localmode="modern" access="public">
	<cfargument name="virtual_folder_id" type="string" required="yes">
	<cfscript>
	db = request.zos.queryObject; 
	if(variables.config.enableCache NEQ "disabled"){
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache.folderDataStruct;
		if(structkeyexists(ts, arguments.virtual_folder_id)){
			return {success:true, data:ts[arguments.virtual_folder_id]};
		}
	}else{
		db.sql = 'SELECT *
		FROM #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( request.zos.globals.id )#
		AND virtual_folder_id = #db.param( arguments.virtual_folder_id )#
		AND virtual_folder_deleted = #db.param( 0 )#';
		qFolder = db.execute( 'Folder' );
		for(row in qFolder){
			return {success:true, data:row};
		}
	}
	return {success:false, errorMessage:"Folder ID " & arguments.virtual_folder_id &" doesn't exist"}; 
	</cfscript>
</cffunction>

<!--- rs=virtualFileCom.getFolderByPath(virtual_folder_path); --->
<cffunction name="getFolderByPath" localmode="modern" access="public">
	<cfargument name="virtual_folder_path" type="string" required="yes">
	<cfscript>
	db = request.zos.queryObject;
	if(right(arguments.virtual_folder_path, 1) EQ "/"){
		arguments.virtual_folder_path=left(arguments.virtual_folder_path, len(arguments.virtual_folder_path)-1);
	}
	if(variables.config.enableCache NEQ "disabled"){ 
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
		tempPath=variables.config.publicPathPrefix&arguments.virtual_folder_path;
		if(structkeyexists(ts.folderPathStruct, tempPath)){
			virtual_folder_id=ts.folderPathStruct[tempPath];
			return {success:true, data:ts.folderDataStruct[virtual_folder_id]};
		}
	}else{
		db.sql = 'SELECT *
		FROM #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( request.zos.globals.id )#
		AND virtual_folder_path = #db.param( arguments.virtual_folder_path )#
		AND virtual_folder_deleted = #db.param( 0 )#';
		qFolder = db.execute( 'Folder' );
		for(row in qFolder){
			return {success:true, data:row};
		}
		return {success:false, errorMessage:"Folder Path " & arguments.virtual_folder_path &" doesn't exist"}; 
	}
	</cfscript>
</cffunction>

<!--- virtualFileCom.folderExistsById(virtual_folder_id); --->
<cffunction name="folderExistsById" localmode="modern" access="public">
	<cfargument name="virtual_folder_id" type="string" required="yes">
	<cfscript>
	rs=getFolderById(arguments.virtual_folder_id);
	return rs.success;
	</cfscript>
</cffunction>

<!--- virtualFileCom.folderExistsByPath(virtual_folder_path); --->
<cffunction name="folderExistsByPath" localmode="modern" access="public">
	<cfargument name="virtual_folder_path" type="string" required="yes">
	<cfscript>
	rs=getFolderByPath(arguments.virtual_folder_path);
	return rs.success;
	</cfscript>
</cffunction>

<cffunction name="getChildFoldersFromCacheAsArray" localmode="modern" access="private" returntype="array">
	<cfargument name="type" type="string" required="yes" hint="Valid values are: folders, files or both">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="arrFolder" type="array" required="yes">
	<cfargument name="limit" type="numeric" required="no" default="#0#" hint="This is used for folderHasChildren as a performance improvement">
	<cfscript>
	ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
	if(arguments.type NEQ "files"){
		if(arguments.path EQ ""){
			tempFolderStruct=ts.treeStruct[left(variables.config.publicPathPrefix, len(variables.config.publicPathPrefix)-1)].folderStruct;
		}else{
			tempFolderStruct=ts.treeStruct[variables.config.publicPathPrefix&arguments.path].folderStruct;
		}
		for(virtual_folder_id in folderStruct){
			if(arguments.limit){
				if(arrayLen(arguments.arrFolder) EQ arguments.limit){
					break;
				}
			}
			arrayAppend(arguments.arrFolder, ts.folderDataStruct[virtual_folder_id]);
			arguments.arrFolder=getChildFoldersFromCacheAsArray(ts.folderDataStruct[virtual_folder_id].virtual_folder_path, arguments.arrFolder);
		}
	}
	if(arguments.type NEQ "folders"){
		if(arguments.path EQ ""){
			tempFolderStruct=ts.treeStruct[left(variables.config.publicPathPrefix, len(variables.config.publicPathPrefix)-1)].fileStruct;
		}else{
			tempFolderStruct=ts.treeStruct[variables.config.publicPathPrefix&arguments.path].fileStruct;
		}
		for(virtual_file_id in fileStruct){ 
			if(arguments.limit){
				if(arrayLen(arguments.arrFolder) EQ arguments.limit){
					break;
				}
			}
			arrayAppend(arguments.arrFolder, ts.fileDataStruct[virtual_file_id]);
			arguments.arrFolder=getChildFoldersFromCacheAsArray(ts.fileDataStruct[virtual_file_id].virtual_file_path, arguments.arrFolder);
		}
	}
	if(arrayLen(arguments.arrFolder) GT 50000){
		throw("Possible infinite loop - reached 50000 child folder limit");
	}
	return arguments.arrFolder;
	</cfscript>
</cffunction>

<cffunction name="getChildFoldersFromCacheAsStruct" localmode="modern" access="private" returntype="array">
	<cfargument name="type" type="string" required="yes" hint="Valid values are: folders, files or both">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="folderStruct" type="struct" required="yes">
	<cfargument name="limit" type="numeric" required="no" default="#0#" hint="This is used for folderHasChildren as a performance improvement">
	<cfscript>
	ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
	 
	if(arguments.type NEQ "files"){
		if(arguments.path EQ ""){
			tempFolderStruct=ts.treeStruct[left(variables.config.publicPathPrefix, len(variables.config.publicPathPrefix)-1)].folderStruct;
		}else{
			tempFolderStruct=ts.treeStruct[variables.config.publicPathPrefix&arguments.path].folderStruct;
		}
		for(virtual_folder_id in tempFolderStruct){
			if(arguments.limit){
				if(structcount(arguments.folderStruct) EQ arguments.limit){
					break;
				}
			}
			arguments.folderStruct[virtual_folder_id]=ts.folderDataStruct[virtual_folder_id];
			arguments.folderStruct=getChildFoldersFromCacheAsStruct(ts.folderDataStruct[virtual_folder_id].virtual_folder_path, arguments.folderStruct);
		}
	}
	if(arguments.type NEQ "folders"){
		if(arguments.path EQ ""){
			tempFolderStruct=ts.treeStruct[left(variables.config.publicPathPrefix, len(variables.config.publicPathPrefix)-1)].fileStruct;
		}else{
			tempFolderStruct=ts.treeStruct[variables.config.publicPathPrefix&arguments.path].fileStruct;
		}
		for(virtual_file_id in tempFileStruct){
			if(arguments.limit){
				if(structcount(arguments.folderStruct) EQ arguments.limit){
					break;
				}
			}
			arguments.fileStruct[virtual_file_id]=ts.fileDataStruct[virtual_file_id];
			arguments.folderStruct=getChildFoldersFromCacheAsStruct(ts.fileDataStruct[virtual_file_id].virtual_file_path, arguments.folderStruct);
		}
	}
	if(structcount(arguments.folderStruct) GT 50000){
		throw("Possible infinite loop - reached 50000 child folder limit");
	}
	return arguments.folderStruct;
	</cfscript>
</cffunction>

<!--- result=virtualFileCom.folderHasChildren(virtual_folder_id); --->
<cffunction name="folderHasChildren" localmode="modern" access="public" returntype="boolean">
	<cfargument name="virtual_folder_id" type="string" required="yes">
	<cfscript>
	arrFolder=getChildrenByFolderId("both", arguments.virtual_folder_id, false, "", 0, 1);
	if(arrayLen(arrFolder)){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
	
<!--- arrFolder=virtualFileCom.getChildrenByFolderId(type, virtual_folder_id, recursive, orderDirection); --->
<cffunction name="getChildrenByFolderId" localmode="modern" access="public" returntype="array">
	<cfargument name="type" type="string" required="yes" hint="Valid values are: folders, files or both">
	<cfargument name="virtual_folder_id" type="string" required="yes">
	<cfargument name="recursive" type="boolean" required="no" default="#false#">
	<cfargument name="orderDirection" type="string" required="no" default="" hint="orderDirection is optional and performance is better if you leave it empty, otherwise use ASC or DESC to sort by virtual_folder_path">
	<cfargument name="limit" type="numeric" required="no" default="#0#" hint="This is used for folderHasChildren as a performance improvement">
	<!--- supporting offset is too complicated: <cfargument name="offset" type="numeric" required="no" default="#0#"> --->
	<cfscript>
	db = request.zos.queryObject;
	offset=0;
	limit=arguments.limit;
	arrFolder=[];
	if(variables.config.enableCache EQ "disabled"){

		if(arguments.recursive){
			if(arguments.virtual_folder_id NEQ 0){
				rs=getFolderById(arguments.virtual_folder_id);
				if(not rs.success){
					return arrFolder;
				}
			}
			if(arguments.type NEQ "files"){
				db.sql = 'SELECT *
				FROM #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#';
				if(arguments.virtual_folder_id NEQ 0){
					db.sql&=" AND virtual_folder_path LIKE #db.param(rs.data.virtual_folder_path&"/%")# ";
				}
				db.sql&=' 
				AND virtual_folder_deleted = #db.param( 0 )# ';
				if ( arguments.orderDirection EQ 'ASC' ) {
					db.sql &= 'ORDER BY virtual_folder_path ASC';
				} else if ( arguments.orderDirection EQ 'DESC' ) {
					db.sql &= 'ORDER BY virtual_folder_path DESC';
				}
				if(limit){
					db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)# ";
				}
				qFolder=db.execute( 'qFolder' );
			}
			if(arguments.type NEQ "folders"){
				db.sql = 'SELECT *
				FROM #db.table( 'virtual_file', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )# ';
				if(arguments.virtual_folder_id NEQ 0){
					db.sql&=" AND virtual_file_path LIKE #db.param(rs.data.virtual_folder_path&"/%")# ";
				}
				db.sql&=' AND virtual_file_deleted = #db.param( 0 )# ';
				if ( arguments.orderDirection EQ 'ASC' ) {
					db.sql &= 'ORDER BY virtual_file_path ASC';
				} else if ( arguments.orderDirection EQ 'DESC' ) {
					db.sql &= 'ORDER BY virtual_file_path DESC';
				}
				if(limit){
					db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)# ";
				}
				qFile=db.execute( 'qFile' );
			}
		}else{
			if(arguments.type NEQ "files"){
				db.sql = 'SELECT *
				FROM #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_parent_id = #db.param( arguments.virtual_folder_id )#
				AND virtual_folder_deleted = #db.param( 0 )# ';
				if ( arguments.orderDirection EQ 'ASC' ) {
					db.sql &= 'ORDER BY virtual_folder_path ASC';
				} else if ( arguments.orderDirection EQ 'DESC' ) {
					db.sql &= 'ORDER BY virtual_folder_path DESC';
				}
				if(limit){
					db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)# ";
				}
				qFolder=db.execute( 'qFolder' );
			}
			if(arguments.type NEQ "folders"){

				db.sql = 'SELECT *
				FROM #db.table( 'virtual_file', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_parent_id = #db.param( arguments.virtual_file_id )#
				AND virtual_file_deleted = #db.param( 0 )# ';
				if ( arguments.orderDirection EQ 'ASC' ) {
					db.sql &= 'ORDER BY virtual_file_path ASC';
				} else if ( arguments.orderDirection EQ 'DESC' ) {
					db.sql &= 'ORDER BY virtual_file_path DESC';
				}
				if(limit){
					db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)# ";
				}
				qFile=db.execute( 'qFile' );
			}
		}
		if(arguments.type EQ "everything"){
			folderStruct={};
			for(row in qFile){
				path=getDirectoryFromPath(row.virtual_file_path);
				if(path EQ "/"){
					path="";
				}else{
					path=left(path, len(path)-1);
				}
				if(not structkeyexists(folderStruct, path)){
					folderStruct[path]=[];
				}
				arrayAppend(folderStruct[path], row);
			}
			lastPath="";
			for(row in qFolder){
				if(limit){
					if(arrayLen(arrFolder) EQ limit){
						break;
					}
				}
				if(lastPath NEQ row.virtual_folder_path){
					for(row in folderStruct[lastPath]){
						if(limit){
							if(arrayLen(arrFolder) EQ limit){
								break;
							}
						}
						arrayAppend(arrFolder, row);
					}
					lastPath=row.virtual_folder_path;
				}
				arrayAppend(arrFolder, row);
			}
		}else if(arguments.type EQ "files"){
			for(row in qFile){
				if(limit){
					if(arrayLen(arrFolder) EQ limit){
						break;
					}
				}
				arrayAppend(arrFolder, row);
			}
		}else if(arguments.type EQ "folders"){
			for(row in qFolder){
				if(limit){
					if(arrayLen(arrFolder) EQ limit){
						break;
					}
				}
				arrayAppend(arrFolder, row);
			}
		}else{
			throw("invalid value for arguments.type");
		}
	}else{
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
		if(arguments.virtual_folder_id NEQ 0){
			rs=getFolderById(arguments.virtual_folder_id);
			if(not rs.success){
				return arrFolder;
			}
			path=rs.data.virtual_folder_path;
		}else{
			path="";
		} 
		if(arguments.recursive){
			if(arguments.orderDirection EQ ""){
				// no sorting required
				arrFolder=getChildFoldersFromCacheAsArray(arguments.type, path, arrFolder, limit);
			}else{
				folderStruct={};
				folderStruct=getChildFoldersFromCacheAsStruct(arguments.type, path, folderStruct, limit);
				arrKey=structsort(folderStruct, "text", arguments.orderDirection, "virtual_folder_path");
				for(path in arrKey){
					if(limit){
						if(arrayLen(arrFolder) EQ limit){
							break;
						}
					}
					arrayAppend(arrFolder, folderStruct[path]);
				}
			}
		}else{
			if(path EQ ""){
				treeStruct=ts.treeStruct[left(variables.config.publicPathPrefix, len(variables.config.publicPathPrefix)-1)];
			}else{ 
				treeStruct=ts.treeStruct[variables.config.publicPathPrefix&path];
			}
			if(arguments.orderDirection EQ ""){
				// no sorting required
				for(virtual_folder_id in treeStruct.folderStruct){
					if(limit){
						if(arrayLen(arrFolder) EQ limit){
							break;
						}
					}
					arrayAppend(arrFolder, ts.folderDataStruct[virtual_folder_id]);
				}
				for(virtual_file_id in treeStruct.fileStruct){
					if(limit){
						if(arrayLen(arrFolder) EQ limit){
							break;
						}
					}
					arrayAppend(arrFolder, ts.fileDataStruct[virtual_file_id]);
				}
			}else{
				tempFolderStruct={};
				tempFileStruct={};
				for(virtual_folder_id in treeStruct.folderStruct){
					tempFolderStruct[virtual_folder_id]=ts.folderDataStruct[virtual_folder_id];
				}
				arrKey=structsort(tempFolderStruct, "text", arguments.orderDirection, "virtual_folder_path");
				for(path in arrKey){
					if(limit){
						if(arrayLen(arrFolder) EQ limit){
							break;
						}
					}
					arrayAppend(arrFolder, tempFolderStruct[path]);
				}
				for(virtual_file_id in treeStruct.fileStruct){
					tempFileStruct[virtual_file_id]=ts.fileDataStruct[virtual_file_id];
				}
				arrKey=structsort(tempFileStruct, "text", arguments.orderDirection, "virtual_file_path");
				for(path in arrKey){
					if(limit){
						if(arrayLen(arrFolder) EQ limit){
							break;
						}
					}
					arrayAppend(arrFolder, tempFileStruct[path]);
				}
			}
			
		}
	}
	return arrFolder;
	</cfscript>
</cffunction>

<!--- 
ts={
	data:{
		virtual_folder_name:"Name",
		virtual_folder_path:"path/to/Name",
		virtual_folder_secure:0,
		virtual_folder_user_group_list:""
	}
}
rs=virtualFileCom.createFolder(ts);
if(rs.success EQ false){
	throw("Failed to create folder");
}
rs.virtual_folder_id;
 --->
<cffunction name="createFolder" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes"> 
	<cfscript>
	ss=arguments.ss;
	ss.data.site_id=request.zos.globals.id;
	if(left(ss.data.virtual_folder_path, 1) EQ "/"){
		ss.data.virtual_folder_path=removeChars(ss.data.virtual_folder_path, 1, 1);
	}
	ts={
		table:"virtual_folder",
		datasource:request.zos.zcoreDatasource,
		struct:ss.data
	}
	tempPath=getDirectoryFromPath(ss.data.virtual_folder_path);
	if(tempPath EQ "/"){
		tempPath="";
	}else if(right(tempPath, 1) EQ "/"){
		tempPath=left(tempPath, len(tempPath)-1);
	}
	if(tempPath EQ ""){
		parentFolderId=0;
	}else{
		rs=getFolderByPath(tempPath);
		if(not rs.success){
			return {success:false, errorMessage:"Parent folder doesn't exist."};
		} 
		parentFolderId=rs.data.virtual_folder_id;
	}
	transaction action="begin"{
		try{
			ts.struct.virtual_folder_deleted=0;
			ts.struct.virtual_folder_updated_datetime=request.zos.mysqlnow;
			ts.struct.virtual_folder_parent_id=parentFolderId;
			// force virtual_file_user_group_list to match any parent folder that has this set
			ts.struct.virtual_folder_id=application.zcore.functions.zInsert(ts);

			if(ts.struct.virtual_folder_id EQ false){
				return {success:false, errorMessage:"Failed to create folder"};
			}
			if(variables.config.storageMethod EQ "localFilesystem"){
				// handle file creation / upload somehow - i think createFile should be uploadFile and a file operation should occur at the same time.

				if(variables.config.storageMethod EQ "localFilesystem"){
					securePath=variables.config.securePathPrefix&ts.struct.virtual_folder_path; 
					publicPath=variables.config.publicPathPrefix&ts.struct.virtual_folder_path; 
					application.zcore.functions.zCreateDirectory(securePath);
					application.zcore.functions.zCreateDirectory(publicPath);
				}else{
					throw("Not implemented");
				}
			}else{
				throw("Not implemented"); // Async push to cloud is better later
			}
			transaction action="commit";
		}catch(Any e2){
			// transaction failed.
			try{
				transaction action="rollback";
			}catch(Any e3){
				// ignore rollback failures
			}
			rethrow;
		}
	}

	if(variables.config.enableCache NEQ "disabled" and variables.config.enableCache NEQ "folders"){
		ts2=application.siteStruct[request.zos.globals.id].virtualFileCache;
		ts2.folderDataStruct[ts.struct.virtual_folder_id]=ts.struct;
		ts2.folderPathStruct[ts.struct.virtual_folder_path]=ts.struct.virtual_folder_id;
		path=getDirectoryFromPath(ts.struct.virtual_folder_path);
		if(path EQ "/"){
			path="";
		}else{
			path=left(path, len(path)-1);
		}
		structDelete(ts2.treeStruct[variables.config.publicPathPrefix&path].folderStruct, ts.struct.virtual_folder_id);
	}
	return {success:true, virtual_folder_id:ts.struct.virtual_folder_id};
	</cfscript>
</cffunction>


<!--- 
ts={
	data:{
		virtual_file_name:"Name",
		virtual_file_path:"path/to/Name",
		virtual_file_secure:0,
		virtual_file_user_group_list:"",
		virtual_file_image_width:0, 
		virtual_file_image_height:0,
		virtual_file_size:0,
		virtual_file_last_modified_datetime:request.zos.mysqlnow
	}
}
rs=virtualFileCom.createfile(ts);
if(rs.success EQ false){
	throw("Failed to create file");
}
rs.virtual_file_id;
 --->
<cffunction name="createFile" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes"> 
	<cfscript>
	ss=arguments.ss;
	ss.data.site_id=request.zos.globals.id;
	if(left(ss.data.virtual_file_path, 1) EQ "/"){
		ss.data.virtual_file_path=removeChars(ss.data.virtual_file_path, 1, 1);
	}
	ts={
		table:"virtual_file",
		datasource:request.zos.zcoreDatasource,
		struct:ss.data
	}
	tempPath=getDirectoryFromPath(ss.data.virtual_file_path);
	if(tempPath EQ "/"){
		tempPath="";
	}
	if(tempPath EQ ""){
		ts.struct.virtual_file_folder_id=0;
	}else{
		rs=getFolderByPath();
		if(not rs.success){
			return {success:false, errorMessage:"Parent folder doesn't exist."};
		}
		ts.struct.virtual_file_folder_id=rs.data.virtual_folder_id;
	}
	ts.struct.virtual_file_download_secret=hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256');
	ts.struct.virtual_file_deleted=0;
	ts.struct.virtual_file_updated_datetime=request.zos.mysqlnow;
	ts.struct.virtual_file_last_modified_datetime=dateformat(ts.struct.virtual_file_last_modified_datetime, "yyyy-mm-dd")&" "&timeformat(ts.struct.virtual_file_last_modified_datetime, "HH:mm:ss");
	// force virtual_file_user_group_list to match any parent file that has this set
	ts.struct.virtual_file_id=application.zcore.functions.zInsert(ts);

	// TODO: consider automating identify, file size and last modified datetime lookups here

	if(variables.config.storageMethod EQ "localFilesystem"){
		// handle file creation / upload somehow - i think createFile should be uploadFile and a file operation should occur at the same time.
	}else{
		throw("Not implemented"); // Async push to cloud is better later
	}
	if(ts.struct.virtual_file_id EQ false){
		return {success:false, errorMessage:"Failed to create file"};
	}

	if(variables.config.enableCache NEQ "disabled" and variables.config.enableCache NEQ "folders"){
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
		ts.fileDataStruct[ts.struct.virtual_file_id]=ts.struct;
		ts.filePathStruct[ts.struct.virtual_file_path]=ts.struct.virtual_file_id;
		path=getDirectoryFromPath(ts.struct.virtual_file_path);
		if(path EQ "/"){
			path="";
		}else{
			path=left(path, len(path)-1);
		}
		ts.treeStruct[variables.config.publicPathPrefix&path].fileStruct[arguments.virtual_file_id]=true;
	}
	return {success:true, virtual_file_id:ts.struct.virtual_file_id};
	</cfscript>
</cffunction>



<!--- 
ts={
	data:{
		virtual_folder_id:virtual_folder_id,
		virtual_folder_name:"Name",
		virtual_folder_path:"path/to/Name",
		virtual_folder_secure:0,
		virtual_folder_user_group_list:""
	}
}
rs=virtualFileCom.updateFolder(ts);
if(rs.success EQ false){
	throw("Failed to update folder");
}
 --->
<cffunction name="updateFolder" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db = request.zos.queryObject;
	rs=getFolderById(ss.data.virtual_folder_id);
	if(not rs.success){
		return rs;
	}
	tempPath=getDirectoryFromPath(ss.data.virtual_folder_path);
	if(tempPath EQ ""){
		newFolderId=0;
	}else{
		rs=getFolderByPath(tempPath);
		if(not rs.success){
			return rs;
		}
		newFolderId=rs.data.virtual_folder_id;
	}
	secureChanged=false;
	if(rs.data.virtual_folder_secure NEQ ss.data.virtual_folder_secure or rs.data.virtual_folder_user_group_list NEQ ss.data.virtual_folder_user_group_list){
		secureChanged=true;
	}

	transaction action="begin"{
		try{ 
			arrFile=getChildrenByFolderId("both", arguments.virtual_folder_id, true);
			for(row in arrFile){
				if(structkeyexists(row, 'virtual_folder_path')){
					newPath=ss.data.virtual_folder_path&removeChars(row.virtual_folder_path, 1, len(rs.data.virtual_folder_path));
					db.sql = 'UPDATE #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
					SET virtual_folder_path = #db.param( newPath )#,
						virtual_folder_updated_datetime = #db.param( request.zos.mysqlnow )# ';
					if(secureChanged){
						db.sql&=" ,virtual_folder_secure=#db.param(ss.data.virtual_folder_secure)#,
						virtual_folder_user_group_list=#db.param(ss.data.virtual_folder_user_group_list)# ";
					}
					db.sql&=' WHERE site_id = #db.param( request.zos.globals.id )#
						AND virtual_folder_id = #db.param( row.virtual_folder_id )# and 
						virtual_folder_deleted=#db.param(0)# ';
					db.execute( 'qUpdate' );
				}else{
					newPath=ss.data.virtual_folder_path&removeChars(row.virtual_file_path, 1, len(rs.data.virtual_folder_path));
					db.sql = 'UPDATE #db.table( 'virtual_file', request.zos.zcoreDatasource )#
					SET virtual_file_path = #db.param( newPath )#,
						virtual_file_updated_datetime = #db.param( request.zos.mysqlnow )#';
					if(secureChanged){
						db.sql&=" ,virtual_file_secure=#db.param(ss.data.virtual_folder_secure)#,
						virtual_file_user_group_list=#db.param(ss.data.virtual_folder_user_group_list)# ";
					}
					db.sql&='
					WHERE site_id = #db.param( request.zos.globals.id )#
						AND virtual_file_id = #db.param( row.virtual_file_id )# and 
						virtual_file_deleted=#db.param(0)# ';
					db.execute( 'qUpdate' );
				}
			}  
			// fix main record last
			db.sql = 'UPDATE #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
			SET virtual_folder_name = #db.param( ss.data.virtual_folder_name )#,
			virtual_folder_path = #db.param( ss.data.virtual_folder_path )#,
			virtual_folder_parent_id=#db.param(newFolderId)#, 
			virtual_folder_updated_datetime = #db.param( request.zos.mysqlnow )#';
			if(secureChanged){
				db.sql&=" ,virtual_folder_secure=#db.param(ss.data.virtual_folder_secure)#,
				virtual_folder_user_group_list=#db.param(ss.data.virtual_folder_user_group_list)# ";
			}
			db.sql&='
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_id = #db.param( arguments.virtual_folder_id )# and 
				virtual_folder_deleted=#db.param(0)#';
			db.execute( 'qUpdate' );

			if(variables.config.storageMethod EQ "localFilesystem"){
				securePath=variables.config.securePathPrefix&rs.data.virtual_folder_path; 
				publicPath=variables.config.publicPathPrefix&rs.data.virtual_folder_path; 
				newSecurePath=variables.config.securePathPrefix&ss.data.virtual_folder_path; 
				newPublicPath=variables.config.publicPathPrefix&ss.data.virtual_folder_path; 
				result=true;
				result2=true;
				if(directoryexists(securePath)){
					result=application.zcore.functions.zRenameDirectory(securePath, newSecurePath);
				}
				if(directoryexists(publicPath)){
					result2=application.zcore.functions.zRenameDirectory(publicPath, newPublicPath);
				}
				if(not result or not result2){
					return {success:false, errorMessage:"Failed to rename directory. The directory may not exist, or have wrong permissions."};
				}
			}else{
				throw("Not implemented"); // better to handle asynchronously
			}
			transaction action="commit";
		}catch(Any e2){
			// transaction failed.
			try{
				transaction action="rollback";
			}catch(Any e3){
				// ignore rollback failures
			}
			rethrow;
		}
	}
		 
	// fix cache to match db - TODO: consider doing this incrementally later
	reloadCache(application.siteStruct[request.zos.globals.id]);

	return {success:true};
	</cfscript>
</cffunction>

<!--- 
rs=virtualFileCom.deleteFolder(virtual_folder_id);
if(not rs.success){
	throw("Failed to delete folder: "&rs.errorMessage);
} 
--->
<cffunction name="deleteFolder" localmode="modern" access="public" hint="Warning: This function will recursively delete the folder and all folders/files within it.">
	<cfargument name="virtual_folder_id" type="string" required="yes">
	<cfscript>
	virtual_folder_id = arguments.virtual_folder_id;

	db = request.zos.queryObject;
	rs=getFolderById(virtual_folder_id);
	if(not rs.success){
		return rs;
	}
	if(not hasFolderAccess(rs.data)){
		return {success:false, errorMessage:"You don't have access to delete this folder"};
	}

	
	transaction action="begin"{
		try{   
			db.sql = 'UPDATE #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
				SET virtual_folder_deleted = #db.param( 1 )#,
					virtual_folder_updated_datetime = #db.param( request.zos.mysqlnow )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND virtual_folder_id = #db.param( virtual_folder_id )# and 
					virtual_folder_deleted=#db.param(0)#';

			db.execute('qUpdate');

			db.sql = 'UPDATE #db.table( 'virtual_folder', request.zos.zcoreDatasource )#
				SET virtual_folder_deleted = #db.param( 1 )#,
					virtual_folder_updated_datetime = #db.param( request.zos.mysqlnow )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND virtual_folder_path LIKE #db.param(rs.data.virtual_folder_path&"/%")# and 
					virtual_folder_deleted=#db.param(0)#';

			db.execute('qUpdate');

			if(variables.config.storageMethod EQ "localFilesystem"){
				securePath=variables.config.securePathPrefix&rs.data.virtual_folder_path; 
				publicPath=variables.config.publicPathPrefix&rs.data.virtual_folder_path; 
				application.zcore.functions.zDeleteDirectory(securePath);
				application.zcore.functions.zDeleteDirectory(publicPath);
			}else{
				throw("Not implemented"); // better if this was async, and on cronjob.  That's why we are using update instead of delete query above.
			}
			transaction action="commit";
		}catch(Any e2){
			// transaction failed.
			try{
				transaction action="rollback";
			}catch(Any e3){
				// ignore rollback failures
			}
			rethrow;
		}
	}

	if(variables.config.enableCache NEQ "disabled"){
		reloadCache(application.siteStruct[request.zos.globals.id]);
		/*
		// TODO: Later incrementally delete, instead of reloadCache - this code below doesn't handle deleting the children file/folders recursively.
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
		folderStruct=ts.folderDataStruct[arguments.virtual_folder_id];
		structdelete(ts.folderDataStruct, arguments.virtual_folder_id);
		structdelete(ts.folderPathStruct, folderStruct.virtual_folder_path);
		path=getDirectoryFromPath(folderStruct.virtual_folder_path);
		if(path EQ "/"){
			path="";
		}else{
			path=left(path, len(path)-1);
		}
		structDelete(ts.treeStruct[variables.config.publicPathPrefix&path].folderStruct, arguments.virtual_folder_id);
		*/

	}
	return {success:true};
	</cfscript>
</cffunction>


<cffunction name="hasFolderAccess" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	if(arguments.row.virtual_folder_secure EQ 1){
		arrGroup=listToArray(arguments.row.virtual_folder_user_group_list, ",");
		if (application.zcore.user.checkGroupAccess("administrator")) {
			return true;
		}else{
			for(group in arrGroup){
				if(application.zcore.user.checkGroupIdAccess(group)){
					return true;
				}
			}
			return false;
		}
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="hasFileAccess" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	if(arguments.row.virtual_file_secure EQ 1){
		arrGroup=listToArray(arguments.row.virtual_file_user_group_list, ",");
		if (application.zcore.user.checkGroupAccess("administrator")) {
			return true;
		}else{
			for(group in arrGroup){
				if(application.zcore.user.checkGroupIdAccess(group)){
					return true;
				}
			}
			return false;
		}
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<!--- arrFolder=virtualFileCom.getParentFolders(virtual_folder_id); --->
<cffunction name="getParentFolders" localmode="modern" access="public" returntype="struct">
	<cfargument name="virtual_folder_id" type="string" required="yes">
	<cfscript>
	arrFolder=[];
	if(arguments.virtual_folder_id EQ 0){
		return {success:true, arrFolder:arrFolder};
	}
	rs=getFolderById(arguments.virtual_folder_id);
	if(not rs.success){
		return rs;
	}
	parentId=rs.data.virtual_folder_parent_id;
	count=0;
	while(true){
		if(parentId EQ 0){
			break;
		}
		rs=getFolderById(parentId);
		if(not rs.success){
			return rs;
		}
		arrayAppend(arrFolder, rs.data);
		parentId=rs.data.virtual_folder_parent_id;
		count++;
		if(count GT 100){
			throw("Possible infinite loop when getting parent folders for virtual_folder_id=#arguments.virtual_folder_id#");
		}
	}
	return {success:true, arrFolder: arrFolder};
	</cfscript>
</cffunction>

<cffunction name="getViewLink" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	// 0.0. are reserved values for future use.
	return "/z/-vf."&arguments.row.virtual_file_secure&".0.0."&arguments.row.virtual_file_id&"."&arguments.row.virtual_file_download_secret;
	</cfscript>
</cffunction>
	
<cffunction name="getDownloadLink" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	// 0.0. are reserved values for future use.
	return "/z/-df."&arguments.row.virtual_file_secure&".0.0."&arguments.row.virtual_file_id&"."&arguments.row.virtual_file_download_secret;
	</cfscript>
</cffunction>
	
<!--- 
form.virtual_file_id=virtual_file_id;
form.virtual_file_download_secret=virtual_file_download_secret;
virtualFileCom.serveVirtualFile();
 --->
<cffunction name="serveVirtualFile" localmode="modern" access="public">
	<cfargument name="forceDownload" type="boolean" required="no" default="#false#">
	<cfscript> 
	form.virtual_file_id=application.zcore.functions.zso(form, 'virtual_file_id', true);
	// we don't need to validate on secure currently, since we pull the data anyway
	// form.virtual_file_secure=application.zcore.functions.zso(form, 'virtual_file_secure', true);
	form.virtual_file_download_secret=application.zcore.functions.zso(form, 'virtual_file_download_secret');
	rs=getFileById(form.virtual_file_id);
	if(not rs.success) {
		application.zcore.functions.z404('File not found (##' & virtual_file_id & ')');
	}
	if(not hasFileAccess(rs.data)){
		application.zcore.status.setStatus(request.zsid, "You must login with an account that has access to view this file", form, true);
		application.zcore.functions.zRedirect("/z/user/preference/index?zsid=#request.zsid#&redirectOnLogin=#urlencodedformat(request.zos.originalURL)#");
	} 

	// we don't want someone to bulk download our sequential file ids, so we include a long hash in our public urls that must be verified.
	if(compare(form.virtual_file_download_secret, rs.data.virtual_file_download_secret) NEQ 0){
		application.zcore.functions.z404("Invalid download secret hash provided");
	}

	downloadLink = getRelativeFilePath(rs.data); 
	ext = application.zcore.functions.zGetFileExt( downloadLink );

	if(not arguments.forceDownload){
		if ( ext EQ 'jpg' OR ext EQ 'jpeg' ) {
			type = 'image/jpeg';
		} else if ( ext EQ 'png' ) {
			type = 'image/png';
		} else if ( ext EQ 'gif' ) {
			type = 'image/gif';
		}else{
			type="";
		}
		if ( type NEQ '' ) {
			application.zcore.functions.zheader( 'Content-Type', type );
		}
	}
	if(variables.config.storageMethod EQ "localFilesystem"){
		if(arguments.forceDownload){
			application.zcore.functions.zheader( 'Content-Disposition', 'attachment; filename=' & rs.data.virtual_file_name );
		}else{
			application.zcore.functions.zheader( 'Content-Disposition', 'inline; filename=' & rs.data.virtual_file_name );
		}
		application.zcore.functions.zXSendFile( downloadLink );
	}else{
		if(variables.config.exposeCloudURLs and rs.data.virtual_file_secure EQ 0){
			throw("not implemented yet");
			downloadLink = getAbsoluteFilePath(rs.data); 
			application.zcore.functions.zRedirect(downloadLink);
		}else{
			throw("Haven't implemented proxy for cloud yet.");
		}
	}
	</cfscript>
</cffunction>

<cffunction name="downloadVirtualFile" localmode="modern" access="public">
	<cfscript>
	serveVirtualFile(true);
	</cfscript>
</cffunction>

<!--- virtualFileCom.downloadVirtualFileByPath(); --->
<cffunction name="downloadVirtualFileByPath" localmode="modern" access="public">
	<cfscript>
	rs=getFileByPath(form.virtual_file_path);
	if(rs.success){
		form.virtual_file_id=rs.data.virtual_file_id;
		downloadVirtualFile();
	}else{
		application.zcore.functions.z404(rs.errorMessage);
	}
	</cfscript>
</cffunction>
	

<cffunction name="getRequestedURL" localmode="modern" access="private">
	<cfscript>
	return request.zos.originalURL;
	</cfscript>
</cffunction>


<!--- virtualFileCom.fileExistsById(virtual_file_id); --->
<cffunction name="fileExistsById" localmode="modern" access="public">
	<cfargument name="virtual_file_id" type="string" required="yes">
	<cfscript>
	rs=getFileById(arguments.virtual_file_id);
	return rs.success;
	</cfscript>
</cffunction>

<!--- virtualFileCom.fileExistsByPath(virtual_file_path); --->
<cffunction name="fileExistsByPath" localmode="modern" access="public">
	<cfargument name="virtual_file_path" type="string" required="yes">
	<cfscript>
	rs=getFileById(arguments.virtual_file_path);
	return rs.success;
	</cfscript>
</cffunction>
	
<!--- 
rs=virtualFileCom.getFileById(virtual_file_id);
if(not rs.success){
	throw("Failed to rename file: "&rs.errorMessage);
}
rs.data;
 --->
<cffunction name="getFileById" localmode="modern" access="public">
	<cfargument name="virtual_file_id" type="string" required="yes">
	<cfscript>
	db = request.zos.queryObject; 
	if(variables.config.enableCache NEQ "disabled" and variables.config.enableCache NEQ "folders"){
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache.fileDataStruct;
		if(structkeyexists(ts, arguments.virtual_file_id)){
			return {success:true, data:ts[arguments.virtual_file_id]};
		}
	}else{
		db.sql = 'SELECT *
		FROM #db.table( 'virtual_file', request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( request.zos.globals.id )#
		AND virtual_file_id = #db.param( arguments.virtual_file_id )#
		AND virtual_file_deleted = #db.param( 0 )#';
		qFile = db.execute( 'File' );
		for(row in qFile){
			return {success:true, data:row};
		}
	}
	return {success:false, errorMessage:"File ID " & arguments.virtual_file_id &" doesn't exist"}; 
	</cfscript>
</cffunction>

<cffunction name="getFileByPath" localmode="modern" access="public">
	<cfargument name="virtual_file_path" type="string" required="yes">
	<cfscript>
	if(right(arguments.virtual_file_path, 1) EQ "/"){
		arguments.virtual_file_path=left(arguments.virtual_file_path, len(arguments.virtual_file_path)-1);
	}
	db = request.zos.queryObject;
	if(variables.config.enableCache NEQ "disabled" and variables.config.enableCache NEQ "folders"){
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
		tempPath=variables.config.publicPathPrefix&arguments.virtual_file_path;
		if(structkeyexists(ts.filePathStruct, tempPath)){
			virtual_file_id=ts.filePathStruct[tempPath];
			return {success:true, data:ts.fileDataStruct[virtual_file_id]};
		}
	}else{
		db.sql = 'SELECT *
		FROM #db.table( 'virtual_file', request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( request.zos.globals.id )#
		AND virtual_file_path = #db.param( arguments.virtual_file_path )#
		AND virtual_file_deleted = #db.param( 0 )#';
		qFile = db.execute( 'File' );
		for(row in qFile){
			return {success:true, data:row};
		}
	}
	return {success:false, errorMessage:"File Path " & arguments.virtual_file_path &" doesn't exist"}; 
	</cfscript>
</cffunction>
 
<!--- 
ts={
	data:{
		virtual_file_name:"Name",
		virtual_file_path:"path/to/Name",
		virtual_file_secure:0,
		virtual_file_user_group_list:"",
		virtual_file_image_width:0, 
		virtual_file_image_height:0,
		virtual_file_size:0,
		virtual_file_last_modified_datetime:request.zos.mysqlnow
	}
}
rs=virtualFileCom.updateFile(ts);
if(rs.success EQ false){
	throw("Failed to update file");
} 
 --->
<cffunction name="updateFile" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db = request.zos.queryObject;
	tempPath=getDirectoryFromPath(rs.data.virtual_file_path); 
	if(tempPath EQ "/"){
		tempPath="";
	}
	if(tempPath EQ ""){
		newFolderId=0;
	}else{
		rs=getFolderByPath(tempPath);
		if(not rs.success){
			return rs;
		}
		newFolderId=rs.data.virtual_folder_id;
	}
	secureChanged=false;
	if(rs.data.virtual_file_secure NEQ ss.data.virtual_file_secure or rs.data.virtual_file_user_group_list NEQ ss.data.virtual_file_user_group_list){
		secureChanged=true;
	}
	newPath=tempPath&ss.data.virtual_file_name;

	transaction action="begin"{
		try{   
			db.sql = 'UPDATE #db.table( 'virtual_file', request.zos.zcoreDatasource )#
			SET virtual_file_name = #db.param( ss.data.virtual_file_name )#,
			virtual_file_path = #db.param( newPath )#,
			virtual_file_folder_id=#db.param(newFolderId)#,
			virtual_file_updated_datetime = #db.param( request.zos.mysqlnow )#';
			if(secureChanged){
				db.sql&=" ,virtual_file_secure=#db.param(ss.data.virtual_file_secure)#,
				virtual_file_user_group_list=#db.param(ss.data.virtual_file_user_group_list)# ";
			}
			db.sql&='
			WHERE site_id = #db.param( request.zos.globals.id )#
			AND virtual_file_id = #db.param( ss.data.virtual_file_id )# and 
			virtual_file_deleted=#db.param(0)# ';

			db.execute( 'qUpdate' );

			if(variables.config.storageMethod EQ "localFilesystem"){
				oldPath=getAbsoluteFilePath(rs.data);
				newPath=getAbsoluteFilePath(ss.data);
				if(oldPath NEQ newPath){
					// only rename when path changed
					result=application.zcore.functions.zRenameFile(oldPath, newPath);
					if(not result){
						return {success:false, errorMessage:"Failed to rename file."};
					}
				}
			}else{
				throw("Not implemented"); // do this async
			} 
			transaction action="commit";
		}catch(Any e2){
			// transaction failed.
			try{
				transaction action="rollback";
			}catch(Any e3){
				// ignore rollback failures
			}
			rethrow;
		}
	}

	if(variables.config.enableCache NEQ "disabled" and variables.config.enableCache NEQ "folders"){
		// add file to new location
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
		fileStruct=ts.fileDataStruct[arguments.virtual_file_id];
		oldPath=getDirectoryFromPath(fileStruct.virtual_file_path);
		if(oldPath EQ "/"){
			oldPath="";
		}else{
			oldPath=left(oldPath, len(oldPath)-1);
		}
		fileStruct.virtual_file_path=newPath;
		fileStruct.virtual_file_folder_id=newFolderId;
		fileStruct.virtual_file_name=ss.data.virtual_file_name;
		fileStruct.virtual_file_updated_datetime=request.zos.mysqlnow;
		newPath=getDirectoryFromPath(fileStruct.virtual_file_path);
		if(newPath EQ "/"){
			newPath="";
		}else{
			newPath=left(newPath, len(newPath)-1);
		}
		ts.fileDataStruct[fileStruct.virtual_file_id]=fileStruct;
		ts.filePathStruct[fileStruct.virtual_file_path]=fileStruct.virtual_file_id;
		ts.treeStruct[variables.config.publicPathPrefix&newPath].fileStruct[fileStruct.virtual_file_id]=true;


		// delete file from old location
		structdelete(ts.fileDataStruct, fileStruct.virtual_file_id);
		structdelete(ts.filePathStruct, oldPath);
		structDelete(ts.treeStruct[variables.config.publicPathPrefix&oldPath].fileStruct, fileStruct.virtual_file_id);
	}

	if ( NOT virtualFile.success ) {
		application.zcore.template.fail( 'Failed to update/rename virtual file record' );
	} else {
		return true;
	}
	</cfscript>
</cffunction>

<!--- 
TODO: we don't need this for now
<cffunction name="moveVirtualFile" localmode="modern" access="public">
	<cfargument name="virtual_file_id" type="string" required="yes">
	<cfargument name="virtual_folder_id" type="string" required="yes">
	<cfscript> 
	db = request.zos.queryObject;
	db.sql = 'UPDATE #db.table( 'virtual_file', request.zos.zcoreDatasource )#
		SET virtual_file_folder_id = #db.param( arguments.virtual_folder_id )#,
			virtual_file_updated_datetime = #db.param( request.zos.mysqlnow )#
		WHERE site_id = #db.param( request.zos.globals.id )#
			AND virtual_file_id = #db.param( arguments.virtual_file_id )# and 
			virtual_file_deleted=#db.param(0)#';

	result = db.execute( 'virtualFile' );
	return result;
	</cfscript>
</cffunction>
 --->

<!--- 
rs=virtualFileCom.deleteFile(virtual_file_id);
if(not rs.success){
	throw("Failed to delete folder: "&rs.errorMessage);
} 
--->
<cffunction name="deleteFile" localmode="modern" access="public" hint="Warning: This function will recursively delete the file and all files/files within it.">
	<cfargument name="virtual_file_id" type="string" required="yes">
	<cfscript>
	virtual_file_id = arguments.virtual_file_id;

	db = request.zos.queryObject;
	rs=getFileById(virtual_file_id);
	if(not rs.success){
		return rs;
	}
	if(not hasFileAccess(rs.data)){
		return {success:false, errorMessage:"You don't have access to delete this file"};
	}

	
	transaction action="begin"{
		try{   
			db.sql = 'UPDATE #db.table( 'virtual_file', request.zos.zcoreDatasource )#
				SET virtual_file_deleted = #db.param( 1 )#,
					virtual_file_updated_datetime = #db.param( request.zos.mysqlnow )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND virtual_file_id = #db.param( virtual_file_id )# and 
					virtual_file_deleted=#db.param(0)#';

			db.execute('qUpdate');

			if(variables.config.storageMethod EQ "localFilesystem"){
				securePath=variables.config.securePathPrefix&ts.struct.virtual_file_path; 
				publicPath=variables.config.publicPathPrefix&ts.struct.virtual_file_path; 
				if(rs.struct.virtual_file_secure EQ 1){
					application.zcore.functions.zDeleteFile(securePath);
				}else{
					application.zcore.functions.zDeleteFile(publicPath);
				}
			}else{
				throw("Not implemented"); // better if this was async, and on cronjob.  That's why we are using update instead of delete query above.
			}
			transaction action="commit";
		}catch(Any e2){
			// transaction failed.
			try{
				transaction action="rollback";
			}catch(Any e3){
				// ignore rollback failures
			}
			rethrow;
		}
	}

	if(variables.config.enableCache NEQ "disabled" and variables.config.enableCache NEQ "folders"){
		ts=application.siteStruct[request.zos.globals.id].virtualFileCache;
		path=getDirectoryFromPath(rs.data.virtual_file_path); 
		if(path EQ "/"){
			path="";
		}else{
			path=left(path, len(path)-1);
		}
		structdelete(ts.fileDataStruct, rs.data.virtual_file_id);
		structdelete(ts.filePathStruct, path);
		structDelete(ts.treeStruct[variables.config.publicPathPrefix&path].fileStruct, rs.data.virtual_file_id);
	}
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="getAbsoluteFilePath" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(variables.config.storageMethod EQ "localFilesystem"){
		if(row.virtual_file_secure EQ 1){ 
			path=variables.config.securePathPrefix&row.virtual_file_path; 
		}else{
			path=variables.config.publicPathPrefix&row.virtual_file_path; 
		}
	}else{
		throw("Not implemented");
	}
	return path;
	</cfscript>
</cffunction>

<cffunction name="getRelativeFilePath" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(variables.config.storageMethod EQ "localFilesystem"){
		if(row.virtual_file_secure EQ 1){ 
			path=variables.config.secureRootRelativePath&row.virtual_file_path; 
		}else{
			path=variables.config.publicRootRelativePath&row.virtual_file_path; 
		}
	}else{
		throw("Not implemented");
	}
	return path;
	</cfscript>
</cffunction>

<cffunction name="getAbsoluteFolderPath" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(variables.config.storageMethod EQ "localFilesystem"){
		if(row.virtual_folder_secure EQ 1){ 
			path=variables.config.securePathPrefix&row.virtual_folder_path; 
		}else{
			path=variables.config.publicPathPrefix&row.virtual_folder_path; 
		}
	}else{
		throw("Not implemented");
	}
	return path;
	</cfscript>
</cffunction>

<cffunction name="getRelativeFolderPath" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(variables.config.storageMethod EQ "localFilesystem"){
		if(row.virtual_folder_secure EQ 1){ 
			path=variables.config.secureRootRelativePath&row.virtual_folder_path; 
		}else{
			path=variables.config.publicRootRelativePath&row.virtual_folder_path; 
		}
	}else{
		throw("Not implemented");
	}
	return path;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
