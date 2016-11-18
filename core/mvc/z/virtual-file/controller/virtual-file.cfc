<cfcomponent>
<cfoutput>
<cffunction name="serveVirtualFile" localmode="modern" access="public">
	<cfscript>
		// Contains the current requested URL (i.e. '/z/-vf.123456').
		variables.requestedURL = this.getRequestedURL();

		// Contains the database information about the requested virtual file.
		// By setting the second parameter of an 'exists' function to true, you
		// can have that data result stored here automatically. This prevents
		// having to make a second query for the same information.
		variables.data = {};

		// Strip out the fileId from the requestedURL.
		fileId = this.getFileIdFromURL();

		// Make sure the fileId exists in the database.
		if ( this.virtualFileIdExists( fileId, true ) ) {
			// Authenticate prior to serving the file if marked as secure.
			this.authenticateSecureRequests();

			fullFilePath = this.getFullFilePath( variables.data.virtual_file_path, variables.data.virtual_file_secure );

			fullFilePath = replace( fullFilePath, request.zos.globals.privatehomedir, '/' );

			ext = application.zcore.functions.zGetFileExt( fullFilePath );

			type = '';

			if ( ext EQ 'jpg' OR ext EQ 'jpeg' ) {
				type = 'image/jpeg';
			} else if ( ext EQ 'png' ) {
				type = 'image/png';
			} else if ( ext EQ 'gif' ) {
				type = 'image/gif';
			}

			if ( type NEQ '' ) {
				application.zcore.functions.zheader( 'Content-Type', type );
			}

			application.zcore.functions.zheader( 'Content-Disposition', 'inline; filename=' & variables.data.virtual_file_name );

			application.zcore.functions.zXSendFile( fullFilePath );
			application.zcore.functions.zabort();

		} else {
			// The fileId does not exist in the database, send 404.
			application.zcore.functions.z404( 'File not found (##' & fileId & ')' );
		}
	</cfscript>
</cffunction>

<cffunction name="downloadVirtualFile" localmode="modern" access="public">
	<cfscript>
		// Contains the current requested URL (i.e. '/z/-df.123456').
		variables.requestedURL = this.getRequestedURL();

		// Contains the database information about the requested virtual file.
		// By setting the second parameter of an 'exists' function to true, you
		// can have that data result stored here automatically. This prevents
		// having to make a second query for the same information.
		variables.data = {};

		// Strip out the fileId from the requestedURL.
		fileId = this.getFileIdFromURL();

		// Make sure the fileId exists in the database.
		if ( this.virtualFileIdExists( fileId, true ) ) {
			// Authenticate prior to downloading the file if marked as secure.
			this.authenticateSecureRequests();

			fullFilePath = this.getFullFilePath( variables.data.virtual_file_path, variables.data.virtual_file_secure );

			fullFilePath = replace( fullFilePath, request.zos.globals.privatehomedir, '/' );

			form.fp = fullFilePath;

			download = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.misc.controller.download' );
			download.index();
		} else {
			// The fileId does not exist in the database, send 404.
			application.zcore.functions.z404( 'File not found (##' & fileId & ')' );
		}
	</cfscript>
</cffunction>

<cffunction name="getRequestedURL" localmode="modern" access="private">
	<cfscript>
		return request.zos.originalURL;
	</cfscript>
</cffunction>

<cffunction name="getFileIdFromURL" localmode="modern" access="public">
	<cfscript>
		// When serving files: /z/-vf.123456
		// When downloading files: /z/-df.123456
		fileId = reMatch( '[\d]+$', variables.requestedURL );

		if ( arrayIsEmpty( fileId ) ) {
			application.zcore.template.fail( 'Invalid virtual file request' );
		} else {
			return fileId[ 1 ];
		}
	</cfscript>
</cffunction>

