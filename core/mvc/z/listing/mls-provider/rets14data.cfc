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

	<!--- <table class="ztablepropertyinfo"> --->
    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
        /*
        idxTemp2["rets14_ListDate"]="List Date";
        idxTemp2["rets14_Timestamp"]="Timestamp";
        idxTemp2["rets14_WithdrawalDate"]="Withdrawal Date";
        idxTemp2["rets14_PictureTimestamp"]="Picture Timestamp";
        idxTemp2["rets14_SoldDate"]="Sold Date";
        idxTemp2["rets14_StatusChangeDate"]="Status Change Date";
        idxTemp2["rets14_EntryTimestamp"]="Entry Timestamp";
        */
        
        idxTemp2["rets14_##Furnished"]="## Furnished";
        idxTemp2["rets14_##Unfurnished"]="## Unfurnished";
        idxTemp2["rets14_##VehicleSpaces"]="## Vehicle Spaces";
        idxTemp2["rets14_AcreageDescription:ClearedAcreage"]="Acreage Description: Cleared Acreage";
        idxTemp2["rets14_AcreageDescription:FencedAcreage"]="Acreage Description: Fenced Acreage";
        idxTemp2["rets14_AcreageDescription:TillableAcreage"]="Acreage Description: Tillable Acreage";
        idxTemp2["rets14_AcreageDescription:WoodedAcreage"]="Acreage Description: Wooded Acreage";
        idxTemp2["rets14_AcresCleared"]="Acres Cleared";
        idxTemp2["rets14_AcresFenced"]="Acres Fenced";
        idxTemp2["rets14_AcresWooded"]="Acres Wooded";
        idxTemp2["rets14_Add'lCoveredPrkng"]="Add'l Covered Prkng";
        idxTemp2["rets14_Add'lParkingSpaces"]="Add'l Parking Spaces";
        //idxTemp2["rets14_AgentID"]="Agent ID";
        idxTemp2["rets14_AmenitiesCommon"]="Amenities Common";
        
        idxTemp2["rets14_Area"]="Area";
        idxTemp2["rets14_AreaAmenities"]="Area Amenities";
        idxTemp2["rets14_AreaExt"]="Area Ext";
        
        
        
        idxTemp2["rets14_Expenses:ElectricExp"]="Expenses: Electric Exp";
        idxTemp2["rets14_Expenses:GasExp"]="Expenses: Gas Exp";
        idxTemp2["rets14_Expenses:InsuranceExp"]="Expenses: Insurance Exp";
        idxTemp2["rets14_Expenses:MaintenanceExp"]="Expenses: Maintenance Exp";
        idxTemp2["rets14_Expenses:ManagementExp"]="Expenses: Management Exp";
        idxTemp2["rets14_Expenses:OilExp"]="Expenses: Oil Exp";
        idxTemp2["rets14_Expenses:OtherExp"]="Expenses: Other Exp";
        idxTemp2["rets14_Expenses:TaxExp"]="Expenses: Tax Exp";
        idxTemp2["rets14_Expenses:WaterExp"]="Expenses: Water Exp";
        idxTemp2["rets14_DocumentsAvailable"]="Documents Available";
        
        idxTemp2["rets14_EnergyFeatures"]="Energy Features";
        idxTemp2["rets14_GasDescription"]="Gas Description";
        
        
        
        idxTemp2["rets14_City"]="City";
        
        
        idxTemp2["rets14_Construction"]="Construction";
        idxTemp2["rets14_ConstructionStatus"]="Construction Status";
        idxTemp2["rets14_Contact"]="Contact";
        idxTemp2["rets14_ContactPhone"]="Contact Phone";
        idxTemp2["rets14_Contingent"]="Contingent";
        idxTemp2["rets14_Cooling"]="Cooling";
        idxTemp2["rets14_Directions"]="Directions";
        //idxTemp2["rets14_DisplayonPublicWebsites"]="Display on Public Websites";
        idxTemp2["rets14_ElectricDescription"]="Electric Description";
        idxTemp2["rets14_ExteriorDoors"]="Exterior Doors";
        idxTemp2["rets14_ExteriorFeatures"]="Exterior Features";
        idxTemp2["rets14_FarmType"]="Farm Type";
        idxTemp2["rets14_Fireplace"]="Fireplace";
        idxTemp2["rets14_Fireplace:##Fireplaces"]="Fireplace: ## Fireplaces";
        idxTemp2["rets14_Floors"]="Floors";
        idxTemp2["rets14_GrossIncome"]="Gross Income";
        idxTemp2["rets14_Heating"]="Heating";
        idxTemp2["rets14_HowSold"]="How Sold";
        idxTemp2["rets14_InteriorFeatures"]="Interior Features";
        //idxTemp2["rets14_InternalListingID"]="Internal Listing ID";
        idxTemp2["rets14_LandDescription"]="Land Description";
        idxTemp2["rets14_LandSub-Type"]="Land Sub-Type";
        idxTemp2["rets14_LandType"]="Land Type";
        idxTemp2["rets14_LaundryLevel"]="Laundry Level";
        idxTemp2["rets14_LaundryRoomLevel"]="Laundry Room Level";
        idxTemp2["rets14_LeaseType"]="Lease Type";
        idxTemp2["rets14_LibraryLevel"]="Library Level";
        idxTemp2["rets14_LibraryRoomLevel"]="Library Room Level";
        idxTemp2["rets14_LIST_135"]="LIST_135";
        //idxTemp2["rets14_ListingID"]="Listing ID";
        idxTemp2["rets14_ListingType"]="Listing Type";
        //idxTemp2["rets14_ListNumberMain"]="List Number Main";
        idxTemp2["rets14_ListNumberPrefix"]="List Number Prefix";
        idxTemp2["rets14_ListPrice"]="List Price";
        idxTemp2["rets14_Location"]="Location";
        idxTemp2["rets14_LockBoxHours"]="Lock Box Hours";
        idxTemp2["rets14_LockBoxY/N"]="Lock Box Y/N";
        idxTemp2["rets14_Lot"]="Lot";
        idxTemp2["rets14_LotDescription"]="Lot Description";
        idxTemp2["rets14_Misc.Information:LandUsePlan"]="Misc. Information: Land Use Plan";
        idxTemp2["rets14_Misc.Information:MobileHomeAllowed"]="Misc. Information: Mobile Home Allowed";
        idxTemp2["rets14_Misc.Information:RoadFrontage"]="Misc. Information: Road Frontage";
        idxTemp2["rets14_Misc.Information:Three-PhasePower"]="Misc. Information: Three-Phase Power";
        idxTemp2["rets14_Misc.Information:UndergroundTanks"]="Misc. Information: Underground Tanks";
        idxTemp2["rets14_MiscellaneousInfo:DoubleWide"]="Miscellaneous Info: Double Wide";
        idxTemp2["rets14_MiscellaneousInfo:PaidUtilities"]="Miscellaneous Info: Paid Utilities";
        idxTemp2["rets14_MiscellaneousInfo:PublicTransport"]="Miscellaneous Info: Public Transport";
        idxTemp2["rets14_MiscellaneousInfo:SingleWide"]="Miscellaneous Info: Single Wide";
        idxTemp2["rets14_MiscellaneousInfo:Upgrades"]="Miscellaneous Info: Upgrades";
        idxTemp2["rets14_MiscFeatures"]="Misc Features";
        //idxTemp2["rets14_MLSApproved"]="MLS Approved";
        //idxTemp2["rets14_MLSIdentifier"]="MLS Identifier";
        idxTemp2["rets14_MobileAllowed"]="Mobile Allowed";
        idxTemp2["rets14_Multi-FamilyType"]="Multi-Family Type";
        idxTemp2["rets14_Municipality"]="Municipality";
        idxTemp2["rets14_NetOperatingIncome"]="Net Operating Income";
        //idxTemp2["rets14_OfficeID"]="Office ID";
        idxTemp2["rets14_OriginalListPrice"]="Original List Price";
        idxTemp2["rets14_OtherWaterDetails:ChannelMarker"]="Other Water Details: Channel Marker";
        idxTemp2["rets14_OtherWaterDetails:LengthofWaterfront"]="Other Water Details: Length of Waterfront";
        idxTemp2["rets14_OtherWaterDetails:NbrofCoveredSlips"]="Other Water Details: Nbr of Covered Slips";
        idxTemp2["rets14_OtherWaterDetails:NbrofUncvrdSlips"]="Other Water Details: Nbr of Uncvrd Slips";
        idxTemp2["rets14_OtherWaterDetails:NumberCoveredSlips"]="Other Water Details: Number Covered Slips";
        idxTemp2["rets14_OtherWaterDetails:NumberUncoverSlips"]="Other Water Details: Number Uncover Slips";
        idxTemp2["rets14_OtherWaterDetails:RiverorOther"]="Other Water Details: River or Other";
        idxTemp2["rets14_OtherWaterDetails:ShorelineMgmtPlan"]="Other Water Details: Shoreline Mgmt Plan";
        idxTemp2["rets14_Owner"]="Owner";
        idxTemp2["rets14_OwnerExpenses"]="Owner Expenses";
        idxTemp2["rets14_OwnerPhone"]="Owner Phone";
        idxTemp2["rets14_ParkingDescription"]="Parking Description";
        idxTemp2["rets14_PendedInBookY/N"]="Pended In Book Y/N";
        idxTemp2["rets14_Phase"]="Phase";
        idxTemp2["rets14_PictureCount"]="Picture Count";
        idxTemp2["rets14_POADues"]="POA Dues";
        idxTemp2["rets14_POATerms"]="POA Terms";
        idxTemp2["rets14_Porch"]="Porch";
        idxTemp2["rets14_PresentUse"]="Present Use";
        idxTemp2["rets14_PricePerAcre"]="Price Per Acre";
        idxTemp2["rets14_Prim.CoveredPrking"]="Prim. Covered Prking";
        //idxTemp2["rets14_PrivateRemarks"]="Private Remarks";
        idxTemp2["rets14_PropertyDescription"]="Property Description";
        //idxTemp2["rets14_PropertyGroupID"]="Property Group ID";
        idxTemp2["rets14_PropertyType"]="Property Type";
        idxTemp2["rets14_PropOwnersAssoc"]="Prop Owners Assoc";
        //idxTemp2["rets14_PublicRemarks"]="Public Remarks";
        idxTemp2["rets14_RatifiedContractDt"]="Ratified Contract Dt";
        idxTemp2["rets14_Realtor.com"]="Realtor.com";
        idxTemp2["rets14_ResidentialType"]="Residential Type";
        idxTemp2["rets14_RoadFrontage"]="Road Frontage";
        idxTemp2["rets14_SAComp"]="SA Comp";
        idxTemp2["rets14_SACompensation"]="SA Compensation";
        idxTemp2["rets14_Section"]="Section";
        idxTemp2["rets14_SewerDescription"]="Sewer Description";
        idxTemp2["rets14_SFEntryHeated/Fnsh"]="SF Entry Heated/Fnsh";
        idxTemp2["rets14_SFEntryUnfnshed"]="SF Entry Unfnshed";
        idxTemp2["rets14_SFLowerHeated/Fnsh"]="SF Lower Heated/Fnsh";
        idxTemp2["rets14_SFLowerUnfnshed"]="SF Lower Unfnshed";
        idxTemp2["rets14_SFOtherHeated/Fnsh"]="SF Other Heated/Fnsh";
        idxTemp2["rets14_SFOtherUnfnshed"]="SF Other Unfnshed";
        idxTemp2["rets14_SFUpperHeated/Fnsh"]="SF Upper Heated/Fnsh";
        idxTemp2["rets14_SFUpperUnfnshed"]="SF Upper Unfnshed";
        idxTemp2["rets14_SoldPrice"]="Sold Price";
        idxTemp2["rets14_State/Province"]="State/Province";
        /*idxTemp2["rets14_StreetDirectionPfx"]="Street Direction Pfx";
        idxTemp2["rets14_StreetDirectionSfx"]="Street Direction Sfx";
        idxTemp2["rets14_StreetName"]="Street Name";
        idxTemp2["rets14_StreetNumber"]="Street Number";
        idxTemp2["rets14_StreetSuffix"]="Street Suffix";
        */
        idxTemp2["rets14_Style"]="Style";
        idxTemp2["rets14_SubagentAuthorized"]="Subagent Authorized";
        idxTemp2["rets14_Subdivision"]="Subdivision";
        idxTemp2["rets14_SubdivisionMap"]="Subdivision Map";
        idxTemp2["rets14_TaxID"]="Tax ID";
        idxTemp2["rets14_Tenant"]="Tenant";
        idxTemp2["rets14_TenantExpenses"]="Tenant Expenses";
        idxTemp2["rets14_TenantPhone"]="Tenant Phone";
        idxTemp2["rets14_Terms"]="Terms";
        idxTemp2["rets14_TotalAcreage"]="Total Acreage";
        idxTemp2["rets14_TotalAnnualExpen"]="Total Annual Expen";
        idxTemp2["rets14_TotalBdrm"]="Total Bdrm";
        idxTemp2["rets14_TotalBths"]="Total Bths";
        idxTemp2["rets14_TotalCov'dPrkSpc"]="Total Cov'd Prk Spc";
        idxTemp2["rets14_TotalFBaths"]="Total F Baths";
        idxTemp2["rets14_TotalFBths"]="Total F Bths";
        idxTemp2["rets14_TotalHBaths"]="Total H Baths";
        idxTemp2["rets14_TotalUnits"]="Total Units";
        //idxTemp2["rets14_UnBrandedVirtualTour"]="UnBranded Virtual Tour";
        idxTemp2["rets14_Uncovered##Spaces"]="Uncovered ## Spaces";
        idxTemp2["rets14_UncoveredParking"]="Uncovered Parking";
        idxTemp2["rets14_Unit##"]="Unit ##";
        idxTemp2["rets14_VariableRateBrkrge"]="Variable Rate Brkrge";
        idxTemp2["rets14_WaterAccessOnly"]="Water Access Only";
        idxTemp2["rets14_WaterClass"]="Water Class";
        idxTemp2["rets14_WaterDescription"]="Water Description";
        idxTemp2["rets14_WaterFeatures"]="Water Features";
        idxTemp2["rets14_WaterID"]="Water ID";
        idxTemp2["rets14_Windows"]="Windows";
        idxTemp2["rets14_YardSign"]="Yard Sign";
        idxTemp2["rets14_YearBuilt"]="Year Built";
        idxTemp2["rets14_ZipCode"]="Zip Code";
        idxTemp2["rets14_ZoningCode"]="Zoning Code";


        
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
        
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		// Room / Building Information
		idxTemp2["rets14_Appliances"]="Appliances";
		idxTemp2["rets14_ApartmentLevel"]="Apartment Level";
		idxTemp2["rets14_ApartmentRoomLevel"]="Apartment Room Level";
		idxTemp2["rets14_BAComp"]="BA Comp";
		idxTemp2["rets14_AtticLevel"]="Attic Level";
		idxTemp2["rets14_AtticRoomLevel"]="Attic Room Level";
		idxTemp2["rets14_Basement"]="Basement";
		idxTemp2["rets14_BasementY/N"]="Basement Y/N";
		idxTemp2["rets14_Bedroom1Level"]="Bedroom 1 Level";
		idxTemp2["rets14_Bedroom1RoomLevel"]="Bedroom 1 Room Level";
		idxTemp2["rets14_Bedroom2Level"]="Bedroom 2 Level";
		idxTemp2["rets14_Bedroom2RoomLevel"]="Bedroom 2 Room Level";
		idxTemp2["rets14_Bedroom3Level"]="Bedroom 3 Level";
		idxTemp2["rets14_Bedroom3RoomLevel"]="Bedroom 3 Room Level";
		idxTemp2["rets14_Bedroom4Level"]="Bedroom 4 Level";
		idxTemp2["rets14_Bedroom4RoomLevel"]="Bedroom 4 Room Level";
		idxTemp2["rets14_Bedroom5Level"]="Bedroom 5 Level";
		idxTemp2["rets14_Bedroom5RoomLevel"]="Bedroom 5 Room Level";
		idxTemp2["rets14_Bedroom6Level"]="Bedroom 6 Level";
		idxTemp2["rets14_Bedroom6RoomLevel"]="Bedroom 6 Room Level";
		idxTemp2["rets14_Bedroom7Level"]="Bedroom 7 Level";
		idxTemp2["rets14_Bedroom7RoomLevel"]="Bedroom 7 Room Level";
		idxTemp2["rets14_Bedroom8Level"]="Bedroom 8 Level";
		idxTemp2["rets14_Bedroom8RoomLevel"]="Bedroom 8 Room Level";
		idxTemp2["rets14_Bedrooms:BedroomsEntryLevel"]="Bedrooms: Bedrooms Entry Level";
		idxTemp2["rets14_Bedrooms:BedroomsLowerLevel"]="Bedrooms: Bedrooms Lower Level";
		idxTemp2["rets14_Bedrooms:BedroomsOtherLevel"]="Bedrooms: Bedrooms Other Level";
		idxTemp2["rets14_Bedrooms:BedroomsUpperLevel"]="Bedrooms: Bedrooms Upper Level";
		idxTemp2["rets14_BldgsonProperty"]="Bldgs on Property";
		idxTemp2["rets14_Block"]="Block";
		idxTemp2["rets14_BoatDockDesc"]="Boat Dock Desc";
		idxTemp2["rets14_BreakfastAreaLevel"]="Breakfast Area Level";
		idxTemp2["rets14_BreakfastAreaRoomLevel"]="Breakfast Area Room Level";
		idxTemp2["rets14_DenLevel"]="Den Level";
		idxTemp2["rets14_DenRoomLevel"]="Den Room Level";
		idxTemp2["rets14_DiningAreaLevel"]="Dining Area Level";
		idxTemp2["rets14_DiningAreaRoomLevel"]="Dining Area Room Level";
		idxTemp2["rets14_DiningRoomLevel"]="Dining Room Level";
		idxTemp2["rets14_DiningRoomRoomLevel"]="Dining Room Room Level";
		idxTemp2["rets14_Eat-inKitchenLevel"]="Eat-in Kitchen Level";
		idxTemp2["rets14_Eat-inKitchenRoomLevel"]="Eat-in Kitchen Room Level";
		idxTemp2["rets14_Entry-SQFTFin/Ht"]="Entry - SQFT Fin/Ht";
		idxTemp2["rets14_Entry-SQFTUnfin"]="Entry - SQFT Unfin";
		idxTemp2["rets14_FamilyRoomLevel"]="Family Room Level";
		idxTemp2["rets14_FamilyRoomRoomLevel"]="Family Room Room Level";
		idxTemp2["rets14_FloridaRoomLevel"]="Florida Room Level";
		idxTemp2["rets14_FloridaroomRoomLevel"]="Florida room Room Level";
		idxTemp2["rets14_FullBaths:FullBathsEntryLvl"]="Full Baths: Full Baths Entry Lvl";
		idxTemp2["rets14_FullBaths:FullBathsLowerLvl"]="Full Baths: Full Baths Lower Lvl";
		idxTemp2["rets14_FullBaths:FullBathsOtherLvl"]="Full Baths: Full Baths Other Lvl";
		idxTemp2["rets14_FullBaths:FullBathsUpperLvl"]="Full Baths: Full Baths Upper Lvl";
		idxTemp2["rets14_FoyerLevel"]="Foyer Level";
		idxTemp2["rets14_FoyerRoomLevel"]="Foyer Room Level";
		idxTemp2["rets14_GameRoomLevel"]="Game Room Level";
		idxTemp2["rets14_GameRoomRoomLevel"]="Game Room Room Level";
		idxTemp2["rets14_GreatRoomLevel"]="Great Room Level";
		idxTemp2["rets14_GreatRoomRoomLevel"]="Great Room Room Level";
		idxTemp2["rets14_HalfBaths:HalfBathsEntryLvl"]="Half Baths: Half Baths Entry Lvl";
		idxTemp2["rets14_HalfBaths:HalfBathsLowerLvl"]="Half Baths: Half Baths Lower Lvl";
		idxTemp2["rets14_HalfBaths:HalfBathsOtherLvl"]="Half Baths: Half Baths Other Lvl";
		idxTemp2["rets14_HalfBaths:HalfBathsUpperLvl"]="Half Baths: Half Baths Upper Lvl";
		idxTemp2["rets14_KitchenLevel"]="Kitchen Level";
		idxTemp2["rets14_KitchenRoomLevel"]="Kitchen Room Level";
		idxTemp2["rets14_LivingRoomLevel"]="Living Room Level";
		idxTemp2["rets14_LivingRoomRoomLevel"]="Living Room Room Level";
		idxTemp2["rets14_MasterBedroom1Level"]="Master Bedroom 1 Level";
		idxTemp2["rets14_MasterBedroom1RoomLevel"]="Master Bedroom 1 Room Level";
		idxTemp2["rets14_MasterBedroom2Level"]="Master Bedroom 2 Level";
		idxTemp2["rets14_MasterBedroom2RoomLevel"]="Master Bedroom 2 Room Level";
		idxTemp2["rets14_MudRoomLevel"]="Mud Room Level";
		idxTemp2["rets14_MudRoomRoomLevel"]="Mud Room Room Level";
		idxTemp2["rets14_OfficeLevel"]="Office Level";
		idxTemp2["rets14_OfficeRoomLevel"]="Office Room Level";
		idxTemp2["rets14_RecreationRoomLevel"]="Recreation Room Level";
		idxTemp2["rets14_RecreationRoomRoomLevel"]="Recreation Room Room Level";
		idxTemp2["rets14_Room##"]="Room ##";
		idxTemp2["rets14_RoomArea"]="Room Area";
		idxTemp2["rets14_RoomLength"]="Room Length";
		idxTemp2["rets14_RoomLevel"]="Room Level";
		idxTemp2["rets14_RoomPictureID"]="Room Picture ID";
		idxTemp2["rets14_RoomRemarks"]="Room Remarks";
		idxTemp2["rets14_RoomWidth"]="Room Width";
		idxTemp2["rets14_WorkRoomLevel"]="Work Room Level";
		idxTemp2["rets14_WorkRoomRoomLevel"]="Work Room Room Level";

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Room &amp; Building Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		// legal / financial
		idxTemp2["rets14_AnnualTaxes"]="Annual Taxes";
		idxTemp2["rets14_##LeasedUnits"]="## Leased Units";
		idxTemp2["rets14_BuildingonProp"]="Building on Prop";
		idxTemp2["rets14_BuyerAgtAuthorized"]="Buyer Agt Authorized";
		idxTemp2["rets14_CancelDate"]="Cancel Date";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Legal &amp; Financial Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		idxTemp2=structnew();
		idxTemp2["rets14_ElementarySchool"]="Elementary School";
		idxTemp2["rets14_MiddleSchool"]="Middle School";
		idxTemp2["rets14_HighSchool"]="High School";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("School Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		idxTemp2=structnew();
		idxTemp2["rets14_GrossBldgSQFT"]="Gross Bldg SQFT";
		idxTemp2["rets14_Lower-SQFTFin/Ht"]="Lower - SQFT Fin/Ht";
		idxTemp2["rets14_Lower-SQFTUnfin"]="Lower - SQFT Unfin";
		idxTemp2["rets14_Other-SQFTFin/Ht"]="Other - SQFT Fin/Ht";
		idxTemp2["rets14_Other-SQFTUnfin"]="Other - SQFT Unfin";
		idxTemp2["rets14_TotalFnshdSqFt"]="Total Fnshd SqFt";
		idxTemp2["rets14_TotalUnfinSQFT"]="Total Unfin SQFT";
		idxTemp2["rets14_TotalUnfnshdSqFt"]="Total Unfnshd SqFt";
		idxTemp2["rets14_Upper-SQFTFin/Ht"]="Upper - SQFT Fin/Ht";
		idxTemp2["rets14_Upper-SQFTUnfin"]="Upper - SQFT Unfin";
		idxTemp2["rets14_LotDimensions"]="Lot Dimensions";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("SQFT and Dimensions", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>