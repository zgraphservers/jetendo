<cfcomponent extends="zcorerootmapping.com.cloud.cloudBase"> 
	
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