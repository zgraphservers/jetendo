
(function($, window, document, undefined){
	"use strict";

function setupMobileHeader(){ 
	var win = $( window ); 
	var mobileHeader = $( '.z-mobile-header');  
	var mobileHeaderMobileMenu        = $( '.z-mobile-menu', mobileHeader );
	var mobileHeaderMobileMenuIcon    = $( '.z-mobile-menu-icon', mobileHeader );
	var mobileHeaderMobileMenuOverlay = $( '.z-mobile-header-overlay', mobileHeader );
 
	if(mobileHeader.hasClass("z-mobile-allow-fixed")){
		win.on( 'scroll', function() {
			var scrollTop = ( window.pageYOffset !== undefined ) ? window.pageYOffset : ( document.documentElement || document.body.parentNode || document.body ).scrollTop;
			if ( scrollTop > 0 ) {
				mobileHeader.addClass( 'z-mobile-header-fixed' );
			} else {
				mobileHeader.removeClass( 'z-mobile-header-fixed' );
			}
		} );
	}
	win.scroll();  

	var scrollbarWidth=zGetScrollBarWidth();
	var hasScrollbar=false;

	function resizeMobileHeader(){

 		var w=$(window).width();
 		var h=$(window).width();
 		var open=false;
		if(mobileHeaderMobileMenuIcon.hasClass( 'open' )){ 
			open=true; 
			mobileHeaderMobileMenuOverlay.css({
				"width":Math.round(w*2)+"px",
				"height":Math.round(h*2)+"px"
			}); 
		}
		var nw=$(window).width(); 
		// keep screen from shifting
 		if(hasScrollbar){ 
 			if(open){ 
				$("body").css("margin-right", scrollbarWidth+"px"); 
				if(mobileHeader.hasClass("z-mobile-allow-fixed") && zScrollPosition.top != 0){
	 				$(".z-mobile-menu-icon").css("right", (20+scrollbarWidth)+"px");
		 			$(".z-mobile-header").css("width", (w)+"px");
	 			}else{
		 		}
 			}else{
	 			$(".z-mobile-header").css("width", "100%");
				$("body").css("margin-right", "0px"); 
				if(mobileHeader.hasClass("z-mobile-allow-fixed") && zScrollPosition.top != 0){
	 				$(".z-mobile-menu-icon").css("right", "20px"); 
	 			}
	 		}
 		}else{ 
	 		$(".z-mobile-header").css("width", "100%");
			$("body").css("margin-right", "0px"); 
	 		$(".z-mobile-menu-icon").css("right", "20px"); 
 		}
	}
 
 	function toggleMenu(){ 
 		var w=$(window).width();
 		var h=$(window).width();
 		var open=false;
		if(mobileHeaderMobileMenuIcon.hasClass( 'open' )){
			$("body").css("overflow", "auto");
			mobileHeaderMobileMenuOverlay.removeClass("open");
		}else{
			$("body").css("overflow", "hidden");
			open=true;
			mobileHeaderMobileMenuOverlay.addClass("open");
			/*mobileHeaderMobileMenuOverlay.addClass("open").css({
				"width":Math.round(w*1.5)+"px",
				"height":Math.round(h*1.5)+"px"
			});*/
		}
		var nw=$(window).width(); 
		// keep screen from shifting
 		if(w!=nw){ 
 			hasScrollbar=true;
 			/*
 			if(open){ 
				$("body").css("margin-right", (nw-w)+"px"); 
				if(mobileHeader.hasClass("z-mobile-allow-fixed") && zScrollPosition.top != 0){
	 				$(".z-mobile-menu-icon").css("right", (20)+"px");
		 			$(".z-mobile-header").css("width", (w)+"px");
	 			}else{
		 		}
 			}else{
	 			$(".z-mobile-header").css("width", "100%");
				$("body").css("margin-right", "0px"); 
				if(mobileHeader.hasClass("z-mobile-allow-fixed") && zScrollPosition.top != 0){
	 				$(".z-mobile-menu-icon").css("right", "20px"); 
	 			}
	 		}*/
 		}else{ 
 			hasScrollbar=false;
 			/*
	 		$(".z-mobile-header").css("width", "100%");
			$("body").css("margin-right", "0px"); 
	 		$(".z-mobile-menu-icon").css("right", "20px"); 
	 		*/
 		}
 		console.log(hasScrollbar+":hasScrollbar");
		mobileHeaderMobileMenuIcon.toggleClass( 'open' );
		mobileHeaderMobileMenu.toggleClass( 'open' );
		resizeMobileHeader();
 	}
 	zArrResizeFunctions.push({functionName:resizeMobileHeader});
 	resizeMobileHeader();

	mobileHeaderMobileMenuIcon.on( 'click', function() {
		toggleMenu();
	} );

	mobileHeaderMobileMenuOverlay.on( 'click', function() {
		console.log('i click');
		toggleMenu();
	} );
}
	
zArrDeferredFunctions.push(setupMobileHeader);

})(jQuery, window, document, "undefined"); 
