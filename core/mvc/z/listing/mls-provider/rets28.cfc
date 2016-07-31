<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
<cfscript>
this.retsVersion="1.7";

this.mls_id=28;
if(request.zos.istestserver){
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/28/";
}else{
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/28/";
}
this.caseSensitiveLookup=true;
this.useRetsFieldName="system";
this.arrTypeLoop=[];//["A","B","C","D", "F", "G"];
this.arrColumns=listtoarray("AdCode,AdditionalRooms,Age,AgeDescription,AgentIDX,AgentRemarks,AgentStatus,AlternateKey,AnnualRent,Appliances,ApplicationFeeAmount,APXBuildingSqFt,AsIsConditionYN,AssessedValuation,Assessment,AssessmentDesc,AssessmentFeeAmount,AssessmentFeePeriod,AssocApprovalRequiredYN,AssociationFee,AssociationFeeCovers,AssociationFeePeriod,AttachmentCount,AttachmentYN,AVMYN,BackUpOffersAcceptedYN,BathsPartial,BathsTotal,Bedroom1Length,Bedroom1Width,Bedroom2Length,Bedroom2Width,Bedroom3Length,Bedroom3Width,Bedroom4Length,Bedroom4Width,Bedrooms,BetweenUS1andRiver,BusinessName,BusinessOnlyYN,BuyerAgentCommAmount,BuyerName,CandRYN,CeilingHeight,City,ClearedYNP,CloseDate,ClosePrice,CoListingAgentID,CoListingAgentName,CoListingOfficeID,CoListingOfficeName,CommentaryYN,CommercialClass,CommunityOver55YN,ComplexUnits,ConcessionAmount,ConfidentialListingYN,ConformingYN,Construction,ConstructionMaterial,ContractDate,Cooling,CoSellAgentName,CoSellingAgentID,CoSellingOfficeID,CoSellingOfficeName,County,CurrentlyLeasedYN,DateAvailable,DateBackOnMarket,DateChange,DateContingency,DateDeleted,DateEstimatedCompletion,DateExpirationExtended,DateLeased,DateListingConfirmed,DateListingUnconfirmed,DateNewListing,DateOwnershipTransfer,DatePriceChange,DateWithdrawn,DaysOnMarket,DaysOnMarketContinuous,DiningRoomLength,DiningRoomWidth,Direction,Directions,Dishwashers,DisplayFlagAddress,DisplayFlagListing,DocumentsAndDisclosures,DoorFaces,Dryers,Electric,ElectricalExpense,ElectricityMeters,ElectricMeters,ElementarySchool,Employees,EquipmentAndAppliances,EstimateValueYN,ExclusiveAgency,ExpirationDate,ExteriorFeatures,ExteriorFinish,FamilyRoomLength,FamilyRoomWidth,FinancialPackageYN,Floor,FloorLocation,FloorNumber,Floors,FloorsPerUnit,FloridaRoomLength,FloridaRoomWidth,ForeignSellerYN,FreestandingYN,FurnishedYN,FutureLandUse,Garage,GarageAndCarStorage,GarageCarportSpaces,GasExpense,GasMeters,GenericTextField1,GenericTextField2,GrossIncome,GroundFloorBedroomYN,GroundsExpense,Heating,HeatingAndAc,HighSchool,HOAYN,HowSoldDesc,IDX,InLawSuite,InsideFeatures,InsuranceExpense,InteriorFeatures,Irrigation,Kickout,KitchenLength,KitchenWidth,LandDimensions,LandStyle,LandType,LaundryLength,LaundryWidth,LeaseAgent,LeaseBoard,LeaseFirm,LeaseInfo,LeaseOffice,LeaseOption,LeaseTerms,LegalDescription,LicAssistingSeller,LicensedREALTORYN,LimitedServiceYN,ListAgentAgentID,ListAgentKey,ListDate,ListingAgentID,ListingAgentName,ListingArea,ListingBoardID,ListingDetail,ListingFirmID,ListingID,ListingOfficeID,ListingStatus,ListingType,ListOfficeAffilliation,ListOfficeOfficeID,ListPrice,LivingArea,LivingRoomLength,LivingRoomWidth,LoadingDocks,LocationDescription,LockboxSerialNumber,LoginIDLastUpdateAgent,LoginIDOriginalListAgent,LoginIDOriginalSellAgent,LotSize,LotSizeArea,MaintenanceExpense,MaintFeeCovers,ManagementExpense,MasterBath,MaxRatedOccupancy,Microwaves,MiddleSchool,Miscellaneous,MiscellaneousN,MLSNumberOriginal,ModificationTimestamp,MonthlyRent,NearHighwayYN,NetIncome,NoDriveBeachYN,NonRepCommDesc,OfficeIDX,OfficeSqFt,OfficeStatus,OpenHouseAid,OpenHouseDt,OpenHouseRem,OpenHouseTm,OpenHouseYN,OperatingExpense,OriginalListingFirmName,OriginalListPrice,OriginalSellingFirmName,OtherAvailbleFeatures,OtherExpense,OtherRoom1Length,OtherRoom1Name,OtherRoom1Width,OtherRoom2Length,OtherRoom2Name,OtherRoom2Width,OverheadDoorNumber,OwnerName,ParcelNumber,Parking,ParkingSpaceYN,ParkingTotal,PendingAgentAgentID,PendingOfficeOfficeID,PetFeeAmount,PetsYNR,PhotoCode,PhotoCount,PhotoFrameNumber,PhotoModificationTimestamp,PhotoRollNumber,Pool,PoolDescription,PoolFeatures,PoolPresent,PorchLength,PorchWidth,Possession,PostalCode,PreviousListPrice,PriceChangeYN,PriceSqFt,ProjectPhase,PropertyFormat,PropertySubType,PropertyType,ProspectsExcludedYN,PublicRemarks,Ranges,RealtorRemarks,Refrigerators,RentalAmount,RentalCompensation,RentalPropertyType,RentalYN,RentIncludes,RentLow,RoadAccessYN,RoadFrontage,Roof,SaleAgentAgentID,SaleAgentCommission,SaleAgentName,SaleAgentOfficeAffiliation,SaleOfficeName,SaleOfficeOfficeID,SecurityAndMisc,SecurityDepositAmount,SellerConcessions,Sewer,ShowingInstructions,ShowInstructions,SpecialContingenciesApplyYN,SplitYN,SqFtLivingArea,SqFtTotal,StateOrProvince,StatusActualNumber,StatusChangeDate,StatusHotSheetNumber,StatusPreviousLetter,StatusPreviousNumber,StatusStatisticalLetter,StatusStatisticalNumber,Stories,StreetName,StreetNumber,Style,StyleFeatures,Subdivision,SurveyYN,TangibleTaxes,TaxAmount,TaxID,TaxYear,TenantExpenses,ThirdPartyApprovalYN,ThirdPartyYN,TitleInsuranceAvailable,TitleInsuranceAvailableYN,TotalLeases,TotalRooms,TotalUnits,TotSqftArea,TransBrokerCommAmount,TransBrokerCommDP,Type,TypeStreet,Unit1Baths,Unit1HalfBaths,Unit1MonthlyRent,Unit1Rooms,Unit1SqFt,Unit2Baths,Unit2HalfBaths,Unit2MonthlyRent,Unit2Rooms,Unit2SqFt,Unit3Baths,Unit3HalfBaths,Unit3MonthlyRent,Unit3Rooms,Unit3SqFt,Unit4Baths,Unit4HalfBaths,Unit4MonthlyRent,Unit4Rooms,Unit4SqFt,UnitNumber,UtilitiesOnsite,UtlitiesAndFuel,VariableRateCommYN,VirtualTourURL,VirtualTourYN,WasherDryerHookupsOnly,Washers,Water,WaterAndSewer,WaterFeatures,WaterMainSize,WaterMeters,WaterOther,WaterSewerExpense,WaterType,Windows,WindowsAndWindowTrtmnt,WindowTrtmnt,YearBuilt,Zoning",",");
this.arrFieldLookupFields=[];
this.mls_provider="rets28";
variables.resourceStruct=structnew();
variables.resourceStruct["property"]=structnew();
variables.resourceStruct["property"].resource="property";
variables.resourceStruct["property"].id="ListingId";