<cffunction name="virtualFileIdExists" localmode="modern" access="public">
	<cfargument name="fileId" type="numeric" required="yes">
	<cfargument name="storeResult" type="boolean" required="no" default="false">
	<cfscript>
		fileId      = arguments.fileId;
		storeResult = arguments.storeResult;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_file', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_id = #db.param( fileId )#
				AND virtual_file_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';

		virtualFile = db.execute( 'virtualFile' );

		if ( virtualFile.recordcount GT 0 ) {
			if ( storeResult ) {
				variables.data = virtualFile;
			}

			this.isFileOnDisk( virtualFile.virtual_file_path, virtualFile.virtual_file_secure );

			return true;
		} else {
			return false;
		}
	</cfscript>
</cffunction>

<cffunction name="virtualFileNameExists" localmode="modern" access="public">
	<cfargument name="fileName" type="string" required="yes">
	<cfargument name="folderId" type="numeric" required="no" default="0">
	<cfargument name="storeResult" type="boolean" required="no" default="false">
	<cfscript>
		fileName    = arguments.fileName;
		folderId    = arguments.folderId;
		storeResult = arguments.storeResult;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_file', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_name = #db.param( fileName )#
				AND virtual_file_folder_id = #db.param( folderId )#
				AND virtual_file_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';

		virtualFile = db.execute( 'virtualFile' );

		if ( virtualFile.recordcount GT 0 ) {
			if ( storeResult ) {
				variables.data = virtualFile;
			}

			this.isFileOnDisk( virtualFile.virtual_file_path, virtualFile.virtual_file_secure );

			return true;
		} else {
			return false;
		}
	</cfscript>
</cffunction>

<cffunction name="virtualFileNameExistsInFolder" localmode="modern" access="public">
	<cfargument name="fileName" type="string" required="yes">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfargument name="storeResult" type="boolean" required="no" default="false">
	<cfscript>
		fileName    = arguments.fileName;
		folderId    = arguments.folderId;
		storeResult = arguments.storeResult;

		return this.virtualFileNameExists( fileName, folderId, storeResult );
	</cfscript>
</cffunction>

<cffunction name="getVirtualFileById" localmode="modern" access="public">
	<cfargument name="fileId" type="numeric" required="yes">
	<cfscript>
		fileId = arguments.fileId;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_file', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_id = #db.param( fileId )#
				AND virtual_file_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';

		virtualFile = db.execute( 'virtualFile' );

		if ( virtualFile.recordcount GT 0 ) {
			variables.data = virtualFile;

			this.isFileOnDisk( virtualFile.virtual_file_path, virtualFile.virtual_file_secure );

			return virtualFile;
		} else {
			return false;
		}
	</cfscript>
</cffunction>

<cffunction name="getFilesInFolder" localmode="modern" access="public">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfargument name="orderBy" type="string" required="no" default="name">
	<cfargument name="orderDirection" type="string" required="no" default="ASC">
	<cfscript>
		folderId       = arguments.folderId;
		orderBy        = arguments.orderBy;
		orderDirection = arguments.orderDirection;

		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'virtual_file', request.zos.globals.datasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_folder_id = #db.param( folderId )#
				AND virtual_file_deleted = #db.param( 0 )#';

		if ( orderBy EQ 'date' ) {
			db.sql &= ' ORDER BY virtual_file_updated_datetime';

			if ( orderDirection EQ 'DESC' ) {
				db.sql &= ' DESC';
			} else {
				db.sql &= ' ASC';
			}
		} else {
			db.sql &= ' ORDER BY virtual_file_name';

			if ( orderDirection EQ 'DESC' ) {
				db.sql &= ' DESC';
			} else {
				db.sql &= ' ASC';
			}
		}

		virtualFiles = db.execute( 'virtualFiles' );

		if ( virtualFiles.recordcount GT 0 ) {
			variables.data = virtualFiles;

			return virtualFiles;
		} else {
			return false;
		}
	</cfscript>
</cffunction>

