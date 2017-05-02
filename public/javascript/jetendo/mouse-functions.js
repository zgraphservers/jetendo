var zMousePosition={x:0,y:0};
var zDrag_dragObject  = null;
var zDragTableOnMouseMove=function(){};
var zMapMarkerRollOutV3=function(){};
var zHumanMovement=false;

(function($, window, document, undefined){
	"use strict";
	var zDrag_arrParam=new Array();
	var zDrag_mouseOffset = null;
	var zDrag_dropTargets = [];
	var zCurOverEditLink="";
	var zOverEditDisableMouseOut=false;
	var zCurOverEditObj=null;
	var zOverEditLastLink="";
	var zOverEditLastPos={x:0,y:0};

	function zDrag_mouseCoords(e) {
		var sl=document.documentElement.scrollLeft;
		var st=document.documentElement.scrollTop;
		if(typeof sl === "undefined") sl=document.body.scrollLeft;
		if(typeof st === "undefined") st=document.body.scrollTop;
	    if (document.layers) {
	        var xMousePosMax = window.innerWidth+window.pageXOffset;
	        var yMousePosMax = window.innerHeight+window.pageYOffset;
	    } else if (document.all) {
			var cw=document.documentElement.clientWidth ? document.documentElement.clientWidth : document.body.clientWidth;
			var ch=document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.clientHeight;
	        var xMousePosMax = cw+sl;
	        var yMousePosMax = ch+st;
	    } else if (document.getElementById) {
	        var xMousePosMax = window.innerWidth+window.pageXOffset;
	        var yMousePosMax = window.innerHeight+window.pageYOffset;
	    }
		var xMousePos=0;
		var yMousePos=0;
		if (e.pageX){ xMousePos=e.pageX;
		}else if(e.clientX){ xMousePos=e.clientX + (sl);}
		if (e.pageY){ yMousePos=e.pageY;
		}else if (e.clientY){ yMousePos=e.clientY + (st);}
		return {x:xMousePos,y:yMousePos,pageWidth:xMousePosMax,pageHeight:yMousePosMax};	
	}
	function zDrag_makeClickable(object){
		object.onmousedown = function(){
			zDrag_dragObject = this;
		};
	}
	function zDragTableOnMouseUp(){};
	function zDrag_mouseUp(ev){
		ev           = ev || window.event;
		zDragTableOnMouseUp(ev);
		var mousePos = zDrag_mouseCoords(ev);
		for(var i=0; i<zDrag_dropTargets.length; i++){
			var curTarget  = zDrag_dropTargets[i];
			var targPos    = zDrag_getPosition(curTarget);
			var targWidth  = parseInt(curTarget.offsetWidth);
			var targHeight = parseInt(curTarget.offsetHeight);
		}
		if(zDrag_dragObject!==null){
			var paramObj=zDrag_arrParam[zDrag_dragObject.id];
			if(typeof paramObj !== "undefined"){
				paramObj.callbackFunction(zDrag_dragObject,paramObj,true);
			}
		}
		zDrag_dragObject   = null;
	}

	function zDrag_getMouseOffset(target, ev){
		ev = ev || window.event;
		var docPos    = zDrag_getPosition(target);
		var mousePos  = zDrag_mouseCoords(ev);
		return {x:mousePos.x - docPos.x, y:mousePos.y - docPos.y};
	}
	function zDrag_getPosition(e){
		var left = 0;
		var top  = 0;
		while (e.offsetParent){
			left += e.offsetLeft;
			top  += e.offsetTop;
			e     = e.offsetParent;
		}
		left += e.offsetLeft;
		top  += e.offsetTop;
		return {x:left, y:top};
	}

	function zDrag_mouseMove(ev){
		zDragTableOnMouseMove(ev);
		zOutEditDiv(ev);
		zMapMarkerRollOutV3(false);
		ev           = ev || window.event;
		var mousePos = zDrag_mouseCoords(ev); 
		zMousePosition=mousePos;
		if(zMousePosition.x+zMousePosition.y > 0){
			zHumanMovement=true;
		}
		if(zDrag_dragObject){
			var pObj=zDrag_arrParam[zDrag_dragObject.id];
			if(typeof pObj === "undefined" || typeof pObj.boxObj === "undefined"){
				return;
			}
			var bObj=document.getElementById(pObj.boxObj);
			var p1=zGetAbsPosition(bObj);
			if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){
				if(zDrag_arrParam[zDrag_dragObject.id].zValue+3===zDrag_arrParam[zDrag_dragObject.id].zValueValue){
					zDrag_dragObject.style.marginRight=(((parseInt(p1.width)-((mousePos.x - zDrag_mouseOffset.x) - p1.x))-parseInt(zDrag_dragObject.style.width))/2)+"px";
				}else{
					zDrag_dragObject.style.marginLeft=(((mousePos.x - zDrag_mouseOffset.x) - p1.x)/2)+"px";
				}
			}else{
				if(zDrag_arrParam[zDrag_dragObject.id].zValue+3===zDrag_arrParam[zDrag_dragObject.id].zValueValue){
					zDrag_dragObject.style.marginRight=((parseInt(p1.width)-((mousePos.x - zDrag_mouseOffset.x) - p1.x))-parseInt(zDrag_dragObject.style.width))+"px";
				}else{
					zDrag_dragObject.style.marginLeft=Math.min(p1.width, Math.max(0,((mousePos.x - zDrag_mouseOffset.x) - p1.x)))+"px";
				}
			}
			zDrag_arrParam[zDrag_dragObject.id].callbackFunction(zDrag_dragObject,zDrag_arrParam[zDrag_dragObject.id]);
			return false;
		}
	}
	function zDrag_makeDraggable(obj,paramObj){
		if(!obj) return;
		zDrag_arrParam[obj.id]=paramObj;
		obj.ondragstart = function(ev){
			return false;
		};
		obj.onmousedown = function(ev){
			zDrag_dragObject  = this;
			zDrag_mouseOffset = zDrag_getMouseOffset(this, ev);
			return false;
		};
		paramObj.callbackFunction(obj,paramObj);
	}

	function zDrag_addDropTarget(dropTarget){
		zDrag_dropTargets.push(dropTarget);
	}

	if(typeof document.onmousemove === "function"){
		var zDragOnMouseMoveBackup=document.onmousemove;
	}else{
		var zDragOnMouseMoveBackup=function(){};
	}
	$(document).bind("mousemove", function(ev){
		zDragOnMouseMoveBackup(ev);
		zDrag_mouseMove(ev);

	});
	if(typeof document.onmouseup === "function"){
		var zDragOnMouseUpBackup=document.onmouseup;
	}else{
		var zDragOnMouseUpBackup=function(){};
	}
	$(document).bind("mouseup", function(ev){
		zDragOnMouseUpBackup(ev);
		zDrag_mouseUp(ev);

	}); 

	function zEnableTextSelection(target){
		target.onmousedown=function(){return true;};
		target.onselectstart=function(){return true;};
		target.style.MozUserSelect="text";
	}
	function zDisableTextSelection(target){
		if (typeof target.onselectstart!=="undefined"){ //IE route
			target.onselectstart=function(){return false;};
		}else if (typeof target.style.MozUserSelect!=="undefined"){ //Firefox route
			target.style.MozUserSelect="none";
		}else if(target.onmousedown===null){ //All other route (ie: Opera)
			target.onmousedown=function(){return false;};
		}
	} 
 
	function zMouseHitTest(object, marginInPixels){ 
		if(object == null || typeof object == "undefined" || typeof object.style == "undefined" || object.style.display=='none'){
			return false;
		}


		var p=zGetAbsPosition(object);
		if(typeof marginInPixels == "undefined"){
			marginInPixels=0;
		} 
		if(p.width==0 && p.height==0){
			return false;
		}
		if(p.x-marginInPixels <= zMousePosition.x){
			if(p.x+p.width+marginInPixels >= zMousePosition.x){
				if(p.y-marginInPixels <= zMousePosition.y){
					if(p.y+p.height+marginInPixels >= zMousePosition.y){
						return true;
					}
				}
			}
		} 
		return false;
	}

	function zOverEditDiv(o,theLink){
		var zOverEditDivTag1=document.getElementById("zOverEditDivTag");
		if(theLink !== zOverEditLastLink){
			zOverEditLastLink=theLink;
			zCurOverEditObj=document.getElementById(o);
			zCurOverEditLink=theLink;
			zOverEditDivTag1.style.left=(zMousePosition.x+10)+"px";
			zOverEditDivTag1.style.top=(zMousePosition.y+10)+"px";
			zOverEditLastPos={x:zMousePosition.x,y:zMousePosition.y};
			zOverEditDivTag1.style.display="block";
		}else{
			zOverEditDivTag1.style.display="block";
			var xChange=Math.abs((zMousePosition.x+10)-zOverEditLastPos.x);
			var yChange=Math.abs((zMousePosition.y+10)-zOverEditLastPos.y);
			if(xChange<=70 && yChange<=70){
				return;
			}else{
				zCurOverEditObj=document.getElementById(o);
				zCurOverEditLink=theLink;
				zOverEditDivTag1.style.left=(zMousePosition.x+10)+"px";
				zOverEditDivTag1.style.top=(zMousePosition.y+10)+"px";
				zOverEditLastPos={x:zMousePosition.x,y:zMousePosition.y};
			}
		}
	}


	function zOutEditDiv(){
		var zOverEditDivTag1=document.getElementById("zOverEditDivTag");
		if(zOverEditDivTag1 !== null && zOverEditDivTag1.style.display==="block"){
			var xChange=Math.abs((zMousePosition.x+10)-zOverEditLastPos.x);
			var yChange=Math.abs((zMousePosition.y+10)-zOverEditLastPos.y);
			if(xChange>300 || yChange>300){
				zOverEditDivTag1.style.display="none";
			}
		}
	}
	function zOverEditGoToURL(url) { 
		window.top.location.href=url;
	}
	function zOverEditClick(){
		if(zCurOverEditLink!==""){
			zOverEditGoToURL(zCurOverEditLink);
		}
	}
	var zOverEditContentLoaded=false;
	function zLoadOverEditButton(){
		if(!zOverEditContentLoaded){
			zOverEditContentLoaded=true;
			$('body').append('<div id="zOverEditDivTag" style="z-index:20001;  position:absolute; background-color:#FFFFFF; display:none; cursor:pointer; left:0px; top:0px; width:50px; height:27px; text-align:center; font-weight:bold; line-height:18px; "><a id="zOverEditATag" href="##" class="zNoContentTransition" target="_top" title="Click EDIT to edit this content">EDIT</a></div>');
			
			$("#zOverEditATag").bind("click", function(){
				if(typeof zIsAdminLoggedIn != "undefined" && zIsAdminLoggedIn()){
					zLoadOverEditButton();
					zOverEditClick();
					return false;
				}
			});
		}
	}
	$(".zOverEdit").bind("mouseover", function(){
		if(typeof zIsAdminLoggedIn != "undefined" && zIsAdminLoggedIn()){
			zLoadOverEditButton();
			var u=$(this).attr("data-editurl");
			if(u != ""){
				zOverEditDiv(this, u);
			}
		}
	});

	window.zMouseHitTest=zMouseHitTest;
	window.zDisableTextSelection=zDisableTextSelection;
	window.zEnableTextSelection=zEnableTextSelection;
	window.zDrag_addDropTarget=zDrag_addDropTarget;
	window.zDrag_makeDraggable=zDrag_makeDraggable;
	window.zDrag_mouseMove=zDrag_mouseMove;
	window.zDrag_getPosition=zDrag_getPosition;
	window.zDrag_getMouseOffset=zDrag_getMouseOffset;
	window.zDrag_mouseUp=zDrag_mouseUp;
	window.zDragTableOnMouseUp=zDragTableOnMouseUp;
	window.zDrag_makeClickable=zDrag_makeClickable;
	window.zDrag_mouseCoords=zDrag_mouseCoords;
})(jQuery, window, document, "undefined"); 
