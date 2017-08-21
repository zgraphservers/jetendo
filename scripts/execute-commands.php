<?php
require("library.php");
set_time_limit(70);
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}

$debug=false; // never go live with this true, since it prevents multi-process execution.
$timeout=60; // seconds
$timeStart=microtimeFloat();
$completePath=get_cfg_var("jetendo_root_path")."execute/complete/";
$startPath=get_cfg_var("jetendo_root_path")."execute/start/";

//$processorCount=`/bin/cat /proc/cpuinfo | /bin/grep processor | /usr/bin/wc -l`;

$runningThreads=0;

$script='/usr/bin/php "'.get_cfg_var("jetendo_scripts_path").'execute-commands-process.php" ';
if($debug && !zIsTestServer()){
	$background=' 2>&1 ';
}else{
	$background=" > /dev/null 2>/dev/null &";
}
$arrEntry=array();
while(true){
	$handle=opendir($startPath);
	if($handle){
		while (false !== ($entry = readdir($handle))) {
			if(array_key_exists($entry, $arrEntry)){
				continue;
			}
			if(substr($entry, strlen($entry)-4, 4) !=".txt"){
				continue;
			}
			$phpCmd=$script.escapeshellarg($entry).$background;
			if($debug){
				$c=file_get_contents($startPath.$entry);
				echo($script." $'".str_replace("\t", "\\t", $c)."' 'debug'\n\n"); 
			}
			echo `$phpCmd`;
			$arrEntry[$entry]=true;
		}
		closedir($handle);
	}
	usleep(30000); // wait 30 milliseconds

	if(microtimeFloat() - $timeStart > $timeout){
		echo "Timeout reached";
		exit;
	}
}
?>