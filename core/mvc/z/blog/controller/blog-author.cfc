<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote"> <cfscript>
	application.zcore.functions.z404("displayBlogSection disabled");
	variables.init();
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);

	struct=application.zcore.functions.zGetSiteOptionGroupSetById(form.site_x_option_group_set_id);
	if(structcount(struct) EQ 0){
		application.zcore.functions.z404("form.site_x_option_group_set_id, ""#form.site_x_option_group_set_id#"" doesn't exist, so displayBlogSection can't load.");
	}


	if(application.zcore.functions.zso(form, 'listId') EQ ''){ 
		form.listId = application.zcore.status.getNewId(); 
	} 
	if(structkeyexists(form, 'zIndex') and isNumeric(form.zIndex)){ 
		application.zcore.status.setField(form.listId,'zIndex',form.zIndex); 
	}else{
		curLink=getSectionHomeLink(form.site_x_option_group_set_id);
		actualLink="/#application.zcore.functions.zso(form, 'zUrlName')#-#application.zcore.app.getAppData("blog").optionStruct.blog_config_url_section_id#-#form.site_x_option_group_set_id#.html";
		if(compare(curLink,actualLink) neq 0){
			application.zcore.functions.z301Redirect(curLink);
		}
	}
	index();
	tempPageNav='<a class="#application.zcore.functions.zGetLinkClasses()#" href="#application.zcore.app.getAppData("blog").optionStruct.blog_config_home_url#">#application.zcore.functions.zvar("homelinktext")#</a> / <a href="#struct.__url#">#struct.__title#</a> /';
	application.zcore.template.setTag("pagenav",tempPageNav);
	affix=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_section_title_affix');
	if(affix NEQ ""){
		title=struct.__title&" "&affix;
	}else{
		title=struct.__title&" Blog Articles";
	}
	application.zcore.template.setTag("pagetitle", title);
	application.zcore.template.setTag("title", title);
	</cfscript>

	
</cffunction>
 
</cfoutput>
</cfcomponent>