<cfcomponent implements="zcorerootmapping.interface.view">
<cfoutput>
<cffunction name="init" access="public" returntype="string" localmode="modern">
	<cfscript> 
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	</cfscript>
</cffunction>
<cffunction name="render" access="public" returntype="string" localmode="modern">
	<cfargument name="tagStruct" type="struct" required="yes">
	<cfscript>
	var tagStruct=arguments.tagStruct;
	</cfscript>
	<cfsavecontent variable="output">
	<cfscript>
	request.znotemplate=1;
	if(application.zcore.functions.zIsTestServer() EQ false){
		application.zcore.functions.zheader("X-UA-Compatible", "IE=edge,chrome=1");
	}
	</cfscript>#application.zcore.functions.zHTMLDoctype()#
	<head>
	    <meta charset="utf-8" />
	<title>#tagStruct.title ?: ""#</title>
	#tagStruct.stylesheets ?: ""# 
	#tagStruct.meta ?: ""#
	</head>
	<body class="zblanktemplatebody">
	<div class="zblanktemplatedivcontainer" style="padding:10px;width:100%; float:left;">
	  <cfif application.zcore.template.getTagContent("pagetitle") NEQ "">
	  <h1>#tagStruct.pagetitle ?: ""#</h1>
	  </cfif>
	    #tagStruct.content ?: ""#
	 
	  </div>
	#tagStruct.scripts ?: ""#
	</body>
	</html>
	</cfsavecontent>
	<cfreturn output>
</cffunction>
</cfoutput>
</cfcomponent>