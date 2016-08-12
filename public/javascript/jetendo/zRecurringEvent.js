
(function($, window, document, undefined){
	"use strict";
	var zRecurringEvent=function(options){
		var self=this;
		var recurType="Daily";
		var lastPreviewColumnCount=0;
		var arrExclude=[];
		var calendarWidth=160; 
		var calendarColumns=0;
		var arrMarked=[];
		var calendarRows=3;
		var disableFormOnChange=false;

		var monthLookup={
			"January":0, 
			"February":1, 
			"March":2, 
			"April":3, 
			"May":4, 
			"June":5,
			"July":6,
			"August":7, 
			"September":8, 
			"October":9, 
			"November":10, 
			"December":11
		};

		var dayLookup={
			"Sunday":0,
			"Monday":1,
			"Tuesday":2,
			"Wednesday":3,
			"Thursday":4,
			"Friday":5,
			"Saturday":6,
			"Day":-1
		};
		var whichNameLookup={
			1:"The First",
			2:"The Second",
			3:"The Third",
			4:"The Fourth",
			5:"The Fifth",
			"-1":"The Last"
		};
		var whichLookup={
			"The First":1,
			"The Second":2,
			"The Third":3,
			"The Fourth":4,
			"The Fifth":5,
			"The Last":-1
		};
		var pythonDayToJs={
			6:0,
			0:1,
			1:2,
			2:3,
			3:4,
			4:5,
			5:6
		};
		var pythonDayToRRuleName={
			6:"SU",
			0:"MO",
			1:"TU",
			2:"WE",
			3:"TH",
			4:"FR",
			5:"SA"
		};
		var jsDayToPython={
			0:6,
			1:0,
			2:1,
			3:2,
			4:3,
			5:4,
			6:5
		};
		var pythonDayNameLookup={
			6:"Sunday",
			0:"Monday",
			1:"Tuesday",
			2:"Wednesday",
			3:"Thursday",
			4:"Friday",
			5:"Saturday"
		};
		var pythonDayLookup={
			"Sunday":6,
			"Monday":0,
			"Tuesday":1,
			"Wednesday":2,
			"Thursday":3,
			"Friday":4,
			"Saturday":5
		};
		var dayNameLookup={
			0:"Sunday",
			1:"Monday",
			2:"Tuesday",
			3:"Wednesday",
			4:"Thursday",
			5:"Friday",
			6:"Saturday"
		};

		if(typeof options === undefined){
			options={};
		}
		var monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
		
		// force defaults
		options.ruleObj=zso(options, 'ruleObj', false, {});
		options.arrExclude=zso(options, 'arrExclude', false, []);
		options.renderingEnabled=zso(options, 'renderingEnabled', false, true);
		function init(options){
			//$cartDiv=$(".zcart."+options.name);
			self.buildMonthlyCalendar();
			for(var i=0;i<options.arrExclude.length;i++){
				var d=new Date(Date.parse(options.arrExclude[i]));
				if(d=='Invalid Date'){
					alert(options.arrExclude[i]+' is an invalid exclude date, and was automatically removed.');
				}else{
					arrExclude[d.getTime()]=d;
				}
			}
 
			self.setFormFromRules(options.ruleObj, true); 

			recurType=$("#zRecurTypeSelect").val();
			$("#zRecurType"+recurType).show();
			$("#zRecurTypeSelect").bind("change", function(){
				recurType=$(this).val();
				$(".zRecurType").hide();
				$("#zRecurType"+recurType).show();
			});

			$("#zRecurTypeRangeDate").datepicker();
			$("#zRecurTypeExcludeDate").datepicker();
			zArrResizeFunctions.push(function(){

				calendarColumns=Math.floor((($(".zRecurPreviewBox").width()))/calendarWidth);
				if(lastPreviewColumnCount== calendarColumns){
					return;
				}
				lastPreviewColumnCount=calendarColumns;
				arrMarked=self.getMarkedDates();
				self.drawPreviewCalendars();
			});

			self.drawExcludedDates();
			$("#zRecurTypeExcludeDateButton").bind("click", function(){
				try{
					var date=new Date(Date.parse($("#zRecurTypeExcludeDate").val()));
					if(date=='Invalid Date'){
						alert($("#zRecurTypeExcludeDate").val()+' is an invalid date.  The date should be formatted: month/day/year using only numbers and /.');
						return false;
					}
				}catch(e){
					alert("You must specify a valid date first.");
					return false;
				}
				self.addExcludeDate(date);
				self.updateState();

				self.drawPreviewCalendars();
				return false;
			});

			$('.zRecurEventBox :input').bind("change", function(){
				self.drawPreviewCalendars();
			}); 
			/*setTimeout(function(){ 

				calendarColumns=Math.floor((($(".zRecurPreviewBox").width()))/calendarWidth);
				lastPreviewColumnCount=calendarColumns;
				arrMarked=self.getMarkedDates();
				self.drawPreviewCalendars();
			}, 200);*/
		};
		self.updateState=function () { 
			if(disableFormOnChange){
				return false;
			}
			var ruleObj=self.getRulesFromForm();
			var rule=self.convertFromRecurringEventToRRule(ruleObj);
			arrMarked=self.getMarkedDates();

			var arrDate2=[];
			for(var i in arrMarked){
				var d=new Date();
				d.setTime(i);
				var m=d.getMonth()+1;
				if(m<10){
					m="0"+m;
				}
				var d2=d.getDate();
				if(d2<10){
					d2="0"+d2;
				}
				arrDate2.push(d.getFullYear()+"-"+(m)+"-"+d2);
			}
			console.log("['"+arrDate2.join("','")+"']");

			if($("#event_recur_ical_rules", window.parent.document).length){
				var r=rule.toString();
				$("#event_recur_ical_rules", window.parent.document).val(r);

				var arrExclude2=[];
				for(var i in arrExclude){
					var n=new Date();
					n.setTime(i);
					var d=(n.getMonth()+1)+"/"+n.getDate()+"/"+n.getFullYear();
					if(d.indexOf("NaN") == -1){
						arrExclude2.push(d);
					}
				}

				$("#event_excluded_date_list", window.parent.document).val(arrExclude2.join(","));
				if($("#zRecurTypeSelect").val() == "None"){
					$("#recurringConfig1", window.parent.document).html("No");
				}else{
					$("#recurringConfig1", window.parent.document).html("Yes");

					var tempObj={};
					tempObj.id="zRecurAsPlainEnglish";
					tempObj.url="/z/_com/ical/ical?method=getIcalRuleAsPlainEnglishAsJson&rule="+escape(r);
					tempObj.callback=function(r2){
						var m=eval("("+r2+")");
						if(m.success){
							$("#recurringConfig1", window.parent.document).html("Yes | "+m.string);
						}
					};
					tempObj.cache=false;
					zAjax(tempObj);
				}
				if($("#zRecurTypeRangeRadio3")[0].checked){
					$("#event_recur_until_datetime", window.parent.document).val($("#zRecurTypeRangeDate").val());
				}else{
					$("#event_recur_until_datetime", window.parent.document).val("");
				}
				if(rule.options.count != null){
					$("#event_recur_count", window.parent.document).val(rule.options.count);
				}else{
					$("#event_recur_count", window.parent.document).val(0);
				}
				if(rule.options.interval != null){
					$("#event_recur_interval", window.parent.document).val(rule.options.interval);
				}else{
					$("#event_recur_interval", window.parent.document).val(1);
				}
				if(rule.options.freq != null){
					$("#event_recur_frequency", window.parent.document).val(rule.options.freq);
				}else{
					$("#event_recur_frequency", window.parent.document).val(1);
				}
			}

		};
		self.buildMonthlyCalendar=function(){
			var arrHTML=[];
			arrHTML.push('<div style="width:100%; float:left;">');
			for(var i=1;i<=31;i++){
				arrHTML.push('<span class="zRecurDayButton" style="width:36px;margin-bottom:3px;"><span style="width:15px; float:left;"><input type="checkbox" name="zRecurTypeMonthlyCalendarDay" class="zRecurTypeMonthlyCalendarDay" id="zRecurTypeMonthlyCalendarDay'+i+'" value="'+i+'" /></span> <label for="zRecurTypeMonthlyCalendarDay'+i+'" style="display:block; float:left;width:21px;">'+i+'</label></span></span>');
				if(i % 7 == 0){
					arrHTML.push('</div><div style="width:100%; float:left;">');
				}
			}
			arrHTML.push('<span class="zRecurDayButton" style="width:70px;margin-bottom:3px;"><span style="width:15px;display:block; float:left;"><input type="checkbox" name="zRecurTypeMonthlyCalendarDay" class="zRecurTypeMonthlyCalendarDay" id="zRecurTypeMonthlyCalendarDay0" value="0" /></span> <label for="zRecurTypeMonthlyCalendarDay0" style="display:block; float:left;width:52px;">Last Day</label></span></span>');
			arrHTML.push('</div>');
			$("#zRecurTypeMonthlyCalendar").html(arrHTML.join(""));
		};
		self.drawPreviewCalendars=function(){ 
			self.updateState();
			if(!options.renderingEnabled){
				return;
			}
			var $calendarDiv=$("#zRecurPreviewCalendars");
			var arrHTML=[];
			var count=0;

			calendarColumns=Math.floor((($(".zRecurPreviewBox").width()))/calendarWidth);
			var startDate=$("#event_start_datetime_date").val();
			if(startDate == ""){
				return;
			}
			try{
				var currentDate=new Date(Date.parse(startDate));
				if(currentDate< new Date()){ 
					currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);  
				}
			}catch(e){
				return;
			}
			for(var i=0;i<calendarRows;i++){
				arrHTML.push('<div style="width:100%; float:left;">');
				for(var n=0;n<calendarColumns;n++){
					// currentDate + 1 month
					var newDate=new Date(currentDate.getTime());
					newDate.setDate(1);
					newDate.setMonth(newDate.getMonth()+count);
					newDate.setDate(1);
					arrHTML.push('<div class="zRecurCalendarContainer">'+self.buildCalendarHTML(newDate)+'</div>');
					count++;
				}
				arrHTML.push('</div>');
			}
			$calendarDiv.html(arrHTML.join(""));
			$(".zRecurCalendarDayMarked").bind("click", function(){
				var e=$(this).hasClass("zRecurCalendarDayExcluded");
				var date=new Date(parseInt($(this).attr("data-date")));
				if(e!=""){
					self.removeExcludedDate(date);
					$(this).removeClass("zRecurCalendarDayExcluded");
				}else{
					self.addExcludeDate(date);
					$(this).addClass("zRecurCalendarDayExcluded");
				}
			});
		};
		self.buildCalendarHTML=function(date){
			// 6 rows to make them all the same
			var month=monthNames[date.getMonth()]+" "+date.getFullYear();
			var arrHTML=['<div class="zRecurCalendarMonth">'+month+'</div><div class="zRecurCalendar">'];
			arrHTML.push('<div class="zRecurCalendarDayLabels">');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Su</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Mo</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Tu</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">We</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Th</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Fr</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Sa</div>');
			arrHTML.push('</div>');


			var monthString=monthNames[date.getMonth()];
			var firstDayOfWeek=date.getDay();
			var currentMonth=date.getMonth();
			date.setDate(date.getDate()-firstDayOfWeek);
			var day=date; 
			for(var i=0;i<6;i++){
				arrHTML.push('<div class="zRecurCalendarWeek">');
				for(var n=0;n<7;n++){
					var dayMonth=day.getMonth();
					var currentDate=day.getDate();
					if(dayMonth != currentMonth){
						arrHTML.push('<div class="zRecurCalendarDayOtherMonth">'+currentDate+'</div>');
					}else{
						var markedCSS=''; 
						
						if(typeof arrMarked[day.getTime()] != "undefined"){
							markedCSS+=' zRecurCalendarDayMarked';
							if(typeof arrExclude[day.getTime()] != "undefined"){
								markedCSS+=' zRecurCalendarDayExcluded';
							}
						}
						var dateAsString=(day.getMonth()+1)+"/"+day.getDate()+"/"+day.getFullYear();
						arrHTML.push('<div class="zRecurCalendarDay'+markedCSS+'" id="zRecurCalendarDay'+day.getTime()+'" data-date="'+day.getTime()+'">'+currentDate+'</div>');
					}
					day.setDate(day.getDate()+1);
				}
				arrHTML.push('</div>');
			}
			arrHTML.push('</div>');
			return arrHTML.join("");
		}
		self.addExcludeDate=function(date){
			arrExclude[date.getTime()]=date;
			self.drawExcludedDates();
		};
		self.removeExcludedDate=function(date){
			var arrNew=[];
			var t=date.getTime();
			for(var i in arrExclude){
				if(i!=t){
					arrNew[i]=arrExclude[i];
				}
			}
			arrExclude=arrNew;
			self.drawExcludedDates();
		};
		self.drawExcludedDates=function(){
			var arrSort=[];
			for(var i in arrExclude){
				arrSort.push(parseInt(i));
			}
			arrSort.sort();
			var arrHTML=[];
			for(var i=0;i<arrSort.length;i++){
				var day=new Date(arrSort[i]);
				var dateAsString=(day.getMonth()+1)+"/"+day.getDate()+"/"+day.getFullYear();
				arrHTML.push('<div class="zRecurExcludedDay" data-date="'+day.getTime()+'"><div class="zRecurExcludedDayText">'+dateAsString+'</div><div class="zRecurExcludedDayDeleteButton">X</div></div>');
			}
			if(arrSort.length == 0){
				arrHTML.push('No dates are excluded');
			}
			$("#zRecurExcludedDates").html(arrHTML.join(""));
			$(".zRecurExcludedDay").bind("click", function(){
				var date=new Date(parseInt($(this).attr("data-date")));
				self.removeExcludedDate(date);
				$("#zRecurCalendarDay"+date.getTime()).removeClass("zRecurCalendarDayExcluded");
				return false;
			});
			self.drawPreviewCalendars();
		};
		self.setFormFromRules=function(ruleObj, disablePreviewUpdate){
			var defaultRuleObj={
				recurType:"None",
				noEndDate:false,
				everyWeekday:false,
				skipDays:1,
				recurLimit:0,
				endDate:false,
				skipWeeks:1,
				skipMonths:1,
				skipYears:1,
				arrWeeklyDays:[],
				monthlyWhich:"",
				monthlyDay:"",
				arrMonthlyCalendarDay:[],
				annuallyWhich:"",
				annuallyDay:"",
				annuallyMonth:""
			};

			for(var i in defaultRuleObj){
				if(typeof ruleObj[i] == "undefined"){
					ruleObj[i]=defaultRuleObj[i];
				}
			}
			disableFormOnChange=true;
			$("#zRecurTypeSelect").val(ruleObj.recurType);
			$("#zRecurTypeSelect").trigger("change");

			if(ruleObj.recurType == "Daily"){
				if(!ruleObj.everyWeekday){
					$("#zRecurTypeDailyRadio1").prop("checked", true);
					$("#zRecurTypeDailyDays").val(ruleObj.skipDays);
				}else{	
					$("#zRecurTypeDailyRadio2").prop("checked", true);
					ruleObj.everyWeekday=true;
				}

			}else if(ruleObj.recurType == "Weekly"){
				$("#zRecurTypeWeeklyWeeks").val(ruleObj.skipWeeks);
				var arrC=[];
				for(var i=0;i<ruleObj.arrWeeklyDays.length;i++){
					arrC[ruleObj.arrWeeklyDays[i]]=true;
				}
				$(".zRecurTypeWeeklyDay").each(function(){
					if(typeof arrC[this.value] != "undefined"){
						this.checked=true;
					}else{
						this.checked=false;
					}
				});

			}else if(ruleObj.recurType == "Monthly"){


				$("#zRecurTypeMonthlyDays").val(ruleObj.skipMonths);
				if(ruleObj.arrMonthlyCalendarDay.length == 0){
					$("#zRecurTypeMonthlyType1").prop("checked", true);

					$("#zRecurTypeMonthlyWhich").val(ruleObj.monthlyWhich); 
					$("#zRecurTypeMonthlyDay").val(ruleObj.monthlyDay);
				}else{
					
					$("#zRecurTypeMonthlyType2").prop("checked", true);
					var arrC=[];
					for(var i=0;i<ruleObj.arrMonthlyCalendarDay.length;i++){
						arrC[ruleObj.arrMonthlyCalendarDay[i]]=true;
					}
					$(".zRecurTypeMonthlyCalendarDay").each(function(){
						if(typeof arrC[this.value] != "undefined"){
							this.checked=true;
						}else{
							this.checked=false;
						}
					});
				}
			}else if(ruleObj.recurType == "Annually"){
				$("#zRecurTypeAnnuallyDays").val(ruleObj.skipYears);
				if(ruleObj.annuallyDay == ""){
					$("#zRecurTypeAnnuallyType1").prop("checked", true);
					$("#zRecurTypeAnnuallyWhich").val(ruleObj.annuallyWhich);
					$("#zRecurTypeAnnuallyMonth").val(ruleObj.annuallyMonth);
				}else{
					$("#zRecurTypeAnnuallyType2").prop("checked", true);
					$("#zRecurTypeAnnuallyWhich2").val(ruleObj.annuallyWhich);
					$("#zRecurTypeAnnuallyDay2").val(ruleObj.annuallyDay);
					$("#zRecurTypeAnnuallyMonth2").val(ruleObj.annuallyMonth);
				} 
			}

			if(typeof ruleObj.endDate != "boolean"){
				$("#zRecurTypeRangeRadio3").prop("checked", true);
				if(ruleObj.endDate != ""){
					ruleObj.endDate=new Date(Date.parse(ruleObj.endDate));
					var dateAsString=(ruleObj.endDate.getMonth()+1)+"/"+ruleObj.endDate.getDate()+"/"+ruleObj.endDate.getFullYear();
					$("#zRecurTypeRangeDate").val(dateAsString);
				}
			}else if(ruleObj.recurLimit != 0 && ruleObj.recurLimit != null){ 
				$("#zRecurTypeRangeDays").val(ruleObj.recurLimit);
				$("#zRecurTypeRangeRadio2").prop("checked", true);
			}else{ 
				$("#zRecurTypeRangeRadio1").prop("checked", true);
			}
			disableFormOnChange=false; 
			if(typeof disablePreviewUpdate == "undefined"){
				disablePreviewUpdate=false;
			}
			if(!disablePreviewUpdate){
				arrMarked=self.getMarkedDates();
				self.drawPreviewCalendars();
			}
		}
		self.getRulesFromForm=function(){
			var ruleObj={};
			ruleObj.recurType="Daily";
			ruleObj.noEndDate=false;
			ruleObj.everyWeekday=false;
			ruleObj.skipDays=1;
			ruleObj.recurLimit=0;
			ruleObj.endDate=false;
			ruleObj.skipWeeks=1;
			ruleObj.skipMonths=1;
			ruleObj.skipYears=1;
			ruleObj.arrWeeklyDays=[];
			ruleObj.monthlyWhich="";
			ruleObj.monthlyDay="";
			ruleObj.arrMonthlyCalendarDay=[];
			ruleObj.annuallyWhich="";
			ruleObj.annuallyDay="";
			ruleObj.annuallyMonth="";

			ruleObj.recurType=$("#zRecurTypeSelect").val();

			if(ruleObj.recurType == "Daily"){
				if($("#zRecurTypeDailyRadio1").prop("checked")){	
					try{
						ruleObj.skipDays=parseInt($("#zRecurTypeDailyDays").val());
						if(isNaN(ruleObj.skipDays)){
							alert('Interval must be a number');
							$("#zRecurTypeDailyDays").val('1');
							ruleObj.skipDays=1;
						}
					}catch(e){
						alert("X must be a valid number for the Every X Day(s) field.");
						$("#zRecurTypeDailyDays").val(1);
					}

				}else if($("#zRecurTypeDailyRadio2").prop("checked")){	
					ruleObj.everyWeekday=true;
				}

			}else if(ruleObj.recurType == "Weekly"){
					try{
						ruleObj.skipWeeks=parseInt($("#zRecurTypeWeeklyWeeks").val());
						if(isNaN(ruleObj.skipWeeks)){
							alert('Interval must be a number');
							$("#zRecurTypeWeeklyWeeks").val('1');
							ruleObj.skipWeeks=1;
						}
					}catch(e){
						alert("X must be a valid number for the Every X Week(s) field.");
						$("#zRecurTypeWeeklyWeeks").val(1);
					}
					
					$(".zRecurTypeWeeklyDay").each(function(){
						if(this.checked){
							ruleObj.arrWeeklyDays.push(this.value);
						}
					});

			}else if(ruleObj.recurType == "Monthly"){
				try{
					ruleObj.skipMonths=parseInt($("#zRecurTypeMonthlyDays").val());
					if(isNaN(ruleObj.skipMonths)){
						alert('Interval must be a number');
						$("#zRecurTypeMonthlyDays").val('1');
						ruleObj.skipMonths=1;
					}
				}catch(e){
					alert("X must be a valid number for the Every X Month(s) field.");
					$("#zRecurTypeMonthlyDays").val(1);
				}
				if($("#zRecurTypeMonthlyType1").prop("checked")){
					ruleObj.monthlyWhich=$("#zRecurTypeMonthlyWhich").val();
					ruleObj.monthlyDay=$("#zRecurTypeMonthlyDay").val();
				}else if($("#zRecurTypeMonthlyType2").prop("checked")){
					
					$(".zRecurTypeMonthlyCalendarDay").each(function(){
						if(this.checked){
							ruleObj.arrMonthlyCalendarDay.push(parseInt(this.value));
						}
					});
				}
			}else if(ruleObj.recurType == "Annually"){
				try{
					ruleObj.skipYears=parseInt($("#zRecurTypeAnnuallyDays").val());
					if(isNaN(ruleObj.skipYears)){
						alert('Interval must be a number');
						$("#zRecurTypeAnnuallyDays").val('1');
						ruleObj.skipYears=1;
					}
				}catch(e){
					alert("X must be a valid number for the Every X Year(s) field.");
					$("#zRecurTypeAnnuallyDays").val(1);
				}
				if($("#zRecurTypeAnnuallyType1").prop("checked")){
					ruleObj.annuallyWhich=$("#zRecurTypeAnnuallyWhich").val();
					ruleObj.annuallyMonth=$("#zRecurTypeAnnuallyMonth").val();


				}else if($("#zRecurTypeAnnuallyType2").prop("checked")){
					ruleObj.annuallyWhich=$("#zRecurTypeAnnuallyWhich2").val();
					ruleObj.annuallyDay=$("#zRecurTypeAnnuallyDay2").val();
					ruleObj.annuallyMonth=$("#zRecurTypeAnnuallyMonth2").val();
				}
			}

			if($("#zRecurTypeRangeRadio1").prop("checked")){
				// do nothing
			}else if($("#zRecurTypeRangeRadio2").prop("checked")){
				try{
					ruleObj.recurLimit=parseInt($("#zRecurTypeRangeDays").val());
				}catch(e){

				}
			}else if($("#zRecurTypeRangeRadio3").prop("checked")){
				var d=$("#zRecurTypeRangeDate").val();
				if(d!=""){
					try{
						ruleObj.endDate=new Date(Date.parse(d));
					}catch(e){
						alert("Invalid end date");
						$("#zRecurTypeRangeDate").val("");
					}
				}
			}
			return ruleObj;
		}
		self.getDaysInMonth=function(date){
			var newDate=new Date(date.getTime());
			newDate.setMonth(newDate.getMonth()+1);
			newDate.setDate(0);
			return newDate.getDate();
		};
		self.getProjectedDateCount=function(startDate){
			
			var d=$("#zRecurTypeRangeDate").val();
			var endDate=new Date();
			if(d!=""){
				try{
					endDate=new Date(Date.parse(d));
					if(endDate< new Date()){
						endDate=new Date();
					}
				}catch(e){
					alert("Invalid end date");
					endDate=new Date();
				}
			}
			var d=new Date(startDate.getTime());
			d.setFullYear(d.getFullYear()+2);
			if(endDate > d){
				d=endDate;
			}
			var count=(d-startDate)/(1000*60*60*24);
			console.log("Project "+count+" days | startDate:"+startDate.toString()+" | endDate:"+d.toString());
			return count;
			/*
			var projectedDateCount=0;
			var monthCount=Math.max(24, Math.floor($(".zRecurPreviewBox").width()/calendarWidth)*calendarRows);
			var d=new Date(startDate.getTime());
			for(var i=0;i<monthCount;i++){
				var daysInMonth=self.getDaysInMonth(d);
				projectedDateCount+=daysInMonth;
				d.setMonth(d.getMonth()+1);
			}
			return projectedDateCount;*/
		};
		self.lastDayOfWeekOfMonth=function(date, day){
			var month = date.getMonth();
			var year = date.getFullYear(); 
			var d = new Date(year,month+1,0);
			if(day==-1){
				return d;
			}
			while (d.getDay() != day) {
				d.setDate(d.getDate() -1);
			}
			return d;
		};

		/* self.isNthDay(new Date(), 1, 2); */
		self.isNthDay=function(theDate, dayOfWeek, dayNum){
			if(Math.ceil(theDate.getDate()/7) == dayNum){
				if(theDate.getDay() == dayOfWeek){
					return true;
				}
			}
			return false;
		}
		self.getMarkedDates=function(){
			var arrDate=[];
			var startDate=$("#event_start_datetime_date").val();
			if(startDate == ""){
				return arrDate;
			}
			try{ 
				var currentDate=new Date(Date.parse(startDate));
				var originalCurrentDate=currentDate;
				if(currentDate< new Date()){
					currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1); 
				}
			}catch(e){
				return arrDate;
			}
			var startTime=currentDate.getTime();
			// this was wrong...
			//currentDate.setDate(1);


			var ruleObj=self.getRulesFromForm();
			if(ruleObj.recurLimit != 0){
				var projectedDateCount=50000;
				console.log("Project "+projectedDateCount+" days | startDate:"+startDate.toString());
			}else{
				var projectedDateCount=self.getProjectedDateCount(originalCurrentDate);
			}


			//console.log("projectedDateCount:"+projectedDateCount);
			var arrDebugDate=[];
			var recurCount=0;
			//console.log(ruleObj);

			//return arrDate;

			var lastDate=new Date(currentDate.getTime());
			lastDate.setDate(lastDate.getDate()+projectedDateCount);
			var lastTime=lastDate.getTime();

			// weekly fields
			var arrWeeklyDayLookup={
				0:false,
				1:false,
				2:false,
				3:false,
				4:false,
				5:false,
				6:false
			};
			var weeklyLookupCount=ruleObj.arrWeeklyDays.length; 
			for(var i=0;i<ruleObj.arrWeeklyDays.length;i++){
				arrWeeklyDayLookup[ruleObj.arrWeeklyDays[i]]=true;
			}

			var monthlyDayLookup=[];
			for(var i=0;i<ruleObj.arrMonthlyCalendarDay.length;i++){
				monthlyDayLookup[ruleObj.arrMonthlyCalendarDay[i]]=true;
			}
			var monthDayCount=0;
			var monthDayCountMonth=-1;
			var monthlyLastDayOfWeekMatch=0;

			try{
				var d=dayLookup[ruleObj.monthlyDay];
			}catch(e){
				alert("Invalid value for ruleObj.monthlyDay: "+ruleObj.monthlyDay);
				return arrDate;
			}
			try{
				var d=dayLookup[ruleObj.monthlyDay];
			}catch(e){
				alert("Invalid value for ruleObj.monthlyDay: "+ruleObj.monthlyDay);
				return arrDate;
			}
			var lastDayOfMonth=0;
			var firstMonth=true;
			var totalMonthCount=0;
			var firstWeek=true;
			var firstYear=true;
			var lastYear=currentDate.getFullYear();
			var firstDay=true;


			//var endDate=new Date($("#event_end_datetime_date").val()); 
			for(var i=0;i<projectedDateCount;i++){ 
				if(i == 50000){
					alert("Infinite loop detected");
					break;
				}
				if(!firstDay && ruleObj.recurType == "Daily" && ruleObj.skipDays-1){
					currentDate.setDate(currentDate.getDate()+(ruleObj.skipDays-1));
				}
				if(!firstWeek && ruleObj.recurType == "Weekly" && currentDate.getDay()==0){
					if(ruleObj.skipWeeks-1){
						currentDate.setDate(currentDate.getDate()+((ruleObj.skipWeeks-1)*7));
					}
				}
				if(monthDayCountMonth != currentDate.getMonth()){
					totalMonthCount++;
					if(ruleObj.recurType == "Monthly"){
						if(!firstMonth && currentDate.getDate() == 1 && ruleObj.skipMonths-1){
							currentDate.setMonth(currentDate.getMonth()+(ruleObj.skipMonths-1));
						}
						firstMonth=false;
					}else if(ruleObj.recurType == "Annually"){
						if(currentDate.getFullYear()!=lastYear && ruleObj.skipYears-1){
							currentDate.setFullYear(currentDate.getFullYear()+(ruleObj.skipYears-1));
							lastYear=currentDate.getFullYear();
						}
					}
					monthDayCount=0;
					monthDayCountMonth=currentDate.getMonth();
					lastDayOfMonth=new Date(currentDate);
					lastDayOfMonth.setMonth(lastDayOfMonth.getMonth()+1);
					lastDayOfMonth.setDate(0);
					var lastDayOfMonthTime=lastDayOfMonth.getTime();
					if(ruleObj.monthlyDay != ""){
						monthlyLastDayOfWeekMatch=self.lastDayOfWeekOfMonth(currentDate, dayLookup[ruleObj.monthlyDay]);
					}
					if(ruleObj.annuallyDay != ""){
						monthlyLastDayOfWeekMatch=self.lastDayOfWeekOfMonth(currentDate, dayLookup[ruleObj.annuallyDay]);
					}
				}
				var day=currentDate.getDay();
				var debugDate=new Date(currentDate.getTime());
				var currentTime=currentDate.getTime(); 
				var isEvent=false;
				var disableEvent=false;
				/*if(currentDate.getTime() > endDate.getTime()){ 
					break;
				}*/
				if(!ruleObj.noEndDate && typeof ruleObj.endDate != "boolean"){
					if(currentTime > ruleObj.endDate.getTime()){
						break;
					}
				}
				/*if(typeof arrExclude[currentTime] != "undefined"){
				//	disableEvent=true;
				}*/
				if(ruleObj.recurType == "Daily"){
					if(ruleObj.everyWeekday){
						if(day != 0 && day != 6){
							isEvent=true;
						}
					}else{
						isEvent=true;
					}
				}else if(ruleObj.recurType == "Weekly"){
					if(arrWeeklyDayLookup[day]){
						isEvent=true;
					}
				}else if(ruleObj.recurType == "Monthly"){
					if(ruleObj.arrMonthlyCalendarDay.length){
						if(typeof monthlyDayLookup[0] != "undefined" && currentTime == lastDayOfMonthTime){
							isEvent=true;
						}
						if(typeof monthlyDayLookup[currentDate.getDate()] != "undefined"){
							isEvent=true;
						}
					}else{
						if(ruleObj.monthlyDay != ""){
							var dayMatch=false;
							if(ruleObj.monthlyDay == "Day"){
								monthDayCount++;	
								dayMatch=true;
							}else if(day == dayLookup[ruleObj.monthlyDay]){
								monthDayCount++;	
								dayMatch=true;
							}

							if(ruleObj.monthlyWhich == "Every"){
								if(dayMatch){
									isEvent=true;
								}
							}else if(ruleObj.monthlyWhich == "The Last"){
								if(dayMatch && currentDate.getDate() == monthlyLastDayOfWeekMatch.getDate()){
									isEvent=true;
								}
							}else if(ruleObj.monthlyDay == "Day"){
								if(currentDate.getDate() == whichLookup[ruleObj.monthlyWhich]){
									isEvent=true;
								}
							}else{
								if(dayMatch && self.isNthDay(currentDate, day, whichLookup[ruleObj.monthlyWhich])){
									isEvent=true;
								}
							}
						}
					}
				}else if(ruleObj.recurType == "Annually"){

					if(currentDate.getMonth() == ruleObj.annuallyMonth){

						if(ruleObj.annuallyDay != ""){
							var dayMatch=false;
							if(ruleObj.annuallyDay == "Day"){
								monthDayCount++;	
								dayMatch=true;
							}else if(day == dayLookup[ruleObj.annuallyDay]){
								monthDayCount++;	
								dayMatch=true;
							}
							if(ruleObj.annuallyWhich == "Every"){
								if(dayMatch){
									isEvent=true;
								}
							}else if(ruleObj.annuallyWhich == "The Last"){
								if(dayMatch && currentDate.getDate() == monthlyLastDayOfWeekMatch.getDate()){
									isEvent=true;
								}
							}else if(ruleObj.annuallyDay == "Day"){
								if(currentDate.getDate() == whichLookup[ruleObj.annuallyWhich]){
									isEvent=true;
								}
							}else{
								if(dayMatch && self.isNthDay(currentDate, day, whichLookup[ruleObj.annuallyWhich])){
									isEvent=true;
								}
							}
						}else{
							if(ruleObj.annuallyWhich == currentDate.getDate()){
								isEvent=true;
							}
						}
					}
				}
				if(currentTime==startTime){
					if(!isEvent){
						recurCount--;
					}
					isEvent=true;
				}
				currentDate.setDate(currentDate.getDate()+1);
				if(isEvent){
					if(!disableEvent && currentTime>=startTime && currentTime<=lastTime){
						arrDate[currentTime]=true;
						arrDebugDate.push(debugDate.toGMTString());
						recurCount++;
						firstDay=false;
						firstWeek=false;
					}
				}
				if(ruleObj.recurLimit != 0 && recurCount==ruleObj.recurLimit){
					break;
				}
			}
			//console.log('projectedDateCount:'+projectedDateCount);
			//console.log(arrDebugDate);
			//console.log(arrDebugDate);
			return arrDate;
		}

		self.convertFromRRuleToRecurringEvent=function(r){
			var rule = RRule.fromString(r);
			var options=rule.options;
			console.log(rule);
			console.log(rule.toString()); 
			/*

			docs: 
			https://www.npmjs.org/package/rrule
			http://www.kanzaki.com/docs/ical/rrule.html

			byeaster: null
			byhour: Array[1]
			byminute: Array[1]
			bymonth: Array[1]
			bymonthday: Array[1]
			bynmonthday: Array[0]
			bynweekday: null
			bysecond: Array[1]
			bysetpos: null
			byweekday: null
			byweekno: null
			byyearday: null
			count: 3
			dtstart: Sun Aug 17 2014 09:45:07 GMT-0400 (Eastern Daylight Time)
			freq: 0
			interval: 1
			until: null
			wkst: 0

			TODO: need to add support for dtstart and until
			*/
			if(options.byeaster == null){
				options.byeaster=[];
			}
			if(options.byhour == null){
				options.byhour=[];
			}
			if(options.byminute == null){
				options.byminute=[];
			}
			if(options.bymonth == null){
				options.bymonth=[];
			}
			if(options.bymonthday == null){
				options.bymonthday=[];
			}
			if(options.bynmonthday == null){
				options.bynmonthday=[];
			}
			if(options.bynweekday == null){
				options.bynweekday=[];
			}
			if(options.bysecond == null){
				options.bysecond=[];
			}
			if(options.bysetpos == null){
				options.bysetpos=[];
			}
			if(options.byweekday == null){
				options.byweekday=[];
			}
			if(options.byweekno == null){
				options.byweekno=[];
			}
			if(options.byyearday == null){
				options.byyearday=[];
			}
			if(options.bymonth.length > 1 || options.bynweekday.length > 1 || 
				options.byeaster.length > 0 || options.bynmonthday.length > 1 || options.bysetpos.length > 0){ 
				//options.bymonthday.length > 1 || 
				console.log(options);
				throw("Unsupported RRule: "+r);
			}
			var ruleObj={};
			ruleObj.recurLimit=options.count;
			/*if(options.dtstart != null){
				$("#event_start_datetime_date").val((options.dtstart.getMonth()+1)+"/"+options.dtstart.getDate()+"/"+options.dtstart.getFullYear());
				var hours=options.dtstart.getHours();
				var ampm="am";
				if(hours>12){
					hours-12;
					ampm="pm";
				}
				$("#event_start_datetime_time").val(hours+":"+options.dtstart.getMinutes()+" "+ampm);
			}
			if(options.dtend != null){
				$("#event_end_datetime_date").val((options.dtstart.getMonth()+1)+"/"+options.dtstart.getDate()+"/"+options.dtstart.getFullYear());
				var hours=options.dtend.getHours();
				var ampm="am";
				if(hours>12){
					hours-12;
					ampm="pm";
				}
				$("#event_end_datetime_time").val(hours+":"+options.dtend.getMinutes()+" "+ampm);
			}*/
			if(typeof options.until != "undefined" && options.until != null && options.until != ""){
				ruleObj.endDate=options.until;
				ruleObj.recurLimit=0;
			}
			if(options.freq == RRule.YEARLY){
				ruleObj.recurType="Annually";
				if(options.bynweekday.length){
					if(typeof pythonDayNameLookup[options.bynweekday[0][0]] == "undefined"){
						alert('Invalid bynweekday value.');
						return [];
					}
					ruleObj.annuallyDay=pythonDayNameLookup[options.bynweekday[0][0]];
					if(options.bynweekday[0][1]==-1){
						ruleObj.annuallyWhich="The Last";
					}else if(options.bynweekday[0][1]<0){
						throw("Unsupported RRule: "+r);
					}else{
						ruleObj.annuallyWhich=whichNameLookup[options.bynweekday[0][1]];
					}
				}else if(options.byweekday.length){
					if(typeof pythonDayNameLookup[options.byweekday[0]] == "undefined"){
						alert('Invalid byweekday value.');
						return [];
					}
					ruleObj.annuallyWhich="Every";
					ruleObj.annuallyDay=pythonDayNameLookup[options.byweekday[0]];
					if(options.byweekday.length == 7){
						ruleObj.annuallyDay="Day";
					}else if(options.byweekday.length>1){
						throw("Unsupported RRule: "+r);
					}
				}else if(options.byyearday.length){
					throw("RRULE BYYEARDAY is not implemented in zRecurringEvent");
				}else if(options.bymonthday.length){
					ruleObj.annuallyWhich=options.bymonthday[0];
				}else if(options.bynmonthday.length){
					ruleObj.annuallyDay="Day";
					ruleObj.annuallyWhich="The Last";
				}else{
					throw("Unsupported RRule: "+r);
				}
				ruleObj.skipYears=options.interval;
				ruleObj.annuallyMonth=options.bymonth[0];
			}else if(options.freq == RRule.MONTHLY){
				ruleObj.recurType="Monthly";
				ruleObj.skipMonths=options.interval;
				if(options.bynweekday.length){
					if(typeof pythonDayNameLookup[options.bynweekday[0][0]] == "undefined"){
						alert('Invalid bynweekday value.');
						return [];
					}
					ruleObj.monthlyDay=pythonDayNameLookup[options.bynweekday[0][0]];
					if(options.bynweekday[0][1]==-1){
						ruleObj.monthlyWhich="The Last";
					}else if(options.bynweekday[0][1]<0){
						throw("Unsupported RRule: "+r);
					}else{
						ruleObj.monthlyWhich=whichNameLookup[options.bynweekday[0][1]];
					}
					console.log('day lookup:'+options.bynweekday[0][0]+":"+pythonDayNameLookup[1]+" python:"+pythonDayNameLookup[options.bynweekday[0][0]]+" final day:"+ruleObj.monthlyDay);
				}else if(options.byweekday.length){
					if(typeof pythonDayNameLookup[options.byweekday[0]] == "undefined"){
						alert('Invalid byweekday value.');
						return [];
					}
					ruleObj.monthlyWhich="Every";
					ruleObj.monthlyDay=pythonDayNameLookup[options.byweekday[0]];
					if(options.byweekday.length == 7){
						ruleObj.monthlyDay="Day";
					}else if(options.byweekday.length>1){
						throw("Unsupported RRule: "+r);
					}

					if(options.bymonthday.length){
						throw("Unsupported RRule (bymonthday is missing from monthly interface in zRecurringEvent): "+r);
					}
				}else if(options.bymonthday.length){
					ruleObj.arrMonthlyCalendarDay=options.bymonthday;
				}else if(options.bynmonthday.length){
					ruleObj.monthlyDay="Day";
					ruleObj.monthlyWhich="The Last";
				}else{
					throw("Unsupported RRule: "+r);
				}

			}else if(options.freq == RRule.WEEKLY){
				ruleObj.recurType="Weekly";
				ruleObj.skipWeeks=options.interval;
				if(options.byweekday.length){
					ruleObj.arrWeeklyDays=[];
					for(var i=0;i<options.byweekday.length;i++){
						ruleObj.arrWeeklyDays.push(pythonDayToJs[options.byweekday[i]]);
					}
				}else{
					throw("Unsupported RRule: "+r);
				}
			}else if(options.freq == RRule.DAILY){
				ruleObj.recurType="Daily";
				if(options.byweekday.length){
					if(options.byweekday.length != 5){
						throw("Unsupported RRule: "+r);
					}
					for(var i=0;i<options.byweekday.length;i++){
						if(options.byweekday[i] == 6 || options.byweekday[i] == 5){
							throw("Unsupported RRule: "+r);
						}
					}
					ruleObj.everyWeekday=true;
					ruleObj.skipDays=1;
				}else{
					ruleObj.skipDays=options.interval;
				}
			}else if(options.freq == RRule.HOURLY){
				throw("FREQ=HOURLY is not implemented in zRecurringEvent");
			}else if(options.freq == RRule.MINUTELY){
				throw("FREQ=MINUTELY is not implemented in zRecurringEvent");
			}else if(options.freq == RRule.SECONDLY){
				throw("FREQ=SECONDLY is not implemented in zRecurringEvent");
			}
			return ruleObj;
		};

		self.convertFromRecurringEventToRRule=function(ruleObj){
			var options={
				byeaster: [],
				byhour: [],
				byminute: [],
				bymonth: [],
				bymonthday: [],
				bynmonthday: [],
				bynweekday: [],
				bysecond: [],
				bysetpos: [],
				byweekday: [],
				byweekno: [],
				byyearday: [],
				count: 0,
				dtstart: null,
				freq: 0,
				interval: 1,
				until: null
			}; 
			if(typeof ruleObj.endDate != "undefined" && ruleObj.endDate != "" && ruleObj.endDate != false && ruleObj.endDate != null){
				options.until=ruleObj.endDate;
			}else{
				options.until=null;
			}
			if(typeof ruleObj.recurLimit != "undefined"){
				options.count=ruleObj.recurLimit;
			}
			if(ruleObj.recurType=="None"){
				var rule = new RRule({});
				console.log(rule);
				console.log(rule.toString()); 
				return rule;
			}else if(ruleObj.recurType=="Annually"){
				options.freq=RRule.YEARLY;
				if(ruleObj.annuallyDay !="" && ruleObj.annuallyWhich!="" && ruleObj.annuallyWhich!="Every"){
					//?
					if(ruleObj.annuallyDay == "Day"){
						options.bymonthday[0]=whichLookup[ruleObj.annuallyWhich];
					}else{
						options.byweekday[0]=pythonDayLookup[ruleObj.annuallyDay];
						if(ruleObj.annuallyWhich=="The Last"){
							options.byweekday[0]=RRule[pythonDayToRRuleName[options.byweekday[0]]].nth(-1); // The Last
						}else{
							options.byweekday[0]=RRule[pythonDayToRRuleName[options.byweekday[0]]].nth(whichLookup[ruleObj.annuallyWhich]);
						}
					}
				}else if(ruleObj.annuallyDay!="" && ruleObj.annuallyWhich=="Every"){
					if(ruleObj.annuallyDay == "Day"){
						options.byweekday=("0,1,2,3,4,5,6").split(",");
					}else{
						options.byweekday[0]=pythonDayLookup[ruleObj.annuallyDay];
					}
				}else{
					options.bymonthday[0]=ruleObj.annuallyWhich;
				}
				options.interval=ruleObj.skipYears;
				options.bymonth[0]=ruleObj.annuallyMonth;
			}else if(ruleObj.recurType=="Monthly"){
				options.freq = RRule.MONTHLY;
				options.interval=ruleObj.skipMonths;
				if(ruleObj.monthlyWhich!="" && ruleObj.monthlyWhich!="Every"){
					if(ruleObj.monthlyDay == "Day"){
						options.bymonthday[0]=whichLookup[ruleObj.monthlyWhich];
					}else{
						options.byweekday[0]=pythonDayLookup[ruleObj.monthlyDay];
						if(ruleObj.monthlyWhich=="The Last"){
							options.byweekday[0]=RRule[pythonDayToRRuleName[options.byweekday[0]]].nth(-1);
						}else{
							options.byweekday[0]=RRule[pythonDayToRRuleName[options.byweekday[0]]].nth(whichLookup[ruleObj.monthlyWhich]);
						}
					}
				}else if(ruleObj.monthlyWhich=="Every"){
					if(ruleObj.monthlyDay == "Day"){
						options.byweekday=("0,1,2,3,4,5,6").split(",");
					}else{
						options.byweekday[0]=pythonDayLookup[ruleObj.monthlyDay];
					}

				}else{
					options.bymonthday=ruleObj.arrMonthlyCalendarDay;
				}

			}else if(ruleObj.recurType == "Weekly"){
				options.freq = RRule.WEEKLY;
				options.interval=ruleObj.skipWeeks;
				if(ruleObj.arrWeeklyDays.length){
					for(var i=0;i<ruleObj.arrWeeklyDays.length;i++){
						options.byweekday.push(jsDayToPython[ruleObj.arrWeeklyDays[i]]);
					}
				}
			}else if(ruleObj.recurType == "Daily"){
				options.interval=ruleObj.skipDays;
				options.freq = RRule.DAILY;
				if(ruleObj.everyWeekday){
					options.byweekday=[0,1,2,3,4];
				}
			}
			for(var i in options){
				if(options[i] != null && typeof options[i].length != "undefined" && options[i].length == 0){
					delete options[i];
				}
			}
			var rule = new RRule(options);
			console.log(rule);
			console.log(rule.toString()); 
			return rule;
		};
		init(options);
		return this;
	}; 
	window.zRecurringEvent=zRecurringEvent;
})(jQuery, window, document, "undefined"); 