this.emptyStruct=structnew();
variables.resourceStruct["office"]=structnew();
variables.resourceStruct["office"].resource="office";
variables.resourceStruct["office"].id="OfficeUID";
variables.resourceStruct["agent"]=structnew();
variables.resourceStruct["agent"].resource="agent";
variables.resourceStruct["agent"].id="AgentUID";
 
variables.tableLookup=structnew();
/*
variables.tableLookup["BoatDock"]="BoatDock";
variables.tableLookup["CommercialProperty"]="CommercialProperty";
variables.tableLookup["CommercialRental"]="CommercialRental";
//variables.tableLookup["Keeplist"]="Keeplist";
variables.tableLookup["ResidentialIncomeProperty"]="ResidentialIncomeProperty";
variables.tableLookup["ResidentialProperty"]="ResidentialProperty";
variables.tableLookup["ResidentialRental"]="ResidentialRental";
variables.tableLookup["VacantLand"]="VacantLand"; */
</cfscript>



<cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
	<cfargument name="idlist" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var arrId=listtoarray(mid(replace(arguments.idlist," ","","ALL"),2,len(arguments.idlist)-2),"','");
	super.deleteListings(arguments.idlist);
	
	db.sql="DELETE FROM #db.table("rets28_property", request.zos.zcoreDatasource)#  
	WHERE rets28_ListingID IN (#db.trustedSQL(arguments.idlist)#)";
	db.execute("q"); 
	</cfscript>
</cffunction>

<cffunction name="initImport" localmode="modern" output="no" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	var qZ=0;
	super.initImport(arguments.resource, arguments.sharedStruct);
	
	arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
	</cfscript>
</cffunction>

<cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	var columnIndex=structnew(); 
	var a9=arraynew(1); 
	
	var db=request.zos.queryObject;
	if(structcount(this.emptyStruct) EQ 0){
		for(i=1;i LTE arraylen(this.arrColumns);i++){
			if(this.arrColumns[i] EQ "HiRes location"){
				continue;
			}
			this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
		}
	}
	
	for(i=1;i LTE arraylen(arguments.ss.arrData);i++){
		if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxSkipDataIndexStruct, i) EQ false){
			arrayappend(a9, arguments.ss.arrData[i]);	
		}
	}
	arguments.ss.arrData=a9;

	ts=duplicate(this.emptyStruct);
	if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
		application.zcore.functions.zdump(arguments.ss.arrData);
		application.zcore.functions.zabort();
	}  
	if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
	}
	photoLocation="";
	for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		if(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i] EQ "rets28_hireslocation"){
			photoLocation=arguments.ss.arrData[i];
			continue;
		}
		col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
		ts["rets28_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
		if(arguments.ss.arrData[i] EQ '0'){
			arguments.ss.arrData[i]="";	
		}
		if(structkeyexists(ts,col)){
			if(ts[col] NEQ ""){
				ts[col]=ts[col]&","&application.zcore.functions.zescape(arguments.ss.arrData[i]);
			}else{
				ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			}
		}else{ 
			ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
		}
		//ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=ts[col];
		columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
	} 
	ts["rets28_listprice"]=replace(ts["rets28_listprice"],",","","ALL");
	// need to clean this data - remove not in subdivision, 0 , etc.
	subdivision="";
	listing_subdivision="";
	if(application.zcore.functions.zso(ts, "rets28_subdivision") NEQ ""){
		subdivision=ts["rets28_subdivision"]; 
		listing_subdivision=this.getRetsValue("property", ts["rets28_subdivision"], "subdivision", subdivision);
	}else if(application.zcore.functions.zso(ts, "rets28_communityname") NEQ ""){
		subdivision=ts["rets28_communityname"];  
		listing_subdivision=this.getRetsValue("property", ts["rets28_communityname"], "communityname", subdivision);
	}
	
	if(listing_subdivision NEQ ""){
		if(findnocase(","&listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			listing_subdivision="";
		}else{
			listing_subdivision=application.zcore.functions.zFirstLetterCaps(listing_subdivision);
		}
	}  
	
	this.price=ts["rets28_listprice"];
	listing_price=ts["rets28_listprice"];
	cityName="";
	cid=0;
	ts['city']=this.getRetsValue("property", ts["rets28_propertysubtype"], "city", ts['rets28_city']);
	ts['StateOrProvince']=this.getRetsValue("property", ts["rets28_propertysubtype"], "StateOrProvince",ts['rets28_StateOrProvince']); 
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["StateOrProvince"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["StateOrProvince"]];
	}
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['rets28_postalcode'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['rets28_postalcode']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["StateOrProvince"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["StateOrProvince"]];
		}
	} 
	listing_county=this.listingLookupNewId("county",ts['rets28_county']);
	
	listing_parking="";//this.listingLookupNewId("listing_parking",ts['rets28_Parking']);
 
	// sub type:
	// PropertySubType 
	/* lookups for sub type:

	LookupMulti5A
	LookupMulti2P
	LookupMulti1G
	Lookup70
	Lookup67
	
	field names
	UseAndPossibleUse
	LandStyle
	LandType
	RentalPropertyType
	CommercialClass
	*/
	if(application.zcore.functions.zso(ts, "rets28_UseAndPossibleUse") NEQ ""){
		arrT=listtoarray(ts["rets28_UseAndPossibleUse"]);
	}else if(application.zcore.functions.zso(ts, "rets28_LandStyle") NEQ ""){
		arrT=listtoarray(ts["rets28_LandType"]);
	}else if(application.zcore.functions.zso(ts, "rets28_RentalPropertyType") NEQ ""){
		arrT=listtoarray(ts["rets28_RentalPropertyType"]);
	}else if(application.zcore.functions.zso(ts, "rets28_CommercialClass") NEQ ""){
		arrT=listtoarray(ts["rets28_CommercialClass"]); 
	}else{
		arrT=[];
	} 
	arrT3=[];
	for(i=1;i LTE arraylen(arrT);i++){
		tmp=this.listingLookupNewId("listing_sub_type",arrT[i]);
		if(tmp NEQ ""){
			arrayappend(arrT3,tmp);
		}
	}
	listing_sub_type_id=arraytolist(arrT3);  
	
	listing_type_id=this.listingLookupNewId("listing_type",ts['rets28_propertysubtype']);

	ad=ts['rets28_streetnumber'];
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	} 
	if(structkeyexists(ts, 'direction')){
		direction=this.getRetsValue("property", ts["rets28_propertysubtype"], "direction",ts['rets28_direction']);
		address&=application.zcore.functions.zfirstlettercaps(direction&" "&ts['rets28_streetname']);
	}else{
		address&=application.zcore.functions.zfirstlettercaps(ts['rets28_streetname']);
	}
	curLat="";
	curLong="";
	/*
	if(curLat EQ "" and trim(address) NEQ ""){
		rs5=this.baseGetLatLong(address,ts['StateOrProvince'],ts['postalcode'], arguments.ss.listing_id);
		curLat=rs5.latitude;
		curLong=rs5.longitude;
	}*/
	
	if(ts['rets28_unitnumber'] NEQ ''){
		address&=" Unit: "&ts["rets28_unitnumber"];
	} 
	
	/*s2=structnew();
	liststatus=this.getRetsValue("property", ts["rets28_propertysubtype"], 'ListingStatus', ts["rets28_ListingStatus"]);
	if(liststatus EQ "Active"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
	}else if(liststatus EQ "Canceled"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Cancelled"]]=true;
	}else if(liststatus EQ "Pending"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
	}else if(liststatus EQ "Expired"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
	}else if(liststatus EQ "Closed"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true; 
	}else if(liststatus EQ "Contingent"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["contingent"]]=true;
	}else if(liststatus EQ "Deleted"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["deleted"]]=true;
	}else if(liststatus EQ "Temp Off Market"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["temporarily withdrawn"]]=true;
	}
	listing_liststatus=structkeylist(s2,",");*/
	s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
	listing_liststatus=structkeylist(s2,",");
	
	/*arrT3=[];
	uns=structnew();
	tmp=ts['style'];
	// style and pool don't work.
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("listing_style",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_style=arraytolist(arrT3);*/
	listing_style="";
	uns={};
	tmp=application.zcore.functions.zso(ts,"rets28_WaterFeatures");
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("view",arrT[i]);
			//LookupMulti1B 

			//LookupMulti4B

			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_view=arraytolist(arrT3);

	tmp=application.zcore.functions.zso(ts, "rets28_WATERTYPE");
	/*
LookupMulti7C
LookupMulti4C
LookupMulti2C
LookupMulti1C
	*/
	uns={};
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("frontage",arrT[i]); 
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_frontage=arraytolist(arrT3);
	 

	tmp=application.zcore.functions.zso(ts, "rets28_PoolPresent");
	listing_pool="0";
	if(tmp EQ "Y"){ 
		listing_pool="1";
	} 
	tempTableLookup={};
	tempTableLookup["D"]="BoatDock"; // Boat Dock
	tempTableLookup["E"]="CommercialRental"; // For Rent-Commercial
	tempTableLookup["F"]="ResidentialProperty"; //  Residential Factory Built
	tempTableLookup["C"]="CommercialProperty"; //  Commercial Sale
	tempTableLookup["L"]="ResidentialProperty"; //  Condotels
	tempTableLookup["N"]="ResidentialRental"; //  For Rent-Residential-Resort
	tempTableLookup["O"]="ResidentialProperty"; //  Condo
	tempTableLookup["I"]="ResidentialIncomeProperty"; //  Residential Income
	tempTableLookup["U"]="ResidentialProperty"; //  Single Unit of 2, 3, 4 plex
	tempTableLookup["T"]="ResidentialProperty"; //  Townhomes
	tempTableLookup["V"]="VacantLand"; //  Vacant Land
	tempTableLookup["P"]="ResidentialProperty"; //  Co-Op
	tempTableLookup["R"]="ResidentialProperty"; //  Single Family Site Built

	propertyTable=tempTableLookup[ts['rets28_propertysubtype']];
 
	ts=this.convertRawDataToLookupValues(ts, propertyTable, '');
	//writedump(propertyTable);
	//writedump(ts);abort;
	//writedump(propertysubtype);abort;
  
 
	/*
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=ts['year built'];
	ts2.foreclosureField="";
	
	s=this.processRawStatus(ts2);
	*/
	s={};
	if(application.zcore.functions.zso(ts, 'rets28_yearbuilt') EQ year(now())){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
	}
	if(ts["rets28_propertysubtype"] EQ "E" or ts["rets28_propertysubtype"] EQ "N"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true; 
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 

	arrListType=listToArray(application.zcore.functions.zso(ts, 'rets28_ListingDetail'), ',');
	for(i in arrListType){
		if(i EQ "REO or Bank Owned"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}else if(i EQ "Under Construction"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["pre construction"]]=true;
		}else if(i EQ "Preforeclosure/Short Sale"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}else if(i EQ "Auction"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
		}else if(i EQ "Lease Option"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else if(i EQ ""){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}else if(i EQ ""){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
	} 
	listing_status=structkeylist(s,",");
	 
	dataCom=this.getRetsDataObject();
	listing_data_detailcache1=dataCom.getDetailCache1(ts);
	listing_data_detailcache2=dataCom.getDetailCache2(ts);
	listing_data_detailcache3=dataCom.getDetailCache3(ts); 
	rs=structnew();
	rs.listing_acreage="";
	if(application.zcore.functions.zso(ts, 'rets28_LotSizeArea') NEQ ""){
		rs.listing_acreage=ts["rets28_LotSizeArea"]; 
	}
	rs.listing_id=arguments.ss.listing_id;
	if(structkeyexists(ts, 'rets28_BathsTotal')){
		rs.listing_baths=ts["rets28_BathsTotal"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=application.zcore.functions.zso(ts, "rets28_BathsPartial");
	if(structkeyexists(ts, "rets28_bedrooms")){
		rs.listing_beds=ts["rets28_bedrooms"];
	}else{
		rs.listing_beds=0;
	}
	rs.listing_condoname="";
	rs.listing_city=cid;
	rs.listing_county=listing_county;
	rs.listing_frontage=","&listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["rets28_listprice"];
	rs.listing_status=","&listing_status&",";
	rs.listing_state=ts["rets28_StateOrProvince"];
	rs.listing_type_id=listing_type_id;
	rs.listing_sub_type_id=","&listing_sub_type_id&",";
	rs.listing_style=","&listing_style&",";
	rs.listing_view=","&listing_view&",";
	rs.listing_lot_square_feet="";

	rs.listing_square_feet=application.zcore.functions.zso(ts, "rets28_SqFtTotal");
 
	rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets28_LotSizeArea"); 


	rs.listing_subdivision=listing_subdivision;
	rs.listing_year_built=application.zcore.functions.zso(ts, "rets28_yearbuilt");
	if(rs.listing_year_built EQ ""){
		rs.listing_year_built=application.zcore.functions.zso(ts, "Year Built");
	}
	rs.listing_office=ts["rets28_ListOfficeOfficeID"];//OfficeUID"];
	rs.listing_agent=ts["rets28_ListAgentAgentID"];//AgentUID"]; 
	db.sql="select * from #db.table("rets28_office", request.zos.zcoreDatasource)# 
	where rets28_OfficeUID=#db.param(rs.listing_office)#";
	qOffice=db.execute("qOffice");  
	if(qOffice.recordcount NEQ 0){
		rs.listing_office_name=qOffice.rets28_name;
	}else{
		rs.listing_office_name='';
	}
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=listing_pool;
	rs.listing_photocount=ts["rets28_PhotoCount"];
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=arguments.ss.listing_mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=ts["rets28_postalcode"];
	rs.listing_condition="";
	rs.listing_parking=listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=listing_liststatus;
	rs.listing_data_remarks=ts["rets28_publicremarks"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["rets28_postalcode"]);
	rs.listing_data_detailcache1=listing_data_detailcache1;
	rs.listing_data_detailcache2=listing_data_detailcache2;
	rs.listing_data_detailcache3=listing_data_detailcache3; 
	//if(ts["WATERTYPE"] NEQ ""){ 	writedump(rs);abort;	}
	rs2={
		listingData:rs,
		columnIndex:columnIndex,
		arrData:arguments.ss.arrData
	};
	//writedump(photoLocation);	writedump(rs2);abort;
	return rs2;
	</cfscript>
</cffunction>
    
<cffunction name="getJoinSQL" localmode="modern" output="yes" returntype="any">
	<cfargument name="joinType" type="string" required="no" default="INNER">
	<cfscript>
	var db=request.zos.queryObject;
	</cfscript>
	<cfreturn "#arguments.joinType# JOIN #db.table("rets28_property", request.zos.zcoreDatasource)# rets28_property ON rets28_property.rets28_listingid = listing.listing_id">
</cffunction>
    <cffunction name="getPropertyListingIdSQL" localmode="modern" output="yes" returntype="any">
    	<cfreturn "rets28_property.rets28_listingid">
    </cffunction>
    <cffunction name="getListingIdField" localmode="modern" output="yes" returntype="any">
    	<cfreturn "rets28_ListingID">
    </cffunction>
    
<cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
	<cfargument name="query" type="query" required="yes">
	<cfargument name="row" type="numeric" required="no" default="#1#">
	<cfargument name="fulldetails" type="boolean" required="no" default="#false#">
	<cfscript>
	var q1=0;
	var t44444=0;
	var t99=0;
	var qOffice=0;
	var details=0;
	var i=0;
	var t1=0;
	var t3=0;
	var t2=0;
	var i10=0;
	var value=0;
	var n=0;
	var column=0;
	var arrV=0;
	var arrV2=0;
	var idx=this.baseGetDetails(arguments.query, arguments.row, arguments.fulldetails);
	t99=gettickcount();
	idx["features"]="";
	idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
	
	t44444=0;
	request.lastPhotoId=idx.listing_id;
	if(idx.listing_photocount EQ 0){
		idx["photo1"]='/z/a/listing/images/image-not-available.gif';
	}else{
		i=1;
		for(i=1;i LTE idx.listing_photocount;i++){
			fNameTemp1="28-"&idx.urlMlsPid&"-"&i&".jpeg";
			fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
			idx["photo"&i]=request.zos.retsPhotoPath&'28/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
		}
	} 
	idx["agentName"]="";
	idx["agentPhone"]="";
	idx["agentEmail"]=""; 
	idx["officeName"]=idx.listing_office_name;
	idx["officePhone"]="";
	idx["officeCity"]="";
	idx["officeAddress"]="";
	idx["officeZip"]="";
	idx["officeState"]="";
	idx["officeEmail"]="";
		
	idx["virtualtoururl"]=arguments.query["rets28_virtualtoururl"];
	idx["zipcode"]=arguments.query["listing_zip"][arguments.row];
	idx["maintfees"]=""; 
	if(isnumeric(arguments.query["rets#this.mls_id#_HOAMaintFees"][arguments.row])){
		idx["maintfees"]=arguments.query["rets#this.mls_id#_HOAMaintFees"][arguments.row]; 
	}else if(isnumeric(arguments.query["rets#this.mls_id#_MaintenanceExpense"][arguments.row])){
		idx["maintfees"]=arguments.query["rets#this.mls_id#_MaintenanceExpense"][arguments.row]; 
	}
	
	</cfscript>
	<cfsavecontent variable="details"><table class="ztablepropertyinfo">
	#idx.listing_data_detailcache1#
	#idx.listing_data_detailcache2#
	#idx.listing_data_detailcache3#
	</table></cfsavecontent>
	<cfscript>
	idx.details=details;
	return idx;
	</cfscript>
</cffunction>
    
<cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
	<cfargument name="mls_pid" type="string" required="yes">
	<cfargument name="num" type="numeric" required="no" default="#1#">
	<cfscript>
	request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
	fNameTemp1="28-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
	fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
	return request.zos.retsPhotoPath&'28/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
	
	</cfscript>
</cffunction>
	
<cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
	<cfscript>
	var i=0;
	var s=0;
	var arrSQL=[];
	var fd=0;
	var arrError=[];
	var i2=0;
	var tmp=0;
	var g=0;
	var db=request.zos.queryObject;
	var qD2=0;
	var arrC=0;
	var tempState=0;
	var failStr=0;
	var qD=0;
	var qZ=0;
	var cityCreated=false; 

	fd={};
	fd["D"]="Boat Dock"; // Boat Dock
	fd["E"]="Commercial Rental"; // For Rent-Commercial
	fd["F"]="Residential Property"; //  Residential Factory Built
	fd["C"]="Commercial Property"; //  Commercial Sale
	fd["L"]="Residential Property"; //  Condotels
	fd["N"]="Residential Rental"; //  For Rent-Residential-Resort
	fd["O"]="Residential Property"; //  Condo
	fd["I"]="Residential Income Property"; //  Residential Income
	fd["U"]="Residential Property"; //  Single Unit of 2, 3, 4 plex
	fd["T"]="Residential Property"; //  Townhomes
	fd["V"]="Vacant Land"; //  Vacant Land
	fd["P"]="Residential Property"; //  Co-Op
	fd["R"]="Residential Property"; //  Single Family Site Built 
	typeStruct=fd;
 
	for(i in fd){
		i2=i;
		if(i2 NEQ ""){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
	}

	// county
	fd=this.getRETSValues("property", "","county");

	for(i in fd){
		i2=i;
		arrayappend(arrSQL,"('#this.mls_provider#','county','#application.zcore.functions.zescape(fd[i])#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
	}

	arrSubType=["UseAndPossibleUse","LandStyle","RentalPropertyType","CommercialClass"];
	for(i2=1;i2 LTE arraylen(arrSubType);i2++){
		fd=this.getRETSValues("property", "", arrSubType[i2]);
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
	} 
 
	arrSubType=["WaterFeatures"];
	for(i2=1;i2 LTE arraylen(arrSubType);i2++){
		fd=this.getRETSValues("property", "", arrSubType[i2]); 
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
	}  

	arrSubType=["watertype"];
	for(i2=1;i2 LTE arraylen(arrSubType);i2++){
		fd=this.getRETSValues("property", "", arrSubType[i2]);
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
	}  
 

	fd=this.getRETSValues("property", "","city"); 
	arrC=arraynew(1);
	failStr="";
	for(i in fd){
		tempState="FL"; 
		if(fd[i] NEQ "SEE REMARKS" and fd[i] NEQ "NOT AVAILABLE" and fd[i] NEQ "NONE"){
			 db.sql="select * from #db.table("city_rename", request.zos.zcoreDatasource)# city_rename 
			WHERE city_name =#db.param(fd[i])# and 
			state_abbr=#db.param(tempState)# and 
			city_rename_deleted = #db.param(0)#";
			qD2=db.execute("qD2");
			if(qD2.recordcount NEQ 0){
				fd[i]=qD2.city_renamed;
			}
			 db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
			WHERE city_name =#db.param(fd[i])# and 
			state_abbr=#db.param(tempState)# and 
			city_deleted = #db.param(0)#";
			qD=db.execute("qD");
			if(qD.recordcount EQ 0){
				 db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
				 SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
				 state_abbr=#db.param(tempState)#,
				 country_code=#db.param('US')#, 
				 city_mls_id=#db.param(i)#,
				 city_deleted=#db.param(0)#,
				 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
				 result=db.insert("q"); 
				 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
				 SET city_id=#db.param(result.result)#, 
				 city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
				 state_abbr=#db.param(tempState)#,
				 country_code=#db.param('US')#, 
				 city_mls_id=#db.param(i)# ,
				 city_deleted=#db.param(0)#,
				 city_updated_datetime=#db.param(request.zos.mysqlnow)#";
				 db.execute("q");
				cityCreated=true; // need to run zipcode calculations
			}
		}
		
		arrayClear(request.zos.arrQueryLog);
	} 
	return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>