<cfcomponent displayname="Query Sorting System" hint="Provides easy to implement session based tracking of ascending and descending sorting on multiple columns of a query at once." output="no">
	<cfoutput><cfscript>
	// init() must be called for this component to work.
	this.id = 0;
	// you can override these icons in your scripts.
	this.icons = StructNew();
	/*if(request.zos.cgi.server_port EQ 443){
		this.icons.up = '/z/images/icons/up_triangle.gif';
		this.icons.down = '/z/images/icons/down_triangle.gif';
	}else{*/
		this.icons.up = '/z/images/icons/up_triangle.gif';
		this.icons.down = '/z/images/icons/down_triangle.gif';
	//}
	</cfscript>

	<!--- sortId = sortCom.init(sortVarName); --->
	<cffunction name="init" localmode="modern" returntype="any" hint="Forces status session to exist." output="false">
		<cfargument name="sortVarName" type="string" hint="The variable name of the status session variable. This is also prepended to the variables used in the query string when the user changes the sorting." required="no" default="zSortId">
		<cfscript>
		this.sortVarName = arguments.sortVarName;
		if(structkeyexists(form, this.sortVarName)){
			// use existing status session
			this.id = form[this.sortVarName];
		}else{
			// use new status session id
			this.id = application.zcore.status.getNewId();
		}
		return this.id;
		</cfscript>
	</cffunction>

	<!--- sortCom.getOrderBy(showOrderBy); --->
	<cffunction name="getOrderBy" localmode="modern" returntype="any" output="false">
		<cfargument name="showOrderBy" hint="If you set showOrderBy to false, you must called this function before your sort fields in the query. Example: ORDER BY ##sortCom.getOrderBy(false)## table_field ASC" required="yes" type="boolean" default="#true#">
		<cfscript>
		var i=0;
		var arrOrder = ArrayNew(1);
		var sortStruct = "";
		var sortOrder = "";
		var exists=0;
		var arrSortOrder = "";
		// get query string vars
		var sortDirection = application.zcore.functions.zso(form, ''&this.sortVarName&'_d');
		var sortField = application.zcore.functions.zso(form, ''&this.sortVarName&'_f');
		
		// get sort data
		sortStruct = application.zcore.status.getField(this.id,'sortStruct', StructNew());
		arrSortOrder = application.zcore.status.getField(this.id,'arrSortOrder', ArrayNew(1));
		
		// check for existence of query string variables used for changing the sorting
		if(len(sortField) NEQ 0){
			exists = false;
			// rebuild order array ignoring the sortField if the sortDirection is an empty string
			for(i=1;i LTE ArrayLen(arrSortOrder);i=i+1){
				if(arrSortOrder[i] EQ sortField){
					exists = true;
					if(len(sortDirection) NEQ 0){
						ArrayAppend(arrOrder, arrSortOrder[i]);
					}
				}else{
					ArrayAppend(arrOrder, arrSortOrder[i]);
				}
			}
			// add field to end of list if it doesn't already exist
			if(exists EQ false and len(sortDirection) NEQ 0){
				ArrayAppend(arrOrder, sortField);
			}
			arrSortOrder = arrOrder;
			if(len(sortDirection) EQ ""){
				// remove column when query string is an empty string
				StructDelete(sortStruct, sortField);
			}else{
				// add column when query string has a sort value
				StructInsert(sortStruct, sortField, sortDirection,true);
			}
			// store sort config in status session
			application.zcore.status.setField(this.id, "sortStruct", sortStruct);
			application.zcore.status.setField(this.id, "arrSortOrder", arrSortOrder);
		}
		// get sort config from status session
		sortStruct = application.zcore.status.getField(this.id,'sortStruct', StructNew());
		arrSortOrder = application.zcore.status.getField(this.id,'arrSortOrder', ArrayNew(1));
		if(StructCount(sortStruct) NEQ 0){
			arrOrder = ArrayNew(1);
			// build order by statement
			for(i=1;i LTE ArrayLen(arrSortOrder);i=i+1){
				ArrayAppend(arrOrder, arrSortOrder[i]&" "&sortStruct[arrSortOrder[i]]);
			}
			if(ArrayLen(arrOrder) NEQ 0){
				if(arguments.showOrderBy){
					// output complete order by statement
					return " ORDER BY "&ArrayToList(arrOrder)&" ";
				}else{
					// output sort statement without order by
					return ArrayToList(arrOrder)&", ";
				}
			}
		}
		return "";
		</cfscript>
	</cffunction>
	
	
	
	<!--- sortCom.getColumnURL(fieldName, prependURL); --->
	<cffunction name="getColumnURL" localmode="modern" returntype="any" output="false">
		<cfargument name="fieldName" hint="Form field name" required="yes" type="string">
		<cfargument name="prependURL" hint="No sort variables should appear in this URL." required="yes" type="string">
		<cfscript>
		var sortStruct = application.zcore.status.getField(this.id, 'sortStruct', StructNew());
		var current = "";
		if(structkeyexists(sortStruct,arguments.fieldName)){
			current = sortStruct[arguments.fieldName];
		}
		if(len(current) EQ 0){
			// return link to set ascending sort
			return application.zcore.functions.zURLAppend(arguments.prependURL,'#this.sortVarName#=#this.id#&#this.sortVarName#_f=#arguments.fieldName#&#this.sortVarName#_d=ASC');
		}else if(current EQ "ASC"){
			// show link to set descending sort
			return application.zcore.functions.zURLAppend(arguments.prependURL,'#this.sortVarName#=#this.id#&#this.sortVarName#_f=#arguments.fieldName#&#this.sortVarName#_d=DESC');
		}else if(current EQ "DESC"){
			// show link to turn off sorting
			return application.zcore.functions.zURLAppend(arguments.prependURL,'#this.sortVarName#=#this.id#&#this.sortVarName#_f=#arguments.fieldName#&#this.sortVarName#_d=');	
		}		
		</cfscript>
	</cffunction>
	
	<!--- sortCom.getColumnIcon(fieldName); --->
	<cffunction name="getColumnIcon" localmode="modern" returntype="any" output="false">
		<cfargument name="fieldName" hint="Form field name" required="yes" type="string">
		<cfscript>
		var sortStruct = application.zcore.status.getField(this.id, 'sortStruct', StructNew());
		var current = "";
		if(structkeyexists(sortStruct,arguments.fieldName)){
			current = sortStruct[arguments.fieldName];
		}
		if(len(current) EQ 0){
			// return link to set ascending sort
			return '';
		}else if(current EQ "ASC"){
			return ' <i class="fa fa-caret-up" aria-hidden="true"></i> ';//<img src="#this.icons.up#">';
		}else if(current EQ "DESC"){
			return ' <i class="fa fa-caret-down" aria-hidden="true"></i> ';//<img src="#this.icons.down#">';
		}		
		</cfscript>
	</cffunction>
	
	<!--- sortCom.setDefault(fieldList, sortList); --->
	<cffunction name="setDefault" localmode="modern" returntype="any" output="false">
		<cfargument name="fieldList" type="string" required="yes">
		<cfargument name="sortList" type="string" required="yes">
		<cfscript>
		var i=0;
		var sortStruct = StructNew();
		var arrSortOrder = ArrayNew(1);
		var sortDirection = application.zcore.functions.zso(form, ''&this.sortVarName&'_f');
		if(sortDirection EQ ''){
			for(i=1;i LTE listLen(arguments.fieldList);i=i+1){
				StructInsert(sortStruct, listGetAt(arguments.fieldList, i), listGetAt(arguments.sortList,i),true);
				ArrayAppend(arrSortOrder, listGetAt(arguments.fieldList, i));		
			}
			application.zcore.status.setField(this.id, "sortStruct", sortStruct);
			application.zcore.status.setField(this.id, "arrSortOrder", arrSortOrder);
		}
		return true;
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>