<cfcomponent>
 <cfoutput>
<cffunction name="simple" localmode="modern" access="remote" output="yes">
	<cfscript>
	request.zForceSimpleViewEmail=true;
	this.index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" output="yes">
 
	<cfscript>
	var output=0;
	var rCom=0;
	var rs=0;
	var zpagenav=0;
	var ts=0;
	var emailCom=0;
	var db=request.zos.queryObject;
	if(isdefined('request.cgi_script_name') EQ false){
		request.cgi_script_name=request.cgi_script_name;
	}
	// switch template based on this variable when zemail_campaign_id is 0.
	form.zemail_template_type_id=application.zcore.functions.zso(form, 'zemail_template_type_id',true);
	request.znotemplate=1;
	zpagenav='<a href="/">Home</a> /';
	if(structkeyexists(form,'zemail_campaign_id') EQ false or (structkeyexists(form,'user_id') EQ false and structkeyexists(form,'contact_id') EQ false)){
	application.zcore.functions.zRedirect('/');
	}
	ts=StructNew();
	// optional
	ts.site_id=request.zos.globals.id;
	ts.preview=true;
	ts.hideViewEmailUrl=true;
	ts.force=true;
	if(form.zemail_campaign_id EQ 0){
		if(form.zemail_template_type_id EQ 0){
			ts.zemail_template_type_name = 'confirm opt-in';
		}else if(form.zemail_template_type_id EQ 3){
			ts.zemail_template_type_name = 'New Listing Alert';
		}
	}else{
		db.sql="SELECT * FROM #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
		WHERE zemail_campaign_id = #db.param(form.zemail_campaign_id)# and 
		site_id = #db.param(request.zos.globals.id)# and
		zemail_campaign_deleted = #db.param(0)#";
		qEC=db.execute("qEC"); 
		if(qEC.recordcount EQ 0){
			application.zcore.functions.zRedirect('/');
		}
		ts.zemail_campaign_id=form.zemail_campaign_id;
		ts.zemail_template_id=qEC.zemail_template_id;
	}
	if(isDefined('request.zForceSimpleViewEmail')){
		ts.contact_key=form.contact_key;
		ts.contact_id=form.contact_id;
	}else{
		ts.user_key=form.user_key;
		ts.user_id=form.user_id;
	}
	if(structkeyexists(form, 'forcetext') eq false){
		ts.forceHTML=true;
	}
	emailCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.app.email");
	rCom=emailCom.sendEmailTemplate(ts); 
	
	if(rCom.isOK() EQ false){
		writeoutput('Sorry, this email is no longer available for viewing online.  <a href="/">Click here to visit our home page.</a>');
		rCom.setStatusErrors(request.zsid);
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zabort();
	}
	rs=rCom.getData();
	if(structkeyexists(form, 'forcetext') or isDefined('rs.sendReturnData.preview.html') EQ false or rs.sendReturnData.preview.html EQ ''){
		output='<table style="border:1px solid ##CCCCCC;width:650px; padding:5px;"><tr><td>'&emailCom.displayBody(emailCom.convertToHtml(rs.sendReturnData.preview.text),'640px')&'</td></tr></table>';
	}else{
		output=rs.sendReturnData.preview.html;
	}
	writeoutput('<table style="width:750px;"><tr><td>'&output&'</td></tr></table>');
	application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
	application.zcore.template.setTag("title",rs.sendReturnData.preview.cfmail.subject);
	application.zcore.template.setTag("pagetitle",rs.sendReturnData.preview.cfmail.subject);
	application.zcore.template.setTag("pagenav",zpagenav);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>