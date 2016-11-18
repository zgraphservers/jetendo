<cfcomponent>
<cfoutput>  
<cffunction name="init" localmode="modern" access="private" roles="member">
<cfscript>
	var cdir=0;
	var ts=0;
	var arrFolders=0;  
	var arrLinks=0;
	var currentfile=0;
	var i=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images");	
	application.zcore.template.appendTag("meta",'<style type="text/css">
	/* <![CDATA[ */
		body, .fi-gallery-table{ background-color:##FFFFFF; color:##000000; }
	.fi-gallery-table a:link { color:##336699; }
	.fi-gallery-table a:visited { color:##225588; }
	.fi-gallery-table a:hover { color:##FF0000;} /* ]]> */
	</style>');
	form.fileGalleryMode=application.zcore.functions.zso(form, 'fileGalleryMode',false,false);
	form.galleryMode=application.zcore.functions.zso(form, 'galleryMode',false,false);
	if(form.fileGalleryMode EQ false and form.galleryMode EQ false){
		application.zcore.template.setTag("title","Files &amp; Images Manager");
	}
	request.zos.fileImage.absDir=application.zcore.functions.zvar('privatehomedir')&'zupload/user/'; 
	request.zos.fileImage.siteRootDir='/zupload/user';
	request.imageSizes=ArrayNew(1);
	ts=StructNew();
	ts.label="Small";
	ts.value="120x200";
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Medium";
	ts.value="250x400";
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Large";
	if(application.zcore.functions.zso(request.zos.globals, 'maximagewidth',true) NEQ 0){
		ts.value="#request.zos.globals.maximagewidth#x2000";
	}else{
		ts.value="760x2000";
	}
	ts.default=true;
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Keep Original Size";
	ts.value="10000x10000";
	ArrayAppend(request.imageSizes, ts);
	if(isDefined('request.zos.fileImage.absDir') EQ false or isDefined('request.zos.fileImage.siteRootDir') EQ false){
		writeoutput('File &amp; Image Directories are undefined for this site.  Please alert the developer.');
		application.zcore.functions.zabort();
	}else if(directoryexists(request.zos.fileImage.absDir) EQ false){
    application.zcore.functions.zCreateDirectory(request.zos.fileImage.absDir);
		if(directoryexists(request.zos.fileImage.absDir) EQ false){
	writeoutput('Unable to create content directory, please contact the webmaster.');
			application.zcore.functions.zabort();
		}
	}
	// shorthand dir
	variables.absDir=request.zos.fileImage.absDir; 
	variables.siteRootDir=request.zos.fileImage.siteRootDir;
	// image sizes can be overriden for each site.
	if(structkeyexists(request,'imageSizes') EQ false){
		request.imageSizes=ArrayNew(1);
		ts=StructNew();
		ts.label="Small";
		ts.value="120x200";
		ArrayAppend(request.imageSizes, ts);
		ts=StructNew();
		ts.label="Medium";
		ts.value="250x400";
		ArrayAppend(request.imageSizes, ts);
		ts=StructNew();
		ts.label="Large";
		if(application.zcore.functions.zso(request.zos.globals, 'maximagewidth',true) NEQ 0){
			ts.value="#request.zos.globals.maximagewidth#x2000";
		}else{
			ts.value="760x2000";
		}
		ts.default=true;
		ArrayAppend(request.imageSizes, ts);
		ts=StructNew();
		ts.label="Keep Original Size";
		ts.value="5000x5000";
		ArrayAppend(request.imageSizes, ts);
	}
	if(not form.fileGalleryMode and form.galleryMode EQ false and structkeyexists(request.zos, 'fileImage') and application.zcore.functions.zso(request.zos.fileImage, 'hideTitle',false,false) EQ false){
		writeoutput('<h2>Files &amp; Images</h2>');
	}
	if(form.fileGalleryMode or form.galleryMode or form.method EQ "fileGalleryViewFile" or form.method EQ "fileGalleryAddFolder" or form.method EQ "fileGalleryAdd" or form.method EQ "galleryAdd" or form.method EQ "galleryAddFolder" or form.method EQ "galleryAddFile"){
		request.zPageDebugDisabled=true;
	}
	if(isDefined('request.zos.fileImage.forceRootFolder')){ 
		if(application.zcore.functions.zso(form, 'd') EQ ''){
			form.d=request.zos.fileImage.forceRootFolder;
		}
		if(left(form.d,len(request.zos.fileImage.forceRootFolder)) NEQ request.zos.fileImage.forceRootFolder){
			application.zcore.status.setStatus(request.zsid,"Access denied to that folder. Now displaying the root folder.");
			application.zcore.functions.zRedirect("/z/admin/files/index?zsid=#request.zsid#");	
		}
	}

	// *** REMOVE *** //
	// UPDATE TO USE ROOT DIRECTORY INSTEAD
	if ( structKeyExists( form, 'd' ) EQ false OR form.d EQ '' ) {
		form.d = '';
		variables.currentDir = variables.absDir;
	} else {
	// *** END REMOVE *** //
		if ( isNumeric( form.d ) ) {
			// Handle directory listings by folder ID.
			if ( form.d EQ 0 ) {
				// Zero is root virtual folder.
				variables.isVirtualRoot = true;
				variables.virtualFolderId = 0;

				// *** REMOVE *** //
				form.d = '';
				variables.currentDir = variables.absDir;
				// *** END REMOVE *** //
			} else {
				variables.isVirtualRoot   = false;
				variables.virtualFolderId = form.d;

				virtualFolderCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-folder' );

				variables.virtualFolder = virtualFolderCom.getVirtualFolderById( variables.virtualFolderId );

				// *** REMOVE *** //
				variables.currentDir = virtualFolderCom.getFullFolderPath( variables.virtualFolder.virtual_folder_path, variables.virtualFolder.virtual_folder_secure );
				// *** END REMOVE *** //
			}
		} else {
			variables.virtualFolderPath = form.d;

			virtualFolderCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-folder' );

			variables.virtualFolder = virtualFolderCom.getVirtualFolderByPath( variables.virtualFolderPath );

			// *** REMOVE *** //
			variables.currentDir = virtualFolderCom.getFullFolderPath( variables.virtualFolder.virtual_folder_path, variables.virtualFolder.virtual_folder_secure );
			// *** END REMOVE *** //


			// *** REMOVE *** //
			/*
			variables.currentDir=replacenocase(form.d,"../","","ALL");
			variables.currentDir=variables.absDir&removeChars(variables.currentDir,1,1)&'/';
			if(directoryexists(variables.currentDir) EQ false){
				variables.currentDir=variables.absDir;
			}
			*/
			// *** END REMOVE *** //
		}
	}

	if ( structKeyExists( form, 'f' ) ) {
		if ( isNumeric( form.f ) ) {
			// Virtual files can ONLY be accessed through their ID.
			variables.virtualFileId = form.f;

			virtualFileCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-file' );

			variables.virtualFile = virtualFileCom.getVirtualFileById( variables.virtualFileId );
		}
		// *** REMOVE *** //
		else {
			currentFile=replacenocase(form.f,"../","","ALL");
			currentFile=variables.absDir&currentFile;
			if(fileexists(currentFile) EQ false){
				StructDelete(variables, 'currentFile');
			}
		}
		// *** END REMOVE *** //
	}

	if(form.fileGalleryMode){
		form.curListMethod="fileGallery";
	}else if(form.galleryMode EQ false){
		form.curListMethod="index";
	}else{
		form.curListMethod="gallery";
	}


	if ( structKeyExists( variables, 'virtualFolder' ) ) {
		arrFolders = listToArray( variables.virtualFolder.virtual_folder_path, '/' );

		cdir='';
		arrLinks=ArrayNew(1);
		if(form.d EQ ''){
			if(form.method EQ "index" or form.method EQ 'gallery'){
			    ArrayAppend(arrLinks, 'Root');
			}else{
			    ArrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#?d=">Root</a>');
			}
		}else{
			ArrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#?d=">Root</a>');
			for(i=1;i LTE arrayLen(arrFolders);i=i+1){
				if ( cdir NEQ '' ) {
					cdir = cdir & '/' & arrFolders[i];
				} else {
					cdir = arrFolders[ i ];
				}
				if(arrayLen(arrFolders) EQ i and (form.method EQ 'list' or form.method EQ 'gallery')){
					ArrayAppend(arrLinks, '#arrFolders[i]#');
				}else{
					ArrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#?d=#URLEncodedFormat(cdir)#">#arrFolders[i]#</a> ');
				}
			}
		}
		if(isDefined('request.zos.fileImage.forceRootFolder')){
			arrayDeleteAt(arrLinks,1);
		}

	} else {
		// *** REMOVE *** //

		// creating links to the parent folders
		arrFolders = ListToArray(form.d,'/');
		cdir='';
		arrLinks=ArrayNew(1);
		if(form.d EQ ''){
			if(form.method EQ "index" or form.method EQ 'gallery'){
			    ArrayAppend(arrLinks, 'Root');
			}else{
			    ArrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#?d=">Root</a>');
			}
		}else{
			ArrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#?d=">Root</a>');
			for(i=1;i LTE arrayLen(arrFolders);i=i+1){
				cdir=cdir&'/'&arrFolders[i];
				if(arrayLen(arrFolders) EQ i and (form.method EQ 'list' or form.method EQ 'gallery')){
					ArrayAppend(arrLinks, '#arrFolders[i]#');
				}else{
					ArrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#?d=#URLEncodedFormat(cdir)#">#arrFolders[i]#</a> ');
				}
			}
		}
		if(isDefined('request.zos.fileImage.forceRootFolder')){
			arrayDeleteAt(arrLinks,1);
		}

		// *** END REMOVE *** //
	}


	writeoutput('<table style="border-spacing:0px; width:100%;"><tr><td>');
	writeoutput('Current Folder: '&ArrayToList(arrLinks,' / '));
	writeoutput('</td></tr></table>');
	if(form.method NEQ 'index'){
		writeoutput('<hr />');
	}
	</cfscript>
</cffunction>

<cffunction name="fileGallery" localmode="modern" access="remote" roles="member">
	<cfscript> 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images");	
	form.fileGalleryMode=true; 
	request.zos.fileImage.absDir=application.zcore.functions.zvar('privatehomedir')&'zupload/user/'; 
	request.zos.fileImage.siteRootDir='/zupload/user';
	Request.zOS.debuggerEnabled=false;  
	
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	 
	this.index(); 

	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
	<script type="text/javascript">
	if(window.parent.Sizer){
		window.parent.Sizer.ResizeDialog(650,480);
	}
	</script>
</cffunction>

<cffunction name="gallery" localmode="modern" access="remote" roles="member">
<cfscript> 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images");	
	form.galleryMode=true; 
	Request.zOS.debuggerEnabled=false;
	request.zos.fileImage.absDir=application.zcore.functions.zvar('privatehomedir')&'zupload/user/'; 
	request.zos.fileImage.siteRootDir='/zupload/user';
	Request.zOS.debuggerEnabled=false;
	request.imageSizes=ArrayNew(1);
	ts=StructNew();
	ts.label="Small";
	ts.value="120x200";
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Medium";
	ts.value="250x400";
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Large";
	if(application.zcore.functions.zso(request.zos.globals, 'maximagewidth',true) NEQ 0){
		ts.value="#request.zos.globals.maximagewidth#x2000";
	}else{
		ts.value="760x2000";
	}
	ts.default=true;
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Keep Original Size";
	ts.value="10000x10000";
	ArrayAppend(request.imageSizes, ts);
	
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	
	if(form.method EQ "gallery"){
		this.index();
	}
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
	<script type="text/javascript">
	if(window.parent.Sizer){
		window.parent.Sizer.ResizeDialog(650,480);
	}
	</script>
</cffunction>

<cffunction name="sharedDocuments" localmode="modern" access="remote" roles="member">
	<cfscript>
	var ts=structnew();
	var r1=0;
	if(application.zcore.app.siteHasApp("content")){
	    ts=structnew();
	    ts.content_unique_name="/z/admin/files/sharedDocuments";
	    r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
	}else{
		r1=false;
	}
	if(r1 EQ false){
	    application.zcore.template.setTag("title","Shared Documents");
	    application.zcore.template.setTag("pagetitle","Shared Documents");
		writeoutput('<p>This files are provided for your convenience.</p>');
	}
	request.zos.fileImage.forceRootFolder="/Shared Documents";
	request.zos.fileImage.editDisabled=true;
	request.zos.fileImage.deleteDisabled=true;
	request.zos.fileImage.enableDownload=true;
	request.zos.fileImage.addDisabled=true;
	this.index();
</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
		variables.init();
		application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
			virtualFileCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-file' );

			// *** TODO *** //

			writeDump( virtualFileCom.getFullFilePath( variables.virtualFile.virtual_file_path, variables.virtualFile.virtual_file_secure ) );
			abort;

			application.zcore.functions.zDeleteFile( virtualFileCom.getFullFilePath( variables.virtualFile.virtual_file_path, variables.virtualFile.virtual_file_secure ) );

			virtualFileCom.deleteVirtualFile( variables.virtualFile.virtual_file_id );

			application.zcore.functions.zDeleteFile(variables.currentDir&GetFileFromPath(form.f));

			virtualFileCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-file' );



			application.zcore.status.setStatus(request.zsid,"File Deleted Successfully");
			application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&d=#urlencodedformat(form.d)#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; text-align:center; ">Are you sure you want to delete this file?
			<br /><br />
			#form.f#	
			<br /><br />
			<a href="/z/admin/files/delete?confirm=1&d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.f)#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/files/index?d=#URLEncodedFormat(form.d)#">No</a>
		</div>
	</cfif>
</cffunction>

<cffunction name="deleteFolder" localmode="modern" access="remote" roles="member">
<cfscript>
	var qDirCheck=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);
	</cfscript>
	<cfif form.f NEQ ''>
    <cfdirectory directory="#variables.currentDir&removeChars(form.f,1,1)#" name="qDirCheck" action="list">
    <cfif qDirCheck.recordcount NEQ 0>
	<cfscript>
	application.zcore.status.setStatus(request.zsid,"This directory has files or folders in it and cannot be deleted until they are removed invidually.");
	application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');
	</cfscript>
    </cfif>
    <cfif structkeyexists(form, 'confirm')>
	<cftry>
	    <cfdirectory action="delete" directory="#variables.currentDir&getfilefrompath(form.f)#">
	    <cfcatch type="any"></cfcatch>
	</cftry>
	<cfscript>
	application.zcore.status.setStatus(request.zsid,"Directory Deleted Successfully");
	application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&d=#urlencodedformat(form.d)#');
	</cfscript>
    <cfelse>
			<div style="font-size:14px; text-align:center; ">Are you sure you want to delete this directory?
			<br /><br />
			#htmleditformat(form.f)#	
			<br /><br />
			<a href="/z/admin/files/deleteFolder?confirm=1&amp;d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.f)#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/files/index?d=#URLEncodedFormat(form.d)#">No</a>
			</div>
    
    </cfif>
</cfif>
</cffunction>

<cffunction name="galleryInsert" localmode="modern" access="remote" roles="member">
<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
<cfscript>
	var local=structnew();
	var photoResize=0;
	var overwrite=0;
	var fileName=0;
	var t=0;
	var tPath=0;
	var qDir=0;
	var arrE=0;
	var fExt=0;
	var n2=0;
	var oldFilePath=0;
	var image_file=0;
	var arrList=0;
	variables.init();
	setting requesttimeout="3600";
    application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);
	returnMethod="edit";
	if(form.method EQ "galleryInsert"){
		returnMethod="galleryAdd";
		successMethod="gallery";
	}else{
		returnMethod="add";
		successMethod="index";
	}
	if(structkeyexists(form, 'image_file') EQ false or trim(form.image_file) EQ ''){
		application.zcore.status.setStatus(request.zsid,"No File was uploaded.");
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');	
		}else{
			application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');
		}
	}
	if(isNumeric(form.image_size_width) and isNumeric(form.image_size_height)){
		photoResize=max(10,min(2000,form.image_size_width))&'x'&max(10,min(2000,form.image_size_height));
	}else{
		application.zcore.status.setStatus(request.zsid,"Invalid image size");
		application.zcore.functions.zRedirect('/z/admin/files/#successMethod#?zsid=#request.zsid#');
	}
	if(form.image_size_width EQ 5000 and form.image_size_height EQ 5000){
		disableResize=true;
	}else{
		disableResize=false;
	}
	if(application.zcore.functions.zso(form, 'image_overwrite') EQ 1){
		overwrite=true;
	}else{
		overwrite=false;
	}
	fileName=application.zcore.functions.zuploadfile('image_file', application.zcore.functions.zvar('serverprivatehomedir')&'_cache/temp_files/');
	form.image_file=application.zcore.functions.zvar('serverprivatehomedir')&'_cache/temp_files/'&fileName;
	ext=lcase(application.zcore.functions.zGetFileExt(fileName));
	if(ext NEQ "png" and ext NEQ "jpg" and ext NEQ "jpeg" and ext NEQ "gif" and ext NEQ "zip"){
		application.zcore.functions.zDeleteFile(application.zcore.functions.zvar('serverprivatehomedir')&'_cache/temp_files/'&fileName);
		application.zcore.status.setStatus(request.zsid, "You must upload a supported image type including gif, jpg, png or a zip file contain 1 or more of these file types.", form, true);
		application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');
	}
	deletePath=application.zcore.functions.zvar('serverprivatehomedir')&'_cache/temp_files/'&fileName;
	if(request.zos.lastCFFileResult.clientfileext EQ 'zip'){
		if(form.method EQ 'update'){
			if(fileexists(deletePath)){
				application.zcore.functions.zdeletefile(deletePath);
			}
			application.zcore.status.setStatus(request.zsid,"You can't replace an image with a zip archive. You must select one JPG or GIF instead.");
			application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');		
		}
		if(fileName EQ false or left(fileName,6) EQ 'Error:'){
			application.zcore.status.setStatus(request.zsid,"File Upload Failed.");
			if(form.method EQ 'insert'){
				application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');
			}else{
				application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');		
			}	
		}
		t=dateformat(now(),'yyyymmdd')&timeformat(now(),'HHmmss');
		tPath=application.zcore.functions.zvar('serverprivatehomedir')&'_cache/temp_files/'&t&'/';
		application.zcore.functions.zcreatedirectory(tPath);
		zip action="unzip" file="#application.zcore.functions.zvar('serverprivatehomedir')&'_cache/temp_files/'&fileName#" storepath="no"  destination="#tPath#";
		application.zcore.functions.zdeletefile(request.zos.globals.serverprivatehomedir&'_cache/temp_files/'&fileName);
		qDir=application.zcore.functions.zReadDirectory(tPath);
		if(isSimpleValue(qDir) and qDir EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to uncompress zip archive.",false,true);
			if(form.method EQ 'insert'){
				application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');
			}else{
				application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');		
			}
		}
		arrE=arraynew(1);
		loop query="qDir"{
			form.imagePath=tPath&qDir.name;
			fileext=application.zcore.functions.zgetfileext(qDir.name);
			ext=fileext;
			filename=application.zcore.functions.zURLEncode(application.zcore.functions.zgetfilename(qDir.name), "-");
			if(left(qDir.name,2) EQ "._" or qDir.name EQ ".DS_Store" or qDir.type NEQ "file"){
				echo('skipping 1: '&qDir.name&'<br />');
				continue;
			}
			if(ext NEQ "png" and ext NEQ "jpg" and ext NEQ "jpeg" and ext NEQ "gif"){
				echo('skipping 2: '&qDir.name&" | "&fileName&' with ext: '&ext&'<br />');
				continue; // skip non image files
			}
			// upload image...
			curFileName=variables.currentDir&fileName&"."&fileext;
			if(fileext EQ 'gif' or disableResize){
				if(overwrite){
					// overwrite existing files
					application.zcore.functions.zDeleteFile(curFileName);
				}else if(fileexists(curFileName)){
					curIndex=1;
					while(true){
						curFileName=variables.currentDir&fileName&curIndex&"."&fileExt;
						if(fileexists(curFileName) EQ false){
							break;
						}
						curIndex++;
					}
				}
				r1=application.zcore.functions.zRenameFile(form.imagePath, curFileName);
			}else{
				arrList = application.zcore.functions.zUploadResizedImage("imagePath", variables.currentDir, photoresize);
				if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
					form.image_file=arrList[1];
				}else{
					application.zcore.functions.zDeleteFile(form.image_file);
					form.image_file='';
				}
				if(fileexists(variables.currentDir&form.image_file) EQ false){
					arrayappend(arrE,'Failed to resize image: '&qDir.name&'<br />');
				}else{
					n2=application.zcore.functions.zURLEncode(qDir.name, "-");
					fExt=".jpg";
					if(right(n2,4) EQ ".png"){
						fExt=".png";
					}
					n2=application.zcore.functions.zgetfilename(n2)&fExt;
					
					if(overwrite and form.image_file NEQ n2){
						// overwrite existing files
						application.zcore.functions.zDeleteFile(variables.currentDir&n2);
						application.zcore.functions.zRenameFile(variables.currentDir&form.image_file,variables.currentDir&n2);
						form.image_file=n2;
					}
				}
			}
		}
		// echo('stop');abort; // uncomment to debug zip image uploading
		application.zcore.functions.zdeletedirectory(tPath);
		if(arraylen(arrE) NEQ 0){
			application.zcore.status.setStatus(request.zsid,"#qdir.recordcount-arraylen(arrE)# Images Uploaded Successfully.");
			
			application.zcore.status.setStatus(request.zsid,"Uploaded images must be .jpg, .png or .gif. #arraylen(arrE)# of #qdir.recordcount# images failed to be resiapplication.zcore.functions.zed:<br />"&arraytolist(arrE,""),false,true);
			if(form.method EQ 'insert' or form.method EQ 'galleryInsert'){
				application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');
			}else{
				application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');		
			}
		}
		application.zcore.status.setStatus(request.zsid,"ZIP Image Archive Uploaded Successfully");
		application.zcore.functions.zRedirect('/z/admin/files/#successMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');
	}else{
		form.image_file=application.zcore.functions.zvar('serverprivatehomedir')&'_cache/temp_files/'&fileName;
		
		fileext=application.zcore.functions.zgetfileext(fileName);
		filename=application.zcore.functions.zgetfilename(fileName);
		curFileName=variables.currentDir&fileName&"."&fileext;
		if(fileext EQ 'gif' or disableResize){
			if(overwrite){
				// overwrite existing files
				application.zcore.functions.zDeleteFile(curFileName);
			}else if(fileexists(curFileName)){
				curIndex=1;
				while(true){
					curFileName=variables.currentDir&fileName&curIndex&"."&fileExt;
					if(fileexists(curFileName) EQ false){
						break;
					}
					curIndex++;
				}
			}
			r1=application.zcore.functions.zRenameFile(form.image_file, curFileName);
			if(r1 EQ false){
				application.zcore.status.setStatus(request.zsid, "Failed to upload image file.");
				if(form.method EQ 'insert'){
					application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');
				}else{
					application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');		
				}	
			}
		}else{
			arrList = application.zcore.functions.zUploadResizedImage("image_file", variables.currentDir, photoresize);	
			if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
				form.image_file=arrList[1];
			}else{
				application.zcore.functions.zDeleteFile(form.image_file);
				form.image_file='';
			}
			if(fileexists(variables.currentDir&form.image_file) EQ false){
				application.zcore.status.setStatus(request.zsid,"Image failed to be resized.  Try another image or format.",false,true);
				if(form.method EQ 'insert'){
					application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');
				}else{
					application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');		
				}
			}
			fExt=".jpg";
			if(right(request.zos.lastCFFileResult.clientfile, 4) EQ ".png"){
				fExt=".png";
			}
			n2=application.zcore.functions.zURLEncode(application.zcore.functions.zgetfilename(request.zos.lastCFFileResult.clientfile),"-")&fExt;
			if(form.method NEQ 'update' and overwrite and compare(n2, form.image_file) NEQ 0){
				application.zcore.functions.zDeleteFile(variables.currentDir&n2);
				application.zcore.functions.zRenameFile(variables.currentDir&form.image_file,variables.currentDir&n2);
				form.image_file=n2;
			}
			if(application.zcore.functions.zgetfileext(form.image_file) NEQ 'jpg' and fExt NEQ ".png"){
				application.zcore.functions.zRenameFile(variables.currentDir&form.image_file,variables.currentDir&application.zcore.functions.zURLEncode(application.zcore.functions.zgetfilename(form.image_file), "-")&'.jpg');
			}
			if(fileexists(deletePath)){
				application.zcore.functions.zdeletefile(deletePath);
			}
		}
		if(form.method EQ 'update'){
			oldFilePath=variables.currentDir&getfilefrompath(form.f); 
			application.zcore.functions.zDeleteFile(oldFilePath); // kill the old file
			application.zcore.functions.zRenameFile(variables.currentDir&form.image_file, oldFilePath); // make the new resized image the same name as the old file that was deleted.
			application.zcore.status.setStatus(request.zsid,"Image Replaced Successfully");
		}else{
			application.zcore.status.setStatus(request.zsid,"Image Uploaded Successfully");
		}
		application.zcore.functions.zRedirect('/z/admin/files/#successMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');
	}
	</cfscript>	
