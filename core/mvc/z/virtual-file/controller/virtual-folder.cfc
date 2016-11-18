<cfcomponent>
<cfoutput>

<cffunction name="getVirtualFolderById" localmode="modern" access="public">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfscript>
		folderId = arguments.folderId;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_folder', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_id = #db.param( folderId )#
				AND virtual_folder_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';

		virtualFolder = db.execute( 'virtualFolder' );

		if ( virtualFolder.recordcount GT 0 ) {
			variables.data = virtualFolder;

			this.isFolderOnDisk( virtualFolder.virtual_folder_path, virtualFolder.virtual_folder_secure );

			return virtualFolder;
		} else {
			application.zcore.template.fail( 'Folder ID ' & folderId & ' does not exist' );
		}
	</cfscript>
</cffunction>

<cffunction name="getVirtualFolderByPath" localmode="modern" access="public">
	<cfargument name="folderPath" type="string" required="yes">
	<cfscript>
		folderPath = arguments.folderPath;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_folder', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_path = #db.param( folderPath )#
				AND virtual_folder_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';

		virtualFolder = db.execute( 'virtualFolder' );

		if ( virtualFolder.recordcount GT 0 ) {
			variables.data = virtualFolder;

			this.isFolderOnDisk( virtualFolder.virtual_folder_path, virtualFolder.virtual_folder_secure );

			return virtualFolder;
		} else {
			application.zcore.template.fail( 'Folder Path ' & folderPath & ' does not exist' );
		}
	</cfscript>
</cffunction>

<cffunction name="virtualFolderIdExists" localmode="modern" access="public">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfargument name="storeResult" type="boolean" required="no" default="false">
	<cfscript>
		folderId = arguments.folderId;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_folder', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_id = #db.param( folderId )#
				AND virtual_folder_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';

		virtualFolder = db.execute( 'virtualFolder' );

		if ( virtualFolder.recordcount GT 0 ) {
			if ( storeResult ) {
				variables.data = virtualFolder;
			}

			this.isFolderOnDisk( virtualFolder.virtual_folder_path, virtualFolder.virtual_folder_secure );

			return true;
		} else {
			return false;
		}
	</cfscript>
</cffunction>

<cffunction name="virtualFolderExists" localmode="modern" access="public">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfscript>
		folderId = arguments.folderId;

		return this.virtualFolderIdExists( folderId );
	</cfscript>
</cffunction>

<cffunction name="getFoldersInFolder" localmode="modern" access="public">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfargument name="orderDirection" type="string" required="no" default="ASC">
	<cfscript>
		folderId       = arguments.folderId;
		orderDirection = arguments.orderDirection;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_folder', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_parent_id = #db.param( folderId )#
				AND virtual_folder_deleted = #db.param( 0 )#
			ORDER BY virtual_folder_name';

		if ( orderDirection EQ 'DESC' ) {
			db.sql &= ' DESC';
		} else {
			db.sql &= ' ASC';
		}

		virtualFolders = db.execute( 'virtualFolders' );

		if ( virtualFolders.recordcount GT 0 ) {
			variables.data = virtualFolders;

			return virtualFolders;
		} else {
			return false;
		}
	</cfscript>
</cffunction>

<cffunction name="createVirtualFolder" localmode="modern" access="public">
	<cfargument name="folderName" type="string" required="yes">
	<cfargument name="folderPath" type="string" required="yes">
	<cfargument name="folderParentId" type="numeric" required="no" default="0">
	<cfargument name="folderSecure" type="boolean" required="no" default="false">
	<cfscript>
		folderName     = arguments.folderName;
		folderPath     = arguments.folderPath;
		folderParentId = arguments.folderParentId;
		folderSecure   = arguments.folderSecure;

		if ( folderSecure EQ true ) {
			folderSecure = 1;
		} else {
			folderSecure = 0;
		}

		this.isFolderOnDisk( virtualFolder.virtual_folder_path, virtualFolder.virtual_folder_secure );

		db = request.zos.queryObject;

		db.sql = 'INSERT INTO #db.table( 'virtual_folder', request.zos.globals.datasource )#
			( virtual_folder_id, site_id, virtual_folder_parent_id, virtual_folder_name, virtual_folder_path, virtual_folder_secure, virtual_folder_deleted, virtual_folder_updated_datetime )
			VALUES (
				NULL,
				#db.param( request.zos.globals.id )#,
				#db.param( folderParentId )#,
				#db.param( folderName )#,
				#db.param( folderPath )#,
				#db.param( folderSecure )#,
				#db.param( 0 )#,
				#db.param( request.zos.mysqlnow )#
			)';

		virtual_folder_id = db.execute( 'virtual_folder_id' );

		if ( NOT virtual_folder_id ) {
			application.zcore.template.fail( 'Failed to insert virtual folder record' );
		} else {
			return virtual_folder_id;
		}
	</cfscript>
