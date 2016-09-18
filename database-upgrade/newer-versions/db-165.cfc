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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog`   
  ADD COLUMN `blog_comment_count` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `blog_grid_id`")){
		return false;
	}     
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_version`   
  ADD COLUMN `blog_comment_count` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `blog_grid_id`")){
		return false;
	}     
	db=request.zos.queryObject;
	db.sql="SELECT blog_id, site_id, COUNT(blog_comment_id) COUNT FROM 
	#db.table("blog_comment", this.datasource)#  WHERE
	blog_comment_approved=#db.param(1)#  AND 
	blog_comment.site_id <> #db.param(-1)# AND 
	blog_comment_deleted = #db.param(0)# 
	GROUP BY site_id, blog_id";
	qCount=db.execute("qCount");
	for(row in qCount){
		db.sql="UPDATE #db.table("blog", this.datasource)# SET 
		blog_comment_count=#db.param(row.count)#, 
		blog_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE blog_deleted=#db.param(0)# and 
		site_id = #db.param(row.site_id)# and 
		blog_id=#db.param(row.blog_id)# ";
		db.execute("qUpdateBlogCount");
	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>