<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
variables.allfields=structnew();
    </cfscript>
<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	var qT=0;
	var curField=0;
	var f2=0;
	var idxExclude=structnew();
	var i=0;
	db.sql="SHOW FIELDS FROM #request.zos.queryObject.table("rets28_property", request.zos.zcoreDatasource)#";
	qT=db.execute("qT");
	variables.allfields=structnew();
	local.n=0;
	</cfscript>
	<cfloop query="qT">
		<cfscript>
		curField=replacenocase(qT.field, "rets28_","");
		if(structkeyexists(application.zcore.listingStruct.mlsStruct["28"].sharedStruct.metaStruct["property"].tableFields, curField)){
		f2=application.zcore.listingStruct.mlsStruct["28"].sharedStruct.metaStruct["property"].tableFields[curField].longname;
		}else{
		f2=curField;
		}
		local.n++;
		variables.allfields[local.n]={field:qT.field, label:f2};
		</cfscript>
	</cfloop>
	<cfscript>  
	application.zcore.listingCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
	// force allfields to not have the fields that already used
	this.getDetailCache1(structnew());
	this.getDetailCache2(structnew());
	this.getDetailCache3(structnew());
	 
	if(structcount(variables.allfields) NEQ 0){
		//writeoutput('<h2>All Fields:</h2>');
		local.arrKey=structsort(variables.allfields, "text", "asc", "label");
		for(i=1;i LTE arraylen(local.arrKey);i++){
			if(structkeyexists(idxExclude, variables.allfields[local.arrKey[i]].field) EQ false){
				writeoutput('idxTemp2["'&variables.allfields[local.arrKey[i]].field&'"]="'&replace(application.zcore.functions.zfirstlettercaps(variables.allfields[local.arrKey[i]].label),"##","####")&'";<br />');
			}
		}
	}
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();  

//idxTemp2["rets28_list_44"]="## Parking"; 
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	    
	//arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Rental Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	   
	return arraytolist(arrR,'');
	
	</cfscript>
</cffunction>

<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();  
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Room Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	return arraytolist(arrR,'');
	
	
	
	</cfscript>
</cffunction>

<cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();  
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial / Legal Info", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	return arraytolist(arrR,'');
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>