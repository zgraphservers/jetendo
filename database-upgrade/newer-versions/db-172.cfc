<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `zipcode`   
  ADD COLUMN `zipcode_latitude_integer` INT(11) DEFAULT 0  NOT NULL AFTER `zipcode_deleted`,
  ADD COLUMN `zipcode_longitude_integer` INT(11) DEFAULT 0  NOT NULL AFTER `zipcode_latitude_integer`, 
  ADD  INDEX `zipcode_latlong2` (`zipcode_latitude_integer`, `zipcode_longitude_integer`)")){
		return false;
	}        
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE zipcode SET zipcode_latitude_integer=zipcode_latitude*100000, zipcode_longitude_integer=zipcode_longitude*100000")){
		return false;
	}         
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>