</cffunction>


<cffunction name="fileGalleryInsertFile" localmode="modern" access="remote" roles="member">
<cfscript>
	this.updateFile();
	</cfscript>
</cffunction>

<cffunction name="insertFile" localmode="modern" access="remote" roles="member">
<cfscript>
	this.updateFile();
	</cfscript>
</cffunction>

	

<cffunction name="updateFile" localmode="modern" access="remote" roles="member">
	<cfscript>
	var oldFilePath=0;
	variables.init();
	setting requesttimeout="3600";
	application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);

	returnMethod="index";
	errorMethod="addFile";
	if(form.method EQ "fileGalleryInsertFile"){
		returnMethod="fileGallery";
		errorMethod="fileGalleryAdd";
	}else if(form.method EQ "updateFile"){
		returnMethod="index";
		errorMethod="editFile"; 
	}

	if(trim(application.zcore.functions.zso(form, 'image_file')) EQ ''){
	    application.zcore.status.setStatus(request.zsid,"No File was uploaded."); 
		application.zcore.functions.zRedirect('/z/admin/files/#errorMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');	
	}


	if(form.image_file CONTAINS ","){
		// patched the cfml server to support multiple file uploads
		rs=application.zcore.functions.zFileUploadAll("image_file", variables.currentDir, false);
		for(i=1;i LTE arraylen(rs.arrError);i++){
			application.zcore.status.setStatus(request.zsid, rs.arrError[i], form, true);
		}
		if(arraylen(rs.arrFile)){
			application.zcore.status.setStatus(request.zsid,"Files Uploaded.");
		}
		application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');	
	}else{

		form.image_file = variables.currentDir&application.zcore.functions.zUploadFile("image_file", variables.currentDir);	
		if('gif,jpg,png,bmp' CONTAINS application.zcore.functions.zgetfileext(getfilefrompath(form.image_file))){
			application.zcore.status.setStatus(request.zsid,"You can't upload an image as a file.  <a href=""/z/admin/files/add?d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#"">Click here to upload an image</a>.");
			application.zcore.functions.zdeletefile(form.image_file);
		application.zcore.functions.zRedirect('/z/admin/files/#errorMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f=#URLEncodedFormat(form.f)#');	
		}

		if(form.method EQ 'updateFile'){
			oldFilePath=variables.currentDir&getfilefrompath(form.f); 
			application.zcore.functions.zDeleteFile(oldFilePath); // kill the old file
			application.zcore.functions.zRenameFile(variables.currentDir&form.image_file, oldFilePath); // make the new resized image the same name as the old file that was deleted.
		}
		if(form.image_file EQ false or left(form.image_file,6) EQ 'Error:'){
			application.zcore.status.setStatus(request.zsid,"File Upload Failed.");
			application.zcore.functions.zRedirect('/z/admin/files/#errorMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');		
		}else{
			application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#&f='&urlencodedformat(replace(form.image_file, request.zos.globals.privatehomedir&'zupload/user', '')));	 
		}
	}

