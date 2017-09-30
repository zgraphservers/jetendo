<cfcomponent extends="zcorerootmapping.functions.session">
<cfoutput><!--- FUNCTION: zGetSES(number, required, status, redirect); 
// returns a variable by number.  Provides optional error handling.
--->
<cffunction name="zGetSES" localmode="modern" returntype="string" output="false">
	<cfargument name="number" type="numeric" required="yes">
	<cfargument name="defaultValue" type="any" required="no" default="#false#">
	<cfargument name="required" type="boolean" required="no" default="#false#">
	<cfargument name="status" type="any" required="no" default="#false#">
	<cfargument name="redirect" type="any" required="no" default="#false#">
	<cfscript>
	var zsid = "";
	if(listLen(form.ses,"/") EQ 0){
		if(arguments.defaultValue NEQ false){
		}else{
			//return "";
		}
			return arguments.defaultValue;
	}else if(structkeyexists(form, 'ses') and arguments.number LTE listLen(form.ses, "/")){
		return listGetAt(form.ses,arguments.number,"/");
	}else{
		if(arguments.required){
			if(arguments.redirect NEQ false){
				if(arguments.status NEQ false){
					request.zsid = zSetStatus(request.zsid, arguments.status);
					application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(arguments.redirect, "zsid=#request.zsid#"));						
				}else{
					application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(arguments.redirect, "zsid=#request.zsid#"));	
				}
			}else{
				zTemplateEnd("<h1>Whoops!</h1><br /><br />This page no longer exists.<br /><br /><a href=""/"">Click Here</a> to go to the home page.",false,true);
			}
		}else{
			return arguments.defaultValue;
			/*if(arguments.defaultValue EQ false){
				return "";
			}else{
			}*/
		}
	}
	</cfscript>
</cffunction>
<!--- zGetSESQueryString(); 
// rebuild the path info seen in the browser
 --->
<cffunction name="zGetSESQueryString" localmode="modern" returntype="any" output="false">
	<cfscript>
	var i = 0;
	var tempString = "";
	for(i=0;i LTE 20;i=i+1){
		if(structkeyexists(form, 'ses_'&i)){
			tempString = tempString&form['ses_'&i]&"/";
		}
	}
	return tempString;
	</cfscript>
</cffunction>

<!--- 
FUNCTION: zURLEncode(value, escapeWith); 
Encodes SES URLs
replaces special characters with underscores by default (MySQL wildcard)
 --->
<cffunction name="zURLEncode" localmode="modern" returntype="string" output="false">
	<cfargument name="value" type="any" required="yes">
	<cfargument name="escapeWith" type="string" required="no" default="_">
	<cfscript>
	return REReplace(arguments.value, "[^[:alnum:]]",arguments.escapeWith,"ALL");
	</cfscript>
</cffunction>

<!--- FUNCTION: zGetSesUp(); // goes up one directory and stops at the zOS root --->
<cffunction name="zGetSesUp" localmode="modern" returntype="any" output="false">
	<cfscript>
	var tempString = removeChars(reverse(Request.zOS.currentURL),1,1);
	var tempPos = find("/",tempString);
	tempString = reverse(removeChars(tempString,1,tempPos)); 
	if(left(tempString, len(Request.zOS.scriptName)) EQ Request.zOS.scriptName){
		return tempString&"/";
	}else{
		return Request.zOS.scriptName;
	}
	</cfscript>
</cffunction>

<cffunction name="zSesUpdate" localmode="modern" returntype="any" output="false">
	<cfargument name="sesURL" type="string" required="yes">
	<cfargument name="position" type="numeric" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	var tempURL = ListDeleteAt(arguments.sesURL, arguments.position+1, "/");
	return ListInsertAt(tempURL, arguments.position+1, arguments.value, "/");
	</cfscript>
</cffunction></cfoutput>
</cfcomponent>