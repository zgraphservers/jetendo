<cfcomponent>
<cfoutput>
<cffunction name="displayJob" localmode="modern" access="private">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	request.zos.currentURLISAJobPage=true;

	db=request.zos.queryObject;
	struct=arguments.struct;

	if(struct.job_status EQ 0){
		application.zcore.template.prependTag("content", '<div class="zJobView-preview-message">This job is not active. The public can''t view it until it is made active.</div>');
	}
	jobCom=application.zcore.app.getAppCFC("job");
	//writedump(struct);

	</cfscript>  
<!---
	<cfsavecontent variable="scriptOutput">
		<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&amp;sensor=false<cfif request.zos.globals.googleMapsApiKey NEQ "">&amp;key=#request.zos.globals.googleMapsApiKey#</cfif>"></script>
		<script type="text/javascript">
		/* <![CDATA[ */
		function zJobMapSuccessCallback(){
			$("##zJobViewMapContainer").show();
		}
		zArrDeferredFunctions.push(function(){
			//$("##zJobSlideshowDiv").cycle({timeout:3000, speed:1200});
			//$( "##startdate" ).datepicker();
			//$( "##enddate" ).datepicker();
			<cfif struct.job_address NEQ "">
				var optionsObj={ zoom: 13 };
				var markerObj={
					infoWindowHTML:'<a href="https://maps.google.com/maps?q=#urlencodedformat(struct.job_address&", "&struct.job_city&", "&struct.job_state&" "&struct.job_zip&" "&struct.job_country)#" target="_blank">Get Directions on Google Maps</a>'
				};
				<cfif struct.job_map_coordinates NEQ "">
					arrLatLng=[#struct.job_map_coordinates#]; 
					zCreateMapWithLatLng("zJobMapDivId", arrLatLng[0], arrLatLng[1], optionsObj, zJobMapSuccessCallback, markerObj);  
				<cfelse>
					zCreateMapWithAddress("zJobMapDivId", "#jsstringformat(struct.job_address&', '&struct.job_city&", "&struct.job_state&" "&struct.job_zip&" "&application.zcore.functions.zCountryAbbrToFullName(struct.job_country))#", optionsObj, zJobMapSuccessCallback); 
				</cfif>
			</cfif> 
		});
		/* ]]> */
		</script> 
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta", scriptOutput); 
	request.zos.template.setTag("title", struct.job_title);
	request.zos.template.setTag("pagetitle", struct.job_title);

	countryName=application.zcore.functions.zCountryAbbrToFullName(struct.job_country);

	</cfscript>


	<div class="zJobView1-4">
		<div class="zJobView1-1">Date:</div>
		<div class="zJobView1-2">
		#jobCom.getDateTimeRangeString(struct)# 
		</div>
	</div>

	<cfscript>

	savecontent variable="slideShowOut"{
		echo('<div class="zJobView1-3">');
		ts=structnew();
		ts.output=true;
		ts.size=request.zos.globals.maximagewidth&"x"&(request.zos.globals.maximagewidth*.6);
		ts.image_library_id=struct.job_image_library_id;
		ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(struct.job_image_library_layout);
		ts.forceSize=true; 
		ts.crop=0;
		ts.offset=0;
		ts.limit=0;  
		arrImage=request.zos.imageLibraryCom.displayImages(ts); 
		ts.layoutType="";
		ts.output=false;
		ts.size="1900x1080";
		arrImage2=request.zos.imageLibraryCom.displayImages(ts); 
		echo('<div id="zJobViewLightGallery" class="zJobView1-larger">  ');
		for(i=1;i LTE arraylen(arrImage2);i++){
			echo('<a href="#arrImage2[i].link#" title="Image #i#" onclick="return false;" ');
			if(i NEQ 1){
				echo('style="display:none;"');
			}
			echo('>View larger images</a>');
		}
		echo('</div>');
		application.zcore.functions.zSetupLightbox("zJobViewLightGallery");
		echo('</div>');
	}
	if(application.zcore.imageLibraryCom.isBottomLayoutType(struct.job_image_library_layout)){
		slideshowOutBottom=slideshowOut;
		slideshowOutTop="";
	}else{
		slideshowOutTop=slideshowOut;
		slideshowOutBottom="";
	}
	</cfscript>
	

	#slideshowOutTop#
	<div style="width:100%; float:left;">
		<cfif struct.job_overview NEQ "">
	
			<div class="zJobView1-3">
				<h2>Job Description</h2>
				#struct.job_overview#
			</div>
		</cfif>
		<div class="zJobView1-3">
			<cfif struct.job_address NEQ "">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Location:</div>
					<div class="zJobView1-2">
						<cfif struct.job_location NEQ "">
							#struct.job_location#<br />
						</cfif>
						#htmleditformat(struct.job_address)#<br />
						#struct.job_city#

						#htmleditformat(struct.job_state&" "&struct.job_zip)# 
						<cfif struct.job_country NEQ "US">
							#countryName#
						</cfif>
					</div>
				</div>
			</cfif> 
			<cfif struct.job_phone NEQ "">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Phone:</div>
					<div class="zJobView1-2"><a class="zPhoneLink">#htmleditformat(struct.job_phone)#</a></div>
				</div>
			</cfif>
			<cfif left(struct.job_website, 7) EQ "http://" or left(struct.job_website, 8) EQ "https://">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Website:</div>
					<div class="zJobView1-2"><a href="#htmleditformat(struct.job_website)#" target="_blank">#htmleditformat(struct.job_website)#</a></div>
				</div>
			</cfif>
			<cfif struct.job_file1 NEQ "" or struct.job_file2 NEQ "">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Download Files:</div>
					<div class="zJobView1-2">
						<cfif struct.job_file1 NEQ "">
							<a href="#htmleditformat("/zupload/job/"&struct.job_file1)#" target="_blank">
								<cfif struct.job_file1label NEQ "">
									#struct.job_file1label#
								<cfelse>
									File 1
								</cfif>
							</a>
						</cfif>
						<cfif struct.job_file2 NEQ "">
							<br /><a href="#htmleditformat("/zupload/job/"&struct.job_file2)#" target="_blank">
								<cfif struct.job_file2label NEQ "">
									#struct.job_file2label#
								<cfelse>
									File 2
								</cfif>
							</a>
						</cfif>
					</div>
				</div>
			</cfif>
			<div class="zJobView1-0">
				<div class="zJobView1-1">Share:</div>
				<div class="zJobView1-2"> 
					<a href="##"  data-ajax="false" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#urlencodedformat(struct.job_title)#&amp;link=#urlencodedformat(request.zos.currentHostName&struct.__url)#', 540, 630);return false;" rel="nofollow" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_03.jpg" alt="Share by email" width="30" height="30" /></a>
					<a href="https://www.facebook.com/sharer/sharer.php?u=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_05.jpg" alt="Share on facebook" width="30" height="30" /></a>
					<a href="https://twitter.com/share?url=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_07.jpg" alt="Share on twitter" width="30" height="30" /></a>
					<a href="http://www.linkedin.com/shareArticle?mini=true&amp;url=#urlencodedformat(request.zos.currentHostName&struct.__url)#&amp;title=#urlencodedformat(struct.job_title)#&amp;summary=&amp;source=#urlencodedformat(request.zos.globals.shortDomain)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_09.jpg" alt="Share on linkedin" width="30" height="30" /></a> 
					<a href="##" onclick="window.print(); return false;" target="_blank" class="zJobView1-print" rel="nofollow">Print</a>
				</div>
			</div>

			<cfif application.zcore.functions.zso(application.zcore.app.getAppData("job").optionStruct, 'job_config_add_to_calendar_enabled') EQ "1">
				<cfscript>
				application.zcore.skin.includeJS("//addthisjob.com/libs/1.6.0/ate.min.js");
				arrLocation=[];
				if(struct.job_location NEQ ""){
					arrayAppend(arrLocation, struct.job_location);
				}
				if(struct.job_address NEQ ""){
					arrayAppend(arrLocation, struct.job_address&", ");
				}
				if(struct.job_city NEQ ""){
					arrayAppend(arrLocation, struct.job_city&", ");
				}
				if(struct.job_state NEQ ""){
					arrayAppend(arrLocation, struct.job_state);
				}
				if(struct.job_zip NEQ ""){
					arrayAppend(arrLocation, struct.job_zip);
				}
				if(struct.job_country NEQ "" and struct.job_country NEQ "US"){
					arrayAppend(arrLocation, countryName);
				}
				locationText=arrayToList(arrLocation, " ");
				</cfscript>
				<div class="zJobView1-0">
					<div class="zJobView1-1">&nbsp;</div>
					<div class="zJobView1-2"> 

						<div title="Add to Calendar" class="addthisjob">
							Add to Your Calendar
							<span class="start">#dateformat(struct.job_posted_datetime, "mm/dd/yyyy")# #timeformat(struct.job_posted_datetime, "HH:mm tt")#</span>
							<span class="end">#dateformat(struct.job_closed_datetime, "mm/dd/yyyy")# #timeformat(struct.job_closed_datetime, "HH:mm tt")#</span>
							<span class="timezone">America/New_York</span>
							<span class="title">#struct.job_title#</span>
							<span class="description">#application.zcore.functions.zRemoveHTMLForSearchIndexer(struct.job_overview)#</span>
							<cfif locationText NEQ "">
								<span class="location">#locationText#</span>
							</cfif>
							<span class="all_day_job"><cfif struct.job_allday EQ 1>true<cfelse>false</cfif></span>
							<span class="date_format">MM/DD/YYYY</span>
						</div>
				
					</div>
				</div>
			</cfif>

		</div>
		<cfif struct.job_address NEQ "">
			<div id="zJobViewMapContainer">
				<div class="zJobView1-Map"  id="zJobMapDivId"></div>
				<div style="width:100%; float:left;padding-top:10px; padding-bottom:10px;"> <a href="https://maps.google.com/maps?q=#urlencodedformat(struct.job_address&", "&struct.job_city&", "&struct.job_state&" "&struct.job_zip&" "&struct.job_country)#" target="_blank">Launch In Google Maps</a></div>
			</div>
		</cfif>
	</div>  
	#slideshowOutBottom#

	<a href="#calendarLink#" class="zJobView1-backToCalendar">Back To Calendar</a>
	<cfif application.zcore.user.checkGroupAccess("member") and application.zcore.adminSecurityFilter.checkFeatureAccess("Manage Jobs", true)>
		<a href="/z/job/admin/manage-jobs/edit?job_id=#struct.job_id#&amp;return=1" class="zNoContentTransition zJobView1-backToCalendar" style="margin-left:10px;">Edit</a>
	</cfif>

--->
 	
</cffunction>
</cfoutput>

<cffunction name="viewJob" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject; 
	form.job_id=application.zcore.functions.zso(form, 'job_id', true);
	ts.job_id=form.job_id;
	ts.perpage=1;

	if(application.zcore.user.checkGroupAccess("member")){
		ts.showInactive=true;
	}
	jobCom=application.zcore.app.getAppCFC("job");
	rs=jobCom.searchJobs(ts);
	if(rs.count EQ 0){
		jobCom=application.zcore.app.getAppCFC("job");
		rs=jobCom.searchJobs(ts);
	} 
	if(rs.count NEQ 1){
		application.zcore.functions.z404("Job, #form.job_id#, is missing");
	}

	row=rs.arrData[1];


	if(structkeyexists(form, 'zUrlName')){
		if(row.job_unique_url EQ ""){

			curLink=row.__url; 
			urlId=application.zcore.app.getAppData("job").optionstruct.job_config_job_url_id;
			actualLink="/"&application.zcore.functions.zURLEncode(form.zURLName, '-')&"-"&urlId&"-"&row.job_id&".html";

			if(compare(curLink,actualLink) neq 0){
				application.zcore.functions.z301Redirect(curLink);
			}
		}else{
			if(compare(row.job_unique_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(row.job_unique_url);
			}
		}
	}
	displayJob(row);
	</cfscript>
</cffunction>
</cfcomponent>