</cffunction>

<cffunction name="renameVirtualFolder" localmode="modern" access="public">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfargument name="newFolderName" type="string" required="yes">
	<cfscript>
		folderId      = arguments.folderId;
		newFolderName = arguments.newFolderName;

		db = request.zos.queryObject;

		db.sql = 'UPDATE #db.table( 'virtual_folder', request.zos.globals.datasource )#
			SET virtual_folder_name = #db.param( newFolderName )#,
				virtual_folder_updated_datetime = #db.param( request.zos.mysqlnow )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_id = #db.param( folderId )#';

		virtualFolder = db.execute( 'virtualFolder' );

		if ( NOT virtualFolder.success ) {
			application.zcore.template.fail( 'Failed to update/rename virtual folder record' );
		} else {
			return true;
		}
	</cfscript>
</cffunction>

<cffunction name="deleteVirtualFolder" localmode="modern" access="public">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfscript>
		folderId = arguments.folderId;

		db = request.zos.queryObject;

		db.sql = 'UPDATE #db.table( 'virtual_folder', request.zos.globals.datasource )#
			SET virtual_folder_deleted = #db.param( 1 )#,
				virtual_folder_updated_datetime = #db.param( request.zos.mysqlnow )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_folder_id = #db.param( folderId )#';

		virtualFolder = db.execute( 'virtualFolder' );

		if ( NOT virtualFolder.success ) {
			application.zcore.template.fail( 'Failed to delete virtual folder record' );
		} else {
			return true;
		}
	</cfscript>
</cffunction>

<cffunction name="getFullFolderPath" localmode="modern" access="public">
	<cfargument name="folderPath" type="string" required="yes">
	<cfargument name="folderSecure" type="numeric" required="no" default="0">
	<cfscript>
		folderPath   = arguments.folderPath;
		folderSecure = arguments.folderSecure;

		if ( folderSecure EQ 1 ) {
			fullFolderPath = request.zos.globals.privatehomedir & 'zuploadsecure/user/' & folderPath & '/';
		} else {
			fullFolderPath = request.zos.globals.privatehomedir & 'zupload/user/' & folderPath & '/';
		}

		return fullFolderPath;
	</cfscript>
</cffunction>

<cffunction name="isFolderOnDisk" localmode="modern" access="public">
	<cfargument name="folderPath" type="string" required="yes">
	<cfargument name="folderSecure" type="numeric" required="no" default="0">
	<cfscript>
		folderPath   = arguments.folderPath;
		folderSecure = arguments.folderSecure;

		fullFolderPath = this.getFullFolderPath( folderPath, folderSecure );

		// Check to make sure that the virtual folder actually exists on disk.
		if ( NOT directoryExists( fullFolderPath ) ) {
			// Not a good thing that it isn't deleted and doesn't exist on disk.
			if ( request.zos.istestserver ) {
				// Simply send a 404 error if on test server.
				application.zcore.functions.z404( 'Virtual folder not found on disk (' & fullFolderPath & ')' );
			} else {
				// Log an error silently and throw an error on live server.
				savecontent variable="e"{
					echo( '<h2>Virtual folder not found on disk</h2>' );
					echo( '<p>' & fullFolderPath & '</p>' );
				}

				ts = {
					type: "Custom",
					errorHTML: e,
					scriptName: '/z/virtual-file/controller/virtual-folder.cfc',
					url: request.zos.originalURL,
					exceptionMessage: 'Virtual folder not found on disk (' & fullFolderPath & ')'
				};

				application.zcore.functions.zLogError( ts );

				throw( 'Folder not found' );
			}
		}
	</cfscript>
</cffunction>

<cffunction name="authenticateSecureRequests" localmode="modern" access="private">
	<cfscript>
		if ( structKeyExists( variables.data, 'virtual_folder_secure' ) AND variables.data.virtual_folder_secure EQ 1 ) {
			if ( NOT application.zcore.user.checkServerAccess() ) {
				application.zcore.status.setStatus( request.zsid, 'You must first login to view this file.', form, true );
				application.zcore.functions.zRedirect( '/z/admin/admin-home/index?zsid=' & request.zsid );
			}
		}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
