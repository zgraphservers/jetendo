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
	tf=application.zcore.listingStruct.mlsStruct["26"].sharedStruct.metaStruct["property"].tableFields;
	n=0;
	for(curField in tf){  
		f2=tf[curField].longname; 
		n++;
		variables.allfields[n]={field:"rets28_"&curField, label:f2};
	}
idxExclude["rets26_list_135"]="Cumulative Dom";
idxExclude["rets26_list_7"]="Property Group Id";
idxExclude["rets26_list_8"]="Property Type";
idxExclude["rets26_property_id"]="Property_id";
idxExclude["rets26_vowaddr"]="Vowaddressdisplay";
idxExclude["rets26_vowavm"]="Vowautomatedvaluationdisplay";
idxExclude["rets26_vowcomm"]="Vowconsumercomment";
idxExclude["rets26_vowlist"]="Vowentirelistingdisplay";
idxExclude["rets26_unbrandedidxvirtualtour"]="Unbranded Virtual Tour";
idxExclude["rets26_list_131"]="Terms Of Bonus";
idxExclude["rets26_list_87"]="Timestamp";
idxExclude["rets26_list_13"]="Under Contract Date";
idxExclude["rets26_list_17"]="Withdrawal Date";
idxExclude["rets26_list_143"]="Seller Name Withheld";
idxExclude["rets26_list_130"]="Seller Nm (lst,frst)";
idxExclude["rets26_list_97"]="Seller Phone ##";
idxExclude["rets26_list_61"]="Selling Agency Id";
idxExclude["rets26_list_62"]="Selling Agent Id";
idxExclude["rets26_selling_member_address"]="Sellingmemberaddress";
idxExclude["rets26_selling_member_email"]="Sellingmemberemail";
idxExclude["rets26_selling_member_fax"]="Sellingmemberfax";
idxExclude["rets26_selling_member_name"]="Sellingmembername";
idxExclude["rets26_selling_member_phone"]="Sellingmemberphone";
idxExclude["rets26_selling_member_shortid"]="Sellingmembershortid";
idxExclude["rets26_selling_member_url"]="Sellingmemberurl";
idxExclude["rets26_selling_office_address"]="Sellingofficeaddress";
idxExclude["rets26_selling_office_email"]="Sellingofficeemail";
idxExclude["rets26_selling_office_fax"]="Sellingofficefax";
idxExclude["rets26_selling_office_name"]="Sellingofficename";
idxExclude["rets26_selling_office_phone"]="Sellingofficephone";
idxExclude["rets26_selling_office_shortid"]="Sellingofficeshortid";
idxExclude["rets26_selling_office_url"]="Sellingofficeurl";
idxExclude["rets26_list_112"]="Single Agent Comp";
idxExclude["rets26_list_12"]="Sold Date";
idxExclude["rets26_list_23"]="Sold Price";
idxExclude["rets26_list_126"]="Sold Price/sqft";
idxExclude["rets26_list_142"]="Sale Notes";
idxExclude["rets26_list_106"]="Office Id";
idxExclude["rets26_listing_member_address"]="Listingmemberaddress";
idxExclude["rets26_listing_member_email"]="Listingmemberemail";
idxExclude["rets26_listing_member_fax"]="Listingmemberfax";
idxExclude["rets26_listing_member_name"]="Listingmembername";
idxExclude["rets26_listing_member_phone"]="Listingmemberphone";
idxExclude["rets26_listing_member_shortid"]="Listingmembershortid";
idxExclude["rets26_listing_member_url"]="Listingmemberurl";
idxExclude["rets26_listing_office_address"]="Listingofficeaddress";
idxExclude["rets26_listing_office_email"]="Listingofficeemail";
idxExclude["rets26_listing_office_fax"]="Listingofficefax";
idxExclude["rets26_listing_office_name"]="Listingofficename";
idxExclude["rets26_listing_office_phone"]="Listingofficephone";
idxExclude["rets26_listing_office_shortid"]="Listingofficeshortid";
idxExclude["rets26_listing_office_url"]="Listingofficeurl";
idxExclude["rets26_list_147"]="Listed On Gccmls";
idxExclude["rets26_list_86"]="Listing Board";
idxExclude["rets26_boardcode"]="List Office Board Code";
idxExclude["rets26_list_163"]="List Office Board Id";
idxExclude["rets26_list_3"]="List Number Main";
idxExclude["rets26_list_2"]="List Number Prefix";
idxExclude["rets26_list_132"]="Entry Timestamp";
idxExclude["rets26_list_11"]="Expiration Date";
idxExclude["rets26_list_104"]="Display On Public Websites";
idxExclude["rets26_list_6"]="Colist Agent Id";
idxExclude["rets26_list_165"]="Colist Office Id";
idxExclude["rets26_colisting_member_address"]="Colistingmemberaddress";
idxExclude["rets26_colisting_member_email"]="Colistingmemberemail";
idxExclude["rets26_colisting_member_fax"]="Colistingmemberfax";
idxExclude["rets26_colisting_member_name"]="Colistingmembername";
idxExclude["rets26_colisting_member_phone"]="Colistingmemberphone";
idxExclude["rets26_colisting_member_shortid"]="Colistingmembershortid";
idxExclude["rets26_colisting_member_url"]="Colistingmemberurl";
idxExclude["rets26_colisting_office_address"]="Colistingofficeaddress";
idxExclude["rets26_colisting_office_email"]="Colistingofficeemail";
idxExclude["rets26_colisting_office_fax"]="Colistingofficefax";
idxExclude["rets26_colisting_office_name"]="Colistingofficename";
idxExclude["rets26_colisting_office_phone"]="Colistingofficephone";
idxExclude["rets26_colisting_office_shortid"]="Colistingofficeshortid";
idxExclude["rets26_colisting_office_url"]="Colistingofficeurl";
idxExclude["rets26_list_166"]="Coselling Agency Id";
idxExclude["rets26_list_63"]="Coselling Agent Id";
idxExclude["rets26_coselling_member_address"]="Cosellingmemberaddress";
idxExclude["rets26_coselling_member_email"]="Cosellingmemberemail";
idxExclude["rets26_coselling_member_fax"]="Cosellingmemberfax";
idxExclude["rets26_coselling_member_name"]="Cosellingmembername";
idxExclude["rets26_coselling_member_phone"]="Cosellingmemberphone";
idxExclude["rets26_coselling_member_shortid"]="Cosellingmembershortid";
idxExclude["rets26_coselling_member_url"]="Cosellingmemberurl";
idxExclude["rets26_coselling_office_address"]="Cosellingofficeaddress";
idxExclude["rets26_coselling_office_email"]="Cosellingofficeemail";
idxExclude["rets26_coselling_office_fax"]="Cosellingofficefax";
idxExclude["rets26_coselling_office_name"]="Cosellingofficename";
idxExclude["rets26_coselling_office_phone"]="Cosellingofficephone";
idxExclude["rets26_coselling_office_shortid"]="Cosellingofficeshortid";
idxExclude["rets26_coselling_office_url"]="Cosellingofficeurl";
idxExclude["rets26_list_110"]="Comp: See Notes?";
idxExclude["rets26_list_19"]="Contingent";
idxExclude["rets26_list_18"]="Cancel Date";
idxExclude["rets26_list_144"]="Buyer Name Withheld";
idxExclude["rets26_list_109"]="Agency Relationship";
idxExclude["rets26_list_140"]="Agent To Agent Rmrks";
idxExclude["rets26_list_107"]="Brokerage Interest";
idxExclude["rets26_list_111"]="Bonus";
idxExclude["rets26_list_82"]="Directions";
idxExclude["rets26_list_1"]="Internal Listing Id";
idxExclude["rets26_list_78"]="Remarks";
idxExclude["rets26_list_15"]="Status";
idxExclude["rets26_list_16"]="Status Change Date";
idxExclude["rets26_list_31"]="Street ##";
idxExclude["rets26_list_33"]="Street Direction";
idxExclude["rets26_list_34"]="Street Name";
idxExclude["rets26_list_37"]="Street Suffix";
idxExclude["rets26_list_5"]="Agent Id";
idxExclude["rets26_list_66"]="Bedrooms";
idxExclude["rets26_list_39"]="City";
idxExclude["rets26_list_46"]="Latitude";
idxExclude["rets26_list_47"]="Longitude";
idxExclude["rets26_list_137"]="Agent Days On Market";
idxExclude["rets26_list_141"]="Agent Info Cont'd";
idxExclude["rets26_list_14"]="Fallthrough Date";
idxExclude["rets26_list_168"]="List Agent Board Code";
idxExclude["rets26_list_167"]="List Agent Board Id";
idxExclude["rets26_list_4"]="Mls Approved";
idxExclude["rets26_list_0"]="Mls Identifier";
idxExclude["rets26_list_73"]="Nrr";
idxExclude["rets26_list_150"]="Nrr Req";
idxExclude["rets26_list_133"]="Picture Count";
idxExclude["rets26_list_134"]="Picture Timestamp";
idxExclude["rets26_gf20141227001748539984000000"]="Showing Instructions";
idxExclude["rets26_gf20150107140556859169000000"]="Showing Instructions";
idxExclude["rets26_gf20141227192848538703000000"]="Showing Instructions";
idxExclude["rets26_gf20141227193424267068000000"]="Showing Instructions";
idxExclude["rets26_list_58"]="Buyer";
idxExclude["rets26_list_127"]="Contingency Date";
idxExclude["rets26_list_10"]="Listing Date";
idxExclude["rets26_list_105"]="Listing Id";
idxExclude["rets26_list_152"]="Survey";
idxExclude["rets26_list_28"]="Sold Terms";
idxExclude["rets26_list_154"]="Special Contingency";
idxExclude["rets26_list_156"]="Monitor Vhf16";
	
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