<cffunction name="createVirtualFile" localmode="modern" access="public">
	<cfargument name="fileName" type="string" required="yes">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="fileSecure" type="boolean" required="no" default="false">
	<cfscript>
		fileName   = arguments.fileName;
		folderId   = arguments.folderId;
		filePath   = arguments.filePath;
		fileSecure = arguments.fileSecure;

		if ( fileSecure EQ true ) {
			fileSecure = 1;
		} else {
			fileSecure = 0;
		}

		this.isFileOnDisk( filePath, fileSecure );

		db = request.zos.queryObject;

		db.sql = 'INSERT INTO #db.table( 'virtual_file', request.zos.globals.datasource )#
			( virtual_file_id, site_id, virtual_file_name, virtual_file_path, virtual_file_folder_id, virtual_file_secure, virtual_file_deleted, virtual_file_updated_datetime )
			VALUES (
				NULL,
				#db.param( request.zos.globals.id )#,
				#db.param( fileName )#,
				#db.param( filePath )#,
				#db.param( folderId )#,
				#db.param( fileSecure )#,
				#db.param( 0 )#,
				#db.param( request.zos.mysqlnow )#
			)';

		virtual_file_id = db.execute( 'virtual_file_id' );

		if ( NOT virtual_file_id ) {
			application.zcore.template.fail( 'Failed to insert virtual file record' );
		} else {
			return virtual_file_id;
		}
	</cfscript>
</cffunction>

<cffunction name="createVirtualImage" localmode="modern" access="public">
	<cfargument name="imageName" type="string" required="yes">
	<cfargument name="folderId" type="numeric" required="yes">
	<cfargument name="imagePath" type="string" required="yes">
	<cfargument name="imageWidth" type="numeric" required="yes">
	<cfargument name="imageHeight" type="numeric" required="yes">
	<cfargument name="imageSecure" type="boolean" required="no" default="false">
	<cfscript>
		imageName   = arguments.imageName;
		folderId    = arguments.folderId;
		imagePath   = arguments.imagePath;
		imageWidth  = arguments.imageWidth;
		imageHeight = arguments.imageHeight;
		imageSecure = arguments.imageSecure;

		if ( imageSecure EQ true ) {
			imageSecure = 1;
		} else {
			imageSecure = 0;
		}

		this.isFileOnDisk( imagePath, imageSecure );

		db = request.zos.queryObject;

		db.sql = 'INSERT INTO #db.table( 'virtual_file', request.zos.globals.datasource )#
			( virtual_file_id, site_id, virtual_file_name, virtual_file_path, virtual_file_image_width, virtual_file_image_height, virtual_file_folder_id, virtual_file_secure, virtual_file_deleted, virtual_file_updated_datetime )
			VALUES (
				NULL,
				#db.param( request.zos.globals.id )#,
				#db.param( imageName )#,
				#db.param( imagePath )#,
				#db.param( imageWidth )#,
				#db.param( imageHeight )#,
				#db.param( folderId )#,
				#db.param( imageSecure )#,
				#db.param( 0 )#,
				#db.param( request.zos.mysqlnow )#
			)';

		virtual_file_id = db.execute( 'virtual_file_id' );

		if ( NOT virtual_file_id ) {
			application.zcore.template.fail( 'Failed to insert virtual image file record' );
		} else {
			return virtual_file_id;
		}
	</cfscript>
</cffunction>

<cffunction name="renameVirtualFile" localmode="modern" access="public">
	<cfargument name="fileId" type="numeric" required="yes">
	<cfargument name="newFileName" type="string" required="yes">
	<cfscript>
		fileId      = arguments.fileId;
		newFileName = arguments.newFileName;

		db = request.zos.queryObject;

		db.sql = 'UPDATE #db.table( 'virtual_file', request.zos.globals.datasource )#
			SET virtual_file_name = #db.param( newFileName )#,
				virtual_file_updated_datetime = #db.param( request.zos.mysqlnow )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_id = #db.param( fileId )#';

		virtualFile = db.execute( 'virtualFile' );

		if ( NOT virtualFile.success ) {
			application.zcore.template.fail( 'Failed to update/rename virtual file record' );
		} else {
			return true;
		}
	</cfscript>
</cffunction>

