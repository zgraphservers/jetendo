<cfcomponent>
<cfoutput>
<cffunction name="select" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.index();
	</cfscript>
</cffunction>

    

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject;
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
    application.zcore.functions.zSetPageHelpId("4.1.2");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");
	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id');
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT * FROM (#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status
    , #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
    ) 
    LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type
    ON inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
    inquiries_type_deleted = #db.param(0)#
    WHERE inquiries.site_id = #db.param(request.zos.globals.id)#  and 		
    inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
    inquiries_deleted = #db.param(0)# and 
    inquiries_status_deleted = #db.param(0)# and 
    inquiries.inquiries_status_id NOT IN (#db.trustedSQL("4,5,0,7")#) and 
     inquiries_id = #db.param(form.inquiries_id)#  
    </cfsavecontent><cfscript>
	qinquiry=db.execute("qinquiry");
        if(qinquiry.recordcount EQ 0){		
            request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
            application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
        }else{
            application.zcore.functions.zQueryToStruct(qinquiry);
        }
        application.zcore.functions.zstatushandler(request.zsid,true);
    </cfscript>
    <span class="form-view">
    <h2>Selected Lead</h2>
	<!--- <p>Leads are matched by email and phone number to help you assign to the same agent if desired.</p> --->
    <table style="width:100%; border-spacing:0px;" class="table-list">
    <tr>
    <th style="width:150px;">Name</th>
    <th style="width:150px;">Email</th>
    <th>&nbsp;</th>
    <th>Date Received</th>
    <th>Previously Assigned To:</th>
    <th>Previous Lead Date:</th>
    </tr>
    <tr >
    <td style="width:150px;">#form.inquiries_first_name# #form.inquiries_last_name#</td>
    <td style="width:150px;"><cfif len(form.inquiries_email) NEQ 0>#form.inquiries_email#</cfif></td>
    <td></td>
    <td style="width:150px;">#DateFormat(form.inquiries_datetime,'m/d/yy')&' '&TimeFormat(form.inquiries_datetime,'h:mm tt')#</td> 
    <cfscript>
    if(qinquiry.user_id NEQ 0){
        db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user
        WHERE user_id = #db.param(qinquiry.user_id)# and 
        user_deleted=#db.param(0)# and 
        site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdFromSiteIdType(qinquiry.user_id_siteIDType))#";
        local.qUserTemp=db.execute("qUserTemp");
        if(local.qUserTemp.recordcount NEQ 0){
            writeoutput('<td>'); 
            writeoutput(local.qUserTemp.user_first_name&" "&local.qUserTemp.user_last_name&" "&local.qUserTemp.user_username);
           writeoutput('</td><td>'&dateformat(qinquiry.inquiries_datetime, "m/d/yy ")&timeformat(qinquiry.inquiries_datetime, 'h:mm tt')&'</td>');
        }
    }else if(qinquiry.inquiries_assign_email NEQ ""){
        writeoutput('<td>'); 
        writeoutput('#qinquiry.inquiries_assign_name# #qinquiry.inquiries_assign_email# ');
        writeoutput('</td><td>'&dateformat(qinquiry.inquiries_datetime, "m/d/yy ")&timeformat(qinquiry.inquiries_datetime, 'h:mm tt')&'</td>');
    }else{
        db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
        WHERE inquiries_id <> #db.param(form.inquiries_id)# and 
        inquiries_email = #db.param(form.inquiries_email)# and
        site_id = #db.param(request.zos.globals.id)# and 
        inquiries_deleted = #db.param(0)# and 
        (user_id <> #db.param(0)# or 
        inquiries_assign_email <> #db.param('')#) 
        ORDER BY inquiries_datetime DESC   ";
        local.qPrevious=db.execute("qPrevious");
        if(local.qPrevious.recordcount NEQ 0){
        	writeoutput('<td>'); 
        	if(local.qPrevious.user_id NEQ 0){
        		db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user
        		WHERE user_id = #db.param(local.qPrevious.user_id)# and 
                user_deleted=#db.param(0)# and 
        		site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdFromSiteIdType(local.qPrevious.user_id_siteIDType))#";
        		local.qUserTemp=db.execute("qUserTemp");
        		if(local.qUserTemp.recordcount NEQ 0){
        			writeoutput(local.qUserTemp.user_first_name&" "&local.qUserTemp.user_last_name&" "&local.qUserTemp.user_username);
        		}
        	}else{
        		writeoutput('#local.qPrevious.inquiries_assign_name# #local.qPrevious.inquiries_assign_email# ');
        	} 
        	writeoutput('</td><td>'&dateformat(local.qPrevious.inquiries_datetime, "m/d/yy ")&timeformat(local.qPrevious.inquiries_datetime, 'h:mm tt')&'</td>');
        }else{
    	   writeoutput('<td>N/A</td><td>&nbsp;</td>');    
        }
    }
    </cfscript>
    </tr>
    </table><br />
  
    <h2><cfif form.user_id NEQ 0 or form.inquiries_assign_email NEQ "">Re-</cfif>Assign Lead</h2>
    <!--- 
    Note: The agents in the drop down menu are sorted in the sequence they are due to receive a lead. Agent will be notified of assignment by email.<br /><br /> --->
    
    <table style="width:100%; border-spacing:0px;">
    <form class="zFormCheckDirty" action="/z/inquiries/admin/assign/<cfif form.method EQ "index">assign<cfelse>userAssign</cfif>?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post">
    <tr><th style="text-align:left;">Assign to a registered user of this web site:</th></tr>
    <tr>
    <td>
    <cfscript>
    if(form.method EQ "userIndex"){ 
        // only allow assigning to people who belong to the same offices that this user does. 
        if(request.zsession.user.office_id NEQ ""){
            qAgents=application.zcore.user.getUsersByOfficeIdList(request.zsession.user.office_id);
        }else{
            db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
            WHERE site_id=#db.param(request.zos.globals.id)# and 
            user_deleted = #db.param(0)# and
            user_id =#db.param(-1)#";
            qAgents=db.execute("qAgents"); 
        } 
    }else{
        // TODO: find only the users this user should have access to 
        db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
        WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
        user_deleted = #db.param(0)# and
        user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 
         and (user_server_administrator=#db.param(0)#)
        ORDER BY member_first_name ASC, member_last_name ASC";
        qAgents=db.execute("qAgents");
    }
    
    </cfscript> 
    <script type="text/javascript">
    /* <![CDATA[ */
	function showAgentPhoto(id){
        var d1=document.getElementById("agentPhotoDiv");
        if(id!="" && arrAgentPhoto[id]!=""){
            d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
        }else{
            d1.innerHTML="";	
        }
    }
    var arrAgentPhoto=new Array();
    <cfif qAgents.recordcount>
        <cfloop query="qAgents">
        arrAgentPhoto["#qAgents.user_id#|#qAgents.site_id#"]=<cfif qAgents.member_photo NEQ "">"#jsstringformat('#application.zcore.functions.zvar('domain',qAgents.userSiteId)##request.zos.memberImagePath##qAgents.member_photo#')#"<cfelse>""</cfif>;
        </cfloop>
    </cfif>
	/* ]]> */
    </script>  
    <div style="width:100%; float:left;">
        <div style="float:left; width:100%;">Type to filter users:</div>
        <div style="float:left; width:100%;"> 
            <input type="text" name="assignInputField" id="assignInputField" value="" style="width:240px; min-width:auto; max-width:auto; margin-bottom:5px;">
        </div>
    </div>
    <div style="width:100%; margin-bottom:20px;float:left;">
        <div style="float:left; width:100%;">Select a user:</div>
        <div style="float:left; width:100%;"> <cfscript> 
        form.user_id = form.user_id&"|"&application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIDType);
        selectStruct = StructNew();
        selectStruct.name = "user_id";
        selectStruct.query = qAgents;
        selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##) ##member_company##";
        selectStruct.onchange="showAgentPhoto(this.options[this.selectedIndex].value);";
        selectStruct.queryParseLabelVars = true;
        selectStruct.queryParseValueVars = true;
        selectStruct.size=5;
        selectStruct.queryValueField = '##user_id##|##site_id##';
        application.zcore.functions.zInputSelectBox(selectStruct);
        application.zcore.skin.addDeferredScript("  $('##user_id').filterByText($('##assignInputField'), true); ");
        </cfscript>
        </div>
    </div>
    </tr>
    <tr><th style="text-align:left;">Or you can assign the lead to anyone outside the web site:</td></tr>
    <tr><td>
    <div style="width:100%; margin-bottom:20px;float:left;"> 
        <p>External Name:<br><input type="text" name="assign_name" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'assign_name')#" /></p>
        <p>External Email(s):<br>
        <input type="text" name="assign_email" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'assign_email')#" /><br>
        (Comma separate multiple emails)</p>
    </div>
    <div id="agentPhotoDiv"></div>
    </td>
    </tr>
    <tr>
    <th style="text-align:left;">Administrative Comments</th></tr>
    <tr>
    <td>
        Optionally enter any notes.  These notes won't be visible to the public customer.<br>
        <textarea name="inquiries_admin_comments" style="width:100%; height:150px; ">#form.inquiries_admin_comments#</textarea></td></tr>
    <tr>
        <td><button type="submit" name="submitForm"><cfif form.user_id NEQ 0>Re-</cfif>Assign Lead</button> <button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/manage-inquiries/<cfif form.method EQ "index">index<cfelse>userIndex</cfif>?zPageId=#form.zPageId#';">Cancel</button></td>
    </tr>
    </form>
    </table>
    </span>
    
