<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript> 
	form.pageStatus = application.zcore.functions.zso(form, "pageStatus", true, 1);
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages");   
	</cfscript>
</cffunction>
    
<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject;
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages", true); 
	db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#  
	WHERE page_id = #db.param(form.page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	page_deleted=#db.param(0)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){ 
		application.zcore.functions.zReturnJson({ success:false, errorMessage:'You don''t have permission to delete this page.'});  
	} 
	application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.page_image_library_id); 
	// don't delete because rewrite rules must persist
	application.zcore.app.getAppCFC("page").searchIndexDeletepage(form.page_id);
	db.sql="UPDATE #db.table("page", request.zos.zcoreDatasource)# 
	SET page_deleted=#db.param(1)#, 
	page_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE page_id = #db.param(form.page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	page_deleted=#db.param(0)# ";
	db.execute("q"); 
	application.zcore.status.setStatus(request.zsid, 'Page deleted.'); 
	application.zcore.functions.zDeleteUniqueRewriteRule(qCheck.page_unique_url);

	application.zcore.functions.zReturnJson({ success:true});
	</cfscript>
</cffunction>
    
<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var myForm=structnew(); 
	var db=request.zos.queryObject;
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages", true);
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);
 
	
	uniqueChanged=false;
	oldURL='';
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'page_unique_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#  
		WHERE page_id = #db.param(form.page_id)# and 
		page_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'Invalid page.',form,true);
			application.zcore.functions.zRedirect('/z/section/admin/page-admin/index?zsid=#request.zsid#');
		} 
		if(application.zcore.user.checkServerAccess()){
			if(structkeyexists(form, 'page_unique_url') and qcheck.page_unique_url NEQ form.page_unique_url){
				uniqueChanged=true;	
			}
		}
	}  
	myForm.page_name.required=true;
	myForm.page_name.friendlyName="Title"; 
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(application.zcore.functions.zso(form,'page_unique_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'page_unique_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		errors=true;
	}
	if(errors){
		application.zcore.status.setStatus(request.zsid,false,form,true);
		if(form.method EQ "update"){
			application.zcore.functions.zRedirect("/z/section/admin/page-admin/edit?page_id=#form.page_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}else{
			application.zcore.functions.zRedirect("/z/section/admin/page-admin/add?zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}
	} 
	csn=form.page_name&" "&form.page_id&" "& form.page_text&" "&form.page_text2&" "&form.page_text3;
	form.page_search=application.zcore.functions.zCleanSearchText(csn, true);

	
	if(application.zcore.app.siteHasApp("listing")){
		if(application.zcore.app.siteHasApp("listing")){
			if(isquery(qcheck) and structkeyexists(qcheck, 'recordcount')){
				form.page_saved_search_id=qcheck.page_saved_search_id;
			}else{
				form.page_saved_search_id="";
			}
			if(form.page_search_mls EQ 1) {
				form.page_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.page_saved_search_id, '', form);
			} else {
				form.page_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.page_saved_search_id);
			}
		}
	}
	if(application.zcore.functions.zso(form, 'convertLinks') EQ 1){
		form.page_text=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name, form.page_text);
		form.page_text2&"_2"=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name&"_2", form.page_text2);
		form.page_text3&"_3"=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name&"_3", form.page_text3);
		form.page_summary=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name, form.page_summary);
	}
	
	ts=StructNew();
	ts.table="page";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	form.page_updated_datetime=request.zos.mysqlnow;
	if(form.method EQ 'insert'){
		form.page_created_datetime = form.page_updated_datetime;
		form.page_id = application.zcore.functions.zInsert(ts);
		if(form.page_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to create page',form,true);
			application.zcore.functions.zRedirect("/z/section/admin/page-admin/add?zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Page to update page',form,true);
			application.zcore.functions.zRedirect("/z/section/admin/page-admin/edit?page_id=#form.page_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}
	}
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'page_image_library_id'));
	  
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect("/z/section/admin/page-admin/getReturnLayoutRowHTML?page_id=#form.page_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}else{
		if(structkeyexists(form, 'page_id') and structkeyexists(request.zsession, 'page_return'&form.page_id) and uniqueChanged EQ false){	
			tempURL = request.zsession['page_return'&form.page_id];
			StructDelete(request.zsession, 'page_return'&form.page_id);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{	
			application.zcore.functions.zRedirect('/z/section/admin/page-admin/index?zsid=#request.zsid#');
		}
	}
	</cfscript>
</cffunction>
    
<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var currentMethod=form.method;
	var db=request.zos.queryObject; 
	init();
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	} 
	form.page_id=application.zcore.functions.zso(form, 'page_id');
	if(currentMethod EQ "add"){
		application.zcore.template.appendTag('scripts','<script type="text/javascript">/* <![CDATA[ */ 
		var zDisableBackButton=true;
		zArrDeferredFunctions.push(function(){
			zDisableBackButton=true;
		});
		/* ]]> */</script>');
	}
	 
	db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#  
	WHERE page_id = #db.param(form.page_id)# and 
	page_deleted=#db.param(0)# and 
	page.site_id = #db.param(request.zos.globals.id)# ";
	qpage=db.execute("qpage");
	if(currentMethod EQ 'edit'){
		if(qpage.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'Invalid page.',false,true);
			application.zcore.functions.zRedirect('/z/section/admin/page-admin/index?zsid=#request.zsid#');
		}
	}  
	application.zcore.functions.zQueryToStruct(qpage, form,'page_id,site_id');
	application.zcore.functions.zStatusHandler(request.zsid,true, false, form);
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "page_return"&form.page_id, form.return, true);		
	}
	if(currentMethod EQ 'add'){
		writeoutput('<h2>Add Page</h2>');
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
	}else{
		writeoutput('<h2>Edit Page</h2>');
	}
	ts=StructNew();
	ts.name="zMLSSearchForm";
	ts.ajax=false;
	if(currentMethod EQ 'add'){
		newAction="insert";
	}else{
		newAction="update";
	}
	ts.class="zFormCheckDirty";
	ts.enctype="multipart/form-data";
	ts.action="/z/section/admin/page-admin/#newAction#?page_id=#form.page_id#&modalpopforced=#form.modalpopforced#";
	ts.method="post";
	ts.successMessage=false; 
	application.zcore.functions.zForm(ts);
	 
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Basic", "Advanced"]); 
	tabCom.setMenuName("member-page-edit");
	cancelURL=application.zcore.functions.zso(request.zsession, 'page_return'&form.page_id); 
	if(cancelURL EQ ""){
		cancelURL="/z/section/admin/page-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#";
	}
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	if(form.modalpopforced EQ 1){
		echo('
		<script type="text/javascript">
		zArrDeferredFunctions.push(function(){
			$(".tabCancelButton").on("click", function(e){
				e.preventDefault();
				window.parent.zCloseModal();
				return false;
			});
		});
		</script>
		');
	}
	</cfscript>
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Basic")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr> 
			<th style="vertical-align:top; ">
				Title *</th>
			<td style="vertical-align:top; ">
				<input type="text" name="page_name" value="#HTMLEditFormat(form.page_name)#" maxlength="150" size="100" />
			</td>
		</tr>

		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Summary Text","member.page.edit page_summary")#</th>
			<td style="vertical-align:top; ">
				<cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "page_summary";
				htmlEditor.value			= form.page_summary;
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 250;
				htmlEditor.create();
				</cfscript>   
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Body Column 1","member.page.edit page_text")#</th>
			<td style="vertical-align:top; "> 
				<cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "page_text";
				htmlEditor.value			= form.page_text;
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 400;
				htmlEditor.create();
				</cfscript>  
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Body Column 2","member.page.edit page_text2")#</th>
			<td style="vertical-align:top; ">
				<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.page_text2)>
					<p class="bodyColumn2Add"><a href="##" onclick="$('.bodyColumn2').show(); $('.bodyColumn2Add').hide(); return false;">Edit Column 2 (optional)</a></p>
				</cfif>
	
				<div class="bodyColumn2" style="<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.page_text2)>display:none;</cfif>">
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "page_text2";
					htmlEditor.value			= form.page_text2;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript>
				</div>  
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Body Column 3","member.page.edit page_text3")#</th>
			<td style="vertical-align:top; "> 
				<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.page_text3)>
					<p class="bodyColumn3Add"><a href="##" onclick="$('.bodyColumn3').show(); $('.bodyColumn3Add').hide(); return false;">Edit Column 3 (optional)</a></p>
				</cfif>
	
				<div class="bodyColumn3" style="<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.page_text3)>display:none;</cfif>">
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "page_text3";
					htmlEditor.value			= form.page_text3;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript>  
				</div>
			</td>
		</tr>

		<tr>
			<th style="width:1%; white-space:nowrap;">Cache External Images:</th>
			<td>
			<cfscript>
			form.convertLinks=application.zcore.functions.zso(form, 'convertLinks', true, 0); 
			ts = StructNew();
			ts.name = "convertLinks";
			ts.radio=true;
			ts.separator=" ";
			ts.listValuesDelimiter="|";
			ts.listLabelsDelimiter="|";
			ts.listLabels="Yes|No";
			ts.listValues="1|0";
			application.zcore.functions.zInput_Checkbox(ts);
			</cfscript> | Selecting "Yes", will cache the external images in the html editor to this domain.
			</td>
		</tr>
		<tr>
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.page.edit page_image_library_id")#</th>
			<td>
				<cfscript>
				ts=structnew();
				ts.name="page_image_library_id";
				ts.value=form.page_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript>
			</td>
		</tr>

		<tr>
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photo Layout","member.page.edit page_image_library_layout")#</th>
			<td>
				<cfscript>
				ts=structnew();
				ts.name="page_image_library_layout";
				ts.value=form.page_image_library_layout;
				application.zcore.imageLibraryCom.getLayoutTypeForm(ts);
				</cfscript>
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("META Title","member.page.edit page_metatitle")#</th>
			<td style="vertical-align:top; ">
				<input type="text" name="page_metatitle" value="#HTMLEditFormat(form.page_metatitle)#" maxlength="150" size="100" /><br /> (Meta title is optional and overrides the &lt;TITLE&gt; HTML element to be different from the visible page title.)
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.page.edit page_metakey")#</th>
			<td style="vertical-align:top; "> 
				<textarea name="page_metakey" rows="5" cols="60">#form.page_metakey#</textarea>
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.page.edit page_metadesc")#</th>
			<td style="vertical-align:top; "> 
				<textarea name="page_metadesc" cols="60" rows="5">#form.page_metadesc#</textarea>
			</td>
		</tr>		
		<tr> 
			<th style="vertical-align:top; ">Active</th>
			<td style="vertical-align:top; ">
				#application.zcore.functions.zInput_Boolean("page_status")#
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Unique URL","member.page.edit page_unique_url")#</th>
			<td style="vertical-align:top; "> 	
				<cfif currentMethod EQ "add">
					#application.zcore.functions.zInputUniqueUrl("page_unique_url", true)#
				<cfelse>
					#application.zcore.functions.zInputUniqueUrl("page_unique_url")#
				</cfif>
			</td>
		</tr> 
	</table>
	#tabCom.endFieldSet()# 
	#tabCom.beginFieldSet("Advanced")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
	 
	</table>
 
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	#application.zcore.functions.zEndForm()#
	 
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 

	application.zcore.template.setTag("title", "Pages");
 
	if(not application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
		return;
	} 
	init();  
	application.zcore.functions.zStatusHandler(request.zsid,true, false, form);  
	form.searchText=replace(application.zcore.functions.zso(form, 'searchText'), '+', ' ', 'all');
	form.searchTextOriginal=replace(replace(replace(form.searchText, '+', ' ', 'all'), '@', '_', 'all'), '"', '', "all");
	form.searchText=application.zcore.functions.zCleanSearchText(form.searchText, true);
	if(form.searchText NEQ "" and isNumeric(form.searchText) EQ false and len(form.searchText) LTE 2){
		application.zcore.status.setStatus(request.zsid,"The search searchText must be 3 or more characters.",form);
		application.zcore.functions.zRedirect("/z/section/admin/page-admin/index?zsid=#request.zsid#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}
	searchTextReg=rereplace(form.searchText,"[^A-Za-z0-9[[:white:]]]*",".","ALL");
	searchTextOReg=rereplace(form.searchTextOriginal,"[^A-Za-z0-9 ]*",".","ALL");
	Request.zScriptName2 = "/z/section/admin/page-admin/index?pageStatus=#form.pageStatus#&searchtext=#urlencodedformat(application.zcore.functions.zso(form, 'searchtext'))#&page_parent_id=#application.zcore.functions.zso(form, 'page_parent_id')#";
	 
	writeoutput('
	<div class="z-manager-list-view">
		<div class="z-float">
			<h2 id="pages_regular" style="display:inline-block;">Pages</h2>');
 
	echo(' &nbsp;&nbsp; ');
	echo('<a href="/z/section/admin/page-admin/add?page_parent_id=#application.zcore.functions.zso(form, 'page_parent_id')#&amp;return=1&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#" class="z-button">Add</a> '); 
	writeoutput('	</div>');
 
	ts=structnew();
	ts.image_library_id_field="page.page_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT *, 
	#db.trustedSQL("if(page.page_price = 0,0.00,page.page_price) page_price2, 
	if(page.page_mls_number = #db.param('')#,'z',page.page_mls_number) page_mls_number2, 
	if(page.page_address = #db.param('')#,'z',page.page_address) page_address2, ")# ";
	if(form.searchText NEQ ''){
		db.sql&="MATCH(page.page_search) AGAINST (#db.param(form.searchText)#) as score , 
			MATCH(page.page_search) AGAINST (#db.param(form.searchTextOriginal)#) as score2 , 
		if(page.page_id = #db.param(form.searchText)#, #db.param(1)#,#db.param(0)#) matchingId, 
		#db.trustedSQL("if(concat(page.page_id,' ',cast(page.page_price as char(11)),' ',page.page_address,' ',page.page_mls_number)")# like #db.param('%#form.searchTextOriginal#%')#,#db.param(1)#,#db.param(0)#) as matchPriceAddress, ";
	}
	db.sql&="
	count(c2.page_id) children 
	#db.trustedSQL(rs2.select)#  
	FROM ( #db.table("page", request.zos.zcoreDatasource)# page ) 
	#db.trustedSQL(rs2.leftJoin)#
	LEFT JOIN #db.table("page", request.zos.zcoreDatasource)# c2 ON 
	c2.page_parent_id = page.page_id and 
	c2.page_deleted= #db.param(0)# and 
	c2.site_id = page.site_id 
	
	WHERE 
	page.site_id = #db.param(request.zos.globals.id)# ";
	if(form.searchText NEQ ''){
		db.sql&=" and 
		
		(#db.trustedSQL("concat(page.page_id,' ',cast(page.page_price as char(11)),' ',page.page_address,' ',page.page_mls_number)")# like 
		#db.param('%#form.searchTextOriginal#%')#  or 
		page.page_text like #db.param('%#form.searchTextOriginal#%')# or 
		(
		(( ";
		if(application.zcore.enableFullTextIndex){
			db.sql&=" MATCH(page.page_search) AGAINST (#db.param(form.searchText)#) or 
			MATCH(page.page_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchText, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE) ";
		}else{
			db.sql&=" page.page_search like #db.param('%#replace(form.searchText,' ','%','ALL')#%')# ";
		}
		db.sql&=" ) or ( ";
		
		if(application.zcore.enableFullTextIndex){
			db.sql&=" MATCH(page.page_search) AGAINST (#db.param(form.searchTextOriginal)#) or 
			MATCH(page.page_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchTextOriginal, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE) ";
		}else{
			db.sql&=" page.page_search like #db.param('%#replace(form.searchTextOriginal,' ','%','ALL')#%')# ";
		}
		db.sql&=" 
		)) 
		)) ";
	}else{
		if(form.mode EQ "sorting"){
			if(structkeyexists(form, 'page_parent_id')){
				db.sql&=" and page.page_parent_id = #db.param(form.page_parent_id)# ";
			}else{
				db.sql&=" and page.page_parent_id = #db.param('0')# ";
			}
		}
	}
	if(form.pageStatus EQ 1){
		db.sql&=" and page.page_status<>#db.param('2')# ";
	}else if(form.pageStatus EQ 0){
		db.sql&=" and page.page_status=#db.param('2')# ";
	}
	db.sql&=" and page.page_deleted = #db.param('0')# and 
	page.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)#  ";

	if(not application.zcore.user.checkServerAccess()){
		db.sql&=" and page.page_hide_edit = #db.param(0)#  ";
	}
	db.sql&=" 
	GROUP BY page.page_id 
	ORDER BY ";
	if(form.mode EQ "sorting"){
		if(request.sortComSQL NEQ ''){
			db.sql&=" #request.sortComSQL# page.page_sort ";
		}else{
			if(form.searchText NEQ ''){
				db.sql&=" matchPriceAddress DESC ,matchingId DESC ";
				if(application.zcore.enableFullTextIndex){
					db.sql&="  ,score2 DESC, score DESC  ";
				}
				db.sql&=" , ";
			}
			if(request.parentChildSorting EQ 1){
				db.sql&=" page.page_price DESC ";
			}else if(request.parentChildSorting EQ 2){
				db.sql&=" page.page_price ASC ";
			}else if(request.parentChildSorting EQ 3){
				db.sql&=" page.page_name ASC ";
			}else if(request.parentChildSorting EQ 0){
				db.sql&=" page.page_parent_id ASC, page.page_sort ASC, page.page_datetime DESC, page.page_created_datetime DESC ";
			}
		}
	}else{
		db.sql&=" page.page_parent_id ASC, page.page_sort ASC, page.page_datetime DESC, page.page_created_datetime DESC ";
	}
	qSite=db.execute("qSite");
	form.searchText=form.searchTextOriginal; 
	g="";
	arrNav=ArrayNew(1);
	if(application.zcore.functions.zso(form, 'searchtext') EQ ''){
		if(qsite.recordcount EQ 0){
			cpi=application.zcore.functions.zso(form, 'page_parent_id',true);
		}else{
			cpi=qsite.page_parent_id;
		}
	}else{
		cpi=0;
	}
	arrName=ArrayNew(1);
	parentparentid='0';
	parentChildGroupId=0; 
	for(g=1;g LTE 255;g++){
		db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)# page 
		WHERE page_id = #db.param(cpi)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		page_deleted=#db.param(0)# ";
		qpar=db.execute("qpar");
		if(qpar.recordcount EQ 0){
			break;
		}
		if(g EQ 1){
			parentParentId=qpar.page_parent_id;
		}
		ArrayAppend(arrName, qpar.page_name);
		arrayappend(arrNav, '<a href="/z/section/admin/page-admin/index?page_parent_id=#qpar.page_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">#qPar.page_name#</a> / ');
		cpi=qpar.page_parent_id;
		if(cpi EQ 0){
			break;
		}
	}
	</cfscript>


	<div class="z-float z-mb-10"> 
		<cfscript>
		if(form.site_x_option_group_set_id NEQ 0){
			if((structkeyexists(form, 'page_parent_id') EQ false or form.page_parent_id EQ 0) and application.zcore.functions.zso(form, 'searchtext') EQ ''){
				echo ('Section Root');
			}else{
				echo('<a href="/z/section/admin/page-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Section Root</a> / ');
			}
		}else{
			if((structkeyexists(form, 'page_parent_id') EQ false or form.page_parent_id EQ 0) and application.zcore.functions.zso(form, 'searchtext') EQ ''){
				writeoutput('Home /');
			}else{
				writeoutput('<a href="/z/section/admin/page-admin/index">Home</a> / ');
			}
		}
		for(i=arraylen(arrNav);i GTE 2;i=i-1){
			writeoutput(arrNav[i]);
		}
		if(ArrayLen(arrNav) NEQ 0){
			writeoutput(arrName[1]);
		}
		</cfscript> 
	</div>

	<cfscript>
	arrSearch=listtoarray(form.searchtext," ");
	if(arraylen(arrSearch) EQ 0){
		arrSearch[1]="";	
	}
	</cfscript>
	
	<cfif application.zcore.app.siteHasApp("listing") and form.page_parent_id NEQ 0>
		<div style="float:left;">Sorting method: <cfif request.parentChildSorting EQ 1>Price Descending<cfelseif request.parentChildSorting EQ 2>Price Ascending<cfelseif request.parentChildSorting EQ 3>Alphabetic<cfelse>Manual (Click black arrows)</cfif> | </div>
		<div style="float:left; width:150px;"><a href="/z/section/admin/page-admin/edit?page_id=#application.zcore.functions.zso(form, 'page_parent_id')#&amp;return=1&amp;mode=#form.mode#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">#application.zcore.functions.zOutputHelpToolTip("Change Sorting Method","member.page.list changeSortingMethod")#</a></div><br />
	</cfif> 

	<form name="myForm22" action="/z/section/admin/page-admin/index" method="GET" style="margin:0px;"> 
		<input type="hidden" name="site_x_option_group_set_id" value="#form.site_x_option_group_set_id#">
		#application.zcore.siteOptionCom.setIdHiddenField()#
		<div class="z-float-left z-pr-10 z-pb-10">
			Search: 
			<input type="text" name="searchtext" id="searchtext" value="#htmleditformat(application.zcore.functions.zso(form, 'searchtext'))#" style="min-width:100px; width:300px;max-width:100%; min-width:auto;" size="20" maxchars="10" /> 
		</div>
		<div class="z-float-left z-pr-10 z-pb-10">
			Active: #application.zcore.functions.zInput_Boolean("pageStatus")# 
			</div>
			<div class="z-float-left z-pr-10 z-pb-10">
			<input type="submit" name="searchForm" value="Search" class="z-manager-search-button" /> 
			<cfif application.zcore.functions.zso(form, 'searchtext') NEQ ''>
				<input type="button" name="searchForm2" value="Clear Search" class="z-manager-search-button" onclick="window.location.href='/z/section/admin/page-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#';" />
			</cfif>
		</div>
		<input type="hidden" name="zIndex" value="1" />
	</form>
	<cfif qSite.recordcount EQ 0>
		<div class="z-float z-mb-10">No page added yet. </div>
	<cfelse>
		<table <cfif form.mode EQ "sorting">id="sortRowTable"</cfif> style="border-spacing:0px; width:100%;" class="table-list">
			<thead>
			<tr>
				<th class="z-hide-at-767"><a href="#request.qSortCom.getColumnURL("page.page_id", Request.zScriptName2)#">ID</a> #request.qSortCom.getColumnIcon("page.page_id")#</th>
				<th class="z-hide-at-767">Photo</th>
				<th>
					<a href="#request.qSortCom.getColumnURL("page.page_name", Request.zScriptName2)#">Title</a> #request.qSortCom.getColumnIcon("page.page_name")# 
					<cfif application.zcore.app.siteHasApp("listing")>
						/ <a href="#request.qSortCom.getColumnURL("page_address2", Request.zScriptName2)#">Address</a>
						 #request.qSortCom.getColumnIcon("page_address2")# / 
						 <a href="#request.qSortCom.getColumnURL("page_mls_number2", Request.zScriptName2)#">MLS ##</a> 
						 #request.qSortCom.getColumnIcon("page_mls_number2")# / 
						 <a href="#request.qSortCom.getColumnURL("page_price2", Request.zScriptName2)#">Price</a> #request.qSortCom.getColumnIcon("page_price2")#
					 </cfif>
				 </th> 
				<th>Last Updated</th> 
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
			<cfscript>
			pageLookupStruct={}; 
			request.parentLookupStruct={}; 
			arrOrder=[];
			currentRow=0;
 
			if(form.mode EQ "sorting"){ 
				for(row in qSite){ 
					arrayAppend(arrOrder, row);
				} 
			}else{
				for(row in qSite){ 
					if(not structkeyexists(pageLookupStruct, row.page_parent_id)){
						pageLookupStruct[row.page_parent_id]=[];
					}
					arrayAppend(pageLookupStruct[row.page_parent_id], row); 
					request.parentLookupStruct[row.page_id]=row.page_parent_id;
				} 
				getpageSiteMapOrder(arrOrder, 0, pageLookupStruct);  
			}
			for(i12=1;i12<=arraylen(arrOrder);i12++){
				row=arrOrder[i12];
				currentRow++;
				echo('<tr ');
				if(form.mode EQ "sorting"){
					echo(variables.queueSortCom.getRowHTML(row.page_id));
				}
				if(currentrow MOD 2 EQ 0){
					echo('class="row1"');
				}else{
					echo('class="row2"');
				}
				echo('>');
				getLayoutRowHTML(row);
				echo('</tr>');
			}
			</cfscript>
			</tbody>
		</table> 
	</cfif> 

	<cfscript>
	
	if(application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_parent_id=#db.param(0)# and 
		site_option_group_enable_unique_url=#db.param(1)# and 
		site_option_group_deleted=#db.param(0)# 
		ORDER BY site_option_group_display_name ASC";
		qGroup=db.execute("qGroup");
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_parent_id=#db.param(0)# and 
		site_option_group_allow_public=#db.param(1)# and 
		site_option_group_deleted=#db.param(0)# 
		ORDER BY site_option_group_display_name ASC";
		qGroupPublic=db.execute("qGroupPublic");
	
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_parent_id=#db.param(0)# and 
		site_option_group_enable_unique_url=#db.param(0)# and  
		site_option_group_allow_public=#db.param(0)# and 
		site_option_group_deleted=#db.param(0)# 
		ORDER BY site_option_group_display_name ASC";
		qGroupCustom=db.execute("qGroupCustom");

		echo('
			<div class="z-float z-mt-10">
			<h2>Other Site page</h2>
			<ul style="margin-top:0px;">
				');

		if(qGroup.recordcount){
			echo('<li><a href="##pages_custom">Custom Landing Pages</a></li> ');
		}
		if(qGroupCustom.recordcount){
			echo('<li><a href="##pages_customtypes">Custom page Types</a></li> ');
		}

		echo('<li><a href="##pages_publicforms">Public Forms</a></li> 
			<li><a href="##pages_builtin">Built-in Landing Pages</a></li> 
		</ul></div>'); 
	}
	</cfscript>
	<div style="float:left; width:100%; line-height:1.7; font-size:16px; padding-top:20px;">
		<cfif application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")>
		 
			<cfif qGroup.recordcount>
				<h2 id="pages_custom">Custom Landing Pages</h2>
				<p>Your web site has additional custom made landing pages that can be edited at the following locations:</p>
				<ul>
				<cfloop query="qGroup">
					<li><a href="/z/admin/site-options/manageGroup?site_option_group_id=#qGroup.site_option_group_id#">#qGroup.site_option_group_display_name#<cfif qGroup.site_option_group_limit NEQ 1 and right(qGroup.site_option_group_display_name, 1) NEQ "s">(s)</cfif></a></li>
				</cfloop>
				</ul>
			</cfif>
 
			<cfif qGroupCustom.recordcount>
				<h2 id="pages_customtypes">Custom page Types</h2>
				<p>Your web site has additional custom page types that can be edited at the following locations:</p>
				<ul>
				<cfloop query="qGroupCustom">
					<li><a href="/z/admin/site-options/manageGroup?site_option_group_id=#qGroupCustom.site_option_group_id#">#qGroupCustom.site_option_group_display_name#<cfif qGroupCustom.site_option_group_limit NEQ 1 and right(qGroupCustom.site_option_group_display_name, 1) NEQ "s">(s)</cfif></a></li>
				</cfloop>
				</ul>
			</cfif>
	
		</cfif>

		<h2 id="pages_publicforms">Public Forms</h2>
		<cfscript>
		echo('<ul>');
		// qGroupPublic
		if(application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")){
			for(row in qGroupPublic){
				link=row.site_option_group_public_form_url;
				if(link EQ ""){
					link="/z/misc/display-site-option-group/add?site_option_group_id="&row.site_option_group_id;
				}	
				echo('<li><a href="'&link&'" target="_blank">'&row.site_option_group_display_name&'</a></li>');
			}
		}

		echo('<li><a href="/z/misc/inquiry/index" target="_blank">Inquiry Form</a></li>
		<li><a href="/z/misc/mailing-list/index" target="_blank">Mailing List Signup Form</a></li>
		<li><a href="/z/misc/loan-calculator/index" target="_blank">Loan Calculator Form</a></li>
		<li><a href="/z/misc/mortgage-quote/index" target="_blank">Mortgage Quote Form</a></li>');
		if(request.zos.globals.enableSendToFriend EQ 1){
			echo('<li><a href="/z/misc/share-with-friend/index?link=#request.zos.globals.domain#" target="_blank">Share With Friend Form</a></li>');
		}
		if(application.zcore.app.siteHasApp("rental")){
			link=application.zcore.app.getAppCFC("rental").getRentalInquiryLink();
			echo('<li><a href="#link#" target="_blank">Rental - Inquiry Form</a></li>');
		}


		if(application.zcore.app.siteHasApp("listing")){
			echo('
			<li><a href="/z/misc/mortgage-calculator/index" target="_blank">Real Estate - Mortgage Calculator</a></li> 
			<li><a href="/z/listing/cma-inquiry/index" target="_blank">Real Estate - CMA Inquiry Form</a></li>
			<li><a href="/z/listing/new-listing-email-signup/index" target="_blank">Real Estate - New Listings By Email Signup Form</a></li>');
		}
		echo('</ul>');
		</cfscript>

		<h2 id="pages_builtin">Built-in Landing Pages</h2>
		<cfscript>
		echo('<ul>');
		echo('
		<li><a href="/z/misc/system/missing" target="_blank">404 Not Found Page</a></li>
		<li><a href="/z/misc/system/legal" target="_blank">Legal Notices</a></li>
		<li><a href="/z/misc/members/index" target="_blank">Our Team - Public User Profiles</a></li> 
		<li><a href="/z/user/privacy/index" target="_blank">Privacy Policy</a></li>
		<li><a href="/z/user/preference/register" target="_blank">Public User Create Account</a> (You have to logout to view this)</li>
		<li><a href="/z/user/home/index" target="_blank">Public User Home Page</a></li>
		<li><a href="/z/user/preference/index" target="_blank">Public User Login</a> (You have to logout to view this)</li>
		<li><a href="/z/user/out/index" target="_blank">Public User Opt Out Form</a></li> 
		<li><a href="/z/user/preference/form" target="_blank">Public User Preferences</a></li>
		<li><a href="/z/user/reset-password/index" target="_blank">Public User Reset Password</a></li>
		<li><a href="/z/misc/search-site/search" target="_blank">Search Site</a></li> 
		<li><a href="/z/misc/site-map/index" target="_blank">Site Map</a></li>
		<li><a href="/z/user/terms-of-use/index" target="_blank">Terms of Use</a></li>');
		if(application.zcore.app.siteHasApp("listing")){
			echo('<li><a href="/z/listing/map-fullscreen/index" target="_blank">Real Estate - Fullscreen Map Search</a></li>
			<li><a href="/z/listing/search-form/index" target="_blank">Real Estate - Search Results</a></li>
			<li><a href="/z/listing/advanced-search/index" target="_blank">Real Estate - Advanced Search</a></li>
			<li><a href="/z/listing/property/your-saved-searches/index" target="_blank">Real Estate - Your Saved Searches</a></li>
			<li><a href="/z/listing/sl/view" target="_blank">Real Estate - Your Saved Listings</a></li>

			');
		}
		if(application.zcore.app.siteHasApp("rental")){
			link=application.zcore.app.getAppCFC("rental").getRentalHomeLink();
			echo('<li><a href="#link#" target="_blank">Rental - Home Page</a></li>');

		}
		echo('</ul>');
		</cfscript>
	</div>
	</div>
</cffunction>

<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();


	var db=request.zos.queryObject; 
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);
	form.page_id=application.zcore.functions.zso(form, "page_id", true, 0);
	form.mode=application.zcore.functions.zso(form, 'mode', false, 'sorting');

	ts=structnew();
	ts.image_library_id_field="page.page_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);  
	db.sql="SELECT *, 
	count(c2.page_id) children 
	#db.trustedSQL(rs2.select)#  
	FROM #db.table("page", request.zos.zcoreDatasource)#

	LEFT JOIN #db.table("page", request.zos.zcoreDatasource)# c2 ON 
	c2.page_parent_id = page.page_id and 
	c2.page_deleted= #db.param(0)# and 
	c2.site_id = page.site_id 
	#db.trustedSQL(rs2.leftJoin)#
	WHERE   
	page.page_deleted = #db.param(0)# and  
	page.page_id=#db.param(form.page_id)# and 
	page.site_id=#db.param(request.zos.globals.id)# 
	GROUP BY page.page_id ";
	qpage=db.execute("qpage");

	if(qpage.page_parent_id NEQ 0){
		db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)# page 
		WHERE page_id = #db.param(qpage.page_parent_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
		page_deleted=#db.param(0)#  ";
		qpagep=db.execute("qpagep");
		if(qpagep.recordcount EQ 0){
			application.zcore.functions.zredirect("/z/section/admin/page-admin/index");
		}
		request.parentChildSorting=qpagep.page_child_sorting;
	}else{
		request.parentChildSorting=0;
	}
	 
	savecontent variable="rowOut"{
		for(row in qpage){
			getLayoutRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>

<cffunction name="getLayoutRowHTML" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;  
	indentCount=0;
	parentId=row.page_parent_id;
	loopCount=0;
	indentChars="";
	while(true){
		if(parentId NEQ 0 and structkeyexists(request.parentLookupStruct, parentId)){
			parentId=request.parentLookupStruct[parentId];
			indentCount++;
			indentChars&="&nbsp;&nbsp;&nbsp;&nbsp;";
		}else{
			break;
		}
		loopCount++;
		if(loopCount > 50){
			throw("Infinite loop detected. page_id:#row.page_id#");
		}
	} 

	ts=structnew();
	ts.image_library_id=row.page_image_library_id;
	ts.output=false;
	ts.struct=row;
	ts.size="100x70";
	ts.crop=1;
	ts.count = 1;
	arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts);
	pagephoto99=""; 
	if(arraylen(arrImages) NEQ 0){
		pagephoto99=(arrImages[1].link);
	}
	</cfscript>
	<td class="z-hide-at-767" style="vertical-align:top; width:30px; ">#row.page_id#</td>
	<td class="z-hide-at-767" style="vertical-align:top; width:100px; ">
		<cfif pagephoto99 NEQ "">
			<img alt="Image" src="#request.zos.currentHostName&pagephoto99#" style="max-width:100%;" /></a>
		<cfelse>
			&nbsp;
		</cfif></td>
	<td style="vertical-align:top; padding-left:#indentCount*20#px;"> 

		<cfsavecontent variable="title">
			#row.page_name#
			<cfif application.zcore.app.siteHasApp("listing")><br />
				<cfif row.page_address NEQ ''>#row.page_address# | </cfif>
				<cfif row.page_mls_number CONTAINS '-'>MLS ##:#listgetat(row.page_mls_number,2,"-")# | </cfif>
				<cfif row.page_price NEQ 0>#DollarFormat(row.page_price)#</cfif>
			</cfif>
		</cfsavecontent> 
			#title# 
	</td> 

	<td>#application.zcore.functions.zTimeSinceDate(row.page_updated_datetime)#</td>
	<td style="vertical-align:top; " class="z-manager-admin">

		<cfif form.mode EQ "sorting">
			<cfif request.parentChildSorting EQ 0 and application.zcore.functions.zso(form, 'searchtext') EQ '' and request.sortComSQL EQ ''> 
				<div class="z-manager-button-container">
					#variables.queueSortCom.getAjaxHandleButton(row.page_id)#
				</div>
				
			</cfif>
		</cfif>
		<cfif row.page_status EQ 2>
			<div class="z-manager-button-container">
				<a title="Inactive"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a>
			</div>
		<cfelse> 
			<div class="z-manager-button-container">
				<a title="<cfif row.page_status EQ '3'>Sold<cfelseif row.page_status EQ '4'>Under Contract<cfelse>Active</cfif>"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a>
			</div>
		</cfif>
		<div class="z-manager-button-container"> 
			<a href="<cfif row.page_url_only NEQ ''>#row.page_url_only#<cfelse><cfif row.page_unique_url NEQ ''>#row.page_unique_url#<cfelse>/#application.zcore.functions.zURLEncode(row.page_name,'-')#-#application.zcore.app.getAppData("page").optionStruct.page_config_url_article_id#-#row.page_id#.html</cfif></cfif><cfif row.page_status EQ 2>?preview=1</cfif>" class="z-manager-view" target="_blank" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a> 
		</div>
		<cfscript>
		deleteDisabled=true;
		if(row.page_locked EQ 0 or application.zcore.user.checkSiteAccess()){
			if(row.children EQ 0){
				deleteDisabled=false;
			}
		}
		</cfscript>
		<div class="z-manager-button-container">

			<a href="##" class="z-manager-edit" id="z-manager-edit#row.page_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
			<div class="z-manager-edit-menu">
				<a href="/z/section/admin/page-admin/edit?page_id=#row.page_id#&amp;return=1&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;modalpopforced=1&amp;mode=#form.mode#" onclick="zTableRecordEdit(this);  return false;">Edit Page</a>
				<cfif (structkeyexists(form, 'qpagep') EQ false or qpagep.page_featured_listing_parent_page NEQ 1)>
					<a href="/z/section/admin/page-admin/add?page_parent_id=#row.page_id#&amp;return=1&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">New Child Page</a>
				</cfif>
				<cfif form.mode EQ "sorting" and row.children NEQ 0>
					<a href="/z/section/admin/page-admin/index?page_parent_id=#row.page_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage #row.children# Sub-Pages</a>
				</cfif>
				<cfif request.zos.isTestServer>
					<cfscript>
					ts=structnew();
					ts.saveIdURL="/z/section/admin/page-admin/saveGridId?page_id=#row.page_id#";
					ts.grid_id=row.page_grid_id;
					application.zcore.grid.getGridForm(ts); 
					</cfscript> 
				</cfif>
				<cfif application.zcore.app.siteHasApp("listing") and row.page_search_mls EQ 1>
					<a href="#request.zos.globals.domain##application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), "zsearch_cid=#row.page_id#")#" target="_blank">Search Results Only</a>
				</cfif>
				<cfif application.zcore.app.siteHasApp("listing")>
					<a href="<cfif row.page_url_only NEQ ''>#row.page_url_only#<cfelse><cfif row.page_unique_url NEQ ''>#row.page_unique_url#<cfelse>/#application.zcore.functions.zURLEncode(row.page_name,'-')#-#application.zcore.app.getAppData("page").optionStruct.page_config_url_article_id#-#row.page_id#.html</cfif></cfif>?<cfif row.page_status EQ 2>preview=1&amp;</cfif>hidemls=1" target="_blank">View (w/o MLS)</a>
				</cfif> 

				<cfif application.zcore.user.checkServerAccess()>
					<cfif row.page_hide_edit EQ 1>
						<a href="/z/section/admin/page-admin/changeEdit?show=0&amp;return=1&amp;page_id=#row.page_id#">Show This Page</a>
					<cfelse>
						<a href="/z/section/admin/page-admin/changeEdit?show=1&amp;return=1&amp;page_id=#row.page_id#">Hide This Page</a>
					</cfif> 
				</cfif>
				<cfif deleteDisabled>
					<a href="##">Delete Disabled</a>
				</cfif>

			</div>
		</div> 
		<cfif form.mode EQ "sorting" and row.children NEQ 0>
			<div class="z-manager-button-container">
				<a class="z-manager-edit" title="Mange #row.children# pages connected to this page" href="/z/section/admin/page-admin/index?page_parent_id=#row.page_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#"><i class="fa fa-sitemap" aria-hidden="true"></i></a>
			</div>
		</cfif>

		<cfif not deleteDisabled>
			<div class="z-manager-button-container">
				<a href="##" class="z-manager-delete" title="Delete" onclick="zDeleteTableRecordRow(this, '/z/section/admin/page-admin/delete?page_id=#row.page_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;returnJson=1&amp;confirm=1'); return false;"><i class="fa fa-trash" aria-hidden="true"></i></a>
			</div>
		</cfif>
	</td>
</cffunction>
 

</cfoutput>
</cfcomponent>