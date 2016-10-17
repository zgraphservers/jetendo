<?php 
// usage - run this via command line only:
// php /var/jetendo-server/jetendo/scripts/email/imap.php > /var/jetendo-server/custom-secure-scripts/imap-images/email-result.html
require("/var/jetendo-server/jetendo/scripts/library.php"); 
require("zMailClient.php"); 
require("/var/jetendo-server/custom-secure-scripts/email-config.php");
 
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}
$filePath="/var/jetendo-server/custom-secure-scripts/imap-images/";
$myMail=new zMailClient();
$myMail->setFilePath($filePath);
set_time_limit(70);
$timeout=55; // seconds
$timeStart=microtimeFloat();

// loop for 55 seconds:
while(true){
	$connected=$myMail->login($host,$port,$user,$pass,$folder="INBOX", $ssl); 
	if(!$connected){
		$myMail->showError("Failed to connect");
	}

	// 7 is html only
	// 6 is plain + file
	// 5 is multiple embedded images + multiple attached + html + plain
	// 4 is plain only
	// 3 is html + plain text
	// 2 is html + plain in different place
	// 1 is html + plain text
	$arrMessage=$myMail->listMessages(7); // TODO: delete number when done    // test 4 which has no attachments.  and test plain text only email and html only email
	foreach($arrMessage as $msgId=>$msg){ 
		// queue message to be downloaded individually in queue_pop table
		echo('<h2>Downloading email #'.$msgId.' parsed plus address:'.$msg['plusId'].'</h2>');
		$message=$myMail->getFullMessage($msgId);  
		//var_dump($message);exit; 
		echo('<h2>Plain Text:</h2><pre>'.$message['text'].'</pre>'."<hr>");
		echo('<h2>HTML Text:</h2>'.$message['html']."<hr>"); 
		// TODO figure out why message 5 is missing word doc
		foreach($message['attachments'] as $key=>$val){
			echo('Attachment #'.$key.': '.$val['name']."<hr>");
		}
		// move files to zuploadsecure/email/ - size could grow too large

		// store message in queue_pop


	}
	
	break; // for testing
	$myMail->close();
	sleep(10); // wait 10 seconds


	if(microtimeFloat() - $timeStart > $timeout){
		echo "Timeout reached";
		exit;
	}
}  
/*
exit;

set_time_limit(70);
$timeout=55; // seconds
$timeStart=microtimeFloat();
// loop to download messages in queue_pop sequentially until reaching 55 seconds.
while(true){
	$connected=$myMail->login($host,$port,$user,$pass,$folder="INBOX", $ssl); 
	if(!$connected){
		$myMail->showError("Failed to connect");
	}

	// route plus addressing to app. 
		// in app, if it matches data with a subscribe list attached
			// loop everyone in the subscribe list
				// queue the message to queue_email for each subscriber
		
	if(microtimeFloat() - $timeStart > $timeout){
		echo "Timeout reached";
		exit;
	}
} 

echo("\npop3_stat\n");
var_dump($myMail->stat()); 

exit;
*/
?> 