</cfscript>
</cffunction>

<cffunction name="fileGalleryInsertFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.insertFolder();
	</cfscript>
</cffunction>

<cffunction name="galleryInsertFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.insertFolder();
	</cfscript>
</cffunction>

<cffunction name="insertFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	var e=0;
	var newdir=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);
	try{
		newdir=application.zcore.functions.zDirectoryStringFormat(form.folder_name);
	}catch(Any e){
		newdir="";
	}
	if(structkeyexists(form, 'folder_name') EQ false or newdir EQ ""){
		application.zcore.status.setStatus(request.zsid,"Folder name required.",false,true);
		if(form.method EQ 'insertFolder'){
			application.zcore.functions.zRedirect('/z/admin/files/addFolder?d=#URLEncodedFormat(form.d)#&zsid=#request.zsid#');
		}else if(form.method EQ 'galleryInsertFolder'){ 
			application.zcore.functions.zRedirect('/z/admin/files/galleryAddFolder?d=#URLEncodedFormat(form.d)#&zsid=#request.zsid#');
		}else if(form.method EQ 'fileGalleryInsertFolder'){
			application.zcore.functions.zRedirect('/z/admin/files/fileGalleryAddFolder?d=#URLEncodedFormat(form.d)#&zsid=#request.zsid#');
		}
	}
	if(form.method EQ 'insertFolder' or form.method EQ 'galleryInsertFolder' or form.method EQ 'fileGalleryInsertFolder'){
		application.zcore.functions.zCreateDirectory(variables.currentDir&application.zcore.functions.zDirectoryStringFormat(form.folder_name));
	}else{
		// if there are no children!
		application.zcore.functions.zRenameDirectory(dirName, application.zcore.functions.zDirectoryStringFormat(newDirName));
	}
	if(form.method EQ 'insertFolder' or form.method EQ 'galleryInsertFolder' or form.method EQ 'fileGalleryInsertFolder'){
		application.zcore.status.setStatus(request.zsid,"Folder Created Successfully");
	}else{
		application.zcore.status.setStatus(request.zsid,"Folder Renamed Successfully");
	}
	if(form.method EQ 'fileGalleryInsertFolder'){
		application.zcore.functions.zRedirect('/z/admin/files/fileGallery?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');
	}else if(form.method EQ 'galleryInsertFolder'){
		application.zcore.functions.zRedirect('/z/admin/files/gallery?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');
	}else{
		application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&d=#URLEncodedFormat(form.d)#');
	}
	</cfscript>
