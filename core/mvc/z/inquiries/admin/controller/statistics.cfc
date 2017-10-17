<cfcomponent>
<cfoutput> 
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
	form.searchOn=application.zcore.functions.zso(form, 'searchOn', true, 0);
	params=[];//&#variables.pageZSID#=#form[variables.pageZSID]#");
	if(form.searchOn EQ 1){
		arrayAppend(params, "searchOn=#form.searchOn#");
	} 
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Reports");
	var db=request.zos.queryObject; 
	rs={};
	loadListLookupData();
	variables.searchFields=[]; 
	if(structkeyexists(rs, 'searchFields')){
		variables.searchFields=rs.searchFields;
	}
 	for(group in variables.searchFields){
 		if(structkeyexists(group, 'fields')){
		 	for(field in group.fields){
		 		form[field.field]=application.zcore.functions.zso(form, field.field); 

				if(form.searchOn EQ 1){
 					arrayAppend(params, "#field.field#=#urlencodedformat(form[field.field])#");
 				}
		 	}
		}
	}
 	currentLink=application.zcore.functions.zURLAppend(request.zos.originalURL, arrayToList(params, "&"));
	form.search_office_id=application.zcore.functions.zso(form, 'search_office_id', true, "0");
	if(application.zcore.functions.zso(request.zsession, "selectedofficeid", true, 0) NEQ 0){
		form.search_office_id=request.zsession.selectedofficeid;
	}
	form.searchType=application.zcore.functions.zso(form, 'searchType');
	form.search_email=application.zcore.functions.zso(form, 'search_email');
	form.search_phone=application.zcore.functions.zso(form, 'search_phone');
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}
	if(structkeyexists(form, 'leadcontactfilter')){
		request.zsession.leadcontactfilter=form.leadcontactfilter;		
	}else if(isDefined('request.zsession.leadcontactfilter') EQ false){
		request.zsession.leadcontactfilter='all';
	}
	if(structkeyexists(form, 'grouping')){
		request.zsession.leademailgrouping=form.grouping;
	}else if(structkeyexists(request.zsession, 'leademailgrouping') EQ false){
		request.zsession.leademailgrouping='0';
	}
	db.sql="select min(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zos.globals.id)# and  
	inquiries.inquiries_datetime <> #db.param('')# and 
	inquiries_parent_id = #db.param(0)# and 
	inquiries_deleted = #db.param(0)# ";
	if(form.method EQ "userIndex"){
		db.sql&=getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ '0'){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
	variables.qinquiriesFirst=db.execute("qinquiriesFirst"); 
 

	if(isnull(variables.qinquiriesFirst.inquiries_datetime) EQ false and isdate(variables.qinquiriesFirst.inquiries_datetime)){
		variables.inquiryFirstDate=variables.qinquiriesFirst.inquiries_datetime;
	}else{
		variables.inquiryFirstDate=dateFormat(now(), "yyyy-mm-dd")&" 00:00:00";
	}
	if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
		form.inquiries_end_date=now();
	}
	if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
		form.inquiries_start_date=variables.inquiryFirstDate; 
	}
	if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
		form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
		form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
	}
	if(datediff("d",form.inquiries_start_date, variables.inquiryFirstDate) GT 0){
			form.inquiries_start_date=variables.inquiryFirstDate;
	}
	if(dateCompare(form.inquiries_start_date, form.inquiries_end_date) EQ 1){
		form.inquiries_end_date = form.inquiries_start_date;
	} 

	variables.searchFields=[];
	savecontent variable="typeField"{

		db.sql="SELECT *, 
		#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as 
		inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
		WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
		inquiries_type_deleted = #db.param(0)# ";
		if(not application.zcore.app.siteHasApp("listing")){
			db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
		}
		if(not application.zcore.app.siteHasApp("rental")){
			db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
		}
		db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
		qTypes=db.execute("qTypes");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_type_id";
		selectStruct.query = qTypes;
		selectStruct.inlineStyle="width:100%;";
		selectStruct.queryLabelField = "inquiries_type_name";
		selectStruct.queryParseValueVars=true;
		selectStruct.queryValueField = "##inquiries_type_id##|##inquiries_type_id_siteIDType##";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}
	savecontent variable="statusField"{
		db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# 
		WHERE   
		inquiries_status_deleted = #db.param(0)# "; 
		db.sql&="ORDER BY inquiries_status_name ASC ";
		qStatus=db.execute("qStatus");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_status_id";
		selectStruct.inlineStyle="width:100%;";
		selectStruct.query = qStatus;
		selectStruct.queryLabelField = "inquiries_status_name"; 
		selectStruct.queryValueField = "inquiries_status_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}

	arrayAppend(variables.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Name",
			formField:'<input type="search" name="inquiries_name" id="inquiries_name" value="#htmleditformat(application.zcore.functions.zso(form, 'inquiries_name'))#"> ',
			field:"inquiries_first_name",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Email",
			formField:'<input type="text" name="search_email" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_email')#" /> ',
			field:"search_email",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Phone",
			formField:'<input type="text" name="search_phone" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_phone')#" />',
			field:"search_phone",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Type",
			formField:typeField,
			field:"inquiries_type_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Status",
			formField:statusField,
			field:"inquiries_status_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Report Type",
			formField:statusField,
			field:"inquiries_status_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});
	arrayAppend(variables.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Start",
			formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"End",
			formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});


	db.sql="SELECT COUNT(*) AS Num, inquiries_type_name
	FROM #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries_deleted = #db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# ";

	if(form.search_phone NEQ ""){
		db.sql&=" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ";
	}
	if(form.search_office_id NEQ "0"){
		db.sql&=" and inquiries.office_id = #db.param(form.search_office_id)# ";
	}
	if(form.inquiries_status_id EQ ""){ 
		db.sql&=" and inquiries.inquiries_status_id <> #db.param(0)# ";
	}else{
		db.sql&=" and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# ";
	}
	db.sql&=" and inquiries_parent_id = #db.param(0)# ";

	if(form.method EQ "userIndex"){
		db.sql&=" #getUserLeadFilterSQL(db)#";
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ 0){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
	//if(form.searchType EQ ""){
		if(form.inquiries_status_id EQ ""){ 
			if(request.zsession.leadcontactfilter NEQ 'allclosed'){
				db.sql&=" and inquiries.inquiries_status_id NOT IN (#db.param('4')#,#db.param('5')#,#db.param('7')#) ";
			}else{
				db.sql&=" and inquiries.inquiries_status_id IN (#db.param('4')#,#db.param('5')#,#db.param('7')#) ";
			} 
		}
	//}else{ 
		if(form.inquiries_start_date EQ false){
			db.sql&=" and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
		}else{
			db.sql&=" and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
		}
		if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
			db.sql&=" and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')# ";
		}
		if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ "" and form.inquiries_type_id CONTAINS "|"){
			db.sql&=" and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
			inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ";
		}

	
	//}
	if(form.inquiries_status_id EQ ""){ 
		if(request.zsession.leadcontactfilter EQ 'new'){
			db.sql&=" and inquiries.inquiries_status_id =#db.param('1')#  ";
		}else if(request.zsession.leadcontactfilter EQ 'email'){
			db.sql&=" and inquiries_phone1 =#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'phone'){
			db.sql&=" and inquiries_phone1 <>#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'forced'){
			db.sql&=" and inquiries_phone_time<>#db.param('')# ";
		} 
	}
	if(request.zsession.leademailgrouping EQ '1'){
		db.sql&=" and inquiries_primary = #db.param('1')#";
	}
	db.sql &= " GROUP BY  inquiries.inquiries_type_id ";
	db.sql&=" ORDER BY Num ASC ";
	form.zPageId3=application.zcore.functions.zso(form, 'zPageId3');
	form.zIndex = application.zcore.status.getField(form.zPageId3, "zIndex", 1, true);
	/*if(form.searchType NEQ ""){
		db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*10)#,#db.param(10)#";
	}else{
		db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*30)#,#db.param(30)#";
	}*/
	rs.qData=db.execute("qData");  
	//echo(db.sql);
	//writeDump(rs.qData);

	//abort;
	
	</cfscript>
	<style>
	.bar {
	  fill: steelblue;
	}

	.bar:hover {
	  fill: brown;
	}

	.axis--x path {
	  display: none;
	}
	</style>
	<h2>Statistics</h2>
		<cfif arraylen(variables.searchFields)>
			<div class="z-float">
				<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 0>active</cfif>" data-tab="" data-click-location="#request.zos.originalURL#">All Data</a>
				<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 1>active</cfif>" data-tab="z-manager-search-fields"><div class="z-float-left">Search</div><div class="z-show-at-992 z-float-left">&nbsp;</div><div class="z-manager-list-tab-refine">Refine</div></a> 
			</div>
			<div class="z-manager-tab-container z-float" <cfif form.searchOn EQ 0>style="display:none;"</cfif>>
				<div class="z-manager-list-tab z-manager-search-fields <cfif form.searchOn EQ 1>active</cfif>">
					<form action="#currentLink#" method="get">
						<input type="hidden" name="searchOn" value="1">
						<cfscript>
						for(group in variables.searchFields){
							echo('<div class="z-manager-search-group"');
							if(structkeyexists(group, 'groupStyle')){
								echo(' style="#group.groupStyle#"');
							}
							echo('>');
							for(field in group.fields){

								echo('<div class="z-manager-search-field">');
								if(structkeyexists(field, 'label')){
									echo('<div class="z-manager-search-field-label"');
									if(structkeyexists(field, 'labelStyle')){
										echo(' style="#field.labelStyle#"');
									}
									echo('>#field.label#</div>');
								}
								echo('<div class="z-manager-search-field-form"');
								if(structkeyexists(field, 'fieldStyle')){
									echo(' style="#field.fieldStyle#"');
								}
								echo('>#field.formField#</div></div>');
							}
							echo('</div>');
						}
						</cfscript> 
						<div class="z-manager-search-submit">
							<input type="submit" name="submit1" class="z-manager-search-button" value="Submit">
						</div>
					</form>
				</div>
			</div>
		</cfif>
		<svg width="960" height="500"></svg>
		<script src="https://code.jquery.com/jquery-1.12.4.min.js" type="text/javascript"></script>
		<script src="https://d3js.org/d3.v4.min.js"></script>
		<script>
			$(document).ready(function(){
				var rawData = JSON.parse('#serializeJson(rs.qData)#');
				var i;
				var data = [];

				for(i = 0; i < rawData.DATA.length; i++){
				    data.push({'Num' : rawData.DATA[i][0], 'Label' : rawData.DATA[i][1]});
				}
				console.log(data);
				var svg = d3.select("svg"),
				    margin = {top: 20, right: 20, bottom: 30, left: 40},
				    width = +svg.attr("width") - margin.left - margin.right,
				    height = +svg.attr("height") - margin.top - margin.bottom;

				var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
				    y = d3.scaleLinear().rangeRound([height, 0]);
				var g = svg.append("g")
				    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

				x.domain(data.map(function(d) { return d.Label; }));
				y.domain([0, d3.max(data, function(d) { return d.Num; })]);

				  g.append("g")
				      .attr("class", "axis axis--x")
				      .attr("transform", "translate(0," + height + ")")
				      .call(d3.axisBottom(x));

				  g.append("g")
				      .attr("class", "axis axis--y")
				      //.call(d3.axisLeft(y).ticks(10, "%"))
				      .call(d3.axisLeft(y).ticks(10))
				    .append("text")
				      .attr("transform", "rotate(-90)")
				      .attr("y", 6)
				      .attr("dy", "0.71em")
				      .attr("text-anchor", "end")
				      .text("Number");

				  g.selectAll(".bar")
				    .data(data)
				    .enter().append("rect")
				      .attr("class", "bar")
				      .attr("x", function(d) { return x(d.Label); })
				      .attr("y", function(d) { return y(parseFloat(d.Num)); })
				      .attr("width", x.bandwidth())
				      .attr("height", function(d) { return height - y(d.Num); });
			});
		</script>
