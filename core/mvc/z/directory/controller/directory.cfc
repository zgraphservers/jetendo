<cfcomponent>
<cfoutput>
<cfscript>
this.app_id=19;


// Public directory form and related functionality is disabled through 404.


// Directory type legend
// 0 = Not provided
// 1 = Full-time
// 2 = Part-time
// 3 = Commission
// 4 = Temporary
// 5 = Temporary to hire
// 6 = Contract
// 7 = Contract to hire
// 8 = Internship
</cfscript>

<!--- <cffunction name="directoryTypeToString" localmode="modern" output="no" returntype="any">
	<cfargument name="directoryTypeId" type="numeric" required="yes">
	<cfscript>
		directoryTypeId = arguments.directoryTypeId;

		directoryTypes = {
			0: 'Not Provided',
			1: 'Full-Time',
			2: 'Part-Time',
			3: 'Commission',
			4: 'Temporary',
			5: 'Temporary to Hire',
			6: 'Contract',
			7: 'Contract to Hire',
			8: 'Internship',
		};

		if ( ! structKeyExists( directoryTypes, directoryTypeId ) ) {
			throw( 'Invalid directory type ID "' & directoryTypeId & '" when getting directoryTypeToString.' );
		}

		return directoryTypes[ directoryTypeId ];
	</cfscript>
</cffunction>

<cffunction name="directoryTypeStringToId" localmode="modern" output="no" returntype="any">
	<cfargument name="directoryType" type="string" required="yes">
	<cfscript>
		directoryType = arguments.directoryType;

		directoryTypes = {
			'':0,
			'Not Provided':0,
			'Full-Time':1,
			'Part-Time':2,
			'Commission':3,
			'Temporary':4 ,
			'Temporary to Hire':5,
			'Contract':6,
			'Contract to Hire':7,
			'Internship':8,
		};

		if ( ! structKeyExists( directoryTypes, directoryType ) ) {
			throw( 'Invalid directory type "' & directoryType & '" when getting directoryTypeStringToId.' );
		}

		return directoryTypes[ directoryType ];
	</cfscript>
</cffunction> --->


<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	ts=application.zcore.app.getInstance(this.app_id);
	db=request.zos.queryObject;

	/*if(ts.optionstruct.directory_config_directory_index_url NEQ "{default}"){
		// directories root url 
		t2=StructNew();
		t2.groupName="Directory";
		t2.url=request.zos.currentHostName&ts.optionStruct.directory_config_directory_index_url;
		t2.title=ts.optionStruct.directory_config_title;
		arrayappend(arguments.arrUrl,t2);
	}else{
		// default home url
		t2=StructNew();
		t2.groupName="Directory";
		t2.url=request.zos.currentHostName&this.getDirectoryLink(ts.optionStruct.directory_config_misc_url_id,1,"html",ts.optionStruct.directory_config_title);
		t2.title=ts.optionStruct.directory_config_title;
		arrayappend(arguments.arrUrl,t2);
	}




	db.sql="SELECT * from #db.table("directory_category", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and  
	directory_category_deleted = #db.param(0)# ";
	db.sql&="ORDER BY directory_category_unique_url DESC";
	qF=db.execute("qF");
	for(row in qF){
		t2=StructNew();
		t2.groupName="Directory Category";
		t2.url=request.zos.currentHostName&getCategoryURL(row);
		t2.title=row.directory_category_name;
		arrayappend(arguments.arrUrl,t2);
	}

	db.sql="SELECT * from #db.table("directory", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and  
	directory_deleted = #db.param(0)# and
	directory_status = #db.param(1)# ";
	db.sql&="ORDER BY directory_title ASC";
	qF=db.execute("qF");
	for(row in qF){
		t2=StructNew();
		t2.groupName="Directory";

		t2.url=request.zos.currentHostName&getDirectoryURL(row);

		t2.title=row.directory_title;
		arrayappend(arguments.arrUrl,t2);
	}*/
	return arguments.arrURL;
	</cfscript>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
		var ts = 0;

		/*if ( structKeyExists( request.zos.userSession.groupAccess, 'administrator' ) ) {
			if ( structKeyExists( arguments.linkStruct, 'Directories' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Directories';
				ts.link        = '/z/directory/admin/manage-directories/index';
				ts.children    = structNew();

				arguments.linkStruct['Directories'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Directories'].children, 'Add Directory' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Add Directories';
				ts.link        = '/z/directory/admin/manage-directories/add';

				arguments.linkStruct['Directories'].children['Add Directory'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Directories'].children, 'Add Directory Category' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Add Directory Category';
				ts.link        = '/z/directory/admin/manage-directory-category/add';

				arguments.linkStruct['Directories'].children['Add Directory Category'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Directories'].children, 'Directories' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Directories';
				ts.link        = '/z/directory/admin/manage-directories/index';

				arguments.linkStruct['Directories'].children['Directories'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Directories'].children, 'Directory Categories' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Directory Categories';
				ts.link        = '/z/directory/admin/manage-directory-category/index';

				arguments.linkStruct['Directories'].children['Directory Categories'] = ts;
			}

			if(application.zcore.user.checkServerAccess()){
				if ( structKeyExists( arguments.linkStruct['Directories'].children, 'Directory Import' ) EQ false ) {
					ts = structNew();

					ts.featureName = 'Directory Import';
					ts.link        = '/z/directory/admin/directory-import/index';

					arguments.linkStruct['Directories'].children['Directory Import'] = ts;
				}
			}
			if ( structKeyExists( arguments.linkStruct['Directories'].children, 'View Directories Home Page' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'View Directories Home Page';
				ts.link        = this.getDirectoriesHomePageLink();

				arguments.linkStruct['Directories'].children['View Directories Home Page'] = ts;
			}
		}*/

		return arguments.linkStruct;
	</cfscript>
