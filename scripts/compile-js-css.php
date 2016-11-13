<?php 
function compileAllPackages(){
	$rootPath=get_cfg_var('jetendo_root_path');
	$jsPath=$rootPath."public/javascript/";
	
	$a=glob($jsPath."jetendo/*");
	// everything
	//array_push($a, $jsPath.'jquery/balupton-history/scripts/uncompressed/json2.js');
	$isCompiled=compileJS($a, "jetendo-no-listing.js");
	if(!$isCompiled){
		return false;
	}
	
	// no listing
	$arrListing=glob($jsPath."jetendo-listing/*");
	$a=array_merge($a, $arrListing);
	$isCompiled=compileJS($a, "jetendo.js");
	if(!$isCompiled){
		return false;
	}
	return true;
}
function compileJS($arrFiles, $outputFileName){
	// manually list the files we want to compress
	$rootPath=get_cfg_var("jetendo_root_path");
	$sourcePath=$rootPath."public/javascript/";
	$compilePath=$rootPath."public/javascript-compiled/";
	$arrLog=array("compileJS started at ".date('l jS \of F Y h:i:s A'));
	
	$versionString="/zv".date("YmdHis")."/";

	$arrMD5=array();
	$logDir=get_cfg_var("jetendo_log_path");
	$jsMD5Path=$logDir."deploy/compile-md5-".$outputFileName.".txt";
	if(file_exists($jsMD5Path)){
		$oldMD5Hash=md5_file($jsMD5Path);
	}else{
		$oldMD5Hash="";
	}
	$arrCompile=array();
	$arrNewFile=array();
	for($i=0;$i<count($arrFiles);$i++){
		$currentSourcePath=$arrFiles[$i];
		array_push($arrCompile, escapeshellarg($currentSourcePath));
		array_push($arrNewFile, $currentSourcePath."\t".md5_file($currentSourcePath));
	}
	$fp=fopen($jsMD5Path, "w");
	fwrite($fp, implode("\n", $arrNewFile));
	fclose($fp);
	if(count($arrCompile)){
		if(md5_file($jsMD5Path) != $oldMD5Hash){
			if(file_exists($compilePath.$outputFileName)){
				$oldMd5=md5_file($compilePath.$outputFileName);
				unlink($compilePath.$outputFileName);
			}else{
				$oldMd5="";
			}
			$cmd="java -jar ".$rootPath."scripts/closure-compiler.jar  --js ".implode(" --js ", $arrCompile)." --create_source_map ".$compilePath.$outputFileName.".map --source_map_format=V3 --js_output_file ".$compilePath.$outputFileName." 2>&1";
			array_push($arrLog, $cmd."\n");
			echo $cmd."\n\n";
			$r=`$cmd`;
			array_push($arrLog, $r."\n\n");
			if(!file_exists($compilePath.$outputFileName)){
				array_push($arrLog, "Compilation failed and requires manual corrections to the javascript.");
				unlink($jsMD5Path);
				return false;
			}else{
				file_put_contents($compilePath.$outputFileName, $data="//# sourceMappingURL=".$outputFileName.".map\n".str_replace("/zv/", $versionString, file_get_contents($compilePath.$outputFileName)));
				file_put_contents($compilePath.$outputFileName.".map", str_replace($rootPath."public/", "/z/", str_replace("/zv/", $versionString, file_get_contents($compilePath.$outputFileName.".map"))));
			}

			$arrOutput=array();
			for($i=0;$i<count($arrCompile);$i++){
				$c=substr($arrCompile[$i], 1, strlen($arrCompile[$i])-2);
				$n=file_get_contents($c);
				array_push($arrOutput, "\n/* ".$c." */\n".$n);
			}
			$uncompressedPath=$compilePath.str_replace(".js", ".combined.js", $outputFileName);
			file_put_contents($uncompressedPath, implode("\n", $arrOutput));
		}
	}
	$fp=fopen(get_cfg_var("jetendo_log_path")."deploy/compile-js-css-log.txt", "a");
	fwrite($fp, implode("\n", $arrLog)."\n");
	fclose($fp);
	return true;
}
?>