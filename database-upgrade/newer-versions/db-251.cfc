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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option`   
  CHANGE `site_x_option_value` `site_x_option_value` LONGTEXT NOT NULL")){
		return false;
	}         

 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_x_option_group`   
  CHANGE `site_x_option_group_value` `site_x_option_group_value` LONGTEXT NOT NULL")){
		return false;
	}         
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE `rets4_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets4_agent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets18_agent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets19_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets20_openhouse`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets17_agent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets26_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets14_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets20_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `ngm`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets12_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets11_agent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets22_activeagent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets26_activeagent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets22_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets21_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets14_activeagent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets26_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets14_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets18_media`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets11_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets11_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets25_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets18_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets18_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets22_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets24_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `far`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets4_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets16_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets7_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets25_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets24_activeagent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets24_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets27_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets20_agent`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets20_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets17_property`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets17_office`")){ 		return false;	}     
if(!arguments.dbUpgradeCom.executeQuery(this.datasource, " DROP TABLE `rets25_agent`")){ 		return false;	}     

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>