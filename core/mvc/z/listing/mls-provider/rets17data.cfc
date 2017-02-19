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
		idxTemp2["rets17_ftr_appliance"]="appliance:";
		idxTemp2["rets17_ftr_assmortgagetype"]="assmortgagetype:";
		idxTemp2["rets17_ftr_constrc"]="constrc:";
		idxTemp2["rets17_ftr_constrc_status"]="constrc status:";
		idxTemp2["rets17_ftr_energy"]="energy:";
		idxTemp2["rets17_ftr_exterior"]="exterior:";
		idxTemp2["rets17_ftr_farm_info"]="farm info:";
		idxTemp2["rets17_ftr_hoaincl"]="hoaincl:";
		idxTemp2["rets17_ftr_interior"]="interior:";
		idxTemp2["rets17_ftr_internet"]="internet:";
		idxTemp2["rets17_ftr_leases"]="leases:";
		idxTemp2["rets17_ftr_listing_class"]="listing class:";
		idxTemp2["rets17_ftr_lotaccess"]="lotaccess:";
		idxTemp2["rets17_ftr_lotdesc"]="lotdesc:";
		idxTemp2["rets17_ftr_parking"]="parking:";
		idxTemp2["rets17_ftr_projfacilities"]="projfacilities:";
		idxTemp2["rets17_ftr_restrictions"]="restrictions:";
		idxTemp2["rets17_ftr_roomdesc"]="roomdesc:";
		idxTemp2["rets17_ftr_sale_type"]="sale type:";
		idxTemp2["rets17_ftr_style"]="style:";
		idxTemp2["rets17_ftr_toshow"]="toshow:";
		idxTemp2["rets17_ftr_utilities"]="utilities:";
		idxTemp2["rets17_ftr_waterfront"]="waterfront:";
		idxTemp2["rets17_ftr_waterview"]="waterview:";
		idxTemp2["rets17_ftr_zoning"]="zoning:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets17_middle_school"]="middle school:";
		idxTemp2["rets17_elem_school"]="Elementary school:";
		idxTemp2["rets17_high_school"]="high school:";
		idxTemp2["rets17_area"]="area:";
		idxTemp2["rets17_county"]="county:";
		idxTemp2["rets17_zoning"]="zoning:";
		
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Zoning Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		
		
		idxTemp2=structnew();
		
		idxTemp2["rets17_lot_depth"]="lot depth:";
		idxTemp2["rets17_lot_dimensions"]="lot dimensions:";
		idxTemp2["rets17_lot_frontage"]="lot frontage:";
		idxTemp2["rets17_master_development"]="master development:";
		idxTemp2["rets17_no_assigned_spaces"]="no assigned spaces:";
		idxTemp2["rets17_no_carport_spaces"]="no carport spaces:";
		idxTemp2["rets17_no_covered_spaces"]="no covered spaces:";
		idxTemp2["rets17_no_driveway_spaces"]="no driveway spaces:";
		idxTemp2["rets17_no_garage_spaces"]="no garage spaces:";
		idxTemp2["rets17_no_street_spaces"]="no street spaces:";
		idxTemp2["rets17_no_total_parking_spaces"]="no total parking spaces:";
		idxTemp2["rets17_num_dock_high_doors"]="num dock high doors:";
		idxTemp2["rets17_num_floors"]="num floors:";
		idxTemp2["rets17_num_fractions"]="num fractions:";
		idxTemp2["rets17_num_ground_level_doors"]="num ground level doors:";
		idxTemp2["rets17_num_rooms"]="num rooms:";
		idxTemp2["rets17_num_stories_abv_grnd"]="num stories abv grnd:";
		idxTemp2["rets17_num_stories_bldg"]="num stories bldg:";
		idxTemp2["rets17_num_units"]="num units:";
		idxTemp2["rets17_wf_description"]="Waterfront description:";
		idxTemp2["rets17_wf_feet"]="Waterfront feet:";
		idxTemp2["rets17_acreage"]="acreage:";
		idxTemp2["rets17_location"]="location:";
		idxTemp2["rets17_building_sqft"]="building sqft:";
		idxTemp2["rets17_fractional_details"]="fractional details:";
		idxTemp2["rets17_hvac_whse_sqft"]="hvac whse sqft:";
		idxTemp2["rets17_office_class"]="office class:";
		idxTemp2["rets17_office_sqft"]="office sqft:";
		idxTemp2["rets17_parcel_id"]="parcel id:";
		idxTemp2["rets17_parking_spaces"]="parking spaces:";
		idxTemp2["rets17_parking_type"]="parking type:";
		idxTemp2["rets17_tot_bldg_sqft"]="tot bldg sqft:";
		idxTemp2["rets17_tot_heat_sqft"]="tot heat sqft:";
		idxTemp2["rets17_tot_whse_sqft"]="tot whse sqft:";
		idxTemp2["rets17_retail_sqft"]="retail sqft:";
		idxTemp2["rets17_site_information"]="site information:";
		idxTemp2["rets17_sprinklers_yn"]="sprinklers yn:";
		idxTemp2["rets17_sqft_balcony"]="sqft balcony:";
		idxTemp2["rets17_stories"]="stories:";
		idxTemp2["rets17_use_plan"]="use plan:";
		idxTemp2["rets17_description"]="description:";
		idxTemp2["rets17_preview_info"]="preview info:";
		idxTemp2["rets17_property_name"]="property name:";
		idxTemp2["rets17_property_type"]="property type:";
		idxTemp2["rets17_proptype_com_ind"]="proptype com ind:";
		idxTemp2["rets17_proptype_com_land"]="proptype com land:";
		idxTemp2["rets17_proptype_com_nli"]="proptype com nli:";
		idxTemp2["rets17_proptype_com_office"]="proptype com office:";
		idxTemp2["rets17_proptype_com_retail"]="proptype com retail:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Building &amp; Land Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["rets17_assessment_yn"]="assessment yn:";
		idxTemp2["rets17_auction_directions"]="auction directions:";
		idxTemp2["rets17_auction_type"]="auction type:";
		idxTemp2["rets17_available_date"]="available date:";
		idxTemp2["rets17_bidder_choice_yn"]="bidder choice yn:";
		idxTemp2["rets17_bom_date"]="bom date:";
		idxTemp2["rets17_brokerage_interest"]="brokerage interest:";
		idxTemp2["rets17_buyer_premium"]="buyer premium:";
		idxTemp2["rets17_cam"]="cam:";
		idxTemp2["rets17_cam_per"]="cam per:";
		idxTemp2["rets17_constrc_status"]="constrc status:";
		idxTemp2["rets17_current_price"]="current price:";
		//idxTemp2["rets17_date_created"]="Listing Date:";
		//idxTemp2["rets17_date_modified"]="Listing Modified Date:";
		idxTemp2["rets17_land_lease_amount"]="land lease amount:";
		idxTemp2["rets17_lease_expire_date"]="lease expire date:";
		idxTemp2["rets17_lease_sqft_year"]="lease sqft year:";
		idxTemp2["rets17_legals"]="legals:";
		idxTemp2["rets17_maint_fee"]="maint fee:";
		idxTemp2["rets17_maint_term"]="maint term:";
		idxTemp2["rets17_min_bid"]="Auction Minimum Bid:";
		idxTemp2["rets17_online_bidding_yn"]="online bidding yn:";
		idxTemp2["rets17_price_acre"]="price acre:";
		idxTemp2["rets17_price_change_date"]="price change date:";
		idxTemp2["rets17_price_sqft"]="price sqft:";
		idxTemp2["rets17_price_unit"]="price unit:";
		idxTemp2["rets17_proj_close_date"]="proj close date:";
		idxTemp2["rets17_proj_name"]="proj name:";
		idxTemp2["rets17_res_hoa_fee"]="res hoa fee:";
		idxTemp2["rets17_res_hoa_term"]="res hoa term:";
		idxTemp2["rets17_rnt_credit_check_yn"]="rnt credit check yn:";
		idxTemp2["rets17_rnt_date_available"]="rnt date available:";
		idxTemp2["rets17_rnt_pet_fee"]="rnt pet fee:";
		idxTemp2["rets17_rnt_security_dep"]="rnt security dep:";
		idxTemp2["rets17_status_date"]="status date:";
		idxTemp2["rets17_subj_to_lease_yn"]="subj to lease yn:";
		idxTemp2["rets17_term"]="term:";
		idxTemp2["rets17_vacancy_rate"]="vacancy rate:";
		idxTemp2["rets17_vacant_yn"]="vacant yn:";
		idxTemp2["rets17_vt_yn"]="vt yn:";
		idxTemp2["rets17_week_of_sale"]="week of sale:";
		idxTemp2["rets17_weeks_fraction"]="weeks fraction:";
		idxTemp2["rets17_occupancy_yn"]="occupancy yn:";
		idxTemp2["rets17_ad_details"]="ad details:";
		idxTemp2["rets17_listing_class"]="listing class:";
		idxTemp2["rets17_listing_type"]="listing type:";
		idxTemp2["rets17_loopnet_1"]="loopnet 1:";
		idxTemp2["rets17_loopnet_2"]="loopnet 2:";
		idxTemp2["rets17_loopnet_3"]="loopnet 3:";
		idxTemp2["rets17_loopnet_4"]="loopnet 4:";
		idxTemp2["rets17_loopnet_5"]="loopnet 5:";
		idxTemp2["rets17_loopnet_6"]="loopnet 6:";
		idxTemp2["rets17_orig_lp"]="orig lp:";
		idxTemp2["rets17_pre_auction_offers_yn"]="pre auction offers yn:";
		idxTemp2["rets17_pre_con_yn"]="pre con yn:";
		idxTemp2["rets17_design"]="design:";
		
		idxTemp2["rets17_event_date"]="event date:";
		idxTemp2["rets17_event_time"]="event time:";
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>