<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private">  
	<cfscript> 
	setting requestTimeout="100000";
	variables.userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36";

	request.cancelSemRushStruct={};
	</cfscript>
	
</cffunction>
<cffunction name="status" localmode="modern" access="remote" roles="administrator">  
	<cfscript>  
	application.zcore.template.setTag("title", "Import Facebook Stats Status");
	application.zcore.template.setTag("pagetitle", "Import Facebook Stats Status"); 
	</cfscript>
	<p>Status: #application.zcore.functions.zso(application, 'facebookImportStatus')#</p>
	<p><a href="/z/inquiries/admin/facebook-test/cancelFacebookImport" target="_blank">Cancel Facebook Import</a>
</cffunction>
<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript>  
	db=request.zos.queryObject;
 	application.zcore.template.setTag("title", "Import Facebook Stats");
	 
	</cfscript>
	<h2>Import Facebook Stats</h2>
	<p>These may take minutes to hours to finish.</p>
	<p><a href="/z/inquiries/admin/import-facebook-stats/status" target="_blank">Show status</a>
	<p><a href="/z/inquiries/admin/facebook-test/cancelFacebookImport" target="_blank">Cancel Facebook Import</a>

	<p><a href="/z/inquiries/admin/facebook-test/index?pullEverything=1" target="_blank">1) Import Everything</a> or 
	<a href="/z/inquiries/admin/facebook-test/index" target="_blank">1) Import Last 3 Months</a></p>

	<p><a href="/z/inquiries/admin/facebook-test/getPostDetails" target="_blank">2) Import Details For All Posts</a></p> 
	<p><a href="/z/inquiries/admin/facebook-test/calculatePageTotals" target="_blank">3) Do All Monthly Calculations</a></p> 
	
	<h2>Want everything at once?</h2>
	<p><a href="/z/inquiries/admin/import-facebook-stats/downloadFacebook?pullEverything=1" target="_blank">Import Everything and All Steps</a> or 
	<a href="/z/inquiries/admin/import-facebook-stats/downloadFacebook" target="_blank">1) Import Last 3 Months and Step 2/3</a></p>
 
</cffunction>

	

<cffunction name="downloadFacebook" access="remote" localmode="modern">

	<cfscript>
	setting requesttimeout="100000";
	init();
	db=request.zos.queryobject;
	facebookTestCom=createobject("component", "facebook-test");
	facebookTestCom.index();
	facebookTestCom.getPostDetails();
	facebookTestCom.calculatePageTotals();
	</cfscript> 
</cffunction>
 
</cfoutput>
</cfcomponent>