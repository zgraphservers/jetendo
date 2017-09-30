<cfcomponent extends="zcorerootmapping.functions.database">
<cfoutput>
<!--- zQueryToStrint(name, query); --->
<cffunction name="zQueryToString" localmode="modern">
    <cfargument name="varName" type="string" required="yes">
    <cfargument name="query" type="query" required="yes">
    <cfscript>
    var arrC=listtoarray(arguments.query.columnlist,",");
    var length=arraylen(arrC);
    var metaData=getmetadata(arguments.query);
    var arrType=arraynew(1);
    var arrColumn=arraynew(1);
    var i=0;
    var n=0;
    var arrR=arraynew(1);
    var newQuery=0;
    for(i=1;i LTE arraylen(metaData);i++){
        arrayappend(arrColumn, replace(metaData[i].name,'"','""',"ALL"));
        arrayappend(arrType, metaData[i].typeName);
    }
    //arrayappend(arrR, arguments.varName&'=queryNew("'&arrayToList(arrColumn, ",")&'", "'&arrayToList(arrType, ",")&'");'&chr(10));
    //arrayappend(arrR, 'QueryAddRow('&arguments.varName&', '&arguments.query.recordcount&');'&chr(10));
    arrayappend(arrR, arguments.varName&'=queryNew("'&arrayToList(arrColumn, ",")&'", "'&arrayToList(arrType, ",")&'", [');
    for(n=1;n LTE arguments.query.recordcount;n++){
        arrayappend(arrR,'[');
        for(i=1;i LTE length;i++){
            if(i NEQ 1){
                arrayappend(arrR, ", ");
            }
            arrayappend(arrR, '"'&replace(arguments.query[arrC[i]][n],'"','""',"ALL")&'"');		
            //arrayappend(arrR, 'QuerySetCell('&arguments.varName&', "'&arrC[i]&'", "'&replace(arguments.query[arrC[i]][n],'"','""',"ALL")&'", '&n&');'&chr(10));				
        }
        arrayappend(arrR,']');
    }
    arrayappend(arrR, ']);'&chr(10));
    return arrayToList(arrR, "");
    </cfscript>
</cffunction>
    
<!--- FUNCTION: zStructToString(name, struct, convertFieldNames, root); --->
<cffunction name="zStructToString" localmode="modern" output="false" returntype="any">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="convertFieldNames" type="boolean" required="no" default="#false#">
	<cfargument name="root" type="boolean" required="no" default="#true#">
	<cfscript>
	var i = 0;
	//var output = "";
	var pos = "";
	var varName = "";
	var arrOutput=ArrayNew(1);
	for(i in arguments.struct){
		i = lcase(i);
		varName = i;
		if(arguments.convertFieldNames){
			pos = find('_', i);
			if(pos NEQ 0){
				varName = removeChars(i, 1, pos);
			}
			varName = replace(varName, '_','','ALL');
		}
		if(isStruct(arguments.struct[i])){
			//ArrayAppend(arrOutput, arguments.name&"."&i&" = StructNew();"&chr(10);
			ArrayAppend(arrOutput, application.zcore.functions.zStructToString(arguments.name&'["'&varName&'"]', arguments.struct[i],arguments.convertFieldNames, false));
		}else if(isNumeric(arguments.struct[i]) and (left(arguments.struct[i],1) NEQ "y" and left(arguments.struct[i],1) NEQ "n")){
			ArrayAppend(arrOutput, arguments.name&'["'&replace(varName,'"','""',"all")&'"] = '&arguments.struct[i]&";"&chr(10));
		}else if(isArray(arguments.struct[i])){
			ArrayAppend(arrOutput, application.zcore.functions.zArrayToString(arguments.name&'["'&varName&'"]', arguments.struct[i],false));
		}else if((arguments.struct[i] EQ true or arguments.struct[i] EQ false) and (left(arguments.struct[i],1) NEQ "y" and left(arguments.struct[i],1) NEQ "n")){
			ArrayAppend(arrOutput, arguments.name&'["'&replace(varName,'"','""',"all")&'"] = '&arguments.struct[i]&";"&chr(10));
		}else if(isSimpleValue(arguments.struct[i])){
			ArrayAppend(arrOutput, arguments.name&'["'&replace(varName,'"','""',"all")&'"] = "'&replace(arguments.struct[i],'"','""',"ALL")&'";'&chr(10));
		}
	}
	if(arguments.root){
		//return "<cfscript>"&chr(10)&arguments.name&" = StructNew();"&chr(10)&output&"</cfscript>";
		return replace(ArrayToList(arrOutput,''),'##','####','ALL');
	}else{
		return ArrayToList(arrOutput,'');
	}
	</cfscript>
</cffunction>


<!--- FUNCTION: zArrayToString(name, array, root); --->
<cffunction name="zArrayToString" localmode="modern" output="false" returntype="any">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="array" type="array" required="yes">
	<cfargument name="root" type="boolean" required="no" default="#true#">
	<cfscript>
	var i = 0;
	//var output = arguments.name&" = ArrayNew(1);"&chr(10);
	var arrOutput=ArrayNew(1);
	var tempVar = "";
	for(i=1;i LTE ArrayLen(arguments.array);i=i+1){
		try{
			i = lcase(i);
			tempVar = arguments.array[i];
			if(isStruct(arguments.array[i])){
				//ArrayAppend(arrOutput, arguments.name&"["&i&"] = StructNew();"&chr(10);
				ArrayAppend(arrOutput, application.zcore.functions.zStructToString(arguments.name&"["&i&"]", arguments.array[i],false));
			}else if(isNumeric(arguments.array[i]) and (left(arguments.array[i],1) NEQ "y" and left(arguments.array[i],1) NEQ "n")){
				ArrayAppend(arrOutput, arguments.name&"["&i&"] = "&arguments.array[i]&";"&chr(10));
			}else if(isArray(arguments.array[i])){
				ArrayAppend(arrOutput, application.zcore.functions.zArrayToString(arguments.name&"["&i&"]", arguments.array[i],false));
			}else if((arguments.array[i] EQ true or arguments.array[i] EQ false) and (left(arguments.array[i],1) NEQ "y" and left(arguments.array[i],1) NEQ "n")){
				ArrayAppend(arrOutput, arguments.name&"["&i&"] = "&arguments.array[i]&";"&chr(10));
			}else if(isSimpleValue(arguments.array[i])){
				ArrayAppend(arrOutput, arguments.name&"["&i&'] = "'&replace(arguments.array[i],'"','""',"ALL")&'";'&chr(10));
			}
		}catch(Any excpt){
		
		}
	}
	if(arguments.root){
		return "<cfscript>"&chr(10)&ArrayToList(arrOutput,'')&"</cfscript>";
	}else{
		return ArrayToList(arrOutput,'');
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>