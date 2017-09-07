<cfcomponent>
<cfoutput> 

<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	var db = request.zos.queryObject; 

	var fileId = application.zcore.functions.zso( form, 'fileId' );
	var parsedFileId = this.parseFileId( fileId );

	// Get inquiries feedback from database
	var inquiriesFeedbackCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.feedback' );
	var inquiries_feedback = inquiriesFeedbackCom.getInquiriesFeedbackById( parsedFileId.inquiries_feedback_id );

	authenticated=false;
	if(parsedFileId.inquiries_feedback_download_key NEQ ""){
		if(inquiries_feedback.inquiries_feedback_download_key NEQ ""){
			if(compare(inquiries_feedback.inquiries_feedback_download_key, parsedFileId.inquiries_feedback_download_key) NEQ 0){
				application.zcore.functions.z404("Invalid inquiries_feedback_download_key for inquiries_feedback_id ###parsedFileId.inquiries_feedback_id#.");
			}else{
				authenticated=true;
			}
		}else{
			application.zcore.functions.z404("inquiries_feedback_id: #parsedFileId.inquiries_feedback_id# has an empty inquiries_feedback_download_key");
		}
	}

	form.inquiries_id = inquiries_feedback.inquiries_id;

	// Get inquiries from database
	var inquiriesFunctionsCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.com.app.inquiriesFunctions' );
	var inquiry = inquiriesFunctionsCom.getInquiryDataById( inquiries_feedback.inquiries_id );

  
	if(not authenticated){
		if ( application.zcore.user.checkGroupAccess("administrator") ) {
			authenticated=true;
		}else if ( application.zcore.user.checkGroupAccess("member") ) {
			// check if assigned to this agent
			if(inquiry.user_id EQ request.zsession.user.id and inquiry.user_id_siteidtype EQ application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id)){
				authenticated=true; 
			}
		}
		if(not authenticated and application.zcore.user.checkGroupAccess("user") ) {
			inquiriesCom = createObject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries' );
			inquiriesCom.userInit();
		}
	}
	if(not authenticated){
		application.zcore.functions.zRedirect("/z/user/preference/index?redirectOnLogin=#urlencodedformat("/z/inquiries/download-attachment/index?fileId=#form.field#")#");
	}


	if ( inquiries_feedback.inquiries_feedback_message_json EQ '' ) {
		application.zcore.functions.z404( 'Inquiry feedback has no json so there are no file attachments to download.' );
	}

	var feedbackMessage = deserializeJSON( inquiries_feedback.inquiries_feedback_message_json );
	var totalFiles = arrayLen( feedbackMessage.files );

	if ( totalFiles EQ 0 ) {
		application.zcore.functions.z404( 'No files to download' );
	}

	if ( parsedFileId.fileIndex GT totalFiles ) {
		application.zcore.functions.z404( 'Invalid file ID' );
	}

	if ( NOT arrayIndexExists( feedbackMessage.files, parsedFileId.fileIndex ) ) {
		application.zcore.functions.z404( 'Invalid file ID' );
	}

	var theFile = feedbackMessage.files[ parsedFileId.fileIndex ]; 
	application.zcore.functions.zheader( 'Content-Disposition', 'attachment; filename=' & replace( theFile.fileName, ",", " ", "all" ) );

	application.zcore.functions.zXSendFile( "/zuploadsecure/email-attachments/" & theFile.filePath ); 
	</cfscript>
</cffunction>

<cffunction name="parseFileId" localmode="modern" access="private">
	<cfargument name="theFileId" type="string" required="yes">
	<cfscript> 
	var fileIdParts = listToArray( arguments.theFileId, '.' );

	if(arraylen(fileIdParts) EQ 2){
		parsedFileId={
			inquiries_feedback_id:fileIdParts[1],
			fileIndex:fileIdParts[2],
			inquiries_feedback_download_key:"",
		}
	}else if(arraylen(fileIdParts) EQ 3){
		parsedFileId={
			inquiries_feedback_id:fileIdParts[1],
			fileIndex:fileIdParts[2],
			inquiries_feedback_download_key:fileIdParts[3],
		}
	}else{
		application.zcore.functions.z404("Invalid fileId: #arguments.theFileId#");
	}

	return parsedFileId;
	</cfscript>
</cffunction> 
</cfoutput>
</cfcomponent>
