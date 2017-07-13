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
$readonly=true;


$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), "jetendo_dev"); 

$sitesWritablePath=get_cfg_var("jetendo_sites_writable_path");

// loop for 55 seconds:
while(true){
	$connected=$myMail->login($host,$port,$user,$pass,$folder="INBOX", $ssl, $readonly); 
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

	// if you call this with nothing, it will pull all of the emails starting from one.  
	// need a way to call with only the newer messages, i.e. start index
	$arrMessage=$myMail->listMessagesSinceMessage(2);
	var_dump($arrMessage);
	exit;
	$arrMessage=$myMail->listMessages(7); // TODO: delete number when done    // test 4 which has no attachments.  and test plain text only email and html only email
	foreach($arrMessage as $msgId=>$msg){ 
		// queue message to be downloaded individually in queue_pop table
		echo('<h2>Downloading email #'.$msgId.' parsed plus address:'.$msg['plusId'].'</h2>');
		$message=$myMail->getFullMessage($msgId);  
		var_dump($message);
		var_dump($message);exit; 
		echo('<h2>Plain Text:</h2><pre>'.$message['text'].'</pre>'."<hr>");
		echo('<h2>HTML Text:</h2>'.$message['html']."<hr>"); 
		// TODO figure out why message 5 is missing word doc
		foreach($message['attachments'] as $key=>$val){
			echo('Attachment #'.$key.': '.$val['name']."<hr>");
		}
		// move files to zuploadsecure/email/ - size could grow too large
		// each site will have a subdomain at our mail routing domain?  or leverage the actual domain via SMTP with separate configuration for each client.
		// $sitesWritablePath

		// store message in queue_pop 

/*
// maybe a field for plus id, or part of a json object.

$site_id=1;
$sql="INSERT INTO queue_pop SET 
site_id='".$cmysql->real_escape_string($site_id).',
queue_pop_message_uid='".$cmysql->real_escape_string($msg['uid']).',
queue_pop_created_datetime='".$cmysql->real_escape_string(date('Y-m-d H:i:s')).',
queue_pop_updated_datetime='".$cmysql->real_escape_string(date('Y-m-d H:i:s')).',
queue_pop_last_run_datetime='".$cmysql->real_escape_string().',
queue_pop_header_data='".$cmysql->real_escape_string().',
queue_pop_subject='".$cmysql->real_escape_string($message['subject']).',
queue_pop_body_text='".$cmysql->real_escape_string($message['text']).',
queue_pop_body_html='".$cmysql->real_escape_string($message['html']).',
queue_pop_file_list='".$cmysql->real_escape_string().',
queue_pop_fail_count='".$cmysql->real_escape_string().',
queue_pop_response='".$cmysql->real_escape_string().',
queue_pop_deleted='".$cmysql->real_escape_string(0).' ';
$cmysql->query($sql, MYSQLI_STORE_RESULT);
*/
/* 
these don't make sense
queue_pop_return_p='".$cmysql->real_escape_string().',
queue_pop_timeout='".$cmysql->real_escape_string().',
queue_pop_retry_interval='".$cmysql->real_escape_string().',
*/

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
