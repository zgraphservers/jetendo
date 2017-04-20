<cfcomponent>
<cfoutput> 
<cffunction name="getUserLeadFilterSQL" localmode="modern" access="public">
	<cfargument name="db" type="component" required="yes">
	<cfscript>
	db=arguments.db;

	savecontent variable="out"{
		echo(' and ( ');

		if(request.zsession.user.office_id NEQ ""){
			echo(' (inquiries.user_id=#db.param(0)# and inquiries.office_id IN (#db.trustedSQL(request.zsession.user.office_id)#) ) or ');
		}
		if(request.userIdList NEQ ""){
			echo(' (inquiries.user_id IN (#db.trustedSQL(request.userIdList)#) and inquiries.user_id_siteIdType=#db.param(1)#) or ');
		}
			// current user 
			echo(' (inquiries.user_id = #db.param(request.zsession.user.id)# and 
			inquiries.user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#)
		) ');
	}
	return out;
	</cfscript>
</cffunction>

<cffunction name="getUserIdListByOfficeIdListAndGroupIdList" localmode="modern" access="public">
    <cfargument name="officeIdList" type="string" required="yes">
    <cfargument name="groupIdList" type="string" required="yes">
    <cfscript> 
    db=request.zos.queryObject;

    arrOfficeId=listToArray(arguments.officeIdList, ",");
    arrGroupId=listToArray(arguments.groupIdList, ",");

    db.sql="SELECT group_concat(distinct user_id SEPARATOR #db.param(',')#) idlist 
    FROM #db.table("user", request.zos.zcoreDatasource)# 
    WHERE site_id = #db.param(request.zos.globals.id)# AND 
    user_active=#db.param(1)# and 
    user_deleted=#db.param(0)# and ";
    if(arrayLen(arrGroupId) EQ 0){
    	db.sql&=" user_group_id=#db.param(-1)# ";
    }else{
    	db.sql&=" user_group_id IN (";
        for(i=1;i LTE arraylen(arrGroupId);i++){
            id=arrGroupId[i];
            if(i NEQ 1){
            	db.sql&=", ";
            }
            db.sql&=db.param(id);
        }
        db.sql&=" ) "; 
    }
    db.sql&=" and ";
    if(arrayLen(arrOfficeId) EQ 0){
    	db.sql&=" office_id=#db.param(-1)# ";
    }else{
    	db.sql&=" office_id IN (";
        for(i=1;i LTE arraylen(arrOfficeId);i++){
            id=arrOfficeId[i];
            if(i NEQ 1){
            	db.sql&=", ";
            }
            db.sql&=db.param(id);
        }
        db.sql&=" ) "; 
    }
    db.sql&=" ORDER BY user_first_name ASC, user_last_name ASC";
    qUser=db.execute("qUser"); 
    return qUser.idlist;
    </cfscript>
</cffunction>

<cffunction name="userInit" localmode="modern" access="public">
	<cfscript>
	if(not structkeyexists(request, 'manageLeadUserGroupStruct')){
		request.manageLeadUserGroupStruct={};
	}
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	// TODO: isReservationSystem=true functionality is no longer possible. I should remove all this code.
	variables.isReservationSystem=false;
	found=false;
	groupStruct={};
	
	userGroupCom=createobject("component", "zcorerootmapping.com.user.user_group_admin"); 
	for(i in request.manageLeadUserGroupStruct){
		if(application.zcore.user.checkGroupAccess(i)){  
			if(isstruct(request.manageLeadUserGroupStruct[i])){
				for(n in request.manageLeadUserGroupStruct[i]){
					if(application.zcore.user.checkGroupAccess(n)){
						//echo("has access:"&n&"<br>");
						groupId=userGroupCom.getGroupId(n, request.zos.globals.id);
						groupStruct[groupId]=true;
					}
				}
			}
			found=true; 
		} 
	} 
	request.userIdList=""; 
	if(structcount(groupStruct) NEQ 0){
		groupIdList=structkeylist(groupStruct);
		// build a userIdList of user that belong to request.zsession.user.office_id and the user groups this user can manage
		request.userIdList=getUserIdListByOfficeIdListAndGroupIdList(request.zsession.user.office_id, groupIdList); 
	}  
	if(application.zcore.functions.zso(form, 'inquiries_id', true) NEQ 0){
		if(not userHasAccessToLead(form.inquiries_id)){
			found=false;
		}
	}
	if(not found){  
		form.userLoginURL=application.zcore.functions.zso(request.zos.globals, 'userLoginURL');
		if(form.userLoginURL NEQ ""){
			application.zcore.status.setStatus(request.zsid, "You don't have access to this lead or need to login.", form, true);
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(form.userLoginURL, "zsid=#request.zsid#"));
		}else{
			application.zcore.status.setStatus(request.zsid, "You don't have access to this lead or need to login.", form, true);
			application.zcore.functions.zRedirect("/z/user/home/index?zsid=#request.zsid#");
		}
	}
	</cfscript>
</cffunction>


<cffunction name="userExport" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	exportCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.export");
	exportCom.index();
	</cfscript>
	
</cffunction>
<cffunction name="userView" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	feedbackCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
	feedbackCom.view();
	</cfscript>
	
</cffunction> 

