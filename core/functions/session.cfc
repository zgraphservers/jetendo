<cfcomponent extends="zcorerootmapping.functions.string">
<cfoutput>
<!--- FUNCTION: zAppSetField(appName, varName, value); --->
<cffunction name="zAppSetField" localmode="modern" returntype="any" output="false">
	<cfargument name="appName" type="string" required="yes">
	<cfargument name="varName" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<!--- save configuration for appName --->
	<cfscript> 
	if(isDefined('request.zsession.appVar') EQ false){
		request.zsession.appVar = StructNew();
	} 
	if(isDefined('request.zsession.appVar.'&arguments.appName) EQ false){
		StructInsert(request.zsession.appVar, arguments.appName, StructNew(), true);
		request.zsession.appVar[arguments.appName].config = StructNew();
	}
	StructInsert(request.zsession.appVar[arguments.appName].config, arguments.varName, arguments.value,true);
	return true;
	</cfscript>
</cffunction>


<!--- FUNCTION: zAppGetField(appName, varName, defaultValue); --->
<cffunction name="zAppGetField" localmode="modern" returntype="any" output="false">
	<cfargument name="appName" type="string" required="yes">
	<cfargument name="varName" type="string" required="yes">
	<cfargument name="value" type="string" required="no" default="">
	<!--- save configuration for appName --->
	<cfscript>
	if(isDefined('request.zsession.appVar.'&arguments.appName&'.config.'&arguments.varName)){
		return request.zsession.appVar[arguments.appName].config[arguments.varName];
	}else{
		return arguments.value;
	}
	</cfscript>
	
</cffunction>

<!--- FUNCTION: zAppReset(appName); --->
<cffunction name="zAppReset" localmode="modern" returntype="any" output="false">
	<cfargument name="appName" type="string" required="yes">
	<!--- clear configuration for appName  --->
	<cfscript>	
	if(isDefined('request.zsession.appVar') EQ false){
		request.zsession.appVar = StructNew();
	}
	StructInsert(request.zsession.appVar, arguments.appName, StructNew(), true);
	request.zsession.appVar[arguments.appName].config = StructNew();
	return true;
	</cfscript>
</cffunction>


</cfoutput>
</cfcomponent>