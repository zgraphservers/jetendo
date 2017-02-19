<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" output="yes" returntype="any">
		<cfscript>
		var db=request.zos.queryObject;
		</cfscript>
    	not implemented
		<cfscript>application.zcore.functions.zabort();</cfscript>
	</cffunction>

    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		/*
		idxTemp2["rets18_agentlist"]="agentlist:";
		idxTemp2["rets18_agentlist_fullname"]="agentlist fullname:";
		idxTemp2["rets18_agentsell_fullname"]="agentsell fullname:";
		*/
		idxTemp2["rets18_area"]="area:";
		idxTemp2["rets18_county"]="county:";
		idxTemp2["rets18_unitnum"]="unit number:";
		idxTemp2["rets18_yearbuilt"]="year built:";
		idxTemp2["rets18_yearbuiltdesc"]="year built  description:";
		
		
		idxTemp2["rets18_appliancesyn"]="appliances y/n:";
		idxTemp2["rets18_ceilingheight"]="ceiling height:";
		
		idxTemp2["rets18_agexemption"]="ag exemption:";
		idxTemp2["rets18_barndesc"]="barn  description:";
		idxTemp2["rets18_commonfeatures"]="common features:";
		idxTemp2["rets18_compd"]="compd:";
		idxTemp2["rets18_complexname"]="complex name:";
		idxTemp2["rets18_construction"]="construction:";
		idxTemp2["rets18_coveredspacestotal"]="covered spaces total:";
		idxTemp2["rets18_cropprogram"]="crop program:";
		idxTemp2["rets18_crops"]="crops:";
		idxTemp2["rets18_development"]="development:";
		idxTemp2["rets18_directions"]="directions:";
		idxTemp2["rets18_doorsfreight"]="doors freight:";
		idxTemp2["rets18_energy"]="energy:";
		idxTemp2["rets18_equipment"]="equipment:";
		idxTemp2["rets18_exterior"]="exterior:";
		idxTemp2["rets18_features"]="features:";
		idxTemp2["rets18_fence"]="fence:";
		idxTemp2["rets18_fencedyard"]="fenced yard:";
		idxTemp2["rets18_fireplacedesc"]="fireplace  description:";
		idxTemp2["rets18_fireplaces"]="fireplaces:";
		idxTemp2["rets18_floors"]="floors:";
		idxTemp2["rets18_foundation"]="foundation:";
		idxTemp2["rets18_frontagefeet"]="frontage feet:";
		idxTemp2["rets18_furnished"]="furnished:";
		idxTemp2["rets18_garagecap"]="garage cap:";
		idxTemp2["rets18_garagedesc"]="garage description:";
		idxTemp2["rets18_greencertification"]="green certification:";
		idxTemp2["rets18_greenfeatures"]="green features:";
		idxTemp2["rets18_handicap"]="handicap:";
		idxTemp2["rets18_handicapyn"]="handicap y/n:";
		idxTemp2["rets18_heatsystem"]="heat system:";
		idxTemp2["rets18_housingtype"]="housing type:";
		idxTemp2["rets18_interior"]="interior:";
		idxTemp2["rets18_internetaddryn"]="internet addr y/n:";
		idxTemp2["rets18_internetdisplayyn"]="internet display y/n:";
		idxTemp2["rets18_internetlist_all"]="internet list all:";
		idxTemp2["rets18_listprice"]="list price:";
		idxTemp2["rets18_listpricelow"]="list price low:";
		idxTemp2["rets18_listpriceorig"]="list price original:";
		idxTemp2["rets18_listpricerange"]="list price range:";
		idxTemp2["rets18_liststatus"]="list status:";
		idxTemp2["rets18_liststatusflag"]="list status flag:";
		idxTemp2["rets18_lotdesc"]="lot description:";
		idxTemp2["rets18_lotdim"]="lot dimension:";
		idxTemp2["rets18_lotnum"]="lot number:";
		idxTemp2["rets18_lotsize"]="lot size:";
		idxTemp2["rets18_lotssoldpkg"]="lots sold package:";
		idxTemp2["rets18_lotssoldsep"]="lots sold sep:";
		idxTemp2["rets18_mapbook"]="map book:";
		idxTemp2["rets18_mapcoord"]="map coordinates:";
		idxTemp2["rets18_mappage"]="map page:";
		idxTemp2["rets18_miscellaneous"]="miscellaneous:";
		idxTemp2["rets18_mlsnum"]="mls number:"; 
		idxTemp2["rets18_muddistrict"]="mud district:";
		idxTemp2["rets18_openhousedate"]="open house date:";
		idxTemp2["rets18_openhousetime"]="open house time:";
		idxTemp2["rets18_parcelsmultiple"]="parcels multiple:";
		idxTemp2["rets18_petfee"]="pet fee:";
		idxTemp2["rets18_pets"]="pets:";
		idxTemp2["rets18_photoaerialavail"]="photo aerial avail:";
		idxTemp2["rets18_planneddevelopment"]="planned development:";
		idxTemp2["rets18_pooldesc"]="pool description:";
		idxTemp2["rets18_poolyn"]="pool y/n:";
		idxTemp2["rets18_possession"]="possession:";
		idxTemp2["rets18_presentuse"]="present use:";
		idxTemp2["rets18_propertyassociation"]="property association:";
		idxTemp2["rets18_proposeduse"]="proposed use:";
		idxTemp2["rets18_propsubtype"]="property sub type:";
		idxTemp2["rets18_propsubtypedisplay"]="property sub type display:";
		idxTemp2["rets18_proptype"]="property type:";
		idxTemp2["rets18_ranchname"]="ranch name:";
		idxTemp2["rets18_ranchtype"]="ranch type:";
		idxTemp2["rets18_roadfrontage"]="road frontage:";
		idxTemp2["rets18_roadfrontagedesc"]="road frontage description:";
		idxTemp2["rets18_roof"]="roof:";
		idxTemp2["rets18_security"]="security:";
		idxTemp2["rets18_securitydesc"]="security  description:";
		idxTemp2["rets18_showing"]="showing:";
		idxTemp2["rets18_soiltype"]="soiltype:";
		idxTemp2["rets18_specialnotes"]="special notes:";
		idxTemp2["rets18_sqftbuilding"]="sqft building:";
		idxTemp2["rets18_sqftgross"]="sqft gross:";
		idxTemp2["rets18_sqftgrprice"]="sqft gr price:";
		idxTemp2["rets18_sqftland"]="sqft land:";
		idxTemp2["rets18_sqftleasable"]="sqft leasable:";
		idxTemp2["rets18_sqftlot"]="sqft lot:";
		idxTemp2["rets18_sqftlotprice"]="sqft lot price:";
		idxTemp2["rets18_sqftprice"]="sqf tprice:";
		idxTemp2["rets18_sqftsource"]="sqft source:";
		idxTemp2["rets18_sqftsourceland"]="sqft source land:";
		idxTemp2["rets18_sqfttotal"]="sqft total:";
		idxTemp2["rets18_state"]="state:";
		idxTemp2["rets18_stories"]="stories:";
		idxTemp2["rets18_storiesbldg"]="building stories:";
		idxTemp2["rets18_streetdir"]="street direction:";
		idxTemp2["rets18_streetdirsuffix"]="street direction suffix:";
		idxTemp2["rets18_streetname"]="street name:";
		idxTemp2["rets18_streetnum"]="street number:";
		idxTemp2["rets18_streetnumdisplay"]="street number display:";
		idxTemp2["rets18_streettype"]="street type:";
		idxTemp2["rets18_style"]="style:";
		idxTemp2["rets18_subarea"]="sub area:";
		idxTemp2["rets18_subdivide"]="subdivide:";
		idxTemp2["rets18_subdivided"]="subdivided:";
		idxTemp2["rets18_subdivision"]="subdivision:";
		idxTemp2["rets18_tenancy"]="tenancy:";
		idxTemp2["rets18_topography"]="topography:";
		idxTemp2["rets18_uidprp"]="uid prp:";
		idxTemp2["rets18_utilities"]="utilities:";
		idxTemp2["rets18_utilitiesother"]="utilities other:";
		idxTemp2["rets18_vowavmyn"]="vowavm y/n:";
		idxTemp2["rets18_vowcommyn"]="vowcomm y/n:";
		idxTemp2["rets18_walls"]="walls:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		
		idxTemp2["rets18_schooldistrict"]="school district:";
		idxTemp2["rets18_schoolname1"]="school name 1:";
		idxTemp2["rets18_schoolname2"]="school name 2:";
		idxTemp2["rets18_schoolname3"]="school name 3:";
		idxTemp2["rets18_schoolname4"]="school name 4:";
		idxTemp2["rets18_schooltype1"]="school type 1:";
		idxTemp2["rets18_schooltype2"]="school type 2:";
		idxTemp2["rets18_schooltype3"]="school type 3:";
		idxTemp2["rets18_schooltype4"]="school type 4:";
		idxTemp2["rets18_zoning"]="zoning:";
		idxTemp2["rets18_zoninginfo"]="zoninginfo:";
		idxTemp2["rets18_zoningmulti"]="zoningmulti:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Zoning Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets18_barn1length"]="barn 1 length:";
		idxTemp2["rets18_barn1width"]="barn 1 width:";
		idxTemp2["rets18_barn2length"]="barn 2 length:";
		idxTemp2["rets18_barn2width"]="barn 2 width:";
		idxTemp2["rets18_barn3length"]="barn 3 length:";
		idxTemp2["rets18_barn3width"]="barn 3 width:";
		idxTemp2["rets18_bathsfullbasement"]="baths full basement:";
		idxTemp2["rets18_bathsfulllevel1"]="baths full level 1:";
		idxTemp2["rets18_bathsfulllevel2"]="baths full level 2:";
		idxTemp2["rets18_bathsfulllevel3"]="baths full level 3:";
		idxTemp2["rets18_bathshalfbasement"]="baths half basement:";
		idxTemp2["rets18_bathshalflevel1"]="baths half level 1:";
		idxTemp2["rets18_bathshalflevel2"]="baths half level 2:";
		idxTemp2["rets18_bathshalflevel3"]="baths half level 3:";
		idxTemp2["rets18_unit1bathsfull"]="unit 1 baths full:";
		idxTemp2["rets18_unit1bathshalf"]="unit 1 baths half:";
		idxTemp2["rets18_unit1beds"]="unit 1 beds:";
		idxTemp2["rets18_unit1lease"]="unit 1 lease:";
		idxTemp2["rets18_unit1sqft"]="unit 1 sqft:";
		idxTemp2["rets18_unit1units"]="unit 1 units:";
		idxTemp2["rets18_unit2bathsfull"]="unit 2 baths full:";
		idxTemp2["rets18_unit2bathshalf"]="unit 2 baths half:";
		idxTemp2["rets18_unit2beds"]="unit 2 beds:";
		idxTemp2["rets18_unit2lease"]="unit 2 lease:";
		idxTemp2["rets18_unit2sqft"]="unit 2 sqft:";
		idxTemp2["rets18_unit2units"]="unit 2 units:";
		idxTemp2["rets18_unit3bathsfull"]="unit 3 baths full:";
		idxTemp2["rets18_unit3bathshalf"]="unit 3 baths half:";
		idxTemp2["rets18_unit3beds"]="unit 3 beds:";
		idxTemp2["rets18_unit3lease"]="unit 3 lease:";
		idxTemp2["rets18_unit3sqft"]="unit 3 sqft:";
		idxTemp2["rets18_unit3units"]="unit 3 units:";
		idxTemp2["rets18_unit4bathsfull"]="unit 4 baths full:";
		idxTemp2["rets18_unit4bathshalf"]="unit 4 baths half:";
		idxTemp2["rets18_unit4beds"]="unit 4 beds:";
		idxTemp2["rets18_unit4lease"]="unit 4 lease:";
		idxTemp2["rets18_unit4sqft"]="unit 4 sqft:";
		idxTemp2["rets18_unit4units"]="unit 4 units:";
		idxTemp2["rets18_unitfloornum"]="unit floor number:";
		idxTemp2["rets18_roombed2length"]="room bed 2 length:";
		idxTemp2["rets18_roombed2level"]="room bed 2  level:";
		idxTemp2["rets18_roombed2width"]="room bed 2 width:";
		idxTemp2["rets18_roombed3length"]="room bed 3 length:";
		idxTemp2["rets18_roombed3level"]="room bed 3 level:";
		idxTemp2["rets18_roombed3width"]="room bed 3 width:";
		idxTemp2["rets18_roombed4length"]="room bed 4 length:";
		idxTemp2["rets18_roombed4level"]="room bed 4 level:";
		idxTemp2["rets18_roombed4width"]="room bed 4 width:";
		idxTemp2["rets18_roombed5length"]="room bed 5 length:";
		idxTemp2["rets18_roombed5level"]="room bed 5 level:";
		idxTemp2["rets18_roombed5width"]="room bed 5 width:";
		idxTemp2["rets18_roombedbathdesc"]="room bed bath description:";
		idxTemp2["rets18_roombreakfastlength"]="room breakfast length:";
		idxTemp2["rets18_roombreakfastlevel"]="room breakfast level:";
		idxTemp2["rets18_roombreakfastwidth"]="room breakfast width:";
		idxTemp2["rets18_roomdininglength"]="room dining length:";
		idxTemp2["rets18_roomdininglevel"]="room dining level:";
		idxTemp2["rets18_roomdiningwidth"]="room dining width:";
		idxTemp2["rets18_roomgaragelength"]="room garage length:";
		idxTemp2["rets18_roomgaragewidth"]="room garage width:";
		idxTemp2["rets18_roomkitchendesc"]="room kitchen description:";
		idxTemp2["rets18_roomkitchenlength"]="room kitchen length:";
		idxTemp2["rets18_roomkitchenlevel"]="room kitchen level:";
		idxTemp2["rets18_roomkitchenwidth"]="room kitchen width:";
		idxTemp2["rets18_roomliving1length"]="room living 1 length:";
		idxTemp2["rets18_roomliving1level"]="room living 1 level:";
		idxTemp2["rets18_roomliving1width"]="room living 1 width:";
		idxTemp2["rets18_roomliving2length"]="room living 2 length:";
		idxTemp2["rets18_roomliving2level"]="room living 2 level:";
		idxTemp2["rets18_roomliving2width"]="room living 2 width:";
		idxTemp2["rets18_roomliving3length"]="room living 3 length:";
		idxTemp2["rets18_roomliving3level"]="room living 3 level:";
		idxTemp2["rets18_roomliving3width"]="room living 3 width:";
		idxTemp2["rets18_roommasterbedlength"]="room master bed length:";
		idxTemp2["rets18_roommasterbedlevel"]="room master bed level:";
		idxTemp2["rets18_roommasterbedwidth"]="room master bed width:";
		idxTemp2["rets18_roomother"]="room other:";
		idxTemp2["rets18_roomother1length"]="room other 1 length:";
		idxTemp2["rets18_roomother1level"]="room other 1 level:";
		idxTemp2["rets18_roomother1width"]="room other 1 width:";
		idxTemp2["rets18_roomother2length"]="room other 2 length:";
		idxTemp2["rets18_roomother2level"]="room other 2 level:";
		idxTemp2["rets18_roomother2width"]="room other 2 width:";
		idxTemp2["rets18_roomstudylength"]="room study length:";
		idxTemp2["rets18_roomstudylevel"]="room study level:";
		idxTemp2["rets18_roomstudywidth"]="room study width:";
		idxTemp2["rets18_roomutildesc"]="room util description:";
		idxTemp2["rets18_roomutilitylength"]="room utility length:";
		idxTemp2["rets18_roomutilitylevel"]="room utility level:";
		idxTemp2["rets18_roomutilitywidth"]="room utility width:";
		idxTemp2["rets18_unit1diningarealength"]="unit 1 dining area length:";
		idxTemp2["rets18_unit1diningareawidth"]="unit 1 dining area width:";
		idxTemp2["rets18_unit1kitchenlength"]="unit 1 kitchen length:";
		idxTemp2["rets18_unit1kitchenwidth"]="unit 1 kitchen width:";
		idxTemp2["rets18_unit1livingarealength"]="unit 1 living area length:";
		idxTemp2["rets18_unit1livingareawidth"]="unit 1 living area width:";
		idxTemp2["rets18_unit1masterbedlength"]="unit 1 master bed length:";
		idxTemp2["rets18_unit1masterbedwidth"]="unit 1 master bed width:";
		idxTemp2["rets18_unit2diningarealength"]="unit 2 dining area length:";
		idxTemp2["rets18_unit2diningareawidth"]="unit 2 dining area width:";
		idxTemp2["rets18_unit2kitchenlength"]="unit 2 kitchen length:";
		idxTemp2["rets18_unit2kitchenwidth"]="unit 2 kitchen width:";
		idxTemp2["rets18_unit2livingarealength"]="unit 2 living area length:";
		idxTemp2["rets18_unit2livingareawidth"]="unit 2 living area width:";
		idxTemp2["rets18_unit2masterbedlength"]="unit 2 master bed length:";
		idxTemp2["rets18_unit2masterbedwidth"]="unit 2 master bed width:";
		idxTemp2["rets18_unit3diningarealength"]="unit 3 dining area length:";
		idxTemp2["rets18_unit3diningareawidth"]="unit 3 dining area width:";
		idxTemp2["rets18_unit3kitchenlength"]="unit 3 kitchen length:";
		idxTemp2["rets18_unit3kitchenwidth"]="unit 3 kitchen width:";
		idxTemp2["rets18_unit3livingarealength"]="unit 3 living area length:";
		idxTemp2["rets18_unit3livingareawidth"]="unit 3 living area width:";
		idxTemp2["rets18_unit3masterbedlength"]="unit 3 master bed length:";
		idxTemp2["rets18_unit3masterbedwidth"]="unit 3 master bed width:";
		idxTemp2["rets18_unit4diningarealength"]="unit 4 dining area length:";
		idxTemp2["rets18_unit4diningareawidth"]="unit 4 dining area width:";
		idxTemp2["rets18_unit4kitchenlength"]="unit 4 kitchen length:";
		idxTemp2["rets18_unit4kitchenwidth"]="unit 4 kitchen width:";
		idxTemp2["rets18_unit4livingarealength"]="unit 4 living area length:";
		idxTemp2["rets18_unit4livingareawidth"]="unit 4 living area width:";
		idxTemp2["rets18_unit4masterbedlength"]="unit 4 master bed length:";
		idxTemp2["rets18_unit4masterbedwidth"]="unit 4 master bed width:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Room Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		idxTemp2["rets18_acres"]="acres:";
		idxTemp2["rets18_acresbottomland"]="acres bottom land:";
		idxTemp2["rets18_acrescultivated"]="acres cultivated:";
		idxTemp2["rets18_acresirrigated"]="acres irrigated:";
		idxTemp2["rets18_acrespasture"]="acres pasture:";
		idxTemp2["rets18_acresprice"]="acres price:";
		idxTemp2["rets18_block"]="block:";
		idxTemp2["rets18_building"]="building:";
		idxTemp2["rets18_buildingnum"]="building number:";
		idxTemp2["rets18_buildinguse"]="building use:";
		idxTemp2["rets18_carportcap"]="carport cap:";
		idxTemp2["rets18_numbarn1stalls"]="number barn 1 stalls:";
		idxTemp2["rets18_numbarn2stalls"]="number barn 2 stalls:";
		idxTemp2["rets18_numbarn3stalls"]="number barn 3 stalls:";
		idxTemp2["rets18_numbarns"]="number barns:";
		idxTemp2["rets18_numbuilding"]="building number:";
		idxTemp2["rets18_numcars"]="number cars:";
		idxTemp2["rets18_numdays"]="number days:";
		idxTemp2["rets18_numdiningareas"]="number dining areas:";
		idxTemp2["rets18_numlakes"]="number lakes:";
		idxTemp2["rets18_numleasespaces"]="number lease spaces:";
		idxTemp2["rets18_numlivingareas"]="number living areas:";
		idxTemp2["rets18_numlots"]="number lots:";
		idxTemp2["rets18_numparking"]="number parking:";
		idxTemp2["rets18_numpets"]="number pets:";
		idxTemp2["rets18_numponds"]="number ponds:";
		idxTemp2["rets18_numresidence"]="number residence:";
		idxTemp2["rets18_numspacesleased"]="number spaces leased:";
		idxTemp2["rets18_numstocktanks"]="number stock tanks:";
		idxTemp2["rets18_numunits"]="number units:";
		idxTemp2["rets18_numwatermeters"]="number water meters:";
		idxTemp2["rets18_numwells"]="number wells:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Building &amp; Land Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets18_dateavail"]="date available:";
		idxTemp2["rets18_assocfee"]="association fee:";
		idxTemp2["rets18_assocfeeincludes"]="association fee includes:";
		idxTemp2["rets18_assocfeepaid"]="association fee paid:";
		idxTemp2["rets18_depositamount"]="deposit amount:";
		idxTemp2["rets18_depositpet"]="deposit pet:";
		idxTemp2["rets18_documents"]="documents:";
		idxTemp2["rets18_easements"]="easements:";
		idxTemp2["rets18_expensegross"]="expense gross:";
		idxTemp2["rets18_expenseinsurance"]="expense insurance:";
		idxTemp2["rets18_expensetenant"]="expense tenant:";
		idxTemp2["rets18_expensetotalincludes"]="expense total includes:";
		idxTemp2["rets18_expiredatelease"]="expire date lease:";
		idxTemp2["rets18_expppvtdisplay"]="exp ppvt display:";
		idxTemp2["rets18_caprate"]="cap rate:";
		idxTemp2["rets18_forlease"]="for lease:";
		idxTemp2["rets18_incexpsource"]="inc exp source:";
		idxTemp2["rets18_inclusions"]="inclusions:";
		idxTemp2["rets18_incomegross"]="income gross:";
		idxTemp2["rets18_incomegrossmultiply"]="income gross multiply:";
		idxTemp2["rets18_incomenetoperating"]="income net operating:";
		idxTemp2["rets18_landlease"]="land lease:";
		idxTemp2["rets18_leaselength"]="lease length:";
		idxTemp2["rets18_leasemonth"]="lease month:";
		idxTemp2["rets18_leaseratemax"]="lease rate max:";
		idxTemp2["rets18_leaseratemin"]="lease rate min:";
		idxTemp2["rets18_leaserequired"]="lease required:";
		idxTemp2["rets18_leaseterms"]="lease terms:";
		idxTemp2["rets18_leasetype"]="lease type:";
		idxTemp2["rets18_legal"]="legal:";
		idxTemp2["rets18_lesseepays"]="lessee pays:";
		idxTemp2["rets18_forsale"]="for sale:";
		idxTemp2["rets18_bus1"]="bus1:";
		idxTemp2["rets18_bus2"]="bus2:";
		idxTemp2["rets18_bus3"]="bus3:";
		idxTemp2["rets18_bus4"]="bus4:";
		idxTemp2["rets18_businessname"]="business name:";
		idxTemp2["rets18_hoa"]="hoa:";
		idxTemp2["rets18_applicationfee"]="application fee:";
		idxTemp2["rets18_appraisername"]="appraiser name:";
		idxTemp2["rets18_approvalnum"]="approval number:";
		idxTemp2["rets18_assumption"]="assumption:";
		idxTemp2["rets18_financeproposed"]="finance proposed:";
		idxTemp2["rets18_moneyrequired"]="money required:";
		idxTemp2["rets18_nonrefundpetfee"]="non refundable pet fee:";
		idxTemp2["rets18_occupancyrate"]="occupancy rate:";
		idxTemp2["rets18_ownerpays"]="owner pays:";
		idxTemp2["rets18_restrictions"]="restrictions:";
		idxTemp2["rets18_roadassess"]="road assess:";
		idxTemp2["rets18_surfacerights"]="surface rights:";
		idxTemp2["rets18_taxid"]="tax id:";
		idxTemp2["rets18_taxunexempt"]="tax unexempt:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>