<cffunction name="userHasAccessToLead" localmode="modern" access="public" roles="user">
	<cfargument name="inquiries_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	if(not structkeyexists(request.zsession, 'user')){
		return false;
	}
	db.sql="select inquiries_id from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_id = #db.param(arguments.inquiries_id)# ";

	db.sql&=getUserLeadFilterSQL(db);
	/*
	and 
	(";
		if(request.zsession.user.office_id NEQ ""){
			db.sql&=" (office_id IN (#db.trustedSQL(request.zsession.user.office_id)#) and user_id =#db.param(0)# ) or ";
		}
		db.sql&=" (user_id=#db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id))#)
	)";*/
	qCheckLead=db.execute("qCheckLead"); 
	if(qCheckLead.recordcount GT 0){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="userChangeStatus" localmode="modern" access="remote" roles="user">
	<cfscript>
	changeStatus();
	</cfscript>
</cffunction>
<!--- <cffunction name="userDelete" localmode="modern" access="remote" roles="user">
	<cfscript>
	delete();
	</cfscript>
	
</cffunction> --->
<cffunction name="userShowAllFeedback" localmode="modern" access="remote" roles="user">
	<cfscript>
	showAllFeedback();
	</cfscript>
	
</cffunction>
	 
<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript>
	index();
	</cfscript>
	
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript> 
	var db=request.zos.queryObject;
	var hCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	if(request.cgi_script_name CONTAINS "/z/inquiries/admin/manage-inquiries/"){
		hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		hCom.displayHeader();
	}
	variables.isReservationSystem=false;
	</cfscript>
</cffunction>

<cffunction name="changeStatus" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qIn=0;
	currentMethod=form.method;
	if(currentMethod EQ "userChangeStatus"){
		userInit();
	}else{
		init();
	}
	// TODO: need user security here
	db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	SET inquiries_status_id= #db.param(form.inquiries_status_id)#,
	inquiries_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE inquiries_id= #db.param(form.inquiries_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)#";
	qIn=db.execute("qIn");
	application.zcore.status.setStatus(request.zsid,'Status Updated');
	application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid=#request.zsid#');
	</cfscript>
</cffunction>
<!--- 
<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	currentMethod=form.method;
	if(currentMethod EQ "userDelete"){
		application.zcore.functions.z404("User can't delete leads.");
		userInit();
	}else{
		init();
	}
	db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_id=#db.param(form.inquiries_id)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Inquiry no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zsid=#request.zsid#&zPageId=#form.zPageId#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.site_id=request.zos.globals.id;
		application.zcore.functions.zDeleteRecord('inquiries','inquiries_id,site_id',request.zos.zcoreDatasource);
		application.zcore.status.setStatus(Request.zsid, 'Inquiry deleted');
		application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zsid=#request.zsid#&zPageId=#form.zPageId#');
		</cfscript>
		<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this inquiry?<br />
			<br />
			#qCheck.inquiries_first_name# #qCheck.inquiries_last_name# (#qcheck.inquiries_email#)<br />
			<br />
			<a href="/z/inquiries/admin/manage-inquiries/delete?confirm=1&amp;inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#">No</a> </div>
	</cfif>
</cffunction> --->

<cffunction name="showAllFeedback" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qFeedback=0;
	var searchNav=0;
	var searchStruct=0;
	var qFeedbackCount=0;
	currentMethod=form.method;
	if(currentMethod EQ "userShowAllFeedback"){
		application.zcore.functions.z404("userShowAllFeedback is disabled for non-admin users");
		userInit();
	}else{
		init();
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
			application.zcore.status.setStatus(request.zsid,"Access denied.");
			application.zcore.functions.zRedirect("/member/?zsid=#request.zsid#");	
		}
	}
	form.zPageId3=application.zcore.functions.zso(form, 'zPageId3');
	form.zIndex = application.zcore.status.getField(form.zPageId3, "zIndex", 1, true);
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>All Feedback</h2>
	<table  style="width:100%; border-spacing:0px;" class="table-white">
		<form action="/z/inquiries/admin/manage-inquiries/showAllFeedback" method="get" id="owner_lookup_form">
			<tr>
				<td>Type a name or phrase
					<input type="text" name="searchtext" value="#application.zcore.functions.zso(form, 'searchtext')#" size="20" maxchars="10" />
					<button type="submit" name="searchForm" value="Search">Search</button>
					<button type="button" name="searchForm2" value="Clear" onclick="window.location.href='/z/inquiries/admin/manage-inquiries/showallfeedback';">Clear</button>
					<input type="hidden" name="zIndex" value="1" />
					<input type="hidden" name="zPageId3" value="#form.zPageId3#" /></td>
			</tr>
		</form>
	</table>
	<cfsavecontent variable="db.sql"> 
	SELECT count(inquiries.inquiries_id) count 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback
	WHERE 
	inquiries_deleted = #db.param(0)# and 
	inquiries_feedback_deleted = #db.param(0)# and 
	inquiries.inquiries_id = inquiries_feedback.inquiries_id and
	<cfif trim(application.zcore.functions.zso(form, 'searchtext')) NEQ ''>
		(inquiries_feedback_comments LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_feedback_subject LIKE #db.param('%#form.searchtext#%')# or 
		concat(inquiries_first_name,#db.param(' ')#,inquiries_last_name) LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_email LIKE #db.param('%#form.searchtext#%')#) and
	</cfif>
	inquiries.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_feedback.site_id = inquiries.site_id </cfsavecontent>
	<cfscript>
	qFeedbackCount=db.execute("qFeedbackCount");
	</cfscript>
	<cfsavecontent variable="db.sql"> 
	SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries_feedback.user_id and 
	user_deleted = #db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_feedback.user_id_siteIDType"))# WHERE 
	inquiries_deleted = #db.param(0)# and 
	inquiries_feedback_deleted = #db.param(0)# and 
	inquiries.inquiries_id = inquiries_feedback.inquiries_id and
	<cfif trim(application.zcore.functions.zso(form, 'searchtext')) NEQ ''>
		(inquiries_feedback_comments LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_feedback_subject LIKE #db.param('%#form.searchtext#%')# or 
		concat(inquiries_first_name,#db.param(' ')#,inquiries_last_name) LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_email LIKE #db.param('%#form.searchtext#%')#) and
	</cfif>
	inquiries.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_feedback.site_id = inquiries.site_id 
	ORDER BY inquiries_feedback_datetime DESC 
	LIMIT #db.param((form.zIndex-1)*10)#,#db.param(10)# </cfsavecontent>
	<cfscript>
	qFeedback=db.execute("qFeedback");
	</cfscript>
	<cfif qFeedBack.recordcount NEQ 0>
		<hr />
		<cfscript>
		searchStruct = StructNew();
		searchStruct.count = qFeedbackCount.count;
		searchStruct.index = form.zIndex;
		searchStruct.showString = "Results ";

		searchStruct.url = "/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#";
		searchStruct.indexName = "zIndex";
		searchStruct.buttons = 5;
		searchStruct.perpage = 10;
		if(searchStruct.count LTE searchStruct.perpage){
			searchNav="";
		}else{
			searchNav = '<table class="table-list" style="width:100%; border-spacing:0px;" ><tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>';
		}
		</cfscript>
		#searchNav#<br />
		<table style="width:100%; border-spacing:0px;">
			<cfloop query="qFeedback">
				<cfif qFeedback.inquiries_feedback_subject NEQ ''>
					<tr>
						<td style="border:1px solid ##999999; background-color:##EFEFEF; ">#qFeedback.inquiries_feedback_subject#</td>
					</tr>
				</cfif>
				<cfif qFeedback.inquiries_feedback_comments NEQ ''>
					<tr>
						<td style=" border:1px solid ##999999;">#application.zcore.functions.zParagraphFormat(qFeedback.inquiries_feedback_comments)#</td>
					</tr>
				</cfif>
				<tr>
					<td style="border:1px solid ##999999; border-top:0px; ">By
						<cfif qFeedback.user_email EQ "">
							Unknown User
						<cfelse>
							<a href="mailto:#qFeedback.user_email#">#qFeedback.user_first_name# #qFeedback.user_last_name#</a>
						</cfif>
						on #DateFormat(qFeedback.inquiries_feedback_datetime, 'm/d/yyyy')&' at '&TimeFormat(qFeedback.inquiries_feedback_datetime, 'h:mm tt')# | 
						<a href="/z/inquiries/admin/feedback/view?inquiries_id=#qFeedback.inquiries_id#">View Lead</a> | 
						<a href="/z/inquiries/admin/feedback/deleteFeedback?inquiries_feedback_id=#qFeedback.inquiries_feedback_id#&amp;inquiries_id=#qFeedback.inquiries_id#">Delete</a></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
			</cfloop>
		</table>
		#searchNav#
	</cfif>
</cffunction>

<cffunction name="userInsertStatus" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	feedbackCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
	feedbackCom.insert();
	</cfscript>
</cffunction> 
 

<cffunction name="view" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	currentMethod=form.method;
	if(currentMethod EQ "userView"){
		userInit();
	}else{
		init();
	}
	db.sql="SELECT * FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status) 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)# and 	
	inquiries_status_deleted = #db.param(0)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	(( inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_parent_id = #db.param(0)# ) or 
	(inquiries_parent_id = #db.param(form.inquiries_id)# )) ";
	if(currentMethod EQ "userView"){
		db.sql&=getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	qinquiry=db.execute("qinquiry");
	if(qinquiry.recordcount EQ 0){		
		request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
	}
	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin"); 
	</cfscript>
	<p><a href="/z/inquiries/admin/manage-inquiries/<cfif currentMethod EQ "userView">userIndex<cfelse>index</cfif>">Leads</a> /</p>
	
	<cfloop query="qinquiry">
		<h2 style="display:inline;">Lead Details</h2>
		<cfif currentMethod EQ "userView" and structkeyexists(request, 'manageLeadEnableUserAssign')>
			| <a href="/z/inquiries/admin/assign/userIndex?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#">Assign Lead</a> 
		<cfelseif currentMethod EQ "view">
	
			<cfif qinquiry.inquiries_readonly EQ 1>
				| Read-only | Edit is disabled
			<cfelse>
				| <a href="/z/inquiries/admin/inquiry/edit?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#">Edit</a>
			</cfif> 
				| <a href="/z/inquiries/admin/assign/index?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#">Assign Lead</a> 
			<cfif qinquiry.inquiries_reservation EQ 1>
				| <a href="/z/rental/admin/reservations/cancel?inquiries_id=#qinquiry.inquiries_id#">Cancel Reservation</a>
			</cfif>
 
		</cfif>
		<br />
		<br />
		<cfscript> 
		viewIncludeCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		viewIncludeCom.getViewInclude(qinquiry);
        </cfscript>
	</cfloop>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	currentMethod=form.method;
	if(currentMethod EQ "userIndex"){
		userInit();
	}else{
		init();
		application.zcore.functions.zSetPageHelpId("4.1");
	}
	form.search_office_id=application.zcore.functions.zso(form, 'search_office_id', true, "0");
	form.searchType=application.zcore.functions.zso(form, 'searchType');
	form.search_email=application.zcore.functions.zso(form, 'search_email');
	form.search_phone=application.zcore.functions.zso(form, 'search_phone');
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}
	if(structkeyexists(form, 'leadcontactfilter')){
		request.zsession.leadcontactfilter=form.leadcontactfilter;		
	}else if(isDefined('request.zsession.leadcontactfilter') EQ false){
		request.zsession.leadcontactfilter='all';
	}
	if(structkeyexists(form, 'grouping')){
		request.zsession.leademailgrouping=form.grouping;
	}else if(structkeyexists(request.zsession, 'leademailgrouping') EQ false){
		request.zsession.leademailgrouping='0';
	}
	/*if(structkeyexists(form, 'viewspam')){
		request.zsession.leadviewspam=form.viewspam;
	}else if(not structkeyexists(request.zsession, 'leadviewspam')){*/
		request.zsession.leadviewspam=0;	
	//}
	qSortCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.querySort");
	form.zPageId = qSortCom.init("zPageId");
	if(structkeyexists(form, 'submitForm')){
		form.zIndex=1;
	}
	if(structkeyexists(form, 'zIndex')){
		 application.zcore.status.setField(form.zPageId, "zIndex", form.zIndex);
	}else{
		form.zIndex = application.zcore.status.getField(form.zPageId, "zIndex", 1, true);
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	application.zcore.functions.zStatusHandler(form.zPageId,true);
	db.sql="select min(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zos.globals.id)# and  
	inquiries.inquiries_datetime <> #db.param('')# and 
	inquiries_parent_id = #db.param(0)# and 
	inquiries_deleted = #db.param(0)# ";
	if(form.method EQ "userIndex"){
		db.sql&=getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ '0'){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
	qinquiriesFirst=db.execute("qinquiriesFirst"); 
	</cfscript>
	<cfsavecontent variable="db.sql"> 
	select max(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zos.globals.id)# and 
	<!--- <cfif form.inquiries_status_id EQ ""> 
		inquiries.inquiries_status_id <> #db.param(0)# and 
	<cfelse>
		inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# and 
	</cfif> --->
	inquiries.inquiries_datetime <> #db.param('')# and 
	inquiries_deleted = #db.param(0)# 
	<cfif variables.isReservationSystem>
		and inquiries_reservation_status=#db.param(0)#
	</cfif>
	and inquiries_parent_id = #db.param(0)#
	<cfif form.method EQ "userIndex">
		#getUserLeadFilterSQL(db)#
	<cfelseif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false>
		AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
	</cfif>
	<cfif form.selected_user_id NEQ 0>
		and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
	</cfif>
	</cfsavecontent>
	<cfscript>
	qinquiriesLast=db.execute("qinquiriesLast");
	</cfscript> 
	<cfscript>
	if(isnull(qinquiriesFirst.inquiries_datetime) EQ false and isdate(qinquiriesFirst.inquiries_datetime)){
		inquiryFirstDate=qinquiriesFirst.inquiries_datetime;
	}else{
		inquiryFirstDate=dateFormat(now(), "yyyy-mm-dd")&" 00:00:00";
	}
	if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
		form.inquiries_end_date=now();
	}
	if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
		form.inquiries_start_date=inquiryFirstDate; 
	}
	if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
		form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
		form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
	}
	if(datediff("d",form.inquiries_start_date, inquiryFirstDate) GT 0){
			form.inquiries_start_date=inquiryFirstDate;
	}
	if(dateCompare(form.inquiries_start_date, form.inquiries_end_date) EQ 1){
		form.inquiries_end_date = form.inquiries_start_date;
	} 
	</cfscript>
	<cfsavecontent variable="db.sql"> 
	SELECT count(inquiries_id) as count 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	WHERE inquiries.inquiries_status_id = #db.param('1')# and 
	inquiries_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#
	<cfif form.inquiries_status_id EQ ""> 
		 and inquiries.inquiries_status_id <> #db.param(0)#
	<cfelse>
		and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# 
	</cfif>
	<cfif variables.isReservationSystem>
		and inquiries_reservation_status=#db.param(0)#
	</cfif>
	and inquiries_parent_id = #db.param(0)#
	<cfif form.method EQ "userIndex">
		#getUserLeadFilterSQL(db)#
	<cfelseif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false>
		AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
	</cfif>
	<cfif form.selected_user_id NEQ 0>
		and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
	</cfif>
	</cfsavecontent>
	<cfscript>
	qinquiriesNew=db.execute("qinquiriesNew");
	db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status ";
	qstatus=db.execute("qstatus");
	statusName=structnew();
	loop query="qstatus"{
		statusName[qstatus.inquiries_status_id]=qstatus.inquiries_status_name;
	}
	</cfscript>
	<cfsavecontent variable="db.sql"> SELECT *, 
	inquiries_id maxid, inquiries_datetime maxdatetime, #db.param('1')# inquiryCount
	FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries)
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE  
	inquiries_deleted = #db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#
	<cfif form.search_phone NEQ "">
		and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# 
	</cfif>
	<cfif form.search_email NEQ "">
		and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# 
	</cfif>
	<cfif form.search_office_id NEQ "0">
		and inquiries.office_id = #db.param(form.search_office_id)# 
	</cfif>
	<cfif form.inquiries_status_id EQ ""> 
		 and inquiries.inquiries_status_id <> #db.param(0)#
	<cfelse>
		and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# 
	</cfif>
	<cfif variables.isReservationSystem>
		and inquiries_reservation_status=#db.param(0)#
	</cfif>
	and inquiries_parent_id = #db.param(0)#

	<cfif form.method EQ "userIndex">
		#getUserLeadFilterSQL(db)#
	<cfelseif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false>
		AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
	</cfif>
	<cfif form.selected_user_id NEQ 0>
		and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
	</cfif>
	<cfif form.searchType EQ "">
		<cfif form.inquiries_status_id EQ ""> 
			<cfif request.zsession.leadcontactfilter NEQ 'allclosed'>
				and inquiries.inquiries_status_id NOT IN (#db.param('4')#,#db.param('5')#,#db.param('7')#)
			<cfelse>
				and inquiries.inquiries_status_id IN (#db.param('4')#,#db.param('5')#,#db.param('7')#)
			</cfif> 
		</cfif>
	<cfelse>
		<cfif form.searchType EQ 0>
			<cfif form.inquiries_start_date EQ false>
				and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)
			<cfelse>
				and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)
			</cfif>
		<cfelse>
			<cfif form.inquiries_start_date EQ false>
				and (inquiries_start_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_end_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)
			<cfelse>
				and (inquiries_start_date >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_end_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)
			</cfif>
		</cfif>
		<cfif application.zcore.functions.zso(form, 'inquiries_name') NEQ "">
			and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')#
		</cfif>
		<cfif application.zcore.functions.zso(form, 'inquiries_type_id') NEQ "" and form.inquiries_type_id CONTAINS "|">
			and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
			inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))#
		</cfif>

	
	</cfif>
	<!--- <cfif request.zsession.leadviewspam EQ "0">
		and inquiries.inquiries_spam =#db.param(0)#
	</cfif> --->
	<cfif form.inquiries_status_id EQ ""> 
		<cfif request.zsession.leadcontactfilter EQ 'new'>
			and inquiries.inquiries_status_id =#db.param('1')# 
		<cfelseif request.zsession.leadcontactfilter EQ 'email'>
			and inquiries_phone1 =#db.param('')# and inquiries_phone_time=#db.param('')#
		<cfelseif request.zsession.leadcontactfilter EQ 'phone'>
			and inquiries_phone1 <>#db.param('')# and inquiries_phone_time=#db.param('')#
		<cfelseif request.zsession.leadcontactfilter EQ 'forced'>
			and inquiries_phone_time<>#db.param('')#
		</cfif> 
	</cfif>
	<cfif request.zsession.leademailgrouping EQ '1'>
		and inquiries_primary = #db.param('1')#
	</cfif>
	<cfif qsortcom.getorderby(false) NEQ ''>
		ORDER BY #qsortcom.getorderby(false)# inquiries_id ASC
	<cfelse>
		ORDER BY maxdatetime DESC
	</cfif>
	<cfif form.searchType NEQ "">
		LIMIT #db.param(max(0,(form.zIndex-1))*10)#,#db.param(10)#
	<cfelse>
		LIMIT #db.param(max(0,(form.zIndex-1))*30)#,#db.param(30)#
	</cfif>
	</cfsavecontent>
	<cfscript>
	qinquiries=db.execute("qinquiries");     
	</cfscript>
	<cfsavecontent variable="db.sql"> SELECT count(
	<cfif request.zsession.leademailgrouping EQ '1'>
		DISTINCT
	</cfif>
	inquiries.inquiries_email) count 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)# and 
	<cfif form.inquiries_status_id EQ ""> 
		inquiries.inquiries_status_id <> #db.param(0)# and 
	<cfelse>
		inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# and 
	</cfif>
	inquiries_deleted = #db.param(0)# 
	<cfif variables.isReservationSystem>
		and inquiries_reservation_status=#db.param(0)#
	</cfif>
	and inquiries_parent_id = #db.param(0)#
	<cfif form.method EQ "userIndex">
		#getUserLeadFilterSQL(db)#
	<cfelseif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false>
		AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
	</cfif>
	<cfif form.selected_user_id NEQ 0>
		and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
	</cfif>
	<cfif form.search_office_id NEQ "0">
		and inquiries.office_id = #db.param(form.search_office_id)# 
	</cfif>
	<cfif form.search_phone NEQ "">
		and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# 
	</cfif>
	<cfif form.search_email NEQ "">
		and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# 
	</cfif>
	<cfif form.searchType EQ "">
		<cfif form.inquiries_status_id EQ ""> 
			<cfif request.zsession.leadcontactfilter NEQ 'allclosed'>
				and inquiries.inquiries_status_id NOT IN (#db.param('4')#,#db.param('5')#,#db.param('7')#)
			<cfelse>
				and inquiries.inquiries_status_id IN (#db.param('4')#,#db.param('5')#,#db.param('7')#)
			</cfif> 
		</cfif>
	<cfelse>
		<cfif form.searchType EQ 0>
			<cfif form.inquiries_start_date EQ false>
				and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)
			<cfelse>
				and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)
			</cfif>
		<cfelse>
			<cfif form.inquiries_start_date EQ false>
				and (inquiries_start_date >= #db.param(dateformat(now(), "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_end_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)
			<cfelse>
				and (inquiries_start_date >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
				inquiries_end_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)
			</cfif>
		</cfif>
		<cfif application.zcore.functions.zso(form, 'inquiries_name') NEQ "">
			and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')#
		</cfif>
		<cfif application.zcore.functions.zso(form, 'inquiries_type_id') NEQ "" and form.inquiries_type_id CONTAINS "|">
			and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
			inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))#
		</cfif>

	</cfif>
	<!--- <cfif request.zsession.leadviewspam EQ "0">
		and inquiries.inquiries_spam =#db.param(0)#
	</cfif> --->
	<cfif form.inquiries_status_id EQ ""> 
		<cfif request.zsession.leadcontactfilter EQ 'new'>
			and inquiries.inquiries_status_id =#db.param('1')#
		<cfelseif request.zsession.leadcontactfilter EQ 'email'>
			and inquiries_phone1 =#db.param('')# and inquiries_phone_time=#db.param('')#
		<cfelseif request.zsession.leadcontactfilter EQ 'phone'>
			and inquiries_phone1 <>#db.param('')# and inquiries_phone_time=#db.param('')#
		<cfelseif request.zsession.leadcontactfilter EQ 'forced'>
			and inquiries_phone_time<>#db.param('')#
		</cfif> 
	</cfif>
	<cfif request.zsession.leademailgrouping EQ '1'>
		and inquiries_primary = #db.param('1')#
	</cfif>
	</cfsavecontent>
	<cfscript> 
	qinquiriesActive=db.execute("qinquiriesActive"); 
	</cfscript>
	<h2>Search Leads</h2>
	<form action="/z/inquiries/admin/manage-inquiries/#currentMethod#" method="get"> 
		<div style="border-spacing:0px; width:100%;  float:left; "> 
			<div style="float:left; padding-right:10px; padding-bottom:10px; width:280px;">
				<div style="float:left; padding-right:10px; padding-bottom:10px; width:100%; ">
					<div style="width:50px; float:left;">Name:</div>
					<div style="width:200px; float:left;">
						<input type="text" name="inquiries_name" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'inquiries_name')#" />
					</div>
				</div>
				<div style="float:left; padding-right:10px; padding-bottom:10px; width:100%; ">
					<div style="width:50px; float:left;">Email:</div>
					<div style="width:200px; float:left;">
						<input type="text" name="search_email" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_email')#" />
					</div>
				</div>
				<div style="float:left; padding-right:10px; padding-bottom:10px; width:100%; ">
					<div style="width:50px; float:left;">Phone:</div>
					<div style="width:200px; float:left;">
						<input type="text" name="search_phone" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_phone')#" />
					</div>
				</div>
				<div style="float:left; padding-right:10px; padding-bottom:10px; width:100%; ">
					<div style="width:50px; float:left;">Type:</div>
					<div style="width:200px; float:left;">
						<cfscript>
						db.sql="SELECT *, 
						#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as 
						inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
						WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
						inquiries_type_deleted = #db.param(0)# ";
						if(not application.zcore.app.siteHasApp("listing")){
							db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
						}
						if(not application.zcore.app.siteHasApp("rental")){
							db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
						}
						db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
						qTypes=db.execute("qTypes");
						selectStruct = StructNew();
						selectStruct.name = "inquiries_type_id";
						selectStruct.query = qTypes;
						selectStruct.queryLabelField = "inquiries_type_name";
						selectStruct.queryParseValueVars=true;
						selectStruct.queryValueField = "##inquiries_type_id##|##inquiries_type_id_siteIDType##";
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript>
					</div>
				</div>
				<div style="float:left; padding-right:10px; padding-bottom:10px; width:100%; ">
					<div style="width:50px; float:left;">Status:</div>
					<div style="width:200px; float:left;">
						<cfscript>
						db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# 
						WHERE   
						inquiries_status_deleted = #db.param(0)# "; 
						db.sql&="ORDER BY inquiries_status_name ASC ";
						qStatus=db.execute("qStatus");
						selectStruct = StructNew();
						selectStruct.name = "inquiries_status_id";
						selectStruct.query = qStatus;
						selectStruct.queryLabelField = "inquiries_status_name"; 
						selectStruct.queryValueField = "inquiries_status_id";
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript>
					</div>
				</div>
			</div>
			<div style="float:left; padding-right:10px; padding-bottom:10px; width:240px;">
				<div style="float:left;  padding-bottom:10px;width:100%;">
					<div style="width:50px; float:left;">Start:</div>
					<div style="width:180px; float:left;"><input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#"> 
					</div>
				</div>
				<div style="float:left; width:100%;">
					<div style="width:50px; float:left;">End:</div>
					<div style="width:180px; float:left;"><input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">
					</div>
				</div>
				<cfif variables.isReservationSystem>
					<div style="float:left; padding-top:10px; ">
						<input type="radio" name="searchtype" value="0" <cfif form.searchType EQ 0>checked="checked"</cfif> style="background:none; border:none;" />
						Received Date<br  />
						<input type="radio" name="searchtype" value="1" <cfif form.searchType EQ 1>checked="checked"</cfif> style="background:none; border:none;" />
						Proposed Occupancy.
					</div>
				<cfelse>
					<input type="hidden" name="searchtype" value="0" />
				</cfif>
			</div>
 
			<cfscript> 
			qOffice=application.zcore.user.getOfficesByOfficeIdList(request.zsession.user.office_id); 
			</cfscript> 
			<!--- office search is only useful when there is more then one office --->
			<cfif application.zcore.user.checkGroupAccess("administrator") or qOffice.recordcount GT 1>
				<div style="float:left; max-width:100%; padding-right:10px; padding-bottom:10px; ">
					<cfscript> 
					selectStruct = StructNew();
					selectStruct.name = "search_office_id"; 
					selectStruct.query = qOffice;
					selectStruct.size=3; 
					selectStruct.queryLabelField = "office_name";
					selectStruct.inlineStyle="width:100%; max-width:100%;";
					selectStruct.queryValueField = 'office_id';

					if(qOffice.recordcount GT 3){
						echo('Office:<br>
							Type to filter offices: <input type="text" name="#selectStruct.name#_InputField" id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select Office:<br>');
						application.zcore.functions.zInputSelectBox(selectStruct);
				   		application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
			   		}else{
			   			selectStruct.size=1;
						echo('<div style="width:50px; float:left;">Office:</div><div style="width:200px;float:left;">');
						application.zcore.functions.zInputSelectBox(selectStruct);
						echo('</div>');
			   		}
					</cfscript>
				</div>
			</cfif> 

			<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
				<div style="float:left; padding-right:10px; padding-bottom:10px; ">
					<cfscript>
					userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
					user_group_id = userGroupCom.getGroupId('agent',request.zos.globals.id);
					db.sql="SELECT user_id, user_username, member_company, user_first_name, user_last_name, site_id, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL('user.site_id'))# as siteIdType 
					FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
					user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))#  
					 and (user_server_administrator=#db.param(0)# ) and 
					 user_deleted = #db.param(0)#
					ORDER BY member_first_name ASC, member_last_name ASC";
					qAgents=db.execute("qAgents");
					</cfscript>
					<script type="text/javascript">
					/* <![CDATA[ */
					var agentSiteIdTypeLookup=[];
					<cfloop query="qAgents">
					agentSiteIdTypeLookup.push("<cfif qAgents.site_id EQ request.zos.globals.id>1<cfelse>2</cfif>");
					</cfloop>
					/* ]]> */
					</script>
					Assignee:<br>Type to filter assignees: 
					<cfscript> 
					selectStruct = StructNew();
					selectStruct.name = "uid";
					echo('<input type="text" name="#selectStruct.name#_InputField" id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select assigness:<br>');
					form.user_id=form.uid; 
					selectStruct.query = qAgents;
					selectStruct.size=3;
					selectStruct.selectedValues=form.user_id;
					selectStruct.queryLabelField = "##user_first_name## ##user_last_name## / ##user_username## / ##member_company##";
					selectStruct.queryParseLabelVars = true;
					selectStruct.queryParseValueVars = true; 
					selectStruct.inlineStyle="width:100%; max-width:100%;";
					selectStruct.queryValueField = '##user_id##|##siteIdType##';
					application.zcore.functions.zInputSelectBox(selectStruct);
			   		application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
					</cfscript>
				</div>
			</cfif>

			<div style="float:left; padding-right:10px; padding-bottom:10px; "><button type="submit" name="submitForm">Search</button></div>
		</div>
	</form>
	<!--- <hr /> --->
	<cfif form.searchType NEQ "">
		<h2 style="display:inline; ">Search Results | </h2>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?zindex=1">Start New Search</a><!--- <br />
		<br /> --->
	<cfelse>
		<h2 style="display:inline; ">All Active Leads</h2>
	</cfif>
	<cfif qsortcom.getorderby(false) NEQ ''>
		| <a href="/z/inquiries/admin/manage-inquiries/#currentMethod#">Clear Sorting</a>
	</cfif>
	<!--- 
	This was removed, because it is redundant with search.
	Show:
	<cfif request.zsession.leadcontactfilter NEQ 'all'>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?leadcontactfilter=all&amp;zPageId=#form.zPageId#">All Active</a>
	<cfelse>
		<strong>All Active</strong>
	</cfif>
	|
	<cfif request.zsession.leadcontactfilter NEQ 'new'>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?leadcontactfilter=new&amp;zPageId=#form.zPageId#">New</a>
	<cfelse>
		<strong>New</strong>
	</cfif>
	|
	<cfif request.zsession.leadcontactfilter NEQ 'email'>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?leadcontactfilter=email&amp;zPageId=#form.zPageId#">Email Only</a>
	<cfelse>
		<strong>Email Only</strong>
	</cfif>
	|
	<cfif request.zsession.leadcontactfilter NEQ 'phone'>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?leadcontactfilter=phone&amp;zPageId=#form.zPageId#">Phone + Email</a>
	<cfelse>
		<strong>Phone + Email</strong>
	</cfif>
	|
	<cfif request.zsession.leadcontactfilter NEQ 'forced'>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?leadcontactfilter=forced&amp;zPageId=#form.zPageId#">Forced Leads</a>
	<cfelse>
		<strong>Forced Leads</strong>
	</cfif>
	|
	<cfif request.zsession.leadcontactfilter NEQ 'allclosed'>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?leadcontactfilter=allclosed&amp;zPageId=#form.zPageId#">All Closed</a>
	<cfelse>
		<strong>All Closed</strong>
	</cfif>
	| <strong>Group By Email:</strong>
	<cfif request.zsession.leademailgrouping NEQ '1'>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?grouping=1&amp;zPageId=#form.zPageId#">Enable</a>
	<cfelse>
		<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?grouping=0&amp;zPageId=#form.zPageId#">Disable</a>
	</cfif>
	<cfif qsortcom.getorderby(false) NEQ ''>
		| <a href="/z/inquiries/admin/manage-inquiries/#currentMethod#">Clear Sorting</a>
	</cfif> --->
	<!---  |  
	<cfif request.zsession.leadviewspam NEQ '1'>
		<strong><a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?viewspam=1&amp;zPageId=#form.zPageId#">View Spam</a></strong>
	 <cfelse>
		<strong><a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?viewspam=0&amp;zPageId=#form.zPageId#">Hide Spam</a></strong>
	 </cfif> --->
	<br />
	<br />
	<cfscript>
	searchNav="";
	</cfscript> 
	<cfif qinquiriesActive.count EQ 0>
		<p>No leads found.</p>
	<cfelse>
		<cfscript> 
		searchStruct = StructNew();
		searchStruct.count = qinquiriesActive.count;
		searchStruct.index = form.zIndex;
		searchStruct.showString = "Results ";
		searchStruct.url="/z/inquiries/admin/manage-inquiries/#currentMethod#?uid=#form.uid#&zPageId=#form.zPageId#&
		search_email=#urlencodedformat(form.search_email)#&search_phone=#urlencodedformat(form.search_phone)#&inquiries_name=#urlencodedformat(application.zcore.functions.zso(form, 'inquiries_name'))#&inquiries_status_id=#form.inquiries_status_id#&inquiries_type_id=#application.zcore.functions.zso(form, 'inquiries_type_id')#&searchtype=#form.searchType#";
		if(structkeyexists(form, 'inquiries_end_date')){
			searchStruct.url&="&inquiries_end_date=#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#";
		}
		if(structkeyexists(form, 'inquiries_start_date')){
			searchStruct.url&="&inquiries_start_date=#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#";
		}; 
		searchStruct.indexName = "zIndex";
		searchStruct.buttons = 5;
		if(form.searchType NEQ ""){		
			searchStruct.perpage = 10;
		}else{
			searchStruct.perpage = 30;
		}
		if(searchStruct.count LTE searchStruct.perpage){
			searchNav="";
		}else{
			searchNav = '<table class="table-list" style="width:100%; border-spacing:0px;" >		
		<tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>';
		}
		</cfscript>
		#searchNav#
		<table class="table-list" style="width:100%; border-spacing:0px;" >
			<tr>
				<th><a href="#qSortCom.getColumnURL("inquiries_first_name", "/z/inquiries/admin/manage-inquiries/#currentMethod#")#" style="text-decoration:underline;">First</a> 
				#qSortCom.getColumnIcon("inquiries_first_name")# / 
				<a href="#qSortCom.getColumnURL("inquiries_last_name", "/z/inquiries/admin/manage-inquiries/#currentMethod#")#" style="text-decoration:underline;">Last</a> 
				#qSortCom.getColumnIcon("inquiries_last_name")# Name</th>
				<th>Phone</th>
				<th style="min-width:200px;">Assigned To</th>
				<th>Status</th>
				<th>Received</th>
				<cfif variables.isReservationSystem>
					<th>Start</th>
					<th>End</th>
				<cfelse>
					<th>Type</th>
				</cfif>
				<th>Admin</th>
			</tr>
			<!--- <cfsavecontent variable="db.sql"> SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_id = #db.param(request.zsession.user.id)# and 
			#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL("user"))# and 
			user_server_administrator=#db.param('0')# and 
			user_deleted = #db.param(0)# </cfsavecontent>
			<cfscript>
			qMember=db.execute("qMember");
			</cfscript> --->
			<cfset arrId=ArrayNew(1)>
			<cfloop query="qinquiries">
				<cfscript>
				local.inquiries_status_name = statusName[qinquiries.inquiries_status_id];
				ArrayAppend(arrId,qinquiries.inquiries_id);
				</cfscript>
				<tr <cfif qinquiries.inquiries_status_id EQ 1 or qinquiries.inquiries_status_id EQ 2><cfif qinquiries.currentrow mod 2 EQ 0>class="row1"<cfelse>class="row2"</cfif><cfelse><cfif qinquiries.currentrow mod 2 EQ 0>class="row2"<cfelse>class="row1"</cfif></cfif>>
					<td><a href="/z/inquiries/admin/feedback/view?inquiries_id=#qinquiries.inquiries_id#&amp;zPageId=#form.zPageId#">#qinquiries.inquiries_first_name# #qinquiries.inquiries_last_name#</a></td>
					<td>#qinquiries.inquiries_phone1#&nbsp;</td>
					<td style="min-width:200px;">
						<cfif qinquiries.inquiries_assign_email NEQ ''> 
							<cfscript>
							arrEmail=listToArray(qinquiries.inquiries_assign_email, ",");
							for(i=1;i<=arraylen(arrEmail);i++){
								e=arrEmail[i];
								if(i NEQ 1){
									echo(', ');
								}
								echo('<a href="mailto:#e#">');
								if(structkeyexists(qinquiries, 'inquiries_assign_name') and qinquiries.inquiries_assign_name neq '' and arraylen(arrEmail) EQ 1){
									echo(qinquiries.inquiries_assign_name);
								}else{
									echo(e);
								}
								echo('</a> ');
							}
							</cfscript>
							
						<cfelse>
							<cfif qinquiries.user_id NEQ 0>
								<cfif qinquiries.user_first_name NEQ "">
									<a href="mailto:#qinquiries.user_username#">#qinquiries.user_first_name# #qinquiries.user_last_name#
										<cfif qinquiries.member_company NEQ "">
											(#qinquiries.member_company#)
										</cfif></a>
								<cfelse>
									<a href="mailto:#qinquiries.user_username#">#qinquiries.user_username#
										<cfif qinquiries.member_company NEQ "">
											(#qinquiries.member_company#)
										</cfif></a>
								</cfif>
							<cfelse>
							</cfif> 
						</cfif>
						
						</td>
						<td style="white-space:nowrap;">#local.inquiries_status_name#<cfif qinquiries.inquiries_spam EQ 1>, <strong>Marked as Spam</strong></cfif></td>
					<td style="white-space:nowrap;">#DateFormat(qinquiries.inquiries_datetime, "m/d/yy")# #TimeFormat(qinquiries.inquiries_datetime, "h:mm tt")#</td>
					<cfif variables.isReservationSystem>
						<td>#DateFormat(qinquiries.inquiries_start_date,'m/d/yy')# </td>
						<td>#DateFormat(qinquiries.inquiries_end_date,'m/d/yy')#</td>
					<cfelse>
						<td style="white-space:nowrap;"><cfif (qinquiries.inquiries_type_name) EQ ''>
								#qinquiries.inquiries_type_other#
							<cfelse>
								#(qinquiries.inquiries_type_name)#
							</cfif>
							<cfif trim(qinquiries.inquiries_phone_time) NEQ ''>
								/ <strong>Forced</strong>
							</cfif>
							&nbsp;</td>
					</cfif>
					<td style="white-space:nowrap;">
						<cfif currentMethod EQ "index">
							<a href="/z/inquiries/admin/feedback/view?inquiries_id=#qinquiries.inquiries_id#&amp;zPageId=#form.zPageId#">View</a>
		
							 | <cfif qinquiries.inquiries_readonly EQ 1>
								Edit Disabled
							<cfelse>
								<a href="/z/inquiries/admin/inquiry/edit?inquiries_id=#qinquiries.inquiries_id#&amp;zPageId=#form.zPageId#">Edit</a>
							</cfif> 
							<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "manager")>
								<cfif qinquiries.inquiries_status_id NEQ 4 and qinquiries.inquiries_status_id NEQ 5 and qinquiries.inquiries_status_id NEQ 7>
									| <a href="/z/inquiries/admin/assign/index?inquiries_id=#qinquiries.inquiries_id#&amp;zPageId=#form.zPageId#">
									<cfif qinquiries.user_id NEQ 0 or qinquiries.inquiries_assign_email NEQ "">
										Re-
									</cfif>
									Assign</a>
								</cfif>
							</cfif>

						<cfelse>
							<a href="/z/inquiries/admin/manage-inquiries/userView?inquiries_id=#qinquiries.inquiries_id#&amp;zPageId=#form.zPageId#">View</a>
							<cfif structkeyexists(request, 'manageLeadEnableUserAssign')>
	
								| <a href="/z/inquiries/admin/assign/userIndex?inquiries_id=#qinquiries.inquiries_id#&amp;zPageId=#form.zPageId#"><cfif qinquiries.user_id NEQ 0 or qinquiries.inquiries_assign_email NEQ "">
										Re-
									</cfif>
									Assign Lead</a> 
							</cfif>
			  
						</cfif>
		
					</td>
				</tr>
			</cfloop>
		</table> 
	</cfif>
	#searchNav# 
	

	<cfif application.zcore.user.checkGroupAccess("member") or currentMethod EQ "userIndex">
	
		<script type="text/javascript">
		/* <![CDATA[ */
		function loadExport(){
			var wf=document.getElementById("whichfields1");	
			var whichfields="0";
			if(wf.checked){
				whichfields="1";
			}
			var et=document.getElementById("exporttype1");	
			var et2=document.getElementById("exporttype2");	
			var exporttype="0";
			if(et.checked){
				exporttype="1";
			}else if(et2.checked){
				exporttype="2";
			}
			var format="html";
			et=document.getElementById("exportformat1");	
			if(et.checked){
				format="csv";	
			}
			window.open("<cfif currentMethod EQ "index">/z/inquiries/admin/export/index<cfelse>/z/inquiries/admin/manage-inquiries/userExport</cfif>?uid=#form.uid#&inquiries_status_id=#form.inquiries_status_id#&inquiries_type_id=#application.zcore.functions.zso(form, 'inquiries_type_id')#&searchType=#urlencodedformat(form.searchType)#&inquiries_name=#urlencodedformat(application.zcore.functions.zso(form, 'inquiries_name'))#&inquiries_start_date=#urlencodedformat(dateformat(form.inquiries_start_date,'yyyy-mm-dd'))#&inquiries_end_date=#urlencodedformat(dateformat(form.inquiries_end_date,'yyyy-mm-dd'))#&format="+format+"&exporttype="+exporttype+"&whichfields="+whichfields);
		}
		/* ]]> */
		</script> 
		<div id="exportLeadDiv" class="z-pt-20 z-float">
			<h2>Export Leads</h2>
			<p>Note: Only the leads in the above report will be exported.</p>
			<p>Format: 
			<input type="radio" name="exportformat" id="exportformat1" value="1" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 1>checked="checked"</cfif> style="vertical-align:middle; margin:0px; background:none; border:none;" />
			CSV
			<input type="radio" name="exportformat" value="0" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px;margin-left:10px; border:none;" />
			HTML</p>
			<p>Fields: 
			<input type="radio" name="whichfields" id="whichfields1" value="1" <cfif application.zcore.functions.zso(form, 'whichfields',false,1) EQ 1>checked="checked"</cfif> style="vertical-align:middle; margin:0px; background:none; border:none;" />
			All Fields
			<cfif request.zos.istestserver>
	
			<input type="radio" name="whichfields" value="0" <cfif application.zcore.functions.zso(form, 'whichfields',false,1) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px;margin-left:10px; border:none;" /> Basic Fields 
</cfif></p>
			<p>Filter:
			<input type="radio" name="exporttype" id="exporttype1" value="1" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 1>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px; border:none;" />
			Unique Emails Only
			<input type="radio" name="exporttype" id="exporttype2" value="2" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 2>checked="checked"</cfif> style="vertical-align:middle; background:none;  margin:0px;margin-left:10px; border:none;" />
			Unique Phone Numbers Only
			<input type="radio" name="exporttype" value="0" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px;margin-left:10px; border:none;" />
			Export All Results</p>
			<p><button type="button" name="submit11" onclick="loadExport();">Export</button></p>
			<!--- <cfif form.searchType NEQ "">
			</cfif> --->
		</div>
	</cfif>
	
</cffunction>
</cfoutput>
</cfcomponent>
