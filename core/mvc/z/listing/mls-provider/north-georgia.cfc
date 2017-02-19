<cfcomponent extends="base">
	<cfoutput><cfscript>
	this.mls_provider="ngm";
	</cfscript>
    <cffunction name="init" localmode="modern" access="public" returntype="string">
    	<cfscript>
		
		if(request.zos.istestserver){
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/3/";
		}else{
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/3/";
		}
		this.getDataObject();
		</cfscript>
    </cffunction>
    
<cffunction name="getPropertyTableName" localmode="modern">
	<cfscript>
	return "ngm";
	</cfscript>
</cffunction>
    
    
    <cffunction name="setColumns" localmode="modern">
    	<cfargument name="arrColumns" type="array" required="yes">
        <cfscript>
		request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxColumns="ngm_"&replace(arraytolist(arguments.arrColumns),",",",ngm_","ALL");
		request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns=listtoarray(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxColumns);
		</cfscript>
    </cffunction>
    
    
    <cffunction name="initImport" localmode="modern" output="no" returntype="any">
    	<cfargument name="resource" type="string" required="yes">
        <cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		var qz=0;
		var i=0;
		if(arguments.resource NEQ "property"){
			application.zcore.template.fail("Invalid resource, ""#arguments.resource#"".");
		}
		arguments.sharedStruct.lookupStruct.table="ngm";
		arguments.sharedStruct.lookupStruct.primaryKey="ngm_listnum";
		arguments.sharedStruct.lookupStruct.idColumnOffset=0;
		for(i=1;i LTE arraylen(arguments.sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.sharedStruct.lookupStruct.arrColumns[i] EQ 'ngm_listnum'){
				arguments.sharedStruct.lookupStruct.idColumnOffset=i;
			}
		}
		arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();

		db.sql="show tables in `#request.zos.zcoreDatasource#` LIKE #db.param('ngm')# ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			query name="qCreate" datasource="#request.zos.zcoreDatasource#"{
				echo("CREATE TABLE `ngm` (
				  `ngm_id` int(11) unsigned NOT NULL AUTO_INCREMENT, 
				  `ngm_listnum` varchar(10) NOT NULL DEFAULT '',
				  `ngm_listprice` int(11) unsigned NOT NULL DEFAULT '0',
				  `ngm_photocount` decimal(2,0) NOT NULL DEFAULT '0',
				  `ngm_lstformtype` varchar(30) NOT NULL DEFAULT '',
				  `ngm_lstpropertytype` varchar(50) NOT NULL DEFAULT '',
				  `ngm_bedrooms` char(2) NOT NULL DEFAULT '',
				  `ngm_fullbaths` char(2) NOT NULL DEFAULT '',
				  `ngm_partialbaths` char(2) NOT NULL DEFAULT '',
				  `ngm_city` varchar(30) NOT NULL DEFAULT '',
				  `ngm_fetfrontage` varchar(25) DEFAULT NULL,
				  `ngm_fetview` varchar(100) DEFAULT NULL,
				  `ngm_lotsize` varchar(15) DEFAULT NULL,
				  `ngm_fetcondition` varchar(30) DEFAULT NULL,
				  `ngm_remarks` text,
				  `ngm_listofficeid` varchar(15) NOT NULL DEFAULT '',
				  `ngm_listofficename` varchar(120) NOT NULL DEFAULT '',
				  `ngm_lotnumber` varchar(10) NOT NULL DEFAULT '',
				  `ngm_fetbusinesstype` varchar(10) NOT NULL DEFAULT '',
				  `ngm_fetdesign` varchar(35) DEFAULT NULL,
				  `ngm_fetconstruction` varchar(20) DEFAULT NULL,
				  `ngm_fetsaleincludes` varchar(100) DEFAULT NULL,
				  `ngm_numofunits` int(2) DEFAULT NULL,
				  `ngm_lstarea` varchar(75) DEFAULT NULL,
				  `ngm_acreage` decimal(8,2) NOT NULL DEFAULT '0.00',
				  `ngm_listagentid` varchar(11) DEFAULT NULL,
				  `ngm_yearbuilt` int(4) DEFAULT NULL,
				  `ngm_zipcode` varchar(5) NOT NULL DEFAULT '',
				  `ngm_lststatus` char(1) NOT NULL DEFAULT '',
				  `ngm_phototimestamp` varchar(20) DEFAULT NULL,
				  `ngm_lakename` varchar(25) DEFAULT NULL,
				  `ngm_licensedowner` varchar(5) DEFAULT NULL,
				  `ngm_listagentcellph` varchar(15) NOT NULL DEFAULT '',
				  `ngm_listagentemail` varchar(50) DEFAULT NULL,
				  `ngm_listagentname` varchar(50) NOT NULL DEFAULT '',
				  `ngm_rivername` varchar(35) DEFAULT NULL,
				  `ngm_fetterrain` varchar(50) DEFAULT NULL,
				  `ngm_mainflrbedrms` varchar(10) DEFAULT NULL,
				  `ngm_upperflrbedrms` varchar(10) DEFAULT NULL,
				  `ngm_lowerflrbedrooms` varchar(10) DEFAULT NULL,
				  `ngm_totalrooms` varchar(10) DEFAULT NULL,
				  `ngm_zoningcode` varchar(10) DEFAULT NULL,
				  `ngm_surveyavailable` varchar(10) DEFAULT NULL,
				  `ngm_coventants` varchar(50) DEFAULT NULL,
				  `ngm_fetrestrictions` varchar(50) DEFAULT NULL,
				  `ngm_fetmasterbedroom` varchar(50) DEFAULT NULL,
				  `ngm_fetparking` varchar(50) DEFAULT NULL,
				  `ngm_fetcooling` varchar(50) DEFAULT NULL,
				  `ngm_fetroadsurface` varchar(50) DEFAULT NULL,
				  `ngm_fetlake` varchar(50) DEFAULT NULL,
				  `ngm_fetlaundrylocation` varchar(50) DEFAULT NULL,
				  `ngm_township` varchar(30) DEFAULT NULL,
				  `ngm_fetmilestotown` varchar(30) DEFAULT NULL,
				  `ngm_subdivision` varchar(30) DEFAULT NULL,
				  `ngm_fetdriveway` varchar(30) DEFAULT NULL,
				  `ngm_fetwater` varchar(30) DEFAULT NULL,
				  `ngm_fetsewer` varchar(30) DEFAULT NULL,
				  `ngm_fetwindows` varchar(100) DEFAULT NULL,
				  `ngm_fetroof` varchar(100) DEFAULT NULL,
				  `ngm_fetbasement` varchar(100) DEFAULT NULL,
				  `ngm_fetstyle` varchar(100) DEFAULT NULL,
				  `ngm_fetrooms` varchar(100) DEFAULT NULL,
				  `ngm_fetinterior` varchar(100) DEFAULT NULL,
				  `ngm_fetexterior` varchar(100) DEFAULT NULL,
				  `ngm_fetheating` varchar(100) DEFAULT NULL,
				  `ngm_fetappliances` varchar(100) DEFAULT NULL,
				  `ngm_fetfloors` varchar(100) DEFAULT NULL,
				  `ngm_listofficeemail` varchar(30) DEFAULT NULL,
				  `ngm_listofficephone` varchar(30) DEFAULT NULL,
				  `ngm_listofficephone2` varchar(30) DEFAULT NULL,
				  `ngm_agentphone` varchar(30) DEFAULT NULL,
				  `ngm_streetnumber` varchar(10) DEFAULT NULL,
				  `ngm_streetdirection` varchar(10) DEFAULT NULL,
				  `ngm_streetname` varchar(30) DEFAULT NULL,
				  `ngm_address` varchar(50) DEFAULT NULL,
				  `ngm_state` char(2) DEFAULT NULL,
				  `ngm_fetrecreation` varchar(50) DEFAULT NULL,
				  `ngm_virtualtoururl` varchar(255) NOT NULL,
				  `ngm_foreclosure` char(1) NOT NULL DEFAULT '0',
				  `ngm_fetvow` varchar(100) NOT NULL,
				  `ngm_csysrevisiondate` varchar(20) NOT NULL,
				  PRIMARY KEY (`ngm_id`),
				  UNIQUE KEY `NewIndex1` (`ngm_listnum`)
				) ENGINE=InnoDB DEFAULT CHARSET=utf8
				");
			}
		}
		</cfscript>
        <cfsavecontent variable="db.sql">
        select city_name, state_abbr, zipcode_zip 
		from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
		where zipcode_zip IN 	#db.trustedSQL("('30540','28906','28904','30546','30512','30560','30582','28909','30513','37326','28902','28781','20909','28905','28901', 
		'30175','30559','30734','30572','30522','30536','37391','28771','30705','30541','30143','30114','30555','37317','28903','30548','30571', 
		'28692','37307','30539','30527','28907','30528','30533','30107','29650','37333','30545','35013','30149','30139','28096','30115','30517', 
		'11111','30514','30148','30703','50559','30576','30852','30577','30620','30506','30534','35040','37369','30183','20582','32560','28703', 
		'30184','30606','39546','31512','30552','30525','30563','28734','30028','30584','30707','30450','30701','31523','28890','30635','37362', 
		'30103','30530','37325','30151','30728','30732','28914','30812','30189','37393','30177','30736','30518','30629','30449','28871','30735','30311')")# 
		and zipcode_deleted = #db.param(0)#
        </cfsavecontent><cfscript>qZ=db.execute("qZ");</cfscript>
        <cfloop query="qZ">
            <cfscript>arguments.sharedStruct.lookupStruct.cityRenameStruct[qZ.zipcode_zip]=qZ.city_name&"|"&qZ.state_abbr;</cfscript>
        </cfloop>
    </cffunction>
    
    <cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
    	<cfargument name="idlist" type="string" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var arrId=listtoarray(mid(replace(arguments.idlist," ","","ALL"),2,len(arguments.idlist)-2),"','");
		super.deleteListings(arguments.idlist);
		db.sql="DELETE FROM #db.table("ngm", request.zos.zcoreDatasource)#  
		WHERE ngm_listnum LIKE #db.param('#this.mls_id#-%')# and 
		ngm_listnum IN (#db.trustedSQL(arguments.idlist)#)";
		db.execute("q"); 
		</cfscript>
    </cffunction>

    <cffunction name="getDataObject" localmode="modern" output="no">
    	<cfscript>
		if(structkeyexists(variables, 'mlsDataCom') EQ false){
			variables.mlsDataCom=createobject("component", "zcorerootmapping.mvc.z.listing.mls-provider.north-georgiadata");
		}
		return variables.mlsDataCom;
		</cfscript>
    </cffunction>
    
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var arrD=0;
		var cid=0;
		var arrS=0;
		var i=0;
		var ts=structnew();
		var columnIndex=structnew();
		var ts2=0;
		var s=0;
		var rs5=0;
		var address=0;
		var cid=0;
		var curLat=0;
		var curLong=0;
		var newList=0;
		var values=0;
		var dataCom=0;
		var cityName=0;
		var rs=0;
		var local=structnew();
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}
		this.price=ts.ngm_listprice;
		
		cityName="";
		cid=0;
		if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts.ngm_zipcode)){
			cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts.ngm_zipcode];
			ts.ngm_city=listgetat(cityName,1,"|");
			if(structkeyexists(request.zos.listing.cityStruct, cityName)){
				cid=request.zos.listing.cityStruct[cityName];
			}
		}else if(structkeyexists(request.zos.listing.cityStruct, ts.ngm_city&"|"&ts.ngm_state)){
			cid=request.zos.listing.cityStruct[ts.ngm_city&"|"&ts.ngm_state];
		}
		arrD=listtoarray(ts.ngm_fetstyle);
		arrS=[];
		for(i=1;i LTE arraylen(arrD);i++){
			arrayappend(arrS,this.listingLookupNewId("style",trim(arrD[i])));
		}
		local.listing_style=arraytolist(arrS);
		
		arrD=listtoarray(ts.ngm_fetview);
		arrS=[];
		for(i=1;i LTE arraylen(arrD);i++){
			arrayappend(arrS,this.listingLookupNewId("view",trim(arrD[i])));
		}
		local.listing_view=arraytolist(arrS);
		
		arrD=listtoarray(ts.ngm_fetfrontage);
		arrS=[];
		for(i=1;i LTE arraylen(arrD);i++){
			arrayappend(arrS,this.listingLookupNewId("frontage",trim(arrD[i])));
		}
		local.listing_frontage=arraytolist(arrS);
		
		local.listing_type_id=this.listingLookupNewId("listing_type",ts.ngm_lstformtype);
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",ts.ngm_lstpropertytype);
		local.listing_county=this.listingLookupNewId("county",ts.ngm_lstarea);
		arrD=listtoarray(ts.ngm_fetcondition);
		arrS=[];
		for(i=1;i LTE arraylen(arrD);i++){
			arrayappend(arrS,this.listingLookupNewId("condition",trim(arrD[i])));
		}
		local.listing_condition=arraytolist(arrS);
		local.listing_pool=0;
		if(ts.ngm_fetexterior CONTAINS "pool"){
			local.listing_pool=1;	
		}
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts.ngm_yearbuilt;
		ts2.foreclosureField="";
		s=this.processRawStatus(ts2);
		if(ts.ngm_foreclosure EQ '1'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		local.listing_status=structkeylist(s,",");
		address=application.zcore.functions.zFirstLetterCaps(lcase(ts.ngm_address));
		curLat="";
		curLong="";
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts.ngm_state,ts.ngm_zipcode, arguments.ss.listing_id);
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		
		
		
		dataCom=this.getDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=getListingTypeWithCode(ts["ngm_lstpropertytype"]);
		//ts["ngm_lstpropertytype"]=rs.id;
		arguments.ss.arrData[columnIndex["ngm_city"]]=""&ts.ngm_city;

		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=ts.ngm_acreage;
		rs.listing_baths=ts.ngm_fullbaths;
		rs.listing_halfbaths=ts.ngm_partialbaths;
		rs.listing_beds=ts.ngm_bedrooms;
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name=trim(ts.ngm_lakename&" "&ts.ngm_rivername);
		rs.listing_price=ts.ngm_listprice;
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts.ngm_state;
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet="";
		rs.listing_square_feet="";
		rs.listing_subdivision=ts.ngm_subdivision;
		rs.listing_year_built=ts.ngm_yearbuilt;
		rs.listing_office=ts.ngm_listofficeid;
		rs.listing_agent=ts.ngm_listagentid;
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts.ngm_photocount;
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_address=trim(address);
		rs.listing_zip=ts.ngm_zipcode;
		rs.listing_condition=local.listing_condition;
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=ts.ngm_remarks;
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=ts.ngm_zipcode;
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
    	<cfreturn "#arguments.joinType# JOIN #db.table("ngm", request.zos.zcoreDatasource)# ngm ON ngm.ngm_listnum = listing.listing_id">
    </cffunction>
    
    <cffunction name="getPropertyListingIdSQL" localmode="modern" output="yes" returntype="any">
    	<cfreturn "ngm.ngm_listnum">
    </cffunction>
    <cffunction name="getListingIdField" localmode="modern" output="yes" returntype="any">
    	<cfreturn "ngm_listnum">
    </cffunction>
    
    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript>
	var column=0;
	var i=0;
	var features=0;
	var value=0;
	var details=0;
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		var ts=application.zcore.listingCom.parseListingId(arguments.ss.listing_id);
		var a2=listtoarray(lcase(arguments.ss.columnlist));
		for(i=1;i LTE arraylen(a2);i++){
			column=a2[i];
			value=arguments.ss[column];
			if(value NEQ ""){
				idx[column]=value;
			}else{
				idx[column]="";
			}
		}
		features="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		request.lastPhotoId=arguments.ss.listing_id;
		arguments.ss.ngm_photocount=application.zcore.functions.zso(arguments.ss, 'ngm_photocount', true);
		if(arguments.ss.ngm_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{	
			for(i=1;i LTE arguments.ss.ngm_photocount;i++){
				idx["photo"&i]='http://photos.neg.ctimls.com/neg/photos/large/#left(right(ts.mls_pid,2),1)#/#right(ts.mls_pid,1)#/#ts.mls_pid##application.zcore.functions.zNumberToLetter(i)#.jpg';
			}
		}
		idx["officeName"]=application.zcore.functions.zso(arguments.ss, 'ngm_listofficename');
		idx["agentName"]=application.zcore.functions.zso(arguments.ss, 'ngm_listagentname');
		idx["features"]="";
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, 'ngm_virtualtoururl');
		
		idx["virtualtoururl"]=replace(application.zcore.functions.zso(idx, "virtualtoururl"),"htttp:","http:");
		if(idx["virtualtoururl"] NEQ "" and find("http://",idx["virtualtoururl"]) EQ 0 and (find(".",idx["virtualtoururl"]) NEQ 0 and find("/",idx["virtualtoururl"]) NEQ 0)){
			idx["virtualtoururl"]&="http://"&idx["virtualtoururl"];
		}
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, 'ngm_zipcode');
		idx["maintfees"]="";
		details="";
		</cfscript>
        <cfif arguments.fulldetails>
        <cfsavecontent variable="details"><table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
		</table></cfsavecontent>
        </cfif>
        <cfscript>
		idx.details=details;
		return idx;
		</cfscript>
    </cffunction>
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
    	<cfscript>
		var photo='http://photos.neg.ctimls.com/neg/photos/large/#left(right(arguments.mls_pid,2),1)#/#right(arguments.mls_pid,1)#/#arguments.mls_pid##application.zcore.functions.zNumberToLetter(arguments.num)#.jpg';
		return photo;
		</cfscript>
    </cffunction>
    
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var db=request.zos.queryObject;
		var dS=0;
		var arrD=0;
		var pos=0;
		var countyName=0;
		var arrD=0;
		var ds2=0;
		var arrT=0;
		var qD=0;
		
		 db.sql="select cast(group_concat(distinct ngm_lstarea SEPARATOR #db.param(',')#) AS CHAR) datalist 
		 from #db.table("ngm", request.zos.zcoreDatasource)# ngm 
		WHERE ngm_lstarea<> #db.param('')#";
		qD=db.execute("qD");
		arrD=listtoarray(qD.datalist);
		dS=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			pos=find(" ",trim(arrD[i]));
			if(pos NEQ 0){
				countyName=left(trim(arrD[i]), pos-1);	
			}else{
				countyName="";
			}
			dS[trim(arrD[i])]=countyName;	
		}
		
		for(i in dS){
			arrayappend(arrSQL,"('#this.mls_provider#','county','#dS[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		 db.sql="select cast(group_concat(distinct ngm_fetview SEPARATOR #db.param(',')#) AS CHAR) datalist 
		 from #db.table("ngm", request.zos.zcoreDatasource)# ngm 
		WHERE ngm_fetview<> #db.param('')#";
		qD=db.execute("qD");
		arrD=listtoarray(qD.datalist);
		dS=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			dS[trim(arrD[i])]=true;	
		}
		
		for(i in dS){
			arrayappend(arrSQL,"('#this.mls_provider#','view','#i#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		 db.sql="select cast(group_concat(distinct ngm_fetcondition SEPARATOR #db.param(',')#) AS CHAR) datalist 
		 from #db.table("ngm", request.zos.zcoreDatasource)# ngm 
		WHERE ngm_fetcondition<> #db.param('')#";
		qD=db.execute("qD");
		arrD=listtoarray(qD.datalist);
		dS=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			dS[trim(arrD[i])]=true;	
		}
		structdelete(dS,"See Remarks");
		
		for(i in dS){
			arrayappend(arrSQL,"('#this.mls_provider#','condition','#i#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		 db.sql="select cast(group_concat(distinct ngm_fetstyle SEPARATOR #db.param(',')#) AS CHAR) datalist 
		 from #db.table("ngm", request.zos.zcoreDatasource)# ngm 
		WHERE ngm_fetstyle<> #db.param('')#";
		qD=db.execute("qD");
		arrD=listtoarray(qD.datalist);
		dS=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			dS[trim(arrD[i])]=true;	
		}
		structdelete(dS,"See Remarks");
		structdelete(dS,"See");
		structdelete(dS,"S");
		
		for(i in dS){
			arrayappend(arrSQL,"('#this.mls_provider#','style','#i#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 
		db.sql="select cast(group_concat(distinct ngm_fetfrontage SEPARATOR #db.param(',')#) AS CHAR) datalist 
		from #db.table("ngm", request.zos.zcoreDatasource)# ngm 
		WHERE ngm_fetfrontage<> #db.param('')#";
		qD=db.execute("qD");
		arrD=listtoarray(qD.datalist);
		dS=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			dS[trim(arrD[i])]=true;	
		}
		ds2=structnew();
		ds2["Lake"]="Lakefront";
		ds2["River"]="Riverfront";
		ds2["Canal"]="Canalfront";
		structdelete(ds,'None');
		for(i in dS){
			if(structkeyexists(ds2,i)){
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#ds2[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}else{
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#i#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		
		
		
		arrayappend(arrSQL,"('#this.mls_provider#','listing_type','Lots and Acreage','Lots/Acreage','#request.zos.mysqlnow#','Lots/Acreage','#request.zos.mysqlnow#', '0')");
		arrayappend(arrSQL,"('#this.mls_provider#','listing_type','Residential','Residential','#request.zos.mysqlnow#','Residential','#request.zos.mysqlnow#', '0')");
		arrayappend(arrSQL,"('#this.mls_provider#','listing_type','Commercial','Commercial','#request.zos.mysqlnow#','Commercial','#request.zos.mysqlnow#', '0')");
		arrayappend(arrSQL,"('#this.mls_provider#','listing_type','Multi-Family','Multi-Family & Apartments','#request.zos.mysqlnow#','Multi-Family & Apartments','#request.zos.mysqlnow#', '0')");
		arrT=listtoarray("Vacant Lot,Lake Front Lot,Commercial Lot,Acreage,River Access Lot,Commercial,Residential,Townhouse,Lake Access Lot,Subdivision being developed,Condominium,Business,Mobile Home Lot,Duplex,RV Lot,Farm,Multi-Family,Apartments,Industrial,Multiple Ownership",",");
		for(i=1;i LTE arraylen(arrT);i++){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#arrT[i]#','#arrT[i]#','#request.zos.mysqlnow#','#arrT[i]#','#request.zos.mysqlnow#', '0')");
		}

		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>