<cfcomponent> 
<cfoutput>
<cffunction name="importComplete" localmode="modern" roles="serveradministrator">
	<cfscript> 
	if(not request.zos.isDeveloper){
		application.zcore.functions.z404("Only developer can run this.");
	} 
	</cfscript>
	Jobs import completed.
</cffunction>

<cffunction name="importFilter" localmode="modern" roles="serveradministrator">
<cfargument name="struct" type="struct" required="yes">
	<cfscript> 
	var struct=arguments.struct;
	if(not request.zos.isDeveloper){
		application.zcore.functions.z404("Only developer can run this.");
	}  
	ts={};  


	arrCategory=[];
	if(struct.category EQ ""){
		if(structkeyexists(form, 'job_category_id') and form.job_category_id NEQ ""){
			ts.job_category_id=form.job_category_id;
			arrCategory=[form.job_category_id];
		}
	}else{
		// get all categories into request.jobCategoryStruct
		arrCategoryName=listToArray(struct.category, ',');
		// loop categories 
		for(name in arrCategoryName){
			if(structkeyexists(request.jobCategoryStruct, name)){
				arrayAppend(arrCategory, request.jobCategoryStruct[name]);
			}
		} 
	}
 
	//ts.user_id=0;
	//ts.user_id_siteIDType=1;
	ts.job_category_id=arrayToList(arrCategory, ",");
	ts.job_title=struct.title;
	ts.job_unique_url=struct["Unique URL"];
	if(struct["Status"] EQ "" or struct["Status"] EQ "Active" or struct["Status"] EQ "true" or struct["Status"] EQ "Y" or struct["Status"] EQ 1 or struct["Status"] EQ "Yes"){
		ts.job_status="1";
	}else{
		ts.job_status=struct.status;
	}
	ts.job_location=struct.location;
	ts.job_address=struct.address;
	ts.job_address2=struct.address2;
	ts.job_city=struct.city;
	ts.job_state=struct.state;
	ts.job_country=struct.country;
	ts.job_zip=struct.zip;
	ts.job_map_coordinates=struct["Map Coordinates"];
	ts.job_company_name=struct["Company Name"];
	if(struct["Hide Company Name"] EQ "true" or struct["Hide Company Name"] EQ "Y" or struct["Hide Company Name"] EQ 1 or struct["Hide Company Name"] EQ "Yes"){
		ts.job_company_name_hidden="1";
	}else{
		ts.job_company_name_hidden="0";
	}
	ts.job_phone=struct.phone;
	ts.job_website=struct.website;
	if(struct["Featured"] EQ "true" or struct["Featured"] EQ "Y" or struct["Featured"] EQ 1 or struct["Featured"] EQ "Yes"){
		ts.job_featured=1;
	}else{
		ts.job_featured=0;
	}

	ts.job_type=application.zcore.app.getAppCFC( 'job' ).jobTypeStringToId(struct.type); 

	if(struct["Posted Datetime"] NEQ "" and isdate(struct["Posted Datetime"])){
		ts.job_posted_datetime=dateformat(struct["Posted Datetime"], "yyyy-mm-dd")&" "&timeformat(struct["Posted Datetime"], "HH:mm:ss");
	}else{
		ts.job_posted_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	}
	if(struct["Closed Datetime"] NEQ "" and isdate(struct["Closed Datetime"])){
		ts.job_closed_datetime=dateformat(struct["Closed Datetime"], "yyyy-mm-dd")&" "&timeformat(struct["Closed Datetime"], "HH:mm:ss");
	}
	ts.job_position_title=struct["Position Title"];
	ts.job_summary=struct["Summary"];
	ts.job_overview=struct["Full Description"];
	ts.job_suggested_by_name=struct["Suggested By Name"];
	ts.job_suggested_by_email=struct["Suggested By Email"];
	ts.job_suggested_by_phone=struct["Suggested By Phone"];
	ts.job_external_id=struct["External ID"];

	// no image support
	//ts.job_image_library_id=0;
	//ts.job_image_library_layout=0;

	return ts;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>