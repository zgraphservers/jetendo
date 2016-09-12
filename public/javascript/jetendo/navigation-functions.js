(function($, window, document, undefined){
	"use strict"; 



var zPagination=function(options){
	var self=this;
	if(typeof options === undefined){
		options={};
	}
	options.id=zso(options, 'id');
	if(options.id == ""){
		throw("zPagination: options.id is required");
	} 
	options.count=zso(options, 'count'); 
	if(options.count === ""){
		throw("zPagination: options.count is required");
	}
	options.perpage=zso(options, 'perpage', true, 20);
	options.offset=zso(options, 'offset', true, 0);
	options.loadFunction=zso(options, 'loadFunction', false, function(){});
	if(typeof options.loadFunction != "function"){
		throw("zPagination: options.loadFunction is required and must be a function");
	}
	self.updatePerPage=function(perpage){
		options.perpage=perpage;
		render();
	};
	self.updateCount=function(count){
		options.count=count;
		render();
	};
	self.updateOffset=function(offset){
		options.offset=offset;
		render();
	};
	function render(){
		drawNavLinks(options.id, options.count, options.offset, options.perpage);
	};
	function runLoad(){
		options.loadFunction(options);
	}
	function drawNavLinks(id, count, curOffset, perPage){
		var arrR=new Array();
		var firstOffset=0;
		var linkCount=5;
		var firstLinkCount=Math.floor((linkCount-1)/2); 
		var beforeLinkCount=Math.min(firstLinkCount, options.offset/options.perpage);
		
		var pageCount=Math.min(Math.ceil(1000/perPage), Math.ceil(count/perPage));
		var lastLinkCount=(linkCount-1)-firstLinkCount;
		
		var firstOffset=curOffset-(beforeLinkCount*perPage);
		
		var arrBind=[];
		if(firstOffset!=curOffset){ 
			arrR.push('<a href="##" class="zPagination-previousLink">Previous<\/a>');	

			arrBind.push({
				"selector":".zPagination-previousLink",
				"offset":curOffset-perPage
			});
		} 
		for(var i=0;i<linkCount;i++){
			var coff=((i*perPage)+firstOffset);
			var clabel=(coff/perPage)+1;
			if(clabel <= pageCount){
				if(clabel == pageCount && coff+perPage == curOffset){
					arrR.push('<span class="search-nav-t">'+clabel+'</span>');
				}else if(coff == curOffset){
					arrR.push('<span class="search-nav-t">'+clabel+'</span>');
				}else{
					arrR.push('<a href="##" class="zPagination-link'+clabel+'">'+clabel+'</a>');	 
					arrBind.push({
						"selector":'.zPagination-link'+clabel,
						"offset": coff
					});
				}
			}
		} 
		if(pageCount >= curOffset/perPage){
			var clabel=((curOffset+perPage)/perPage)+1;
			if(clabel <= pageCount){
				arrR.push('<a href="##" class="zPagination-nextLink">Next<\/a>'); 
				
				arrBind.push({
					"selector":".zPagination-nextLink",
					"offset":curOffset+perPage
				});
			}
		}

		var r='<div style="width:100%; float:left" class="zPagination-container">'+arrR.join("")+'</div>';
		$("#"+id).html(r);
		for(var i=0;i<arrBind.length;i++){
			$(arrBind[i].selector, "#"+id).unbind("click");
			var c=arrBind[i];
			$(arrBind[i].selector, "#"+id).attr("data-offset", c.offset);
			$(arrBind[i].selector, "#"+id).bind("click", function(){ 
				var offset=parseInt($(this).attr("data-offset")); 
				options.offset=offset;
				runLoad(); 
				return false;
			});
		}
	}
	render();

}

	window.zPagination=zPagination;
})(jQuery, window, document, "undefined"); 