</cffunction>


<cffunction name="galleryAdd" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank", true, true);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
<cfscript>
	var ts=0;
	var arrS=0;
	var i=0;
	var ts=0;
	var width=0;
	var currentMethod=form.method;
	application.zcore.functions.zSetPageHelpId("2.5.2");
	form.image_size_width=request.zos.globals.maxImageWidth;
	form.image_size_height=5000;
	variables.init();
if(structkeyexists(form, 'd') EQ false){
    form.d='';
}
if(structkeyexists(form, 'f') EQ false){
    form.f='';
}
application.zcore.functions.zStatusHandler(request.zsid,true);
</cfscript>
<h2>Upload Image</h2> 
<cfif currentMethod EQ 'edit'>
    <strong style="color:##FF0000;">You are about to replace this image.</strong><br />
    All references to it on the site will be updated to the new image.<br />
    If you want to add an image instead, <a href="/z/admin/files/add?d=#URLEncodedFormat(form.d)#">click here</a><br />
    <!--- <br />
    <strong style="color:##FF0000;">Note:</strong> When replacing images, they must share the <strong>same file extension</strong>.<br /><strong>Current file extension: "#application.zcore.functions.zGetFileExt(getfilefrompath(form.f))#"</strong> ----> 
    </cfif>  
    <cfif currentMethod NEQ 'add' and currentMethod NEQ 'galleryAdd'><br />
    <h2>URL to embed/view image using browser default settings:</h2><br />
    <cfscript>
    path=getdirectoryfrompath(form.f);
    fileName=getfilefrompath(form.f);
	fileExtension=application.zcore.functions.zGetFileExt(fileName);
	fileName=urlencodedformat(application.zcore.functions.zGetFileName(fileName));

	</cfscript>
    <textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#application.zcore.functions.zvar('domain')##variables.siteRootDir##path&fileName&"."&fileExtension#</textarea><br />
    <br />
    
    <h2>URL to force download of image file:</h2>
    <textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#request.zos.currentHostName#/z/misc/download/index?fp=#urlencodedformat(variables.siteRootDir&form.f)#</textarea><br />
    <br />
    </cfif>

