<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<!--- 
download is throttled to 5000 records during the day
unlimited between 7pm and 5am hawaii time
1am to 11am eastern time
 --->
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=20;
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("ActiveContinueToShowDate	ActiveOpenHouseCount	AdditionalParcelsYN	AdvertiseDate	AssociationCommunityName	AssociationFee	AssociationFee2	AssociationFeeTotal	AssociationPhone	AuctionDate	BackOnMarketDate	BathsFull	BathsHalf	BathsTotal	BedsTotal	BuildingName	BuyerFinancing	City	CloseDate	ClosePrice	CoListAgentDirectWorkPhone	CoListAgentEmail	CoListAgentFullName	CoListAgentMLSID	CoListAgent_MUI	CoListOfficeMLSID	CoListOffice_MUI	CoListOfficeName	CoListOfficePhone	CoSellingAgentDirectWorkPhone	CoSellingAgentEmail	CoSellingAgentFullName	CoSellingAgentMLSID	CoSellingAgent_MUI	CoSellingOfficeMLSID	CoSellingOffice_MUI	CoSellingOfficeName	CoSellingOfficePhone	CompensationMethod	CompensationSubjectTo	Concessions	ConditionalDate	CondoPropertyRegimeYN	ConstructionMaterials	CountyOrParish	CropsIncludedYN	CurrentPrice	Disclosures	DivisionName	Documents	DOM	DualVariableCompensationYN	Easements	ElementarySchool	FeeOptions	FeePurchase	FloodZoneCode	Flooring	ForecloseureCivilCaseNumber	ForeclosureYN	ForeignCountryOrState	HighSchool	Improvements	LandRecorded	LandTenure	LandUse	LeaseExpirationDate	LeaseExpirationYear	LeaseFeeMonth	LeasePrice	LeaseRenegotiationDate	LessorName	ListAgentDirectWorkPhone	ListAgentEmail	ListAgentFullName	ListAgentMLSID	ListAgent_MUI	ListOfficeMLSID	ListOffice_MUI	ListOfficeName	ListOfficePhone	ListPrice	ListingAgreement	ListingContractDate	ListingFinancing	ListingService	Location	LockBoxYN	LotFeatures	LotSizeArea	LotSizeDimensions	MaintenanceExpense	ManagementCompanyName	ManagementCompanyPhone	MatrixModifiedDT	Matrix_Unique_ID	MiddleOrJuniorSchool	MLS	MLSAreaMajor	MLSNumber	Neighbourhood	OffMarketDate	OpenHouseCount	OpenHouseUpcoming	OriginalEntryTimestamp	OriginalListPrice	ParcelNumber	ParkingFeatures	PendingDate	PermitAddressInternetYN	PermitInternetYN	PhotoCount	PhotoModificationTimestamp	PossibleUse	PostalCode	PostalCodePlus4	PriceChangeTimestamp	PrivateRemarks	PropertyCondition	PropertyFrontage	PropertySubType	PropertyType	PublicRemarks	PublicReportNumber	RentStepUpMonthFirst	RentStepUpMonthSecond	RentYearFirst	RentYearSecond	Restrictions	RoadFrontage	RoomCount	SecurityFeatures	SellingAgentDirectWorkPhone	SellingAgentEmail	SellingAgentFullName	SellingAgentMLSID	SellingAgent_MUI	SellingAgentRemarks	SellingOfficeMLSID	SellingOffice_MUI	SellingOfficeName	SellingOfficePhone	SetBacks	Sewer	SpecialListingConditions	SQFTBuilding	SQFTGarageCarport	SQFTLanaiOpen	SQFTRoofedLiving	SQFTRoofedOther	SqftTotal	StateOrProvince	Status	StatusChangeTimestamp	StatusContractualSearchDate	StreetDirPrefix	StreetDirSuffix	StreetName	StreetNumber	StreetSuffix	StreetViewParam	StructuresPresentYN	SubAgencyCompensation	SupplementCount	SupplementModificationTimestamp	Table	TaxAmount	TaxAssessedValue	TaxAssessedValueImprovements	TaxAssessedValueLand	TaxLot	TaxPaidBySellerYN	TaxYear	TempOffMarketDate	TemporarilyWithdrawnDate	TMKArea	TMKCondoPropertyRegimeNumber	TMKDivision	TMKParcel	TMKSection	TMKZone	TMKPLAT	Topography	UnitCount	UnitNumber	Utilities	UtilitiesMeters	View	VirtualTourURLUnbranded	WithdrawnDate	YearBuilt	Zoning	Amenities	BusinessName	BusinessType	BusinessTypeDescription	CommercialSpaceYN	Cooling	DaysOpenNumberOf	Employees	ExpensesInformationSource	FloorNumber	FranchiseFee	GrossIncome	HoursOpen	Inclusions	IncomeInformationSource	LandlordName	LandlordPhone	LastChangeTimestamp	LeaseType	Loading	NetOperatingIncome	NumberOfUnitsTotal	OwnershipType	ParkingTotal	Possession	Roof	ShowingInstructions	SQFTInterior	SQFTOther	StandardIndustrialClassification	Stories	StoriesType	TenantsResponsibilitiesIncludes	TotalActualRent	TotalAnnualOperatingExpenses	YearEstablished	BuildingType	CommercialSpacesNumberOf	ElevatorsNumberOf	ExpensesInclude	Furnished	IsDeleted	LaundryFacilities	OtherIncome	OtherParkingFeatures	ProviderModificationTimestamp	RecreationFacilities	StudioUnitsNumberOf	TotalIncome	UnitOneBedNumberOf	UnitThreeBedNumberOf	UnitTwoBedNumberOf	YearRemodeled	ArchitecturalStyle	AssociationFee2Includes	AssociationFeeIncludes	BuilderName	CondoParkingUnit	ConversionYear	DepositAmount	ElevatorsFreightNumberOf	Exclusions	FractionalOwnershipYN	LessorName2	Model	ModelSiteContactName	ModelSiteContactPhone	ModelSiteOpenHours	NewDevelopmentConstructionYN	OccupantType	OwnerOccupancyPercentage	ParkingAdditional	PetsAllowed	PetsAllowedYN	PoolFeatures	ProjectPublicReportNumber	Remodelled	RentalType	RentalUnitAvailableDate	ResidentManagerYN	Section8YN	SQFTLanaiCovered	TaxExcemptionOwnerOccupancy	UnitFeatures",chr(9));
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/20/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/20/";
	}
	this.arrTypeLoop=listtoarray("COMM,MULT,LAND,RESI");
	this.mls_provider="rets20";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="mlsnumber";
	resourceStruct["office"]=structnew();
	resourceStruct["office"].resource="office";
	resourceStruct["office"].id="mlsid";
	resourceStruct["agent"]=structnew();
	resourceStruct["agent"].resource="agent";
	resourceStruct["agent"].id="mlsid";
	resourceStruct["media"]=structnew();
	resourceStruct["media"].id="matrix_unique_id";
	resourceStruct["media"].resource="media";
	resourceStruct["media"].extraPrimaryKey="KEY `ExtraIndex1` (`rets20_table_id`,`rets20_table_mui`)";/**/
	resourceStruct["openhouse"]=structnew();
	resourceStruct["openhouse"].id="matrix_unique_id";
	resourceStruct["openhouse"].resource="openhouse";
	/*
	ListAgentMLSID - foreign key to agent
	ListOfficeMLSID "" office
	rets20_listingmui 	mlsnumber
	*/
	this.sysidfield="rets20_matrix_unique_id";
	this.sysidfield2="rets20_propertytype";
	variables.cityRename=structnew();
	variables.cityRename["Captain"]="Captain Cook";
	variables.cityRename["Ewa"]="Ewa Beach";
	variables.cityRename["Kailu-kona"]="Kailua Kona";
	variables.cityRename["Kailua-kona"]="Kailua Kona";
	variables.cityRename["Kialua-kona"]="Kailua Kona";
	variables.cityRename["Mililani Town"]="Mililani";
	</cfscript>


    <cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
    	<cfargument name="idlist" type="string" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var arrId=listtoarray(mid(replace(arguments.idlist," ","","ALL"),2,len(arguments.idlist)-2),"','");
		super.deleteListings(arguments.idlist);
		db.sql="DELETE FROM #db.table("rets20_property", request.zos.zcoreDatasource)#  
		WHERE rets20_mlsnumber LIKE #db.param('20-%')# and rets20_mlsnumber IN (#db.trustedSQL(arguments.idlist)#)";
		db.execute("q"); 
		</cfscript>
    </cffunction>
    
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var rs5=0;
		var r222=0;
		var values="";
		var newlist="";
		var i=0;
		var columnIndex=structnew();
		var cityname=0;
		var cid=0;
		var cityName=0;
		var address=0;
		var cid=0;
		var curLat=0;
		var curLong=0;
		var s=0;
		var cityStruct222=0;
		var arrt3=0;
		var uns=0;
		var tmp=0;
		var arrt=0;
		var arrt2=0;
		var ts2=0;
		var datacom=0;
		var values=0;
		var condition=0;
		var tenure=0;
		var region=0;
		var parking=0;
		var livingsqfoot=0;
		var liststatus=0;
		var arrs=0;
		var s2=0;
		var ad=0;
		var rs=0;
		var ts=structnew();
		var idx=0;
		var column=0;
		var fieldName=0;
		var i10=0;
		var value=0;
		var c=0;
		
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS20: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}
		if(structkeyexists(ts, "rets20_neighbourhood")){
			if(findnocase(","&ts["rets20_neighbourhood"]&",", ",,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["rets20_neighbourhood"]="";
			}else if(ts["rets20_neighbourhood"] NEQ ""){
				ts["rets20_neighbourhood"]=application.zcore.functions.zFirstLetterCaps(ts["rets20_neighbourhood"]);
			}
		}
		if(structkeyexists(ts,'rets20_originalentrytimestamp')){
			arguments.ss.listing_track_datetime=dateformat(ts.rets20_originalentrytimestamp,"yyyy-mm-dd")&" "&timeformat(ts.rets20_originalentrytimestamp, "HH:mm:ss");
		}
		arguments.ss.listing_track_updated_datetime=dateformat(ts.rets20_matrixmodifieddt,"yyyy-mm-dd")&" "&timeformat(ts.rets20_matrixmodifieddt, "HH:mm:ss");
		arguments.ss.listing_track_price=ts["rets20_OriginalListPrice"];
		if(arguments.ss.listing_track_price EQ "0"){
			arguments.ss.listing_track_price=ts.rets20_LISTPRICE;
		}
		arguments.ss.listing_track_price_change=ts.rets20_LISTPRICE;
		
		this.price=ts["rets20_LISTPRICE"];
		cityName="";
		cid=0;
		if(ts["rets20_city"] NEQ ""){
			if(structkeyexists(variables.cityRename, ts["rets20_city"])){
				ts["rets20_city"]=variables.cityRename[ts["rets20_city"]];
			}
			cityName=ts["rets20_city"]&"|"&ts["rets20_StateOrProvince"];
			if(structkeyexists(request.zos.listing.cityStruct, cityName)){
				cid=request.zos.listing.cityStruct[cityName];
			}
			cityName=ts["rets20_city"];
		}
		
		if(structkeyexists(ts,'rets20_PROPERTYCONDITION')){
			condition=this.listingLookupNewId("condition",ts.rets20_PROPERTYCONDITION);
		}else{
			condition="";
		}
		if(structkeyexists(ts,'rets20_ParkingFeatures')){
			parking=this.listingLookupNewId("parking",ts.rets20_ParkingFeatures);
		}else{
			parking="";
		}
		region=this.listingLookupNewId("region",ts.rets20_MLSAreaMajor);
		if(structkeyexists(ts,'rets20_landtenure')){
			tenure=this.listingLookupNewId("tenure",ts.rets20_landtenure);
		}else{
			tenure="";
		}
		
		local.listing_type_id=this.listingLookupNewId("listing_type",ts.rets20_PROPERTYTYPE);
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",application.zcore.functions.zso(ts, 'rets20_PROPERTYSUBTYPE'));
		if(application.zcore.functions.zso(ts, 'rets20_permitaddressinternetyn') EQ "1"){
			ad=application.zcore.functions.zso(ts, 'rets20_streetnumber');
			if(ad NEQ 0){
				address="#ad# ";
			}else{
				address="";	
			}	
			
			address&=application.zcore.functions.zfirstlettercaps(trim(replace(ts.rets20_StreetDirPrefix&" "&ts.rets20_StreetName&" "&ts.rets20_StreetDirSuffix&" "&ts.rets20_StreetSuffix,"  "," ","all")));
			
			curLat="";
			curLong="";
				if(trim(address) NEQ ""){// and cityName NEQ ""){
					rs5=this.baseGetLatLong(address,ts.rets20_stateorprovince,ts.rets20_postalcode, arguments.ss.listing_id);
					curLat=rs5.latitude;
					curLong=rs5.longitude;
				}
			if(application.zcore.functions.zso(ts, 'rets20_unitnumber') NEQ ''){
				address&=" Unit: "&ts["rets20_unitnumber"];	
			}
		}else{
			address="";
		}
		arrS=listtoarray(application.zcore.functions.zso(ts, 'rets20_SpecialListingConditions'),",");
		s=structnew();
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(find(","&c&",",",SHOSAL,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
				break;
			}
			if(find(","&c&",",",FORECL,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
				break;
			}
			
		}
		
		arrS=listtoarray(application.zcore.functions.zso(ts, 'rets20_STATUS'),",");
		
		
		liststatus=ts.rets20_STATUS;
		s2=structnew();
		if(liststatus EQ "a"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
		}
		if(liststatus EQ "w"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
		}
		if(liststatus EQ "C"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active continue to show"]]=true;
		}
		if(liststatus EQ "t"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["temporarily withdrawn"]]=true;
		}
		if(liststatus EQ "p"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
		}
		if(liststatus EQ "x"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
		}
		if(liststatus EQ "s"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true;
		}
		if(liststatus EQ "r"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["leased"]]=true;
		}
		if(liststatus EQ "i"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["incoming"]]=true;
		}
		
		if(application.zcore.functions.zso(ts, 'rets20_NewDevelopmentConstructionYN') EQ "1"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(application.zcore.functions.zso(ts, 'rets20_proptype') EQ "rnt"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		local.listing_status=structkeylist(s,",");
		local.listing_liststatus=structkeylist(s2,",");
		local.listing_style=this.listingLookupNewId("style",application.zcore.functions.zso(ts, 'rets20_ArchitecturalStyle'));
		
		// view & frontage
		arrT2=[];
		arrT3=[];
		
		tmp=application.zcore.functions.zso(ts, 'rets20_PROPERTYFRONTAGE');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage",arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_frontage=arraytolist(arrT3);
		tmp=application.zcore.functions.zso(ts, 'rets20_VIEW');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if(application.zcore.functions.zso(ts, 'rets20_POOLFeatures') NEQ "" or application.zcore.functions.zso(ts, 'rets20_Amenities') CONTAINS "HEAPOO" or application.zcore.functions.zso(ts, 'rets20_amenities') CONTAINS "POOL"){
			local.listing_pool=1;
		}
		
		
		livingsqfoot=application.zcore.functions.zso(ts, 'rets20_SQFTRoofedLiving');
		if(livingsqfoot EQ "" or livingsqfoot EQ "0"){
			livingsqfoot=application.zcore.functions.zso(ts, 'rets20_sqfttotal');
		}

		idx=ts;
		for(i10 in idx){
			column=i10;
			value=idx[column];
			if(value NEQ ""){
				fieldName=replacenocase(column,"rets20_","");
				if(left(column,8) NEQ 'listing_' and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup, fieldName)){
					arrV=listtoarray(trim(value),',',false);
					arrV2=arraynew(1);
					for(n=1;n LTE arraylen(arrV);n++){
						t2=replace(arrV[n]," ","","ALL");
						t3=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup[fieldName]].valueStruct;
						if(structkeyexists(t3, t2)){
							t1=application.zcore.functions.zfirstlettercaps(t3[t2]);
						}else{
							t1="";	
						}
						if(t1 NEQ ""){
							arrayappend(arrV2,t1);
						}
					}
					value=arraytolist(arrV2,", ");
				}
				idx[column]=value;
			}else{
				idx[column]="";
			}
		}
		local.arrDate=["originalentrytimestamp","matrixmodifieddt","ActiveContinueToShowDate","AdvertiseDate","AuctionDate","BackOnMarketDate","CloseDate","ConditionalDate","LeaseExpirationDate","LeaseRenegotiationDate","ListingContractDate","OffMarketDate","PendingDate","RentalUnitAvailableDate","StatusContractualSearchDate","TempOffMarketDate","TemporarilyWithdrawnDate","WithdrawnDate","OriginalEntryTimestamp","PhotoModificationTimestamp","PriceChangeTimestamp","StatusChangeTimestamp","SupplementModificationTimestamp"];
		for(local.i=1;local.i LTE arraylen(local.arrDate);local.i++){
			if(isDefined('idx.rets20_'&local.arrDate[local.i]) and isdate(idx["rets20_"&local.arrDate[local.i]])){ idx["rets20_"&local.arrDate[local.i]]=dateformat(idx["rets20_"&local.arrDate[local.i]],"m/d/yyyy");}
		}
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage="";
		rs.listing_baths=application.zcore.functions.zso(ts, 'rets20_bathsfull');
		rs.listing_halfbaths=application.zcore.functions.zso(ts, 'rets20_bathshalf');
		rs.listing_beds=application.zcore.functions.zso(ts, 'rets20_bedstotal');
		rs.listing_city=cid;
		rs.listing_county=application.zcore.functions.zso(ts, 'rets20_CountyOrParish');
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts.rets20_LISTPRICE;
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts.rets20_stateorprovince;
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, 'rets20_lotsizearea');
		rs.listing_square_feet=livingsqfoot;
		rs.listing_subdivision=application.zcore.functions.zso(ts, 'rets20_neighbourhood');
		rs.listing_year_built=application.zcore.functions.zso(ts, 'rets20_yearbuilt');
		rs.listing_office=ts.rets20_ListOfficeMLSID;
		rs.listing_agent=application.zcore.functions.zso(ts, 'rets20_ListAgentMLSID');
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts.rets20_photocount;
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_condoname=application.zcore.functions.zFirstLetterCaps(application.zcore.functions.zso(ts, 'rets20_BUILDINGNAME'));
		rs.listing_address=trim(address);
		rs.listing_zip=trim(ts.rets20_postalcode);
		rs.listing_condition=trim(condition);
		rs.listing_parking=trim(parking);
		rs.listing_region=trim(region);
		rs.listing_tenure=trim(tenure);
		rs.listing_liststatus=trim(local.listing_liststatus);
		rs.listing_data_remarks=ts.rets20_publicremarks;
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts.rets20_postalcode);
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3;
		return {
			listingData:rs,
			columnIndex:columnIndex,
			arrData:arguments.ss.arrData
		};
		</cfscript>
    </cffunction>
    
    <cffunction name="getJoinSQL" localmode="modern" output="yes" returntype="any">
    	<cfargument name="joinType" type="string" required="no" default="INNER">
		<cfscript>
		var db=request.zos.queryObject;
		</cfscript>
    	<cfreturn "#arguments.joinType# JOIN #db.table("rets20_property", request.zos.zcoreDatasource)# rets20_property ON rets20_property.rets20_mlsnumber = listing.listing_id">
    </cffunction>
    <cffunction name="getPropertyListingIdSQL" localmode="modern" output="yes" returntype="any">
    	<cfreturn "rets20_property.rets20_mlsnumber">
    </cffunction>
    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="query" type="query" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript>
		var q1=0;
		var t1=0;
		var t3=0;
		var t9=0;
		var db=request.zos.queryObject;
		var d44=0;
		var t2=0;
		var i10=0;
		var value=0;
		var n=0;
		var details=0;
		var oid1=0;
		var column=0;
		var arrV=0;
		var arrV2=0;
		var local=structnew();
		var idx=this.baseGetDetails(arguments.query, arguments.row, arguments.fulldetails);
		idx["features"]="";
		request.lastPhotoId=idx.listing_id;
		idx.virtualtoururl="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		
		if(arguments.query.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
			
		}else{
			i=1;
			if(idx["rets20_status"] NEQ "A"){
				local.tempCount=1;
			}else{
				local.tempCount=arguments.query.listing_photocount;
			}
			for(i=1;i LTE local.tempCount;i++){
				local.fNameTemp1=idx.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				idx["photo"&i]=request.zos.retsPhotoPath&'20/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}
		}
		
		oid1="0";
		
		request.zos.tempObj.currentListingIdx=idx;
		
		idx.photowidth=460;
		idx.photoheight=304;
		
		idx["zipcode"]=arguments.query["rets20_postalcode"][arguments.row];
		idx["maintfees"]=arguments.query["rets20_MaintenanceExpense"][arguments.row];
		</cfscript>
        <cfsavecontent variable="details">     
		<table class="ztablepropertyinfo">   
        <!--- 
        <cfif structkeyexists(idx,'pdf1')>
            <tr><td colspan="2"><h3>PDFs Available For Download</h3></td></tr>
            <cfloop from="1" to="25" index="local.i">
                <cfif structkeyexists(idx, "pdf"&i)>
                <tr><th>PDF ###local.i#</th><th><a href="#idx["pdf"&i]#" target="_blank">#htmleditformat(idx["pdf_description"&i])#</a></th></tr>
                <cfelse>
                    <cfbreak>
                </cfif>
            </cfloop>
        </cfif> --->
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
</table>
<cfif idx.rets20_parcelnumber NEQ "">
<h3><a href="http://www.honolulupropertytax.com/Forms/PrintDatalet.aspx?jur=000&amp;State=1&amp;item=1&amp;ranks=Datalet&amp;ownseq=1&amp;card=1&amp;pin=#htmleditformat(removechars(replace(idx.rets20_parcelnumber,"-","","all"),1,1))#&amp;gsp=PROFILEALL&amp;items=-1&amp;all=all" target="_blank" rel="nofollow">View Property Tax Records</a><h3>
</cfif>
        </cfsavecontent>
        <cfscript>
		idx.details=details;
		return idx;
		</cfscript>
    </cffunction>
    
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
    	<cfscript>
		var local=structnew();
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/20/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'20/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			request.lastPhotoId="";
			return "";
		}
		</cfscript>
    </cffunction>
	
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var g=0;
		fd=structnew();
		fd["BUS"]="Business";
		fd["com"]="Commercial/Industry";
		fd["PUD"]="Condo (PUD)";
		fd["CND"]="Condo";
		fd["FOR"]="Foreclosure";
		fd["lnd"]="Land";
		fd["RNT"]="Rental";
		fd["RES"]="Single Family";
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
			}
		}
		
		for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PROPERTYFRONTAGE");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','frontage','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"VIEW");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','view','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PROPERTYSUBTYPE");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"ArchitecturalStyle");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','style','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"LANDTENURE");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','tenure','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PROPERTYCONDITION");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','condition','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"MLSAreaMajor");
			s=structnew();
			s["DiamondHd"]="Diamond Head";
			s["ewaplain"]="Ewa Plain";
			s["Metro"]="Metro Oahu";
			s["PearlCity"]="Pearl City";
			s["Central"]="Central Oahu";
			s["leeward"]="Leeward Coast";
			for(i in fd){
				if(i NEQ ""){
					if(structkeyexists(s, fd[i])){
						fd[i]=s[fd[i]];
					}
					arrayappend(arrSQL,"('#this.mls_provider#','region','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
			/* i shouldn't have used this here...
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"LISTSTATUS");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','liststatus','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}*/
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PARKINGFEATURES");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','parking','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#')");
				}
			}
		}
		return {arrSQL:arrSQL, cityCreated:false, failStr:"", arrError:arrError};
		</cfscript>
	</cffunction>
    
    </cfoutput>
</cfcomponent>