</cffunction>

<cffunction name="getAdminNavMenu" localmode="modern" access="public">
	<cfscript>
		application.zcore.template.setTag("title", "Directories");
	</cfscript>

	<!--- <p>Manage: <a href="/z/directory/admin/manage-directory-category/index">Categories</a> | 
		<a href="/z/directory/admin/manage-directories/index">Directories</a> 
		| Add:
		<a href="/z/directory/admin/manage-directory-category/add">Category</a> | 
		<a href="/z/directory/admin/manage-directories/add">Directory</a>
	</p> --->
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("directory_config", request.zos.zcoreDatasource)# 
	where 
	site_id = #db.param(arguments.site_id)# and 
	directory_config_deleted = #db.param(0)#";
	qData=db.execute("qData"); 
	for(row in qData){
		return row;
	}
	throw("directory_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>


<!--- directory category search indexing --->
	
<!--- application.zcore.app.getAppCFC("directory").searchReindexCategory(false, true); --->
<cffunction name="searchReindexCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	return; // TODO need to implement
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT directory_category.*, directory_config_directory_url_id FROM #db.table("directory_category", request.zos.zcoreDatasource)#,
		#db.table("directory_config", request.zos.zcoreDatasource)# 
		WHERE 
		directory_config.site_id = directory_category.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and directory_category.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and directory_category.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and directory_category_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and directory_category_deleted=#db.param(0)# and 
		directory_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteDirectory(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.directory_category_name&" "&row.directory_category_description;
				ds.search_title=row.directory_category_name;
				//if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.directory_category_description;
				//}
				ds.search_summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 150);
				
				ds.search_url=getCategoryURL(row);
				ds.search_table_id="directory-category-"&row.directory_category_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.directory_category_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.directory_category_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and  
		search_table_id LIKE #db.param('directory-category-%')# and
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>


<!--- directory search reindexing --->

<!--- application.zcore.app.getAppCFC("directory").searchReindexDirectory(false, true); --->
<cffunction name="searchReindexDirectory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	return; // TODO need to implement
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT directory.*, directory_config_directory_url_id FROM #db.table("directory", request.zos.zcoreDatasource)#,
		#db.table("directory_config", request.zos.zcoreDatasource)# 
		WHERE 
		directory_config.site_id = directory.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and directory.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and directory.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and directory_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and directory_status = #db.param(1)# and  
		directory_deleted=#db.param(0)# and 
		directory_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteDirectory(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.directory_title&" "&row.directory_city&" "&row.directory_summary&" "&row.directory_overview;
				ds.search_title=row.directory_title;
				//if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.directory_overview;
				//}
				ds.search_summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 150);
				
				ds.search_url=getDirectoryURL(row);
				ds.search_table_id="directory-"&row.directory_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.directory_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.directory_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and  
		search_table_id LIKE #db.param('directory-%')# and
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>
	
	
<!--- application.zcore.app.getAppCFC("directory").searchIndexDeleteContent(directory_id); --->
<cffunction name="searchIndexDeleteDirectory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	return; // TODO need to implement
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("directory-"&arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

	
<!--- application.zcore.app.getAppCFC("directory").searchIndexDeleteContent(directory_category_id); --->
<cffunction name="searchIndexDeleteCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	return; // TODO need to implement
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("directory-category-"&arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

	

<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 

	return; // TODO need to implement
	db.sql="SELECT * FROM #db.table("directory_config", request.zos.zcoreDatasource)# directory_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = directory_config.site_id and 
	directory_config.site_id = #db.param(arguments.site_id)# and 
	directory_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_id = #db.param(this.app_id)# and
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig");  

	loop query="qConfig"{
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_directory_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_misc_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_category_url_id]=[];

		if(qConfig.directory_config_directory_index_url NEQ "{default}"){
			t9=structnew();
			t9.scriptName="/z/directory/directory/index";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/directory/index";
			
			arguments.sharedStruct.uniqueURLStruct[trim(qConfig.directory_config_directory_index_url)]=t9;
		}else{
			// ## directory home
			//  /#name#-#appid#-#id#.#ext#
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/directory/directory/index";
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="1";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/directory/index";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_misc_url_id],t9);
		}

		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/directory/view-directory/viewDirectory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/view-directory/viewDirectory";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="directory_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_directory_url_id],t9); 

		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/directory/directory-category/viewCategory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/directory-category/viewCategory";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="directory_category_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_category_url_id],t9); 

		t9=structnew();
		t9.type=3;
		t9.scriptName="/z/directory/directory/index";
		t9.ifStruct=structnew();
		t9.ifStruct.dataId="1";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/directory/index";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="urlid";
		t9.mapStruct.dataId2="zIndex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_misc_url_id],t9);

		t9=structnew();
		t9.type=3;
		t9.scriptName="/z/directory/directory-category/viewCategory";
		t9.ifStruct=structnew();
		t9.ifStruct.ext="html";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/directory-category/viewCategory";
		t9.urlStruct.method="index";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="directory_category_id";
		t9.mapStruct.dataId2="zindex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.directory_config_category_url_id],t9);

		db.sql="SELECT * from #db.table("directory", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		directory_unique_url<>#db.param('')# and 
		directory_deleted = #db.param(0)#
		ORDER BY directory_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/directory/view-directory/viewDirectory";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/view-directory/viewDirectory";
			t9.urlStruct.directory_id=qF.directory_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.directory_unique_url)]=t9;
		}

		db.sql="SELECT * from #db.table("directory_category", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		directory_category_unique_url<>#db.param('')# and 
		directory_category_deleted = #db.param(0)#
		ORDER BY directory_category_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/directory/directory-category/viewCategory";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/directory-category/viewCategory";
			t9.urlStruct.directory_category_id=qF.directory_category_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.directory_category_unique_url)]=t9;
		}
	} 
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleDirectory" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	return true; // TODO need to implement
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("directory", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	directory_unique_url<>#db.param('')# and 
	directory_id=#db.param(arguments.id)# and 
	directory_deleted = #db.param(0)#
	ORDER BY directory_unique_url DESC";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/directory/view-directory/viewDirectory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/view-directory/viewDirectory";
		t9.urlStruct.directory_id=qF.directory_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.directory_unique_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleCategory" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	return true; // TODO need to implement
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("directory_category", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	directory_category_unique_url<>#db.param('')# and 
	directory_category_id=#db.param(arguments.id)# and 
	directory_category_deleted = #db.param(0)#
	ORDER BY directory_category_unique_url DESC";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/directory/directory-category/viewCategory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/directory/directory-category/viewCategory";
		t9.urlStruct.directory_category_id=qF.directory_category_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.directory_category_unique_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("directory_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	directory_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();

	// Set config defaults here
	// TODO need to implement
	//df.directory_config_title = "Directories";
	//df.directory_config_directory_index_url = "{default}";

	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"directory_config_",""),"_"," ","ALL")));
				application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
			}
		}else{
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
				form[i]=df[i];
			}
		}
	}
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
	<cfscript>
	var ts=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';

	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	

	form.site_id=form.sid; 

	ts=StructNew();
	ts.arrId=arrayNew(1);

	// Processing/validation of config options before save/update
	// Display error
	// application.zcore.status.setStatus(Request.zsid, 'Directory no longer exists', form, true);
	// TODO need to implement
	/*
	arrayappend(ts.arrId,trim(form.directory_config_directory_url_id));
	arrayappend(ts.arrId,trim(form.directory_config_misc_url_id));
	arrayappend(ts.arrId,trim(form.directory_config_category_url_id));
*/
	ts.site_id=form.site_id;
	ts.app_id=this.app_id;

	rCom=application.zcore.app.reserveAppUrlId(ts);

	if(rCom.isOK() EQ false){
		return rCom;
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();
	} 
	form.directory_config_deleted=0;
	form.directory_config_updated_datetime=request.zos.mysqlnow;
	ts.table="directory_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'directory_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts);  
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");

	// Build the config form.

	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("directory_config", request.zos.zcoreDatasource)# directory_config 
		WHERE site_id = #db.param(form.sid)# and 
		directory_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="directory_config_id" value="#form.directory_config_id#" />
		<table style="border-spacing:0px;" class="table-list">');
		echo('
		<tr>
		<th>Directory Home Page Title:</th>
		<td>');
		ts = StructNew();
		ts.name = "directory_config_title";
		ts.required = true;
		ts.defaultValue = "Directories";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>');
/*
		echo(' 
		<tr>
		<th>Directory Home Page URL:</th>
		<td>');
		ts = StructNew();
		ts.name = "directory_config_directory_index_url";
		ts.required = true;
		ts.defaultValue = "{default}";
		application.zcore.functions.zInput_Text(ts);
		echo('<br />(URL for listing all directories in all categories) <a href="##" onclick=" document.getElementById(''directory_config_directory_index_url'').value=''{default}''; return false;">Restore default</a></td>
		</tr>
		<tr>
		<th>Directory URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("directory_config_directory_url_id", form.directory_config_directory_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Category URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("directory_config_category_url_id", form.directory_config_category_url_id, this.app_id));
		echo('</td>
		</tr> 
		<tr>
		<th>Directory Misc URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("directory_config_misc_url_id", form.directory_config_misc_url_id, this.app_id));
		echo('</td>
		</tr> 
		');

*/


		echo('</table>');


	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
 
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>


<cffunction name="getDirectoryURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.directory_unique_url NEQ ""){
		return row.directory_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("directory").optionstruct.directory_config_directory_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.directory_title, '-')&"-"&urlId&"-"&row.directory_id&".html";
	}
	</cfscript>
