<cfcomponent>
<cfoutput>  
<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0; 
	db.sql="SELECT * FROM #db.table("short_link", request.zos.zcoreDatasource)#
	WHERE short_link_id= #db.param(application.zcore.functions.zso(form,'short_link_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	short_link_deleted = #db.param(0)#  ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Link doesn''t exist or was already removed', false,true);
		application.zcore.functions.zRedirect('/z/admin/short-link/index?zsid=#request.zsid#');
	} 
	db.sql="DELETE FROM #db.table("short_link", request.zos.zcoreDatasource)# WHERE 
	short_link_id= #db.param(application.zcore.functions.zso(form, 'short_link_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	short_link_deleted = #db.param(0)#   ";
	q=db.execute("q");
	application.zcore.status.setStatus(Request.zsid, 'Link deleted');
	application.zcore.functions.zRedirect('/z/admin/short-link/index?zsid=#request.zsid#');
	</cfscript> 
</cffunction>
 


<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var ts={};
	var result=0;
	init(); 
	ts.short_link_url.required=true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/short-link/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/short-link/edit?short_link_id=#form.short_link_id#&zsid=#request.zsid#');
		}
	}  
	form.short_link_deleted=0;
	form.short_link_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table='short_link';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.short_link_id = application.zcore.functions.zInsert(ts);
		if(form.short_link_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save short link.',form,true);
			application.zcore.functions.zRedirect('/z/admin/short-link/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Short link saved.');
			//variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save short link.',form,true);
			application.zcore.functions.zRedirect('/z/admin/short-link/edit?short_link_id=#form.short_link_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Short link updated.');
		} 
	} 
	application.zcore.functions.zRedirect('/z/admin/short-link/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject; 
	var currentMethod=form.method; 
	if(application.zcore.functions.zso(form,'short_link_id') EQ ''){
		form.short_link_id = -1;
	}
	db.sql="SELECT * FROM #db.table("short_link", request.zos.zcoreDatasource)# short_link 
	WHERE  
	short_link_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	short_link_id=#db.param(form.short_link_id)#";
	qLink=db.execute("qLink");
	application.zcore.functions.zQueryToStruct(qLink);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2><cfif currentMethod EQ "add">
		Add
		<cfscript>
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		</cfscript>
	<cfelse>
		Edit
	</cfif>
	Link</h2>
	 
	<cfscript>
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
			tabCom.init();
	tabCom.setTabs(["Basic"]);
	tabCom.setMenuName("admin-list"); 
	cancelURL="/z/admin/short-link/index"; 
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	</cfscript>
	<form id="listForm1" action="/z/admin/short-link/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?short_link_id=#form.short_link_id#" method="post">
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Basic")#

	<table style="width:100%;" class="table-list">  
		<tr>
			<th>Short Link URL</th>
			<td><input type="text" name="short_link_url" id="short_link_url" value="#htmleditformat(form.short_link_url)#" /></td>
		</tr>
	 
	</table>

	#tabCom.endFieldSet()#  
	#tabCom.endTabMenu()#    
	</form>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="administrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Short Links");	 
	</cfscript>
</cffunction>	

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	init();  
	application.zcore.functions.zStatusHandler(request.zsid);

	form.zIndex=application.zcore.functions.zso(form, 'zIndex',true, 1); 
	form.short_link_search=application.zcore.functions.zso(form, 'short_link_search'); 
 
 	searchOn=false; 
	db.sql="SELECT short_link.* 
	 from #db.table("short_link", request.zos.zcoreDatasource)#  
	WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	short_link_deleted = #db.param(0)# ";
	if(form.short_link_search NEQ ""){
		searchOn=true;
		db.sql&=" and (short_link_url like #db.param('%#application.zcore.functions.zURLEncode(form.short_link_search, '%')#%')# or short_link.short_link_id =#db.param(form.short_link_search)#) ";
	}  
	db.sql&=" ORDER BY short_link_url 
	LIMIT #db.param((form.zIndex-1)*30)#, #db.param(30)#";
	qShortLink=db.execute("qShortLink");


	db.sql="SELECT count(short_link_id) count 
	 from #db.table("short_link", request.zos.zcoreDatasource)#  
	WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	short_link_deleted = #db.param(0)# ";
	if(form.short_link_search NEQ ""){
		searchOn=true;
		db.sql&=" and (short_link_url like #db.param('%#application.zcore.functions.zURLEncode(form.short_link_search, '%')#%')# or short_link.short_link_id =#db.param(form.short_link_search)#) ";
	}  
	qCount=db.execute("qCount"); 
	searchStruct = StructNew();
	searchStruct.showString = "";
	searchStruct.indexName = 'zIndex';
	searchStruct.url = "/z/admin/short-link/index?short_link_search=#urlencodedformat(form.short_link_search)#";
	searchStruct.index=form.zIndex;
	searchStruct.buttons = 5;
	searchStruct.count = qCount.count;
	searchStruct.perpage = 30;
	searchNav=application.zcore.functions.zSearchResultsNav(searchStruct);
	if(qCount.count <= 10){
		searchNav="";
	}
	</cfscript>
	<h2>Manage Links</h2>
	<p><a href="/z/admin/short-link/add">Add Link</a></p>
	<p>Short links turn a long url into a shorter unique ID based URL that can be updated later without breaking old links.  This is useful for links placed on other web sites like Facebook or Twitter where there may be limited space.</p>

	<form action="/z/admin/short-link/index" method="get">
		<table class="table-list">
			<tr>
				<td><h2>Search</h2></td>
				<td>
					Keyword or ID: <input type="text" name="short_link_search" style="min-width:200px;width:200px;" value="#htmleditformat(form.short_link_search)#">
				</td> 
				<td>
					<input type="submit" name="search1" value="Search"> 
					<cfif searchOn>
		
						<input type="button" name="showall1" value="Show All" onclick="window.location.href='/z/admin/short-link/index';">
					</cfif>
				</td>
			</tr>
		</table>
	</form>
	<cfif qShortLink.recordcount EQ 0>
		<p>No short links found.</p>
	<cfelse>
 

		#searchNav#
		<table class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Full URL</th> 
				<th>Short URL</th> 
				<th>Updated Date</th>  
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfloop query="qShortLink">
				<tr <cfif qShortLink.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					<td>#qShortLink.short_link_id#</td> 
					<td><a href="#qShortLink.short_link_url#" target="_blank">#qShortLink.short_link_url#</a></td> 
					<td><input type="text" name="short_url" style="min-width:250px; width:250px; " id="short_url#qShortLink.short_link_id#" value="#replace(request.zos.globals.domain, 'www.', '')#/z/-vl.#qShortLink.short_link_id#"></td> 
					<td>#dateformat(qShortLink.short_link_updated_datetime, "m/d/yy")#</td>

					<td> 
					<a href="/z/-vl.#qShortLink.short_link_id#" target="_blank">View</a> | 
					<a href="##" onclick="document.getElementById('short_url#qShortLink.short_link_id#').select();document.execCommand('copy'); return false;">Copy to Clipboard</a> | 
					<a href="/z/admin/short-link/edit?short_link_id=#qShortLink.short_link_id#">Edit</a> |  
						<a href="/z/admin/short-link/delete?short_link_id=#qShortLink.short_link_id#" onclick="return window.confirm('Are you sure you want to remove this link?');">Delete</a> 

					</td>

				</tr>
				</cfloop>
			</tbody>
		</table>
		#searchNav#
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>