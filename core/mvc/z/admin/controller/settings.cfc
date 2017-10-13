<cfcomponent>
<cfoutput> 
<cffunction name="processFavicon" access="remote" localmode="modern" roles="administrator">
	<cfscript>
	setting requesttimeout="100";
	//application.zcore.functions.z404("this is not working yet");	abort;
	form.iconFile=application.zcore.functions.zso(form, 'iconFile');

	destination=request.zos.globals.privatehomedir&"zupload/settings/";
	application.zcore.functions.zCreateDirectory(destination); 
	if(structkeyexists(form,'iconFile_delete')){
		application.zcore.functions.zDeleteFile(destination&'icon-logo-original.png');
		application.zcore.functions.zDeleteFile(destination&'favicon.ico');
		application.zcore.functions.zDeleteFile(destination&'apple-icon-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-144x144-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-114x114-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-72x72-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon-57x57-precomposed.png');
		application.zcore.functions.zDeleteFile(destination&'apple-touch-icon.png');
		structdelete(application.siteStruct[request.zos.globals.id], 'iconLogoExists');
	}
	fail=false;
	if(form.iconFile NEQ ""){
		form.iconFile=application.zcore.functions.zUploadFile("iconFile", destination, false);
		if(right(form.iconFile, 4) NEQ ".png"){
			application.zcore.functions.zDeleteFile(destination&form.iconFile);
			application.zcore.status.setStatus(request.zsid, "The Icon Logo file must be a png.", form, true);
			fail=true;
		}
		if(not fail){
			if(form.iconFile NEQ "icon-logo-original.png"){
				application.zcore.functions.zDeleteFile(destination&'icon-logo-original.png');
				application.zcore.functions.zRenameFile(destination&form.iconFile, destination&'icon-logo-original.png');
			}

			source=destination&'icon-logo-original.png';

			result=application.zcore.functions.zSecureCommand("saveFaviconSet#chr(9)##source##chr(9)##destination#", "50");
			if(result EQ 0){
				application.zcore.status.setStatus(request.zsid, "Failed to save icon set", form, true);
				fail=true;
			}else{
				application.siteStruct[request.zos.globals.id].iconLogoExists=true;
			}
		}
	}
	if(not fail){
		application.zcore.status.setStatus(request.zsid, "Settings saved successfully"); 
	}
	application.zcore.functions.zRedirect("/z/admin/settings/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.functions.zStatusHandler(request.zsid, true); 
	</cfscript>	
	<h2>Settings</h2>
	<form class="zFormCheckDirty" id="uploadForm1" action="/z/admin/settings/processFavicon" enctype="multipart/form-data" method="post">
		<table class="table-list">
			<tr>
				<th>Icon Logo</th>
				<td>
					<cfscript>
					form.iconFile="icon-logo-original.png";
					if(!fileexists(request.zos.globals.privateHomeDir&"zupload/settings/"&form.iconFile)){
						form.iconFile="";
					}
					echo(application.zcore.functions.zInputImage("iconFile", request.zos.globals.privateHomeDir&"zupload/settings/", "/zupload/settings/"));
					</cfscript><br />
					Please upload a 24-bit transparent png at least 256x256. It should be pre-cropped to be a square image.  <br />
					This will be used for the touch icons and the favicon.  This feature generates many different images sizes.
				</td>
			</tr>
			<tr>
				<th>&nbsp;</th>
				<td><input type="submit" name="submit1" value="Save" class="z-manager-search-button" /></td>
			</tr>
		</table>
	</form>
</cffunction>

</cfoutput>
</cfcomponent>