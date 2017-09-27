<?php 
// usage - run this via command line only:
// php /var/jetendo-server/jetendo/scripts/email/imap.php > /var/jetendo-server/custom-secure-scripts/imap-images/email-result.html
require("/var/jetendo-server/jetendo/scripts/library.php"); 
require("zMailClient.php"); 
require("zProcessIMAP.php"); 
// no longer needed:
//require("/var/jetendo-server/custom-secure-scripts/email-config.php");

// schedule as cron that runs for 5 minutes at most.
// this number is set higher in case a download takes slightly longer.
set_time_limit(350);

// TODO: if an imap account check fails, continue to the next account instead of hard failure.
 
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
} 
$myProcessImap=new zProcessIMAP();
$myProcessImap->process();

//echo("\nDone");
?> 
