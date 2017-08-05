<?php 
// usage - run this via command line only:
// php /var/jetendo-server/jetendo/scripts/email/imap.php > /var/jetendo-server/custom-secure-scripts/imap-images/email-result.html
require("/var/jetendo-server/jetendo/scripts/library.php"); 
require("zMailClient.php"); 
// no longer needed:
//require("/var/jetendo-server/custom-secure-scripts/email-config.php");
 
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
} 

function processEmailAddressList($list, $accountEmail){

	$arrList=explode(",", $list);
	$arrEmail=array();
	for($i=0;$i<count($arrList);$i++){
		$arrCurrentList=explode("<", $arrList[$i]);
		if(count($arrCurrentList) == 2){
			$arrEnd=explode(">", $arrCurrentList[1]);
			$temp=array(
				"name"=>trim($arrCurrentList[0]),
				"email"=>trim($arrEnd[0])
			));
		}else{ 
			$temp=array(
				"name"=>"",
				"email"=>trim($arrList[$i])
			));
		}
 
		$arrPart1=explode("@", $temp["email"]);
		if(count($arrPart1) <= 1){
			continue;
		}
		$arrPart2=explode("+", $arrPart1[0]);
		if(count($arrPart2)==2){
			$tempEmail=$arrPart2[0]."@".$arrPart1[1];
			if($tempEmail==$accountEmail){
				$temp["plusId"]=$arrPart2[1];
				$temp["originalEmail"]=$temp["email"];
				$temp["email"]=$tempEmail;
			}
		}
		array_push($arrEmail, $temp);
	}
	return $arrEmail;
}
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
	$thedomainpath=str_replace("www.", "", str_replace(".".$testDomain, "", $account["site_short_domain"]));
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
	$arrMessage=$myMail->listMessages(5); // TODO: delete number when done    // test 4 which has no attachments.  and test plain text only email and html only email
	foreach($arrMessage as $msgId=>$msg){ 
		// queue message to be downloaded individually in queue_pop table
		//echo('<h2>Downloading email #'.$msgId.' parsed plus address:'.$msg['plusId'].'</h2>');
		$message=$myMail->getFullMessage($msgId);  
		/*echo(json_encode($message,  JSON_FORCE_OBJECT | JSON_PRETTY_PRINT));
		echo("\n");
		echo($sitePath);
		exit;*/
  
		$subject="";
		if(isset($message["headers"]["parsed"]["Subject"])){
			$subject=$message["headers"]["parsed"]["Subject"];
		}  
		$from=array();
		$to=array();
		$cc=array();
		$bcc=array(); 
		if(isset($message["headers"]["parsed"]["From"])){
			$tempFrom=processEmailAddressList($message["headers"]["parsed"]["From"]);
			$from=$tempFrom[0];
		}
		if(isset($message["headers"]["parsed"]["To"])){
			$to=processEmailAddressList($message["headers"]["parsed"]["To"], $message, $account["imap_account_username"]);
		}
		if(isset($message["headers"]["parsed"]["Cc"])){
			$cc=processEmailAddressList($message["headers"]["parsed"]["Cc"]);
		}
		if(isset($message["headers"]["parsed"]["Bcc"])){
			$bcc=processEmailAddressList($message["headers"]["parsed"]["Bcc"]);
		}  

		$message['plusId']='';

		if(isset($message["headers"]["parsed"]["Delivered-To"])){
			$deliveredTo=processEmailAddressList($message["headers"]["parsed"]["Delivered-To"]);
			if(isset($deliveredTo["plusId"])){
				$message['plusId']=$deliveredTo["plusId"];
			}
		}
		if($message['plusId']==''){
			// find the plus id in the to address list instead.

			for($i=0;$i<count($to);$i++){
				// check for address to match 
				if(isset($to[$i]["plusId"])){
					if($to[$i]["email"] == $account["imap_account_username"]){
						// set plusId
						$message['plusId']=$to[$i]["plusId"];
						break;
					}
				}
			}
		}
		if($message['plusId']==''){
			// find the plus id in the cc address list instead.
			for($i=0;$i<count($cc);$i++){
				// check for address to match 
				if(isset($cc[$i]["plusId"])){
					if($cc[$i]["email"] == $account["imap_account_username"]){
						// set plusId
						$message['plusId']=$cc[$i]["plusId"];
						break;
					}
				}
			}
		}
		// if the plusId is still missing, then this email must have been sent directly to this email address without a plus id.


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
		$emailSize=0;
		foreach($message['attachments'] as $key=>$file){
			$emailSize+=$file["size"];
            $tempFile=array(
            	"size"=>$file["size"], //: 292427,
	            "filePath"=>$file["path"], // "\/var\/jetendo-server\/custom-secure-scripts\/imap-images\/cbenckacbifelmnn1.png",
            	"fileName"=> $file["name"]
            ); 
			array_push($arrFile, $tempFile);
		} 
		//var_dump($message);exit; 
		$dataObj=new stdClass();
		$dataObj->headers=$message["headers"];
		$dataObj->from=$from;
		$dataObj->to=$to;
		$dataObj->cc=$cc;
		$dataObj->bcc=$bcc;
		$dataObj->subject=$subject;
		$dataObj->html=$message['html'];
		$dataObj->text=$message['text'];
		$dataObj->files=$arrFile;
		
		$emailSize+=strlen($message["headers"]["raw"]);
		$emailSize+=strlen($dataObj->html);
		$emailSize+=strlen($dataObj->text);

		$dataObj->size=$emailSize;

		$messageJson=json_encode($dataObj,  JSON_PRETTY_PRINT); 
		echo($messageJson);		exit; 

		$sql="INSERT INTO queue_pop SET 
		site_id='".$cmysql->real_escape_string($account["site_id"])."',
		imap_account_id='".$cmysql->real_escape_string($account["imap_account_id"])."',
		queue_pop_message_uid='".$cmysql->real_escape_string($msg['uid'])."',
		queue_pop_created_datetime='".$cmysql->real_escape_string(date('Y-m-d H:i:s'))."',
		queue_pop_updated_datetime='".$cmysql->real_escape_string(date('Y-m-d H:i:s'))."',
		queue_pop_scheduled_processing_datetime='".$cmysql->real_escape_string(date('Y-m-d H:i:s'))."', 
		queue_pop_message_json='".$cmysql->real_escape_string($messageJson)."',
		queue_pop_process_fail_count='".$cmysql->real_escape_string(0)."',
		queue_pop_process_retry_interval_seconds='".$cmysql->real_escape_string(60)."',
		queue_pop_deleted='".$cmysql->real_escape_string(0);
		$cmysql->query($sql, MYSQLI_STORE_RESULT);

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
