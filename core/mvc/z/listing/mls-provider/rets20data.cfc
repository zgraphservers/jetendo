<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
	variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" access="remote" output="yes" returntype="any">
    	<cfscript>
	application.zcore.listingCom.makeListingImportDataReady();
	idxExclude={};
	tf=application.zcore.listingStruct.mlsStruct["20"].sharedStruct.metaStruct["property"].tableFields;
	n=0;
	for(curField in tf){  
		f2=tf[curField].longname; 
		n++;
		variables.allfields[n]={field:"rets20_"&curField, label:f2};
	}
		idxExclude["rets20_colistagent_mui"]="Co List Agent Mui";
		idxExclude["rets20_colistagentdirectworkphone"]="Co List Agent Direct Work Phone";
		idxExclude["rets20_colistagentemail"]="Co List Agent Email";
		idxExclude["rets20_colistagentfullname"]="Co List Agent Full Name";
		idxExclude["rets20_colistagentmlsid"]="Co List Agent Mlsid";
		idxExclude["rets20_colistoffice_mui"]="Co List Office Mui";
		idxExclude["rets20_colistofficemlsid"]="Co List Office Mlsid";
		idxExclude["rets20_colistofficename"]="Co List Office Name";
		idxExclude["rets20_colistofficephone"]="Co List Office Phone";
		idxExclude["rets20_compensationsubjectto"]="Compensation Subject To";
		idxExclude["rets20_cosellingagent_mui"]="Co Selling Agent Mui";
		idxExclude["rets20_cosellingagentdirectworkphone"]="Co Selling Agent Direct Work Pho";
		idxExclude["rets20_cosellingagentemail"]="Co Selling Agent Email";
		idxExclude["rets20_cosellingagentfullname"]="Co Selling Agent Full Name";
		idxExclude["rets20_cosellingagentmlsid"]="Co Selling Agent Mlsid";
		idxExclude["rets20_cosellingoffice_mui"]="Co Selling Office Mui";
		idxExclude["rets20_cosellingofficemlsid"]="Co Selling Office Mlsid";
		idxExclude["rets20_cosellingofficename"]="Co Selling Office Name";
		idxExclude["rets20_cosellingofficephone"]="Co Selling Office Phone";
		idxExclude["rets20_compensationmethod"]="Compensation Method";
		idxExclude["rets20_dualvariablecompensationyn"]="Dual Variable Compensation Yn";
		idxExclude["rets20_listagent_mui"]="List Agent Mui";
		idxExclude["rets20_listagentdirectworkphone"]="List Agent Direct Work Phone";
		idxExclude["rets20_listagentemail"]="List Agent Email";
		idxExclude["rets20_listagentfullname"]="List Agent Full Name";
		idxExclude["rets20_listagentmlsid"]="List Agent Mlsid";
		idxExclude["rets20_listoffice_mui"]="List Office Mui";
		idxExclude["rets20_listofficemlsid"]="List Office Mlsid";
		idxExclude["rets20_listofficename"]="List Office Name";
		idxExclude["rets20_listofficephone"]="List Office Phone";
		idxExclude["rets20_permitaddressinternetyn"]="Permit Address Internet Yn";
		idxExclude["rets20_permitinternetyn"]="Permit Internet Yn";
		idxExclude["rets20_managementcompanyname"]="Management Company Name";
		idxExclude["rets20_managementcompanyphone"]="Management Company Phone";
		idxExclude["rets20_matrix_unique_id"]="Matrix Unique Id";
		idxExclude["rets20_mlsnumber"]="Mls Number";
		idxExclude["rets20_publicremarks"]="Public Remarks";
		idxExclude["rets20_privateremarks"]="Private Remarks";
		idxExclude["rets20_sellingagent_mui"]="Selling Agent Mui";
		idxExclude["rets20_sellingagentdirectworkphone"]="Selling Agent Direct Work Phone";
		idxExclude["rets20_sellingagentemail"]="Selling Agent Email";
		idxExclude["rets20_sellingagentfullname"]="Selling Agent Full Name";
		idxExclude["rets20_sellingagentmlsid"]="Selling Agent Mlsid";
		idxExclude["rets20_sellingagentremarks"]="Selling Agent Remarks";
		idxExclude["rets20_sellingoffice_mui"]="Selling Office Mui";
		idxExclude["rets20_sellingofficemlsid"]="Selling Office Mlsid";
		idxExclude["rets20_sellingofficename"]="Selling Office Name";
		idxExclude["rets20_sellingofficephone"]="Selling Office Phone";
		idxExclude["rets20_showinginstructions"]="Showing Instructions";
		idxExclude["rets20_subagencycompensation"]="Sub Agency Compensation";
		idxExclude["rets20_streetdirprefix"]="Street Dir Prefix";
		idxExclude["rets20_streetdirsuffix"]="Street Dir Suffix";
		idxExclude["rets20_streetname"]="Street Name";
		idxExclude["rets20_streetnumber"]="Street Number";
		idxExclude["rets20_streetsuffix"]="Street Suffix";
		idxExclude["rets20_property_id"]="Property_id";
		
		application.zcore.listingCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
		// force allfields to not have the fields that already used
		this.getDetailCache1(structnew());
		this.getDetailCache2(structnew());
		this.getDetailCache3(structnew());
		
		if(structcount(variables.allfields) NEQ 0){
			writeoutput('<h2>All Fields:</h2>');
			local.arrF=structkeyarray(variables.allfields);
			arraysort(local.arrF, "text");
			for(i=1;i LTE arraylen(local.arrF);i++){
				if(structkeyexists(idxExclude, local.arrF[i]) EQ false){
					writeoutput('idxTemp2["'&local.arrF[i]&'"]="'&replace(application.zcore.functions.zfirstlettercaps(variables.allfields[local.arrF[i]]),"##","####")&'";<br />');
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
		
		idxTemp2["rets20_activecontinuetoshowdate"]="Active Continue To Show Date";
		idxTemp2["rets20_activeopenhousecount"]="Active Open House Count";
		idxTemp2["rets20_additionalparcelsyn"]="Additional Parcels Yn";
		idxTemp2["rets20_advertisedate"]="Advertise Date";
		idxTemp2["rets20_amenities"]="Amenities";
		idxTemp2["rets20_architecturalstyle"]="Architectural Style";
		idxTemp2["rets20_associationcommunityname"]="Association Community Name";
		idxTemp2["rets20_associationfee"]="Association Fee";
		idxTemp2["rets20_associationfee2"]="Association Fee 2";
		idxTemp2["rets20_associationfee2includes"]="Association Fee 2 Includes";
		idxTemp2["rets20_associationfeeincludes"]="Association Fee Includes";
		idxTemp2["rets20_associationfeetotal"]="Association Fee Total";
		idxTemp2["rets20_associationphone"]="Association Phone";
		idxTemp2["rets20_auctiondate"]="Auction Date";
		idxTemp2["rets20_backonmarketdate"]="Back On Market Date";
		idxTemp2["rets20_bathsfull"]="Baths Full";
		idxTemp2["rets20_bathshalf"]="Baths Half";
		idxTemp2["rets20_bathstotal"]="Baths Total";
		idxTemp2["rets20_bedstotal"]="Beds Total";
		idxTemp2["rets20_buildername"]="Builder Name";
		idxTemp2["rets20_buildingname"]="Building Name";
		idxTemp2["rets20_buildingtype"]="Building Type";
		idxTemp2["rets20_businessname"]="Business Name";
		idxTemp2["rets20_businesstype"]="Business Type";
		idxTemp2["rets20_businesstypedescription"]="Business Type Description";
		idxTemp2["rets20_buyerfinancing"]="Buyer Financing";
		idxTemp2["rets20_city"]="City";
		idxTemp2["rets20_closedate"]="Close Date";
		idxTemp2["rets20_closeprice"]="Close Price";
		idxTemp2["rets20_commercialspacesnumberof"]="Commercial Spaces Number Of";
		idxTemp2["rets20_commercialspaceyn"]="Commercial Space Yn";
		idxTemp2["rets20_concessions"]="Concessions";
		idxTemp2["rets20_conditionaldate"]="Conditional Date";
		idxTemp2["rets20_condoparkingunit"]="Condo Parking Unit";
		idxTemp2["rets20_condopropertyregimeyn"]="Condo Property Regime Yn";
		idxTemp2["rets20_constructionmaterials"]="Construction Materials";
		idxTemp2["rets20_conversionyear"]="Conversion Year";
		idxTemp2["rets20_cooling"]="Cooling";
		idxTemp2["rets20_countyorparish"]="County Or Parish";
		idxTemp2["rets20_cropsincludedyn"]="Crops Included Yn";
		idxTemp2["rets20_currentprice"]="Current Price";
		idxTemp2["rets20_daysopennumberof"]="Days Open Number Of";
		idxTemp2["rets20_depositamount"]="Deposit Amount";
		idxTemp2["rets20_disclosures"]="Disclosures";
		idxTemp2["rets20_divisionname"]="Division Name";
		idxTemp2["rets20_documents"]="Documents";
		idxTemp2["rets20_dom"]="Dom";
		idxTemp2["rets20_easements"]="Easements";
		idxTemp2["rets20_elementaryschool"]="Elementary School";
		idxTemp2["rets20_elevatorsfreightnumberof"]="Elevators Freight Number Of";
		idxTemp2["rets20_elevatorsnumberof"]="Elevators Number Of";
		idxTemp2["rets20_employees"]="Employees";
		idxTemp2["rets20_exclusions"]="Exclusions";
		idxTemp2["rets20_expensesinclude"]="Expenses Include";
		idxTemp2["rets20_expensesinformationsource"]="Expenses Information Source";
		idxTemp2["rets20_feeoptions"]="Fee Options";
		idxTemp2["rets20_feepurchase"]="Fee Purchase";
		idxTemp2["rets20_floodzonecode"]="Flood Zone Code";
		idxTemp2["rets20_flooring"]="Flooring";
		idxTemp2["rets20_floornumber"]="Floor Number";
		idxTemp2["rets20_forecloseurecivilcasenumber"]="Forecloseure Civil Case Number";
		idxTemp2["rets20_foreclosureyn"]="Foreclosure Yn";
		idxTemp2["rets20_foreigncountryorstate"]="Foreign Country Or State";
		idxTemp2["rets20_fractionalownershipyn"]="Fractional Ownership Yn";
		idxTemp2["rets20_franchisefee"]="Franchise Fee";
		idxTemp2["rets20_furnished"]="Furnished";
		idxTemp2["rets20_grossincome"]="Gross Income";
		idxTemp2["rets20_highschool"]="High School";
		idxTemp2["rets20_hoursopen"]="Hours Open";
		idxTemp2["rets20_improvements"]="Improvements";
		idxTemp2["rets20_inclusions"]="Inclusions";
		idxTemp2["rets20_incomeinformationsource"]="Income Information Source";
		idxTemp2["rets20_isdeleted"]="Is Deleted";
		idxTemp2["rets20_landlordname"]="Landlord Name";
		idxTemp2["rets20_landlordphone"]="Landlord Phone";
		idxTemp2["rets20_landrecorded"]="Land Recorded";
		idxTemp2["rets20_landtenure"]="Land Tenure";
		idxTemp2["rets20_landuse"]="Land Use";
		idxTemp2["rets20_lastchangetimestamp"]="Last Change Timestamp";
		idxTemp2["rets20_laundryfacilities"]="Laundry Facilities";
		idxTemp2["rets20_leaseexpirationdate"]="Lease Expiration Date";
		idxTemp2["rets20_leaseexpirationyear"]="Lease Expiration Year";
		idxTemp2["rets20_leasefeemonth"]="Lease Fee Month";
		idxTemp2["rets20_leaseprice"]="Lease Price";
		idxTemp2["rets20_leaserenegotiationdate"]="Lease Renegotiation Date";
		idxTemp2["rets20_leasetype"]="Lease Type";
		idxTemp2["rets20_lessorname"]="Lessor Name";
		idxTemp2["rets20_lessorname2"]="Lessor Name 2";
		idxTemp2["rets20_listingagreement"]="Listing Agreement";
		idxTemp2["rets20_listingcontractdate"]="Listing Contract Date";
		idxTemp2["rets20_listingfinancing"]="Listing Financing";
		idxTemp2["rets20_listingservice"]="Listing Service";
		idxTemp2["rets20_listprice"]="List Price";
		idxTemp2["rets20_loading"]="Loading";
		idxTemp2["rets20_location"]="Location";
		idxTemp2["rets20_lockboxyn"]="Lock Box Yn";
		idxTemp2["rets20_lotfeatures"]="Lot Features";
		idxTemp2["rets20_lotsizearea"]="Lot Size Area";
		idxTemp2["rets20_lotsizedimensions"]="Lot Size Dimensions";
		idxTemp2["rets20_maintenanceexpense"]="Maintenance Expense";
		idxTemp2["rets20_matrixmodifieddt"]="Matrix Modified Dt";
		idxTemp2["rets20_middleorjuniorschool"]="Middle Or Junior School";
		idxTemp2["rets20_mls"]="Mls";
		idxTemp2["rets20_mlsareamajor"]="Mls Area Major";
		idxTemp2["rets20_model"]="Model";
		idxTemp2["rets20_modelsitecontactname"]="Model Site Contact Name";
		idxTemp2["rets20_modelsitecontactphone"]="Model Site Contact Phone";
		idxTemp2["rets20_modelsiteopenhours"]="Model Site Open Hours";
		idxTemp2["rets20_neighbourhood"]="Neighborhood";
		idxTemp2["rets20_netoperatingincome"]="Net Operating Income";
		idxTemp2["rets20_newdevelopmentconstructionyn"]="New Development Construction Yn";
		idxTemp2["rets20_numberofunitstotal"]="Number Of Units Total";
		idxTemp2["rets20_occupanttype"]="Occupant Type";
		idxTemp2["rets20_offmarketdate"]="Off Market Date";
		idxTemp2["rets20_openhousecount"]="Open House Count";
		idxTemp2["rets20_openhouseupcoming"]="Open House Upcoming";
		idxTemp2["rets20_originalentrytimestamp"]="Original Entry Timestamp";
		idxTemp2["rets20_originallistprice"]="Original List Price";
		idxTemp2["rets20_otherincome"]="Other Income";
		idxTemp2["rets20_otherparkingfeatures"]="Other Parking Features";
		idxTemp2["rets20_owneroccupancypercentage"]="Owner Occupancy Percentage";
		idxTemp2["rets20_ownershiptype"]="Ownership Type";
		idxTemp2["rets20_parcelnumber"]="Parcel Number";
		idxTemp2["rets20_parkingadditional"]="Parking Additional";
		idxTemp2["rets20_parkingfeatures"]="Parking Features";
		idxTemp2["rets20_parkingtotal"]="Parking Total";
		idxTemp2["rets20_pendingdate"]="Pending Date";
		idxTemp2["rets20_petsallowed"]="Pets Allowed";
		idxTemp2["rets20_petsallowedyn"]="Pets Allowed Yn";
		idxTemp2["rets20_photocount"]="Photo Count";
		idxTemp2["rets20_photomodificationtimestamp"]="Photo Modification Timestamp";
		idxTemp2["rets20_poolfeatures"]="Pool Features";
		idxTemp2["rets20_possession"]="Possession";
		idxTemp2["rets20_possibleuse"]="Possible Use";
		idxTemp2["rets20_postalcode"]="Postal Code";
		idxTemp2["rets20_postalcodeplus4"]="Postal Code Plus 4";
		idxTemp2["rets20_pricechangetimestamp"]="Price Change Timestamp";
		idxTemp2["rets20_projectpublicreportnumber"]="Project Public Report Number";
		idxTemp2["rets20_propertycondition"]="Property Condition";
		idxTemp2["rets20_propertyfrontage"]="Property Frontage";
		idxTemp2["rets20_propertysubtype"]="Property Sub Type";
		idxTemp2["rets20_propertytype"]="Property Type";
		idxTemp2["rets20_providermodificationtimestamp"]="Provider Modification Timestamp";
		idxTemp2["rets20_publicreportnumber"]="Public Report Number";
		idxTemp2["rets20_recreationfacilities"]="Recreation Facilities";
		idxTemp2["rets20_remodelled"]="Remodelled";
		idxTemp2["rets20_rentaltype"]="Rental Type";
		idxTemp2["rets20_rentalunitavailabledate"]="Rental Unit Available Date";
		idxTemp2["rets20_rentstepupmonthfirst"]="Rent Step Up Month First";
		idxTemp2["rets20_rentstepupmonthsecond"]="Rent Step Up Month Second";
		idxTemp2["rets20_rentyearfirst"]="Rent Year First";
		idxTemp2["rets20_rentyearsecond"]="Rent Year Second";
		idxTemp2["rets20_residentmanageryn"]="Resident Manager Yn";
		idxTemp2["rets20_restrictions"]="Restrictions";
		idxTemp2["rets20_roadfrontage"]="Road Frontage";
		idxTemp2["rets20_roof"]="Roof";
		idxTemp2["rets20_roomcount"]="Room Count";
		idxTemp2["rets20_section8yn"]="Section 8 Yn";
		idxTemp2["rets20_securityfeatures"]="Security Features";
		idxTemp2["rets20_setbacks"]="Set Backs";
		idxTemp2["rets20_sewer"]="Sewer";
		idxTemp2["rets20_speciallistingconditions"]="Special Listing Conditions";
		idxTemp2["rets20_sqftbuilding"]="Sqft Building";
		idxTemp2["rets20_sqftgaragecarport"]="Sqft Garage Carport";
		idxTemp2["rets20_sqftinterior"]="Sqft Interior";
		idxTemp2["rets20_sqftlanaicovered"]="Sqft Lanai Covered";
		idxTemp2["rets20_sqftlanaiopen"]="Sqft Lanai Open";
		idxTemp2["rets20_sqftother"]="Sqft Other";
		idxTemp2["rets20_sqftroofedliving"]="Sqft Roofed Living";
		idxTemp2["rets20_sqftroofedother"]="Sqft Roofed Other";
		idxTemp2["rets20_sqfttotal"]="Sqft Total";
		idxTemp2["rets20_standardindustrialclassification"]="Standard Industrial Classificati";
		idxTemp2["rets20_stateorprovince"]="State Or Province";
		idxTemp2["rets20_status"]="Status";
		idxTemp2["rets20_statuschangetimestamp"]="Status Change Timestamp";
		idxTemp2["rets20_statuscontractualsearchdate"]="Status Contractual Search Date";
		idxTemp2["rets20_stories"]="Stories";
		idxTemp2["rets20_storiestype"]="Stories Type";
		idxTemp2["rets20_streetviewparam"]="Street View Param";
		idxTemp2["rets20_structurespresentyn"]="Structures Present Yn";
		idxTemp2["rets20_studiounitsnumberof"]="Studio Units Number Of";
		idxTemp2["rets20_supplementcount"]="Supplement Count";
		idxTemp2["rets20_supplementmodificationtimestamp"]="Supplement Modification Timestam";
		idxTemp2["rets20_table"]="Table";
		idxTemp2["rets20_taxamount"]="Tax Amount";
		idxTemp2["rets20_taxassessedvalue"]="Tax Assessed Value";
		idxTemp2["rets20_taxassessedvalueimprovements"]="Tax Assessed Value Improvements";
		idxTemp2["rets20_taxassessedvalueland"]="Tax Assessed Value Land";
		idxTemp2["rets20_taxexcemptionowneroccupancy"]="Tax Excemption Owner Occupancy";
		idxTemp2["rets20_taxlot"]="Tax Lot";
		idxTemp2["rets20_taxpaidbyselleryn"]="Tax Paid By Seller Yn";
		idxTemp2["rets20_taxyear"]="Tax Year";
		idxTemp2["rets20_tempoffmarketdate"]="Temp Off Market Date";
		idxTemp2["rets20_temporarilywithdrawndate"]="Temporarily Withdrawn Date";
		idxTemp2["rets20_tenantsresponsibilitiesincludes"]="Tenants Responsibilities Include";
		idxTemp2["rets20_tmkarea"]="Tmk Area";
		idxTemp2["rets20_tmkcondopropertyregimenumber"]="Tmk Condo Property Regime Number";
		idxTemp2["rets20_tmkdivision"]="Tmk Division";
		idxTemp2["rets20_tmkparcel"]="Tmk Parcel";
		idxTemp2["rets20_tmkplat"]="Tmkplat";
		idxTemp2["rets20_tmksection"]="Tmk Section";
		idxTemp2["rets20_tmkzone"]="Tmk Zone";
		idxTemp2["rets20_topography"]="Topography";
		idxTemp2["rets20_totalactualrent"]="Total Actual Rent";
		idxTemp2["rets20_totalannualoperatingexpenses"]="Total Annual Operating Expenses";
		idxTemp2["rets20_totalincome"]="Total Income";
		idxTemp2["rets20_unitcount"]="Unit Count";
		idxTemp2["rets20_unitfeatures"]="Unit Features";
		idxTemp2["rets20_unitnumber"]="Unit Number";
		idxTemp2["rets20_unitonebednumberof"]="Unit One Bed Number Of";
		idxTemp2["rets20_unitthreebednumberof"]="Unit Three Bed Number Of";
		idxTemp2["rets20_unittwobednumberof"]="Unit Two Bed Number Of";
		idxTemp2["rets20_utilities"]="Utilities";
		idxTemp2["rets20_utilitiesmeters"]="Utilities Meters";
		idxTemp2["rets20_view"]="View";
		idxTemp2["rets20_virtualtoururlunbranded"]="Virtual Tour Url Unbranded";
		idxTemp2["rets20_withdrawndate"]="Withdrawn Date";
		idxTemp2["rets20_yearbuilt"]="Year Built";
		idxTemp2["rets20_yearestablished"]="Year Established";
		idxTemp2["rets20_yearremodeled"]="Year Remodeled";
		idxTemp2["rets20_zoning"]="Zoning";
		
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