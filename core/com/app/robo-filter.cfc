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

		var messageJSON = '{
    "headers": {
        "raw": "Delivered-To: zgraphportal+id.id2@gmail.com\r\nReceived: by 10.36.238.202 with SMTP id b193csp613483iti; Sun, 18 Sep 2016\r\n 11:19:10 -0700 (PDT)\r\nX-Received: by 10.55.139.196 with SMTP id n187mr16198489qkd.300.1474222750187;\r\n Sun, 18 Sep 2016 11:19:10 -0700 (PDT)\r\nReturn-Path: <bruce.kirkpatrick@zgraph.com>\r\nReceived: from smtp64.iad3a.emailsrvr.com (smtp64.iad3a.emailsrvr.com.\r\n [173.203.187.64]) by mx.google.com with ESMTPS id\r\n m9si13053871qki.316.2016.09.18.11.19.09 for <zgraphportal+id.id2@gmail.com>\r\n (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128\/128); Sun, 18 Sep\r\n 2016 11:19:10 -0700 (PDT)\r\nReceived-SPF: pass (google.com: domain of bruce.kirkpatrick@zgraph.com\r\n designates 173.203.187.64 as permitted sender) client-ip=173.203.187.64;\r\nAuthentication-Results: mx.google.com; spf=pass (google.com: domain of\r\n bruce.kirkpatrick@zgraph.com designates 173.203.187.64 as permitted sender)\r\n smtp.mailfrom=bruce.kirkpatrick@zgraph.com\r\nReceived: from smtp1.relay.iad3a.emailsrvr.com (localhost [127.0.0.1]) by\r\n smtp1.relay.iad3a.emailsrvr.com (SMTP Server) with ESMTP id C1823C01AF for\r\n <zgraphportal+id.id2@gmail.com>; Sun, 18 Sep 2016 14:19:09 -0400 (EDT)\r\nX-Auth-ID: bruce.kirkpatrick@zgraph.com\r\nReceived: by smtp1.relay.iad3a.emailsrvr.com (Authenticated sender:\r\n bruce.kirkpatrick-AT-zgraph.com) with ESMTPSA id 332C1C020E for\r\n <zgraphportal+id.id2@gmail.com>; Sun, 18 Sep 2016 14:19:09 -0400 (EDT)\r\nX-Sender-Id: bruce.kirkpatrick@zgraph.com\r\nReceived: from [192.168.1.224] (50-88-30-86.res.bhn.net [50.88.30.86]) (using\r\n TLSv1.2 with cipher DHE-RSA-AES128-SHA) by 0.0.0.0:465 (trex\/5.7.7); Sun, 18\r\n Sep 2016 14:19:09 -0400\r\nTo: zgraphportal+id.id2@gmail.com\r\nFrom: Bruce Kirkpatrick <bruce.kirkpatrick@zgraph.com>\r\nSubject: multiple attached\r\nMessage-ID: <3f89b0f7-c8d6-7ea4-4063-86124aa19310@zgraph.com>\r\nDate: Sun, 18 Sep 2016 14:19:07 -0400\r\nUser-Agent: Mozilla\/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko\/20100101\r\n Thunderbird\/45.2.0\r\nMIME-Version: 1.0\r\nContent-Type: multipart\/mixed; boundary=\"------------6C80C668334E1813CB180BD3\"\r\n\r\n",
        "parsed": {
            "Delivered-To": "zgraphportal+id.id2@gmail.com",
            "Received": "from [192.168.1.224] (50-88-30-86.res.bhn.net [50.88.30.86]) (usingTLSv1.2 with cipher DHE-RSA-AES128-SHA) by 0.0.0.0:465 (trex\/5.7.7); Sun, 18Sep 2016 14:19:09 -0400",
            "X-Received": "by 10.55.139.196 with SMTP id n187mr16198489qkd.300.1474222750187;Sun, 18 Sep 2016 11:19:10 -0700 (PDT)",
            "Return-Path": "<bruce.kirkpatrick@zgraph.com>",
            "Received-SPF": "pass (google.com: domain of bruce.kirkpatrick@zgraph.comdesignates 173.203.187.64 as permitted sender) client-ip=173.203.187.64;",
            "Authentication-Results": "mx.google.com; spf=pass (google.com: domain ofbruce.kirkpatrick@zgraph.com designates 173.203.187.64 as permitted sender)smtp.mailfrom=bruce.kirkpatrick@zgraph.com",
            "X-Auth-ID": "bruce.kirkpatrick@zgraph.com",
            "X-Sender-Id": "bruce.kirkpatrick@zgraph.com",
            "To": "zgraphportal+id.id2@gmail.com",
            "From": "Bruce Kirkpatrick <bruce.kirkpatrick@zgraph.com>",
            "Subject": "multiple attached",
            "Message-ID": "<3f89b0f7-c8d6-7ea4-4063-86124aa19310@zgraph.com>",
            "Date": "Sun, 18 Sep 2016 14:19:07 -0400",
            "User-Agent": "Mozilla\/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko\/20100101Thunderbird\/45.2.0",
            "MIME-Version": "1.0"
        }
    },
    "from": {
        "name": "Bruce Kirkpatrick",
        "email": "bruce.kirkpatrick@zgraph.com"
    },
    "to": [
        {
            "name": "",
            "email": "zgraphportal@gmail.com",
            "plusId": "id.id2",
            "originalEmail": "zgraphportal+id.id2@gmail.com"
        }
    ],
    "cc": [],
    "subject": "multiple attached",
    "html": "<html>\r\n  <head>\r\n\r\n    <meta http-equiv=\"content-type\" content=\"text\/html; charset=utf-8\">\r\n  <\/head>\r\n  <body bgcolor=\"##FFFFFF\" text=\"##000000\">\r\n    <p>body with multiple<br>\r\n    <\/p>\r\n    <img src=\"cbenckacbifelmnn.png\" alt=\"\"><img\r\n      src=\"niajdghmmmgibill.jpg\" alt=\"\"><br>\r\n    <img src=\"jpanhdoniknnencp.jpg\" alt=\"\"><br>\r\n    <pre class=\"moz-signature\" cols=\"72\">-- \r\nBest Regards,\r\n\r\n------------\r\nBruce Kirkpatrick\r\n<a class=\"moz-txt-link-freetext\" href=\"http:\/\/www.zgraph.com\/\">http:\/\/www.zgraph.com\/<\/a>\r\n(386) 255-5556 (ext 109)\r\n(386) 206-8475 (direct)<\/pre>\r\n  <\/body>\r\n<\/html>\r\n",
    "text": "test",
    "files": [
        {
            "size": 292427,
            "filePath": "cbenckacbifelmnn1.png",
            "fileName": "cbenckacbifelmnn.png"
        },
        {
            "size": 2715,
            "filePath": "niajdghmmmgibill.jpg",
            "fileName": "niajdghmmmgibill.jpg"
        },
        {
            "size": 1363,
            "filePath": "jpanhdoniknnencp.jpg",
            "fileName": "jpanhdoniknnencp.jpg"
        },
        {
            "size": 3990,
            "filePath": "test.docx",
            "fileName": "test.docx"
        }
    ],
    "plusId": "id.id2",
    "size": 303237,
    "date": "2016-09-18 14:19:07"
}';

		var message = deserializeJSON( messageJSON );

		var isHumanReply = this.isHumanReply( message );

		writedump( isHumanReply );
		abort;
	</cfscript>