</cffunction>


<cffunction name="getCategoryURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.directory_category_unique_url NEQ ""){
		return row.directory_category_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("directory").optionstruct.directory_config_category_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.directory_category_name, '-')&"-"&urlId&"-"&row.directory_category_id&".html";
	}
	</cfscript>
</cffunction>



<cffunction name="onSiteStart" access="public" localmode="modern">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	ts={}; 

	// Cached data

	arguments.sharedStruct=ts;
	return arguments.sharedStruct;
	</cfscript>
</cffunction>


<cffunction name="isCurrentPageInDirectory" localmode="modern" returntype="boolean" access="remote">
	<cfscript>
	if(structkeyexists(request.zos, 'currentURLISADirectoryPage')){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="getDirectoryLink" localmode="modern" returntype="string" output="no">
	<cfargument name="appid" type="string" required="yes">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="ext" type="string" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfscript>
	return "/"&application.zcore.functions.zURLEncode(arguments.name,'-')&"-"&arguments.appid&"-"&arguments.id&"."&arguments.ext;
	</cfscript>
</cffunction>

<cffunction name="getDirectoriesHomePageLink" localmode="modern" returntype="string" output="no">
	<cfscript>
		ts2 = application.zcore.app.getInstance( this.app_id );

		if ( ts2.optionStruct.directory_config_directory_index_url NEQ '{default}' ) {
			return request.zos.currentHostName & ts2.optionStruct.directory_config_directory_index_url;
		} else {
			// Default home url
			return this.getDirectoryLink( ts2.optionStruct.directory_config_misc_url_id, 1, 'html', ts2.optionStruct.directory_config_title );
		}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
		request.zos.currentURLISADirectoryPage = true;

		return; // TODO: need to implement
		directoryHomePageTitle = application.zcore.app.getAppData( 'directory' ).optionStruct.directory_config_title;

		form.zIndex = application.zcore.functions.zso( form, 'zIndex', true, 1 );

		if ( form.zIndex LTE 0 ) {
			form.zIndex = 1;
		}

		form.directory_category_id = application.zcore.functions.zso( form, 'directory_category_id' );
		form.company         = application.zcore.functions.zso( form, 'company' );

		if ( form.company NEQ '' ) {
			showCompanyNamePageTitle = false;

			if ( application.zcore.app.getAppData( 'directory' ).optionStruct.directory_config_this_company EQ 0 ) {
				showCompanyNamePageTitle = true;

				if ( application.zcore.app.getAppData( 'directory' ).optionStruct.directory_config_company_names_hidden EQ 1 ) {
					// If company names are hidden globally, then we should 404.
					application.zcore.functions.z404( 'Not found' );
				}
			}

			if ( showCompanyNamePageTitle ) {
				directoryHomePageTitle = form.company & ' Directories';
			}
		}

		application.zcore.template.setTag( "title", directoryHomePageTitle );
		application.zcore.template.setTag( "pagetitle", directoryHomePageTitle );

		// TODO: Get all the directory categories and show as a list in a sidebar.
	</cfscript>

	<div class="z-directory-rows">
		<cfscript>
			countLimit = 5;

			directoriesearch = {
				perpage: countLimit,
				// categories: form.directory_category_id,
				company: form.company,
				offset: ( ( form.zIndex - 1 ) * countLimit )
			};

			directoryResults = this.searchDirectories( directoriesearch );

			ts = {
				directoryResults: directoryResults,
				countLimit: countLimit,
				searchView: 'index'
			};

			this.outputDirectoryResults( ts );
		</cfscript>
		<div class="z-clear"></div>
	</div>

</cffunction>

<!--- 
ts={
	// all criteria optional
	directory_id:"",
	categories:"",
	keyword:"",
	company:"",
};
searchDirectories(ts);
 --->
<cffunction name="searchDirectories" access="public" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject;

	return { count: 0, hasPhotos:false, arrData: [] };
	 // TODO: need to implement
	ss.perpage=application.zcore.functions.zso(ss, 'perpage', true, 10);
	ss.offset=application.zcore.functions.zso(ss, 'offset', true);
	ss.directory_id=application.zcore.functions.zso(ss, 'directory_id', true);
	ss.categories=application.zcore.functions.zso(ss, 'categories');
	ss.keyword=application.zcore.functions.zso(ss, 'keyword');
	ss.company=application.zcore.functions.zso(ss, 'company');
 	ss.showInactive=application.zcore.functions.zso(ss, 'showInactive');

	if(not application.zcore.user.checkGroupAccess("member")){
		ts.showInactive=false;
	}

	ss.keyword=replace(replace(ss.keyword, '+', '%', 'all'), ' ', '%', 'all');

	arrCategory=listToArray(ss.categories, ',');
	if(arraylen(arrCategory)){
		arrCategory2=[];
		for(i=1;i LTE arraylen(arrCategory);i++){
			if(isnumeric(trim(arrCategory[i]))){
				arrayAppend(arrCategory2, arrCategory[i]);
			}
		}
		arrCategory=arrCategory2;
	}

	ts=structnew();
	ts.image_library_id_field="directory.directory_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);

	// By default we feel that most sites will be set up for 'this company' so
	// we don't need to include the company name in the search query.
	// This variable changes how the SQL query is built below.
	searchingForCompanyName = false;

	// However, if this site is set up to list directories for other companies...
	if ( application.zcore.app.getAppData( 'directory' ).optionStruct.directory_config_this_company EQ 0 ) {
		// Then include the company name in the __FRONT END__ search query by default.
		searchingForCompanyName = true;

		// ... BUT if we want the company names hidden...
		if ( application.zcore.app.getAppData( 'directory' ).optionStruct.directory_config_company_names_hidden EQ 1 ) {
			// Then do not include the company name in the __FRONT END__ search query.
			searchingForCompanyName = false;
		}
	}


	if ( searchingForCompanyName EQ false ) {
		ss.company = '';
	}


	db.sql="select * ";

	if ( ss.keyword NEQ "" ) {

		if ( searchingForCompanyName ) {
			db.sql &= ", IF ( concat(directory.directory_id, #db.param(' ')#, directory_title, #db.param(' ')#, directory_company_name, #db.param(' ')#, directory_city, #db.param(' ')#, directory_summary, #db.param(' ')#, directory_overview) LIKE #db.param( '%' & application.zcore.functions.zURLEncode( ss.keyword, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `directory_search` ) AGAINST( #db.param( ss.keyword )# ) relevance ";
		} else {
			db.sql &= ", IF ( `directory_search` LIKE #db.param( '%' & application.zcore.functions.zURLEncode( ss.keyword, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `directory_search` ) AGAINST( #db.param( ss.keyword )# ) relevance ";
		}
	}

	db.sql &= "
	#db.trustedsql(rs2.select)# from 
	#db.table("directory", request.zos.zcoreDatasource)#
	#db.trustedsql(rs2.leftJoin)#
	WHERE 
	directory.site_id = #db.param(request.zos.globals.id)# and 
	directory_deleted=#db.param(0)# ";
	if(ss.showInactive NEQ 1){
		db.sql&=" and directory.directory_status=#db.param(1)# ";
	}
	if(ss.directory_id NEQ 0){
		db.sql&=" and directory.directory_id = #db.param(ss.directory_id)# ";
	}

	// Only display directories where the posted date is before right now and the closed date is after right now (or not set).
	db.sql&=" and directory_posted_datetime <= #db.param(request.zos.mysqlnow)# ";
	db.sql&=" and ( directory_closed_datetime >= #db.param(request.zos.mysqlnow)# OR directory_closed_datetime = #db.param('0000-00-00 00:00:00')# ) ";

	if ( ss.company NEQ "" ) {
		if ( searchingForCompanyName ) {
			db.sql &= " and ( directory_company_name LIKE #db.param( '%' & ss.company & '%' )# AND directory_company_name_hidden = #db.param( 0 )# ) ";
		}
	}

	if(ss.keyword NEQ ""){
		searchOn=true;

		if ( searchingForCompanyName ) {
			db.sql &= " and ( MATCH( `directory_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
			db.sql &= " or concat(directory.directory_id, #db.param(' ')#, directory_title, #db.param(' ')#, directory_company_name, #db.param(' ')#, directory_city, #db.param(' ')#, directory_summary, #db.param(' ')#, directory_overview)  like #db.param('%#ss.keyword#%')# ";
			db.sql &= " ) ";
		} else {
			db.sql &= " and ( MATCH( `directory_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
			db.sql &= " or directory_search LIKE #db.param( '%' & ss.keyword & '%' )# ) ";
		}

		db.sql &= " and ( MATCH( `directory_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
		db.sql &= " or concat(directory.directory_id, #db.param(' ')#, directory_title, #db.param(' ')#, directory_company_name, #db.param(' ')#, directory_city, #db.param(' ')#, directory_summary, #db.param(' ')#, directory_overview)  like #db.param('%#ss.keyword#%')# ";
		db.sql &= " ) ";
	}

	if(arraylen(arrCategory)){
		db.sql&=" and ( ";
		searchOn=true;
		for(i=1;i LTE arraylen(arrCategory);i++){
			if(i NEQ 1){
				db.sql&=" or ";
			}
			db.sql&=" CONCAT(#db.param(',')#,directory_category_id, #db.param(',')#) LIKE #db.param('%,'&arrCategory[i]&',%')# ";
		}
		db.sql&=" ) ";
	}

	db.sql &= " GROUP BY directory.directory_id ";

	if ( ss.keyword NEQ "" ) {
		db.sql &= " ORDER BY exactMatch DESC, relevance DESC";
	} else {
		db.sql &= " ORDER BY directory_featured DESC, directory_posted_datetime DESC";
	}

	db.sql&="
	 LIMIT #db.param(ss.offset)#, #db.param(ss.perpage)# ";

	qList=db.execute("qList");

	if(request.zos.isdeveloper and structkeyexists(form, 'zdebug')){
		writedump(qList);
	}

	if(ss.offset EQ 0 and ( qList.recordcount LT ss.perpage)){
		qCount={count:qList.recordcount};
	}else{

		db.sql="select count(directory_id) count from 
		#db.table("directory", request.zos.zcoreDatasource)#
		WHERE directory.site_id = #db.param(request.zos.globals.id)# and 
		directory_deleted=#db.param(0)# ";

		if(ss.showInactive NEQ 1){
			db.sql&=" and directory.directory_status=#db.param(1)# ";
		}

		if(ss.directory_id NEQ 0){
			db.sql&=" and directory.directory_id = #db.param(ss.directory_id)# ";
		}

		// Only display directories where the posted date is before right now and the closed date is after right now (or not set).
		db.sql&=" and directory_posted_datetime <= #db.param(request.zos.mysqlnow)# ";
		db.sql&=" and ( directory_closed_datetime >= #db.param(request.zos.mysqlnow)# OR directory_closed_datetime = #db.param('0000-00-00 00:00:00')# ) ";

		if ( ss.company NEQ "" ) {
			if ( searchingForCompanyName ) {
				db.sql &= " and ( directory_company_name LIKE #db.param( '%' & ss.company & '%' )# AND directory_company_name_hidden = #db.param( 0 )# ) ";
			}
		}

		if(ss.keyword NEQ ""){
			searchOn=true;

			if ( searchingForCompanyName ) {
				db.sql &= " and ( MATCH( `directory_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
				db.sql &= " or concat(directory.directory_id, #db.param(' ')#, directory_title, #db.param(' ')#, directory_company_name, #db.param(' ')#, directory_city, #db.param(' ')#, directory_summary, #db.param(' ')#, directory_overview)  like #db.param('%#ss.keyword#%')# ";
				db.sql &= " ) ";
			} else {
				db.sql &= " and MATCH( `directory_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
			}
		}

		if(arraylen(arrCategory)){
			db.sql&=" and ( ";
			searchOn=true;
			for(i=1;i LTE arraylen(arrCategory);i++){
				if(i NEQ 1){
					db.sql&=" or ";
				}
				db.sql&=" CONCAT(#db.param(',')#,directory_category_id, #db.param(',')#) LIKE #db.param('%,'&arrCategory[i]&',%')# ";
			}
			db.sql&=" ) ";
		}

		qCount=db.execute("qCount"); 
	}
	arrData=[];
	directoryCom=application.zcore.app.getAppCFC("directory");
	hasPhotos=false;
	for(row in qList){
		row.__url=directoryCom.getDirectoryURL(row);

		hasPhotos=true;
		arrayAppend(arrData, row);
	}
	return { count: qCount.count, hasPhotos:hasPhotos, arrData: arrData };
	</cfscript>
</cffunction>

<cffunction name="outputDirectoryResults" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss = arguments.ss;
	return;
	 // TODO: need to implement

		directoryResults        = application.zcore.functions.zso( ss, 'directoryResults' );
		countLimit        = application.zcore.functions.zso( ss, 'countLimit' );
		searchView        = application.zcore.functions.zso( ss, 'searchView' );
		currentPageStruct = application.zcore.functions.zso( ss, 'currentPageStruct' );

		form.directory_category_id = application.zcore.functions.zso( form, 'directory_category_id' );

		db = request.zos.queryObject;

		countTotal = directoryResults.count;

		if ( countTotal GT 0 ) {
			directories = directoryResults.arrData;

			// Loop through the directories that were found and output each.
			for ( directory in directories ) {
				this.outputDirectoryRow( directory );
			}

			// required
			searchStruct = StructNew();

			searchStruct.count             = countTotal;
			searchStruct.index             = form.zIndex;
			searchStruct.indexName         = "zIndex";
			searchStruct.buttons           = 5;
			searchStruct.perpage           = countLimit;
			searchStruct.parseURLVariables = true;
			searchStruct.firstPageHack     = true;

			if ( searchView EQ 'index' ) {
				searchStruct.url          = this.getDirectoryLink( application.zcore.app.getAppData("directory").optionStruct.directory_config_misc_url_id, '1_##zIndex##', "html", application.zcore.app.getAppData("directory").optionStruct.directory_config_title );
				searchStruct.firstpageurl = this.getDirectoryLink( application.zcore.app.getAppData("directory").optionStruct.directory_config_misc_url_id, 1, "html", application.zcore.app.getAppData("directory").optionStruct.directory_config_title );
			} else if ( searchView EQ 'category' ) {
				searchStruct.url          = this.getDirectoryLink( application.zcore.app.getAppData("directory").optionStruct.directory_config_category_url_id, currentPageStruct.directory_category_id & '_##zIndex##', "html", currentPageStruct.directory_category_name );
				searchStruct.firstpageurl = this.getDirectoryLink( application.zcore.app.getAppData("directory").optionStruct.directory_config_category_url_id, currentPageStruct.directory_category_id, "html", currentPageStruct.directory_category_name );
			} else {
				// Same as index
				searchStruct.url          = this.getDirectoryLink( application.zcore.app.getAppData("directory").optionStruct.directory_config_misc_url_id, '1_##zIndex##', "html", application.zcore.app.getAppData("directory").optionStruct.directory_config_title );
				searchStruct.firstpageurl = this.getDirectoryLink( application.zcore.app.getAppData("directory").optionStruct.directory_config_misc_url_id, 1, "html", application.zcore.app.getAppData("directory").optionStruct.directory_config_title );
			}


			var searchNav = application.zcore.functions.zSearchResultsNav( searchStruct );
			echo( '<div class="z-column z-pv-40 z-directory-pagination">' );

			writeoutput(searchNav);

			echo( '</div>' );
		} else {
			echo( '<div class="z-column">No directories were found.</div><div class="z-clear"></div>' );
		}
	</cfscript>
</cffunction>

<cffunction name="outputDirectoryRow" localmode="modern" access="public">
	<cfargument name="directory" type="struct" required="yes">
	<cfscript>
	return;
	 // TODO: need to implement
		directory = arguments.directory;

		// Only active directories can be displayed using this function.
		if ( directory.directory_status NEQ 1 ) {
			return;
		}

		// Determine whether or not we should display the company name.
		showCompanyName            = false;
		showCompanyNamePlaceholder = '';

		if ( application.zcore.app.getAppData( 'directory' ).optionStruct.directory_config_this_company EQ 0 ) {
			showCompanyName = true;

			if ( application.zcore.app.getAppData( 'directory' ).optionStruct.directory_config_company_names_hidden EQ 1 ) {
				showCompanyName = false;
				showCompanyNamePlaceholder = 'Confidential';
			}

			if ( directory.directory_company_name_hidden EQ 1 ) {
				showCompanyName = false;
				showCompanyNamePlaceholder = 'Confidential';
			}
		}

		// Get the first image in the directory's image library.
		directoryImage        = '';
		directoryImageLibrary = structNew();

		directoryImageLibrary.image_library_id = directory.image_library_id;
		directoryImageLibrary.output           = false;
		directoryImageLibrary.size             = '320x240';
		directoryImageLibrary.crop             = 1;
		directoryImageLibrary.count            = 1;

		directoryImages = application.zcore.imageLibraryCom.displayImages( directoryImageLibrary );

		if ( arrayLen( directoryImages ) GT 0 ) {
			directoryImage = request.zos.currentHostName & directoryImages[ 1 ].link;
		}
	</cfscript>

	<div class="z-column z-directory-row z-center-children-at-992">
		<cfif directoryImage NEQ ''>
			<div class="z-1of4 z-m-0 z-p-0 z-directory-row-image">
				<a href="#directory.__url#"><img src="#directoryImage#" alt="#htmlEditFormat( directory.directory_title )#" class="z-fluid" /></a>
			</div>
			<div class="z-3of4 z-directory-row-content">
		<cfelse>
			<div class="z-1of1 z-directory-row-content">
		</cfif>

			<h2 class="z-directory-row-title"><a href="#directory.__url#">#directory.directory_title#</a></h2>

			<div class="z-directory-row-details">
				<cfif directory.directory_type NEQ 0>
					<span class="z-directory-row-directory-type">#this.directoryTypeToString( directory.directory_type )#</span> - 
				</cfif>
				<span class="z-directory-row-posted">Posted <span class="z-directory-row-posted-date">#application.zcore.functions.zTimeSinceDate( directory.directory_posted_datetime, true )#</span></span><br />

				<cfif showCompanyName EQ true AND directory.directory_company_name NEQ ''>
					<a href="#this.getDirectoriesHomePageLink()#?company=#urlEncodedFormat( directory.directory_company_name )#" class="z-directory-row-company-name">#directory.directory_company_name#</a>
				<cfelse>
					<cfif showCompanyNamePlaceholder NEQ ''>
						<span class="z-directory-row-company-name-placeholder">#showCompanyNamePlaceholder#</span>
					</cfif>
				</cfif>

				<cfif directory.directory_location NEQ ''>
					- <span class="z-directory-row-location">#htmlEditFormat( directory.directory_location )#</span>
				</cfif>

				<cfif directory.directory_category_id NEQ ''>
					<cfscript>
						directoryCategories = this.getDirectoryCategories( directory.directory_category_id );
					</cfscript>
					- <span class="z-directory-row-categories">Categories:
					<cfloop from="1" to="#arrayLen( directoryCategories )#" index="directoryCategoryIndex">
						<cfscript>directoryCategory = directoryCategories[ directoryCategoryIndex ];</cfscript>
						<a href="#directoryCategory.__url#">#directoryCategory.directory_category_name#</a><cfif directoryCategoryIndex LT arrayLen( directoryCategories )>, </cfif>
					</cfloop>
				</cfif>

			</div>

			<cfif directory.directory_summary NEQ ''>
				<div class="z-t-16 z-directory-row-summary">
					#directory.directory_summary#
				</div>
			</cfif>

			<div class="z-directory-row-buttons">
				<cfif application.zcore.functions.zso(application.zcore.app.getAppData( 'directory' ).optionStruct, 'directory_config_disable_apply_online', true, 0) EQ 0>
	
					<a href="#request.zos.globals.domain#/z/directory/apply/index?directoryId=#directory.directory_id#" class="z-button z-directory-row-button apply-now"><div class="z-t-16">Apply Now</div></a>
				</cfif>
				<a href="#directory.__url#" class="z-button z-directory-row-button view-details"><div class="z-t-16">View Details</div></a>
			</div>
		</div>
	</div>
</cffunction>

<cffunction name="getDirectoryCategories" localmode="modern" access="public">
	<cfargument name="categoryIdList" type="string" required="no" default="0">
	<cfscript>
	return [];
	 // TODO: need to implement
		categoryIdList = arguments.categoryIdList;

		ts = application.zcore.app.getInstance( this.app_id );

		db = request.zos.queryObject;

		// TODO - Category sorting - currently sorting by name, needs to sort by directory_category_sort when implemented.
		if ( categoryIdList EQ 0 ) {
			db.sql = "SELECT *
				FROM #db.table( 'directory_category', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND directory_category_deleted = #db.param( 0 )#
				ORDER BY directory_category_name ASC ";
		} else {
			categoryIdArray = listToArray( categoryIdList, ',' ); 
			for(i=1;i<=arrayLen(categoryIdArray);i++){
				categoryIdArray[i]="'"&application.zcore.functions.zEscape(categoryIdArray[i])&"'";
			}

			db.sql = "SELECT *
				FROM #db.table( 'directory_category', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND directory_category_id IN ( #db.trustedSQL( arrayToList( categoryIdArray, ',' ) )# )
					AND directory_category_deleted = #db.param( 0 )#
				ORDER BY directory_category_name ASC ";
		}

		qCategories = db.execute( 'qCategories' );

		categories = [];

		for ( category in qCategories ) {

			if ( category.directory_category_unique_url NEQ '' ) {
				category.__url = category.directory_category_unique_url;
			} else {
				category.__url = this.getDirectoryLink( ts.optionStruct.directory_config_category_url_id, category.directory_category_id, 'html', category.directory_category_name );
			}

			arrayAppend( categories, category );
		}

		return categories;
	</cfscript>
</cffunction>

<cffunction name="getDirectoryById" localmode="modern" access="public">
	<cfargument name="directoryId" type="string" required="yes">
	<cfscript>
	return {};
	 // TODO: need to implement
		directoryId = arguments.directoryId;

		directoriesearch = {
			directory_id: directoryId
		};

		directories = this.searchDirectories( directoriesearch );

		if ( structKeyExists( directories, 'count' ) ) {
			if ( directories.count GT 0 ) {
				directory = directories.arrData[ 1 ];
			} else {
				directory = {};
			}
		} else {
			directory = {};
		}

		return directory;
	</cfscript>
</cffunction>
 
</cfoutput>
</cfcomponent>
