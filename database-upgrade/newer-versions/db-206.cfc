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
 	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `form_log`   
  CHANGE `form_log_field1_label` `form_log_field1_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL  AFTER `form_log_user_agent`,
  CHANGE `form_log_field2_label` `form_log_field2_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field3_label` `form_log_field3_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field4_label` `form_log_field4_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field5_label` `form_log_field5_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field6_label` `form_log_field6_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field7_label` `form_log_field7_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field8_label` `form_log_field8_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field9_label` `form_log_field9_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field10_label` `form_log_field10_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field11_label` `form_log_field11_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field12_label` `form_log_field12_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field13_label` `form_log_field13_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field14_label` `form_log_field14_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field15_label` `form_log_field15_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field16_label` `form_log_field16_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field17_label` `form_log_field17_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field18_label` `form_log_field18_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field19_label` `form_log_field19_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `form_log_field20_label` `form_log_field20_label` VARCHAR(50) CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){
		return false;
	}  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>