</cffunction>

<cffunction name="isHumanReply" localmode="modern" access="public">
	<cfargument name="message" type="struct" required="yes">
	<cfscript>
		var message = arguments.message;
		var rs = {
			isHumanReply: false,
			roboScore: 0,
			roboTriggers: [],
			humanScore: 0,
			humanTriggers: []
		};

		// Strip out line endings
		var tempMessageHTML = message.html;
		tempMessageHTML = replace( tempMessageHTML, chr(13), ' ', 'ALL' );
		tempMessageHTML = replace( tempMessageHTML, chr(10), ' ', 'ALL' );

		writedump( message );

		// Message contains certain headers - pretty much guarentees a non-human reply
		var headerRoboTriggers = [
			{ 'key': 'Auto-Submitted', 'value': '' },
			{ 'key': 'Auto-Submitted', 'value': 'auto-replied' },
			{ 'key': 'Precedence',     'value': 'bulk' },
			{ 'key': 'Precedence',     'value': 'list' },
			{ 'key': 'Precedence',     'value': 'junk' },
			{ 'key': 'Return-Path',    'value': '<>' },
			{ 'key': 'X-Autoreply',    'value': 'yes' },
		];
		var headerRoboTriggered = false;

		for ( headerRoboTrigger in headerRoboTriggers ) {
			if ( structKeyExists( message.headers.parsed, headerRoboTrigger.key ) ) {
				if ( message.headers.parsed[ headerRoboTrigger.key ] EQ headerRoboTrigger.value ) {
					arrayAppend( rs.roboTriggers, 'header found - key: "' & headerRoboTrigger.key & '" value: "' & headerRoboTrigger.value & '"' );
					headerRoboTriggered = true;
					rs.roboScore++;
				}
			}
		}

		if ( headerRoboTriggered ) {
			arrayAppend( rs.roboTriggers, 'at least one header was triggered - considered robo' );
			// Email headers can guarentee that it was robo.
			return rs;
		} else {
			// If the headers didn't robo trigger, likely it is more human reply.
			arrayAppend( rs.humanTriggers, 'headers check was ok' );
			rs.humanScore++;
		}

		// Message was sent a long time ago, just received it.
		var oldMessageDayThreshold = 365; // 1 year
		var days = dateDiff( 'd', message.date, request.zos.mysqlnow );

		if ( days GT oldMessageDayThreshold ) {
			arrayAppend( rs.roboTriggers, 'old message check failed (' & days & ' days of max ' & oldMessageDayThreshold & ')' );
			// return rs;
		} else {
			arrayAppend( rs.humanTriggers, 'old message check was ok (' & days & ' days of max ' & oldMessageDayThreshold & ')' );
			rs.humanScore++;
		}


		// Message was sent within a minute of our reply
			// Need to get our message they replied to
			// Test the send date of our message
			// Compare the send date of the reply message


		// Message contains a lot of HTML elements
