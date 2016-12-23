<cfcomponent>
<cfoutput>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript>
	/*
	
		ytd
		month
		month over month
		year over year

		web lead and phone (call tracking metrics)
	*/
	db=request.zos.queryObject;
	typeLookup={};
	typeIdLookup={};
	//application.zcore.template.setPlainTemplate();


	if(not structkeyexists(form, 'selectedMonth')){
		firstOfMonth=createdate(year(now()), month(now()), 1);
		form.selectedMonth=dateformat(dateadd("d", -1, firstOfMonth), "yyyy-mm");
	}
	//startDate=form.selectedMonth&"-01 00:00:00";
	startDate=dateformat(dateadd("m", -2, form.selectedMonth&"-01"), "yyyy-mm-dd");
	startMonthDate=form.selectedMonth&"-01";
	endDate=dateformat(dateadd("m", 1, form.selectedMonth), "yyyy-mm-dd")&" 00:00:00";

	previousStartDate=dateformat(dateadd("yyyy", -1, startDate), "yyyy-mm-dd");
	previousStartMonthDate=dateformat(dateadd("yyyy", -1, startMonthDate), "yyyy-mm-dd");
	previousEndDate=dateformat(dateadd("yyyy", -1, endDate), "yyyy-mm-dd");
 

	db.sql="SELECT * FROM #db.table("inquiries_type", request.zos.zcoreDatasource)#
	WHERE  
	inquiries_type_deleted=#db.param(0)# and   
	site_id = #db.param(0)#";
	qType=db.execute("qType");
	for(row in qType){
		typeLookup[row.site_id&"-"&row.inquiries_type_id]=row.inquiries_type_name;
		typeIdLookup[row.inquiries_type_name]=row;
	}

	db.sql="SELECT * FROM #db.table("inquiries_type", request.zos.zcoreDatasource)#
	WHERE  
	inquiries_type_deleted=#db.param(0)# and   
	site_id = #db.param(request.zos.globals.id)#";
	qType=db.execute("qType");

	for(row in qType){
		typeLookup[row.site_id&"-"&row.inquiries_type_id]=row.inquiries_type_name;
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
	inquiries.site_id = #db.param(request.zos.globals.id)#
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
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
	inquiries.site_id = #db.param(request.zos.globals.id)#
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
	inquiries.site_id = #db.param(request.zos.globals.id)# 
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
	inquiries.site_id = #db.param(request.zos.globals.id)# 
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
	inquiries.site_id = #db.param(request.zos.globals.id)#
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
	inquiries.site_id = #db.param(request.zos.globals.id)#
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
	inquiries.site_id = #db.param(request.zos.globals.id)# 
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
	inquiries.site_id = #db.param(request.zos.globals.id)# 
	ORDER BY date ";
	qYTDPhone=db.execute("qYTDPhone"); 


	db.sql="SELECT  inquiries.inquiries_type_id, DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE   
	inquiries_deleted=#db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# 
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
	cssPageBreak='<div class="page-break"></div>';
	</cfscript>  

<cfsavecontent variable="htmlOut">
	
<html>
	<head>
		<title>Report</title>
	    <meta charset="utf-8" />
	<style type="text/css">
		body{font-family:Verdana, arial, helvetica, sans-serif; line-height:1.3; font-size:14px; margin:0px;}
	h1,h2,h3,h4,h5, p, ul, ol{margin:0px; padding:0px; padding-bottom:15px;}
	h2{ margin-top:50px;}

	.leadHeading{padding-top:20px;}
	.leadTable1{border-spacing:0px;
	width:100%;
	margin-bottom:20px;
		border-right:1px solid ##999;
		border-bottom:1px solid ##999;}
	.leadTable1 th{ text-align:left;}
	.leadTable1 th, .leadTable1 td{
		padding:3px;
		font-size:11px;
		line-height:1.3; 
		border:1px solid ##999;
		border-right:none;
		border-bottom:none;

	} 
	*{-webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing:border-box;}
	.topFiveColor{background-color:##e9ea96;}
	.topTenColor{background-color:##96dcf8;}
	.topTwentyColor{background-color:##bacde4;}
	.topFiftyColor{background-color:##fbd57f;}
	.wrapper{  padding:20px;}
	.page-break	{ display: none; }
	<cfif structkeyexists(form, 'print')>
		.hide-on-print{display:none;}
		.page-break	{ display: block; page-break-before: always; }
	<cfelse>
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
		<form action="/z/inquiries/admin/custom-lead-report/index" method="get">
		<p style="text-align:right;">Select Month: 
		<input type="month" name="selectedMonth" value="#dateformat(form.selectedMonth, "yyyy-mm")#"> 
		<input type="submit" name="select1" value="Select"> | 
		<a href="#request.zos.originalURL#?selectedMonth=#form.selectedMonth#&amp;print=1" target="_blank">View PDF</a></p>
		</form>
	</div>
	<h2 style="color:##999; padding-bottom:0px; margin-top:0px;">#request.zos.globals.shortDomain#</h2>
	<h3>#dateformat(form.selectedMonth, "mmmm yyyy")# Search Engine Marketing Report</h3> 

	<h2 style="margin-top:0px;">Website Leads</h2>
	<p>We are tracking conversions from your website through phone calls and contact form leads. Below are the conversions from the month of #dateformat(form.selectedMonth, "mmmm")#:</p>
	<table class="leadSummaryTable">
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
	</table>
	
	<cfscript>
	if(arrayLen(arrStat)){
		echo('<h2>Lead Highlights</h2>');
		for(stat in arrStat){
			echo('<h4>#stat#</h4>');
		}
	}
	</cfscript>

	<h2>#dateformat(startDate, "mmmm")# through #dateformat(startMonthDate, "mmmm")# Monthly Lead Comparison Report</h2>
	<table style="border-spacing:0px;" class="leadTable1">
		<tr> 
			<th style="width:1%; white-space:nowrap;">&nbsp;</th>
			<cfscript> 
			arrMonth=structkeyarray(monthStruct);
			arraySort(arrMonth, "text", "asc");
			for(month in arrMonth){
				echo('<th>#month#</th>');
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

	<h2>January 1 to #dateformat(dateadd("d", -1, endDate), "mmmm d")# Lead Comparison Report</h2>
	<table style="border-spacing:0px;" class="leadTable1">
		<tr> 
			<th style="width:1%; white-space:nowrap;">&nbsp;</th>
			<th>#year(previousStartMonthDate)#</th>
			<th>#year(startMonthDate)#</th>
		</tr> 
		<cfscript>
		echo('<tr>');
		echo('<td style="width:1%; white-space:nowrap;">Web Leads</td>');
		echo('<td>#previousYtdStruct.total-previousYtdStruct.phone#</td>');
		echo('<td>#ytdStruct.total-ytdStruct.phone#</td>');
		echo('</tr><tr>');
		echo('<td style="width:1%; white-space:nowrap;">Phone Leads</td>');
		echo('<td>#previousYtdStruct.phone#</td>');
		echo('<td>#ytdStruct.phone#</td>');
		echo('</tr><tr>');
		echo('<td style="width:1%; white-space:nowrap;">Total Leads</td>');
		echo('<td>#previousYtdStruct.total#</td>');
		echo('<td>#ytdStruct.total#</td>');
		echo('</tr>');
 
		</cfscript>  
	</table>  


	<!--- list out all phone call leads individually for the selected month  --->
	<cfscript> 
	db.sql="SELECT 
	*
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_datetime>=#db.param(startMonthDate)# and 
	inquiries_datetime<#db.param(endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(phonemonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(phonemonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#
	ORDER BY inquiries_datetime ASC ";
	qPhone=db.execute("qPhone");
	</cfscript>
	

	<cfsavecontent variable="tableHead"> 
		<cfif structkeyexists(form, 'print')>
			<p class="leadHeading">#form.selectedMonth# Lead Report for #request.zos.globals.shortDomain#</p>
		</cfif>
		<h2 style="margin-top:0px;">#dateformat(startMonthDate, "mmmm yyyy")# Phone Call Log</h2>
		<table class="leadTable1">
			<tr>
				<th style="width:1%; white-space:nowrap;">Name</th>
				<th>Customer ##</th>
				<th>City</th>
				<th>Date</th>
				<th>Office</th>
				<th>Source</th>
			</tr>
	</cfsavecontent>
	<cfscript>
	echo(cssPageBreak);
	rowCount=0;
	echo(tableHead);
	for(row in qPhone){
		if(rowCount > 38){
			echo('</table>'&cssPageBreak&tableHead);
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
		/*writedump(row);
		writedump(js);
		break;*/
		// Phone 1
		echo('<tr>
			<td style="width:1%; white-space:nowrap;">#fs.Name#</td>
			<td>#fs["Phone 1"]#</td>
			<td>#fs.city#</td>
			<td>#dateformat(row.inquiries_datetime, "m/d/yyyy")#</td>
			<td>#application.zcore.functions.zLimitStringLength(fs.tracking_label, 60)#</td>
			<td>#fs.source#</td>
		</tr>');

		rowCount++;
	}
	</cfscript>
	</table>


	<cfif request.zos.isTestServer or structkeyexists(form, 'testKeywordReport')>
	
		<cfscript>
		echo(cssPageBreak); 


		ks={};
		ks["2016-11"]={
			"daytona beach stuff":4,
			"daytona stuff":1,
			"daytona widget":6,
			"ormond stuff":11,
			"deltona stuff":20,
			"ponce inlet things":51
		};
		ks["2016-10"]={
			"deleted keyword":3,
			"daytona stuff":4,
			"daytona widget":8,
			"ormond stuff":3,
			"deltona stuff":40,
			"ponce inlet things":0
		};
		ks["2016-09"]={
			"daytona stuff":11,
			"daytona widget":26,
			"ormond stuff":34,
			"deltona stuff":0,
			"ponce inlet things":0
		};
		for(date in ks){
			cs=ks[date];
			for(keyword in cs){
				kw[keyword]=true;
			}
		}
		arrKeywordDate=structkeyarray(ks);
		arraySort(arrKeywordDate, "text", "asc");
		keywordSortStruct={};
		ts=ks["2016-11"];
		count=0;
		for(keyword in ts){
			keywordSortStruct[count]={keyword:keyword, position:ts[keyword]};
			if(keywordSortStruct[count].position EQ 0){
				keywordSortStruct[count].position=1000;
			}
			count++;
		}
		arrKey=structsort(keywordSortStruct, "numeric", "asc", "position");
		arrKeyword=[];
		for(i in arrKey){
			arrayAppend(arrKeyword, keywordSortStruct[i].keyword);
		}
		</cfscript>
		<cfsavecontent variable="tableHead"> 
			<cfif structkeyexists(form, 'print')>
				<p class="leadHeading">#form.selectedMonth# Lead Report for #request.zos.globals.shortDomain#</p>
			</cfif>
			<h2 style="margin-top:0px;">Google Ranking Keyword Report (work in progress)</h2>
			<table class="keywordTable1 leadTable1">
				<tr>
					<th style="width:1%; white-space:nowrap;">&nbsp;</th>
					<cfscript>
					for(date in arrKeywordDate){
						echo('<th>#date#</th>');
					}
					</cfscript>
					<th>Search Volume</th>
				</tr>
		</cfsavecontent>
			<cfscript> 
			echo(tableHead);
			count=0;
			// need to implement page breaks here..
			for(i=1;i LTE arrayLen(arrKeyword);i++){
				keyword=arrKeyword[i];
				if(count > 38){
					echo('</table>'&tableHead);
					count=0;
				}
				echo('<tr>');
				echo('<th style="width:1%; white-space:nowrap;">#keyword#</th>');
				for(n=1;n<=arrayLen(arrKeywordDate);n++){
					date=arrKeywordDate[n];
					if(structkeyexists(ks, date) and structkeyexists(ks[date], keyword)){
						position=ks[date][keyword];
						if(arrayLen(arrKeywordDate) EQ n){
							if(position < 6){
								className="topFiveColor";
							}else if(position < 11){
							 	className="topTenColor";
							}else if(position < 21){
								className="topTwentyColor";
							}else{
								className="topFiftyColor";
							}
						}else{
							className="";
						}
						echo('<td class="#className#">#position#</td>');
					}else{
						echo('<td style="background-color:##CCC;">&nbsp;</td>');
					}
				}
				// need to get this from manual data entry
				echo('<td>X</td>');
				echo('</tr>');
				count++;
			}
			</cfscript>
		</table>

		<h4>Google Ranking Keyword Color Legend</h4> 
		<div style="width:100%; float:left;">
			<div style="padding:10px; margin-right:20px; border:2px solid ##000; float:left; margin-bottom:20px;" class="topFiveColor">Top Five (First Page)</div> 
			<div style="padding:10px; margin-right:20px; border:2px solid ##000; float:left; margin-bottom:20px;" class="topTenColor">Top Ten (First Page)</div>  
			<div style="padding:10px; margin-right:20px; border:2px solid ##000; float:left; margin-bottom:20px;" class="topTwentyColor">Top Twenty (Second Page)</div> 
			<div style="padding:10px; margin-right:20px; border:2px solid ##000; float:left; margin-bottom:20px;" class="topFiftyColor">Top 50</div>  
		</div>
		<p>This is your current ranking position for your targeted keywords on Google Search. Page rankings 1 through 10 appear on the first results page, 11 through 20 on the second, etc. Our goal is first page placement for all of your targeted keywords.  Search volume varies over time.</p>
	</cfif>
	</div>
</body>
</html>
</cfsavecontent>

<cfif structkeyexists(form, 'print')>
	<!--- <cfdocument format="pdf">
	#htmlOut#
	</cfdocument>
 --->
	<cfscript>
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
</cfoutput>
</cfcomponent>