<div id="imageForm2" style="display:none; font-size:18px; line-height:24px;">Uploading, please wait...</div>
<div id="imageForm">

<form class="zFormCheckDirty" action="/z/admin/files/<cfif currentMethod EQ 'galleryAdd'>galleryInsert<cfelseif currentMethod EQ 'add'>insert<cfelse>update</cfif>?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.f)#" method="post" enctype="multipart/form-data" onsubmit="return submitImageForm();">
<cfif currentMethod EQ 'edit' and form.f NEQ ''>
    Current Image:<br />
<img src="#variables.siteRootDir##htmleditformat(form.f)#?z=#TimeFormat(now(),'HHmmss')&gettickcount()#" /><br /><br />
</cfif>
<p>Select a .jpg, .png or .gif image<cfif currentMethod NEQ 'edit'> or a .zip archive with .jpg, .png and/or .gif files inside</cfif>.</p>

<p>Select File: <input type="file" name="image_file"></p>


Resize Image:  
<script type="text/javascript">
/* <![CDATA[ */var arrWidth=new Array();
var arrHeight=new Array();
function setWH(n){	
    w=document.getElementById("image_size_width");
    h=document.getElementById("image_size_height");
    w.value=arrWidth[n];
    h.value=arrHeight[n];
    fixValue(w);
    fixValue(h);
}
function submitImageForm(){
    var r=onSub();
    if(r == false){
	return false;	
    }else{
	var d1=document.getElementById("imageForm");
	var d2=document.getElementById("imageForm2");
	d1.style.display="none";
	d2.style.display="block";
	return true;
    }
}
function fixValue(t){
    t.value=parseInt(t.value);
    if(t.value > 5000){
	t.value=5000;
    }
    if(t.value < 10){
	t.value="";
    }
    if(t.value=="NaN"){
	t.value="";
    }
}
function onSub(){
    w=document.getElementById("image_size_width");
    h=document.getElementById("image_size_height");
    fixValue(w);
    fixValue(h);
    if(w.value=="" || h.value==""){
	alert("Width and height are required.");
	return false;
    }
    return true;
}
<cfloop from="1" to="#ArrayLen(request.imageSizes)#" index="i">
<cfscript>
ts=request.imageSizes[i];
arrS=listtoarray(ts.value,'x');
</cfscript>
arrWidth.push('#arrS[1]#');arrHeight.push('#arrS[2]#');
</cfloop>
	/* ]]> */
</script>
<cfloop from="1" to="#ArrayLen(request.imageSizes)#" index="i">
    <cfscript>
    ts=request.imageSizes[i];
    arrS=listtoarray(ts.value,'x');
    </cfscript>
    <input type="radio" name="image_size" onclick="setWH(#i-1#);" value="#i#" <cfif application.zcore.functions.zso(form, 'image_size') EQ i or (application.zcore.functions.zso(form, 'image_size') EQ '' and structkeyexists(ts,'default') and ts.default)>checked="checked"<cfset form.image_size_width=arrS[1]><cfset form.image_size_height=arrS[2]><cfelse><cfset width=false></cfif> style="background:none; border:none;"/> #ts.label# 
</cfloop><br />
<br />
Pixel Size: Width: <input type="text" size="5" name="image_size_width" id="image_size_width"<!---  onkeyup="fixValue(this);" ---> value="#application.zcore.functions.zso(form, 'image_size_width')#"> Height: <input type="text" size="5" name="image_size_height" id="image_size_height"<!---  onkeyup="fixValue(this);" ---> value="#application.zcore.functions.zso(form, 'image_size_height')#"> (preserves ratio)
<br />
<br />
<cfif currentMethod NEQ 'edit'>
Overwrite Existing Files? <input type="radio" name="image_overwrite" value="1" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="image_overwrite" value="0" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 0 or application.zcore.functions.zso(form, 'image_overwrite') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No 
<br />
<br /></cfif>
<input type="submit" name="image_submit" value="Upload Image" /> 
	<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/files/<cfif form.method EQ "galleryAdd">gallery<cfelse>index</cfif>?d=#URLEncodedFormat(form.d)#';" />
</form>
</cffunction>

<cffunction name="fileGalleryAdd" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.addFile();
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank", true, true);
	</cfscript>
</cffunction>

<cffunction name="addFile" localmode="modern" access="remote" roles="member">
<cfscript>
	application.zcore.functions.zSetPageHelpId("2.5.1");
	var currentMethod=form.method;
	variables.init();
if(structkeyexists(form, 'd') EQ false){
    form.d='';
}
if(structkeyexists(form, 'f') EQ false){
    form.f='';
}
application.zcore.functions.zStatusHandler(request.zsid,true);
</cfscript>
<h1>Upload File</h1>
<cfif currentMethod EQ 'editFile'>
    <strong style="color:##FF0000;">You are about to replace this file.</strong><br />
All references to it on the site will be updated to the new file.<br />
If you just want to add an file, <a href="/z/admin/files/addFile?d=#URLEncodedFormat(form.d)#">click here</a><br />
</cfif>

	<form class="zFormCheckDirty" action="/z/admin/files/<cfif currentMethod EQ "fileGalleryAdd">fileGalleryInsertFile<cfelseif currentMethod EQ 'addFile'>insertFile<cfelse>updateFile</cfif>?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.f)#" method="post" enctype="multipart/form-data">
	<cfif form.f NEQ ''>
		Download: <a href="#variables.siteRootDir##urlencodedformat(form.f)#">#urlencodedformat(form.f)#</a><br />
		<br />
	</cfif>
	Select file(s):
	<input type="file" name="image_file" multiple="multiple" />
	<br />
	<br />
	<input type="submit" name="image_submit" value="Upload File" /> 
	<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/files/<cfif currentMethod EQ "fileGalleryAdd">fileGallery<cfelse>index</cfif>?d=#URLEncodedFormat(form.d)#';" />
	</form>
</cffunction>

