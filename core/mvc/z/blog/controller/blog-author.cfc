<cfcomponent>
<cfoutput>
<cffunction name="authorBlogHome" localmode="modern" access="remote"> <cfscript> 
	blogCom=application.zcore.app.getAppCFC("blog");
	blogCom.init();
	form.uid=application.zcore.functions.zso(form, 'uid', true, 0);
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0); 
	userStruct=application.zcore.user.getUserById(form.uid, application.zcore.functions.zGetSiteIdFromSiteIdType(form.sid));
	if(structcount(userStruct) EQ 0){
		application.zcore.functions.z404("User doesn't exist.");
	} 
	if(application.zcore.functions.zso(form, 'listId') EQ ''){ 
		form.listId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex') and isNumeric(form.zIndex)){ 
		application.zcore.status.setField(form.listId,'zIndex',form.zIndex); 
	}else{
		curLink=blogCom.getAuthorLink(userStruct);
		actualLink="/#application.zcore.functions.zso(form, 'zUrlName')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_author_id#-#form.uid#_#form.sid#.html";
		if(compare(curLink,actualLink) neq 0){
			application.zcore.functions.z301Redirect(curLink);
		}
	} 
	echo('<p>Email The Author: ');
	echo(application.zcore.functions.zEncodeEmail(userStruct.user_email, true, userStruct.user_email));
	echo('</p>');
	blogCom.index();
	tempPageNav='<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> /';
	application.zcore.template.setTag("pagenav",tempPageNav); 
	if(trim(userStruct.user_first_name&" "&userStruct.user_last_name) EQ ""){
		if(trim(userStruct.member_company) EQ ""){
			title="Blog Articles by "&userStruct.user_email;
		}else{
			title="Blog Articles by "&userStruct.member_company; 
		}
	}else{
		title="Blog Articles by "&userStruct.user_first_name&" "&userStruct.user_last_name; 
	}
	application.zcore.template.setTag("pagetitle", title);
	application.zcore.template.setTag("title", title);
	</cfscript>

	
</cffunction>
 
</cfoutput>
</cfcomponent>