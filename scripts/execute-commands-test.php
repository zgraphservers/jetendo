<?php
// note all \t must be replaced with \\t before running command
// php execute-commands-test.php $'command'
$startPath=get_cfg_var("jetendo_root_path")."execute/start/";
$startFile=$startPath."test.txt";
file_put_contents($startFile, str_replace("\\t", "\t", $argv[1])); 
var_dump(explode("\t", file_get_contents($startFile)) );
$argv[2]="debug";
require("execute-commands-process.php");
exit;
?>