</cffunction>

<cffunction name="loadListLookupData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# ";
	qstatus=db.execute("qstatus");
	variables.statusName={};
	loop query="qstatus"{
		variables.statusName[qstatus.inquiries_status_id]=qstatus.inquiries_status_name;
	}

	db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
	WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_type_deleted = #db.param(0)# ";
	if(not application.zcore.app.siteHasApp("listing")){
		db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
	}
	if(not application.zcore.app.siteHasApp("rental")){
		db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
	}
	db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
	variables.qTypes=db.execute("qTypes");
	loop query="variables.qTypes"{
		variables.typeNameLookup[variables.qTypes.inquiries_type_id]=variables.qTypes.inquiries_type_name;
	}

	if(application.zcore.user.checkGroupAccess("administrator")){ 
		db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		office_deleted = #db.param(0)# 
		ORDER BY office_name ASC"; 
		qOffice=db.execute("qOffice"); 
	}else{
		qOffice=application.zcore.user.getOfficesByOfficeIdList(request.zsession.user.office_id); 
	}
	variables.officeLookup={};
	for(row in qOffice){
		variables.officeLookup[row.office_id]=row;
	}
	</cfscript> 

</cffunction>
<cffunction name="googleSourceBreakdown" localmode="modern" access="remote" roles="member">
	<cfscript> 
	form.searchOn=application.zcore.functions.zso(form, 'searchOn', true, 0);
	params=[];//&#variables.pageZSID#=#form[variables.pageZSID]#");
	if(form.searchOn EQ 1){
		arrayAppend(params, "searchOn=#form.searchOn#");
	} 
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Reports");
	var db=request.zos.queryObject; 
	rs={};
	loadListLookupData();
	variables.searchFields=[]; 
	if(structkeyexists(rs, 'searchFields')){
		variables.searchFields=rs.searchFields;
	}
 	for(group in variables.searchFields){
 		if(structkeyexists(group, 'fields')){
		 	for(field in group.fields){
		 		form[field.field]=application.zcore.functions.zso(form, field.field); 

				if(form.searchOn EQ 1){
 					arrayAppend(params, "#field.field#=#urlencodedformat(form[field.field])#");
 				}
		 	}
		}
	}
 	currentLink=application.zcore.functions.zURLAppend(request.zos.originalURL, arrayToList(params, "&"));
	form.search_office_id=application.zcore.functions.zso(form, 'search_office_id', true, "0");
	if(application.zcore.functions.zso(request.zsession, "selectedofficeid", true, 0) NEQ 0){
		form.search_office_id=request.zsession.selectedofficeid;
	}
	form.searchType=application.zcore.functions.zso(form, 'searchType');
	form.search_email=application.zcore.functions.zso(form, 'search_email');
	form.search_phone=application.zcore.functions.zso(form, 'search_phone');
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}
	if(structkeyexists(form, 'leadcontactfilter')){
		request.zsession.leadcontactfilter=form.leadcontactfilter;		
	}else if(isDefined('request.zsession.leadcontactfilter') EQ false){
		request.zsession.leadcontactfilter='all';
	}
	if(structkeyexists(form, 'grouping')){
		request.zsession.leademailgrouping=form.grouping;
	}else if(structkeyexists(request.zsession, 'leademailgrouping') EQ false){
		request.zsession.leademailgrouping='0';
	}
	db.sql="select min(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zos.globals.id)# and  
	inquiries.inquiries_datetime <> #db.param('')# and 
	inquiries_parent_id = #db.param(0)# and 
	inquiries_deleted = #db.param(0)# ";
	if(form.method EQ "userIndex"){
		db.sql&=getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ '0'){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
	variables.qinquiriesFirst=db.execute("qinquiriesFirst"); 
 

	if(isnull(variables.qinquiriesFirst.inquiries_datetime) EQ false and isdate(variables.qinquiriesFirst.inquiries_datetime)){
		variables.inquiryFirstDate=variables.qinquiriesFirst.inquiries_datetime;
	}else{
		variables.inquiryFirstDate=dateFormat(now(), "yyyy-mm-dd")&" 00:00:00";
	}
	if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
		form.inquiries_end_date=now();
	}
	if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
		form.inquiries_start_date=variables.inquiryFirstDate; 
	}
	if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
		form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
		form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
	}
	if(datediff("d",form.inquiries_start_date, variables.inquiryFirstDate) GT 0){
			form.inquiries_start_date=variables.inquiryFirstDate;
	}
	if(dateCompare(form.inquiries_start_date, form.inquiries_end_date) EQ 1){
		form.inquiries_end_date = form.inquiries_start_date;
	} 
	
	variables.searchFields=[];
	savecontent variable="typeField"{

		db.sql="SELECT *, 
		#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as 
		inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
		WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
		inquiries_type_deleted = #db.param(0)# ";
		if(not application.zcore.app.siteHasApp("listing")){
			db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
		}
		if(not application.zcore.app.siteHasApp("rental")){
			db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
		}
		db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
		qTypes=db.execute("qTypes");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_type_id";
		selectStruct.query = qTypes;
		selectStruct.inlineStyle="width:100%;";
		selectStruct.queryLabelField = "inquiries_type_name";
		selectStruct.queryParseValueVars=true;
		selectStruct.queryValueField = "##inquiries_type_id##|##inquiries_type_id_siteIDType##";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}
	savecontent variable="statusField"{
		db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# 
		WHERE   
		inquiries_status_deleted = #db.param(0)# "; 
		db.sql&="ORDER BY inquiries_status_name ASC ";
		qStatus=db.execute("qStatus");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_status_id";
		selectStruct.inlineStyle="width:100%;";
		selectStruct.query = qStatus;
		selectStruct.queryLabelField = "inquiries_status_name"; 
		selectStruct.queryValueField = "inquiries_status_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}

	arrayAppend(variables.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Name",
			formField:'<input type="search" name="inquiries_name" id="inquiries_name" value="#htmleditformat(application.zcore.functions.zso(form, 'inquiries_name'))#"> ',
			field:"inquiries_first_name",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Email",
			formField:'<input type="text" name="search_email" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_email')#" /> ',
			field:"search_email",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Phone",
			formField:'<input type="text" name="search_phone" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_phone')#" />',
			field:"search_phone",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Type",
			formField:typeField,
			field:"inquiries_type_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Status",
			formField:statusField,
			field:"inquiries_status_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Report Type",
			formField:statusField,
			field:"inquiries_status_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});
	arrayAppend(variables.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Start",
			formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"End",
			formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});


	db.sql="SELECT COUNT(*) AS Num, inquiries_type_name
	FROM #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries_deleted = #db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# ";

	if(form.search_phone NEQ ""){
		db.sql&=" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ";
	}
	if(form.search_office_id NEQ "0"){
		db.sql&=" and inquiries.office_id = #db.param(form.search_office_id)# ";
	}
	if(form.inquiries_status_id EQ ""){ 
		db.sql&=" and inquiries.inquiries_status_id <> #db.param(0)# ";
	}else{
		db.sql&=" and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# ";
	}
	db.sql&=" and inquiries_parent_id = #db.param(0)# ";

	if(form.method EQ "userIndex"){
		db.sql&=" #getUserLeadFilterSQL(db)#";
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ 0){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
	//if(form.searchType EQ ""){
		if(form.inquiries_status_id EQ ""){ 
			if(request.zsession.leadcontactfilter NEQ 'allclosed'){
				db.sql&=" and inquiries.inquiries_status_id NOT IN (#db.param('4')#,#db.param('5')#,#db.param('7')#) ";
			}else{
				db.sql&=" and inquiries.inquiries_status_id IN (#db.param('4')#,#db.param('5')#,#db.param('7')#) ";
			} 
		}
	//}else{ 
		if(form.inquiries_start_date EQ false){
			db.sql&=" and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
		}else{
			db.sql&=" and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
		}
		if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
			db.sql&=" and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')# ";
		}
		if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ "" and form.inquiries_type_id CONTAINS "|"){
			db.sql&=" and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
			inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ";
		}

	
	//}
	if(form.inquiries_status_id EQ ""){ 
		if(request.zsession.leadcontactfilter EQ 'new'){
			db.sql&=" and inquiries.inquiries_status_id =#db.param('1')#  ";
		}else if(request.zsession.leadcontactfilter EQ 'email'){
			db.sql&=" and inquiries_phone1 =#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'phone'){
			db.sql&=" and inquiries_phone1 <>#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'forced'){
			db.sql&=" and inquiries_phone_time<>#db.param('')# ";
		} 
	}
	if(request.zsession.leademailgrouping EQ '1'){
		db.sql&=" and inquiries_primary = #db.param('1')#";
	}
	db.sql &= " GROUP BY  inquiries.inquiries_type_id ";
	db.sql&=" ORDER BY Num ASC ";
	form.zPageId3=application.zcore.functions.zso(form, 'zPageId3');
	form.zIndex = application.zcore.status.getField(form.zPageId3, "zIndex", 1, true);
	/*if(form.searchType NEQ ""){
		db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*10)#,#db.param(10)#";
	}else{
		db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*30)#,#db.param(30)#";
	}*/
	rs.qData=db.execute("qData");  
	//echo(db.sql);
	//writeDump(rs.qData);

	//abort;
	
	</cfscript>
	<style>
		.arc text {
		  font: 16px sans-serif;
		  text-anchor: middle;
		}

		.arc path {
		  stroke: ##fff;
		}
	</style>
	<h2>Statistics</h2>
		<cfif arraylen(variables.searchFields)>
			<div class="z-float">
				<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 0>active</cfif>" data-tab="" data-click-location="#request.zos.originalURL#">All Data</a>
				<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 1>active</cfif>" data-tab="z-manager-search-fields"><div class="z-float-left">Search</div><div class="z-show-at-992 z-float-left">&nbsp;</div><div class="z-manager-list-tab-refine">Refine</div></a> 
			</div>
			<div class="z-manager-tab-container z-float" <cfif form.searchOn EQ 0>style="display:none;"</cfif>>
				<div class="z-manager-list-tab z-manager-search-fields <cfif form.searchOn EQ 1>active</cfif>">
					<form action="#currentLink#" method="get">
						<input type="hidden" name="searchOn" value="1">
						<cfscript>
						for(group in variables.searchFields){
							echo('<div class="z-manager-search-group"');
							if(structkeyexists(group, 'groupStyle')){
								echo(' style="#group.groupStyle#"');
							}
							echo('>');
							for(field in group.fields){

								echo('<div class="z-manager-search-field">');
								if(structkeyexists(field, 'label')){
									echo('<div class="z-manager-search-field-label"');
									if(structkeyexists(field, 'labelStyle')){
										echo(' style="#field.labelStyle#"');
									}
									echo('>#field.label#</div>');
								}
								echo('<div class="z-manager-search-field-form"');
								if(structkeyexists(field, 'fieldStyle')){
									echo(' style="#field.fieldStyle#"');
								}
								echo('>#field.formField#</div></div>');
							}
							echo('</div>');
						}
						</cfscript> 
						<div class="z-manager-search-submit">
							<input type="submit" name="submit1" class="z-manager-search-button" value="Submit">
						</div>
					</form>
				</div>
			</div>
		</cfif>
		<br />
		<br />
		<br />
		<br />
		<h3 style="color:##000000;padding-left:20px;">Top Channels</h3>
		<div>
			<svg width="600" height="440" style="padding-left:10px; float:left;">
			</svg>
			<div id="divPieLabels" style="padding-top:50px; float:left;"></div>
		<div>
		<script src="https://code.jquery.com/jquery-1.12.4.min.js" type="text/javascript"></script>
		<script src="https://d3js.org/d3.v4.min.js"></script>
		<script>
			$(document).ready(function(){
				var rawData = JSON.parse('#serializeJson(rs.qData)#');
				var i;
				//var data = [];
				var data = [{"mrktType":"Organic Search", "amt":3404}, 
						          {"mrktType":"Direct", "amt":849}, 
						          {"mrktType":"Referral", "amt":541},
						          {"mrktType":"Social", "amt":170},
						          {"mrktType":"Email", "amt":1029}
						          ];

				var total = 0;
				var $divPieLabels = $("##divPieLabels");
				//var color = d3.scale.category20c();
				var arrColors = ["##058dc7", "##50b432", "##ed561b", "##edef00", "##24cbe5", "##d0743c", "##ff8c00"];
				var color = d3.scaleOrdinal(arrColors);	
				for(i=0; i < data.length; i++){
					total	+= data[i].amt;
					$divPieLabels.append("<div style=\"float:left; width:15px;background-color:" 
						+ arrColors[i] 
						+ "\">&nbsp;</div>&nbsp;&nbsp;&nbsp;<span style=\"font:16px  sans-serif;font-weight:bold;\">" 
						+ data[i].mrktType 
						+ "</span><br /><br />"); 		
				} 		          
				/*for(i = 0; i < rawData.DATA.length; i++){
				    data.push({'Num' : rawData.DATA[i][0], 'Label' : rawData.DATA[i][1]});
				}*/
				console.log(data);
				var svg = d3.select("svg"),
    				width = 580 /*+svg.attr("width")*/,
    				height = 370/*+svg.attr("height")*/,
    				radius = Math.min(width, height) / 2,
    				g = svg.append("g").attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

				
				var pie = d3.pie()
			    	.sort(null)
			    	.value(function(d) { return d.amt; });

				var path = d3.arc()
			    	.outerRadius(radius - 40)
			    	.innerRadius(0);

				var label = d3.arc()
			    	.outerRadius(radius + 10)
			    	.innerRadius(radius - 40);

				var arc = g.selectAll(".arc")
				.data(pie(data))
				.enter().append("g")
				  .attr("class", "arc");

				arc.append("path")
				  .attr("d", path)
				  .attr("fill", function(d) { return color(d.data.mrktType); });

				arc.append("text")
				  .attr("transform", function(d) { return "translate(" + label.centroid(d) + ")"; })
				  .attr("dy", "0.35em")
				  .text(function(d) { 
				  	var amt 	= (100 * parseFloat(d.data.amt/total).toFixed(2)).toString();
				  	var iPos 	= amt.indexOf(".");
				  	if(iPos	!= -1){
				  		amt = amt.substr(0, iPos);
				  	}
				  	//return d.data.mrktType + " " + (amt) + " %"; 
				  	return amt + "%"; 
				  });
			});
		</script>
