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



// TODO: must store images in site specific locations
$filePath="/var/jetendo-server/custom-secure-scripts/imap-images/";

set_time_limit(120);
$timeout=55; // seconds
$timeStart=microtimeFloat();

$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), get_cfg_var("jetendo_datasource")); 

$r=$cmysql->query("select * from site, imap_account WHERE 
	site.site_id = imap_account.site_id and 
	site.site_active=1 and 
	site_deleted=0 and 
	imap_account_deleted=0", MYSQLI_STORE_RESULT);
if($cmysql->error != ""){ 
	zEmailErrorAndExit("Check IMAP DB Error", "fatal db error:".$cmysql->error."\n"); 
}
$sitesWritablePath=get_cfg_var("jetendo_sites_writable_path");

$arrAccount=array();
$testDomain=get_cfg_var("jetendo_test_domain"); 
while($account=$r->fetch_array(MYSQLI_ASSOC)){
	$thedomainpath=str_replace("www.", "", str_replace(".".$testDomain, "", $account->site_short_domain));
	$sitePath=$sitesWritablePath.str_replace(".","_",$thedomainpath)."/zuploadsecure/email-attachments/";
	if(!is_dir($sitePath)){
		mkdir($sitePath, 0770);
	}
	$myMail=new zMailClient();
	$myMail->setFilePath($sitePath);

	$ssl=false;
	if($account["imap_account_ssl"] == "1"){
		$ssl=true;
	}
	$host=$account["imap_account_host"]; 
	$user=$account["imap_account_user"];
	$pass=$account["imap_account_pass"];
	$port=$account["imap_account_port"];
	$folder="INBOX";
	$readonly=true;
	$connected=$myMail->login($host,$port,$user,$pass,$folder, $ssl, $readonly);  
	if(!$connected){
		$myMail->showError("Failed to connect");
	}

	// 6 is html only
	// 5 is plain + file
	// 4 is multiple embedded images + multiple attached + html + plain
	// 3 is plain only
	// 2 is html + plain text
	// 1 is html + plain in different place
	// 0 is html + plain text

	// if you call this with nothing, it will pull all of the emails starting from one.  
	// need a way to call with only the newer messages, i.e. start index
	/*$arrMessage=$myMail->listMessagesSinceMessage(2);
	var_dump($arrMessage);
	exit;*/
	$arrMessage=$myMail->listMessages(4); // TODO: delete number when done    // test 4 which has no attachments.  and test plain text only email and html only email
	foreach($arrMessage as $msgId=>$msg){ 
		// queue message to be downloaded individually in queue_pop table
		echo('<h2>Downloading email #'.$msgId.' parsed plus address:'.$msg['plusId'].'</h2>');
		$message=$myMail->getFullMessage($msgId);  
		echo(json_encode($message,  JSON_FORCE_OBJECT | JSON_PRETTY_PRINT));
		exit;
  
		$subject="";
		if(isset($message["headers"]["parsed"]["Subject"])){
			$subject=$message["headers"]["parsed"]["Subject"];
		}
		/*
		// TODO need function to parse: Name <email>

		// need to add FROM/TO/CC/BCC as parsed arrays to the JSON object
		$to=array();
		
		array_push($to, array(
			name=>"First Last",
			email=>"someone@somewhere.com"
		));
		*/

		if(!isset($message['plusId'])){
			$message['plusId']='';
		}
		if(!isset($message['html'])){
			$message['html']='';
		}
		if(!isset($message['text'])){
			$message['text']='';
		}
		if(!isset($message['headers'])){
			$message['headers']='';
		}
		if(!isset($message['html'])){
			$message['html']='';
		}
		if(!isset($message['text'])){
			$message['text']='';
		}

		$arrFile=array();
		foreach($message['attachments'] as $key=>$file){
            $tempFile=array(
            	"size"=>$file["size"], //: 292427,
	            "filePath"=>$file["path"], // "\/var\/jetendo-server\/custom-secure-scripts\/imap-images\/cbenckacbifelmnn1.png",
            	"fileName"=> $file["name"]
            ); 
			array_push($arrFile, $tempFile);
		}
		var_dump($message);exit; 
		$arrData=array( 
			"headers" => $message["headers"],
			"subject" => $subject,
			"html" => $message['html'],
			"text" => $message['text'],
			"files" => $arrFile,
			"size" => $emailSize
		);
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

		json_encode($arrData, JSON_FORCE_OBJECT | JSON_PRETTY_PRINT);

/*

queue_pop_file_json=[{
	originalFileName:'originalFileName.jpg',
	filePath:'relative/path/to/hashedFileName.jpg',
	size:'1230',
},
...other files
]

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
queue_pop_file_json='".$cmysql->real_escape_string().',
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
