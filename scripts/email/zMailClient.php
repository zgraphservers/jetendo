<?php
class zMailClient{
	var $connection;
	var $arrEmailParts;
	var $filePath;
	function login($host,$port,$user,$pass,$folder="INBOX",$ssl=false){  
		$this->arrEmailParts=explode("@", $user);
	
		/*
		if($ssl){
				$path="{"."$host:$port/pop3/ssl"."}$folder";
		}else{
				$path="{"."$host:$port/pop3"."}$folder"; 
		}
		*/
		if($ssl){
				$path="{"."$host:$port/imap/ssl"."}$folder";
		}else{
				$path="{"."$host:$port/imap"."}$folder"; 
		} 
		$this->connection=imap_open($path,$user,$pass); 
		if($this->connection===FALSE){
			$this->showError("imap_open failed");
		}
		return true;
	} 
	function stat(){ 
		$check = imap_mailboxmsginfo($this->connection); 
		if($check===FALSE){
			$this->showError("imap_mailboxmsginfo failed");
		}
		return ((array)$check); 
	} 
	function listMessages($message=""){ 
		if ($message){ 
			$range=$message; 
		}else{ 
			$MC = imap_check($this->connection); 
			if($MC===FALSE){
				$this->showError("imap_check failed");
			} 
			$range = "1:".$MC->Nmsgs; 
		} 
		$response = imap_fetch_overview($this->connection,$range); 
		if($response===FALSE){
			$this->showError("fetch_overview failed");
		} 
		$result=array();
		foreach ($response as $msg){
			$result[$msg->msgno]=array(
				'data'=>(array)$msg,
				'plusId'=>$this->getPlusId($msg->to)
			);
			
		}
		
		return $result;
	} 
	function getPlusId($email){
		$arrPlusParts=explode("+", $email);
		if(count($arrPlusParts) == 1){
				return "";
		}
		$arrPlus=explode("@", $arrPlusParts[1]);
		if($arrPlus[1]==$this->arrEmailParts[1]){
			return $arrPlus[0];
		}else{
			return "";
		} 
	}
	function getMessage($messageId){ 
		$response=imap_fetchheader($this->connection,$messageId,FT_PREFETCHTEXT);
		if($response===FALSE){
			$this->showError("imap_fetchheader failed");
		}
		return $response; 
	} 
	function deleteMessage($messageId){ 
		$response=imap_delete($this->connection,$messageId);
		if($response===FALSE){
			$this->showError("imap_delete failed");
		}
		return $response; 
	} 
	function mail_parse_headers($headers){ 
		$headers=preg_replace('/\r\n\s+/m', '',$headers); 
		preg_match_all('/([^: ]+): (.+?(?:\r\n\s(?:.+?))*)?\r\n/m', $headers, $matches); 
		$result=array();
		foreach ($matches[1] as $key =>$value){
			$result[$value]=$matches[2][$key]; 
		} 
		return($result); 
	} 
	function flattenParts($messageParts, $flattenedParts = array(), $prefix = '', $index = 1, $fullPrefix = true) {

		foreach($messageParts as $part) {
			$flattenedParts[$prefix.$index] = $part;
			if(isset($part->parts)) {
				if($part->type == 2) {
					$flattenedParts = $this->flattenParts($part->parts, $flattenedParts, $prefix.$index.'.', 0, false);
				}
				elseif($fullPrefix) {
					$flattenedParts = $this->flattenParts($part->parts, $flattenedParts, $prefix.$index.'.');
				}
				else {
					$flattenedParts = $this->flattenParts($part->parts, $flattenedParts, $prefix);
				}
				unset($flattenedParts[$prefix.$index]->parts);
			}
			$index++;
		}

		return $flattenedParts;
			
	}
	function setFilePath($filePath){
		$this->filePath=$filePath;
	}
	function getFullMessage($messageId){ 
		$mail = imap_fetchstructure($this->connection, $messageId); 
		//var_dump($mail);exit;
		//var_dump($mail);
		if($mail===FALSE){
			$this->showError("imap_fetchstructure failed");
		} 
		$newMail=array();
		$headers=$this->mail_decode_part($messageId, $mail, 0);
		$newMail["html"]="";
		$newMail["text"]="";
		$newMail["attachments"]=array();
		if(isset($mail->parts)){
			$mail=$this->flattenParts($mail->parts);  
			foreach($mail as $key=>$part){
				$mail[$key] = $this->mail_decode_part($messageId, $part, $key); 
				if(isset($mail[$key]["subtype"])){
					if($mail[$key]["subtype"] == "PLAIN"){
						$newMail["text"]=$mail[$key]["data"];
						unset($mail[$key]); 
					}else if($mail[$key]["subtype"] == "HTML"){
						$newMail["html"]=$mail[$key]["data"];
						unset($mail[$key]); 
					}
				}
			}  
			unset($mail["0"]);
			foreach($mail as $key=>$val){
				if(isset($mail[$key]) && isset($mail[$key]["is_attachment"])){ 
					$part=$mail[$key];
					$arrFilename=explode(".", $part['filename']);
					if(count($arrFilename) == 1){
						$ext="";
						$filename=$arrFilename[0];
					}else{
						$ext=".".array_pop($arrFilename);
						$filename=implode(".", $arrFilename);
					}
					// force unique filename
					$newFilePath=$this->filePath.$filename.$ext;
					$newFileName=$filename.$ext;
					if(file_exists($newFilePath)){
						$fileIndex=1;
						while(true){
							$newFilePath=$this->filePath.$filename.$fileIndex.$ext;
							$newFileName=$filename.$fileIndex.$ext;
							if(file_exists($newFilePath)){
								$fileIndex++;
							}else{
								break;
							}
						}
					}
					file_put_contents($newFilePath, $mail[$key]["data"]);
					array_push($newMail["attachments"], array(
						'size'=>strlen($mail[$key]["data"]),
						'path'=>$newFilePath,
						'name'=>$newFileName
					));
					if(isset($part['id'])){ 
						$newMail["html"]=str_replace('cid:'.$part['id'], $newFileName, $newMail["html"]);
					} 
				}
			}  
		}else{
			// handle single part messages
			$part=clone $mail;
			$part=$this->mail_decode_part($messageId, $part, '1');
			if(isset($part["subtype"])){
				if($part["subtype"] == "PLAIN"){
					$newMail["text"]=$part["data"];
				}else if($part["subtype"] == "HTML"){
					$newMail["html"]=$part["data"];
				}
			}else{
				$newMail["text"]=$part["data"];
			}
		}

		$newMail["headers"]=array(
			"raw"=>$headers["data"],
			"parsed"=>$this->mail_parse_headers($headers["data"])
		);
		return($newMail); 
	}  
	function mail_decode_part($messageId,$part,$prefix){ 
		$attachment = array();  
 
		if($part->ifdparameters) { 
			foreach($part->dparameters as $object) { 
				$attachment[strtolower($object->attribute)]=$object->value; 
				if(strtolower($object->attribute) == 'filename') { 
					$attachment['is_attachment'] = true; 
					$attachment['filename'] = $object->value; 
				} 
			} 
		} 

		if($part->ifsubtype) { 
			$attachment['subtype']=$part->subtype;
		}
		if($part->ifid) { 
			$attachment['id']=substr($part->id, 1, strlen($part->id)-2);
		}
		if($part->ifparameters) { 
			foreach($part->parameters as $object) { 
				$attachment[strtolower($object->attribute)]=$object->value; 
				if(strtolower($object->attribute) == 'name') { 
					$attachment['is_attachment'] = true; 
					$attachment['name'] = $object->value; 
				} 
			} 
		} 
 
		$attachment['data'] = imap_fetchbody($this->connection, $messageId, $prefix); 
		if($attachment['data']===FALSE){
			$this->showError("imap_fetchbody failed");
		}
		if($part->encoding == 3) { // 3 = BASE64 
			$attachment['data'] = base64_decode($attachment['data']); 
		}else if($part->encoding == 4) { // 4 = QUOTED-PRINTABLE 
			$attachment['data'] = quoted_printable_decode($attachment['data']); 
		} 
		//$attachment['data']='shortened'; // TODO: delete this
		return $attachment; 
	} 
	
	function close(){
		$result=imap_close($this->connection);
		if($result===FALSE){
			$this->showError("imap_close failed");
		}
	}
	function showError($message){
		echo($message.": ".imap_last_error());
		exit;
		
	}
}
?>