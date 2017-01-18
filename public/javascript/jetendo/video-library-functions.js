
// start video-library
var debugVideoLibrary=false;
var arrVideoLibrary=new Object();
var zVideoLibraryIntervalId=false;
var arrCurVideo=[];
var arrQueueVideoMap=[];
var progressBarWidth=100;		
var arrProgressVideo=[];
var videoSortingStarted=false;
var videoSortingChanged=false; 
var currentVideoLibraryId="";
var arrVideoLibraryCaptions=new Array();
var zVideoJsEmbedded=false;
var zVideoJsEmbedIndex=0;


(function($, window, document, undefined){
	"use strict";
 
	function checkForPlayingVideo(){ 
		$("video").each(function(){
			if(this.currentTime != 0){
				clearInterval(videoAutoPlayDetectId);
				$(".zHideWhenVideoAutoPlays").hide();
			}
		}); 
	}
	var videoAutoPlayDetectId=setInterval(checkForPlayingVideo, 100);
	checkForPlayingVideo();

	function zAjaxDeleteVideoCallback(r){
		var r2=eval('(' + r + ')');
		if(r2.success){
			var t=arrVideoLibraryComplete[r2.libraryId];
			
			var d=document.getElementById("sortable");
			d.removeChild(arrVideoLibraryComplete[r2.libraryId].NewLI);
			delete arrVideoLibraryComplete[r2.libraryId];
		}else{
			alert('Failed to delete video.');
		}
	}
	function zDeleteVideo(libraryId){
		var t=arrVideoLibraryComplete[libraryId];
		var r=confirm("Are you sure you want to delete: "+t.name);
		if (r===true){
			//document.getElementById('embedVideoDiv').innerHTML="";
			//document.getElementById('embedMenuDiv').style.display="none";
			var tempObj={};
			tempObj.id="zAjaxDeleteVideo";
			tempObj.url="/z/_com/app/video-library?method=deleteVideo&video_id="+t.video_id+"&libraryid="+libraryId;
			tempObj.cache=false;
			tempObj.callback=zAjaxDeleteVideoCallback;
			tempObj.ignoreOldRequests=false;
			zAjax(tempObj);	
		}
	}
	function zAjaxSaveQueueToVideoCallback(r){
		var r2=eval('(' + r + ')');
		if(r2.success === false){
			alert("Failed to save video to database.");	
			return;
		}
		var uploadId=arrQueueVideoMap[r2.queue_id];
		arrVideoLibrary[uploadId].width=r2.video_width;
		arrVideoLibrary[uploadId].height=r2.video_height;
		arrVideoLibrary[uploadId].video_id=r2.video_id;
		document.getElementById('divprogressbar'+uploadId).style.display="none";
		arrVideoLibrary[uploadId].divProgressBg.style.display="none";
		arrVideoLibrary[uploadId].divProgressBg2.style.display="none";
		arrVideoLibrary[uploadId].divProgressName.innerHTML+=' | <a href="#" onclick="showEmbedOptions(\''+uploadId+'\'); return false;">Embed</a> | <a href="#" onclick="zDeleteVideo(\''+uploadId+'\'); return false;">Delete</a>';
		
		arrVideoLibraryComplete[uploadId]=arrVideoLibrary[uploadId];
	}
	function zFixVideoObject(t){
		t.divVideoError=document.getElementById('divvideoerror'+t.id);
		t.divProgressName=document.getElementById('divprogressname'+t.id);
		t.divProgress=document.getElementById('divprogress'+t.id);
		t.divProgressBg=document.getElementById('divprogressbg'+t.id);
		t.divProgressBg2=document.getElementById('divprogressbg2'+t.id);
	}
	function zAjaxEncodeProgressCallback(r){
		var r2=eval('(' + r + ')');
		var a9=[];
		for(var i=0;i<r2.arrVideos.length;i++){
			r=r2.arrVideos[i];
			var uploadId=arrQueueVideoMap[r.queue_id];
			var t=arrVideoLibrary[uploadId];
			zFixVideoObject(t);
			var curDate=new Date();
			var mult=(100/Math.max(0.01,r.percent));
			var etaTime=mult*(curDate.getTime()-t.startEncodeDate.getTime());
			var dTime=(curDate.getTime()-t.startEncodeDate.getTime())/1000;
			var remainingTime=Math.round(Math.round(((etaTime-(curDate.getTime()-t.startEncodeDate.getTime()))/1000)*100)/100);
			if(r.status === 2){
				t.divVideoError.innerHTML='There was an error encoding the video, please try again or contact the webmaster for assistance. Cause: '+r.errorMessage;
			}else if(r.percent === 100){
				if(r.previewImage){
					$("#divprogressbar"+t.id).css("float", "none");
					t.divProgress.style.width="110px";
					t.divProgress.style.cssFloat="left";
					t.divProgress.innerHTML='<img src="/zupload/video/'+r.filename+'-00001.jpg" width="100" alt="Video" />';
					t.posterImage='/zupload/video/'+r.filename+'-00001.jpg';
				}else{
					t.divProgress.innerHTML='Complete - Image Preview Not Available';
					t.posterImage=false;
				}
				$("#divprogress2_"+t.id).html("Encoding complete.");
				t.divProgressName.style.width="80%";
				t.divProgressName.style.cssFloat="left";
				t.videoFile='/zupload/video/'+r.filename;
				var tempObj={};
				tempObj.id="zAjaxSaveQueueToVideo";
				tempObj.url="/z/_com/app/video-library?method=saveQueueToVideo&queue_id="+r.queue_id;
				tempObj.cache=false;
				tempObj.callback=zAjaxSaveQueueToVideoCallback;
				tempObj.ignoreOldRequests=false;
				zAjax(tempObj);	
			}else{
				if(r.percent === 0){
					remainingTime='Calculating';
				}
				$("#divprogress2_"+t.id).html('Encoding | Progress: '+r.percent+'% | Seconds remaining: '+(remainingTime));
			}
			t.divProgressBg2.style.width=Math.round((r.percent/100)*progressBarWidth)+"px";
			if(r.percent < 100){
				for(var n=0;n<arrProgressVideo.length;n++){
					if(arrProgressVideo[n] === parseInt(r.queue_id)){
						a9.push(arrProgressVideo[n]);
						break;
					}
				}
			}
		}
		arrProgressVideo=a9;
		if(a9.length===0 && zVideoLibraryIntervalId!==false){
			clearInterval(zVideoLibraryIntervalId);
			zVideoLibraryIntervalId=false;
			
		}
	}
	function zAjaxEncodeProgress(){
		var tempObj={};
		tempObj.id="zAjaxVideoEncodeProgress";
		tempObj.url="/z/_com/app/video-library?method=videoencodeprogress&queue_id_list="+arrProgressVideo.join(",");
		tempObj.cache=false;
		tempObj.callback=zAjaxEncodeProgressCallback;
		tempObj.ignoreOldRequests=false;
		zAjax(tempObj);	
	}
	function zAjaxEncodeCancelCallback(r){
		var r2=eval('(' + r + ')');
		for(var i in arrVideoLibrary){
			var c=arrVideoLibrary[i];
			if(typeof c.video_id !== "undefined"){
				continue;
			}
			var d=document.getElementById("sortable");
			d.removeChild(c.NewLI);
			delete arrVideoLibrary[i];
		}
		if(zVideoLibraryIntervalId!==false){
			clearInterval(zVideoLibraryIntervalId);
			zVideoLibraryIntervalId=false;
		}
		arrVideoLibrary=[];
		arrProgressVideo=[];
	}
	function cancelEncoding(){
		if(arrProgressVideo.length === 0){
			alert('No videos are currently being encoded.'); 
			return;
		}
		var tempObj={};
		tempObj.id="zAjaxVideoEncodeCancel";
		tempObj.url="/z/_com/app/video-library?method=videoencodecancel&queue_id_list="+arrProgressVideo.join(",");
		tempObj.cache=false;
		tempObj.callback=zAjaxEncodeCancelCallback;
		tempObj.ignoreOldRequests=false;
		zAjax(tempObj);	
			
	}
			
	function myUploadSuccess(obj, serverData){ 
		var r2=eval('(' + serverData + ')'); 
		//alert(serverData);
		var ac=arrCurVideo;
		arrCurVideo=[];
		//alert(ac);
		for(var i=0;i<r2.arrVideos.length;i++){
			var r=r2.arrVideos[i];
			if(r.success===false){
				alert(r.message);
				continue;
			}
			arrProgressVideo.push(parseInt(r.queue_id));
			arrQueueVideoMap[parseInt(r.queue_id)]=ac[i];
			arrVideoLibrary[ac[i]].startEncodeDate=new Date();
			arrVideoLibrary[ac[i]].width=r.width;
			arrVideoLibrary[ac[i]].height=r.height;
			arrVideoLibrary[ac[i]].divProgressName.innerHTML=r.video_file;
		}
		clearInterval(zVideoLibraryIntervalId);
		zVideoLibraryIntervalId=setInterval(function(){zAjaxEncodeProgress();},1000);
	}
	function myUploadError(obj, serverData,s3){			
		alert('Upload Cancelled');//:'+obj.name+" | "+serverData+" | "+s3);	
	}
	function zAjaxKeepSessionActiveCallback(file, serverdata){
		// do nothing	
	}
	function keepSessionActive(){ 
		var tempObj={};
		tempObj.id="zKeepSessionActive";
		tempObj.url="/z/_com/app/video-library?method=videokeepsessionactive";
		tempObj.cache=false;
		tempObj.callback=zAjaxKeepSessionActiveCallback;
		tempObj.ignoreOldRequests=false;
		zAjax(tempObj);	
	}


	function ajaxSaveVideo(id){
		if(debugVideoLibrary) document.getElementById("forvideodata").value+="ajaxSaveVideo(): video_id:"+id+"\n";
		var link="/z/_com/app/video-library?method=saveVideoId&action=update&video_library_id="+currentVideoLibraryId+"&video_id="+id+"&video_caption="+escape(document.getElementById('caption'+id).value);
		if(debugVideoLibrary) document.getElementById("forvideodata").value+="\n\n"+link+"\n\n";
		$.get(link, "",     function(data) { if(debugVideoLibrary) document.getElementById("forvideodata").value+="\n\nAJAX SAVE IMAGE RESULT:\n"+data+"\n"; },     "html");  
	}
	 
	function videoModalClose(){
		var embedVideoDiv=document.getElementById('embedVideoDiv');
		embedVideoDiv.innerHTML="";
	}

	function showEmbedOptions(libraryid){
		var modalContent1=embedCode;		
		zArrModalCloseFunctions.push(videoModalClose);
		zShowModal(modalContent1,{'width':Math.min(1920, zWindowSize.width-50),'height':Math.min(1080, zWindowSize.height-50),"maxWidth":1920, "maxHeight":1080});
		var titleDiv=document.getElementById('embedMenuDivTitle');
		titleDiv.innerHTML=arrVideoLibraryComplete[libraryid].name;
		document.getElementById('video_embed_id').value=libraryid;
		document.getElementById('video_embed_width').value=arrVideoLibraryComplete[libraryid].width;
		document.getElementById('video_embed_height').value=arrVideoLibraryComplete[libraryid].height;
	}
	function generateEmbedCode(){
		var libraryid = document.getElementById('video_embed_id').value;
		var t=arrVideoLibraryComplete[libraryid];
		var video_embed_width=document.getElementById('video_embed_width').value;
		var video_embed_height=document.getElementById('video_embed_height').value;
		var video_embed_autoplay=0;
		if(document.getElementById('video_embed_autoplay1').checked){
			video_embed_autoplay=1;
		}
		var video_embed_viewing_method=0;
		if(document.getElementById('video_embed_viewing_method_name1').checked){
			video_embed_viewing_method=1;
		}else if(document.getElementById('video_embed_viewing_method_name2').checked){
			video_embed_viewing_method=2;
		}
		var embedCodeTr=document.getElementById('embedCodeTr');
		embedCodeTr.style.display="block";
		var embedTextarea=document.getElementById('embedTextarea');
		
		if(zVideoJsEmbedded===false){
			zVideoJsEmbedded=true;
		}
		zVideoJsEmbedIndex++;
		
		t.video_hash=t.videoFile.split("-")[1].substr(0,32);
		var autoplay=0;
		if(video_embed_autoplay === 1){
			autoplay=1;
		}
		
		var s='<iframe src="'+zVideoJSDomain+'/z/misc/embed/video/'+t.video_id+'-'+t.video_hash+'-'+video_embed_width+'-'+video_embed_height+'-'+autoplay+'-0-0-0-0"  style="margin:0px; border:none; overflow:auto;" seamless="seamless" width="'+video_embed_width+'" height="'+video_embed_height+'"></iframe>';
		 
		embedTextarea.value=s;
		var embedVideoDiv=document.getElementById('embedVideoDiv');
		embedVideoDiv.innerHTML=s;
	}
	window.zAjaxEncodeProgressCallback=zAjaxEncodeProgressCallback;
	window.zFixVideoObject=zFixVideoObject;
	window.zAjaxSaveQueueToVideoCallback=zAjaxSaveQueueToVideoCallback;
	window.zDeleteVideo=zDeleteVideo;
	window.zAjaxDeleteVideoCallback=zAjaxDeleteVideoCallback;
	window.generateEmbedCode=generateEmbedCode;
	window.showEmbedOptions=showEmbedOptions;
	window.videoModalClose=videoModalClose;
	window.ajaxSaveVideo=ajaxSaveVideo;
	window.keepSessionActive=keepSessionActive;
	window.zAjaxKeepSessionActiveCallback=zAjaxKeepSessionActiveCallback;
	window.zAjaxEncodeCancelCallback=zAjaxEncodeCancelCallback;
	window.zAjaxEncodeProgress=zAjaxEncodeProgress;
	window.myUploadError=myUploadError;
	window.myUploadSuccess=myUploadSuccess;
	window.cancelEncoding=cancelEncoding;

})(jQuery, window, document, "undefined"); 