</cffunction>

<cffunction name="loadListLookupData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# ";
	qstatus=db.execute("qstatus");
	variables.statusName={};
	loop query="qstatus"{
		variables.statusName[qstatus.inquiries_status_id]=qstatus.inquiries_status_name;
	}

	db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
	WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_type_deleted = #db.param(0)# ";
	if(not application.zcore.app.siteHasApp("listing")){
		db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
	}
	if(not application.zcore.app.siteHasApp("rental")){
		db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
	}
	db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
	variables.qTypes=db.execute("qTypes");
	loop query="variables.qTypes"{
		variables.typeNameLookup[variables.qTypes.inquiries_type_id]=variables.qTypes.inquiries_type_name;
	}

	if(application.zcore.user.checkGroupAccess("administrator")){ 
		db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		office_deleted = #db.param(0)# 
		ORDER BY office_name ASC"; 
		qOffice=db.execute("qOffice"); 
	}else{
		qOffice=application.zcore.user.getOfficesByOfficeIdList(request.zsession.user.office_id); 
	}
	variables.officeLookup={};
	for(row in qOffice){
		variables.officeLookup[row.office_id]=row;
	}
	</cfscript> 

</cffunction>


<cffunction name="chart" localmode="modern" access="remote">
	<cfscript>
	//init();
	</cfscript>
