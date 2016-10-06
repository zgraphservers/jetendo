
(function($, window, document, undefined){
	"use strict";
	var calendarConfig={};

	function setupFullCalendar(){

		$('#zCalendarFullPageDiv').fullCalendar({ 
			//timezone:'America/New_York',
			//ignoreTimezone :true, 
		    eventClick: function(calEvent, jsEvent, view) {
				if(typeof calEvent.link != "undefined"){
					window.location.href=calEvent.link;
				}
				return;
		    },
			header: {
				left: 'prev,next today',
				center: 'title',
				right: 'month,basicWeek,basicDay'
			},
			eventRender: function(event, element, view) {  
				element.find('.fc-time').hide(); 
				if(calendarConfig.disableOtherMonth){    
					if(view.type == "month"){
						var date=view.start.local().toDate(); 
						if(date.getDate() > 15){
							// force date to the next month
			   				date.setDate(date.getDate() + 10);   
			   			} 
			   			// uncomment to debug dates:
		   				//console.log(event.start.local().toDate()+":"+event.start.local().toDate().getMonth()+" !== "+view.start.local().toDate().getMonth()+":"+date.getMonth());
		   				if(event.start.local().toDate().getMonth() !== date.getMonth()) {  
		   					return false; 
		   				} 
		   			}
	   			}
			},
			defaultDate: calendarConfig.defaultDate,
			editable: false,
			eventSources: [{
				url: calendarConfig.jsonFullLink,
				type: 'GET',
				data: {},
				error: function () {
					alert('There was an error while fetching events!');
				}
			}]
		});
		if(navigator.userAgent.indexOf("MSIE 7.0") != -1){
			$(".fc-icon-left-single-arrow").html("&lt;");
			$(".fc-icon-right-single-arrow").html("&gt;");
		}
	}
	function setupPagination(rs){

		var options={
			id:"zEventListCalendarNav",
			count: rs.count,
			perpage: rs.perpage, 
			offset: rs.offset,
			loadFunction: function(options){
				var link=zURLAppend(rs.link, "offset="+options.offset);

				var tempObj={};
				tempObj.id="zListCalendar";
				tempObj.url=link;
				tempObj.callback=listViewCallback;
				tempObj.cache=false;
				zAjax(tempObj);
				zJumpToId("zCalendarTab_List");
			}
		}
		var p=new zPagination(options);
	}
	function listViewCallback(r){ 
		var rs=JSON.parse(r);
		if(rs.success){
			$("#zCalendarTab_List").html(rs.html);
			setupPagination(rs);
		}
	}

	function setupListView(){

		var tempObj={};
		tempObj.id="zListCalendar";
		tempObj.url=calendarConfig.jsonListLink;
		tempObj.callback=listViewCallback;
		tempObj.cache=false;
		zAjax(tempObj);
	}
	function zDisplayEventCalendar(s){
		calendarConfig=s;
		if(typeof calendarConfig.disableOtherMonth == "undefined"){
			calendarConfig.disableOtherMonth=false;
		}
		if(calendarConfig.hasListView){
		
			if(calendarConfig.activeTab == 0){
				var activeTab=0;
				setupListView();
			}else{
				var activeTab=1;
				setTimeout(setupFullCalendar, 100);
			}
			$("#zCalendarHomeTabs").tabs({
				active:activeTab,
				activate:function(e, e2){ 
					if(e2.newPanel[0].id == "zCalendarTab_Calendar"){
						setTimeout(setupFullCalendar, 100);
					}else if(e2.newPanel[0].id == "zCalendarTab_List"){
						setTimeout(setupListView, 100);
					}
				}
			});
		}else{
			setTimeout(setupFullCalendar, 100);
		}
		
		zArrResizeFunctions.push({functionName:resizeEventCalendar});
		resizeEventCalendar();
	}
	function resizeEventCalendar(){
		if(zWindowSize.width < 600){
			var active = $("#zCalendarHomeTabs").tabs( "option", "active" );
			if(active == 1){ 
				$("#zCalendarHomeTabs").tabs({active:0});
			} 
			$("#zCalendarHomeTabs .ui-tabs-nav").hide();
		}else{ 
			$("#zCalendarHomeTabs .ui-tabs-nav").show();
		}
	}
	function zEventSearchCallback(r){ 
		var r2=JSON.parse(r);
		if(r2.success){
			$("#zCalendarTab_List").html(r2.html);

			setupPagination(r2);
			zJumpToId("zEventSearchResults");
		}
	}
	function zEventSearchGetData(){
		var startdate=$("#zEventSearchStartDate").val();
		var enddate=$("#zEventSearchEndDate").val();
		var keyword=$("#zEventSearchKeyword").val();
		var arr=[];
		$(".zEventSearchCategory").each(function(){
			if(this.checked){
				arr.push(this.value);
			}
		});
		var categories=arr.join(",");
		var arr=[];
		$(".zEventSearchCalendar").each(function(){
			if(this.checked){
				arr.push(this.value);
			}
		});
		var calendarids=arr.join(",");
		
		var searchString="startdate="+escape(startdate)+"&enddate="+escape(enddate)+"&keyword="+escape(keyword)+"&categories="+escape(categories)+"&calendarids="+escape(calendarids);
		if(window.location.href.indexOf("/z/event/event-search/index") == -1){
			window.location.href="/z/event/event-search/index?"+searchString;
			return;
		}
		var tempObj={};
		tempObj.id="zAjaxEventSearch";
		tempObj.url="/z/event/event-search/ajaxEventSearch?"+searchString;
		tempObj.cache=false;
		tempObj.callback=zEventSearchCallback;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);
	}

	function zEventSearchSetupForm(){
		$( "#zEventSearchStartDate" ).datepicker({ 
			//minDate: -20, 
			maxDate: "+1Y",
			numberOfMonths:3,
			onClose: function( selectedDate ) {
				if($( "#zEventSearchStartDate" ).val() == ''){
					return;
				}
				$( "#zEventSearchEndDate" ).datepicker( "option", "minDate", selectedDate );
				$( "#zEventSearchEndDate" ).datepicker( "option", "maxDate", "+1Y");//selectedDate );
				var newdate=new Date(selectedDate);
				newdate.setDate(newdate.getDate() + 30);
				
				var year = String(newdate.getFullYear());
				var month = String(newdate.getMonth() + 1);
				if (month.length == 1) {
				    month = "0" + month;
				}
				var day = String(newdate.getDate());
				if (day.length == 1) {
				    day = "0" + day;
				}
				document.getElementById("zEventSearchEndDate").value=month+"/"+day+"/"+year;
			}
		});
		$( "#zEventSearchEndDate" ).datepicker({ 
			//minDate: -20, 
			maxDate: "+1Y",
			numberOfMonths:3,
			onClose: function( selectedDate ) {
			//	$( "#startdate" ).datepicker( "option", "maxDate", selectedDate );
			} 
		});
		$( "#zEventSearchStartDate" ).bind("change", zEventSearchGetData);
		$( "#zEventSearchEndDate" ).bind("change", zEventSearchGetData);
		$("#zEventSearchKeyword").bind("change", zEventSearchGetData);
		$( ".zEventSearchCategory" ).bind("change click", zEventSearchGetData);
		$( ".zEventSearchCalendar" ).bind("change click", zEventSearchGetData);
		$("#zSearchEventButton").bind("click", zEventSearchGetData);

	}
	window.zEventSearchSetupForm=zEventSearchSetupForm;
	window.zDisplayEventCalendar=zDisplayEventCalendar;
})(jQuery, window, document, "undefined"); 