<cffunction name="fileGalleryViewFile" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	form.fileGalleryMode=true; 
	Request.zOS.debuggerEnabled=false;
	application.zcore.functions.zSetPageHelpId("2.5.5");
	form.f=application.zcore.functions.zso(form, 'f');
	p=reverse(form.f);
	pos=find("/",p);
	if(pos NEQ 0){
		fn=(reverse(left(p,pos-1)));
		p=left(form.f,len(form.f)-(pos-1));
		form.f=p&fn;
	} 
    path=getdirectoryfrompath(form.f);
    fileName=getfilefrompath(form.f);
	fileExtension=application.zcore.functions.zGetFileExt(fileName);
	fileName=urlencodedformat(application.zcore.functions.zGetFileName(fileName));

	</cfscript>
	<form class="zFormCheckDirty" action="" onsubmit=" insertFile(); return false;">
	<h3>File to Insert: #form.f#</h3>
	<input type="hidden" name="fileLink" id="fileLink" value="#htmleditformat("#request.zos.currentHostName#/z/misc/download/index?fp=#urlencodedformat(variables.siteRootDir&form.f)#")#">
	<p>Link Text: <input type="text" name="fileLabel" id="fileLabel" style="width:350px;" value="#htmleditformat("Download File (#form.f#)")#"></p>
	<input type="submit" name="submit1" value="Insert File Link" /> 

	<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/files/fileGallery?d=#URLEncodedFormat(form.d)#';" />
	</form>
	<script type="text/javascript">
	/* <![CDATA[ */
	if(!window.parent.zInsertGalleryFile){
	    alert('HTML Editor is missing');
	}
	function insertFile(){ 
		var fileLabel=$("##fileLabel").val();
		var fileLink=$("##fileLink").val();
		if(fileLabel.trim() == ""){
			alert("Link Text is required.");
			return false;
		}
	    var theHTML='<a href="'+fileLink+'">'+fileLabel+'</a>';
	    

		window.parent.zInsertGalleryFile(theHTML); 

	}
	/* ]]> */
	</script> 

</cffunction>
	

<cffunction name="editFile" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();
	application.zcore.functions.zSetPageHelpId("2.5.5");
	p=reverse(form.f);
	pos=find("/",p);
	if(pos NEQ 0){
		fn=(reverse(left(p,pos-1)));
		p=left(form.f,len(form.f)-(pos-1));
		form.f=p&fn;
	} 
    path=getdirectoryfrompath(form.f);
    fileName=getfilefrompath(form.f);
	fileExtension=application.zcore.functions.zGetFileExt(fileName);
	fileName=urlencodedformat(application.zcore.functions.zGetFileName(fileName));

	</cfscript>
	<h2>URL to embed/view file using browser default settings:</h2>
	<textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#request.zos.currentHostName##variables.siteRootDir&path&fileName&"."&fileExtension#</textarea><br />
	<br />
	<h2>URL to force download of file:</h2>
	<textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#request.zos.currentHostName#/z/misc/download/index?fp=#urlencodedformat(variables.siteRootDir&form.f)#</textarea><br />
	<br />

	Copy and Paste the above link into the URL field of the content manager to link to this file on any page of the site. <br />
	<br />
	Be careful not to delete files unless you have removed all links to them.<br />

	<cfif right(form.f,3) EQ ".js" or right(form.f,4) EQ ".css" or right(form.f,4) EQ ".htm">
		<br />
		<cfscript>
		application.zcore.functions.zstatushandler(request.zsid, true);
		</cfscript>
		<cfif structkeyexists(form,'fifilecontents1')>
		<cfscript>
		application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&removechars(variables.siteRootDir,1,1)&form.f, fifilecontents1);
		application.zcore.status.setStatus(request.zsid, "File updated.");
		application.zcore.functions.zRedirect("/z/admin/files/editFile?d="&urlencodedformat(form.d)&"&f="&urlencodedformat(form.f)&"&zsid=#request.zsid#");
		</cfscript>
		</cfif>
		<h2>Edit File Contents</h2>
		<cfscript>
		cc=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&removechars(variables.siteRootDir,1,1)&form.f);
		</cfscript>
		<form class="zFormCheckDirty" action="/z/admin/files/editFile?d=#urlencodedformat(form.d)#&amp;f=#urlencodedformat(form.f)#" method="post">
		<textarea name="fifilecontents1" cols="100" rows="10" style="width:100%; height:600px; " >#htmleditformat(cc)#</textarea><br />
		<br />
		<input type="submit" name="submit11" value="Save Changes" style="padding:5px;" /> <input type="button" name="csubmit11" value="Cancel" onclick="window.location.href='/z/admin/files/index';" style="padding:5px;" /> 
		</form>
	</cfif>
</cffunction>

<cffunction name="fileGalleryAddFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.addFolder();
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
</cffunction>

<cffunction name="galleryAddFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.addFolder();
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
</cffunction>

<cffunction name="addFolder" localmode="modern" access="remote" roles="member">
<cfscript>
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.5.3");
if(structkeyexists(form, 'd') EQ false){
    form.d='';
}
if(structkeyexists(form, 'f') EQ false){
    form.f='';
}
application.zcore.functions.zStatusHandler(request.zsid,true);
</cfscript>
<h1><cfif currentMethod EQ 'editFolder'>Rename<cfelse>Create</cfif> Folder</h1>

<form class="zFormCheckDirty" action="/z/admin/files/<cfif currentMethod EQ 'fileGalleryAddFolder'>fileGalleryInsertFolder<cfelseif currentMethod EQ 'galleryAddFolder'>galleryInsertFolder<cfelseif currentMethod EQ 'addFolder'>insertFolder<cfelse>updateFolder</cfif>?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.f)#" method="post" enctype="multipart/form-data">
<cfif form.f NEQ '' and currentMethod EQ 'editFolder'>
Current Folder Name: #urlencodedformat(form.f)#<br /><br />
</cfif>
Type folder name:
<input type="text" name="folder_name" />
<br /><br />   
<input type="submit" name="image_submit" value="<cfif currentMethod EQ 'editFolder'>Rename<cfelse>Create</cfif> Folder" />
	<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/files/<cfif currentMethod EQ 'fileGalleryAddFolder'>fileGallery<cfelseif currentMethod EQ 'galleryAddFolder'>gallery<cfelse>index</cfif>?d=#URLEncodedFormat(form.d)#';" />
</form>
</cffunction>

<cffunction name="download" localmode="modern" access="remote" roles="member">
<cfscript>
	variables.init();
form.fp=variables.siteRootDir&form.f;
d=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.misc.controller.download");
d.index();
</cfscript>
</cffunction>


<cffunction name="align" localmode="modern" access="remote" roles="member">
<cfscript>
	var output=0;
	var currentWidth=0;
	var currentHeight=0;
	this.gallery();
	variables.init();
	</cfscript>
	<a href="##" onclick="history.back(); return false;">Back</a>
<table style="margin-left:auto; margin-right:auto; border-spacing:0px;width:100%;">
	<tr>
	<td>
	<script type="text/javascript">
/* <![CDATA[ */

if(!window.parent.zInsertGalleryImage){
    alert('HTML Editor is missing');
}
function setImage(){
    var radioGrp = document.iaform.image_align;
    var a="";
    for (var i = 0; i< radioGrp.length; i++) {
		if (radioGrp[i].checked) {
		    a=radioGrp [i].value;
		}
    }
    var theHTML="";
    if(a==0){// left
	theHTML='<img src="#variables.siteRootDir##urlencodedformat(form.f)#" class="zImageLeft">';
    }else if(a==3){ // default - none
	theHTML='<img src="#variables.siteRootDir##urlencodedformat(form.f)#" class="zImageDefault">';
    }else if(a==2){ // right
	theHTML='<img src="#variables.siteRootDir##urlencodedformat(form.f)#" class="zImageRight">';
    }else if(a==1){ // center
	theHTML='<div style="width:100%; float:none; text-align:center;"><img src="#variables.siteRootDir##urlencodedformat(form.f)#"></div>';
    }

	window.parent.zInsertGalleryImage(theHTML); 

}/* ]]> */
</script>

	<table style="text-align:center;">
	<tr>
	<td style="text-align:center;">
		<img src="#variables.siteRootDir##urlencodedformat(form.f)#" height="150" /><br />
		<cfscript> 
		imageSize=application.zcore.functions.zGetImageSize(variables.absDir&(form.f));      
		echo('File Name: #getfilefrompath(form.f)# | ');
		if(not imageSize.success){
			echo(imageSize.errorMessage);
		}else{
			echo('Resolution: '&imageSize.width&'x'&imageSize.height&' Quality: '&imageSize.quality);
		}
		</cfscript>
		<br />

	How do you want this image to align with the text on this page?<br /> 
	<form action="" name="iaform" id="iaform" method="get">

	<table style="margin-left:auto; margin-right:auto; border-spacing:0px;">
	<tr>
	<td>
	<a href="##" onclick="document.iaform.image_align[0].checked=true;setImage();" style="text-decoration:none;"><img src="/z/images/page/align-left.gif" /><br />
	<input type="radio" name="image_align" id="image_align" value="0"  style="background:none; border:none;" />Left</a>
	</td>
	<td>
	<a href="##" onclick="document.iaform.image_align[1].checked=true;setImage();" style="text-decoration:none;"><img src="/z/images/page/align-center.gif" /><br />
	<input type="radio" name="image_align" id="image_align" value="1" checked="checked" style="background:none; border:none;" />Center</a>
	</td>
	<td>
	<a href="##" onclick="document.iaform.image_align[2].checked=true;setImage();" style="text-decoration:none;"><img src="/z/images/page/align-right.gif" /><br />
	<input type="radio" name="image_align" id="image_align" value="2"  style="background:none; border:none;" />Right</a>
	</td>
	</tr>
	<tr><td colspan="3" style="text-align:center"><a href="##" onclick="document.iaform.image_align[3].checked=true;setImage();" style="text-decoration:none;"><input type="radio" name="image_align" id="image_align" value="3"  style="background:none; border:none;" /> Click here for no alignment (<strong>recommended</strong>)</a></td></tr>
	</table>
	</form>
	</div>
