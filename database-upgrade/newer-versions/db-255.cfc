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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets11_agent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets11_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets11_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets12_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets14_activeagent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets14_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets14_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets16_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets17_agent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets17_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets17_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets18_agent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets18_media")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets18_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets18_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets19_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets20_agent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS ngm")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS far")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets20_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets20_openhouse")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets20_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets21_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets22_activeagent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets22_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets22_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets24_activeagent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets24_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets24_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets25_agent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets25_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets25_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets26_activeagent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets26_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets26_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets27_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets28_agent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets28_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets28_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets4_agent")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets4_office")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets4_property")){		return false;	}            
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "DROP TABLE IF EXISTS rets7_property")){		return false;	}            


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>