</cffunction>


<cffunction name="userIndex" localmode="modern" access="remote">
    <cfscript> 
    inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
    inquiriesCom.userInit();
    index();
    </cfscript>
</cffunction>

<cffunction name="userAssign" localmode="modern" access="remote">
    <cfscript> 
    inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
    inquiriesCom.userInit();
    assign();
    </cfscript>
</cffunction>

<cffunction name="assign" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject;
    if(form.method EQ "assign"){ 
        application.zcore.adminSecurityFilter.requireFeatureAccess("Leads", true);
    }
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	if(application.zcore.functions.zso(form, 'user_id') EQ '' and application.zcore.functions.zso(form, 'assign_email') EQ ''){
        application.zcore.status.setStatus(request.zsid,"You forgot to type an email address or select a user from the drop down menu.",form,true);
        if(form.method EQ "userAssign"){
            application.zcore.functions.zRedirect("/z/inquiries/admin/assign/userIndex?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid=#request.zsid#");  
        }else{
            application.zcore.functions.zRedirect("/z/inquiries/admin/assign/index?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
        }
    }
    if(application.zcore.functions.zso(form, 'user_id') CONTAINS "|"){
        local.assignUserId=listGetAt(form.user_id, 1, "|");
        local.assignSiteId=listGetAt(form.user_id, 2, "|");
    }else{
        local.assignUserId=0;
        local.assignSiteId=0;
    } 
    local.assignSiteIdType=application.zcore.functions.zGetSiteIdType(local.assignSiteId);
    if(application.zcore.functions.zso(form, 'assign_email') NEQ ''){
        arrEmail=listToArray(form.assign_email, ",");
        arrEmailFinal=[];
        for(i=1;i LTE arraylen(arrEmail);i++){
            e=trim(arrEmail[i]);
            if(e NEQ ""){
                if(application.zcore.functions.zEmailValidate(e) EQ false){
                    application.zcore.status.setStatus(request.zsid,"Invalid email address format: #arrEmail[i]#",form,true);
                    if(form.method EQ "userAssign"){
                        application.zcore.functions.zRedirect("/z/inquiries/admin/assign/userIndex?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid=#request.zsid#");  
                    }else{
                        application.zcore.functions.zRedirect("/z/inquiries/admin/assign/index?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid=#request.zsid#");  
                    }
                }
                arrayAppend(arrEmailFinal, e);
            }
        }
        form.assign_email=arraytolist(arrEmailFinal, ", ");
    }
	</cfscript>
    <cfif application.zcore.functions.zso(form, 'assign_email') NEQ ''>
        <cfscript>
        request.noleadsystemlinks=true;
        db.sql="SELECT inquiries_email from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
        WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
        site_id = #db.param(request.zos.globals.id)# and 
        inquiries_deleted=#db.param(0)#";
        qGetInquiry=db.execute("qGetInquiry");
        db.sql="SELECT count(inquiries_feedback_id) count 
        from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
        WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
        inquiries_feedback_deleted = #db.param(0)# and
        site_id = #db.param(request.zos.globals.id)#";
        qFeedback=db.execute("qFeedback");
        </cfscript>
        <cfsavecontent variable="db.sql">
        UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
         SET inquiries_assign_email = #db.param(form.assign_email)#,  
         <cfif isDefined('form.assign_name') and form.assign_name neq ''>inquiries_assign_name=#db.param(form.assign_name)#,</cfif>  
         user_id = #db.param("")#, 
         inquiries_admin_comments = #db.param(form.inquiries_admin_comments)#, 
         <cfif qFeedback.count NEQ 0>inquiries_status_id = #db.param(3)#<cfelse>inquiries_status_id = #db.param(2)#</cfif> 
         WHERE inquiries_id = #db.param(form.inquiries_id)# and 
         site_id = #db.param(request.zos.globals.id)# and 
         inquiries_deleted=#db.param(0)#
        </cfsavecontent><cfscript>qInquiry=db.execute("qInquiry");</cfscript>
        <cfset form.groupEmail=false>
        <cfscript>
        toEmail=form.assign_email; 
        </cfscript>

        <cfmail  to="#toEmail#" from="#request.fromemail#" replyto="#qGetInquiry.inquiries_email#" subject="A new lead assigned to you" type="html">
            <cfscript>
            iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
            iemailCom.getEmailTemplate();
            </cfscript>
        </cfmail>
        <cfscript>
        request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead assigned to #form.assign_email#, An email has been sent to notify them.");
        if(form.method EQ "userAssign"){
            application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid="&request.zsid);
        }else{
            application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
        }
        </cfscript>
    <cfelse>
        <cfsavecontent variable="db.sql">
        SELECT inquiries_email from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
        WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
        site_id = #db.param(request.zos.globals.id)# and 
        inquiries_deleted=#db.param(0)# 
        </cfsavecontent><cfscript>qGetInquiry=db.execute("qGetInquiry");</cfscript> 
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user
        WHERE site_id =#db.param(local.assignSiteId)# and 
        user_id = #db.param(local.assignUserId)#  and 
        user_deleted=#db.param(0)# 
        </cfsavecontent><cfscript>qMember=db.execute("qMember");</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT count(inquiries_feedback_id) count 
        from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
        WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
        site_id = #db.param(request.zos.globals.id)#  and 
        inquiries_feedback_deleted=#db.param(0)# 
        </cfsavecontent><cfscript>qFeedback=db.execute("qFeedback");
        if(qMember.recordcount EQ 0){
            request.zsid = application.zcore.status.setStatus(Request.zsid, "User doesn't exist.",form,true);
            if(form.method EQ "userAssign"){
                application.zcore.functions.zRedirect("/z/inquiries/admin/assign/userIndex?inquiries_id=#inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
            }else{
                application.zcore.functions.zRedirect("/z/inquiries/admin/assign/index?inquiries_id=#inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
            }
        }
        form.inquiries_admin_comments = trim(application.zcore.functions.zso(form, 'inquiries_admin_comments'));
        </cfscript>
        <cfsavecontent variable="db.sql">
        UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
         SET inquiries_assign_email = #db.param("")#, 
         user_id = #db.param(qMember.user_id)#, 
         user_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(local.assignSiteId))#, 
         inquiries_admin_comments = #db.param(form.inquiries_admin_comments)#, 
         <cfif qFeedback.count NEQ 0>inquiries_status_id = #db.param(3)#<cfelse>inquiries_status_id = #db.param(2)#</cfif> 
         WHERE inquiries_id = #db.param(form.inquiries_id)#  and
         site_id = #db.param(request.zos.globals.id)# and 
        inquiries_deleted=#db.param(0)#  and 
         inquiries_deleted=#db.param(0)#
        </cfsavecontent><cfscript>qInquiry=db.execute("qInquiry");</cfscript> 
        <cfset form.groupEmail=false>
        <cfscript>
        toEmail=qMember.user_username; 
        </cfscript>

        <cfmail  to="#toEmail#" cc="#qMember.user_alternate_email#" from="#request.fromemail#" replyto="#qGetInquiry.inquiries_email#" subject="A new lead assigned to you" type="html">
            <cfscript>
			iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
            iemailCom.getEmailTemplate();
            </cfscript>
        </cfmail>
        <cfscript>
        request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead assigned to #qMember.member_first_name# #qMember.member_last_name#, An email has been sent to this user to notify them."); 
        if(form.method EQ "userAssign"){
            application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid="&request.zsid);
        }else{
            application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
        }
        </cfscript>
    </cfif>
</cffunction>
</cfoutput>
</cfcomponent>