<!DOCTYPE html>
<head>
<script src="https://code.jquery.com/jquery-1.12.4.min.js" type="text/javascript"></script>
<script src="https://d3js.org/d3.v4.min.js"></script>
</head>
<body>
<cfscript>
chartData=[{date:"04/01/2017", close: 10}, 
	{date:"05/01/2017", close: 15}, 
	{date:"06/01/2017", close: 25}];
</cfscript>
<svg data-jsondata="#htmleditformat(serializeJson(chartData))#" width="960" height="500"></svg>
<script>
<cfscript>myJson={ stuff:true};</cfscript><script> var myJson=#serializeJson(myJson)#; </script>
/*
var dataArray = [103, 13, 21, 14, 37, 15, 18, 34, 30];

var svg = d3.select("body").append("svg")
          .attr("height","100%")
          .attr("width","100%");

svg.selectAll("rect")
    .data(dataArray)
    .enter().append("rect")
          .attr("class", "bar")
          .attr("height", function(d, i) {return (d * 10)})
          .attr("width","40")
          .attr("x", function(d, i) {return (i * 60) + 25})
          .attr("y", function(d, i) {return 400 - (d * 10)});
*/

function loadLineCharts(){
	$("svg").each(function(){

		var svg = d3.select("svg"),
		    margin = {top: 20, right: 20, bottom: 30, left: 50},
		    width = +svg.attr("width") - margin.left - margin.right,
		    height = +svg.attr("height") - margin.top - margin.bottom,
		    g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

		var parseTime = d3.timeParse("%m/%d/%Y");

		var x = d3.scaleTime()
		    .rangeRound([0, width]);

		var y = d3.scaleLinear()
		    .rangeRound([height, 0]);

		var area = d3.area()
		    .x(function(d) { return x(d.date); })
		    .y1(function(d) { return y(d.close); });

		var data=JSON.parse($(this).attr("data-jsondata"));
		for(var i=0;i<data.length;i++){
			data[i].date=parseTime(data[i].date);
		}
			/*[{date:parseTime("04/01/2017"), close: 10}, 
		{date:parseTime("05/01/2017"), close: 15}, 
		{date:parseTime("06/01/2017"), close: 25}]; 
		*/
		 /*
		d3.tsv("/zupload/data.txt", function(d) {
		  d.date = parseTime(d.date);
		  d.close = +d.close;
		  return d;
		}, function(error, data2) {
			console.log(data2);*/
		x.domain(d3.extent(data, function(d) {  return d.date; }));
		y.domain([0, d3.max(data, function(d) { return d.close; })]);
		area.y0(y(0));

		g.append("path")
		      .datum(data)
		      .attr("fill", "rgba(0,68,175,1)")
		      .attr("d", area);

		g.append("g")
		      .attr("transform", "translate(0," + height + ")")
		      .call(d3.axisBottom(x));
		      /*
		    .append("text") 
		      .attr("y", 6)
		      .attr("x", 850)
		      .attr("dy", "0.71em")
		      .attr("fill", "##000")
		      .attr("text-anchor", "end")
		      .text("Month");*/

		g.append("g")
		      .call(d3.axisLeft(y))
		    .append("text")
		      .attr("fill", "##000")
		      .attr("transform", "rotate(-90)")
		      .attr("y", 6)
		      .attr("dy", "0.71em")
		      .attr("text-anchor", "end")
		      .text("Facebook Fans");
		      g;  
		/* }); */
	});
}
$(document).ready(function(){
	loadLineCharts();
});
//});
</script>
</body></html><cfabort>

</cffunction>


</cfoutput>

</cfcomponent>