/*
		var htmlCountThreshold = 20;
		var htmlCountThresholdRoboTriggered = false;

		var messageHtmlElements = REFindNoCase( '<([^>]*)>', tempMessageHTML );

		writedump( messageHtmlElements );
		abort;
*/

		// Message contains blacklisted words.
		var blacklistWordArray = [

		];
		var blacklistWordRoboTriggered = false;

		for ( blacklistWord in blacklistWordArray ) {
			if ( message.html CONTAINS blacklistWord ) {
				arrayAppend( rs.roboTriggers, 'blacklisted word found: ' & blacklistWord );
				blacklistWordRoboTriggered = true;
				rs.roboScore++;
			}
		}

		if ( NOT blacklistWordRoboTriggered ) {
			arrayAppend( rs.humanTriggers, 'blacklisted word check was ok' );
			rs.humanScore++;
		}


		// Message contains a lot of to recipients.
		var toCountThreshold = 5;
		var toCount = arrayLen( message.to );
		if ( toCount GTE toCountThreshold ) {
			arrayAppend( rs.roboTriggers, 'to recipients check failed (' & toCount & ' of max ' & toCountThreshold & ')' );
			rs.roboScore++;
		} else {
			arrayAppend( rs.humanTriggers, 'to recipients check was ok (' & toCount & ' of max ' & toCountThreshold & ')' );
			rs.humanScore++;
		}


		// Message contains a lot of CC recipients.
		var ccCountThreshold = 5;
		var ccCount = arrayLen( message.cc );
		if ( ccCount GTE ccCountThreshold ) {
			arrayAppend( rs.roboTriggers, 'cc recipients check failed (' & ccCount & ' of max ' & toCountThreshold & ')' );
			rs.roboScore++;
		} else {
			arrayAppend( rs.humanTriggers, 'cc recipients check was ok (' & ccCount & ' of max ' & toCountThreshold & ')' );
			rs.humanScore++;
		}


		// Message contains a lot of images (3 or more)
		var imageCountThreshold = 3;
		var imageCountThresholdRoboTriggered = false;

		var messageImages = listToArray( application.zcore.functions.zExtractImagesFromHTML( tempMessageHTML ), chr(9) );
		var totalMessageImages = arrayLen( messageImages );

		if ( totalMessageImages GTE imageCountThreshold ) {
			arrayAppend( rs.roboTriggers, 'image count check failed (' & totalMessageImages & ' of max ' & imageCountThreshold & ')' );
			imageCountThresholdRoboTriggered = true;
			rs.roboScore++;
		} else {
			arrayAppend( rs.humanTriggers, 'image count check ok (' & totalMessageImages & ' of max ' & imageCountThreshold & ')' );
			rs.humanScore++;
		}


		// Message contains a lot of links (3 or more)
		var linkCountThreshold = 3;
		var linkCountThresholdRoboTriggered = false;

		var messageLinks = listToArray( application.zcore.functions.zExtractLinksFromHTML( tempMessageHTML ), chr(9) );
		var totalMessageLinks = arrayLen( messageLinks );

		if ( totalMessageLinks GTE linkCountThreshold ) {
			arrayAppend( rs.roboTriggers, 'link count check failed (' & totalMessageLinks & ' of max ' & linkCountThreshold & ')' );
			linkCountThresholdRoboTriggered = true;
			rs.roboScore++;
		} else {
			arrayAppend( rs.humanTriggers, 'link count check ok (' & totalMessageLinks & ' of max ' & linkCountThreshold & ')' );
			rs.humanScore++;
		}


		// If we have both too many images and too many links, probably not human.
		if ( imageCountThresholdRoboTriggered && linkCountThresholdRoboTriggered ) {
			arrayAppend( rs.roboTriggers, 'image and link count check both failed' );
			return rs;
		}


		// Check if the subject line contains any of the following strings.
		var subjectRoboTriggers = [
			'Auto Response',
			'Auto Reply',
			'AutoReply',
			'MAILER-DAEMON',
			'Out of Office',
			'Undelivered',
			'Vacation'
		];
		var subjectRoboTriggered = false;

		for ( subjectRoboTrigger in subjectRoboTriggers ) {
			if ( message.subject CONTAINS subjectRoboTrigger ) {
				arrayAppend( rs.roboTriggers, 'subject - ' & subjectRoboTrigger );
				subjectRoboTriggered = true;
				rs.roboScore++;
			}
		}

		if ( NOT subjectRoboTriggered ) {
			arrayAppend( rs.humanTriggers, 'subject check ok' );
			rs.humanScore++;
		}





		echo( '<h1>rs.RoboScore</h1>' );
		writedump( rs.roboScore );
		writedump( rs.roboTriggers );
		echo( '<h1>rs.HumanScore</h1>' );
		writedump( rs.humanScore );
		writedump( rs.humanTriggers );
		abort;




		if ( rs.roboScore > 8 ) {
			// Might be robo-reply
			return rs;
		}

		rs.isHumanReply = true;

		return true;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
