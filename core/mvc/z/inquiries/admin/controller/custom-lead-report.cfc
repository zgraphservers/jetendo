<cfcomponent>
<cfoutput>
<cffunction name="showDate" localmode="modern" access="public">
	<cfargument name="d" type="string" required="yes">
	<cfscript>
	d=arguments.d;
	if(d EQ "" or not isdate(d)){
		echo('Never Imported');
	}else{
		echo(dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "h:mm:ss"));
	}
	</cfscript>
</cffunction>

<cffunction name="isValidMonth" localmode="modern" access="remote">
	<cfargument name="month" type="string" required="yes">
	<cfscript>
	reportStartDate=application.zcore.functions.zso(request.zos.globals, 'reportStartDate'); 
	if(reportStartDate NEQ ""){

		arguments.month=dateformat(arguments.month, "yyyy-mm-dd"); 
		if(datecompare(arguments.month, reportStartDate) GTE 0){
			return true;
		}else{
			return false;
		}
	}else{
		return true;
	}
	</cfscript>
</cffunction>

	
<cffunction name="filterInquiryTableSQL" localmode="modern" access="remote">
	<cfargument name="db" type="component" required="yes">
	<cfscript>
	db=arguments.db;
	arrExcludeLeadTypeList=listToArray(application.zcore.functions.zso(request.zos.globals, 'excludeLeadTypeList'), ",");
	db.sql&=" and inquiries_spam <> #db.param(1)# "
	if(arrayLen(arrExcludeLeadTypeList)){
		db.sql&=" and ( ";
		for(i=1;i<=arraylen(arrExcludeLeadTypeList);i++){
			if(i NEQ 1){
				db.sql&=" and ";
			}
			db.sql&=" concat(inquiries_type_id, #db.param('|')#, inquiries_type_id_siteIDType) <> #db.param(arrExcludeLeadTypeList[i])# ";
		}
		db.sql&=" ) ";
	}
	reportStartDate=application.zcore.functions.zso(request.zos.globals, 'reportStartDate');
	if(reportStartDate NEQ ""){
		db.sql&=" and inquiries_datetime>=#db.param(dateformat(reportStartDate, "yyyy-mm-dd")&" 00:00:00")# ";
	}
	</cfscript>
</cffunction>
	
<cffunction name="filterOtherTableSQL" localmode="modern" access="remote">
	<cfargument name="db" type="component" required="yes">
	<cfargument name="dateField" type="string" required="yes">
	<cfscript>
	db=arguments.db; 
	reportStartDate=application.zcore.functions.zso(request.zos.globals, 'reportStartDate');
	if(reportStartDate NEQ ""){
		db.sql&=" and `#arguments.dateField#`>=#db.param(dateformat(reportStartDate, "yyyy-mm-dd")&" 00:00:00")# ";
	}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript>
	/*
	
		ytd
		month
		month over month
		year over year

		web lead and phone (call tracking metrics)
	*/

	form.yearToDateLeadLog=application.zcore.functions.zso(form, 'yearToDateLeadLog', true, 0);

	request.pageCount=0;
	if(form.yearToDateLeadLog EQ 1){
		request.rowLimit=36;
	}else{
		request.rowLimit=31;
	}
	request.contentSection={
		Summary:0,
		LeadComparison:0,
		TopVerifiedRankings:0,
		VerifiedRankings:0,
		OrganicSearch:0,
		PhoneLog:0,
		WebLeadLog:0,
		leadTypeSummary:0
	};
	request.disableContentSection={
		Summary:false,
		LeadComparison:false,
		TopVerifiedRankings:false,
		VerifiedRankings:false,
		OrganicSearch:false,
		PhoneLog:false,
		WebLeadLog:false,
		leadTypeSummary:false
	}; 
	form.disableSection=application.zcore.functions.zso(form, 'disableSection');
	arrSection=listToArray(form.disableSection, ",");
	for(section in arrSection){
		if(structkeyexists(request.disableContentSection, section)){
			request.disableContentSection[section]=true;
		}
	}
	db=request.zos.queryObject;
	typeLookup={};
	typeIdLookup={};
	//application.zcore.template.setPlainTemplate();


	if(not structkeyexists(form, 'selectedMonth')){
		firstOfMonth=createdate(year(now()), month(now()), 1);
		form.selectedMonth=dateformat(dateadd("d", -1, firstOfMonth), "yyyy-mm");
	}
	request.selectedMonth=form.selectedMonth;

	//startDate=form.selectedMonth&"-01 00:00:00";

	firstOfYear=year(request.selectedMonth)&"-01-01";
	if(form.yearToDateLeadLog EQ 1){
		//throw("not implemented");
		startDate=firstOfYear;
		startMonthDate=firstOfYear;
		endDate=dateformat(dateadd("m", 1, form.selectedMonth), "yyyy-mm-dd")&" 00:00:00";
	}else{
		startDate=dateformat(dateadd("m", -2, form.selectedMonth&"-01"), "yyyy-mm-dd");
		startMonthDate=form.selectedMonth&"-01";
		endDate=dateformat(dateadd("m", 1, form.selectedMonth), "yyyy-mm-dd")&" 00:00:00";
	}
	previousStartDate=dateformat(dateadd("yyyy", -1, startDate), "yyyy-mm-dd");
	previousStartMonthDate=dateformat(dateadd("yyyy", -1, startMonthDate), "yyyy-mm-dd");
	previousEndDate=dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd");
 

	db.sql="SELECT * FROM #db.table("inquiries_type", request.zos.zcoreDatasource)#
	WHERE  
	inquiries_type_deleted=#db.param(0)# and   
	site_id = #db.param(0)#";
	qType=db.execute("qType");
	for(row in qType){
		typeLookup[application.zcore.functions.zGetSiteIdType(row.site_id)&"-"&row.inquiries_type_id]=row.inquiries_type_name;
		typeIdLookup[row.inquiries_type_name]=row;
	} 

	db.sql="SELECT * FROM #db.table("inquiries_type", request.zos.zcoreDatasource)#
	WHERE  
	inquiries_type_deleted=#db.param(0)# and   
	site_id = #db.param(request.zos.globals.id)#";
	qType=db.execute("qType");
 
	for(row in qType){
		typeLookup[application.zcore.functions.zGetSiteIdType(row.site_id)&"-"&row.inquiries_type_id]=row.inquiries_type_name;
		typeIdLookup[row.inquiries_type_name]=row;
	}


	phonemonthStruct=typeIdLookup["Phone Call"];
	// get previous period

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(previousStartDate)# and 
	inquiries_datetime<#db.param(previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&=" GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qPreviousMonthTotal=db.execute("qPreviousMonthTotal"); 

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(previousStartDate)# and 
	inquiries_datetime<#db.param(previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(phonemonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(phonemonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qPreviousMonthPhone=db.execute("qPreviousMonthPhone"); 


	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(year(previousStartMonthDate)&"-01-01 00:00:00")# and 
	inquiries_datetime<#db.param(previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qPreviousYTDTotal=db.execute("qPreviousYTDTotal"); 

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(year(previousStartMonthDate)&"-01-01 00:00:00")# and 
	inquiries_datetime<#db.param(previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(phonemonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(phonemonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qPreviousYTDPhone=db.execute("qPreviousYTDPhone");



	// get current period
	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(startDate)# and 
	inquiries_datetime<#db.param(endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qMonthTotal=db.execute("qMonthTotal");  

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(startDate)# and 
	inquiries_datetime<#db.param(endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(phonemonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(phonemonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qMonthPhone=db.execute("qMonthPhone"); 


	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(year(startMonthDate)&"-01-01 00:00:00")# and 
	inquiries_datetime<#db.param(endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qYTDTotal=db.execute("qYTDTotal");

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(year(startMonthDate)&"-01-01 00:00:00")# and 
	inquiries_datetime<#db.param(endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(phonemonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(phonemonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qYTDPhone=db.execute("qYTDPhone"); 


	db.sql="SELECT  inquiries.inquiries_type_id, DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE   
	inquiries_deleted=#db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date";
	qMonth=db.execute("qMonth");
	
 
	monthStruct2={};
	monthStruct={};
	ytdStruct={
		total:0,
		phone:0
	};
	previousYtdStruct={
		total:0,
		phone:0
	};
	for(row in qMonthTotal){
		if(not structkeyexists(monthStruct, row.date)){
			monthStruct[row.date]={
				total:0,
				phone:0
			};
		} 
		monthStruct[row.date].total=row.count;
	}
	for(row in qMonthPhone){
		if(not structkeyexists(monthStruct, row.date)){
			monthStruct[row.date]={
				total:0,
				phone:0
			};
		} 
		monthStruct[row.date].phone=row.count;
		if(monthStruct[row.date].total EQ 0){
			monthStruct[row.date].total=monthStruct[row.date].phone;
		}
	}  
	for(row in qYTDTotal){ 
		ytdStruct.total=row.count;
	}
	for(row in qYTDPhone){
		ytdStruct.phone=row.count;
		if(ytdStruct.total EQ 0){
			ytdStruct.total=ytdStruct.phone;
		}
	}  

	if(form.yearToDateLeadLog EQ 0){
		for(row in qPreviousMonthTotal){
			if(not structkeyexists(monthStruct, row.date)){
				monthStruct[row.date]={
					total:0,
					phone:0
				};
			} 
			monthStruct[row.date].total=row.count;
		}
		for(row in qPreviousMonthPhone){
			if(not structkeyexists(monthStruct, row.date)){
				monthStruct[row.date]={
					total:0,
					phone:0
				};
			} 
			monthStruct[row.date].phone=row.count;
			if(monthStruct[row.date].total EQ 0){
				monthStruct[row.date].total=monthStruct[row.date].phone;
			}
		}  
	}
	for(row in qPreviousYTDTotal){ 
		previousYtdStruct.total=row.count;
	}
	for(row in qPreviousYTDPhone){
		previousYtdStruct.phone=row.count;
		if(previousYtdStruct.total EQ 0){
			previousYtdStruct.total=previousYtdStruct.phone;
		}
	}  

	arrStat=[];
	for(row in qMonthTotal){
		tempPreviousDate=dateformat(dateadd("yyyy", -1, row.date), "yyyy-mm");
		//if(dateformat(row.date, "mmmm") EQ dateformat(startMonthDate, "mmmm")){
			if(structkeyexists(monthStruct, tempPreviousDate)){
				ps=monthStruct[tempPreviousDate];
				cs=monthStruct[row.date]; 
				previousWebLeads=ps.total-ps.phone;
				webLeads=cs.total-cs.phone;
				if(ps.total NEQ 0 and ps.total<cs.total){
					percentIncrease=round(((cs.total-ps.total)/ps.total)*100);
					arrayAppend(arrStat, "There was a "&percentIncrease&"% increase in total leads in #dateformat(row.date, "mmmm")# compared to last year");
				}else if(ps.phone NEQ 0 and ps.phone<cs.phone){
					percentIncrease=round(((cs.phone-ps.phone)/ps.phone)*100);
					arrayAppend(arrStat, "There was a "&percentIncrease&"% increase in phone call leads in #dateformat(row.date, "mmmm")# compared to last year");
				}else if(previousWebLeads NEQ 0 and previousWebLeads<webLeads){
					percentIncrease=round(((webLeads-previousWebLeads)/previousWebLeads)*100);
					arrayAppend(arrStat, "There was a "&percentIncrease&"% increase in web form leads in #dateformat(row.date, "mmmm")# compared to last year");
				}
			}
			// calc year on year MONTHLY comparison percentages.

			// calc year on year YTD comparison percentages.
		//}
	} 
	previousYTDWebLeads=previousYtdStruct.total-previousYtdStruct.phone;
	yTDWebLeads=ytdStruct.total-ytdStruct.phone;
	if(previousYtdStruct.total NEQ 0 and previousYtdStruct.total<ytdStruct.total){
		percentIncrease=round(((ytdStruct.total-previousYtdStruct.total)/previousYtdStruct.total)*100);
		arrayAppend(arrStat, "There was a "&percentIncrease&"% increase in total leads year on year");
	}else if(previousYtdStruct.phone NEQ 0 and previousYtdStruct.phone<ytdStruct.phone){
		percentIncrease=round(((ytdStruct.phone-previousYtdStruct.phone)/previousYtdStruct.phone)*100);
		arrayAppend(arrStat, "There was a "&percentIncrease&"% increase in phone call leads year on year");
	}else if(previousYTDWebLeads NEQ 0 and previousYTDWebLeads<YTDwebLeads){
		percentIncrease=round(((YTDwebLeads-previousYTDWebLeads)/previousYTDWebLeads)*100);
		arrayAppend(arrStat, "There was a "&percentIncrease&"% increase in web form leads year on year");
	} 
	</cfscript>  

