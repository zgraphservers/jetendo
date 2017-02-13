<?php
// this should be a cronjob that runs once a day or week or whenever
// php /var/jetendo-server/jetendo/scripts/geoip/geoip-import.php
require(get_cfg_var("jetendo_scripts_path")."library.php");
set_time_limit(5000);
$mysqlUser=get_cfg_var("jetendo_mysql_default_username");
$mysqlPass=get_cfg_var("jetendo_mysql_default_password");

$mysqlDatabase="task";
// jetendo_mysql_default_host
$path=get_cfg_var("jetendo_share_path")."geoip-data/";
if(!is_dir($path)){	
	mkdir($path, 0700);
}
chdir($path);

$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), "task"); // zGetDatasource() 

echo "Drop geoip_block_safe\n";
$sql="DROP TABLE IF EXISTS `geoip_block_safe` ";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

echo "Drop geoip_location_safe\n";
$sql="DROP TABLE IF EXISTS `geoip_location_safe` ";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);  
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE IF NOT EXISTS `geoip_block` (
  `geoip_block_network_cidr` varchar(32) NOT NULL DEFAULT '',
  `geoip_location_id` int(11) DEFAULT NULL,
  `geoip_block_registered_country_geoname_id` int(11) DEFAULT NULL,
  `geoip_block_represented_country_geoname_id` int(11) DEFAULT NULL,
  `geoip_block_is_anonymous_proxy` varchar(1) DEFAULT '0',
  `geoip_block_is_satellite_provider` varchar(1) DEFAULT '0',
  `geoip_block_postal_code` varchar(45) DEFAULT NULL,
  `geoip_block_latitude` float DEFAULT NULL,
  `geoip_block_longitude` float DEFAULT NULL,
  `geoip_block_network` int(10) unsigned DEFAULT NULL,
  `geoip_block_broadcast` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`geoip_block_network_cidr`),
  KEY `newindex1` (`geoip_block_network`,`geoip_block_broadcast`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
echo "Create geoip_block\n";
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE IF NOT EXISTS `geoip_location` (
  `geoip_location_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_location_locale_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_name` varchar(2) DEFAULT NULL,
  `geoip_location_country_iso_code` varchar(2) DEFAULT NULL,
  `geoip_location_country_name` varchar(45) DEFAULT NULL,
  `geoip_location_subdivision_1_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_1_name` varchar(1000) DEFAULT NULL,
  `geoip_location_subdivision_2_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_2_name` varchar(1000) DEFAULT NULL,
  `geoip_location_city_name` varchar(1000) DEFAULT NULL,
  `geoip_location_metro_code` int(11) DEFAULT NULL,
  `geoip_location_postalCode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`geoip_location_id`),
  KEY `geoip_location_city_name` (`geoip_location_city_name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
echo "Create geoip_location\n";
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE `geoip_block_safe` (
  `geoip_block_network_cidr` varchar(32) NOT NULL DEFAULT '',
  `geoip_location_id` int(11) DEFAULT NULL,
  `geoip_block_registered_country_geoname_id` int(11) DEFAULT NULL,
  `geoip_block_represented_country_geoname_id` int(11) DEFAULT NULL,
  `geoip_block_is_anonymous_proxy` varchar(1) DEFAULT '0',
  `geoip_block_is_satellite_provider` varchar(1) DEFAULT '0',
  `geoip_block_postal_code` varchar(45) DEFAULT NULL,
  `geoip_block_latitude` float DEFAULT NULL,
  `geoip_block_longitude` float DEFAULT NULL,
  `geoip_block_network` int(10) unsigned DEFAULT NULL,
  `geoip_block_broadcast` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`geoip_block_network_cidr`),
  KEY `newindex1` (`geoip_block_network`,`geoip_block_broadcast`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE `geoip_location_safe` (
  `geoip_location_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_location_locale_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_name` varchar(2) DEFAULT NULL,
  `geoip_location_country_iso_code` varchar(2) DEFAULT NULL,
  `geoip_location_country_name` varchar(45) DEFAULT NULL,
  `geoip_location_subdivision_1_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_1_name` varchar(1000) DEFAULT NULL,
  `geoip_location_subdivision_2_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_2_name` varchar(1000) DEFAULT NULL,
  `geoip_location_city_name` varchar(1000) DEFAULT NULL,
  `geoip_location_metro_code` int(11) DEFAULT NULL,
  `geoip_location_postalCode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`geoip_location_id`),
  KEY `geoip_location_city_name` (`geoip_location_city_name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
		zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
} 
echo "Download Zip\n";
$zipPath=$path."GeoLite2-City-CSV.zip";
@unlink($zipPath);
$cmd="wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip -O ".$zipPath;
`$cmd`;
if(!file_exists($zipPath)){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed to download zip: ".$zipPath);
}

echo "Process Zip\n";
`unzip -jo GeoLite2-City-CSV.zip`;
@unlink($path."geoip_block.csv");
@unlink($path."geoip_location.csv");
`rm GeoLite2-City-CSV.zip`;
`mv GeoLite2-City-Locations-en.csv geoip_location.csv`;
`mv GeoLite2-City-Blocks-IPv4.csv geoip_block.csv`;
if(!file_exists($path."geoip_location.csv")){
	zEmailErrorAndExit("GeoIP Import Failed", "geoip location csv missing");
}
if(!file_exists($path."geoip_block.csv")){
	zEmailErrorAndExit("GeoIP Import Failed", "geoip block csv missing");
} 
chmod($path, 0777);
chmod($path."geoip_block.csv", 0777);
chmod($path."geoip_location.csv", 0777);

echo "Load geoip_block_safe\n";
$sql="LOAD DATA INFILE '".$path."geoip_block.csv'  INTO TABLE geoip_block_safe   FIELDS    TERMINATED BY ','  OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\\\\'	IGNORE 2 LINES";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

echo "Load geoip_location_safe\n";
$sql="LOAD DATA INFILE '".$path."geoip_location.csv'  INTO TABLE geoip_location_safe FIELDS    TERMINATED BY ','  OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\\\\'	IGNORE 2 LINES";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

echo "Process blocks\n";
$sql="update geoip_block_safe set 
geoip_block_broadcast = (INET_ATON(substring_index(geoip_block_network_cidr, '/', 1)) + (pow(2, (32-substr(geoip_block_network_cidr, instr(geoip_block_network_cidr, '/')+1)))-1)), 
geoip_block_network = inet_aton(substring_index(geoip_block_network_cidr, '/', 1))";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

echo "Swap geoip tables\n";
$sql="RENAME TABLE `geoip_location_safe` to `geoip_location_temp`, `geoip_location` to `geoip_location_safe`, `geoip_location_temp` to `geoip_location`,  `geoip_block_safe` to `geoip_block_temp`, `geoip_block` to `geoip_block_safe`, `geoip_block_temp` to `geoip_block` ";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}
		
echo('done');exit;
/*

$ip='50.88.30.86';
//$ip2='205.251.199.158';

// this query is up to 10 times faster then the single index version
$cmd='SELECT SQL_NO_CACHE  
 geoip_location.geoip_location_country_name,
 geoip_location.geoip_location_city_name,
 geoip_block.geoip_block_latitude,
 geoip_block.geoip_block_longitude 
FROM geoip_block FORCE INDEX(newindex1), geoip_location  
where geoip_block.geoip_block_id = geoip_location.geoip_block_id 
AND inet_aton('.$cmysql->real_escape_string($ip).') >= geoip_block_network
AND inet_aton('.$cmysql->real_escape_string($ip).') <= geoip_block_broadcast';

*/

?>
