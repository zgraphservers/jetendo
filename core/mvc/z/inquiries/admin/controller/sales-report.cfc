<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Member Import/Update</h2>
	<p>Be patient after clicking import.  It may take a few minutes for the file to be processed.<p>
	<p>The file format should be excel CSV or tab delimited with no text qualifier, and have this exact number of columns in this order:<br />
	CloseDate,FirstName,LastName,Email,Phone,Phone2,Amount,Salesperson
	<!--- ID,QuoteDate, --->
	</p>
	<form action="/z/inquiries/admin/sales-report/showReport" enctype="multipart/form-data" method="post">
		Select CSV File: <br />
		<input type="file" name="memberFile"> 
		<br /><br /><input type="checkbox" name="forceCloseDate" value="1"> Check box to force all data to be now for the close date
		<br /><br /><input type="submit" name="submit1" value="Import" onclick="$('.memberWaitDiv1').show();this.style.display='none';">
		<div class="memberWaitDiv1" style="display:none;">Please wait...</div>
	</form><br /> 
</cffunction>

<cffunction name="showReport" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="";
	setting requesttimeout="10000";

	reportPath=request.zos.globals.privateHomeDir&"sales-report/";
	application.zcore.functions.zCreateDirectory(reportPath);
	form.memberFile=application.zcore.functions.zUploadFile("memberFile", reportPath);
	reportFile=reportPath&form.memberFile;

	contents=application.zcore.functions.zReadFile(reportFile); 
	application.zcore.functions.zDeleteFile(reportFile);
 
	arrLine=listToArray(replace(contents, chr(13), "", "all"), chr(10)); 
	ds={
		externalId:"",
		firstname:"",
		lastname:"",
		soldDate:"",
		soldBy:"",
		firstInquiryDate:"",
		mostRecentInquiryBeforeSaleDate:"",
		amount:0,
		description:"",
		phone:"",
		phone2:"",
		email:"", 
		inquiryStruct:{},
		arrInquiry:[],
		inquiryCount:0
	};

	arrColumn=listToArray(arrLine[1], chr(9), true);

	db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# WHERE 
	site_id IN (#db.param(request.zos.globals.id)#, #db.param(0)#)";
	qType=db.execute("qType");
	typeStruct={};
	for(row in qType){
		typeStruct[row.inquiries_type_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id)]=row;
	}

	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("track_user", request.zos.zcoreDatasource)# ON 
	 track_user.site_id =inquiries.site_id AND 
	inquiries.inquiries_id = track_user.inquiries_id and 
	track_user_deleted=#db.param(0)# 
	WHERE  
	inquiries.site_id = #db.param(request.zos.globals.id)# and 
	inquiries.inquiries_deleted=#db.param(0)# ";
	//LIMIT #db.param(0)#, #db.param(500)#";
	qI=db.execute("qI");
	inquiryPhoneLookup={};
	inquiryEmailLookup={};
	uniqueSaleLeadCount=0;
	phoneSale={};
	emailSale={};
	d=0;
	emailSourceURLParams={};
	phoneSourceURLParams={};
	emailsourceCountStruct={};
	emailsourceCountAmount={};
	phonesourceCountStruct={};
	phonesourceCountAmount={};
	for(row in qI){
		row.sortInquiryDate=dateformat(row.inquiries_datetime, "yyyymmdd")&timeformat(row.inquiries_datetime, "HHmmss");
		if(row.inquiries_phone1 NEQ "" and row.inquiries_phone1_formatted EQ ""){
			row.inquiries_phone1_formatted=application.zcore.functions.zFormatInquiryPhone(row.inquiries_phone1);
		}
		if(row.inquiries_phone2 NEQ "" and row.inquiries_phone2_formatted EQ ""){
			row.inquiries_phone2_formatted=application.zcore.functions.zFormatInquiryPhone(row.inquiries_phone2);
		}
		if(row.inquiries_phone3 NEQ "" and row.inquiries_phone3_formatted EQ ""){
			row.inquiries_phone3_formatted=application.zcore.functions.zFormatInquiryPhone(row.inquiries_phone3);
		} 
		if(row.inquiries_phone1_formatted NEQ ""){
			if(not structkeyexists(inquiryPhoneLookup, row.inquiries_phone1_formatted)){
				inquiryPhoneLookup[row.inquiries_phone1_formatted]={};
			}
			inquiryPhoneLookup[row.inquiries_phone1_formatted][d]=row;
			d++;
		}
		if(row.inquiries_phone2_formatted NEQ ""){
			if(not structkeyexists(inquiryPhoneLookup, row.inquiries_phone2_formatted)){
				inquiryPhoneLookup[row.inquiries_phone2_formatted]={};
			}
			inquiryPhoneLookup[row.inquiries_phone2_formatted][d]=row;
			d++;
		}
		if(row.inquiries_phone3_formatted NEQ ""){
			if(not structkeyexists(inquiryPhoneLookup, row.inquiries_phone3_formatted)){
				inquiryPhoneLookup[row.inquiries_phone3_formatted]={};
			}
			inquiryPhoneLookup[row.inquiries_phone3_formatted][d]=row;
			d++;
		}
		if(trim(row.inquiries_email) NEQ ""){
			if(not structkeyexists(inquiryEmailLookup, trim(row.inquiries_email))){
				inquiryEmailLookup[trim(row.inquiries_email)]={};
			}
			inquiryEmailLookup[trim(row.inquiries_email)][d]=row;
			d++;
		} 
	}
	killCount=0;
	assistCount=0;
	emailSaleAmount=0;
	phoneSaleAmount=0;
	saleCount=0;
	uniqueSalesAmount=0;
	uniqueTrackableSalesAmount=0;

	//writedump(structkeyarray(inquiryPhoneLookup));
	for(i=2;i<=arraylen(arrLine);i++){
		line=arrLine[i];
		arrRow=listToArray(line, chr(9), true);
		row={};
		for(n=1;n<=arraylen(arrRow);n++){
			try{
				row[arrColumn[n]]=trim(arrRow[n]);
			}catch(e){
				echo('Invalid row format:');
				writedump(arrRow);
			}
		}
		/*if(application.zcore.functions.zso(row, "CloseDate") EQ ""){
			continue;
		}*/
		row["phone_formatted"]=application.zcore.functions.zFormatInquiryPhone(application.zcore.functions.zso(row, "Phone")); 
		row["phone2_formatted"]=application.zcore.functions.zFormatInquiryPhone(application.zcore.functions.zso(row, "Phone2")); 
		for(n in row){
			row[n]=trim(row[n]);
		}

		ts=duplicate(ds);
		// force it to be unique.
		ts.externalId=i;//application.zcore.functions.zso(row, "ID");
		ts.firstName=application.zcore.functions.zso(row, "FirstName");
		ts.lastName=application.zcore.functions.zso(row, "LastName");
		ts.email=application.zcore.functions.zso(row, "Email");
		ts.amount=numberformat(application.zcore.functions.zso(row, "Amount", true), "_.__");
		ts.soldBy=replace(application.zcore.functions.zso(row, "SalesPerson"), '"', '', 'all');
		if(structkeyexists(form, 'forceCloseDate') or application.zcore.functions.zso(row, "CloseDate") EQ ""){
			ts.soldDate=request.zos.mysqlnow;
		}else{
			ts.soldDate=dateformat(application.zcore.functions.zso(row, "CloseDate"), "yyyy-mm-dd")&" "&timeformat(application.zcore.functions.zso(row, "CloseDate"), "HH:mm:ss");
			ts.soldDate=dateadd("h", 1, ts.soldDate);
			ts.soldDate=dateformat(ts.soldDate, "yyyy-mm-dd")&" "&timeformat(ts.soldDate, "HH:mm:ss");
		}
		compareSoldDate=dateformat(ts.soldDate, "yyyymmdd")&""&timeformat(ts.soldDate, "HHmmss");

		if(row["Email"] NEQ "" and structkeyexists(inquiryEmailLookup, trim(row["Email"]))){
			for(inquiries_id in inquiryEmailLookup[trim(row["Email"])]){
				ss=inquiryEmailLookup[trim(row["Email"])][inquiries_id];
				ts.inquiryStruct[d]=ss;
				d++; 
			} 
		}
		// inquiries_phone1 and inquiries_phone1_formatted

		if(row["phone_formatted"] NEQ "" and structkeyexists(inquiryPhoneLookup, row["phone_formatted"])){ 
			for(inquiries_id in inquiryPhoneLookup[row["phone_formatted"]]){
				ss=inquiryPhoneLookup[row["phone_formatted"]][inquiries_id];
				ts.inquiryStruct[d]=ss;
				d++;
			} 
		}else if(row["phone2_formatted"] NEQ "" and structkeyexists(inquiryPhoneLookup, row["phone2_formatted"])){ 
			for(inquiries_id in inquiryPhoneLookup[row["phone2_formatted"]]){
				ss=inquiryPhoneLookup[row["phone2_formatted"]][inquiries_id];
				ts.inquiryStruct[d]=ss;
				d++;
			} 
		}else{
			if(trim(row["Email"]) EQ "" or not structkeyexists(inquiryEmailLookup, trim(row["Email"]))){
				echo(ts.firstName&" "&ts.lastName&" | "&row["phone_formatted"]&" no phone or email match<br>");
			}
		}
		uniqueSalesAmount+=ts.amount;
		assistCountStruct={};
		arrDate=structsort(ts.inquiryStruct, "numeric", "desc", "sortInquiryDate");
		for(n=1;n<=arraylen(arrDate);n++){
			killCount++;
			cs=ts.inquiryStruct[arrDate[n]];
			if(cs.sortInquiryDate LT compareSoldDate){
				if(structkeyexists(typeStruct, cs.inquiries_type_id&"|"&cs.inquiries_type_id_siteidtype)){
					cs.leadType=typeStruct[cs.inquiries_type_id&"|"&cs.inquiries_type_id_siteidtype];
				}
				if(structkeyexists(inquiryEmailLookup, trim(row["Email"]))){
					if(not structkeyexists(emailSale, ts.externalId)){
						emailSaleAmount+=ts.amount; 
					}
					emailSale[ts.externalId]=true;
					if(cs.track_user_source NEQ ""){
						if(not structkeyexists(emailsourceCountStruct, cs.track_user_source)){
							emailsourceCountStruct[cs.track_user_source]=0;
							emailsourceCountAmount[cs.track_user_source]=0;
							emailSourceURLParams[cs.track_user_source]={};
						}
						assistCountStruct["email_"&cs.track_user_source]=true;
						emailsourceCountAmount[cs.track_user_source]+=ts.amount;
						emailsourceCountStruct[cs.track_user_source]++;
						// TODO need to finish this
						//emailSourceURLParams[cs.track_user_source][track_user_first_page]=true;
					}else if(cs.track_user_referer NEQ ""){
						referer=replace(replace(cs.track_user_referer, "https://", ""), "http://", "");
						if(referer CONTAINS "/"){
							referer=listGetAt(referer, 1, "/");
						}
						if(not structkeyexists(emailsourceCountStruct, referer)){
							emailsourceCountStruct[referer]=0;
							emailsourceCountAmount[referer]=0;
						}
						emailsourceCountAmount[referer]+=ts.amount;
						assistCountStruct["email_"&referer]=true;
						emailsourceCountStruct[referer]++;
					}
				}
				if(structkeyexists(inquiryPhoneLookup, row["phone_formatted"])){ 
					if(not structkeyexists(phoneSale, ts.externalId)){
						phoneSaleAmount+=ts.amount; 
					} 
					phoneSale[ts.externalId]=true; 
					if(cs.track_user_source NEQ ""){

						if(not structkeyexists(phonesourceCountStruct, cs.track_user_source)){
							phoneSourceURLParams[cs.track_user_source]={};
							phonesourceCountStruct[cs.track_user_source]=0;
							phonesourceCountAmount[cs.track_user_source]=0;
						}
						assistCountStruct["phone_"&cs.track_user_source]=true;
						phonesourceCountAmount[cs.track_user_source]+=ts.amount;
						phonesourceCountStruct[cs.track_user_source]++;
					}else if(cs.track_user_referer NEQ ""){
						referer=replace(replace(cs.track_user_referer, "https://", ""), "http://", "");
						if(referer CONTAINS "/"){
							referer=listGetAt(referer, 1, "/");
						}
						if(not structkeyexists(phonesourceCountStruct, referer)){
							phonesourceCountStruct[referer]=0;
							phonesourceCountAmount[referer]=0;
						}
						phonesourceCountAmount[referer]+=ts.amount;
						assistCountStruct["phone_"&referer]=true;
						phonesourceCountStruct[referer]++;
						//phoneSourceURLParams[cs.track_user_source][track_user_first_page]=true;
					}
				}
				if(structkeyexists(inquiryPhoneLookup, row["phone2_formatted"])){ 
					if(not structkeyexists(phoneSale, ts.externalId)){
						phoneSaleAmount+=ts.amount; 
					} 
					phoneSale[ts.externalId]=true; 
					if(cs.track_user_source NEQ ""){

						if(not structkeyexists(phonesourceCountStruct, cs.track_user_source)){
							phoneSourceURLParams[cs.track_user_source]={};
							phonesourceCountStruct[cs.track_user_source]=0;
							phonesourceCountAmount[cs.track_user_source]=0;
						}
						assistCountStruct["phone_"&cs.track_user_source]=true;
						phonesourceCountAmount[cs.track_user_source]+=ts.amount;
						phonesourceCountStruct[cs.track_user_source]++;
					}else if(cs.track_user_referer NEQ ""){
						referer=replace(replace(cs.track_user_referer, "https://", ""), "http://", "");
						if(referer CONTAINS "/"){
							referer=listGetAt(referer, 1, "/");
						}
						if(not structkeyexists(phonesourceCountStruct, referer)){
							phonesourceCountStruct[referer]=0;
							phonesourceCountAmount[referer]=0;
						}
						phonesourceCountAmount[referer]+=ts.amount;
						assistCountStruct["phone_"&referer]=true;
						phonesourceCountStruct[referer]++;
						//phoneSourceURLParams[cs.track_user_source][track_user_first_page]=true;
					}
				}
				arrayAppend(ts.arrInquiry, cs);
			}else{
				echo("Future lead only: "&ts.firstName&" | "&ts.lastName&" | "&ts.email&" | "&cs.inquiries_datetime&" | "&cs.sortInquiryDate&" LT "&compareSoldDate&"<br>");
			}
		}
		if(structcount(assistCountStruct) GT 1){
			assistCount++;
		}
		structdelete(ts, 'inquiryStruct');
		if(arraylen(ts.arrInquiry) NEQ 0){
			uniqueTrackableSalesAmount+=ts.amount;
			firstInquiry=ts.arrInquiry[1];
			lastInquiry=ts.arrInquiry[arrayLen(ts.arrInquiry)];
			ts.firstInquiryDate=dateformat(firstInquiry.inquiries_datetime, "yyyy-mm-dd")&" "&timeformat(firstInquiry.inquiries_datetime, "HH:mm:ss");
			ts.mostRecentInquiryBeforeSaleDate=dateformat(lastInquiry.inquiries_datetime, "yyyy-mm-dd")&" "&timeformat(lastInquiry.inquiries_datetime, "HH:mm:ss"); 
			ts.inquiryCount=arrayLen(ts.arrInquiry);
			//echo('sale with lead: '&ts.externalId&"<hr>");
			uniqueSaleLeadCount+=ts.inquiryCount;
			//uniqueSaleLeadCount++;
			//writedump(ts);abort;
		}else{
			echo("Not from web:"&ts.firstName&" | "&ts.lastName&" | "&ts.phone&" | "&row.phone_formatted&" | "&ts.email&" | "&compareSoldDate&"<br>");
			//writedump(ts);
			/*if(killCount GT 20){
				abort;
			}*/
		}
		saleCount++;
		//break;
	}

	echo('Total Sales: #saleCount#<br>
		Total Sales Gross Amount: #dollarformat(uniqueSalesAmount)#<br>Trackable Sales: #uniqueSaleLeadCount#<br>
		Trackable Sales Gross Amount: #dollarformat(uniqueTrackableSalesAmount)#<br>Sales Involving a Phone Call Lead: #structcount(phoneSale)#<br>Sales Involving a Form Lead: #structcount(emailSale)#<br>');
	if(saleCount EQ 0){
		saleCount=0.0001;
	}
	echo(numberformat((uniqueSaleLeadCount/saleCount)*100, "_.__")&"% of the data matched phone or email in lead database. These are the ""trackable sales"" being reported on below.<br>");
	if(uniqueSaleLeadCount EQ 0){
		uniqueSaleLeadCount=0.001;
	}
	echo(numberformat((structcount(phoneSale)/uniqueSaleLeadCount)*100, "_.__")&"% of the trackable sales involved a phone call lead.<br>");
	echo(dollarformat(phoneSaleAmount)&" of the trackable sales volume involved a phone call lead.<br>");
	echo(numberformat((structcount(emailSale)/uniqueSaleLeadCount)*100, "_.__")&"% of the trackable sales involved a form lead.<br>");
	echo(dollarformat(emailSaleAmount)&" of the trackable sales volume involved a form lead.<br>");
	

	echo('<h2>Trackable Lead Source Report For Form Leads</h2> 
	');
	echo('<table class="table-list">');
	echo('<tr>
		<th>Source</th>
		<th>## of leads</th>
		<th>% of sales</th>
		<th>$ amount sold</th>
		</tr>');
	totalPercentSales=0;
	totalAmount=0;
	totalLeads=0;
	for(source in emailsourceCountStruct){
		if(source EQ ""){
			sourceLabel="Direct/Unknown";
		}else{
			sourceLabel=application.zcore.functions.zFirstLetterCaps(source);
		}
		percentSales=numberformat((emailsourceCountStruct[source]/uniqueSaleLeadCount)*100, "_.__");
		totalPercentSales+=percentSales;
		totalLeads+=emailsourceCountStruct[source];
		totalAmount+=emailsourceCountAmount[source];
		
		echo('<tr><td>#sourceLabel#</td><td>#emailsourceCountStruct[source]#</td><td>#percentSales#%</td>
			<td>#dollarformat(emailsourceCountAmount[source])#</td></tr>');
	}
	//assistPercent=numberformat((assistCount/saleCount)*100, "_.__");
	//percentUntrackable=100-(totalPercentSales-assistPercent);
	echo('<tr>
		<th>Total</th>
		<th>#totalLeads#</th>
		<th>#numberformat(totalPercentSales, "_.__")#%</th>
		<th>#dollarformat(totalAmount)#</th>
		</tr>');
	echo('</table><br>');

	echo('
		<h2>Trackable Lead Source Report For Phone Leads</h2>
		<table class="table-list">');
	echo('<tr>
		<th>Source</th>
		<th>## of leads</th>
		<th>% of sales</th>
		<th>$ amount sold</th>
		</tr>');
	totalPercentSales=0;
	totalAmount=0;
	totalLeads=0;
	for(source in phonesourceCountStruct){
		if(source EQ ""){
			sourceLabel="Direct/Unknown";
		}else{
			sourceLabel=application.zcore.functions.zFirstLetterCaps(source);
		}
		percentSales=numberformat((phonesourceCountStruct[source]/uniqueSaleLeadCount)*100, "_.__");
		totalPercentSales+=percentSales;
		totalLeads+=phonesourceCountStruct[source];
		totalAmount+=phonesourceCountAmount[source];

		echo('<tr><td>#sourceLabel#</td><td>#phonesourceCountStruct[source]#</td><td>#percentSales#%</td>
			<td>#dollarformat(phonesourceCountAmount[source])#</td></tr>');
	}
	assistPercent=numberformat((assistCount/saleCount)*100, "_.__");
	//percentUntrackable=100-(totalPercentSales-assistPercent);
	echo('<tr>
		<th>Total</th>
		<th>#totalLeads#</th>
		<th>#numberformat(totalPercentSales, "_.__")#%</th>
		<th>#dollarformat(totalAmount)#</th>
		</tr>');
	echo('</table><br>
	<p>In some cases, a trackable sale was assisted by multiple sources.   #assistPercent#% of the sales involved multiple sources.</p>
	<p>The remaining sales were not able to be shown in the source report, perhaps because they are not attributed to the web or we have incomplete data.</p>');

	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