<cfsavecontent variable="htmlOut">
	
<html>
	<head>
		<title>Report</title>
	    <meta charset="utf-8" /> 
	    <link href="#request.zos.globals.domain#/z/fonts/stylesheet.css" type="text/css" rel="stylesheet" />
	<style type="text/css">
		body{font-family:'Open Sans', serif; line-height:1.3; font-size:13px; margin:0px;}
	h1,h2,h3,h4,h5, p, ul, ol{margin:0px; padding:0px; padding-bottom:20px;}
	h1{ font-size:30px;}
	h2{ margin-top:50px; font-size:24px;}
	h3{font-size:18px;}
	table{font-family:'Open Sans', serif; font-weight:normal;}

	.leadHeading{padding-top:20px;}
	.leadTable1{border-spacing:0px;
	width:100%;
	margin-bottom:20px;
		border-right:1px solid ##999;
		border-bottom:1px solid ##999;}
	.leadTable1 th{ text-align:left;}
	.leadTable1 th, .leadTable1 td{
		padding:3px;
		font-size:10px;
		line-height:1.3; 
		border:1px solid ##999;
		border-right:none;
		border-bottom:none;

	} 
	<cfif form.yearToDateLeadLog EQ 1>
		.leadTable1 th, .leadTable1 td{
		font-size:9px;
		}
	</cfif>
	*{-webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing:border-box;}
	.topFiveColor{background-color:##e9ea96;}
	.topTenColor{background-color:##96dcf8;}
	.topTwentyColor{background-color:##bacde4;}
	.topFiftyColor{background-color:##fbd57f;}
	.wrapper{  padding:20px; } 
	.print-footer {
	    text-align:right;
	    width: 100%;
	    float:left;
	    position: relative;
	    margin-top:-95px;
	    z-index:2;
	    margin-left:23px;
	    padding:45px;
	    padding-top:20px; 
	    padding-bottom:0px;
	    width:755px;
	} 
	.organicTrafficChart td{  font-size:13px; padding:5px;}
	.leadSummaryTable td{padding-right:50px; white-space:nowrap; }
	.tableOfContentsTable td{padding-right:50px; white-space:nowrap; }
	.main-header{
	margin-top:30px;
	position:relative;z-index:1; 
	width:100%; float:left;}
	<cfif structkeyexists(form, 'print')>
		.wrapper{padding:0px;max-width:8.5in;}
		.main-header{ margin-top:23px;margin:23px;  float:left; width:755px; border:1px solid ##000; padding:45px; padding-top:165px; height:985px; clear:both;  page-break-after: always; }
		<cfif not request.zos.istestserver and request.zos.marketingBgImageURL NEQ "">
			.main-header{background-image:url(#request.zos.marketingBgImageURL#); background-repeat:no-repeat; background-size:100% auto;}
		</cfif>
		.leadHeading{padding-top:0px;}
		.hide-on-print{display:none;}  
	<cfelse>
		##print-footer { display:none; }
		@media only print {
			.hide-on-print{display:none;}
			.page-break	{ display: block; page-break-before: always; }
		}
	</cfif>
	</style>
</head>
<body>

<div class="wrapper">
	<div class="hide-on-print">
		<cfscript>
		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		site_deleted=#db.param(0)# ";
		qSite=db.execute("qSite");

		request.footerDomain=qSite.site_short_domain;
		if(qSite.site_semrush_domain NEQ ""){
			request.footerDomain=qSite.site_semrush_domain;
		}
		if(qSite.site_report_company_name NEQ ""){
			request.footerDomain=qSite.site_report_company_name;
		}

		arrExcludeList=listToArray(qSite.site_google_analytics_exclude_keyword_list, ",");
		arrayAppend(arrExcludeList, '(not provided)');
		arrayAppend(arrExcludeList, '(not set)');
		arrayAppend(arrExcludeList, 'sharebutton');

		arrDisable=[];
		for(i in request.disableContentSection){
			if(request.disableContentSection[i]){
				arrayAppend(arrDisable, i);
			}
		}
		</cfscript>
		<div>
			<div style="width:50%; float:left;">
				<a href="##generatedInfo">Learn How This Report Was Generated</a> 
			</div>
			<div style="width:50%; float:left;">
				<form action="/z/inquiries/admin/custom-lead-report/index" method="get">
				<p style="text-align:right;">Select Month: 
				<input type="month" name="selectedMonth" value="#dateformat(form.selectedMonth, "yyyy-mm")#"> 
				<input type="submit" name="select1" value="Select"> | 
				<a href="#request.zos.originalURL#?selectedMonth=#form.selectedMonth#&amp;print=1&amp;yearToDateLeadLog=#form.yearToDateLeadLog#&amp;disableSection=#urlencodedformat(arrayToList(arrDisable, ","))#" target="_blank">View {totalPageCount} Page PDF</a></p>
				</form>

			</div>
		</div>
		<div class="uptodateDiv"><p style="font-size:18px; font-weight:bold; color:##FF0000;">This report has data sources that are not up to date for the selected month<br>
			See data integration status at the bottom of report for more information</p></div>
		<cfscript> 
		if(not isValidMonth(request.selectedMonth)){
			echo('<div><p style="font-size:18px; font-weight:bold; color:##FF0000;">There is no data available for this month.</p></div>');
		}
		</cfscript>
	</div>
	<div class="main-header">
		<p style="font-size:36px; color:##999; padding-bottom:0px;  margin-top:0px;">#request.footerDomain#</p>
		<cfif form.yearToDateLeadLog EQ 1>
			<p style="font-size:24px; font-weight:bold; padding-top:0px;">January to #dateformat(request.selectedMonth, "mmmm yyyy")#<br>
			Search Engine Marketing Report</p> 
		<cfelse>
			<p style="font-size:24px; font-weight:bold; padding-top:0px;">#dateformat(form.selectedMonth, "mmmm yyyy")# Search Engine Marketing Report</p> 
		</cfif>
	
		<h2 style="font-weight:normal;">Table Of Contents</h2>
		<form action="#request.zos.originalURL#" method="get">
		<table class="tableOfContentsTable">
			<tr style="{SummaryStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="Summary" <cfif request.disableContentSection.Summary>checked="checked"</cfif>></td> 
				<td>Website Leads</td><td>{SummaryPageNumber}</td></tr>
			<tr style="{LeadComparisonStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="LeadComparison" <cfif request.disableContentSection.LeadComparison>checked="checked"</cfif>></td>
				<td>Lead Comparison</td><td>{LeadComparisonPageNumber}</td></tr>
			<tr style="{TopVerifiedRankingsStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="TopVerifiedRankings" <cfif request.disableContentSection.TopVerifiedRankings>checked="checked"</cfif>></td>
				<td>Top Verified Keyword Rankings</td><td>{TopVerifiedRankingsPageNumber}</td></tr>
			<tr style="{VerifiedRankingsStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="VerifiedRankings" <cfif request.disableContentSection.VerifiedRankings>checked="checked"</cfif>></td>
				<td>Verified Keyword Ranking Results</td><td>{VerifiedRankingsPageNumber}</td></tr>
			<tr style="{OrganicSearchStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="OrganicSearch" <cfif request.disableContentSection.OrganicSearch>checked="checked"</cfif>></td>
				<td>Incoming Organic Search Traffic</td><td>{OrganicSearchPageNumber}</td></tr>
			<tr style="{leadTypeSummaryStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="leadTypeSummary" <cfif request.disableContentSection.leadTypeSummary>checked="checked"</cfif>></td>
				<td>Lead Summary By Type</td><td>{leadTypeSummaryPageNumber}</td></tr>
			<tr style="{PhoneLogStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="PhoneLog" <cfif request.disableContentSection.PhoneLog>checked="checked"</cfif>></td>
				<td>Phone Call Lead Log</td><td>{PhoneLogPageNumber}</td></tr>
			<tr style="{WebLeadLogStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="WebLeadLog" <cfif request.disableContentSection.webLeadLog>checked="checked"</cfif>></td>
				<td>Web Form Lead Log</td><td>{WebLeadLogPageNumber}</td></tr> 
		</table>
		<div class="hide-on-print" style="padding-top:20px;">
			<input type="hidden" name="selectedMonth" value="#htmleditformat(form.selectedMonth)#">
			<p>Date Range: 
			<input type="radio" name="yearToDateLeadLog" value="1" <cfif form.yearToDateLeadLog EQ 1>checked="checked"</cfif>> 
			January 1st to End of Selected Month
			<input type="radio" name="yearToDateLeadLog" value="0" <cfif form.yearToDateLeadLog EQ 0>checked="checked"</cfif>> 
			Selected Month</p>
			<p><input type="submit" name="submit1" value="Update Report">
			<input type="button" name="submit2" value="Reset" onclick="window.location.href='#request.zos.originalURL#';"></p>
		</div>
		<cfscript>
		for(i in request.disableContentSection){
			if(request.disableContentSection[i]){
				echo('<input type="hidden" name="disableSection" value="#i#">');
			}
		}
		</cfscript>
		</form>


 		<cfif not request.disableContentSection["Summary"]>
 			#showFooter()#
			<cfscript>
			request.contentSection.Summary=request.pageCount; 
			</cfscript>

			<h2 style="margin-top:0px;">Website Leads</h2>
			<p>We are tracking conversions from your website through phone calls and contact form leads. 
			Below are the conversions from the month of #dateformat(form.selectedMonth, "mmmm")#:</p>
			<table class="leadSummaryTable ">
				<cfif form.yearToDateLeadLog EQ 1>
					<cfscript>
					totalCalls=0;
					totalForms=0;
					totalLeads=0;
					for(i in monthStruct){
						v=monthStruct[i];
						totalCalls+=v.phone;
						totalForms+=v.total-v.phone;
						totalLeads+=v.total;
					}
					</cfscript>
						<tr>
							<td style="width:1%; white-space:nowrap;">Phone Calls:</td>
							<td>#totalCalls#</td>
						</tr>
						<tr>
							<td style="width:1%; white-space:nowrap;">Contact Form Leads:</td>
							<td>#totalForms#</td>
						</tr>
						<tr>
							<td style="width:1%; white-space:nowrap;">Total Leads:</td>
							<td>#totalLeads#</td>
						</tr>
				<cfelse>
					<cfif structkeyexists(monthStruct, dateformat(startMonthDate, "yyyy-mm"))>
						
						<tr>
							<td style="width:1%; white-space:nowrap;">Phone Calls:</td>
							<td>#monthStruct[dateformat(startMonthDate, "yyyy-mm")].phone#</td>
						</tr>
						<tr>
							<td style="width:1%; white-space:nowrap;">Contact Form Leads:</td>
							<td>#monthStruct[dateformat(startMonthDate, "yyyy-mm")].total-monthStruct[dateformat(startMonthDate, "yyyy-mm")].phone#</td>
						</tr>
						<tr>
							<td style="width:1%; white-space:nowrap;">Total Leads:</td>
							<td>#monthStruct[dateformat(startMonthDate, "yyyy-mm")].total#</td>
						</tr>
					<cfelse>
						<tr>
							<td style="width:1%; white-space:nowrap;">Phone Calls:</td>
							<td>0</td>
						</tr>
						<tr>
							<td style="width:1%; white-space:nowrap;">Contact Form Leads:</td>
							<td>0</td>
						</tr>
						<tr>
							<td style="width:1%; white-space:nowrap;">Total Leads:</td>
							<td>0</td>
						</tr>
					</cfif> 
					<tr>
						<td style="width:1%; white-space:nowrap;">Total Leads Year to Date:</td>
						<td>#ytdStruct.total#</td>
					</tr>
				</cfif>
			</table>
		
			<cfscript>
			if(form.yearToDateLeadLog EQ 0){
				if(arrayLen(arrStat)){
					echo('<h2>Lead Highlights</h2>');
					for(stat in arrStat){
						echo('<h4>#stat#</h4>');
					}
				}
			}
			</cfscript> 
		</cfif>

 		<cfif not request.disableContentSection["LeadComparison"]> 
			<cfscript>
			showFooter();  
			request.contentSection.LeadComparison=request.pageCount;
			</cfscript>
			<h2 style="margin-top:0px;">Lead Comparison Report</h2>
			<cfif form.yearToDateLeadLog EQ 1>
				<h3>January to #dateFormat(dateadd("m", -1, endDate), "mmmm")# Leads</h3>
			<cfelse>
				<h3>#dateformat(startDate, "mmmm")# through #dateformat(startMonthDate, "mmmm")# Monthly Leads</h3>
			</cfif>
			<table style="border-spacing:0px;" class="leadTable1">
				<tr> 
					<th style="width:1%; white-space:nowrap;">&nbsp;</th>
					<cfscript> 
					arrMonth=structkeyarray(monthStruct);
					arraySort(arrMonth, "text", "asc");
					for(month in arrMonth){
						echo('<th>#dateformat(month, "mmm yyyy")#</th>');
					}
					</cfscript> 
				</tr> 
				<cfscript>
				echo('<tr>');
				echo('<td style="width:1%; white-space:nowrap;">Web Leads</td>');
				for(month in arrMonth){ 
					echo('<td>#monthStruct[month].total-monthStruct[month].phone#</td>');
				}
				echo('</tr><tr>');
				echo('<td style="width:1%; white-space:nowrap;">Phone Leads</td>');
				for(month in arrMonth){ 
					echo('<td>#monthStruct[month].phone#</td>');
				}
				echo('</tr><tr>');
				echo('<td style="width:1%; white-space:nowrap;">Total Leads</td>');
				for(month in arrMonth){ 
					echo('<td>#monthStruct[month].total#</td>');
				}
				echo('</tr>');
				</cfscript>  
			</table>  

			<h3>Year To Date Total Leads</h3>
			<table style="border-spacing:0px;" class="leadTable1">
				<tr> 
					<th style="width:1%; white-space:nowrap;">&nbsp;</th>
					<cfif isValidMonth(previousStartMonthDate)> 
						<th>#year(previousStartMonthDate)#</th>
					</cfif>
					<th>#year(startMonthDate)#</th>
				</tr> 
				<cfscript>
				echo('<tr>');
				echo('<td style="width:1%; white-space:nowrap;">Web Leads</td>');
				if(isValidMonth(previousStartMonthDate)){
					echo('<td>#previousYtdStruct.total-previousYtdStruct.phone#</td>');
				}
				echo('<td>#ytdStruct.total-ytdStruct.phone#</td>');
				echo('</tr><tr>');
				echo('<td style="width:1%; white-space:nowrap;">Phone Leads</td>');
				if(isValidMonth(previousStartMonthDate)){
					echo('<td>#previousYtdStruct.phone#</td>');
				}
				echo('<td>#ytdStruct.phone#</td>');
				echo('</tr><tr>');
				echo('<td style="width:1%; white-space:nowrap;">Total Leads</td>');
				if(isValidMonth(previousStartMonthDate)){
					echo('<td>#previousYtdStruct.total#</td>');
				}
				echo('<td>#ytdStruct.total#</td>');
				echo('</tr>');
		 
				</cfscript>  
			</table>   
 
		</cfif>

		<cfscript>

		vs={};
		ks={};

		db.sql="select *,
		DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#) date, 
		min(keyword_ranking_position) topPosition, 
		max(keyword_ranking_search_volume) highestSearchVolume
		from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE 
		keyword_ranking_run_datetime>=#db.param(startDate)# and 
		keyword_ranking_run_datetime<#db.param(endDate)# and 
		
		site_id = #db.param(request.zos.globals.id)# and 
		keyword_ranking_deleted=#db.param(0)# ";
		filterOtherTableSQL(db, "keyword_ranking_run_datetime");
		db.sql&="
		GROUP BY DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#), keyword_ranking_keyword";
		qKeyword=db.execute("qKeyword"); //keyword_ranking_position<>#db.param(0)# and 

		// TODO also need the previous search too qPreviousKeyword, etc
		db.sql="select *,
		DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#) date, 
		min(keyword_ranking_position) topPosition, 
		max(keyword_ranking_search_volume) highestSearchVolume 
		from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE 
		keyword_ranking_run_datetime>=#db.param(previousStartDate)# and 
		keyword_ranking_run_datetime<#db.param(previousEndDate)# and 
		
		site_id = #db.param(request.zos.globals.id)# and 
		keyword_ranking_deleted=#db.param(0)# ";
		filterOtherTableSQL(db, "keyword_ranking_run_datetime");// keyword_ranking_position<>#db.param(0)# and 
		db.sql&="
		GROUP BY DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#), keyword_ranking_keyword";
		qPreviousKeyword=db.execute("qPreviousKeyword");

		db.sql="select 
		DATE_FORMAT(min(keyword_ranking_run_datetime), #db.param('%Y-%m')#) date 
		from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE  
		
		site_id = #db.param(request.zos.globals.id)# and 
		keyword_ranking_deleted=#db.param(0)# ";
		filterOtherTableSQL(db, "keyword_ranking_run_datetime"); //keyword_ranking_position<>#db.param(0)# and 
		qFirstKeyword=db.execute("qFirstKeyword");
		if(qFirstKeyword.recordcount){
			db.sql="select *,
			DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#) date, 
			min(keyword_ranking_position) topPosition, 
			max(keyword_ranking_search_volume) highestSearchVolume
			from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE 
			
			keyword_ranking_run_datetime>=#db.param(qFirstKeyword.date&"-01 00:00:00")# and 
			keyword_ranking_run_datetime<#db.param(dateformat(dateadd("m", 1, qFirstKeyword.date&"-01"), "yyyy-mm-dd")&" 00:00:00")# and 
			site_id = #db.param(request.zos.globals.id)# and 
			keyword_ranking_deleted=#db.param(0)# ";
			filterOtherTableSQL(db, "keyword_ranking_run_datetime");//keyword_ranking_position<>#db.param(0)# and 
			db.sql&="
			GROUP BY DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#), keyword_ranking_keyword";
			qFirstRankKeyword=db.execute("qFirstRankKeyword");
			for(row in qFirstRankKeyword){
				if(not structkeyexists(ks, row.date)){
					ks[row.date]={};
				}
				ks[row.date][row.keyword_ranking_keyword]=row.topPosition;
				if(not structkeyexists(vs, row.keyword_ranking_keyword)){
					vs[row.keyword_ranking_keyword]=0;
				}
				if(row.highestSearchVolume > vs[row.keyword_ranking_keyword]){
					vs[row.keyword_ranking_keyword]=row.highestSearchVolume;
				}
			} 
		}
		keywordVolumeSortStruct={};
		uniqueKeyword={};
		count=0;
		for(row in qKeyword){
			if(not structkeyexists(ks, row.date)){
				ks[row.date]={};
			}
			ks[row.date][row.keyword_ranking_keyword]=row.topPosition;
			if(not structkeyexists(vs, row.keyword_ranking_keyword)){
				vs[row.keyword_ranking_keyword]=0;
			}
			if(row.highestSearchVolume > vs[row.keyword_ranking_keyword]){
				vs[row.keyword_ranking_keyword]=row.highestSearchVolume;
			}
			if(not structkeyexists(uniqueKeyword, row.keyword_ranking_keyword)){
				uniqueKeyword[row.keyword_ranking_keyword]=true;
				keywordVolumeSortStruct[count]={
					keyword:row.keyword_ranking_keyword,
					volume:vs[row.keyword_ranking_keyword]
				}
			}
			count++;
		} 
		count=0;

		for(row in qPreviousKeyword){
			if(form.yearToDateLeadLog EQ 0){
				if(not structkeyexists(ks, row.date)){
					ks[row.date]={};
				}
				ks[row.date][row.keyword_ranking_keyword]=row.topPosition;
				if(not structkeyexists(vs, row.keyword_ranking_keyword)){
					vs[row.keyword_ranking_keyword]=0;
				}
				if(row.highestSearchVolume > vs[row.keyword_ranking_keyword]){
					vs[row.keyword_ranking_keyword]=row.highestSearchVolume;
				}
			}
			if(not structkeyexists(uniqueKeyword, row.keyword_ranking_keyword)){
				uniqueKeyword[row.keyword_ranking_keyword]=true;
				keywordVolumeSortStruct[count]={
					keyword:row.keyword_ranking_keyword,
					volume:vs[row.keyword_ranking_keyword]
				}
			}
			count++;
		} 
		arrVolumeSort=structsort(keywordVolumeSortStruct, "numeric", "desc", "volume"); 
		for(date in ks){
			cs=ks[date];
			for(keyword in cs){
				kw[keyword]=true;
			}
		}
		arrKeyword=[];
		arrKeywordDate=structkeyarray(ks);
		if(qKeyword.recordcount NEQ 0 or qPreviousKeyword.recordcount NEQ 0){
			arraySort(arrKeywordDate, "text", "asc");
			keywordSortStruct={};
			ts=ks[arrKeywordDate[arraylen(arrKeywordDate)]];
			count=0;
			for(keyword in ts){
				keywordSortStruct[count]={keyword:keyword, position:ts[keyword]};
				if(keywordSortStruct[count].position EQ 0){
					keywordSortStruct[count].position=1000;
				}
				count++; 
			}
			arrKey=structsort(keywordSortStruct, "numeric", "asc", "position");
			for(i in arrKey){
				arrayAppend(arrKeyword, keywordSortStruct[i].keyword);
			}
		}
		</cfscript>

 		<cfif not request.disableContentSection["TopVerifiedRankings"]> 
			
			<cfif qKeyword.recordcount NEQ 0 or qPreviousKeyword.recordcount NEQ 0>
			
				<cfscript>
				showFooter();  
				request.contentSection.TopVerifiedRankings=request.pageCount; 
				</cfscript>
				<cfsavecontent variable="tableHead">  
					<h2 style="margin-top:0px;">Top Verified Keyword Google Rankings</h2>
					<table class="keywordTable1 leadTable1">
						<tr>
							<th style="width:1%; white-space:nowrap;">Keyword</th>
							<cfscript>
							for(date in arrKeywordDate){
								if(isValidMonth(date)){
									echo('<th>#dateformat(date, "mmm yyyy")#</th>');
								}
							}
							</cfscript>
							<!--- <th>Search Volume</th> --->
						</tr>
				</cfsavecontent>
					<cfscript> 
					echo(tableHead);
					count=0;
					// need to implement page breaks here..
					for(i=1;i LTE arrayLen(arrKeyword);i++){
						keyword=arrKeyword[i];
						if(count > request.rowLimit){
							if(structkeyexists(form, 'print')){
								echo('</table>');
								showFooter();
								echo(tableHead);
							}else{
								request.pagecount++;
							}
							count=0;
						}
						topKeyword=false;
						savecontent variable="keyOut"{
							echo('<tr>');
							echo('<th style="width:1%; white-space:nowrap;">#keyword#</th>');
							for(n=1;n<=arrayLen(arrKeywordDate);n++){
								date=arrKeywordDate[n];
								if(not isValidMonth(date)){
									continue;
								}
								if(structkeyexists(ks, date) and structkeyexists(ks[date], keyword)){
									position=ks[date][keyword];
									if(position EQ 0){
										position=1000;
									}
									if(arrayLen(arrKeywordDate) EQ n){
										if(position<51){
											topKeyword=true;
										}
										if(position < 6){
											className="topFiveColor";
										}else if(position < 11){
										 	className="topTenColor";
										}else if(position < 21){
											className="topTwentyColor";
										}else if(position <51){
											className="topFiftyColor";
										}else{
											echo('<td>&nbsp;</td>');// style="background-color:##CCC;"
											continue;
										}
									}else{ 
										className="";
									}
									if(position EQ 1000 or position EQ 0){ 
										echo('<td>&nbsp;</td>');// style="background-color:##CCC;"
									}else{
										echo('<td class="#className#">#position#</td>');
									}
								}else{
									echo('<td>&nbsp;</td>');// style="background-color:##CCC;"
								}
							}
							// need to get this from manual data entry
							//echo('<td>#vs[keyword]#</td>');
							echo('</tr>');
						}
						if(topKeyword){
							echo(keyOut);
							count++;
						}
					}
					</cfscript>
				</table> 
				<cfscript>
				if(count>request.rowLimit-7){ 
					showFooter(); 
					echo('<h2 style="margin-top:0px;">Top Verified Keyword Google Rankings</h2>');
					count=0;
				}
				</cfscript>
				<div style="width:100%; float:left;">
					<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topFiveColor">Top Five (1st Page)</div> 
					<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topTenColor">Top Ten (1st Page)</div>  
					<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topTwentyColor">Top Twenty (2nd Page)</div> 
					<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topFiftyColor">Top 50</div>  
				</div>
				<p>This is your current ranking position for your targeted keywords on Google Search. Page rankings 1 through 10 appear on the first results page, 11 through 20 on the second, etc. Our goal is first page placement for all of your targeted keywords.  Search volume varies over time.</p> 
 
			</cfif>
			


	 		<cfif not request.disableContentSection["VerifiedRankings"] and arrayLen(arrVolumeSort)> 
				<cfsavecontent variable="tableHead">  
					<h2 style="margin-top:0px;">Verified Google Keyword Ranking Results</h2>
					<table class="keywordTable1 leadTable1">
						<tr>
							<th style="width:1%; white-space:nowrap;">Keyword</th>
							<cfscript>
							for(date in arrKeywordDate){
								if(isValidMonth(date)){
									echo('<th>#dateformat(date, "mmm yyyy")#</th>');
								}
							}
							</cfscript>
							<th>Search Volume</th>
						</tr>
				</cfsavecontent>
				<cfscript> 
				showFooter();  
				request.contentSection.VerifiedRankings=request.pageCount; 
				echo(tableHead);
				count=0;
				// need to implement page breaks here..
				for(i=1;i LTE arrayLen(arrVolumeSort);i++){
					keyword=keywordVolumeSortStruct[arrVolumeSort[i]].keyword;
					if(count > request.rowLimit){
						if(structkeyexists(form, 'print')){
							echo('</table>');
							showFooter();
							echo(tableHead);
						}else{
							request.pagecount++;
						}
						count=0;
					}
					echo('<tr>');
					echo('<th style="width:1%; white-space:nowrap;">#keyword#</th>');
					for(n=1;n<=arrayLen(arrKeywordDate);n++){
						date=arrKeywordDate[n];
						if(not isValidMonth(date)){	
							continue;
						}
						if(structkeyexists(ks, date) and structkeyexists(ks[date], keyword)){
							position=ks[date][keyword];
							if(position EQ 0){
								position=1000;
							} 
							if(position EQ 1000 or position EQ 0){ 
								echo('<td >&nbsp;</td>');//style="background-color:##CCC;"
							}else{
								echo('<td>#position#</td>');
							}
						}else{
							echo('<td>&nbsp;</td>'); //  style="background-color:##CCC;"
						}
					}
					// need to get this from manual data entry
					echo('<td>#vs[keyword]#</td>');
					echo('</tr>');
					count++;
				}
				</cfscript>
				</table>  
			</cfif>
		</cfif> 

 		<cfif not request.disableContentSection["OrganicSearch"]> 
			<cfscript> 

			db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			ga_month_type=#db.param(2)# and 
			ga_month_deleted=#db.param(0)# and ";
			if(form.yearToDateLeadLog EQ 1){
				db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd"))# and ";
			}else{
				db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("m", -1, endDate), "yyyy-mm-dd"))# and ";
			}
			db.sql&=" ga_month_date<#db.param(endDate)# ";
			filterOtherTableSQL(db, "ga_month_date"); 
			qOrganicTraffic=db.execute("qOrganicTraffic");  
		 
			db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			ga_month_type=#db.param(2)# and 
			ga_month_deleted=#db.param(0)# and ";
			if(form.yearToDateLeadLog EQ 1){
				db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("yyyy", -2, endDate), "yyyy-mm-dd"))# and
				ga_month_date<#db.param(dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd"))#  ";
			}else{
				db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("yyyy", -1, dateadd("m", -1, endDate)), "yyyy-mm-dd"))# and  
				ga_month_date<#db.param(dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd"))#";
			}  
			qPreviousOrganicTraffic=db.execute("qPreviousOrganicTraffic");  

			db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			ga_month_keyword_deleted=#db.param(0)# and ";
			if(form.yearToDateLeadLog EQ 1){
				db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd"))# and ";
			}else{
				db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("m", -1, endDate), "yyyy-mm-dd"))# and ";
			}
			db.sql&="
			ga_month_keyword_date<#db.param(endDate)# ";
			filterOtherTableSQL(db, "ga_month_keyword_date");
			qKeyword=db.execute("qKeyword"); 

			db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			ga_month_keyword_deleted=#db.param(0)# and ";
			if(form.yearToDateLeadLog EQ 1){
				db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("yyyy", -2, endDate), "yyyy-mm-dd"))# and ";
			}else{
				db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("yyyy", -1, dateadd("m", -1, endDate)), "yyyy-mm-dd"))# and  ";
			}
			db.sql&="
			ga_month_keyword_date<#db.param(dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd"))# ";  
			filterOtherTableSQL(db, "ga_month_keyword_date");
			qPreviousKeyword=db.execute("qPreviousKeyword"); 
			ks={};
			ksp={};
			count=0; 
			for(row in qKeyword){
				count++;
				skip=false;
				for(phrase in arrExcludeList){
					if(row.ga_month_keyword_keyword CONTAINS phrase){
						skip=true;
						break;
					}
				}
				if(skip){
					continue;
				}
				ts={
					visits:row.ga_month_keyword_visits, 
					keyword:row.ga_month_keyword_keyword 
				}; 
				ks[count]=ts;
			} 
			count=0;
			for(row in qPreviousKeyword){
				count++;
				skip=false;
				for(phrase in arrExcludeList){
					if(row.ga_month_keyword_keyword CONTAINS phrase){
						skip=true;
						break;
					}
				}
				if(skip){
					continue;
				}
				ts={
					visits:row.ga_month_keyword_visits, 
					keyword:row.ga_month_keyword_keyword 
				}; 
				ksp[count]=ts;
			}  
			arrKeywordSort=structsort(ks, "numeric", "desc", "visits");  
			arrPreviousKeywordSort=structsort(ksp, "numeric", "desc", "visits");  
			</cfscript> 
			<cfif qKeyword.recordcount or qPreviousKeyword.recordcount> 
				<cfscript>
				showFooter(); 
				request.contentSection.OrganicSearch=request.pageCount; 
				</cfscript>

				<h2 style="margin-top:0px;">Incoming Organic Search Traffic</h2>
				<cfscript> 

				/*db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				ga_month_type=#db.param(2)# and 
				ga_month_deleted=#db.param(0)# and 
				ga_month_date>=#db.param(dateformat(dateadd("m", -2, endDate), "yyyy-mm-dd"))# and 
				ga_month_date<#db.param(dateformat(dateadd("m", -1, endDate), "yyyy-mm-dd"))# ";  
				qPreviousMonthOrganicTraffic=db.execute("qPreviousMonthOrganicTraffic");  */ 
				db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				ga_month_type=#db.param(2)# and 
				ga_month_deleted=#db.param(0)# and 
				ga_month_date>=#db.param(dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd"))# and 
				ga_month_date<#db.param(endDate)# ";
				filterOtherTableSQL(db, "ga_month_date");
				db.sql&=" 
				ORDER BY ga_month_date ASC";  
				qOrganicTrafficAnnual=db.execute("qOrganicTrafficAnnual");   
				echo('<p>This data includes traffic from Google, Bing, Yahoo and other search engines.</p>');
				echo('<h3>Visits by Month This Year</h3>');
				echo('<table class="leadTable1 organicTrafficChart">');
				echo('<tr>');
				for(row in qOrganicTrafficAnnual){
					if(isValidMonth(row.ga_month_date)){	
					echo('<td>#dateformat(row.ga_month_date, "mmm yy")#</td>');
					}

				}
				echo('</tr>');
				echo('<tr>');
				for(row in qOrganicTrafficAnnual){
					if(isValidMonth(row.ga_month_date)){	
						echo('<td>#row.ga_month_visits#</td>');
					}

				}
				echo('</tr>');
				echo('</table>');


				db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				ga_month_type=#db.param(2)# and 
				ga_month_deleted=#db.param(0)# and 
				ga_month_date>=#db.param(dateformat(dateadd("yyyy", -2, endDate), "yyyy-mm-dd"))# and 
				ga_month_date<#db.param(dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd"))#  ";
				filterOtherTableSQL(db, "ga_month_date");
				db.sql&=" 
				ORDER BY ga_month_date ASC";  
				qOrganicTrafficAnnual2=db.execute("qOrganicTrafficAnnual");  

				echo('<h3>Visits by Month Last Year</h3>');
				echo('<table class="leadTable1 organicTrafficChart">');
				echo('<tr>');
				for(row in qOrganicTrafficAnnual2){
					if(isValidMonth(row.ga_month_date)){	
						echo('<td>#dateformat(row.ga_month_date, "mmm yy")#</td>');
					}

				}
				echo('</tr>');
				echo('<tr>');
				for(row in qOrganicTrafficAnnual2){
					if(isValidMonth(row.ga_month_date)){	
						echo('<td>#row.ga_month_visits#</td>');
					}

				}
				echo('</tr>');
				echo('</table>');
				</cfscript>
				<h3>Top 10 Google Keywords Generating Website Traffic</h3>
				<div style=" ">
					<div style="width:50%; padding-right:5%; float:left;">
						<h3>
							<cfif form.yearToDateLeadLog EQ 1>
								Jan to #dateformat(dateadd("m", -1, previousEndDate), "mmm yyyy")# -
							<cfelse>
								#dateformat(previousStartMonthDate, "mmmm yyyy")# - 
							</cfif>

						<cfif qPreviousOrganicTraffic.recordcount>
							<cfscript>
							visits=0;
							for(row in qPreviousOrganicTraffic){
								visits+=qPreviousOrganicTraffic.ga_month_visits;
							}
							</cfscript>
							#visits#
						<cfelse>
							0
						</cfif> Visits</h3>
						<table class="keywordTable1 leadTable1">
							<tr>
								<th style="width:1%; white-space:nowrap;">&nbsp;</th> 
								<th >Google Keyword Phrase</th>   
							</tr>
							<cfscript>
							for(i=1;i<=min(10, arraylen(arrPreviousKeywordSort));i++){
								ts=ksp[arrPreviousKeywordSort[i]];
								echo('<tr><td>#i#</td><td>#ts.keyword#</td></tr>');
							}
							</cfscript>
						</table>
					</div>
					<div style="width:50%;padding-right:5%; float:left;">
						<h3>
							<cfif form.yearToDateLeadLog EQ 1>
								Jan to #dateformat(dateadd("m", -1, endDate), "mmm yyyy")# -
							<cfelse>
								#dateformat(startMonthDate, "mmmm yyyy")# - 
							</cfif>
						<cfif qOrganicTraffic.recordcount>
							<cfscript>
							visits=0;
							for(row in qOrganicTraffic){
								visits+=qOrganicTraffic.ga_month_visits;
							}
							</cfscript>
							#visits# 
						<cfelse>
							0
						</cfif> Visits</h3>
						<table class="keywordTable1 leadTable1">
							<tr>
								<th style="width:1%; white-space:nowrap;">&nbsp;</th> 
								<th >Google Keyword Phrase</th>   
							</tr>
							<cfscript>
							for(i=1;i<=min(10, arraylen(arrKeywordSort));i++){
								ts=ks[arrKeywordSort[i]];
								echo('<tr><td>#i#</td><td>#ts.keyword#</td></tr>');
							}
							</cfscript>
						</table>
					</div>
				</div>  
				<!--- <p>These are the top keyword searches on Google that led visitors to your website in the month of #dateformat(form.selectedMonth, "mmmm yyyy")# not including your name or company name.</p> --->

				<cfscript>
				if(qPreviousOrganicTraffic.recordcount and qOrganicTraffic.recordcount){
					if(isValidMonth(qPreviousOrganicTraffic.ga_month_date)){	
						v=round(((qOrganicTraffic.ga_month_visits-qPreviousOrganicTraffic.ga_month_visits)/qPreviousOrganicTraffic.ga_month_visits)*100);
						if(v>0){
							echo('<p style="font-weight:bold;">'&v&'% increase in organic traffic year over year</p>'); 
						}
					}
				}
				/*if(qPreviousMonthOrganicTraffic.recordcount and qPreviousMonthOrganicTraffic.recordcount){
					v=round(((qOrganicTrafficAnnual.ga_month_visits[qOrganicTrafficAnnual.recordcount]-qPreviousMonthOrganicTraffic.ga_month_visits)/qPreviousMonthOrganicTraffic.ga_month_visits)*100);
					if(v>0){
						echo('<p style="font-weight:bold;">'&v&'% increase in organic traffic this month</p>'); 
					}
				}*/
				</cfscript>
			</cfif>
 
		</cfif>

	 

		<cfscript>
		webFormOut="";
		phoneLogOut=""; 
		if(not request.disableContentSection["leadTypeSummary"]){
			savecontent variable="footerSummaryOut"{
				showFooter();
				request.contentSection.leadTypeSummary=request.pageCount; 
			}
		}
		db.sql="SELECT 
		*
		FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
		WHERE 
		inquiries_datetime>=#db.param(startMonthDate)# and 
		inquiries_datetime<#db.param(endDate)# and 
		inquiries_deleted=#db.param(0)# and  
		inquiries_type_id=#db.param(phonemonthStruct.inquiries_type_id)# and 
		inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(phonemonthStruct.site_id))# and 
		inquiries.site_id = #db.param(request.zos.globals.id)#"; 
		filterInquiryTableSQL(db);
		db.sql&="
		ORDER BY inquiries_datetime ASC ";
		qPhone=db.execute("qPhone");


		db.sql="SELECT 
		*
		FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
		WHERE 
		inquiries_datetime>=#db.param(startMonthDate)# and 
		inquiries_datetime<#db.param(endDate)# and 
		inquiries_deleted=#db.param(0)# and  
		concat(inquiries_type_id, #db.param('-')#, inquiries_type_id_siteIDType) <> 
		#db.param(phonemonthStruct.inquiries_type_id&'-'&application.zcore.functions.zGetSiteIdType(phonemonthStruct.site_id))# and 
		inquiries.site_id = #db.param(request.zos.globals.id)#"; 
		filterInquiryTableSQL(db);
		db.sql&="
		ORDER BY inquiries_datetime ASC ";
		qWebLead=db.execute("qWebLead");
		phoneGroup={};
		phoneGroupOffset={};
		webFormGroup={};
		webFormGroupOffset={};
		count=0;
		for(row in qPhone){
			js=deserializeJson(row.inquiries_custom_json);
			fs={
				"name":"",
				"Phone 1":"",
				"source":"",
				"city":"",
				"tracking_label":"",
				"called_at":""
			};
			for(field in js.arrCustom){
				fs[field.label]=field.value;
			}
			label=application.zcore.functions.zLimitStringLength(fs.tracking_label, 60);
			if(not structkeyexists(phoneGroupOffset, label)){
				phoneGroupOffset[label]=count;
				phoneGroup[count]={
					label:label,
					count:0
				};
			}
			phoneGroup[phoneGroupOffset[label]].count++;
			count++;
		}

		count=0;
		for(row in qWebLead){
			v=row.inquiries_type_id_siteIDType&"-"&row.inquiries_type_id;
			if(structkeyexists(typeLookup, v)){
				inquiries_type_name=typeLookup[v];
			
				if(not structkeyexists(webFormGroupOffset, inquiries_type_name)){
					webFormGroupOffset[inquiries_type_name]=count;
					webFormGroup[count]={
						label:inquiries_type_name,
						count:0
					};
				}
				webFormGroup[webFormGroupOffset[inquiries_type_name]].count++;
			}else{
				if(not structkeyexists(webFormGroupOffset, "(No Label)")){
					webFormGroupOffset["(No Label)"]=count;
					webFormGroup[count]={
						label:"(No Label)",
						count:0
					}
				}
				webFormGroup[webFormGroupOffset["(No Label)"]].count++;
			}
			count++;
		}
		</cfscript>
 		<cfif not request.disableContentSection["PhoneLog"]> 
			<!--- list out all phone call leads individually for the selected month  --->
			

			<cfsavecontent variable="phoneLogOut">
				<cfif qPhone.recordcount>  
					
					<cfsavecontent variable="tableHead">
						<cfif form.yearToDateLeadLog EQ 1>
							<h2 style="margin-top:0px;">#dateformat(startMonthDate, "mmmm")# to #dateformat(dateadd("m", -1, endDate), "mmmm yyyy")# Phone Call Log</h2>
						<cfelse>  
							<h2 style="margin-top:0px;">#dateformat(startMonthDate, "mmmm yyyy")# Phone Call Log</h2>
						</cfif>
						<table class="leadTable1">
							<tr>
								<th style="width:1%; white-space:nowrap;">Caller ID</th>
								<th>Customer ##</th>
								<th>City</th>
								<th>Date</th>
								<th>Office</th>
								<!--- <th>Source</th> --->
							</tr>
					</cfsavecontent>
					<cfscript>
					showFooter(); 
					request.contentSection.PhoneLog=request.pageCount;  
					rowCount=0;
					echo(tableHead);
					for(row in qPhone){
						if(rowCount > request.rowLimit){
							if(structkeyexists(form, 'print')){
								echo('</table>');

								showFooter();
								echo(tableHead);
							}else{
								request.pagecount++;
							}
							rowCount=0;
						}
						js=deserializeJson(row.inquiries_custom_json);
						fs={
							"name":"",
							"Phone 1":"",
							"source":"",
							"city":"",
							"tracking_label":"",
							"called_at":""
						};
						for(field in js.arrCustom){
							fs[field.label]=field.value;
						}
						//echo('</table>');
						if(fs["Phone 1"] EQ ""){
							fs["Phone 1"]=row.inquiries_phone1;
						}
						label=application.zcore.functions.zLimitStringLength(fs.tracking_label, 60); 
						/*writedump(row);
						writedump(js);
						break;*/
						// Phone 1
						echo('<tr>
							<td style="width:1%; white-space:nowrap;">#fs.Name#</td>
							<td>#fs["Phone 1"]#</td>
							<td>#fs.city#</td>
							<td>#dateformat(row.inquiries_datetime, "m/d/yyyy")#</td>
							<td>#label#</td>
							
						</tr>');//<td>#fs.source#</td>

						rowCount++;
					}
					</cfscript>
					</table> 
				</cfif> 
			</cfsavecontent> 
		</cfif>

 		<cfif not request.disableContentSection["WebLeadLog"]> 
			<cfsavecontent variable="webFormOut">
			
				<cfif qWebLead.recordcount> 
					<cfsavecontent variable="tableHead">  
						<cfif form.yearToDateLeadLog EQ 1>
							<h2 style="margin-top:0px;">#dateformat(startMonthDate, "mmmm")# to #dateformat(dateadd("m", -1, endDate), "mmmm yyyy")# Web Form Log</h2>
						<cfelse>  
							<h2 style="margin-top:0px;">#dateformat(startMonthDate, "mmmm yyyy")# Web Form Log</h2>
						</cfif>
	
						<table class="leadTable1">
							<tr>
								<th style="width:1%; white-space:nowrap;">Name</th>
								<th>Phone</th>
								<th>Email</th>
								<th>Date</th>
								<th>Type</th>
							</tr>
					</cfsavecontent>
					<cfscript>
					showFooter();  
					request.contentSection.WebLeadLog=request.pageCount; 
					rowCount=0;
					echo(tableHead);
					for(row in qWebLead){
						if(rowCount > request.rowLimit){
							if(structkeyexists(form, 'print')){
								echo('</table>');

								showFooter();
								echo(tableHead);
							}else{
								request.pagecount++;
							}
							rowCount=0;
						} 
						fs["Phone 1"]="";
						if(row.inquiries_custom_json NEQ ""){
							js=deserializeJson(row.inquiries_custom_json);
							
							fs={
								"name":"",
								"Phone 1":"",
								"source":"",
								"city":"",
								"tracking_label":"",
								"called_at":""
							};
							for(field in js.arrCustom){
								fs[field.label]=field.value;
							} 
							//echo('</table>');
							if(fs["Phone 1"] EQ ""){
								fs["Phone 1"]=row.inquiries_phone1;
							} 
						}
						v=row.inquiries_type_id_siteIDType&"-"&row.inquiries_type_id;
						if(structkeyexists(typeLookup, v)){
							inquiries_type_name=typeLookup[v];
						}else{
							inquiries_type_name="";
						}
					 
						/*writedump(row);
						writedump(js);
						break;*/
						// Phone 1
						echo('<tr>
							<td style="width:1%; white-space:nowrap;">#row.inquiries_first_name# #row.inquiries_last_name#</td>
							<td>#row.inquiries_phone1#</td>
							<td>#row.inquiries_email#</td>
							<td>#dateformat(row.inquiries_datetime, "m/d/yyyy")#</td>
							<td>#inquiries_type_name#</td>
						</tr>');
						rowCount++;
					}
					</cfscript>
					</table>
				</cfif> 
			</cfsavecontent> 
		</cfif>
	 
	 	<cfsavecontent variable="leadSummaryOut">
	 		<cfscript>
			rowCount=0;
			</cfscript>
	 		<cfif not request.disableContentSection["leadTypeSummary"]> 
				#footerSummaryOut#
				<cfif qPhone.recordcount or qWebLead.recordcount> 
					<h2 style="margin-top:0px;">Lead Summary By Type</h2>
					<cfif qPhone.recordcount>  
						<h3>Phone Calls by <cfif qSite.site_phone_tracking_label_text EQ "">Tracking Label<cfelse>#qSite.site_phone_tracking_label_text#</cfif></h3>
						<cfscript> 
						echo('<table style="font-size:12px;">'); 
						arrGroupSort=structsort(phoneGroup, "numeric", "desc", "count");
						for(i=1;i<=arraylen(arrGroupSort);i++){
							c=phoneGroup[arrGroupSort[i]];
							if(rowCount > 30){
								if(structkeyexists(form, 'print')){
									echo('</table>');

									showFooter();
									echo('<h3>Phone Calls by Tracking Label</h3><table style="font-size:12px;">'); 
								}else{
									request.pagecount++;
								}
								rowCount=0;
							}
							echo('<tr><td style="width:1%; white-space:nowrap;">');
							echo(c.count);
							echo(' calls</td>');

							if(c.label EQ ""){
								echo('<td style=" padding-left:10px;">(No Label)</td>');
							}else{
								echo('<td style=" padding-left:10px;">#c.label#</td>');
							}
							echo('</tr>');
							rowCount++;
						}
						echo('</table>');
						</cfscript>
					</cfif>
					
					<cfif qWebLead.recordcount>
						<h3 style="margin-top:30px;">Web Form Leads by Type</h3>
						<cfscript>
						echo('<table style="font-size:12px;">');
						rowCount+=6;
						arrGroupSort=structsort(webFormGroup, "numeric", "desc", "count");
						for(i=1;i<=arraylen(arrGroupSort);i++){
							c=webFormGroup[arrGroupSort[i]]; 
							if(rowCount > 30){
								if(structkeyexists(form, 'print')){
									echo('</table>');

									showFooter();
									echo('<h3>Phone Calls by Tracking Label</h3><table style="font-size:12px;">');
								}else{
									request.pagecount++;
								}
								rowCount=0;
							} 
							echo('<tr><td style="width:1%; white-space:nowrap;">');
							echo(c.count);
							echo(' leads</td>
							<td style=" padding-left:10px;">#c.label#</td></tr>');
							rowCount++;
						}
						echo('</table>');

						</cfscript>
					</cfif>
				</cfif>
		 
			</cfif>
		</cfsavecontent>
		<cfscript> 
		echo(leadSummaryOut);
		echo(phoneLogOut);
		echo(webFormOut);

		notUpToDate=false;
		</cfscript>

		#showFooter(true)#

		<div class="hide-on-print"> 
			<a id="generatedInfo">&nbsp;</a>
			<h2>About This Report</h2>
			<p>The displayed search volume for keywords is the highest number during that month.  This data comes from semrush.com or moz.com.</p>
			<p>The displayed ranking for keywords is the lowest number during that month.</p>
			<p>"Visits" are visits.  They are not unique, and they are not sessions or users.</p>
			<p>Search Console and Google Analytics are combined to report the keywords people used to find the site. The majority of keywords for bing/yahoo can't be collected.</p>
			<p>There is permanently going to be less keyword traffic data available before October 2016 because Search Console only goes back 90 days and this report system went into use in January 2017.</p>
			<p>Parts of the report will not show if there is no data being collected for that part during the selected time period.</p>
			<p>There is no separation between paid traffic and other traffic.  Most reports except for "organic search" are showing all sources of traffic combined.</p>
			<h2>Data Integration Status:</h2>      
			<cfif qSite.site_webposition_id_list EQ "">
				<p>Webposition backup import not enabled</p>
			<cfelse>
				<p>Webposition backup was imported</p>
			</cfif>
			<cfif qSite.site_semrush_id_list EQ "">
				<p>SEMRush.com: not enabled</p>
			<cfelse>
				<cfscript>
				if(qSite.site_semrush_last_import_datetime NEQ "" and datecompare(dateformat(qSite.site_semrush_last_import_datetime, "yyyy-mm-dd"), request.selectedMonth) GTE 0){
					notUpToDate=true;
				}
				</cfscript>
				<p>SEMRush.com: #showDate(qSite.site_semrush_last_import_datetime)#</p> 
			</cfif>
			<cfif qSite.site_google_search_console_domain EQ "">
				<p>Google Webmaster Search Analytics: not enabled</p>
			<cfelse>
				<cfscript>
				if(qSite.site_google_search_console_last_import_datetime NEQ "" and datecompare(dateformat(qSite.site_google_search_console_last_import_datetime, "yyyy-mm-dd"), request.selectedMonth) GTE 0){
					notUpToDate=true;
				}
				</cfscript>
				<p>Google Webmaster Search Analytics: #showDate(qSite.site_google_search_console_last_import_datetime)#</p>
			</cfif>
			<cfif qSite.site_google_api_account_email EQ "">
				<p>Google Analytics API: not enabled</p>
			<cfelse>
				<cfscript>
				if(qSite.site_google_analytics_keyword_last_import_datetime NEQ "" and datecompare(dateformat(qSite.site_google_analytics_keyword_last_import_datetime, "yyyy-mm-dd"), request.selectedMonth) GTE 0){
					notUpToDate=true;
				}
				if(qSite.site_google_analytics_organic_last_import_datetime NEQ "" and datecompare(dateformat(qSite.site_google_analytics_organic_last_import_datetime, "yyyy-mm-dd"), request.selectedMonth) GTE 0){
					notUpToDate=true;
				}
				</cfscript>
				<p>Google Analytics Organic Keywords: #showDate(qSite.site_google_analytics_keyword_last_import_datetime)#</p>  
				<p>Google Analytics Organic Overview: #showDate(qSite.site_google_analytics_organic_last_import_datetime)#</p>
			</cfif>
			<cfif qSite.site_seomoz_id_list EQ "">
				<p>moz.com: not enabled</p>
			<cfelse>
				<cfscript>
				if(qSite.site_seomoz_last_import_datetime NEQ "" and datecompare(dateformat(qSite.site_seomoz_last_import_datetime, "yyyy-mm-dd"), request.selectedMonth) GTE 0){
					notUpToDate=true;
				}
				</cfscript>
				<p>moz.com: #showDate(qSite.site_seomoz_last_import_datetime)#</p>
			</cfif>
			<cfif qSite.site_calltrackingmetrics_enable_import NEQ 1>
				<p>CallTrackingMetrics.com: not enabled</p>
			<cfelse>
				<cfscript>
				if(qSite.site_calltrackingmetrics_import_datetime NEQ "" and datecompare(dateformat(qSite.site_calltrackingmetrics_import_datetime, "yyyy-mm-dd"), request.selectedMonth) GTE 0){
					notUpToDate=true;
				}
				</cfscript>
				<p>CallTrackingMetrics.com: #showDate(qSite.site_calltrackingmetrics_import_datetime)#</p>
			</cfif>
		</div>

	</div>
	</div>
</body>
</html>
</cfsavecontent>
<cfscript>
if(structkeyexists(form, 'print')){ 
	htmlOut=replace(htmlOut, '{pagecount}', request.pagecount, 'all'); 
}
htmlOut=replace(htmlOut, '{totalPageCount}', request.pageCount, 'all');  

if(notUpToDate){
	htmlOut=replace(htmlOut, 'class="uptodateDiv"', 'class="uptodateDiv"  style="display:none;" ');
}

for(i in request.contentSection){
	v=request.contentSection[i];
	if(v EQ 0){
		htmlOut=replace(htmlOut, '{#i#Style}', 'display:none;');
	}else{
		htmlOut=replace(htmlOut, '{#i#Style}', ' ');
		htmlOut=replace(htmlOut, '{#i#PageNumber}', v+1);
	}
}  
</cfscript>
<cfif structkeyexists(form, 'print')> 
	<cfscript> 
	// uncomment to debug print version
	//echo(htmlOut);abort;
	debug=false;
	setting requesttimeout="20";
	pdfFile=request.zos.globals.privateHomeDir&"#form.selectedMonth#-Lead-Report-#request.zos.globals.shortDomain#.pdf";
	r=application.zcore.functions.zConvertHTMLTOPDF(htmlOut, pdfFile);
	if(r EQ false){

		ts={
			type:"Custom",
			errorHTML:'HTML to PDF Failed.  User saw the raw html instead of a pdf.  Error message: '&request.zos.htmlToPDFErrorMessage&"<br /><br />Full HTML: "&html,
			scriptName:'/builder-pdf/index',
			url:request.zos.originalURL,
			exceptionMessage:'HTML to PDF Failed.  User saw the raw html instead of a pdf.  Error message: '&request.zos.htmlToPDFErrorMessage,
			// optional
			lineNumber:'1'
		}
		application.zcore.functions.zLogError(ts);
		echo(html);
		abort;
	}
	if(debug){
		echo(html);
		application.zcore.functions.zdeletefile(pdfFile);
		echo('html to pdf result: '&r);
		abort;
	}
    header name="Content-Disposition" value="inline; filename=#getfilefrompath(pdfFile)#" charset="utf-8";
    content type="application/pdf" deletefile="yes" file="#pdfFile#";
	</cfscript>
	
<cfelse>
	#htmlOut#
</cfif>
<!--- send email of monthly --->
<cfabort>
</cffunction>


<cffunction name="showFooter" localmode="modern" access="public">
	<cfargument name="last" type="boolean" required="no" default="#false#">
	<cfscript>
	request.pageCount++;
	</cfscript>
	
	</div>
	<cfif structkeyexists(form, 'print')>
		<div class="print-footer"> 
			<div style="width:70%; float:left; text-align:left;">
				<cfif form.yearToDateLeadLog EQ 1>
					<p class="leadHeading">Jan to #dateformat(request.selectedMonth, "mmm yyyy")# - #request.footerDomain#</p>
				<cfelse>
					<p class="leadHeading">#dateformat(request.selectedMonth, "mmmm yyyy")# - #request.footerDomain#</p>
				</cfif>  
			</div>
			<div style="width:30%; float:left;">
				Page #request.pageCount# of {pagecount}
			</div>
		</div>
	</cfif> <!--- 
	<cfif structkeyexists(form, 'print')>
		<div class="page-break"></div>
	</cfif> --->
	
	<cfif arguments.last EQ false>
		<div class="main-header">
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>