<cffunction name="moveVirtualFile" localmode="modern" access="public">
	<cfargument name="fileId" type="numeric" required="yes">
	<cfargument name="newFolderId" type="numeric" required="yes">
	<cfscript>
		fileId      = arguments.fileId;
		newFolderId = arguments.newFolderId;

		db = request.zos.queryObject;

		db.sql = 'UPDATE #db.table( 'virtual_file', request.zos.globals.datasource )#
			SET virtual_file_folder_id = #db.param( newFolderId )#,
				virtual_file_updated_datetime = #db.param( request.zos.mysqlnow )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_id = #db.param( fileId )#';

		virtualFile = db.execute( 'virtualFile' );

		if ( NOT virtualFile.success ) {
			application.zcore.template.fail( 'Failed to update/move virtual file record' );
		} else {
			return true;
		}
	</cfscript>
</cffunction>

<cffunction name="moveVirtualFileToFolder" localmode="modern" access="public">
	<cfargument name="fileId" type="numeric" required="yes">
	<cfargument name="newFolderId" type="numeric" required="yes">
	<cfscript>
		fileId      = arguments.fileId;
		newFolderId = arguments.fileId;

		return this.moveVirtualFile( fileId, newFolderId );
	</cfscript>
</cffunction>

<cffunction name="deleteVirtualFile" localmode="modern" access="public">
	<cfargument name="fileId" type="numeric" required="yes">
	<cfscript>
		fileId = arguments.fileId;

		db = request.zos.queryObject;

		db.sql = 'UPDATE #db.table( 'virtual_file', request.zos.globals.datasource )#
			SET virtual_file_deleted = #db.param( 1 )#,
				virtual_file_updated_datetime = #db.param( request.zos.mysqlnow )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND virtual_file_id = #db.param( fileId )#';

		virtualFile = db.execute( 'virtualFile' );

		if ( NOT virtualFile.success ) {
			application.zcore.template.fail( 'Failed to delete virtual file record' );
		} else {
			return true;
		}
	</cfscript>
</cffunction>

<cffunction name="getFullFilePath" localmode="modern" access="public">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="fileSecure" type="numeric" required="no" default="0">
	<cfscript>
		filePath   = arguments.filePath;
		fileSecure = arguments.fileSecure;

		if ( fileSecure EQ 1 ) {
			fullFilePath = request.zos.globals.privatehomedir & 'zuploadsecure/user/' & filePath;
		} else {
			fullFilePath = request.zos.globals.privatehomedir & 'zupload/user/' & filePath;
		}

		return fullFilePath;
	</cfscript>
</cffunction>

<cffunction name="isFileOnDisk" localmode="modern" access="public">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="fileSecure" type="numeric" required="no" default="0">
	<cfscript>
		filePath   = arguments.filePath;
		fileSecure = arguments.fileSecure;

		fullFilePath = this.getFullFilePath( filePath, fileSecure );

		// Check to make sure that the virtual file actually exists on disk.
		if ( NOT fileExists( fullFilePath ) ) {
			// Not a good thing that it isn't deleted and doesn't exist on disk.
			if ( request.zos.istestserver ) {
				// Simply send a 404 error if on test server.
				application.zcore.functions.z404( 'Virtual file not found on disk (' & fullFilePath & ')' );
			} else {
				// Log an error silently and throw an error on live server.
				savecontent variable="e"{
					echo( '<h2>Virtual file not found on disk</h2>' );
					echo( '<p>' & fullFilePath & '</p>' );
				}

				ts = {
					type: "Custom",
					errorHTML: e,
					scriptName: '/z/virtual-file/controller/virtual-file.cfc',
					url: request.zos.originalURL,
					exceptionMessage: 'Virtual file not found on disk (' & fullFilePath & ')'
				};

				application.zcore.functions.zLogError( ts );

				throw( 'File not found' );
			}
		}
	</cfscript>
</cffunction>

<cffunction name="authenticateSecureRequests" localmode="modern" access="private">
	<cfscript>
		if ( structKeyExists( variables.data, 'virtual_file_secure' ) AND variables.data.virtual_file_secure EQ 1 ) {
			if ( NOT application.zcore.user.checkServerAccess() ) {
				application.zcore.status.setStatus( request.zsid, 'You must first login to view this file.', form, true );
				application.zcore.functions.zRedirect( '/z/admin/admin-home/index?zsid=' & request.zsid );
			}
		}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