idxTemp2["rets26_list_44"]="## Parking";
idxTemp2["rets26_list_65"]="## Units";
idxTemp2["rets26_gf20141227001528056321000000"]="1st Floor";
idxTemp2["rets26_gf20141227192834057254000000"]="1st Floor";
idxTemp2["rets26_gf20141227194557132723000000"]="Access/transport";
idxTemp2["rets26_gf20141227192834317267000000"]="Acreage";
idxTemp2["rets26_list_57"]="Acreage";
idxTemp2["rets26_gf20141226230259827496000000"]="Acreage";
idxTemp2["rets26_gf20141227193410300025000000"]="Air Conditioning";
idxTemp2["rets26_gf20141227193546701063000000"]="Air Conditioning";
idxTemp2["rets26_gf20141227001311156424000000"]="Air Conditioning";
idxTemp2["rets26_gf20141227192834666082000000"]="Air Conditioning";
idxTemp2["rets26_gf20141227192835088770000000"]="Appliances";
idxTemp2["rets26_gf20141227193410727401000000"]="Appliances";
idxTemp2["rets26_gf20141226230513688158000000"]="Appliances";
idxTemp2["rets26_gf20141227192835969249000000"]="Architecture";
idxTemp2["rets26_gf20141226230444683855000000"]="Architecture";
idxTemp2["rets26_list_29"]="Area";
idxTemp2["rets26_list_67"]="Baths";
idxTemp2["rets26_list_69"]="Baths - Half";
idxTemp2["rets26_gf20141227193548494838000000"]="Bldg Type/location";
idxTemp2["rets26_list_9"]="Boat Dock Style";
idxTemp2["rets26_gf20141226230405195560000000"]="Building";
idxTemp2["rets26_gf20141227192836583087000000"]="Building";
idxTemp2["rets26_gf20141227193412356482000000"]="Building Type";
idxTemp2["rets26_gf20141227195028677239000000"]="Ceiling Height";
idxTemp2["rets26_list_159"]="Ceiling Height";
idxTemp2["rets26_list_90"]="Commercial Property Name";
idxTemp2["rets26_list_101"]="Commercial Property Type";
idxTemp2["rets26_gf20141227001849499306000000"]="Condo";
idxTemp2["rets26_gf20141227192837165022000000"]="Condo";
idxTemp2["rets26_gf20141227001902268272000000"]="Condo Parking";
idxTemp2["rets26_gf20141227192838320884000000"]="Condo Parking";
idxTemp2["rets26_list_54"]="Condo Unit ##";
idxTemp2["rets26_gf20141227193549712759000000"]="Construction";
idxTemp2["rets26_gf20141226230416743766000000"]="Construction";
idxTemp2["rets26_gf20141227192837801758000000"]="Construction";
idxTemp2["rets26_gf20141227193413674607000000"]="Construction";
idxTemp2["rets26_list_41"]="County";
idxTemp2["rets26_list_158"]="Current ## Tenant";
idxTemp2["rets26_list_124"]="Depth";
idxTemp2["rets26_list_81"]="Directions";
idxTemp2["rets26_list_113"]="Facility Name";
idxTemp2["rets26_gf20141227001326295145000000"]="Floor Coverings";
idxTemp2["rets26_gf20141227192838985297000000"]="Floor Coverings";
idxTemp2["rets26_list_153"]="Harbormaster";
idxTemp2["rets26_gf20141227193552219738000000"]="Heating";
idxTemp2["rets26_gf20141227193416451569000000"]="Heating";
idxTemp2["rets26_gf20141227001224390986000000"]="Heating";
idxTemp2["rets26_gf20141227192840262031000000"]="Heating";
idxTemp2["rets26_gf20141227192839779357000000"]="House Orientation";
idxTemp2["rets26_gf20141227001543899079000000"]="House Orientation";
idxTemp2["rets26_gf20141226230458968493000000"]="Inside";
idxTemp2["rets26_gf20141227192840945324000000"]="Inside";
idxTemp2["rets26_gf20141227193417138040000000"]="Inside";
idxTemp2["rets26_gf20141227194656448898000000"]="Interior Improvement";
idxTemp2["rets26_gf20141227192841845016000000"]="Land";
idxTemp2["rets26_gf20141226230311380539000000"]="Land";
idxTemp2["rets26_gf20141227193418087637000000"]="Land Type";
idxTemp2["rets26_gf20150107201859464523000000"]="Land Type-commercial";
idxTemp2["rets26_gf20150107140549889252000000"]="Land Type-res";
idxTemp2["rets26_list_95"]="Location";
idxTemp2["rets26_list_56"]="Lot Size";
idxTemp2["rets26_list_52"]="Lot Sqft";
idxTemp2["rets26_gf20150113203837017118000000"]="Marina Amenities";
idxTemp2["rets26_feat20150108170645439801000000"]="Meters: ## Electric Meters";
idxTemp2["rets26_feat20141229145138164152000000"]="Meters: ## Electric Meters";
idxTemp2["rets26_feat20141229145153687439000000"]="Meters: ## Gas Meters";
idxTemp2["rets26_feat20150108170743177653000000"]="Meters: ## Gas Meters";
idxTemp2["rets26_feat20141229145118055494000000"]="Meters: ## Water Meters";
idxTemp2["rets26_feat20150108170714327492000000"]="Meters: ## Water Meters";
idxTemp2["rets26_gf20141226230530523380000000"]="Miscellaneous";
idxTemp2["rets26_gf20141227192842483375000000"]="Miscellaneous";
idxTemp2["rets26_gf20150113203813169264000000"]="Moorage";
idxTemp2["rets26_gf20141227193422151879000000"]="Pool";
idxTemp2["rets26_gf20141226230335404830000000"]="Pool";
idxTemp2["rets26_gf20141227192846024680000000"]="Pool";
idxTemp2["rets26_gf20141227192844323514000000"]="Occupancy";
idxTemp2["rets26_gf20141227001804189977000000"]="Occupancy";
idxTemp2["rets26_gf20141227002720558708000000"]="Outside";
idxTemp2["rets26_gf20141227193420780210000000"]="Outside";
idxTemp2["rets26_gf20141227192844574139000000"]="Outside";
idxTemp2["rets26_list_145"]="Overnight Comments";
idxTemp2["rets26_gf20141227193556888800000000"]="Parking";
idxTemp2["rets26_gf20141227193421492461000000"]="Parking";
idxTemp2["rets26_gf20141226230426862688000000"]="Parking";
idxTemp2["rets26_gf20141227192845246339000000"]="Parking";
idxTemp2["rets26_list_157"]="Parking Available";
idxTemp2["rets26_gf20141227194901735001000000"]="Possible Use";
idxTemp2["rets26_gf20141227001940123830000000"]="Road";
idxTemp2["rets26_gf20141227192847200678000000"]="Road";
idxTemp2["rets26_list_123"]="Road Frontage";
idxTemp2["rets26_list_108"]="Road Frontage";
idxTemp2["rets26_gf20141227001555393624000000"]="Roof";
idxTemp2["rets26_gf20141227193423364613000000"]="Roof";
idxTemp2["rets26_gf20141227192847415428000000"]="Roof";
idxTemp2["rets26_gf20141227193558750386000000"]="Roof";
idxTemp2["rets26_gf20150113203800450795000000"]="Security";
idxTemp2["rets26_gf20141227194620250823000000"]="Sewer";
idxTemp2["rets26_gf20150107201927432439000000"]="Sewer";
idxTemp2["rets26_gf20150113144647743453000000"]="Sewer";
idxTemp2["rets26_gf20141227194819652551000000"]="Site Improvements";
idxTemp2["rets26_gf20150113203825119434000000"]="Slip Amenities";
idxTemp2["rets26_list_93"]="Slip Draft";
idxTemp2["rets26_list_89"]="Slip Size";
idxTemp2["rets26_list_49"]="Sqft - Bldg";
idxTemp2["rets26_list_48"]="Sqft - Total";
idxTemp2["rets26_list_91"]="Sqft Source";
idxTemp2["rets26_feat20141229150451463764000000"]="Sqft: Largest Contiguous";
idxTemp2["rets26_feat20141229150702524631000000"]="Sqft: Manufacturing Rate Sqft";
idxTemp2["rets26_feat20141229150352900748000000"]="Sqft: Manufacturing Sqft";
idxTemp2["rets26_feat20141229150431193331000000"]="Sqft: Max Area";
idxTemp2["rets26_feat20141229150421297114000000"]="Sqft: Min Area";
idxTemp2["rets26_feat20141229150515105932000000"]="Sqft: Occupied Sqft";
idxTemp2["rets26_feat20141229150558923570000000"]="Sqft: Office Rate/sqft";
idxTemp2["rets26_feat20141229150212708273000000"]="Sqft: Office Sqft";
idxTemp2["rets26_feat20141229150619157422000000"]="Sqft: Retail Rate Sqft";
idxTemp2["rets26_feat20141229150230241806000000"]="Sqft: Retail Sqft";
idxTemp2["rets26_feat20141229150534994153000000"]="Sqft: Vacant Sqft";
idxTemp2["rets26_feat20141229150638493647000000"]="Sqft: Warehouse Rate Sqft";
idxTemp2["rets26_feat20141229150326562731000000"]="Sqft: Warehouse Sqft";
idxTemp2["rets26_list_40"]="State/province";
idxTemp2["rets26_gf20150107140555547865000000"]="Streets";
idxTemp2["rets26_list_59"]="Sub";
idxTemp2["rets26_list_77"]="Subdivision";
idxTemp2["rets26_list_35"]="Unit ##";
idxTemp2["rets26_list_45"]="Unit Floor";
idxTemp2["rets26_gf20141227192849327292000000"]="Util For Land Only";
idxTemp2["rets26_gf20141227001731140343000000"]="Util For Land Only";
idxTemp2["rets26_gf20150107201947930749000000"]="Utilities At Site";
idxTemp2["rets26_gf20141227194850136354000000"]="Utilities On Site";
idxTemp2["rets26_gf20141227193424857651000000"]="Utilities On Site";
idxTemp2["rets26_room_ur_room_length"]="Utility Room Room Dimensions";
idxTemp2["rets26_room_ur_room_level"]="Utility Room Room Level";
idxTemp2["rets26_gf20150113144638235722000000"]="Water";
idxTemp2["rets26_gf20141227195128500758000000"]="Water";
idxTemp2["rets26_gf20150107201916072541000000"]="Water";
idxTemp2["rets26_gf20141227193425333350000000"]="Waterfront";
idxTemp2["rets26_gf20150107140558302722000000"]="Waterfront";
idxTemp2["rets26_gf20141227192849848869000000"]="Waterfront";
idxTemp2["rets26_gf20141226230324959029000000"]="Waterfront";
idxTemp2["rets26_list_53"]="Year Built";
idxTemp2["rets26_list_43"]="Zip Code";
idxTemp2["rets26_list_148"]="Zone Complies";
idxTemp2["rets26_list_74"]="Zoning";

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
idxTemp2["rets26_room_br1_room_length"]="Bedroom 1 Room Dimensions";
idxTemp2["rets26_room_br1_room_level"]="Bedroom 1 Room Level";
idxTemp2["rets26_room_br2_room_length"]="Bedroom 2 Room Dimensions";
idxTemp2["rets26_room_br2_room_level"]="Bedroom 2 Room Level";
idxTemp2["rets26_room_br3_room_length"]="Bedroom 3 Room Dimensions";
idxTemp2["rets26_room_br3_room_level"]="Bedroom 3 Room Level";
idxTemp2["rets26_room_br4_room_length"]="Bedroom 4 Room Dimensions";
idxTemp2["rets26_room_br4_room_level"]="Bedroom 4 Room Level";
idxTemp2["rets26_room_do_room_length"]="Den/office Room Dimensions";
idxTemp2["rets26_room_do_room_level"]="Den/office Room Level";
idxTemp2["rets26_room_dr_room_length"]="Dining Room Room Dimensions";
idxTemp2["rets26_room_dr_room_level"]="Dining Room Room Level";
idxTemp2["rets26_room_ek_room_length"]="Eat-in-kitchen Room Dimensions";
idxTemp2["rets26_room_ek_room_level"]="Eat-in-kitchen Room Level";
idxTemp2["rets26_room_fr_room_length"]="Family Room Room Dimensions";
idxTemp2["rets26_room_fr_room_level"]="Family Room Room Level";
idxTemp2["rets26_room_fl_room_length"]="Florida Room Room Dimensions";
idxTemp2["rets26_room_fl_room_level"]="Florida Room Room Level";
idxTemp2["rets26_room_kt_room_length"]="Kitchen Room Dimensions";
idxTemp2["rets26_room_kt_room_level"]="Kitchen Room Level";
idxTemp2["rets26_room_lr_room_length"]="Living Room Room Dimensions";
idxTemp2["rets26_room_lr_room_level"]="Living Room Room Level";
idxTemp2["rets26_room_mr_room_length"]="Media Room Room Dimensions";
idxTemp2["rets26_room_mr_room_level"]="Media Room Room Level";
idxTemp2["rets26_gf20141227001344053028000000"]="Porch";
idxTemp2["rets26_gf20141227192846650034000000"]="Porch";
idxTemp2["rets26_room_pd_room_length"]="Patio/deck Room Dimensions";
idxTemp2["rets26_room_pd_room_level"]="Patio/deck Room Level";
idxTemp2["rets26_list_151"]="Phase 1 Envrmnt Complete";
idxTemp2["rets26_room_pb_room_length"]="Porch/balcony Room Dimensions";
idxTemp2["rets26_room_pb_room_level"]="Porch/balcony Room Level";
idxTemp2["rets26_gf20150217135649410135000000"]="Rooms";
idxTemp2["rets26_gf20150217135449359725000000"]="Rooms";
idxTemp2["rets26_feat20150217142201131993000000"]="Rooms: Bedroom 1 Level";
idxTemp2["rets26_feat20150217141222499515000000"]="Rooms: Bedroom 1 Level";
idxTemp2["rets26_feat20150217142212556354000000"]="Rooms: Bedroom 2 Level";
idxTemp2["rets26_feat20150217141201409162000000"]="Rooms: Bedroom 2 Level";
idxTemp2["rets26_feat20150217142225502383000000"]="Rooms: Bedroom 3 Level";
idxTemp2["rets26_feat20150217141147340887000000"]="Rooms: Bedroom 3 Level";
idxTemp2["rets26_feat20150217141135359138000000"]="Rooms: Bedroom 4 Level";
idxTemp2["rets26_feat20150217142239583032000000"]="Rooms: Bedroom 4 Level";
idxTemp2["rets26_feat20150217145626241677000000"]="Rooms: Den/office Level";
idxTemp2["rets26_feat20150217140916630551000000"]="Rooms: Den/office Level";
idxTemp2["rets26_feat20150217141050083464000000"]="Rooms: Dining Room Level";
idxTemp2["rets26_feat20150217142127345119000000"]="Rooms: Dining Room Level";
idxTemp2["rets26_feat20150217144610924572000000"]="Rooms: Eat-in-kitchen Level";
idxTemp2["rets26_feat20150217140842301970000000"]="Rooms: Eat-in-kitchen Level";
idxTemp2["rets26_feat20150217141032420230000000"]="Rooms: Family Room Level";
idxTemp2["rets26_feat20150217142108716323000000"]="Rooms: Family Room Level";
idxTemp2["rets26_feat20150217140820531605000000"]="Rooms: Florida Room Level";
idxTemp2["rets26_feat20150217145852154211000000"]="Rooms: Florida Room Level";
idxTemp2["rets26_feat20150217141012916898000000"]="Rooms: Kitchen Level";
idxTemp2["rets26_feat20150217142312067832000000"]="Rooms: Kitchen Level";
idxTemp2["rets26_feat20150217141106131358000000"]="Rooms: Living Room Level";
idxTemp2["rets26_feat20150217142144057732000000"]="Rooms: Living Room Level";
idxTemp2["rets26_feat20150217140738268585000000"]="Rooms: Media Room Level";
idxTemp2["rets26_feat20150217145927809817000000"]="Rooms: Media Room Level";
idxTemp2["rets26_feat20150217140957054142000000"]="Rooms: Patio/deck Level";
idxTemp2["rets26_feat20150217142411557889000000"]="Rooms: Patio/deck Level";
idxTemp2["rets26_feat20150217142337197693000000"]="Rooms: Porch/balcony Level";
idxTemp2["rets26_feat20150217145137635735000000"]="Rooms: Porch/balcony Level";
idxTemp2["rets26_feat20150217140933740240000000"]="Rooms: Utility Room Level";
idxTemp2["rets26_feat20150217142431106706000000"]="Rooms: Utility Room Level";
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Room Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	return arraytolist(arrR,'');
	
	
	
	</cfscript>
