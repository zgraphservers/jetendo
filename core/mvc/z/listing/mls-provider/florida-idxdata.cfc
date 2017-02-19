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
        
        idxTemp2["far_apn"]="apn:";
        idxTemp2["far_available_date"]="available date:";
        idxTemp2["far_community_name"]="community name:";
        idxTemp2["far_county"]="county:";
        idxTemp2["far_fireplace_number"]="fireplace number:";
        idxTemp2["far_hoa_fees"]="hoa fees:";
        idxTemp2["far_owners_name"]="owners name:";
        idxTemp2["far_property_state_id"]="state:";
        idxTemp2["far_property_type_description"]="property type description:";
        idxTemp2["far_range"]="range:";
        idxTemp2["far_rent_off_season"]="rent off season:";
        idxTemp2["far_rent_on_season"]="rent on season:";
        idxTemp2["far_school_district"]="school district:";
        idxTemp2["far_school_elementary"]="school elementary:";
        idxTemp2["far_school_high"]="school high:";
        idxTemp2["far_school_junior_high"]="school junior high:";
        idxTemp2["far_school_middle"]="school middle:";
        idxTemp2["far_sold_date"]="sold date:";
        idxTemp2["far_sold_price"]="sold price:";
        idxTemp2["far_subdivision"]="subdivision:";
        idxTemp2["far_tax_year"]="tax year:";
        idxTemp2["far_taxes"]="taxes:";
        idxTemp2["far_township"]="township:";
        idxTemp2["far_building_square_footage"]="building square footage:";
        idxTemp2["far_acres"]="acres:";
        idxTemp2["far_lot_dimensions"]="lot dimensions:";
        idxTemp2["far_lot_square_footage"]="lot square footage:";
        idxTemp2["far_lot_square_footage_land"]="lot square footage land:";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["far_unit_number"]="unit number:";
		idxTemp2["far_total_buildings"]="total buildings:";
		idxTemp2["far_total_lots"]="total lots:";
		idxTemp2["far_total_rooms"]="total rooms:";
		idxTemp2["far_total_units"]="total units:";
		idxTemp2["far_great"]="great:";
		idxTemp2["far_kitchen"]="kitchen:";
		idxTemp2["far_laundry"]="laundry:";
		idxTemp2["far_living"]="living:";
		idxTemp2["far_master_bed"]="master bed:";
		idxTemp2["far_bed2"]="bed2:";
		idxTemp2["far_bed3"]="bed3:";
		idxTemp2["far_bed4"]="bed4:";
		idxTemp2["far_bed5"]="bed5:";
		idxTemp2["far_breakfast"]="breakfast:";
		idxTemp2["far_den"]="den:";
		idxTemp2["far_dining"]="dining:";
		idxTemp2["far_extra"]="extra:";
		idxTemp2["far_family"]="family:";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Unit Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		idxTemp2["far_legal"]="legal:";


		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>