<cfcomponent>
<cfoutput>
<!--- 
new import-ical.cfc structure notes:
import:
process:
	
	// future: call the delete cfc method
	
If recurring field is just like this in database: 
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
then I could just parse it on each view

when recurring data changes, the recurring projection table must be cleared so those can be regenerated.

on front-end
	need a function to calculate the recurring projection for a specific date range.
		returns a struct of dates that the event occurs on.

 --->
<cffunction name="index" access="remote" localmode="modern" roles="serveradministrator">
	<!--- 
	not needed on first version:
		delete cfc path & method - remove all records no longer in the calendar 
	 --->
	<cfscript>
	var row=0;
	var qOption=0;
	var db=request.zos.queryObject;  
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Import iCalendar</h2> 
	<p>This feature helps you import the iCalendar format to another custom database. If the Event application is enabled for this site and at least one calendar is created, then you can import into the event application without writing any code using the default import cfc below.  Note: Recurring events can import, but the rules don't all work correctly.  <strong>Warning: It is important to manually verify the recurring event rules for each event after importing and save them individually.</strong></p>
	<form action="/z/admin/ical-import/process" enctype="multipart/form-data" method="post"> 
		<cfif application.zcore.app.siteHasApp("event")>
	
			<h2>Select an existing calendar</h2>
			<p>
			<cfscript>
			db.sql="select * from #db.table("event_calendar", request.zos.zcoreDatasource)# WHERE 
			event_calendar_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# 
			ORDER BY event_calendar_name ASC ";
			qCalendar=db.execute("qCalendar");

			if(qCalendar.recordcount EQ 1){
				form.event_calendar_id=qCalendar.event_calendar_id;
			}
			ts = StructNew();
			ts.name = "event_calendar_id"; 
			ts.size = 1;  
			ts.query = qCalendar;
			ts.queryLabelField = "event_calendar_name"; 
			ts.queryValueField = "event_calendar_id";  
			application.zcore.functions.zInputSelectBox(ts);
			</cfscript></p>
		</cfif>
		<h2>Select a properly formatted CSV file to upload</h2>
		<p><input type="file" name="filepath" value="" /></p>
		<cfif request.zos.isDeveloper>
			<h2>Specify Import CFC filter.</h2>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" roles="serveradministrator">
			<cfargument name="struct" type="struct" required="yes">
				<cfscript>
				writedump(arguments.struct);
				abort;
				</cfscript>
			</cffunction>
			<cffunction name="importComplete" localmode="modern" roles="serveradministrator">
				<cfscript>
				// clean up
				</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p>
			<cfif application.zcore.app.siteHasApp("event")>
				<p>Import CFC CreateObject Path: <input type="text" name="cfcImportPath" style="width:500px; max-width:100%;" value="zcorerootmapping.mvc.z.event.admin.controller.eventImportFilter" /> (i.e. root.importFilter)</p>
			<cfelse>
				<p>Import CFC CreateObject Path: <input type="text" name="cfcImportPath" style="width:500px; max-width:100%;" value="root.importFilter" />
			</cfif>

			<p>Import CFC Method: <input type="text" name="cfcImportMethod" value="importFilter" /> (i.e. importFilter)</p>
			<p>Import Complete CFC Method: <input type="text" name="cfcImportCompeteMethod" value="importComplete" /> (i.e. importComplete)</p>
		</cfif>
		<h2>Then Click Import CSV</h2>
		<p><input type="submit" name="submit1" value="Import CSV" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div>
		</p>

		<h2>Need to delete the existing events?</h2>
		<p>Run these queries:</p>
		<p>DELETE FROM `event` where site_id=#request.zos.globals.id#;</p>
		<p>DELETE FROM `event_recur` where site_id=#request.zos.globals.id#;</p>
		
	</form>
</cffunction>

<cffunction name="process" localmode="modern" access="remote" roles="serveradministrator">
	<cfsetting requesttimeout="3000">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	fileName=application.zcore.functions.zUploadFile("filepath", request.zos.globals.privateHomedir&"zupload/user/");
	newPath=request.zos.globals.privateHomedir&"zupload/user/"&fileName;
	if(isBoolean(fileName) or not fileExists(newPath)){
		application.zcore.status.setStatus(request.zsid, "Failed to upload iCal file.", form, true);
		application.zcore.functions.zRedirect("/z/admin/ical-import/index?zsid=#request.zsid#");
	}
	data=application.zcore.functions.zreadfile(newPath);
	application.zcore.functions.zdeletefile(newPath);
	/*
	form.cfcImportPath="root.importFilter";
	form.cfcImportMethod="importFilter";
	form.cfcImportCompeteMethod="importComplete";
	newPath=request.zos.globals.homedir&"localendar_CVBmelissa.ics";
	data=application.zcore.functions.zreadfile(newPath);
	*/
	if(form.cfcImportPath EQ "" or form.cfcImportMethod EQ ""){
		application.zcore.status.setStatus(request.zsid, "Import CFC Path and Method are required.", form, true);
		application.zcore.functions.zRedirect("/z/admin/ical-import/index");
	}
	if(left(form.cfcImportPath, 5) EQ "root."){
		form.cfcImportPath=request.zrootcfcpath&removechars(form.cfcImportPath, 1, 5);
	}
	cfcImportObject=application.zcore.functions.zcreateobject("component", form.cfcImportPath, true);
	
	ical = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.ical.ical").init(data);
	ical.importEvents(cfcImportObject, form.cfcImportMethod); 
	
	if(form.cfcImportCompeteMethod NEQ ""){
		cfcImportObject[form.cfcImportCompeteMethod]();
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>