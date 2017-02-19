<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" output="yes" returntype="any">
		<cfscript>
	application.zcore.listingCom.makeListingImportDataReady();
	idxExclude={};
	tf=application.zcore.listingStruct.mlsStruct["12"].sharedStruct.metaStruct["property"].tableFields;
	n=0;
	for(curField in tf){  
		f2=tf[curField].longname; 
		n++;
		variables.allfields[n]={field:"rets12_"&curField, label:f2};
	}
	application.zcore.listingCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
	// force allfields to not have the fields that already used
	this.getDetailCache1(structnew());
	this.getDetailCache2(structnew());
	this.getDetailCache3(structnew());
 
	 
	if(structcount(variables.allfields) NEQ 0){
		//writeoutput('<h2>All Fields:</h2>');
		arrKey=structsort(variables.allfields, "text", "asc", "label");
		for(i=1;i LTE arraylen(arrKey);i++){
			if(structkeyexists(idxExclude, variables.allfields[arrKey[i]].field) EQ false){
				writeoutput('idxTemp2["'&variables.allfields[arrKey[i]].field&'"]="'&replace(application.zcore.functions.zfirstlettercaps(variables.allfields[arrKey[i]].label),"##","####")&'";<br />');
			}
		}
	}
	application.zcore.functions.zabort();</cfscript>
	</cffunction>

	<!--- <table class="ztablepropertyinfo"> --->
    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew(); 
		 
		//idxTemp2["rets12_property_id"]="property id:";
		//idxTemp2["rets12_1"]="Property Type:";
		//idxTemp2["rets12_10"]="Zip Code:";
		//idxTemp2["rets12_11"]="Zip Code (Last 4 Digits):";
		//idxTemp2["rets12_113"]="I##:";
		//idxTemp2["rets12_114"]="Internet:";
		//idxTemp2["rets12_115"]="Internet Remarks:";
		//idxTemp2["rets12_1218"]="Selling Agent Code:";
		//idxTemp2["rets12_1223"]="Virtual Tour:";
		//idxTemp2["rets12_127"]="Agent License ##:";
		//idxTemp2["rets12_131"]="Last Transaction Date:";
		//idxTemp2["rets12_1328"]="InternetOK:";
		//idxTemp2["rets12_1329"]="Last Img Trans Date:";
		//idxTemp2["rets12_134"]="List Broker Code:";
		//idxTemp2["rets12_136"]="List Agent Public Id:";
		//idxTemp2["rets12_137"]="List Price:";
		//idxTemp2["rets12_1370"]="OK to Advertise (Y/N):";
		//idxTemp2["rets12_144"]="Listing Agent's Name:";
		//idxTemp2["rets12_146"]="Listing Type:";
		//idxTemp2["rets12_1465"]="Short Sale:";
		idxTemp2["rets12_157"]="MLS ##:";
		idxTemp2["rets12_152"]="Manufactured Home Miscell:";
		idxTemp2["rets12_158"]="Model Name:";
		//idxTemp2["rets12_165"]="Office Name:";
		//idxTemp2["rets12_167"]="Listing Office Phone:";
		//idxTemp2["rets12_18"]="Agent Phone:";
		//idxTemp2["rets12_195"]="IDX:";
		//idxTemp2["rets12_214"]="Remarks:";
		//idxTemp2["rets12_223"]="Selling Agent License ##:";
		//idxTemp2["rets12_229"]="Selling Broker Code:";
		//idxTemp2["rets12_230"]="Selling Agent Public Id:";
		idxTemp2["rets12_231"]="Serial Number:";
		//idxTemp2["rets12_234"]="Showing Instructions:";
		//idxTemp2["rets12_242"]="Selling Agent's Name:";
		idxTemp2["rets12_246"]="Status:";
		//idxTemp2["rets12_247"]="Street Name:";
		//idxTemp2["rets12_248"]="Street Number:";
		//idxTemp2["rets12_249"]="Street Suffix:";
		//idxTemp2["rets12_317"]="Zip Code (Last 4 Digits) (O:";
		idxTemp2["rets12_34"]="Block Group:";
		//idxTemp2["rets12_365"]="Showing Instructions:";
		//idxTemp2["rets12_46"]="City - Original:";
		//idxTemp2["rets12_486"]="Showing Instructions:";
		//idxTemp2["rets12_523"]="Listing Type:";
		idxTemp2["rets12_524"]="Miscellaneous Information:";
		//idxTemp2["rets12_536"]="Showing Instructions:";
		idxTemp2["rets12_538"]="Special Information:";
		idxTemp2["rets12_54"]="Type of Contingencies:";
		//idxTemp2["rets12_565"]="Listing Type:";
		idxTemp2["rets12_568"]="Miscellaneous:";
		idxTemp2["rets12_569"]="Model Name:";
		idxTemp2["rets12_581"]="Restrictions:";
		//idxTemp2["rets12_585"]="Showing Instructions:";
		idxTemp2["rets12_608"]="Fire Protection:";
		idxTemp2["rets12_61"]="County:";
		idxTemp2["rets12_623"]="Miscellaneous Information:";
		idxTemp2["rets12_734"]="Miscellaneous Information:";
		idxTemp2["rets12_737"]="## Employees:";
		idxTemp2["rets12_738"]="## Seats:";
		idxTemp2["rets12_746"]="Special Information:";
		idxTemp2["rets12_747"]="Style of Business:";
		idxTemp2["rets12_748"]="Type of Business:";
		//idxTemp2["rets12_78"]="Web Address:";
		//idxTemp2["rets12_80"]="Entry Date:";
		//idxTemp2["rets12_881"]="Address:";
		//idxTemp2["rets12_882"]="List and Sell Agent:";
		idxTemp2["rets12_886"]="Elementary School:";
		//idxTemp2["rets12_887"]="List and Sell Office:";
		//idxTemp2["rets12_888"]="List or Sell Agent:";
		//idxTemp2["rets12_889"]="List or Sell Office:";";
		idxTemp2["rets12_891"]="Middle School:";
		idxTemp2["rets12_893"]="Senior High School:";
		//idxTemp2["rets12_922"]="City Name:";
		//idxTemp2["rets12_924"]="State:";
		
		//idxTemp2["rets12_sysid"]="sysid:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		idxTemp2["rets12_164"]="Occupancy Information:";
		idxTemp2["rets12_574"]="Occupancy Information:";
		idxTemp2["rets12_404"]="Gross Rent Income:";
		idxTemp2["rets12_429"]="Rent Includes:";
		idxTemp2["rets12_578"]="Rent Period:";
		idxTemp2["rets12_579"]="Rental Deposit Includes:";
		idxTemp2["rets12_580"]="Rental Payment Includes:";
		idxTemp2["rets12_899"]="Furn Annual Rent:";
		idxTemp2["rets12_900"]="Furn Off-Season Rent:";
		idxTemp2["rets12_901"]="Furn Seasonal Rent:";
		idxTemp2["rets12_895"]="Rent Status - April:";
		idxTemp2["rets12_896"]="Rent Status - August:";
		idxTemp2["rets12_897"]="Rent Status - December:";
		idxTemp2["rets12_898"]="Rent Status - February:";
		idxTemp2["rets12_902"]="Rent Status - January:";
		idxTemp2["rets12_903"]="Rent Status - July:";
		idxTemp2["rets12_904"]="Rent Status - June:";
		idxTemp2["rets12_905"]="Rent Status - March:";
		idxTemp2["rets12_906"]="Rent Status - May:";
		idxTemp2["rets12_907"]="Rent Status - November:";
		idxTemp2["rets12_908"]="Rent Status - October:";
		idxTemp2["rets12_909"]="Rent Status - September:";
		

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Rental Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets12_1340"]="Unit Number:";
		idxTemp2["rets12_17"]="Unit Number:";
		idxTemp2["rets12_335"]="Unit Floor Location:";
		idxTemp2["rets12_373"]="Total ## of Units In Buildin:";
		idxTemp2["rets12_374"]="Total ## of Units In Complex:";
		idxTemp2["rets12_654"]="Price/Unit:";
		idxTemp2["rets12_375"]="Unit View:";
		idxTemp2["rets12_371"]="Unit Number (Old):";
		idxTemp2["rets12_372"]="Unit Design:";
		idxTemp2["rets12_1030"]="Unit 4 Efficiency:";
		idxTemp2["rets12_1000"]="Unit 7 - A Rent:";
		idxTemp2["rets12_1002"]="Unit 7 - B Rent:";
		idxTemp2["rets12_1016"]="Unit 1 Hotel Room:";
		idxTemp2["rets12_1018"]="Unit 2 Hotel Room:";
		idxTemp2["rets12_1020"]="Unit 3 Hotel Room:";
		idxTemp2["rets12_1022"]="Unit 4 Hotel Room:";
		idxTemp2["rets12_1024"]="Unit 1 Efficiency:";
		idxTemp2["rets12_1026"]="Unit 2 Efficiency:";
		idxTemp2["rets12_1028"]="Unit 3 Efficiency:";
		idxTemp2["rets12_1032"]="Unit 1 ## of Beds:";
		idxTemp2["rets12_1034"]="Unit 2 ## of Beds:";
		idxTemp2["rets12_1036"]="Unit 3 ## of Beds:";
		idxTemp2["rets12_1038"]="Unit 4 ## of Beds:";
		idxTemp2["rets12_1040"]="Unit 1 ## of HBaths:";
		idxTemp2["rets12_1042"]="Unit 2 ## of HBaths:";
		idxTemp2["rets12_1044"]="Unit 3 ## of HBaths:";
		idxTemp2["rets12_1046"]="Unit 4 ## of HBaths:";
		idxTemp2["rets12_1048"]="Unit 1 Sq.Ft:";
		idxTemp2["rets12_1050"]="Unit 2 Sq.Ft:";
		idxTemp2["rets12_1052"]="Unit 3 Sq.Ft:";
		idxTemp2["rets12_1054"]="Unit 4 Sq.Ft:";
		idxTemp2["rets12_1056"]="Unit 1 Monthly Income:";
		idxTemp2["rets12_1058"]="Unit 2 Monthly Income:";
		idxTemp2["rets12_1060"]="Unit 3 Monthly Income:";
		idxTemp2["rets12_1062"]="Unit 4 Monthly Income:";
		idxTemp2["rets12_1064"]="Unit 1 Furniture Info.:";
		idxTemp2["rets12_1066"]="Unit 2 Furniture Info.:";
		idxTemp2["rets12_1068"]="Unit 3 Furniture Info.:";
		idxTemp2["rets12_1070"]="Unit 4 Furniture Info.:";
		idxTemp2["rets12_1072"]="Unit 1 Lease Ends Info.:";
		idxTemp2["rets12_1074"]="Unit 2 Lease Ends Info.:";
		idxTemp2["rets12_1076"]="Unit 3 Lease Ends Info.:";
		idxTemp2["rets12_1078"]="Unit 4 Lease Ends Info.:";
		idxTemp2["rets12_1080"]="Unit 1 ## of Units:";
		idxTemp2["rets12_1082"]="Unit 2 ## of Units:";
		idxTemp2["rets12_1084"]="Unit 3 ## of Units:";
		idxTemp2["rets12_1086"]="Unit 4 ## of Units:";
		idxTemp2["rets12_386"]="Unit - Number of Bedrooms:";
		idxTemp2["rets12_388"]="Unit - Efficiency (Y/N)?:";
		idxTemp2["rets12_390"]="Unit 1 Equipment:";
		idxTemp2["rets12_391"]="Unit 2 Equipment:";
		idxTemp2["rets12_392"]="Unit 3 Equipment:";
		idxTemp2["rets12_393"]="Unit 4 Equipment:";
		idxTemp2["rets12_396"]="Unit 1 ## of FBaths:";
		idxTemp2["rets12_397"]="Unit 2 ## of FBaths:";
		idxTemp2["rets12_398"]="Unit 3 ## of FBaths:";
		idxTemp2["rets12_399"]="Unit 4 ## of FBaths:";
		idxTemp2["rets12_418"]="Unit - Number of Units:";
		idxTemp2["rets12_419"]="Unit 1 Parking:";
		idxTemp2["rets12_420"]="Unit 2 Parking:";
		idxTemp2["rets12_421"]="Unit 3 Parking:";
		idxTemp2["rets12_422"]="Unit 4 Parking:";
		idxTemp2["rets12_401"]="Unit - Furniture Informatio:";
		idxTemp2["rets12_406"]="Unit - Hotel Room (Y/N)?:";
		idxTemp2["rets12_411"]="Unit - Lease Ends Info:";
		idxTemp2["rets12_415"]="Unit - Monthly Income:";
		idxTemp2["rets12_430"]="Unit 1 Room Description:";
		idxTemp2["rets12_431"]="Unit 2 Room Description:";
		idxTemp2["rets12_432"]="Unit 3 Room Description:";
		idxTemp2["rets12_433"]="Unit 4 Room Description:";
		idxTemp2["rets12_436"]="Unit - Square Footage:";
		idxTemp2["rets12_671"]="##Units:";
		idxTemp2["rets12_676"]="Unit Type:";
		idxTemp2["rets12_677"]="Unit 1 ## of Baths:";
		idxTemp2["rets12_678"]="Unit 1 Furnished:";
		idxTemp2["rets12_679"]="Number of Unit - Units:";
		idxTemp2["rets12_680"]="Unit Rent :";
		idxTemp2["rets12_681"]="Unit 1 Rental Period A:";
		idxTemp2["rets12_682"]="Unit 1 Rental Period B:";
		idxTemp2["rets12_683"]="Unit 2 ## of Baths:";
		idxTemp2["rets12_684"]="Unit 2 Furnished:";
		idxTemp2["rets12_685"]="Unit 2 Rental Period A:";
		idxTemp2["rets12_686"]="Unit 2 Rental Period B:";
		idxTemp2["rets12_687"]="Unit 3 ## of Baths:";
		idxTemp2["rets12_688"]="Unit 3 Furnished:";
		idxTemp2["rets12_689"]="Unit 3 Rental Period A:";
		idxTemp2["rets12_690"]="Unit 3 Rental Period B:";
		idxTemp2["rets12_691"]="Unit 4 ## of Baths:";
		idxTemp2["rets12_692"]="Unit 4 Furnished:";
		idxTemp2["rets12_693"]="Unit 4 Rental Period A:";
		idxTemp2["rets12_694"]="Unit 4 Rental Period B:";
		idxTemp2["rets12_695"]="Unit 5 ## of Baths:";
		idxTemp2["rets12_696"]="Unit 5 Furnished:";
		idxTemp2["rets12_697"]="Unit 5 Rental Period A:";
		idxTemp2["rets12_698"]="Unit 5 Rental Period B:";
		idxTemp2["rets12_699"]="Unit 6 ## of Baths:";
		idxTemp2["rets12_700"]="Unit 6 Furnished:";
		idxTemp2["rets12_701"]="Unit 6 Rental Period A:";
		idxTemp2["rets12_702"]="Unit 6 Rental Period B:";
		idxTemp2["rets12_703"]="Unit 7 ## of Baths:";
		idxTemp2["rets12_704"]="Unit 7 Furnished:";
		idxTemp2["rets12_705"]="Unit 7 Rental Period A:";
		idxTemp2["rets12_706"]="Unit 7 Rental Period B:";
		idxTemp2["rets12_948"]="Unit 1 Type:";
		idxTemp2["rets12_950"]="Unit 2 Type:";
		idxTemp2["rets12_952"]="Unit 3 Type:";
		idxTemp2["rets12_954"]="Unit 4 Type:";
		idxTemp2["rets12_956"]="Unit 5 Type:";
		idxTemp2["rets12_958"]="Unit 6 Type:";
		idxTemp2["rets12_960"]="Unit 7 Type:";
		idxTemp2["rets12_962"]="Unit 1 ## of Units:";
		idxTemp2["rets12_964"]="Unit 2 ## of Units:";
		idxTemp2["rets12_966"]="Unit 3 ## of Units:";
		idxTemp2["rets12_968"]="Unit 4 ## of Units:";
		idxTemp2["rets12_970"]="Unit 5 ## of Units:";
		idxTemp2["rets12_972"]="Unit 6 ## of Units:";
		idxTemp2["rets12_974"]="Unit 7 ## of Units:";
		idxTemp2["rets12_976"]="Unit 1 - A Rent:";
		idxTemp2["rets12_978"]="Unit 1 - B Rent:";
		idxTemp2["rets12_980"]="Unit 2 - A Rent:";
		idxTemp2["rets12_982"]="Unit 2 - B Rent:";
		idxTemp2["rets12_984"]="Unit 3 - A Rent:";
		idxTemp2["rets12_986"]="Unit 3 - B Rent:";
		idxTemp2["rets12_988"]="Unit 4 - A Rent:";
		idxTemp2["rets12_990"]="Unit 4 - B Rent:";
		idxTemp2["rets12_992"]="Unit 5 - A Rent:";
		idxTemp2["rets12_994"]="Unit 5 - B Rent:";
		idxTemp2["rets12_996"]="Unit 6 - A Rent:";
		idxTemp2["rets12_998"]="Unit 6 - B Rent:";
		
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Unit Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		idxTemp2["rets12_587"]="Sewer Description:";
		idxTemp2["rets12_442"]="Total Expenses:";
		idxTemp2["rets12_370"]="Type of Property:";
		idxTemp2["rets12_446"]="Type of Property:";
		idxTemp2["rets12_450"]="Water Access:";
		idxTemp2["rets12_455"]="Total Acreage:";
		idxTemp2["rets12_462"]="Development:";
		idxTemp2["rets12_466"]="Development Name:";
		idxTemp2["rets12_469"]="Fill Description:";
		idxTemp2["rets12_472"]="Miscellaneous/Improvements:";
		idxTemp2["rets12_477"]="## Parcels:";
		idxTemp2["rets12_479"]="Price/Acre:";
		idxTemp2["rets12_483"]="Price/SqFt:";
		idxTemp2["rets12_484"]="Rail Description:";
		idxTemp2["rets12_487"]="Type of Soil:";
		idxTemp2["rets12_492"]="Subdivision Information:";
		idxTemp2["rets12_494"]="Sewer Description:";
		idxTemp2["rets12_495"]="Type of Trees:";
		idxTemp2["rets12_498"]="Type of Property:";
		idxTemp2["rets12_50"]="Compass Point:";
		idxTemp2["rets12_501"]="Water Description:";
		idxTemp2["rets12_502"]="Waterview Description:";
		idxTemp2["rets12_511"]="Ground Cover:";
		idxTemp2["rets12_518"]="Location:";
		idxTemp2["rets12_519"]="Lot Description:";
		idxTemp2["rets12_520"]="Lot Square Footage:";
		idxTemp2["rets12_521"]="Lot Depth:";
		idxTemp2["rets12_522"]="Lot Frontage:";
		idxTemp2["rets12_534"]="Road Description:";
		idxTemp2["rets12_540"]="Sewer Description:";
		idxTemp2["rets12_542"]="Type of Trees:";
		idxTemp2["rets12_544"]="Type of Property:";
		idxTemp2["rets12_547"]="Water Description:";
		idxTemp2["rets12_548"]="Water View:";
		idxTemp2["rets12_588"]="Type of Property:";
		idxTemp2["rets12_661"]="Special Information:";
		idxTemp2["rets12_664"]="Sewer Description:";
		idxTemp2["rets12_675"]="Type of Property:";
		idxTemp2["rets12_69"]="Development Name:";
		idxTemp2["rets12_709"]="Water Description:";
		idxTemp2["rets12_73"]="Compass Point:";
		idxTemp2["rets12_733"]="Location of Property:";
		idxTemp2["rets12_742"]="Road Frontage:"
		idxTemp2["rets12_87"]="Exterior Features:";
		idxTemp2["rets12_90"]="Front Exposure:";
		idxTemp2["rets12_440"]="Sewer Description:";
		idxTemp2["rets12_140"]="Lot or Track##:";
		idxTemp2["rets12_141"]="Lot Description:";
		idxTemp2["rets12_145"]="Approximate Lot Size:";
		idxTemp2["rets12_19"]="Area:";
		idxTemp2["rets12_1428"]="SF/FF:";
		idxTemp2["rets12_106"]="Geographic Area:";
		idxTemp2["rets12_241"]="Sprinkler Description:";
		idxTemp2["rets12_258"]="Sewer Description:";
		idxTemp2["rets12_276"]="Type of Property:";
		idxTemp2["rets12_285"]="View:";
		idxTemp2["rets12_289"]="Waterfront Frontage:";
		idxTemp2["rets12_291"]="Water Description:";
		idxTemp2["rets12_294"]="Water Access:";
		idxTemp2["rets12_295"]="Waterfront Property (Y/N):";
		idxTemp2["rets12_296"]="Waterfront Description:";
		idxTemp2["rets12_314"]="Year Built:";
		idxTemp2["rets12_315"]="Year Built Description:";
		idxTemp2["rets12_655"]="Road Frontage Description:";
		idxTemp2["rets12_892"]="Map Coordinates:";
		idxTemp2["rets12_656"]="Road Type Description:";
		idxTemp2["rets12_326"]="Complex Name:";
		idxTemp2["rets12_330"]="Dock Number:";
		idxTemp2["rets12_333"]="Exterior Features:";
		idxTemp2["rets12_334"]="Front Exposure:";
		
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Land Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets12_621"]="Miles to Beach:";
		idxTemp2["rets12_622"]="Miles to Expressway:";
		idxTemp2["rets12_658"]="Roof Description:";
		idxTemp2["rets12_66"]="Den Dimensions:";
		idxTemp2["rets12_659"]="Security Information:";
		idxTemp2["rets12_713"]="Year Built Description:";
		idxTemp2["rets12_883"]="Year Built:";
		idxTemp2["rets12_44"]="Cable Available:";
		idxTemp2["rets12_500"]="Utilities Available:";
		idxTemp2["rets12_53"]="Construction Type:";
		idxTemp2["rets12_584"]="Security Information:";
		
		idxTemp2["rets12_109"]="## Half Baths:";
		idxTemp2["rets12_586"]="Style:";
		idxTemp2["rets12_59"]="## Carport Spaces:";
		idxTemp2["rets12_594"]="Prop Type/Type of Building:";
		idxTemp2["rets12_598"]="Ceiling Description:";
		idxTemp2["rets12_60"]="Carport Description:";
		idxTemp2["rets12_600"]="Construction Type:";
		idxTemp2["rets12_601"]="Cooling Description:";
		idxTemp2["rets12_603"]="Dock Height:";
		idxTemp2["rets12_604"]="Door Height:";
		idxTemp2["rets12_605"]="Eave Height:";
		idxTemp2["rets12_606"]="Electric Service:";
		idxTemp2["rets12_609"]="Floor Description:";
		idxTemp2["rets12_610"]="Heating Description:";
		idxTemp2["rets12_613"]="Improvement Height:";
		idxTemp2["rets12_638"]="Maximum Ceiling Height:";
		idxTemp2["rets12_641"]="## Bays:";
		idxTemp2["rets12_642"]="## Buildings:";
		idxTemp2["rets12_643"]="## Floors:";
		idxTemp2["rets12_644"]="## Loading Doors:";
		idxTemp2["rets12_645"]="## Meters:";
		idxTemp2["rets12_646"]="## Offices:";
		idxTemp2["rets12_647"]="## Tenants:";
		idxTemp2["rets12_648"]="## Toilets:";
		idxTemp2["rets12_651"]="##Parking Spaces:";
		idxTemp2["rets12_92"]="## Full Baths:";
		idxTemp2["rets12_652"]="Parking Description:";
		idxTemp2["rets12_653"]="Property Description:";
		idxTemp2["rets12_662"]="Style of Property:";
		idxTemp2["rets12_67"]="Design:";
		idxTemp2["rets12_68"]="Design Description:";
		idxTemp2["rets12_70"]="Dining Description:";
		idxTemp2["rets12_71"]="Dining Area Dimensions:";
		idxTemp2["rets12_716"]="Type of Building:";
		idxTemp2["rets12_720"]="Construction Type:";
		idxTemp2["rets12_721"]="Electric Service:";
		idxTemp2["rets12_723"]="Floor Description:";
		idxTemp2["rets12_727"]="Improvement Height:";
		idxTemp2["rets12_743"]="Roof:";
		idxTemp2["rets12_76"]="Dining Room Dimensions:";
		idxTemp2["rets12_81"]="Equipment/Appliances:";
		idxTemp2["rets12_894"]="## Interior Levels:";
		idxTemp2["rets12_96"]="Floor Description:";
		idxTemp2["rets12_97"]="Florida Room Dimensions:";
		idxTemp2["rets12_98"]="Family Room Dimensions:";
		idxTemp2["rets12_99"]="Furnished Info (List):";
		idxTemp2["rets12_368"]="Total Floors In Building:";
		idxTemp2["rets12_376"]="Windows/Treatment:";
		idxTemp2["rets12_400"]="Floor Description:";
		idxTemp2["rets12_417"]="## Parking Spaces:";
		idxTemp2["rets12_367"]="Style:";
		idxTemp2["rets12_424"]="Pool Description:";
		idxTemp2["rets12_437"]="Style:";
		idxTemp2["rets12_449"]="Windows/Treatment:";
		idxTemp2["rets12_45"]="## Ceiling Fans:";
		idxTemp2["rets12_491"]="Style of Property:";
		idxTemp2["rets12_506"]="Property Description:";
		idxTemp2["rets12_539"]="Style of Property:";
		idxTemp2["rets12_552"]="Amenities:";
		idxTemp2["rets12_56"]="Convertible Bedroom:";
		idxTemp2["rets12_563"]="Design:";
		idxTemp2["rets12_57"]="Cooling Description:";
		idxTemp2["rets12_573"]="## Stories:";
		idxTemp2["rets12_575"]="Parking Description:";
		idxTemp2["rets12_576"]="Pool Description:";
		idxTemp2["rets12_582"]="Rooms Description:";
		idxTemp2["rets12_25"]="## Beds:";
		idxTemp2["rets12_260"]="Manufactured Home Size:";
		idxTemp2["rets12_261"]="Approx. Sqft Total Area:";
		idxTemp2["rets12_28"]="2nd Bedroom Dimensions:";
		idxTemp2["rets12_29"]="3rd Bedroom Dimensions:";
		idxTemp2["rets12_290"]="Windows/Treatment:";
		idxTemp2["rets12_30"]="4th Bedroom Dimensions:";
		idxTemp2["rets12_31"]="Bedroom Description:";
		idxTemp2["rets12_319"]="Amenities:";
		idxTemp2["rets12_322"]="Balcony, Porch and/or Patio:";
		idxTemp2["rets12_329"]="Dining Description:";
		idxTemp2["rets12_331"]="Efficiency:";
		idxTemp2["rets12_332"]="Equipment/Appliances:";
		idxTemp2["rets12_336"]="Floor Description:";
		idxTemp2["rets12_337"]="Garage Description:";
		idxTemp2["rets12_341"]="Interior Features:"
		idxTemp2["rets12_352"]="Main Living Area:";
		idxTemp2["rets12_353"]="Master Bathroom Description:";
		idxTemp2["rets12_355"]="Parking Description:";
		idxTemp2["rets12_356"]="Parking Space Number:";
		idxTemp2["rets12_360"]="Patio/Balcony Dimensions:";
		idxTemp2["rets12_363"]="Rooms Information:";
		idxTemp2["rets12_100"]="Additional Furnished Info.:";
		idxTemp2["rets12_102"]="## Garage Spaces:";
		idxTemp2["rets12_103"]="Garage Description:";
		idxTemp2["rets12_107"]="SqFt L.A. of Guest House:";
		idxTemp2["rets12_116"]="Interior Features:";
		idxTemp2["rets12_108"]="Guest House Description:";
		idxTemp2["rets12_110"]="Heating Description:";
		idxTemp2["rets12_126"]="Kitchen Dimensions:";
		idxTemp2["rets12_129"]="SqFt Liv Area:";
		idxTemp2["rets12_1424"]="## Full Baths:";
		idxTemp2["rets12_1426"]="## Half Baths:";
		idxTemp2["rets12_163"]="## Stories:";
		idxTemp2["rets12_177"]="Parking Description:";
		idxTemp2["rets12_178"]="Parking Restrictions:";
		idxTemp2["rets12_149"]="Master Bedroom Dimensions:";
		idxTemp2["rets12_162"]="Master Bathroom Description:";
		idxTemp2["rets12_143"]="Living Room Dimensions:";
		idxTemp2["rets12_179"]="Patio/Balcony Dimensions:";
		idxTemp2["rets12_189"]="Pool Dimensions:";
		idxTemp2["rets12_191"]="Pool:";
		idxTemp2["rets12_192"]="Pool Description:";
		idxTemp2["rets12_193"]="Porch Dimensions:";
		idxTemp2["rets12_2"]="5th Bedroom Dimensions:";
		idxTemp2["rets12_219"]="Roof Description:";
		idxTemp2["rets12_220"]="Rooms Description:";
		idxTemp2["rets12_232"]="Property SqFt:";
		

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Room &amp; Building Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		idxTemp2=structnew();
		idxTemp2["rets12_619"]="Management Expense:";
		idxTemp2["rets12_62"]="Closing Date:";
		idxTemp2["rets12_1088"]="Directions:";
		idxTemp2["rets12_111"]="Type of Association:";
		idxTemp2["rets12_1430"]="Subdivision/Complex/Bldg.:";
		idxTemp2["rets12_527"]="Other Income Expense:";
		idxTemp2["rets12_147"]="Maintenance Includes:";
		idxTemp2["rets12_1473"]="REO:";
		idxTemp2["rets12_150"]="Municipal Code:";
		idxTemp2["rets12_190"]="Parcel Number:";
		idxTemp2["rets12_216"]="Restrictions:";
		idxTemp2["rets12_226"]="Subdivision Number:";
		idxTemp2["rets12_227"]="Section:";
		idxTemp2["rets12_235"]="Subdivision Name:";
		idxTemp2["rets12_239"]="Special Information:";
		idxTemp2["rets12_250"]="Map Coordinates:";
		idxTemp2["rets12_338"]="Type of Governing Bodies:";
		idxTemp2["rets12_347"]="Maintenance Includes:";
		idxTemp2["rets12_348"]="Maintenance Charge/Month:";
		idxTemp2["rets12_366"]="Special Information:";
		idxTemp2["rets12_416"]="Net Operating Income:";
		idxTemp2["rets12_489"]="Special Information:";
		idxTemp2["rets12_510"]="Gross Operating Income:";
		idxTemp2["rets12_512"]="Gross Scheduled Income:";
		idxTemp2["rets12_514"]="Insurance Expense:";
		idxTemp2["rets12_517"]="Maximum Leasable Sqft:";
		idxTemp2["rets12_435"]="Special Information:";
		idxTemp2["rets12_253"]="Sub Num:";
		idxTemp2["rets12_254"]="Subdivision Information:";
		
		idxTemp2["rets12_160"]="Membership Purch Rqd:";
		idxTemp2["rets12_161"]="Membership Purchase Fee:";
		idxTemp2["rets12_180"]="Pet Restrictions:";
		idxTemp2["rets12_181"]="Pets Allowed:";
		idxTemp2["rets12_194"]="Possession Information:";
		idxTemp2["rets12_206"]="Previous List Price:";
		idxTemp2["rets12_21"]="Assoc Fee Paid Per:";
		idxTemp2["rets12_22"]="Assumable:";
		idxTemp2["rets12_225"]="Sale Price:";
		idxTemp2["rets12_362"]="Restrictions:";
		idxTemp2["rets12_263"]="Tax Information:";
		idxTemp2["rets12_266"]="Total Mortgage:";
		idxTemp2["rets12_267"]="Township/Range:";
		idxTemp2["rets12_268"]="Sale Terms:";
		idxTemp2["rets12_274"]="Tax Amount:";
		idxTemp2["rets12_275"]="Tax Year:";
		idxTemp2["rets12_318"]="Zoning Information:";
		idxTemp2["rets12_441"]="Tax Information:";
		idxTemp2["rets12_63"]="Dade Assessed $/SOH Value:";
		idxTemp2["rets12_632"]="Miscellaneous Expense:";
		idxTemp2["rets12_634"]="Maint. and Repairs Expense:";
		idxTemp2["rets12_650"]="Type of Ownership:";
		idxTemp2["rets12_665"]="Tax Amount:";
		idxTemp2["rets12_722"]="Expenses Included:";
		idxTemp2["rets12_728"]="Sale Includes (INCL):";
		idxTemp2["rets12_75"]="Dade Market $/Assessed $:";
		idxTemp2["rets12_890"]="List or Sell Price:";
		idxTemp2["rets12_93"]="Association Fee:";
		idxTemp2["rets12_94"]="Maintenance Fee Includes:";

		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>