</cffunction>

<cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew(); 
idxTemp2["rets26_gf20141227192847903634000000"]="Special Conditions";
idxTemp2["rets26_gf20141227001822456749000000"]="Special Conditions";
idxTemp2["rets26_gf20141227193559134378000000"]="Special Conditions";
idxTemp2["rets26_gf20150107140556308462000000"]="Special Conditions";
idxTemp2["rets26_gf20141227193423763336000000"]="Special Conditions";
idxTemp2["rets26_list_120"]="% Occupancy";
idxTemp2["rets26_list_155"]="As Is Cond";
idxTemp2["rets26_list_122"]="Base Lease";
idxTemp2["rets26_list_121"]="Concession Amt";
idxTemp2["rets26_gf20141227193549092607000000"]="Condo Fees Include";
idxTemp2["rets26_gf20150113144629066331000000"]="Docs & Discl";
idxTemp2["rets26_list_162"]="Document Count";
idxTemp2["rets26_list_161"]="Document Timestamp";
idxTemp2["rets26_gf20141227194925318751000000"]="Documents/disclosure";
idxTemp2["rets26_feat20150108165754408943000000"]="Financial Info: % Vacancy";
idxTemp2["rets26_feat20150108165737145587000000"]="Financial Info: Annual Noi";
idxTemp2["rets26_feat20150108165630073273000000"]="Financial Info: Gross Monthly Rent";
idxTemp2["rets26_feat20150108165710733602000000"]="Financial Info: Other Annual Inc";
idxTemp2["rets26_feat20150108165650554083000000"]="Financial Info: Total Annual Rent";
idxTemp2["rets26_gf20141227193415617007000000"]="Financing";
idxTemp2["rets26_gf20141227001833876907000000"]="Financing";
idxTemp2["rets26_gf20150107140547074282000000"]="Financing";
idxTemp2["rets26_gf20141227193551462863000000"]="Financing";
idxTemp2["rets26_gf20141227192839454070000000"]="Financing";
idxTemp2["rets26_list_149"]="Foreign Seller";
idxTemp2["rets26_list_96"]="Franchise Opt In";
idxTemp2["rets26_list_114"]="Governing Body";
idxTemp2["rets26_feat20141229150900997734000000"]="Income/operating Inc: Annual Escalation";
idxTemp2["rets26_feat20141229150844131789000000"]="Income/operating Inc: Average Utilities";
idxTemp2["rets26_feat20141229150817086141000000"]="Income/operating Inc: Blend Rate";
idxTemp2["rets26_feat20141229150911265922000000"]="Income/operating Inc: Cam Charge";
idxTemp2["rets26_feat20141229145427455062000000"]="Income/operating Inc: Gross Income";
idxTemp2["rets26_feat20141229145502644200000000"]="Income/operating Inc: Gross Operating Income";
idxTemp2["rets26_feat20141229150931601578000000"]="Income/operating Inc: Improvement Allowance";
idxTemp2["rets26_feat20141229145440616012000000"]="Income/operating Inc: Noi";
idxTemp2["rets26_feat20141229145606182757000000"]="Income/operating Inc: Net Operating Income";
idxTemp2["rets26_feat20141229145547454159000000"]="Income/operating Inc: Total Operating Income";
idxTemp2["rets26_gf20141227195320847948000000"]="Included In Lease";
idxTemp2["rets26_gf20141227195308633273000000"]="Included In Sale";
idxTemp2["rets26_list_118"]="Lease $/sqft";
idxTemp2["rets26_gf20141227195245871670000000"]="Lease Provisions";
idxTemp2["rets26_list_22"]="List Price";
idxTemp2["rets26_list_125"]="List Price/sqft";
idxTemp2["rets26_list_117"]="Maint Fee";
idxTemp2["rets26_gf20141227001925179813000000"]="Maint Fee Covers";
idxTemp2["rets26_gf20150113203850400754000000"]="Maint Fee Covers";
idxTemp2["rets26_gf20141227192843436684000000"]="Maint Fee Covers";
idxTemp2["rets26_list_92"]="Maint Fee Paid";
idxTemp2["rets26_list_21"]="Original List Price";
idxTemp2["rets26_gf20150113144559808305000000"]="Owner Pays";
idxTemp2["rets26_list_94"]="Ownership Required";
idxTemp2["rets26_list_119"]="Per Month $";
idxTemp2["rets26_list_146"]="Recorded";
idxTemp2["rets26_list_36"]="Street Dir Suffix";
idxTemp2["rets26_synd_list_ref_url"]="Syndication Listing Reference Url";
idxTemp2["rets26_list_80"]="Tax Id";
idxTemp2["rets26_list_76"]="Tax Year";
idxTemp2["rets26_list_75"]="Taxes";
idxTemp2["rets26_gf20150113144548552928000000"]="Tenant Pays";
idxTemp2["rets26_list_60"]="Transaction";
idxTemp2["rets26_list_88"]="Type";

	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial / Legal Info", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	return arraytolist(arrR,'');
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>