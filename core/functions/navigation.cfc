<cfcomponent extends="zcorerootmapping.functions.os">
<cfoutput>
<!--- 
	This is the newest search results navbar.  It supports search engine safe URLs (SES) 
	<cfscript>
	// required
	searchStruct = StructNew();
	searchStruct.count = 0;
	searchStruct.index = 0;
	// optional
	searchStruct.ses = true; // use search engine safe URLs
	searchStruct.showString = "Results ";
	searchStruct.url = "";
	searchStruct.indexName = "zIndex";
	searchStruct.buttons = 5;
	searchStruct.count = 0;
	searchStruct.index = 0;
	searchStruct.perpage = 10;
	searchStruct.showPages=true;
	searchStruct.allowUnlimitedPages=false; // only 1000 records can be shown by default. Set to true to allow all to be shown.
	// stylesheet overriding
	searchStruct.tableStyle = "table-searchresults";
	searchStruct.linkStyle = "small-hover";
	searchStruct.textStyle = "small";
	searchStruct.highlightStyle = "highlight";
	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	</cfscript>
--->
<cffunction name="zSearchResultsNav" localmode="modern" returntype="any" output="true">
	<cfargument name="navStruct" required="yes" type="struct">
	<cfscript>
	var tempStruct=0;
	var i = 0;
	var results = "";
	var indexHalfButton = 0;
	var maxButton = 0;
	var halfButtons = 0;
	var special = 0;
	var last = 0;
	var afteradjust = 0;
	var beforeadjust = 0;
	var current = 0;
	var after = 0;
	var before = 0;
	var tempURL = "";
	var dataStruct=StructNew();
	var ts="";
	var noFollowText="";
	// set defaults
	var tempStruct = StructNew();
	dataStruct.arrData=ArrayNew(1);
	tempStruct.ses = false;
	tempStruct.showString = "Results ";
	tempStruct.url = "";
	tempStruct.jsRedirect=false;
	tempStruct.buttons = 5;
	tempStruct.count = 0;
	tempStruct.index = 0;
	tempStruct.noFollow=false;
	tempStruct.showPages=false;
	tempStruct.javascriptPrepend="";
	tempStruct.javascriptAppend="";
	tempStruct.indexName = "zIndex";
	tempStruct.perpage = 10;
	tempStruct.allowUnlimitedPages=false;
	tempStruct.parseURLVariables = false;
	tempStruct.returnDataOnly=false;
	tempStruct.tableStyle = "table-searchresults";
	tempStruct.linkStyle = "small-hover";
	tempStruct.textStyle = "small";
	tempStruct.highlightStyle = "highlight";
	tempStruct.parentIndexPosition = false;
	tempStruct.parentIndexPerPage = false;
	tempStruct.firstPageHack=false;
	// override defaults
	StructAppend(arguments.navStruct, tempStruct, false);
	if(arguments.navStruct.index NEQ 0){
		arguments.navStruct.index = arguments.navStruct.index - 1;
	}
	if(arguments.navStruct.noFollow){
		noFollowText=' rel="nofollow" ';
	}
	
	if(not arguments.navStruct.allowUnlimitedPages and arguments.navStruct.index GT 100){
		arguments.navStruct.index=100;
	}
	if(arguments.navStruct.index * arguments.navStruct.perpage GT arguments.navStruct.count or arguments.navStruct.index * arguments.navStruct.perpage LT 0){	
		if(arguments.navStruct.ses){
			if(arguments.navStruct.parentIndexPosition NEQ false){
				application.zcore.functions.zRedirect(application.zcore.functions.zSesUpdate(arguments.navStruct.url, arguments.navStruct.parentIndexPosition, "1")&"1/",arguments.navStruct.jsRedirect);
			}else{
				application.zcore.functions.zRedirect(arguments.navStruct.url&"1/",arguments.navStruct.jsRedirect);
			}
		}else{
			if(arguments.navStruct.parseURLVariables){
				application.zcore.functions.z301Redirect(replace(arguments.navStruct.url, '##'&arguments.navStruct.indexName&'##', '1', 'one'),arguments.navStruct.jsRedirect);
			}else{
				application.zcore.functions.z301Redirect(application.zcore.functions.zURLAppend(arguments.navStruct.url, arguments.navStruct.indexName&'=1'),arguments.navStruct.jsRedirect);
			}
			//application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"=1"));			
		}
	}
	</cfscript>
	<cfsavecontent variable="results">
		
		<table style="width:100%; border-spacing:0px;" class="#arguments.navStruct.tableStyle#"><tr><td>
		<table style=" border-spacing:0px;" class="#arguments.navStruct.tableStyle#"><tr>
		<cfscript>	
		halfButtons = fix(arguments.navStruct.buttons / 2);
		/*if(1 EQ 0 and arguments.navStruct.buttons mod 2 NEQ 0){
			indexHalfButton = halfButtons - 1;
			maxButton = arguments.navStruct.buttons - 3;
			special = 0;
		}else{*/
			arguments.navStruct.buttons = arguments.navStruct.buttons + 1;
			indexHalfButton = halfButtons - 2;
			maxButton = arguments.navStruct.buttons - 3;
			if(arguments.navStruct.index LTE indexHalfButton){
				special = 1;
			}else{
				special = 0;
			}
		//}
		// this forces a url variable to be set so further variables can be appended to the ?
		if(arguments.navStruct.url EQ ""){
			if(arguments.navStruct.ses){				
				arguments.navStruct.url = application.zcore.functions.zGetSesUp();
			}else{
				arguments.navStruct.url = request.cgi_script_name&"?"&CGI.QUERY_STRING;
			}
		}
		if(arguments.navStruct.allowUnlimitedPages){
			last = ceiling(arguments.navStruct.count / arguments.navStruct.perpage);
		}else{
			last = min(100,ceiling(arguments.navStruct.count / arguments.navStruct.perpage));
			if(arguments.navStruct.index EQ 100){
				if(arguments.navStruct.ses){
					tempURL = arguments.navStruct.url&(100)&"/";
				}else{
					if(arguments.navStruct.parseURLVariables){
						tempURL = replace(arguments.navStruct.url, '##zIndex##', 100, 'one');
					}else{
						tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&100);
					}
				}
				application.zcore.functions.z301Redirect(tempURL);
			}
		}
		afteradjust = 0;
		beforeadjust = 0;
		if(arguments.navStruct.index - 1 LT indexHalfButton){
			afteradjust = halfButtons - arguments.navStruct.index;
		}
		if(last - arguments.navStruct.index LT halfButtons and arguments.navStruct.index - maxButton GTE 0){
			beforeadjust = arguments.navStruct.index - maxButton;
		}
		after = min(halfButtons - special,last - arguments.navStruct.index) + min(last - 1 - arguments.navStruct.index,afteradjust);
		if(last EQ arguments.navStruct.index + after){
			beforeadjust = (arguments.navStruct.buttons-1 - halfButtons - after) + 1;
		}
		before =  min(indexHalfButton,arguments.navStruct.index -1) + beforeadjust;
		if(arguments.navStruct.index EQ 0){
			writeoutput("<td style=""text-align:left; width:95px; "">&nbsp;</td>");
		}
		/*if(Request.zos.isdeveloper){
		writeoutput("index:"&arguments.navStruct.index&"<br>");
		writeoutput("before:"&before&"<br>");
		writeoutput("beforeadjust:"&beforeadjust&"<br>");
		writeoutput("after:"&after&"<br>");
		writeoutput("indexHalfButton:"&indexHalfButton&"<br>");
		writeoutput("maxButton:"&maxButton&"<br>");
		writeoutput("last:"&last&"<br>");
		writeoutput("arguments.navStruct.index:"&arguments.navStruct.index&"<br>");
		}*/
		if(arguments.navStruct.index NEQ 0 and (before GT 0 or arguments.navStruct.index NEQ 0) and arguments.navStruct.count GT arguments.navStruct.perpage){
			if(arguments.navStruct.ses){
				if(arguments.navStruct.parentIndexPosition NEQ false){
					tempURL = application.zcore.functions.zSesUpdate(arguments.navStruct.url, arguments.navStruct.parentIndexPosition, "1")&"1/";
				}else{
					tempURL = arguments.navStruct.url&"1/";
				}
			}else{
				if(arguments.navStruct.firstPageHack){
					tempURL = arguments.navStruct.firstPageURL;
				}else{
					if(arguments.navStruct.parseURLVariables){
						tempURL = replace(arguments.navStruct.url, '##zIndex##', '1', 'one');
					}else{
						tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"=1");
					}
				}
			//	tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"=1");			
			}
			ts=StructNew();
			ts.url=tempURL;
			ts.label="First";
			ArrayAppend(dataStruct.arrData,ts);
			writeoutput("<td><a href="""&htmleditformat(arguments.navStruct.javascriptPrepend&tempURL&arguments.navStruct.javascriptAppend)&""" class=""#arguments.navStruct.linkStyle# #application.zcore.functions.zGetLinkClasses()#"">First</a>");
			if(arguments.navStruct.ses){
				tempURL = arguments.navStruct.url&(arguments.navStruct.index)&"/";
			}else{
				if(arguments.navStruct.firstPageHack and arguments.navStruct.index EQ 1){
						tempURL = arguments.navStruct.firstPageURL;
				}else{
					if(arguments.navStruct.parseURLVariables){
						tempURL = replace(arguments.navStruct.url, '##zIndex##', arguments.navStruct.index, 'one');
					}else{
						tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&arguments.navStruct.index);
					}
				}
				//tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&(arguments.navStruct.index));			
			}
			ts=StructNew();
			ts.url=tempURL;
			ts.label="Previous";
			ArrayAppend(dataStruct.arrData,ts);
			writeoutput("&nbsp;&nbsp;&nbsp;&nbsp;<a #noFollowText# href="""&htmleditformat(arguments.navStruct.javascriptPrepend&tempURL&arguments.navStruct.javascriptAppend)&""" class=""#arguments.navStruct.linkStyle# #application.zcore.functions.zGetLinkClasses()#"">&lt;&nbsp;Previous</a></td>");
			for(i=before;i GTE 0;i=i-1){
				if(arguments.navStruct.index - i - 1 GTE 0){
					if(arguments.navStruct.ses){
						tempURL = arguments.navStruct.url&(arguments.navStruct.index - i)&"/";
					}else{
						if(arguments.navStruct.firstPageHack and arguments.navStruct.index-i EQ 1){
								tempURL = arguments.navStruct.firstPageURL;
						}else{
							if(arguments.navStruct.parseURLVariables){
								tempURL = replace(arguments.navStruct.url, '##zIndex##', arguments.navStruct.index-i, 'one');
							}else{
								tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&(arguments.navStruct.index-i));
							}
						}
						//tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&(arguments.navStruct.index - i));			
					}
					ts=StructNew();
					ts.url=tempURL;
					ts.label=(arguments.navStruct.index - i);
					ArrayAppend(dataStruct.arrData,ts);
					writeoutput("<td style=""text-align:center; width:20px;""><a #noFollowText# href="""&htmleditformat(arguments.navStruct.javascriptPrepend&tempURL&arguments.navStruct.javascriptAppend)&""" class=""#arguments.navStruct.linkStyle# #application.zcore.functions.zGetLinkClasses()#"">"&(arguments.navStruct.index - i)&"</a></td>");
				}
			}
		}
		ts=StructNew();
		ts.url="";
		ts.label=arguments.navStruct.index+1;
		ArrayAppend(dataStruct.arrData,ts);
		writeoutput("<td style=""width:20px; text-align:center;"" class=""#arguments.navStruct.highlightStyle#""><strong>"&arguments.navStruct.index+1 & "</strong></td>");
		if(after GTE 0){
			for(i=1;i LTE after;i=i+1){				
				if(arguments.navStruct.index + i LT last){
					if(arguments.navStruct.ses){
						tempURL = arguments.navStruct.url&(arguments.navStruct.index + i + 1)&"/";
					}else{
						if(arguments.navStruct.parseURLVariables){
							tempURL = replace(arguments.navStruct.url, '##zIndex##', arguments.navStruct.index+i+1, 'one');
						}else{
							tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&(arguments.navStruct.index+i+1));
						}		
					}
					ts=StructNew();
					ts.url=tempURL;
					ts.label=(arguments.navStruct.index + i + 1);
					ArrayAppend(dataStruct.arrData,ts);
					writeoutput("<td style=""width:20px; text-align:center;""><a #noFollowText# href="""&htmleditformat(arguments.navStruct.javascriptPrepend&tempURL&arguments.navStruct.javascriptAppend)&""" class=""#arguments.navStruct.linkStyle# #application.zcore.functions.zGetLinkClasses()#"">"&(arguments.navStruct.index + i + 1)&"</a></td>");
				}
			}
		}
		writeoutput("<td style=""width:95px; text-align:left"">&nbsp;");
		if(after GTE 0 and arguments.navStruct.index NEQ last - 1){
			if(arguments.navStruct.ses){
				tempURL = arguments.navStruct.url&(arguments.navStruct.index + 2)&"/";
			}else{
				if(arguments.navStruct.parseURLVariables){
					tempURL = replace(arguments.navStruct.url, '##zIndex##', arguments.navStruct.index+2, 'one');
				}else{
					tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&(arguments.navStruct.index+2));
				}		
			}
			ts=StructNew();
			ts.url=tempURL;
			ts.label="Next";
			ArrayAppend(dataStruct.arrData,ts);
			writeoutput("<a #noFollowText# href="""&htmleditformat(arguments.navStruct.javascriptPrepend&tempURL&arguments.navStruct.javascriptAppend)&""" class=""#arguments.navStruct.linkStyle# #application.zcore.functions.zGetLinkClasses()#"">Next&nbsp;&gt;</a>");
			if(arguments.navStruct.ses){
				if(arguments.navStruct.parentIndexPosition NEQ false and arguments.navStruct.parentIndexPerPage NEQ false){
					tempURL = application.zcore.functions.zSesUpdate(arguments.navStruct.url, arguments.navStruct.parentIndexPosition, fix(last/arguments.navStruct.parentIndexPerPage))&(last)&"/";
				}else{
					tempURL = arguments.navStruct.url&(last)&"/";
				}
			}else{ 
				if(arguments.navStruct.parseURLVariables){
					tempURL = replace(arguments.navStruct.url, '##zIndex##', last, 'one');
				}else{
					tempURL = application.zcore.functions.zURLAppend(arguments.navStruct.url,arguments.navStruct.indexName&"="&last);
				} 		
			}
			ts=StructNew();
			ts.url=tempURL;
			ts.label="Last";
			ArrayAppend(dataStruct.arrData,ts);
			writeoutput("&nbsp;&nbsp;&nbsp;&nbsp;<a #noFollowText# href="""&htmleditformat(arguments.navStruct.javascriptPrepend&tempURL&arguments.navStruct.javascriptAppend)&""" class=""#arguments.navStruct.linkStyle# #application.zcore.functions.zGetLinkClasses()#"">Last</a></td>");
		}
		current = (arguments.navStruct.index) * arguments.navStruct.perpage;
		last = current+arguments.navStruct.perpage;
		if(current+1 GTE arguments.navStruct.count or arguments.navStruct.perpage EQ 1){
			last = "";
		}else{
			if(last GT arguments.navStruct.count){
				last = "-" & arguments.navStruct.count;
			}else{
				last = "-" & last;
			}	
		}
		if(arguments.navStruct.showPages){
			dataStruct.textPosition = '#arguments.navStruct.count# Total Matches';
		}else{
			dataStruct.textPosition = arguments.navStruct.showString&current+1&last&"&nbsp;of&nbsp;"&arguments.navStruct.count;
		}
		writeoutput("</tr></table></td><td style=""text-align:right"" class=""#arguments.navStruct.textStyle#"">"&dataStruct.textPosition&"</td>");
		</cfscript>
		</tr></table>
		
	</cfsavecontent>
	<cfif arguments.navStruct.returnDataOnly>
		<cfreturn dataStruct>
	<cfelse>
		<cfreturn results>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>