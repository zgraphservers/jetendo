<cfcomponent extends="zcorerootmapping.com.cloud.cloudBase">
<cffunction name="init" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes"> 
</cffunction>
	
<cffunction name="makeFileAvailableOffline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
</cffunction>

<cffunction name="purgeFile" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
</cffunction>

<cffunction name="storeOnline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
</cffunction>
</cfcomponent>