
var zScrollbarWidth=0;

(function($, window, document, undefined){
	"use strict";
	var zScrollTopComplete=true;
	var zScrollBarWidthCached=-1;
	function zFindPosition(obj) {
		var curleft,curtop,curwidth,curheight;
		curleft = curtop = curwidth = curheight = 0;
		if (obj.offsetParent) {
			curleft = obj.offsetLeft;
			curtop = obj.offsetTop;
			curwidth=obj.offsetWidth;
			curheight=obj.offsetHeight;
			while (true) {
				obj = obj.offsetParent;
				if(typeof obj === "undefined" || obj ===null){
					break;
				}else{
					curleft += obj.offsetLeft;
					curtop += obj.offsetTop;
				}
			}
		}
		return [curleft,curtop,curwidth,curheight];
	}
	

	function zGetAbsPosition(object) { 
		if(object == null || typeof object == "undefined" || typeof object.style == "undefined" || object.style.display=='none'){
			return {x:0, y:0, width:0, height:0 };
		} 

		var position = new Object();
		position.x = 0;
		position.y = 0; 
		if( object ) {
			position.x = object.offsetLeft;
			position.y = object.offsetTop;

			if( object.offsetParent ) {
				var parentpos = zGetAbsPosition(object.offsetParent);
				position.x += parentpos.x;
				position.y += parentpos.y;
			}
			position.cx = object.offsetWidth;
			position.cy = object.offsetHeight;
		}
		position.width=position.cx;
		position.height=position.cy;
		var $obj=$(object);
		position.innerWidth=$obj.innerWidth(),
		position.innerHeight=$obj.innerHeight()
		return position;
	}

	function zScrollTop(elem, y, forceAnimate){
		if(typeof elem === "undefined" || typeof elem === "boolean"){
			elem='html, body';	
		}
		if(zScrollTopComplete){
			if(typeof forceAnimate !== "undefined" && forceAnimate){
				$(elem).animate({scrollTop: y}, { 
					"duration":200, 
					"complete":function(){
						zScrollTopComplete=true;
					}
				});
				zScrollTopComplete=false;
			}else{
				$(window).scrollTop(y);
				zScrollTopComplete=true;
			}
		}
	}

	var zBoxHitTest=function(object1, object2){
		var p=zGetAbsPosition(object1);
		var p2=zGetAbsPosition(object2);

		//console.log(p.x+":"+p.y+":"+p.width+":"+p.height+" | "+p2.x+":"+p2.y+":"+p2.width+":"+p2.height);
		if(p2.x <= p.x+p.width){
			if(p2.x+p2.width >= p.x){
				if(p2.y <= p.y+p.height){
					if(p2.y+p2.height >= p.y){
						return true;
					}
				}
			}
		}
		return false;
	}

	function zJumpToId(id,offset){	
		var r94=document.getElementById(id);
		if(r94===null) return;
		var p=zFindPosition(r94);
		var isWebKit = navigator.userAgent.toLowerCase().indexOf('webkit') > -1;
		if(!offset || offset === null){
			offset=0;
		}
		if(isWebKit){
			document.body.scrollTop=p[1]+offset;
		}else{
			document.documentElement.scrollTop=p[1]+offset;
		}
	}
	function zGetScrollBarWidth () {
		if(zScrollBarWidthCached !== -1){
			return zScrollBarWidthCached;
		}
		var inner = document.createElement('p');
		inner.style.width = "100%";
		inner.style.height = "200px";

		var outer = document.createElement('div');
		outer.style.position = "absolute";
		outer.style.top = "0px";
		outer.style.left = "0px";
		outer.style.visibility = "hidden";
		outer.style.width = "200px";
		outer.style.height = "150px";
		outer.style.overflow = "hidden";
		outer.appendChild (inner);

		var b=document.documentElement || document.body;
		b.appendChild (outer);
		var w1 = inner.offsetWidth;
		outer.style.overflow = 'scroll';
		var w2 = inner.offsetWidth;
		if (w1 === w2) w2 = outer.clientWidth;

		b.removeChild (outer);
		zScrollBarWidthCached=(w1-w2);
		return zScrollBarWidthCached;
	};

	function zGetClientWindowSize() {
		var myWidth = 0, myHeight = 0;
		if( typeof( window.innerWidth ) === 'number' ) {
			//Non-IE
			myWidth = window.innerWidth;
			myHeight = window.innerHeight;
		} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
			//IE 6+ in 'standards compliant mode'
			myWidth = document.documentElement.clientWidth;
			myHeight = document.documentElement.clientHeight;
		} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
			//IE 4 compatible
			myWidth = document.body.clientWidth;
			myHeight = document.body.clientHeight;
		}
		if(zScrollbarWidth===0){
		zScrollbarWidth=zGetScrollBarWidth();	
		}
		zWindowSize={
			"width":myWidth-zScrollbarWidth,
					"height":myHeight
		};
		return zWindowSize;
	}

	var parentIdIndex=0;
	function zForceEqualHeights(className){  
		// only the elements with the same parent should be made the same height
		var arrParent=[];  
		$(className).height("auto");
		$(className).each(function(){
			if(this.parentNode.id == ""){
				// force parent to have unique id
				this.parentNode.id="zEqualHeightsParent"+parentIdIndex;
				parentIdIndex++;
			}
			if(typeof arrParent[this.parentNode.id] == "undefined"){
				arrParent[this.parentNode.id]=0;
			}
			var pos=zGetAbsPosition(this);
			var height=pos.height;  
			var height2=$(this).height();
			height=Math.max(height,height2);
			if(height>arrParent[this.parentNode.id]){
				arrParent[this.parentNode.id]=height;
			}
		});

		$(className).each(function(){
			if(arrParent[this.parentNode.id] == 0){
				arrParent[this.parentNode.id]="auto";
			}
			$(this).height(arrParent[this.parentNode.id]);
		});
 
	}
 
	function forceAutoHeightFix(){ 
		var images=$(".zForceEqualHeights img");
		var imagesCount=images.length;
		var imagesLoaded=0; 
		images.each(function(){
			if(this.complete){
				imagesLoaded++;
			}
		}); 
		if(imagesLoaded != imagesCount){
			images.bind("load", function(e){
				imagesLoaded++; 
				if(imagesLoaded>imagesCount){
					zForceEqualHeights(".zForceEqualHeights"); 
				}
			});
		}
		zForceEqualHeights(".zForceEqualHeights"); 
		if($(".zForceEqualHeight").length > 0){
			console.log("The class name should be zForceEqualHeights, not zForceEqualHeight");
		}
	} 
	zArrResizeFunctions.push({functionName:forceAutoHeightFix });

	window.zFindPosition=zFindPosition;
	window.zGetAbsPosition=zGetAbsPosition;
	window.zScrollTop=zScrollTop;
	window.zBoxHitTest=zBoxHitTest;
	window.zJumpToId=zJumpToId;
	window.zGetScrollBarWidth=zGetScrollBarWidth;
	window.zGetClientWindowSize=zGetClientWindowSize;
})(jQuery, window, document, "undefined"); 