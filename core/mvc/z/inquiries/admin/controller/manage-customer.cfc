<cfcomponent>
<cfoutput> 
<!--- 
in addition to working for manager users, it must work for external users (i.e. userIndex)



index (including search)
	same stuff as inquiry, but not assignee
edit / update
	allow changing the basic fields
	no custom fields yet
view
	shows basic fields
	shows inquiries attached

userView & userIndex - Allow non-manager users to view only the customers they have leads for.   This requires a slower join on inquiries table.

when a new lead comes in, we should apply the newest mapped data to the customer record, i.e. product of interest, phone number, address, augmenting it.

later:
export
 --->

<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript>
	application.zcore.functions.z404("handle security");

	index();
	</cfscript>
</cffunction>
	

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject; 
	application.zcore.functions.z404("handle security");
	
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
