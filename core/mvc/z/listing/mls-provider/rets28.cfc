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
this.useRetsFieldName="system";
this.arrTypeLoop=["A","B","C","D", "F", "G"];
this.arrColumns=listtoarray("AdCode,AdditionalRooms,Age,AgeDescription,AgentIDX,AgentRemarks,AgentStatus,AlternateKey,AnnualRent,Appliances,ApplicationFeeAmount,APXBuildingSqFt,AsIsConditionYN,AssessedValuation,Assessment,AssessmentDesc,AssessmentFeeAmount,AssessmentFeePeriod,AssocApprovalRequiredYN,AssociationFee,AssociationFeeCovers,AssociationFeePeriod,AttachmentCount,AttachmentYN,AVMYN,BackUpOffersAcceptedYN,BathsPartial,BathsTotal,Bedroom1Length,Bedroom1Width,Bedroom2Length,Bedroom2Width,Bedroom3Length,Bedroom3Width,Bedroom4Length,Bedroom4Width,Bedrooms,BetweenUS1andRiver,BusinessName,BusinessOnlyYN,BuyerAgentCommAmount,BuyerName,CandRYN,CeilingHeight,City,ClearedYNP,CloseDate,ClosePrice,CoListingAgentID,CoListingAgentName,CoListingOfficeID,CoListingOfficeName,CommentaryYN,CommercialClass,CommunityOver55YN,ComplexUnits,ConcessionAmount,ConfidentialListingYN,ConformingYN,Construction,ConstructionMaterial,ContractDate,Cooling,CoSellAgentName,CoSellingAgentID,CoSellingOfficeID,CoSellingOfficeName,County,CurrentlyLeasedYN,DateAvailable,DateBackOnMarket,DateChange,DateContingency,DateDeleted,DateEstimatedCompletion,DateExpirationExtended,DateLeased,DateListingConfirmed,DateListingUnconfirmed,DateNewListing,DateOwnershipTransfer,DatePriceChange,DateWithdrawn,DaysOnMarket,DaysOnMarketContinuous,DiningRoomLength,DiningRoomWidth,Direction,Directions,Dishwashers,DisplayFlagAddress,DisplayFlagListing,DocumentsAndDisclosures,DoorFaces,Dryers,Electric,ElectricalExpense,ElectricityMeters,ElectricMeters,ElementarySchool,Employees,EquipmentAndAppliances,EstimateValueYN,ExclusiveAgency,ExpirationDate,ExteriorFeatures,ExteriorFinish,FamilyRoomLength,FamilyRoomWidth,FinancialPackageYN,Floor,FloorLocation,FloorNumber,Floors,FloorsPerUnit,FloridaRoomLength,FloridaRoomWidth,ForeignSellerYN,FreestandingYN,FurnishedYN,FutureLandUse,Garage,GarageAndCarStorage,GarageCarportSpaces,GasExpense,GasMeters,GenericTextField1,GenericTextField2,GrossIncome,GroundFloorBedroomYN,GroundsExpense,Heating,HeatingAndAc,HighSchool,HOAYN,HowSoldDesc,IDX,InLawSuite,InsideFeatures,InsuranceExpense,InteriorFeatures,Irrigation,Kickout,KitchenLength,KitchenWidth,LandDimensions,LandStyle,LandType,LaundryLength,LaundryWidth,LeaseAgent,LeaseBoard,LeaseFirm,LeaseInfo,LeaseOffice,LeaseOption,LeaseTerms,LegalDescription,LicAssistingSeller,LicensedREALTORYN,LimitedServiceYN,ListAgentAgentID,ListAgentKey,ListDate,ListingAgentID,ListingAgentName,ListingArea,ListingBoardID,ListingDetail,ListingFirmID,ListingID,ListingOfficeID,ListingStatus,ListingType,ListOfficeAffilliation,ListOfficeOfficeID,ListPrice,LivingArea,LivingRoomLength,LivingRoomWidth,LoadingDocks,LocationDescription,LockboxSerialNumber,LoginIDLastUpdateAgent,LoginIDOriginalListAgent,LoginIDOriginalSellAgent,LotSize,LotSizeArea,MaintenanceExpense,MaintFeeCovers,ManagementExpense,MasterBath,MaxRatedOccupancy,Microwaves,MiddleSchool,Miscellaneous,MiscellaneousN,MLSNumberOriginal,ModificationTimestamp,MonthlyRent,NearHighwayYN,NetIncome,NoDriveBeachYN,NonRepCommDesc,OfficeIDX,OfficeSqFt,OfficeStatus,OpenHouseAid,OpenHouseDt,OpenHouseRem,OpenHouseTm,OpenHouseYN,OperatingExpense,OriginalListingFirmName,OriginalListPrice,OriginalSellingFirmName,OtherAvailbleFeatures,OtherExpense,OtherRoom1Length,OtherRoom1Name,OtherRoom1Width,OtherRoom2Length,OtherRoom2Name,OtherRoom2Width,OverheadDoorNumber,OwnerName,ParcelNumber,Parking,ParkingSpaceYN,ParkingTotal,PendingAgentAgentID,PendingOfficeOfficeID,PetFeeAmount,PetsYNR,PhotoCode,PhotoCount,PhotoFrameNumber,PhotoModificationTimestamp,PhotoRollNumber,Pool,PoolDescription,PoolFeatures,PoolPresent,PorchLength,PorchWidth,Possession,PostalCode,PreviousListPrice,PriceChangeYN,PriceSqFt,ProjectPhase,PropertyFormat,PropertySubType,PropertyType,ProspectsExcludedYN,PublicRemarks,Ranges,RealtorRemarks,Refrigerators,RentalAmount,RentalCompensation,RentalPropertyType,RentalYN,RentIncludes,RentLow,RoadAccessYN,RoadFrontage,Roof,SaleAgentAgentID,SaleAgentCommission,SaleAgentName,SaleAgentOfficeAffiliation,SaleOfficeName,SaleOfficeOfficeID,SecurityAndMisc,SecurityDepositAmount,SellerConcessions,Sewer,ShowingInstructions,ShowInstructions,SpecialContingenciesApplyYN,SplitYN,SqFtLivingArea,SqFtTotal,StateOrProvince,StatusActualNumber,StatusChangeDate,StatusHotSheetNumber,StatusPreviousLetter,StatusPreviousNumber,StatusStatisticalLetter,StatusStatisticalNumber,Stories,StreetName,StreetNumber,Style,StyleFeatures,Subdivision,SurveyYN,TangibleTaxes,TaxAmount,TaxID,TaxYear,TenantExpenses,ThirdPartyApprovalYN,ThirdPartyYN,TitleInsuranceAvailable,TitleInsuranceAvailableYN,TotalLeases,TotalRooms,TotalUnits,TotSqftArea,TransBrokerCommAmount,TransBrokerCommDP,Type,TypeStreet,Unit1Baths,Unit1HalfBaths,Unit1MonthlyRent,Unit1Rooms,Unit1SqFt,Unit2Baths,Unit2HalfBaths,Unit2MonthlyRent,Unit2Rooms,Unit2SqFt,Unit3Baths,Unit3HalfBaths,Unit3MonthlyRent,Unit3Rooms,Unit3SqFt,Unit4Baths,Unit4HalfBaths,Unit4MonthlyRent,Unit4Rooms,Unit4SqFt,UnitNumber,UtilitiesOnsite,UtlitiesAndFuel,VariableRateCommYN,VirtualTourURL,VirtualTourYN,WasherDryerHookupsOnly,Washers,Water,WaterAndSewer,WaterFeatures,WaterMainSize,WaterMeters,WaterOther,WaterSewerExpense,WaterType,Windows,WindowsAndWindowTrtmnt,WindowTrtmnt,YearBuilt,Zoning",",");
this.arrFieldLookupFields=[];
this.mls_provider="rets28";
variables.resourceStruct=structnew();
variables.resourceStruct["property"]=structnew();
variables.resourceStruct["property"].resource="property";
variables.resourceStruct["property"].id="ListingId";
// list_1 is the sysid
this.emptyStruct=structnew();
variables.resourceStruct["office"]=structnew();
variables.resourceStruct["office"].resource="office";
variables.resourceStruct["office"].id="OfficeUID";
variables.resourceStruct["agent"]=structnew();
variables.resourceStruct["agent"].resource="activeagent";
variables.resourceStruct["agent"].id="AgentUID";
/*
*/
variables.tableLookup=structnew();
variables.tableLookup["A"]="A"; // residential
variables.tableLookup["B"]="B"; // condo
variables.tableLookup["C"]="C"; // lots and land
variables.tableLookup["D"]="D"; // rentals
variables.tableLookup["E"]="E";	// investment/multifamily
variables.tableLookup["F"]="F"; // Commercial for Sale
variables.tableLookup["G"]="G"; // Commercial For Lease

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
	writedump(ts);
	writedump(a9);abort;
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
	ts["rets28_list_22"]=replace(ts["rets28_list_22"],",","","ALL");
	// need to clean this data - remove not in subdivision, 0 , etc.
	subdivision="";
	listing_subdivision="";
	if(application.zcore.functions.zso(ts, "Legal Name of Subdiv") NEQ ""){
		subdivision=ts["Legal Name of Subdiv"]; 
		listing_subdivision=this.getRetsValue("property", ts["rets28_list_8"], "LIST_83", subdivision);
	}else if(application.zcore.functions.zso(ts, "Common Name of Sub") NEQ ""){
		subdivision=ts["Common Name of Sub"];  
		listing_subdivision=this.getRetsValue("property", ts["rets28_list_8"], "LIST_77", subdivision);
	}
	
	if(listing_subdivision NEQ ""){
		if(findnocase(","&listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			listing_subdivision="";
		}else{
			listing_subdivision=application.zcore.functions.zFirstLetterCaps(listing_subdivision);
		}
	}  
	
	this.price=ts["rets28_list_22"];
	listing_price=ts["rets28_list_22"];
	cityName="";
	cid=0;
	ts['city']=this.getRetsValue("property", ts["rets28_list_8"], "LIST_39", ts['city']);
	ts['state/Province']=this.getRetsValue("property", ts["rets28_list_8"], "LIST_40",ts['state/Province']);
	if(ts['state/Province'] EQ "Florida"){
		ts["state/Province"]="FL";
	}else if(ts['state/Province'] EQ "Georgia"){
		ts["state/Province"]="GA";
	}
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["State/Province"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["State/Province"]];
	}
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['postal code'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['postal code']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["State/Province"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["State/Province"]];
		}
	} 
	listing_county=this.listingLookupNewId("county",ts['county']);
	
	listing_parking=this.listingLookupNewId("parking",ts['Parking Facilities']);
 
	if(application.zcore.functions.zso(ts, "rets28_GF20030609154828999409000000") NEQ ""){
		arrT=listtoarray(ts["rets28_GF20030609154828999409000000"]);
	}else if(application.zcore.functions.zso(ts, "rets28_GF20030607043107874564000000") NEQ ""){
		arrT=listtoarray(ts["rets28_GF20030607043107874564000000"]);
	}else if(application.zcore.functions.zso(ts, "rets28_GF20030326015036881057000000") NEQ ""){
		arrT=listtoarray(ts["rets28_GF20030326015036881057000000"]);
	}else if(application.zcore.functions.zso(ts, "rets28_GF20030319224856584184000000") NEQ ""){
		arrT=listtoarray(ts["rets28_GF20030319224856584184000000"]);
	}else if(application.zcore.functions.zso(ts, "rets28_GF20030226223922292850000000") NEQ ""){
		arrT=listtoarray(ts["rets28_GF20030226223922292850000000"]);
	}else if(application.zcore.functions.zso(ts, "rets28_LIST_97") NEQ ""){
		arrT=listtoarray(ts["rets28_LIST_97"]);
	}else if(application.zcore.functions.zso(ts, "rets28_GF20030307143703901758000000") NEQ ""){
		arrT=listtoarray(ts["rets28_GF20030307143703901758000000"]);
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
	
	listing_type_id=this.listingLookupNewId("listing_type",ts['rets28_list_8']);

	ad=ts['street number'];
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	}
	ts['street sfx']=this.getRetsValue("property", ts["rets28_list_8"], "LIST_37",ts['street sfx']);
	if(structkeyexists(ts, 'street direction sfx')){
		ts['street dir']=this.getRetsValue("property", ts["rets28_list_8"], "LIST_36",ts['street direction sfx']);
		address&=application.zcore.functions.zfirstlettercaps(ts['street name']&ts['street dir']&" "&" "&ts['street sfx']);
	}else{
		ts['street dir']=this.getRetsValue("property", ts["rets28_list_8"], "LIST_33",ts['street direction pfx']);
		address&=application.zcore.functions.zfirstlettercaps(ts['street dir']&" "&ts['street name']&" "&ts['street sfx']);
	}
	curLat=ts["rets28_list_46"];
	curLong=ts["rets28_list_47"];
	if(curLat EQ "" and trim(address) NEQ ""){
		rs5=this.baseGetLatLong(address,ts['State/Province'],ts['postal code'], arguments.ss.listing_id);
		curLat=rs5.latitude;
		curLong=rs5.longitude;
	}
	
	if(ts['Unit ##'] NEQ ''){
		address&=" Unit: "&ts["Unit ##"];
	} 
	
	s2=structnew();
	liststatus=this.getRetsValue("property", ts["rets28_list_8"], 'list_15', ts["status"]);
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
	listing_liststatus=structkeylist(s2,",");
	
	arrT3=[];
	uns=structnew();
	tmp=ts['style'];
	// style and pool don't work.
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("style",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_style=arraytolist(arrT3);
	
	tmp=ts["Lot Description/View"];
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("view",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_view=arraytolist(arrT3);

	tmp=ts["Waterfront Descript"];
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
	 

	tmp=application.zcore.functions.zso(ts, "pool");
	if(tmp EQ ""){
		tmp=ts["Pool/Hot Tub"];
	}
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("pool",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_pool=arraytolist(arrT3);
	if(listing_pool CONTAINS "no pool"){
		listing_pool="";
	}
  
 
	ts=this.convertRawDataToLookupValues(ts, ts["rets28_list_8"], ts["rets28_list_8"]);
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=ts['year built'];
	ts2.foreclosureField="";
	
	s=this.processRawStatus(ts2);
	
	if(ts["rets28_list_8"] EQ "D" or ts["rets28_list_8"] EQ "G"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true; 
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 

	if(structkeyexists(ts, 'OwnerApprPublicMktg')){  
		arrT=listToArray(ts["OwnerApprPublicMktg"]);
		currentField="";
		if(application.zcore.functions.zso(ts, "rets28_GF20091007175439371259000000") NEQ ""){
			currentField="GF20091007175439371259000000";
		}else if(application.zcore.functions.zso(ts, "rets28_GF20091007175403725545000000") NEQ ""){
			currentField="GF20091007175403725545000000";
		}else if(application.zcore.functions.zso(ts, "rets28_GF20091007175439371259000000") NEQ ""){
			currentField="GF20091007175326003449000000";
		}else if(application.zcore.functions.zso(ts, "rets28_GF20091007175249510919000000") NEQ ""){
			currentField="GF20091007175249510919000000";
		}else if(application.zcore.functions.zso(ts, "rets28_GF20091007174340223056000000") NEQ ""){
			currentField="GF20091007174340223056000000";
		}
		arrT2=[];
		for(i=1;i<=arraylen(arrT);i++){
			t=this.getRetsValue("property", ts["rets28_list_8"], currentField, arrT[i]);
			if(t NEQ ""){
				arrayAppend(arrT2, t);
			}
		}
		saleType=arrayToList(arrT2, ",");
		if(saleType CONTAINS "Pre-Foreclosure"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		if(saleType CONTAINS "Foreclosed"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(saleType CONTAINS "short sale"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}    
	}
	listing_status=structkeylist(s,",");
	 
	dataCom=this.getRetsDataObject();
	listing_data_detailcache1=dataCom.getDetailCache1(ts);
	listing_data_detailcache2=dataCom.getDetailCache2(ts);
	listing_data_detailcache3=dataCom.getDetailCache3(ts);

	rs=structnew();
	rs.listing_acreage="";
	if(application.zcore.functions.zso(ts, 'rets28_list_57') NEQ ""){
		rs.listing_acreage=ts["rets28_list_57"]; 
	}
	rs.listing_id=arguments.ss.listing_id;
	if(structkeyexists(ts, 'Full Baths')){
		rs.listing_baths=ts["Full Baths"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=application.zcore.functions.zso(ts, "Half Baths");
	if(structkeyexists(ts, "Total Bedrooms")){
		rs.listing_beds=ts["Total Bedrooms"];
	}else if(structkeyexists(ts, "Bedrooms")){
		rs.listing_beds=ts["Bedrooms"];
	}else{
		rs.listing_beds=0;
	}
	rs.listing_condoname="";
	rs.listing_city=cid;
	rs.listing_county=listing_county;
	rs.listing_frontage=","&listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["rets28_list_22"];
	rs.listing_status=","&listing_status&",";
	rs.listing_state=ts["State/Province"];
	rs.listing_type_id=listing_type_id;
	rs.listing_sub_type_id=","&listing_sub_type_id&",";
	rs.listing_style=","&listing_style&",";
	rs.listing_view=","&listing_view&",";
	rs.listing_lot_square_feet="";

	rs.listing_square_feet=application.zcore.functions.zso(ts, "rets28_list_48");

	if(ts["rets28_list_8"] EQ "E"){
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets28_list_49");
	}else if(ts["rets28_list_8"] EQ "F" or ts["rets28_list_8"] EQ "G"){
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets28_list_52");
	}


	rs.listing_subdivision=listing_subdivision;
	rs.listing_year_built=ts["year built"];
	rs.listing_office=ts["rets28_OfficeUID"];
	rs.listing_agent=ts["rets28_AgentUID"]; 
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
	rs.listing_photocount=ts["Picture Count"];
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=arguments.ss.listing_mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=ts["postal code"];
	rs.listing_condition="";
	rs.listing_parking=listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=listing_liststatus;
	rs.listing_data_remarks=ts["Public Remarks"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["postal code"]);
	rs.listing_data_detailcache1=listing_data_detailcache1;
	rs.listing_data_detailcache2=listing_data_detailcache2;
	rs.listing_data_detailcache3=listing_data_detailcache3; 
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
	<cfreturn "#arguments.joinType# JOIN #db.table("rets28_property", request.zos.zcoreDatasource)# rets28_property ON rets28_property.rets28_ListingID = listing.listing_id">
</cffunction>
    <cffunction name="getPropertyListingIdSQL" localmode="modern" output="yes" returntype="any">
    	<cfreturn "rets28_property.rets28_ListingID">
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
	idx["officeName"]=idx.listing_OriginalListingFirmName;
	idx["officePhone"]="";
	idx["officeCity"]="";
	idx["officeAddress"]="";
	idx["officeZip"]="";
	idx["officeState"]="";
	idx["officeEmail"]="";
		
	idx["virtualtoururl"]=arguments.query["rets28_unbrandedidxvirtualtour"];
	idx["zipcode"]=arguments.query["listing_zip"][arguments.row];
	idx["maintfees"]="";
	if(isnumeric(arguments.query["rets#this.mls_id#_LIST_26"][arguments.row])){
		idx["maintfees"]=arguments.query["rets#this.mls_id#_LIST_26"][arguments.row]; 
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
	fd=structnew(); 
	fd["CommercialProperty"]="Commercial";
	fd["CommercialRental"]="Commercial Rental";
	fd["ResidentialIncomeProperty"]="Residential Income";
	fd["ResidentialProperty"]="Residential";
	fd["ResidentialRental"]="Residential Rental";
	fd["VacantLand"]="Vacant Land"; 


	writedump('not implemented');abort;
	for(i in fd){
		i2=i;
		if(i2 NEQ ""){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
	}


	for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"list_41");
		for(i in fd){
			i2=i;
			arrayappend(arrSQL,"('#this.mls_provider#','county','#application.zcore.functions.zescape(fd[i])#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 

		 
		// sub_type
		arrSubType=["GF20030609154828999409000000","GF20030607043107874564000000","GF20030326015036881057000000","GF20030319224856584184000000","GF20030226223922292850000000","LIST_97","GF20030307143703901758000000"];
		for(i2=1;i2 LTE arraylen(arrSubType);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrSubType[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			} 
		} 
 
		arrFrontage=["GF20020923141755529165000000","GF20030307150709625693000000","GF20030310024252785856000000","GF20030326015018607749000000"];
		// frontage
		for(i2=1;i2 LTE arraylen(arrFrontage);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrFrontage[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			} 
		} 
		arrView=["GF20030319224838160515000000","GF20030313222248944660000000","GF20030311034137194777000000"];
		// view
		for(i2=1;i2 LTE arraylen(arrView);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrView[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','view','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			} 
		} 
		 
		arrStyle=["GF20030226223932480526000000","GF20030326015035381127000000"];
		// style 
		for(i2=1;i2 LTE arraylen(arrStyle);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrStyle[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','style','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			}  
		}

		arrParking=["GF20030226223936808977000000","GF20030307150710451244000000", "GF20030326015019402171000000", "GF20030319224835368134000000", "GF20030313222246117493000000", "GF20030311034134339042000000"];
		// parking 
		for(i2=1;i2 LTE arraylen(arrParking);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrParking[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			}  
		}


		fd=this.getRETSValues("property", this.arrTypeLoop[g],"list_39"); 
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
	}
	return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>