</td></tr></table>
</td></tr></table>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
<cfscript>
	var fileext=0;
	var tempImage=0;
	var vertical=0;
	var currentWidth=0;
	var currentHeight=0;
	var output=0;
	var i=0;
	var inputStruct=0;
	var myColumnOutput=0;
	var qDir=0;
	var qDirCheck=0;
	var arrDir=0;
	var arrImages=0;
	var dirSortString=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.5");
application.zcore.functions.zStatusHandler(request.zsid);

application.zcore.template.appendTag("meta",'<style type="text/css">
/* <![CDATA[ */ .fi-1 {
    background-color:##336699;
    color:##FFFFFF;
}
.fi-1 a:link, .fi-1 a:visited {
    color:##FFFFFF; text-decoration:none;
}
.fi-1 a:hover {
    color:##FFFF00; text-decoration:underline;
} /* ]]> */
</style>');




if ( structKeyExists( form, 'csort' ) ) {
	if ( form.csort EQ 'date' ) {
		// Order by Date
		variables.orderFolderBy        = 'date';
		variables.orderFolderDirection = 'DESC';

		request.zsession.fileManagerSortDate=1;
	} else {
		// Order by Name
		variables.orderFolderBy        = 'name';
		variables.orderFolderDirection = 'ASC';

		request.zsession.fileManagerSortDate=0;
	}
} else {
	variables.orderFolderBy        = 'name';
	variables.orderFolderDirection = 'ASC';

	request.zsession.fileManagerSortDate=0;
}
</cfscript>
<cfif not isDefined('request.zos.fileImage.editDisabled') or not request.zos.fileImage.editDisabled>
    <table style="border-spacing:0px; width:100%; border-bottom:1px solid ##CCC; padding-bottom:5px; margin-bottom:5px;">
		<tr>
		<td style="font-weight:700;">
			<cfif form.fileGalleryMode EQ false and form.galleryMode EQ false>
				<a href="/z/admin/files/addFolder?d=#URLEncodedFormat(form.d)#"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Create Folder</a> | 
				<a href="/z/admin/files/addFile?d=#URLEncodedFormat(form.d)#"><img src="/z/images/page/file.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Upload File</a> | 
				<a href="/z/admin/files/add?d=#URLEncodedFormat(form.d)#"><img src="/z/images/page/image.gif" style="vertical-align:bottom; padding-left:4px; padding-right:4px;">Upload Image</a> | 
				<a href="/z/admin/files/index?d=#URLEncodedFormat(form.d)#" target="_blank">Manage Files</a> | 
				Sort by: 
				<cfif application.zcore.functions.zso(request.zsession, 'fileManagerSortDate',true) EQ 0>
					<a href="/z/admin/files/index?csort=date&amp;d=#URLEncodedFormat(form.d)#">Date</a> | Name | 
				<cfelse>
					Date | <a href="/z/admin/files/index?csort=name&d=#URLEncodedFormat(form.d)#">Name</a> | 
				</cfif> 
				<a href="/z/admin/files/gallery?d=#URLEncodedFormat(form.d)#">Refresh</a>
			<cfelseif form.fileGalleryMode>
				<a href="/z/admin/files/fileGalleryAddFolder?d=#URLEncodedFormat(form.d)#"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Create Folder</a> | 
				<a href="/z/admin/files/fileGalleryAdd?d=#URLEncodedFormat(form.d)#"><img src="/z/images/page/file.gif" style="vertical-align:bottom; padding-left:4px; padding-right:4px;">Upload File</a> | 
				<a href="/z/admin/files/index?d=#URLEncodedFormat(form.d)#" target="_blank">Manage Images</a> | 
				Sort by: 
				<cfif application.zcore.functions.zso(request.zsession, 'fileManagerSortDate',true) EQ 0>
					<a href="/z/admin/files/fileGallery?csort=date&amp;d=#URLEncodedFormat(form.d)#">Date</a> | Name | 
				<cfelse>
					Date | <a href="/z/admin/files/fileGallery?csort=name&d=#URLEncodedFormat(form.d)#">Name</a> | 
				</cfif> 
				<a href="/z/admin/files/fileGallery?d=#URLEncodedFormat(form.d)#">Refresh</a>
			<cfelse>
				<a href="/z/admin/files/galleryAddFolder?d=#URLEncodedFormat(form.d)#"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Create Folder</a> | 
				<a href="/z/admin/files/galleryAdd?d=#URLEncodedFormat(form.d)#"><img src="/z/images/page/image.gif" style="vertical-align:bottom; padding-left:4px; padding-right:4px;">Upload Image</a> | 
				Sort by: 
				<cfif application.zcore.functions.zso(request.zsession, 'fileManagerSortDate',true) EQ 0>
					<a href="/z/admin/files/gallery?csort=date&amp;d=#URLEncodedFormat(form.d)#">Date</a> | Name | 
				<cfelse>
					Date | <a href="/z/admin/files/gallery?csort=name&d=#URLEncodedFormat(form.d)#">Name</a> | 
				</cfif> 
			</cfif> 
			 
			</td>
		</tr>
		</table>
</cfif>
<table style="border-spacing:0px; width:100%;" <cfif form.method EQ "index">class="table-list"</cfif>>



<cfscript>

	virtualFileCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-file' );

	theFiles = virtualFileCom.getFilesInFolder( variables.virtualFolder.virtual_folder_id, variables.orderFolderBy, variables.orderFolderDirection );

	virtualFolderCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-folder' );

</cfscript>




<cfdirectory directory="#variables.currentDir#" name="qDir" action="list" sort="#dirSortString#">

<cfif qDir.recordcount EQ 0>
    <tr><td colspan="3">This directory has no files or folders.</td></tr>
</cfif>
	<cfscript>
	imageTypeStruct={
		"png":true,
		"jpg":true,
		"gif":true
	}; 
	</cfscript>
	<cfif form.fileGalleryMode>
		<tr><td>
		<cfscript>	
		arrDir=arraynew(1);
		arrFile=ArrayNew(1);
		for(i=1;i LTE qDir.recordcount;i=i+1){
			if(qDir.type[i] EQ 'file' and not structkeyexists(imageTypeStruct, application.zcore.functions.zGetFileExt(qDir.name[i]))){
				arrayAppend(arrFile, qDir.name[i]);
			}else if(qDir.type[i] EQ 'dir'){
				arrayAppend(arrDir, qDir.name[i]);
			}
		}
		</cfscript>
		<cfif arraylen(arrDir) NEQ 0>
			<strong>Subdirectories:</strong><br />
			<table style="width:100%;">
			<cfscript>	
			inputStruct = StructNew();
			inputStruct.colspan = 4;
			inputStruct.rowspan = arraylen(arrDir);
			inputStruct.vertical = true;
			myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
			myColumnOutput.init(inputStruct);
			</cfscript>
			<cfloop from="1" to="#arraylen(arrDir)#" index="i">
				#myColumnOutput.check(i)#
			   <a href="/z/admin/files/#form.curListMethod#?d=#URLEncodedFormat(form.d&'/'&arrDir[i])#" style="color:##000000;">#arrDir[i]#</a><br />
				#myColumnOutput.ifLastRow(i)#
			</cfloop>
			</table>
		</cfif>
		<cfscript>
		inputStruct = StructNew();
		inputStruct.colspan = 4;
		inputStruct.rowspan = ArrayLen(arrFile);
		inputStruct.vertical = true;
		myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
		</cfscript>
		<cfif ArrayLen(arrFile) NEQ 0>
			<strong>Files:</strong><br />
		</cfif>
		<cfloop from="1" to="#ArrayLen(arrFile)#" index="i">
			<cfset tempImage=false>
				<div style="width:100%; float:left; border-bottom:1px solid ##CCCCCC; padding:5px; ">
					<a href="/z/admin/files/fileGalleryViewFile?fileGalleryMode=true&amp;d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&arrFile[i])#">#arrFile[i]#</a>
				</div>
		</cfloop> 
		</td>
		</tr>

	<cfelseif form.galleryMode>
		<tr><td>
		<cfscript>	
		arrDir=arraynew(1);
		arrImages=ArrayNew(1);
		for(i=1;i LTE qDir.recordcount;i=i+1){
			if(qDir.type[i] EQ 'file' and structkeyexists(imageTypeStruct, application.zcore.functions.zGetFileExt(qDir.name[i]))){
				arrayAppend(arrImages, qDir.name[i]);
			}else if(qDir.type[i] EQ 'dir'){
				arrayAppend(arrDir, qDir.name[i]);
			}
		}
		</cfscript>
		<cfif arraylen(arrDir) NEQ 0>
			<strong>Subdirectories:</strong><br />
			<table style="width:100%;">
			<cfscript>	
			inputStruct = StructNew();
			inputStruct.colspan = 4;
			inputStruct.rowspan = arraylen(arrDir);
			inputStruct.vertical = true;
			myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
			myColumnOutput.init(inputStruct);
			</cfscript>
			<cfloop from="1" to="#arraylen(arrDir)#" index="i">
				#myColumnOutput.check(i)#
			   <a href="/z/admin/files/#form.curListMethod#?d=#URLEncodedFormat(form.d&'/'&arrDir[i])#" style="color:##000000;">#arrDir[i]#</a><br />
				#myColumnOutput.ifLastRow(i)#
			</cfloop>
			</table>
		</cfif>
		<cfscript>
		inputStruct = StructNew();
		inputStruct.colspan = 4;
		inputStruct.rowspan = ArrayLen(arrImages);
		inputStruct.vertical = true;
		myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
		</cfscript>
		<cfif ArrayLen(arrImages) NEQ 0>
			<strong>Images:</strong><br />
		</cfif>
		<cfloop from="1" to="#ArrayLen(arrImages)#" index="i">
			<cfset tempImage=false>
				<div style="width:100px; height:100px; float:left; text-align:center; overflow:hidden; border:1px solid ##CCCCCC; padding:0px; margin-right:10px; margin-bottom:10px;font-size:10px;">
				<a href="/z/admin/files/align?galleryMode=true&amp;d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&arrImages[i])#"><img class="zLazyImage" src="/z/a/images/loading.gif" data-original="#variables.siteRootDir##form.d&'/'&arrImages[i]#" style="max-width:100px; max-height:100px;"  /></a></div>
		</cfloop> 
		</td>
		</tr>
	<cfelse>
		<cfloop query="qDir">
			<tr>
			<td style="vertical-align:top;">
			<cfif qDir.type EQ 'dir'>
				<a href="/z/admin/files/#form.curListMethod#?d=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">#qDir.name#</a>
			<cfelse>
				<cfset fileext=application.zcore.functions.zGetFileExt(qDir.name)>
				<cfif structkeyexists(request.zos, 'fileImage') and application.zcore.functions.zso(request.zos.fileImage, 'addDisabled',false,false) EQ false>
					<cfif 'jpg' EQ fileext OR 'gif' EQ fileext or 'png' EQ fileext>
						<a href="/z/admin/files/edit?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;"><img class="zLazyImage" src="/z/a/images/loading.gif" style="max-width:100px; max-height:100px;vertical-align:bottom;padding-left:4px; padding-right:4px;" data-original="#variables.siteRootDir##urlencodedformat(form.d)&'/'&qDir.name#">#qDir.name#</a>
					<cfelse>
						<a href="/z/admin/files/editFile?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;"><img src="/z/images/page/file.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">#qDir.name#</a>
					</cfif>
				<cfelse>
					<cfif structkeyexists(request.zos, 'fileImage') and application.zcore.functions.zso(request.zos.fileImage, 'enableDownload',false,false)>
						<cfif 'jpg' EQ fileext OR 'gif' EQ fileext or 'png' EQ fileext>
							<a href="/z/admin/files/download?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;"><img src="/z/images/page/image.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">#qDir.name#</a>
						<cfelse>
							<a href="/z/admin/files/download?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;"><img src="/z/images/page/file.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">#qDir.name#</a>
						</cfif>
					
					<cfelse>
						<cfif 'jpg' EQ fileext OR 'gif' EQ fileext>
							<a href="#variables.siteRootDir##urlencodedformat(form.d)&'/'&qDir.name#" style="color:##000000;"><img src="/z/images/page/image.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">#qDir.name#</a>
						<cfelse>
							<a href="#variables.siteRootDir##urlencodedformat(form.d)&'/'&qDir.name#" style="color:##000000;"><img src="/z/images/page/file.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">#qDir.name#</a>
						</cfif>
					</cfif>				
				</cfif>
			</cfif></td>
			<td style="vertical-align:top;">#DateFormat(qDir.dateLastModified,'mm/dd/yyyy')&' '&TimeFormat(qDir.dateLastModified,'HH:mm:ss')#
			</td>
			<td style="vertical-align:top;">
			<cfif qDir.type EQ 'file'>
					<a href="/z/misc/download/index?fp=#URLEncodedFormat(replace(variables.currentDir, request.zos.globals.privatehomedir, "/")&qDir.name)#" style="color:##000000;">Download</a> | 
					<a href="/z/admin/files/<cfif right(qDir.name,4) EQ ".png" OR right(qDir.name,4) EQ ".jpg" OR right(qDir.name,4) EQ '.gif'>edit<cfelse>editFile</cfif>?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;">View<cfif right(qDir.name,4) EQ ".png" OR right(qDir.name,4) EQ ".jpg" OR right(qDir.name,4) EQ '.gif' or right(qDir.name,3) EQ ".js" or right(qDir.name,4) EQ ".css" or right(qDir.name,4) EQ ".htm">/Edit</cfif></a> 
			</cfif>
			<cfif isDefined('request.zos.fileImage.deleteDisabled') EQ false or request.zos.fileImage.deleteDisabled EQ false>
				<cfif qDir.type EQ 'dir'>
					<cfdirectory directory="#variables.currentDir#/#qDir.name#" name="qDirCheck" action="list">
					<cfif qDirCheck.recordcount NEQ 0>
						Delete Contents First
					<cfelse>
						<a href="/z/admin/files/deleteFolder?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;">Delete</a>
					</cfif>
				<cfelse> | 
					<a href="/z/admin/files/delete?d=#URLEncodedFormat(form.d)#&amp;f=#URLEncodedFormat(form.d&'/'&qDir.name)#" style="color:##000000;">Delete</a>
				</cfif>
			</cfif>
			</td>
			</tr>
		</cfloop> 
	</cfif>
	</table>
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery-lazyload/jquery.lazyload.min.js");
	application.zcore.skin.addDeferredScript('
		var lazyImages=$("img.zLazyImage"); 
		if(typeof lazyImages.lazyload != "undefined"){
			lazyImages.lazyload(); 
		}
	');
	</cfscript>
</cffunction>

<cffunction name="serveFile" localmode="modern" access="remote">
	<cfscript>
		virtualFile = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-file' );
		virtualFile.serveVirtualFile();
	</cfscript>
</cffunction>

<cffunction name="downloadFile" localmode="modern" access="remote">
	<cfscript>
		virtualFile = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.virtual-file.controller.virtual-file' );
		virtualFile.downloadVirtualFile();
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
