<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>

	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
		this.init();
		var db = request.zos.queryObject;

		// application.zcore.user.requireLogin("administrator");

		var fileId = application.zcore.functions.zso( form, 'fileId' );
		var parsedFileId = this.parseFileId( fileId );

		// Get inquiries feedback from database
		var inquiriesFeedbackCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.feedback' );
		var inquiries_feedback = inquiriesFeedbackCom.getInquiriesFeedbackById( parsedFileId.inquiries_feedback_id );

		form.inquiries_id = inquiries_feedback.inquiries_id;

		// Get inquiries from database
		var inquiriesFunctionsCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.com.app.inquiriesFunctions' );
		var inquiry = inquiriesFunctionsCom.getInquiryDataById( inquiries_feedback.inquiries_id );

		// TODO: login stuff for bruce to discover - we want them to see a login for the manager?

		if ( application.zcore.user.checkGroupAccess("agent") ) {

		} else if ( application.zcore.user.checkGroupAccess("user") ) {
			inquiriesCom = createObject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries' );
			inquiriesCom.userInit();
		}




		if ( inquiries_feedback.inquiries_feedback_message_json EQ '' ) {
			application.zcore.functions.z404( 'Inquiry feedback has no json' );
		}

		var feedbackMessage = deserializeJSON( inquiries_feedback.inquiries_feedback_message_json );
		var totalFiles = arrayLen( feedbackMessage.files );

		if ( totalFiles EQ 0 ) {
			application.zcore.functions.z404( 'No files to download' );
		}

		if ( parsedFileId.file_id GT totalFiles ) {
			application.zcore.functions.z404( 'Invalid file ID' );
		}

		if ( NOT arrayIndexExists( feedbackMessage.files, parsedFileId.file_id ) ) {
			application.zcore.functions.z404( 'Invalid file ID' );
		}

		var theFile = feedbackMessage.files[ parsedFileId.file_id ];


		// header name="Content-Disposition"  value="attachment;filename=#Replace(replace(theFilefileName, ",", " ", "all"), " ",  "_", "all")#";
		// content deleteFile="yes" file="#tempZipPath#" type="application/x-zip-compressed";

		application.zcore.functions.zheader( 'Content-Disposition', 'attachment; filename=' & replace( theFile.fileName, ",", " ", "all" ) );

		application.zcore.functions.zXSendFile( "/zuploadsecure/email-attachments/" & theFile.filePath );

		// "/zuploadsecure/email-attachments/" & theFile.filePath;

		// writedump( theFile );
		abort;


		var site_enable_insecure_lead_file_downloads = true;

		if ( site_enable_insecure_lead_file_downloads ) {
			this.downloadInsecureFile();
		} else {
			// Do authentication here.
			throw( 'Not implemented yet' );
			// this.downloadSecureFile();
		}


/*

	inquiries_feedback_id

	must be logged in
	based on office id being set and matching
		- office id 1

	files stored in
		"/zuploadsecure/email-attachments/"
*/


		abort;		
	</cfscript>
</cffunction>

<cffunction name="parseFileId" localmode="modern" access="private">
	<cfargument name="theFileId" type="string" required="yes">
	<cfscript>
		// ?fileId={office_id}.{inquiries_feedback_id}.{file_id}
		var fileIdParts = listToArray( arguments.theFileId, '.' );

		var parsedFileId = {
			office_id: fileIdParts[ 1 ],
			inquiries_feedback_id: fileIdParts[ 2 ],
			file_id: fileIdParts[ 3 ]
		};

		if ( NOT isNumeric( parsedFileId.office_id ) ) {
			throw( 'Invalid office ID' );
		}

		if ( NOT isNumeric( parsedFileId.inquiries_feedback_id ) ) {
			throw( 'Invalid inquiries feedback ID' );
		}

		if ( NOT isNumeric( parsedFileId.file_id ) ) {
			throw( 'Invalid file ID' );
		}

		return parsedFileId;
	</cfscript>
</cffunction>

<cffunction name="downloadSecureFile" localmode="modern" access="private">
	<cfscript>
		var messageId = application.zcore.functions.zso( form, 'messageId' );
		var fileId    = application.zcore.functions.zso( form, 'fileId' );
	</cfscript>
</cffunction>

<cffunction name="downloadInsecureFile" localmode="modern" access="private">
	<cfscript>
		var messageId = application.zcore.functions.zso( form, 'messageId' );
		var fileId    = application.zcore.functions.zso( form, 'fileId' );
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
