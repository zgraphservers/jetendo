<?php
# schedule this script to run every 1 minute all day on the production server only

$failcount=0;
$httpddown=false;
for($i=1;$i <= 4;$i++){
	$ch = curl_init(); 
	// note this is privatelinux on live server, not the ip
	curl_setopt($ch, CURLOPT_URL, get_cfg_var('jetendo_company_domain').'/z/misc/system/index'); 
	if(strpos(get_cfg_var('jetendo_company_domain'), 'https:') === FALSE){
		curl_setopt ($ch, CURLOPT_PORT , 80);
	}else{
		curl_setopt ($ch, CURLOPT_PORT , 443);
	}
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch,CURLOPT_CONNECTTIMEOUT_MS,5000); 
	$response = curl_exec($ch); 
	curl_close($ch);
	if($response=== FALSE){
		curl_setopt($ch, CURLOPT_URL, get_cfg_var('jetendo_company_domain')); 
		if(strpos(get_cfg_var('jetendo_company_domain'), 'https:') === FALSE){
			curl_setopt ($ch, CURLOPT_PORT , 80);
		}else{
			curl_setopt ($ch, CURLOPT_PORT , 443);
		}
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch,CURLOPT_CONNECTTIMEOUT_MS,2000); 
		$response2 = curl_exec($ch); 
		curl_close($ch);
		if($response2 === FALSE){
			// httpd didn't respond
			$httpddown=true;
		}
		$failcount++;
		$host=`hostname`;
		if($failcount==4){
			if($httpddown){
				$eBody="The monitoring script detected a httpd crash/hang condition and restarted the httpd process.";
				$r=shell_exec('service nginx reload');
				echo $r."\n";
				//my
				mail(get_cfg_var("jetendo_developer_email_to"),"HTTPD auto-restarted on live server at ".$host, $eBody, "From: <".get_cfg_var("jetendo_developer_email_from").">\nReply-To: \"Error\" <".get_cfg_var("jetendo_developer_email_from").">\nX-Mailer: php" );
			}else{
				$eBody="The monitoring script detected a cfml server crash/hang condition and restarted the cfml process.";
				if(file_exists("/etc/init.d/railo_ctl")){
					$r=shell_exec('service railo_ctl restart');
				}else{
					$r=shell_exec('service lucee_ctl restart');
				}
				echo $r."\n";
				//my
				mail(get_cfg_var("jetendo_developer_email_to"),"CFML Application Server auto-restarted on live server at ".$host, $eBody, "From: <".get_cfg_var("jetendo_developer_email_from").">\nReply-To: \"Error\" <".get_cfg_var("jetendo_developer_email_from").">\nX-Mailer: php" );
			}
		}
		echo 'Request '.$i.' failed.'."\n";
	}else{
		// go silent until it fails
		echo 'Request '.$i.' was successful.'."\n";
	}
	usleep(20000000);
}
?>