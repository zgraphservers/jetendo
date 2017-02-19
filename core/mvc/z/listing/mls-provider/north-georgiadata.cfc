<cfcomponent>
<cfoutput>
<cfscript>
variables.idxExclude=structnew();
variables.allfields=structnew();
</cfscript>
<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" output="yes" returntype="any">
	not implemented
	
	<cfscript>application.zcore.functions.zabort();</cfscript>
</cffunction>

<!--- <table class="ztablepropertyinfo"> --->
<cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();
	idxTemp2["ngm_coventants"]="covenants:";
	idxTemp2["ngm_fetappliances"]="appliances:";
	idxTemp2["ngm_fetbasement"]="basement:";
	idxTemp2["ngm_fetbusinesstype"]="business type:";
	idxTemp2["ngm_fetcondition"]="condition:";
	idxTemp2["ngm_fetconstruction"]="construction:";
	idxTemp2["ngm_fetcooling"]="cooling:";
	idxTemp2["ngm_fetdesign"]="design:";
	idxTemp2["ngm_fetdriveway"]="driveway:";
	idxTemp2["ngm_fetexterior"]="exterior:";
	idxTemp2["ngm_fetfloors"]="floors:";
	idxTemp2["ngm_fetfrontage"]="frontage:";
	idxTemp2["ngm_fetheating"]="heating:";
	idxTemp2["ngm_fetinterior"]="interior:";
	idxTemp2["ngm_fetlake"]="lake:";
	idxTemp2["ngm_fetlaundrylocation"]="laundry location:";
	idxTemp2["ngm_fetmasterbedroom"]="master bedroom:";
	idxTemp2["ngm_fetmilestotown"]="miles to town:";
	idxTemp2["ngm_fetparking"]="parking:";
	idxTemp2["ngm_fetrecreation"]="recreation:";
	idxTemp2["ngm_fetrestrictions"]="restrictions:";
	idxTemp2["ngm_fetroadsurface"]="road surface:";
	idxTemp2["ngm_fetroof"]="roof:";
	idxTemp2["ngm_fetrooms"]="rooms:";
	idxTemp2["ngm_fetsaleincludes"]="sale includes:";
	idxTemp2["ngm_fetsewer"]="sewer:";
	idxTemp2["ngm_fetstyle"]="style:";
	idxTemp2["ngm_fetterrain"]="terrain:";
	idxTemp2["ngm_fetview"]="view:";
	idxTemp2["ngm_fetwater"]="water:";
	idxTemp2["ngm_fetwindows"]="windows:";
	idxTemp2["ngm_foreclosure"]="foreclosure:";
	idxTemp2["ngm_lakename"]="lake name:";
	idxTemp2["ngm_licensedowner"]="licensed owner:";
	idxTemp2["ngm_lotnumber"]="lot number:";
	idxTemp2["ngm_lotsize"]="lot size:";
	idxTemp2["ngm_lowerflrbedrooms"]="lower floor bedrooms:";
	idxTemp2["ngm_lstarea"]="list area:";
	idxTemp2["ngm_lstpropertytype"]="property type:";
	idxTemp2["ngm_mainflrbedrms"]="main floor bedrms:";
	idxTemp2["ngm_numofunits"]="number of units:";
	idxTemp2["ngm_rivername"]="river name:";
	idxTemp2["ngm_state"]="state:";
	idxTemp2["ngm_subdivision"]="subdivision:";
	idxTemp2["ngm_surveyavailable"]="survey available:";
	idxTemp2["ngm_totalrooms"]="total rooms:";
	idxTemp2["ngm_township"]="township:";
	idxTemp2["ngm_upperflrbedrms"]="upper floor bedrms:";
	idxTemp2["ngm_zoningcode"]="zoning code:";
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	return arraytolist(arrR,'');
	</cfscript>
</cffunction>

<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();
	return arraytolist(arrR,'');
	</cfscript>
</cffunction>

<cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();
	return arraytolist(arrR,'');
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>