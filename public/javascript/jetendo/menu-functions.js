 
var zValues=[];
var zFormData=new Object();
	var zTouchPosition={x:[0],y:[0],curX:[0],curY:[0],count:0,curCount:0};
if(typeof window.zMenuDisablePopups === "undefined"){
	window.zMenuDisablePopups=false;	
}
var arrOriginalMenuButtonWidth=[]; 

(function($, window, document, undefined){
	"use strict";
	var zMenuButtonCache=new Array();
	var zMenuDivIndex=0;
	var zTabletStylesheetLoaded=false;


	function zInitZValues(v){
		for(var i=0;i<v;i++){
			zValues[i]=[];	
		}
	}
	function zFixMenuOnTablets(){
		var a=zGetElementsByClassName("trigger");
		$(".zMenuBarDiv ul").css("display", "none");
		for(var i=0;i<a.length;i++){
			a[i].onmousedown=function(){ 
				var pos=zGetAbsPosition(this);
				var pos2=$(this).position();
				var c2=document.getElementById(this.parentNode.id+"_menu"); 
				if(zContentTransition.firstLoad===false){
					$(this).children("ul").css("display","block");
				} 
				if(c2){
					 c2.style.position="absolute";
					 var vertical=zo(this.id.split("_")[0]+"Vertical");
					 if(vertical){
						 c2.style.top=(pos2.top)+"px";c2.style.left=(pos2.left+pos.width)+"px";
					 }else{ 
						 c2.style.top=(pos2.top+pos.height)+"px";c2.style.left=pos2.left+"px";
					 }
				}
			}; 
			a[i].onclick=function(){  
				if(zWindowSize.width < 960){
					return true;
				}
				var c2=document.getElementById(this.parentNode.id+"_menu"); 
				var currentDisplay=c2.style.display;
				$(".zMenuBarDiv ul").css("display", "none");
				c2.style.display='block'; 
				if(c2){
					if(currentDisplay!='none'){
						var v=zContentTransition.doLinkOnClick(this); 
						if(v){
							$(".zMenuBarDiv ul").css("display", "none");
						}
						return v;
					}else{
						return false;
					}
				}else{
					var v=zContentTransition.doLinkOnClick(this); 
					if(v){
						$(".zMenuBarDiv ul").css("display", "none");
					}
					return v;
				} 
			};
		}
	}
	zArrDeferredFunctions.push(function(){
		document.body.addEventListener('touchstart', function (event) {
			zTouchPosition.x=[];
			zTouchPosition.y=[];
			if(typeof event.targetTouches === "undefined"){
				return;
			}
			zTouchPosition.count=event.targetTouches.length;
			for(var i=0;i<event.targetTouches.length;i++){
				zTouchPosition.x.push(event.targetTouches[i].pageX);
				zTouchPosition.y.push(event.targetTouches[i].pageY);
			}
		}, {
			passive:true 
		});
		document.body.addEventListener('touchmove', function (event) {
			zTouchPosition.curX=[];
			zTouchPosition.curY=[];
			if(typeof event.targetTouches === "undefined"){
				return;
			}
			for(var i=0;i<event.targetTouches.length;i++){
				zTouchPosition.curX.push(event.targetTouches[i].pageX);
				zTouchPosition.curY.push(event.targetTouches[i].pageY);
			} 
		}, {
			passive:true 
		});  
		document.body.addEventListener('touchend', function (event) {
			zTouchPosition.x=[];
			zTouchPosition.y=[];
			zTouchPosition.curX=[];
			zTouchPosition.curY=[];
			if(typeof event.targetTouches === "undefined"){
				return;
			}
			zTouchPosition.count=event.targetTouches.length;
			for(var i=0;i<event.targetTouches.length;i++){
				zTouchPosition.curX.push(event.targetTouches[i].pageX);
				zTouchPosition.curY.push(event.targetTouches[i].pageY);
				zTouchPosition.x.push(event.targetTouches[i].pageX);
				zTouchPosition.y.push(event.targetTouches[i].pageY);
			}
		}, {
			passive:true 
		}); 
		
		
	});

	
	function zMenuInit(){ // modified version of v1.1.0.2 by PVII-www.projectseven.com 
		//if(zMSIEBrowser==-1){return;}
		//return;
		var i,k,g,lg,r=/\s*zMenuHvr/,nn='',c,bv='zMenuDiv';
		 lg=document.getElementsByTagName("LI"); 
		var $wrapper=$(".zMenuWrapper").css("visibility", "visible").show();

		var arrButtons=$(".trigger", $wrapper);
		arrButtons.each(function(){
			if(this.href==window.location.href){
				$(this).addClass("trigger-selected");
			}
		});
		 $(".zMenuWrapper").each(function(){ 
			 if(this.className.indexOf('zMenuEqualDiv') === -1){
				 return; 
			 } 
			var arrA=$(".zMenuWrapper > ul > li > a");
			var menuWidth=$(".zMenuBarDiv", this).width();
			var borderTotal=0; 
			$(this).width(menuWidth);
			if(arrA.length){
				var padding=($(arrA[0]).outerWidth()-$(arrA[0]).width())/2;
			}
			if(this.id === ''){
				this.id='zMenuContainerDiv'+zMenuDivIndex;
				zMenuDivIndex++;
			} 
			var buttonMargin=0;
			if(this.getAttribute("data-button-margin") !== ''){
				buttonMargin=parseInt(this.getAttribute("data-button-margin"));
			}
			 zSetEqualWidthMenuButtons(this.id, buttonMargin);
		 });
		 if(zMenuDisablePopups){
			 $(".zMenuBarDiv .trigger").each(function(){
				 $("ul", this.parentNode).detach();
			});
		 }else if(!zIsTouchscreen()){ 
			 if(lg){
				 for(k=0;k<lg.length;k++){
					if(lg[k].parentNode.id.indexOf("zMenuDiv")!==-1){ 
						zMenuButtonCache.push(lg[k]); 
						 lg[k].onmouseover=function(){
							 var pos=zGetAbsPosition(this);
							 var pos2=$(this).position();
							 var c2=document.getElementById(this.id+"_menu"); 
							if(zContentTransition.firstLoad===false){
								$(this).children("ul").css("display","block");
							}
							if(c2){
								 c2.style.position="absolute";
								 var vertical=zo(this.id.split("_")[0]+"Vertical");
								 if(vertical){
									 c2.style.top=(pos2.top)+"px";c2.style.left=(pos2.left+pos.width)+"px";
								 }else{ 
									 c2.style.top=(pos2.top+pos.height)+"px";c2.style.left=pos2.left+"px";
								 }
								c2.style.zIndex=2000;
							 }
							if(this.className.indexOf('zMenuEqualUL') === -1){ 
								this.className="zMenuHvr";
							 }else{
								this.className="zMenuEqualLI zMenuHvr";
							 } 
						 };
						 lg[k].onmouseout=function(){
							c=this.className;
							if(this.className.indexOf('zMenuEqualUL') === -1){ 
								this.className="zMenuNoHvr";
							}else{ 
								this.className="zMenuEqualLI zMenuNoHvr";
							}
							if(zContentTransition.firstLoad===false){
								$(this).children("ul").css("display","none");
							} 
						 };
					}
				}
			}
		}
		nn=i+1;
		
		if((zTabletStylesheetLoaded===false && zIsTouchscreen())){
			zTabletStylesheetLoaded=true;
			zLoadFile("/z/stylesheets/tablet.css","css");
			zFixMenuOnTablets(); 
		}
	}
	function zHideMenuPopups(){
		//alert(zMenuButtonCache.length);
		for(var i=0;i<zMenuButtonCache.length;i++){
			$(zMenuButtonCache[i]).children("ul").css("display","none");
			//zMenuButtonCache[i].onmouseout();	
		}
		$(".zdc-sub").css("display","none");
		
	}
	/*
	example html:
	<div id="menu" class="zMenuEqualDiv"><ul class="zMenuEqualUL"><li class="zMenuEqualLI"><a href="#" class="zMenuEqualA">test1</a></li><li class="zMenuEqualLI"><a href="#" class="zMenuEqualA">test2</a></li></ul></div>

	example js:
	zSetEqualWidthMenuButtons("menu");
	*/
	function zSetEqualWidthMenuButtons(containerDivId, marginSize){ 
		$("#"+containerDivId).css("visibility", "hidden");

		if(typeof arrOriginalMenuButtonWidth[containerDivId] === "undefined"){
			zArrResizeFunctions.push(function(){ zSetEqualWidthMenuButtons(containerDivId, marginSize); });
		}
		arrOriginalMenuButtonWidth[containerDivId]={
			ul:$("#"+containerDivId+" > ul "),
			arrLI:$("#"+containerDivId+" > ul > li"),
			arrItem:$("#"+containerDivId+" > ul > li > a"),
			arrItemWidth:[],
			arrItemBorderAndPadding:[],
			containerWidth:	0,
			navWidth:0,
			marginSize:marginSize
		};
		var currentMenu=arrOriginalMenuButtonWidth[containerDivId];
		for(var i=0;i<currentMenu.arrItem.length;i++){ 
			$(currentMenu.arrItem[i]).css({
				"width": "auto",
				"min-width":"1px"
			});
			$(currentMenu.arrItem[i]).css({
				"margin-right": "0px"
			});
		}
		$(currentMenu.arrLI).each(function(){ $(this).css("margin-right", "0px"); });

		//console.log("run equal width: "+ containerDivId+":"+currentMenu.arrItem.length);
		var sLen=currentMenu.arrItem.length;
		for(var i=0;i<sLen;i++){ 
			var jItem=$(currentMenu.arrItem[i]);
				/*$(currentMenu.arrItem[i]).css({ 
					"padding-left": "0px",
					"padding-right": "0px"
				});*/
 			jItem.width("auto");
 			//console.log("new auto width:"+jItem.width());
			var curWidth=jItem.width();
			var borderLeft=parseInt(jItem.css("border-left-width"));
			var borderRight=parseInt(jItem.css("border-right-width"));
			if(isNaN(borderLeft)){
				borderLeft=1;
			}
			if(isNaN(borderRight)){
				borderRight=1;
			}
			var curBorderAndPadding=parseInt(jItem.css("padding-left"))+parseInt(jItem.css("padding-right"))+parseInt(borderLeft)+parseInt(borderRight);
			if(jItem.css("box-sizing") == "border-box"){
				curBorderAndPadding=0;
			}
			//console.log("borpad:"+curBorderAndPadding+":"+borderLeft+":"+borderRight+":"+curWidth+":"+jItem.width()+":"+(jItem.css("padding-left"))+":"+(jItem.css("padding-right"))+":"+jItem.css("border-left-width")); 
			$(jItem).css({
				"padding-left":"0px",
				"padding-right":"0px"
			}); 
			if(i===sLen-1){
				//curWidth-=0.5;
				$(jItem).css({
					"margin-right": "0px"
				});
				curWidth=$(jItem).width();
				//console.log("last:"+curWidth);
				$(jItem).css({ 
					"width": curWidth+"px"
				});
				currentMenu.navWidth+=curWidth+curBorderAndPadding; 
				//console.log(curWidth+marginSize+curBorderAndPadding);
			}else{
				$(jItem).css({
					"margin-right": currentMenu.marginSize+"px",
					"width": curWidth
				}); 
				currentMenu.navWidth+=curWidth+marginSize+curBorderAndPadding;
				//console.log(curWidth+marginSize+curBorderAndPadding);
			}
			currentMenu.arrItemBorderAndPadding.push(curBorderAndPadding);
			currentMenu.arrItemWidth.push(curWidth);
		} 
		//console.log(currentMenu.navWidth);
 
		//console.log(currentMenu.marginSize);
		//currentMenu.ul.detach(); 
		//console.log(containerDivId+":"+"containerWidth:"+$("#"+containerDivId).width());
		$("#"+containerDivId).width("100%");
		currentMenu.containerWidth=$("#"+containerDivId).width()-1;
		//console.log(currentMenu.containerWidth+":"+currentMenu.navWidth+":"+currentMenu.marginSize);
		//return;
		var totalWidth = currentMenu.containerWidth;//-2;
		var navWidth = 0;
		var deltaWidth = totalWidth - (currentMenu.navWidth);// + currentMenu.marginSize);
		var padding = Math.floor((deltaWidth / currentMenu.arrItem.length) / 2);// - (currentMenu.marginSize/2); 
		var floatEnabled=false;
		if(totalWidth<currentMenu.navWidth + ((currentMenu.arrItem.length-1)*currentMenu.marginSize)){
			//padding=0;
			floatEnabled=true;
			$(currentMenu.arrLI).each(function(){ $(this).css("display", "block"); });
		}else{
			if($.browser.msie && $.browser.version <= 7){
				$(currentMenu.arrLI).each(function(){ $(this).css("display", "inline"); });
			}else{
				$(currentMenu.arrLI).each(function(){ $(this).css("display", "inline-block"); });
			} 
		} 
		//console.log(containerDivId+":"+"marginSize:"+currentMenu.marginSize+" containerWidth:" +currentMenu.containerWidth+" totalWidth:"+totalWidth+" navWidth:"+currentMenu.navWidth+" deltaWidth:"+deltaWidth+" padding:"+padding);
		var totalWidth2=0;
		var sLen=currentMenu.arrItem.length;
		for(var i=0;i<sLen;i++){ 
			var curWidth=currentMenu.arrItemWidth[i];
			//console.log(padding);
			//$(currentMenu.arrItem[i]).width(curWidth-20);
			var newWidth=Math.floor(curWidth+(padding*2)); 
 
			var addWidth=Math.max(curWidth, newWidth);
			newWidth=(newWidth/currentMenu.containerWidth);
			curWidth=(curWidth/currentMenu.containerWidth);
 			newWidth=(Math.round(newWidth*100000)/1000)-0.001;
 			curWidth=(Math.round(curWidth*100000)/1000)-0.001; 
			if(sLen-1 == i){
				
				newWidth=(currentMenu.containerWidth-totalWidth2);
	 			addWidth=newWidth;
	 			newWidth=newWidth/currentMenu.containerWidth;
	 			newWidth=(Math.round(newWidth*100000)/1000)-0.001;
	 			curWidth=newWidth;
				$(currentMenu.arrItem[i]).parent().css({
					"width": (newWidth)+"%",
					"min-width":(curWidth)+"%"
				});
				$(currentMenu.arrItem[i]).css({
					"width": (100)+"%",
					"min-width":(100)+"%" 
				});
			}else{
				$(currentMenu.arrItem[i]).parent().css({
					"width": (newWidth)+"%",
					"min-width":(curWidth)+"%", 
					"margin-right":marginSize+"px"
				});
				$(currentMenu.arrItem[i]).css({
					"width": (100)+"%",
					"min-width":(100)+"%" 
				});
					
			}
			totalWidth2+=Math.round(addWidth+marginSize);
		} 
		$("#"+containerDivId).append(currentMenu.ul);
		$("#"+containerDivId).css("visibility", "visible");
	}



	zArrLoadFunctions.push({functionName:function(){
		if($(".zMenuClear").length){
			zMenuInit(); 
		}
	}});


	function zSetGearMenuPosition(obj){

		var p=zGetAbsPosition(obj);
		var p2=zGetAbsPosition($("#zGearWindowPreDiv1")[0]);
		p.y+=Math.round(p.height/2);
		p.x+=Math.round(p.width/2);
		if(p.x+p2.width+10 > zWindowSize.width){
			p.x=zWindowSize.width-p2.width-10;
		}
		if(p.y+p2.height+10 > zWindowSize.height){
			p.y=zWindowSize.height-p2.height-10;
		}
		if(p.x<10){
			p.x=10;
		}
		if(p.y<10){
			p.y=10;
		}
		$("#zGearWindowPreDiv1").css({
			"left":p.x,
			"top":p.y
		});
	}
	function zSetupGearMenu(obj){
		if(zMSIEBrowser!==-1 && zMSIEVersion<=7){
			$(".zGearButton").html('<img src="/z/a/images/gear.png" alt="Settings" />');
		}
		$(".zGearButton").bind("click", function(){
			var json=this.getAttribute("data-button-json");
			var currentGearObj=this;
			if(!$("#zGearWindowPreDiv1").length){
				$("body").append('<div id="zGearWindowPreDiv1" class="zGearPopupMenu"><div class="zGearPopupInnerMenu"></div></div>');
				$("body").bind("click", function(){
					if($("#zGearWindowPreDiv1").css("visibility") == "visible"){
						$("#zGearWindowPreDiv1").slideToggle(100, function(){ $(this).css("visibility", "hidden");});
					}
				});
				zArrResizeFunctions.push(function(){
					zSetGearMenuPosition(currentGearObj);
				});
			}
			$("#zGearWindowPreDiv1").css("visibility", "hidden").show();
			$("#zGearWindowPreDiv1 .zGearPopupInnerMenu").html(json);
			zSetGearMenuPosition(currentGearObj);
			var p2=zGetAbsPosition($("#zGearWindowPreDiv1")[0]);
			$("#zGearWindowPreDiv1 .zGearPopupMenuButton").css({
				"width":(p2.width-20)+"px"
			}).last().css("margin-bottom", "0px");
			$("#zGearWindowPreDiv1").css({
				"display": "none",
				"visibility":"visible"
			}).slideToggle(100);
			return false;
		});
	}
	zArrDeferredFunctions.push(function(){
		zSetupGearMenu();
	});

	window.zInitZValues=zInitZValues;
	window.zHideMenuPopups=zHideMenuPopups;

})(jQuery, window, document, "undefined"); 