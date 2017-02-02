<?php
// run this script via command line to debug the javascript compilation process.
// php test-compile-js.css.php
require("library.php");
require("compile-js-css.php");

$arrDebug=array();
$isCompiled=compileAllPackages($arrDebug);
echo $isCompiled;
echo('done\n');
var_dump($arrDebug);
exit;

$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
$sql="select * FROM site WHERE 
site_active='1' and 
site_id='23' and 
site_deleted='0'  ";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);


$arrNew=array();
$arrDebug=array();
while($row=$r->fetch_assoc()){
	compileSiteFiles($row, $arrDebug);
}

echo('done\n');
var_dump($arrDebug);

exit;
?>