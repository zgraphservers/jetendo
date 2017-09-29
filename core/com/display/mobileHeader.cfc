<!--- Below is an example of a CFC that is used for making a custom page, search result, and search index for a site_x_option_group_set record. --->
<cfcomponent>
<cfoutput>
<!--- 
ts={
	fixedPosition:true, // true will keep header at top when scrolling down.
	alwaysShow:false, // true will enable 3 line menu button on desktop
	logoImage:"/images/logo.png",
	logoAltText:"",
	arrLink:[{
		label:"Link",
		link:"##",
		arrLink:[{
			label:"Sub-link",
			link:"##"
		}]
	}]
};
mobileHeaderCom=createobject("component", "zcorerootmapping.com.display.mobileHeader");
mobileHeaderCom.init(); // call this in template init function before including other stylesheets
mobileHeaderCom.displayMobileMenu(ts); // run where you want it to output
 --->
<cffunction name="init" access="public" localmode="modern"> 
	<cfscript>
	if(not structkeyexists(request.zos, 'zMobileMenuDisplayed')){
		request.zos.zMobileMenuDisplayed=true; 
		application.zcore.skin.includeCSS("/z/javascript/zMobileHeader.css");
		application.zcore.skin.includeJS("/z/javascript/zMobileHeader.js");
	}
	</cfscript>
</cffunction>

<cffunction name="displayMobileMenu" access="public" localmode="modern"> 
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	ss=arguments.ss;
	ss.fixedPosition=ss.fixedPosition?:false;
	if(not structkeyexists(ss, 'logoImage')){
		throw("ss.logoImage is required");
	}
	if(not structkeyexists(ss, 'logoAltText')){
		throw("ss.logoAltText is required");
	}
	if(not structkeyexists(ss, 'arrLink') or arraylen(ss.arrLink) EQ 0){
		throw("ss.arrLink is required with one or more links with this structure: { label:'Label', link:'##' } ");
	}
	</cfscript>   
	
	<div class="z-mobile-header <cfif ss.fixedPosition>z-mobile-allow-fixed</cfif> <cfif not ss.alwaysShow>z-show-at-992</cfif> z-float">
		<div class="z-mobile-header-spacer">
			<a href="/"><img src="#ss.logoImage#" alt="#htmleditformat(ss.logoAltText)#" class="z-mobile-header-logo"></a>
			<div class="z-mobile-menu-icon">
				<span></span>
				<span></span>
				<span></span>
			</div>
		</div>

		<nav class="z-mobile-menu">
			<ul>
				<cfscript>
				for(i=1;i<=arraylen(ss.arrLink);i++){
					link=ss.arrLink[i];
					echo('<li><a href="#link.link#">#link.label#</a>');
					if(structkeyexists(link, 'arrLink') and arrayLen(link.arrLink)){
						echo('<ul>');
						for(n=1;n<=arraylen(link.arrLink);n++){
							sublink=link.arrLink[n];
							echo('<li><a href="#sublink.link#">#sublink.label#</a></li>');
						}
					}
					echo('</li>');
				}
				</cfscript>
			</ul>
		</nav>
		<div class="z-mobile-header-overlay"></div>
	</div>

</cffunction> 

 
</cfoutput>
</cfcomponent>