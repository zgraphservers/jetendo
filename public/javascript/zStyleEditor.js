
(function($, window, document, undefined){
	"use strict";
	
var zStyleEditor=function(options){
	var self=this;

 
	var config=options.config;
	if(config == ""){
		config={
			fonts:{},
			sizes:{},
			spaces:{},
			colors:{}
		};
	}
	if(typeof options.selector == "undefined"){
		options.selector="body ";
	}
	if(typeof config.fonts == "undefined"){
		config.fonts={};
	}
	if(typeof config.sizes == "undefined"){
		config.sizes={};
	}
	if(typeof config.spaces == "undefined"){
		config.spaces={};
	}
	if(typeof config.colors == "undefined"){
		config.colors={};
	}
	if(typeof options === undefined){
		options={};
	} 

	function executeParentCallback(){ 
		var f=window.parent.document.getElementById(options.field);
		if(typeof f != "undefined" && f){
			f.value=JSON.stringify(config);
		}
	}    
	function bindEvents(){
		$("#"+options.formId+" input").on("mousewheel keyup paste", function(e){
			editorChanged();
		});

		$("#"+options.formId+" .zColorEditLink").on("click", function(e){
			e.preventDefault();
			var field=$(this).attr("data-field");
			$("#"+options.formId+" ."+field+"_color").show();
			$("#"+options.formId+" ."+field+"_color_box").hide();
			$(this).hide();
			$("#"+options.formId+" ."+field+"_color_reset").show();
			$("#"+options.formId+" ."+field+"_color").trigger("focus");
			if($("#"+options.formId+" ."+field).val() == ""){
				$("#"+options.formId+" ."+field).val("FFFFFF");
			}
			editorChanged();
		});
		$("#"+options.formId+" .zColorResetLink").on("click", function(e){
			e.preventDefault();
			var field=$(this).attr("data-field");
			$("#"+options.formId+" ."+field+"_color").val("FFFFFF").css("background-color", "#FFFFFF");
			$("#"+options.formId+" ."+field).val($("#"+field).attr("data-original-value"));
			$("#"+options.formId+" ."+field+"_color").hide();
			$("#"+options.formId+" ."+field+"_color_box").show();
			$(this).hide();
			$("#"+options.formId+" ."+field+"_color_edit").show();
			editorChanged();
		});
		$("#"+options.formId+" .zColorInput").on("change", function(e){
			console.log('color changed'+Math.random());
			var field=$(this).attr("data-field");
			$("#"+options.formId+" ."+field).val(this.value);
			editorChanged();
		});
	}
	var selectedBreakpoint="";
	function loadPreviewCallback(r){
		var r=JSON.parse(r);
		if(r.success){ 
			var panelHeight=$(window).height()-120;
			var panelWidth=Math.round($(window).width()*.4)-20;

			if(selectedBreakpoint != ""){
				var arrDelete=[];
				if(selectedBreakpoint == "1362"){
					arrDelete=["1362"];
				}else if(selectedBreakpoint == "992"){
					arrDelete=["1362","992"];
				}else if(selectedBreakpoint == "767"){
					arrDelete=["1362","992","767"];
				}else if(selectedBreakpoint == "479"){
					arrDelete=["1362","992","767","479"];
				}
				for(var i in arrDelete){
					r.html=r.html.replace('@media (max-width:'+arrDelete[i]+'px){', '');
					r.html=r.html.replace('} /* media-end '+arrDelete[i]+' */', ''); 
				}
			}
			$(".stylePreviewHTML").css("width", panelWidth+"px").html(r.html); 

			var previewHeight=$(".stylePreviewHTML").height();
			var previewWidth=$(".stylePreviewHTML").width();
			if(previewHeight > panelHeight){
				var scale=panelHeight/previewHeight;
				var newWidth=scale*previewWidth;
				var newHeight=panelHeight;
				if(newWidth > panelWidth){
					scale=(panelWidth)/previewWidth;
					var newHeight=scale*previewHeight;
					var newWidth=panelWidth;
				}
			}else{
				var scale=panelWidth/previewWidth;
				var newHeight=scale*previewHeight;
				var newWidth=panelWidth;

			}
			scale=Math.min(1, Math.round(scale*100)/100);
			var top=0;//-Math.round(newHeight/scale/2);
			var right=-Math.round(newWidth/scale/2);
			if(scale == 1){
				$(".stylePreviewScale").hide();
				top=40;
			}else{
				$(".stylePreviewScale").show().html("Note: Preview is scaled "+Math.round(scale*100)+"% smaller to fit");
				top=60;
			}
			$(".stylePreviewHTML").css({
				"-webkit-transform" : "scale("+scale+")",
				"-moz-transform"    : "scale("+scale+")",
				"-ms-transform"     : "scale("+scale+")",
				"-o-transform"      : "scale("+scale+")",
				"transform":"scale("+scale+")",
			    "-ms-transform-origin": "0% 0%",
			    "-webkit-transform-origin": "0% 0%",
			    "transform-origin": "0% 0%",
				"top":top+"px",
				//"right":right+"px",
				"position":"fixed"
			}); 
			$(".stylePreviewCSS").html('<textarea id="stylePreviewTextArea" cols="20" rows="5" style="height:'+panelHeight+'px; display:none; font-family:monospace; width:100%; font-size:9px;">'+htmlEntities.encode(r.css)+'</textarea>'); 
		}else{
			alert(r.errorMessage);
		}
	}
	var loadPreviewTimeoutId=false;
	function loadPreview(){

		clearTimeout(loadPreviewTimeoutId);
		loadPreviewTimeoutId=setTimeout(function(){
			var tempObj={};
			tempObj.id="zLoadPreview";
			tempObj.url="/z/misc/styleEditor/modalStylePreview";
			tempObj.postObj={
				selector:options.selector,
				baseConfig:JSON.stringify(options.config),
				config:JSON.stringify(config)
			};
			tempObj.method="post";
			tempObj.callback=loadPreviewCallback;
			tempObj.cache=false;
			zAjax(tempObj);
		}, 500);
	}
	function editorChanged(){
		// read form state and store changes in config
		var obj=zGetFormDataByFormId(options.formId);
		for(var i in fontFields){
			var field=fontFields[i];
			var defaultValue=options.defaultConfig.fonts[field.field];
			var newValue=obj[field.field]; 
			if(newValue == "font-family:; font-weight:; font-style:;"){
				newValue=defaultValue;
			}
			if(defaultValue != newValue){
				config.fonts[field.field]=newValue;
			}else{
				config.fonts[field.field]="";
			}
		}
		for(var i in sizeFields){
			var field=sizeFields[i];
			for(var b in breakpointFields){
				var bp=breakpointFields[b];
				if(field.type == "marginPaddingBorder"){
					var defaultValue=options.defaultConfig.sizes[field.field][bp];
					var newValue=obj[field.field+"_"+bp+"_top"]+","+obj[field.field+"_"+bp+"_right"]+","+obj[field.field+"_"+bp+"_bottom"]+","+obj[field.field+"_"+bp+"_left"];
					if(newValue == ",,,"){
						newValue="";
					}
				}else{
					var defaultValue=options.defaultConfig.sizes[field.field][bp];
					var newValue=obj[field.field+"_"+bp];
				}
				if(defaultValue != newValue){
					config.sizes[field.field][bp]=newValue;
				}else{
					config.sizes[field.field][bp]="";
				}
			}
		}
		for(var i in spaceFields){
			var field=spaceFields[i];
			for(var b in breakpointFields){
				var bp=breakpointFields[b];
				if(field.type == "marginPaddingBorder"){
					var defaultValue=options.defaultConfig.spaces[field.field][bp];
					var newValue=obj[field.field+"_"+bp+"_top"]+","+obj[field.field+"_"+bp+"_right"]+","+obj[field.field+"_"+bp+"_bottom"]+","+obj[field.field+"_"+bp+"_left"];
					if(newValue == ",,,"){
						newValue="";
					}
				}else{
					var defaultValue=options.defaultConfig.spaces[field.field][bp];
					var newValue=obj[field.field+"_"+bp];
				}
				if(defaultValue != newValue){
					config.spaces[field.field][bp]=newValue;
				}else{
					config.spaces[field.field][bp]="";
				}
			}
		}
		for(var i in colorFields){
			var field=colorFields[i];
			for(var b in breakpointFields){
				var bp=breakpointFields[b];
				var defaultValue=options.defaultConfig.colors[field.field][bp];
				var newValue=obj[field.field+"_"+bp];
				if(defaultValue != newValue){
					config.colors[field.field][bp]=newValue;
				}else{
					config.colors[field.field][bp]="";
				}
			}
		}

		loadPreview();
		//console.log('editorChanged');
		//console.log(config);
		executeParentCallback();
	} 
	function getInputElement(fc, suffix){
		var arrHTML=[];  
		if(fc.type == "lineHeight"){ 
			var style='width:'+fc.width+'; min-width:'+fc.width+';"; ';
			arrHTML.push('<input type="number" step="0.1" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" style="'+style+'" value="'+htmlEntities.encode(fc.value)+'">');
		}else if(fc.type == "font"){ 
			var style='width:'+fc.width+'; min-width:'+fc.width+';"; ';
			if(fc.value == ""){
				fc.value="font-family:; font-weight:; font-style:;";
			}
			arrHTML.push('<input type="text" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" style="'+style+'" value="'+htmlEntities.encode(fc.value)+'">');
		}else if(fc.type == "pixelNumber"){ 
			width="50px";
			var style='width:'+width+'; min-width:'+width+';"; ';
			arrHTML.push('<input type="number" step="1" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" style="'+style+'" value="'+htmlEntities.encode(fc.value)+'"> px');
		}else if(fc.type == "color"){
			var style='width:46px; min-width:46px;"; ';

			// if(options.config != config){ 

			arrHTML.push('<a href="#" class="zColorEditLink '+fc.name+suffix+'_color_edit" style="display:block; float:left; padding:3px; padding-left:7px; padding-right:7px; text-decoration:none; background-color:#369; border-radius:5px; color:#FFF; " data-field="'+fc.name+suffix+'">Edit</a>');
			arrHTML.push('<span id="'+fc.name+suffix+'_color_box" style="display:none; margin-left:3px; border-radius:5px; border:1px solid #999; float:left; width:35px; height:23px; ');
			if(fc.value != ""){
				arrHTML.push('background-color:#'+fc.value+';');
			}
			arrHTML.push('"></span>');
			arrHTML.push('<input type="hidden" class="'+fc.name+suffix+'" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" data-original-value="'+htmlEntities.encode(fc.value)+'" value="'+htmlEntities.encode(fc.value)+'">');
			arrHTML.push('<input type="text" class="zColorInput '+fc.name+suffix+'_color" onkeyup="this.value.replace(\'#\', \'\');" data-field="'+fc.name+suffix+'" name="'+fc.name+suffix+'_color" id="'+fc.name+suffix+'_color" style="display:none; float:left; '+style+'" value="'+htmlEntities.encode(fc.value)+'">'); 
			arrHTML.push('<a href="#" class="zColorResetLink '+fc.name+suffix+'_color_reset" data-field="'+fc.name+suffix+'" style="display:none; padding:3px; padding-left:7px; padding-right:7px;margin-left:3px; border-radius:5px; text-decoration:none; background-color:#369; color:#FFF; float:left;">X</a>');
		}else if(fc.type == "marginPaddingBorder"){
			var arrValue=fc.value.split(",");
			if(arrValue.length != 4){
				arrValue=["", "", "", ""];
			}
			var width="45px";
			var margin="5px";
			var style='margin-right:'+margin+'; margin-bottom:'+margin+'; width:'+width+'; min-width:'+width+';"; ';
			//var styleBottom='margin-right:'+margin+'; margin-bottom:'+margin+'; width:62px; min-width:62px;"; ';
			var styleBottom='margin-right:'+margin+'; margin-bottom:'+margin+'; width:'+width+'; min-width:'+width+';"; ';
			arrHTML.push('<div style="width:100%; text-align:center;"><input type="number" step="1" placeholder="T" name="'+fc.name+suffix+'_top" id="'+fc.name+suffix+'_left" style="'+styleBottom+'" value="'+htmlEntities.encode(arrValue[0])+'"></div>');
			arrHTML.push('<div style="width:100%; "><div style="width:50%; text-align:left; float:left;"><input type="number" step="1" placeholder="L" name="'+fc.name+suffix+'_left" id="'+fc.name+suffix+'_left" style="'+style+'" value="'+htmlEntities.encode(arrValue[3])+'"></div>');
			arrHTML.push('<div style="width:50%; text-align:right; float:right;"><input type="number" step="1" placeholder="R" name="'+fc.name+suffix+'_right" id="'+fc.name+suffix+'_right" style="'+style+'" value="'+htmlEntities.encode(arrValue[1])+'"></div></div>');
			arrHTML.push('<div style="width:100%; text-align:center;"><input type="number" step="1" placeholder="B" name="'+fc.name+suffix+'_bottom" id="'+fc.name+suffix+'_bottom" style="'+styleBottom+'" value="'+htmlEntities.encode(arrValue[2])+'"></div>');
		}
		return arrHTML.join('');
	}
	function scrollStyleEditor(){
		if($(window).scrollTop() > 55){
			$(".zStyleEditorFixed").show();
		}else{
			$(".zStyleEditorFixed").hide();
		}
	}
	function init(){
		buildStyleEditor();

		$(".breakpointLink").on("click", function(e){
			e.preventDefault();
			selectedBreakpoint=$(this).attr("data-breakpoint");
			$(".selectedBreakpointDiv").html("Selected Breakpoint: "+selectedBreakpoint);
			if(selectedBreakpoint == "Default"){
				selectedBreakpoint="";
			}
			loadPreview();
		});

		zArrScrollFunctions.push({functionName:scrollStyleEditor});
		scrollStyleEditor();
		loadPreview();
		zArrResizeFunctions.push({functionName:loadPreview});
	}
	function buildStyleEditor(){
		var arrHTML=[];
		var labelWidth="130px";
		var breakWidth="110px";
		arrHTML.push('<div class="zStyleEditorFixed" style=" font-weight:bold; float:left; display:none; position:fixed; background-color:#FFF; color:#000;"><div style="float:left; padding: 3px; padding-left: 3px;  width:'+labelWidth+';"><a href="##" onclick="window.parent.zCloseModal(); return false;" class="z-manager-search-button">Close</a></div>');
		if(!options.breakpoints){
			breakpointFields=["Default"];
		}
		var fullColspan=(breakpointFields.length+1);
		for(var i in breakpointFields){
			arrHTML.push('<div style="float:left; width:'+breakWidth+';  padding: 3px; padding-top:8px; padding-right:0px; padding-left: 3px;  "><a href="#" title="Click to select this breakpoint." class="breakpointLink" style="color:#000 !important; text-decoration:none;" data-breakpoint="'+breakpointFields[i]+'">'+breakpointFields[i]+'</a></div>');
		}
		arrHTML.push('</div>');
		arrHTML.push('<table class="table-list" style="width:680px;">');
		arrHTML.push('<tr style=" background-color:#FFF; color:#000;"><th style="width:'+labelWidth+';">&nbsp;</th>');
		if(!options.breakpoints){
			breakpointFields=["Default"];
		}
		var fullColspan=(breakpointFields.length+1);
		for(var i in breakpointFields){
			arrHTML.push('<th style="width:'+breakWidth+';"><a href="#" title="Click to select this breakpoint." class="breakpointLink" data-breakpoint="'+breakpointFields[i]+'">'+breakpointFields[i]+'</a></th>');
		}
		arrHTML.push('</tr>');
		if(options.sizes){
			arrHTML.push('<tr title="Click to toggle display of these fields" onclick="$(\'.sizeRow\').toggle();" style="cursor:pointer; font-size:16px;"><td colspan="'+fullColspan+'">Adjust sizes</td></tr><tbody class="sizeRow" style="display:none;">');
			for(var field in sizeFields){
				var fd=sizeFields[field];
				if(typeof config.sizes[fd.field] == "undefined"){
					config.sizes[fd.field]={};
					for(var i in breakpointFields){
						config.sizes[fd.field][breakpointFields[i]]="";
					}
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th style="font-size:12px; font-weight:normal; white-space:nowrap; width:'+labelWidth+';">'+fd.label+'</th>');
				for(var i in breakpointFields){
					var value=config.sizes[fd.field][breakpointFields[i]];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						baseValue:"",
						width:"50px"
					};
					if(typeof options.baseConfig.sizes[fd.field] != "undefined" && typeof options.baseConfig.sizes[fd.field][breakpointFields[i]] != "undefined"){
						fc.baseValue=options.baseConfig.sizes[fd.field][breakpointFields[i]];
					}
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td style=" padding-right:3px; ');
					if(fc.value != fc.baseValue){
						arrHTML.push('background-color:#FEE;');
					}
					arrHTML.push('">'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		if(options.spaces){
			arrHTML.push('<tr title="Click to toggle display of these fields" onclick="$(\'.spaceRow\').toggle();" style="cursor:pointer; font-size:16px;"><td colspan="'+fullColspan+'">Adjust spaces</td></tr><tbody class="spaceRow" style="display:none;">');
			for(var field in spaceFields){
				var fd=spaceFields[field];
				if(typeof config.spaces[fd.field] == "undefined"){
					config.spaces[fd.field]={};
					for(var i in breakpointFields){
						config.spaces[fd.field][breakpointFields[i]]="";
					}
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th style="font-size:12px; font-weight:normal; white-space:nowrap; width:'+labelWidth+';">'+fd.label+'</th>');
				for(var i in breakpointFields){
					var value=config.spaces[fd.field][breakpointFields[i]];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						baseValue:"",
						width:"50px"
					};
					if(typeof options.baseConfig.spaces[fd.field] != "undefined" && typeof options.baseConfig.spaces[fd.field][breakpointFields[i]] != "undefined"){
						fc.baseValue=options.baseConfig.spaces[fd.field][breakpointFields[i]];
					}
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td style=" padding-right:3px;');
					if(fc.value != fc.baseValue){
						arrHTML.push('background-color:#FEE;');
					}
					arrHTML.push('">'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		if(options.colors){
			arrHTML.push('<tr title="Click to toggle display of these fields" onclick="$(\'.colorRow\').toggle();" style="cursor:pointer; font-size:16px;"><td colspan="'+fullColspan+'">Adjust colors</td></tr><tbody class="colorRow" style="display:none;">');
			for(var field in colorFields){
				var fd=colorFields[field];
				if(typeof config.colors[fd.field] == "undefined"){
					config.colors[fd.field]={};
					for(var i in breakpointFields){
						config.colors[fd.field][breakpointFields[i]]="";
					}
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th style="font-size:12px; font-weight:normal; white-space:nowrap; width:'+labelWidth+';">'+fd.label+'</th>');
				for(var i in breakpointFields){
					var value=config.colors[fd.field][breakpointFields[i]];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						baseValue:"",
						width:"50px"
					};
					if(typeof options.baseConfig.colors[fd.field] != "undefined" && typeof options.baseConfig.colors[fd.field][breakpointFields[i]] != "undefined"){
						fc.baseValue=options.baseConfig.colors[fd.field][breakpointFields[i]];
					}
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td style=" padding-right:3px;');
					if(fc.value != fc.baseValue){
						arrHTML.push('background-color:#FEE;');
					}
					arrHTML.push('">'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		if(options.fonts){
			arrHTML.push('<tr title="Click to toggle display of these fields" onclick="$(\'.fontRow\').toggle();" style="cursor:pointer; font-size:16px;"><td colspan="'+fullColspan+'">Adjust fonts</td></tr><tbody class="fontRow" style="display:none;"><tr><td colspan="'+fullColspan+'"><p>Please type in the font-family, font-weight, font-style CSS combination that will trigger the font to be applied.</p></td></tr>');
			for(var index in fontFields){
				var fd=fontFields[index]; 
				if(typeof config.fonts[fd.field] == "undefined"){
					config.fonts[fd.field]="";
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th style="font-size:12px; font-weight:normal; white-space:nowrap; width:'+labelWidth+';">'+fd.label+'</th>');
				for(var i in breakpointFields){ 
					var value=config.fonts[fd.field];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						baseValue:"",
						width:"100%"
					};
					if(typeof options.baseConfig.fonts[fd.field] != "undefined"){
						fc.baseValue=options.baseConfig.fonts[fd.field];
					}
					var suffix="";
					arrHTML.push('<td style=" padding-left:3px;');
					if(fc.value != fc.baseValue){
						arrHTML.push('background-color:#FEE;');
					}
					arrHTML.push('" colspan="'+fullColspan+'">'+getInputElement(fc, suffix)+'</td>');
					break;
				}
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		
		arrHTML.push('</table>');
		//arrHTML.push('<div class="z-float z-p-10"><a href="##" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Close</a></div>'); 
		var c=$(options.container);
		c.html(arrHTML.join(""));
		jscolor.bind();
		bindEvents();
	} 

	var fontFields=[
		{
			field:"text_font",
			label:"Text Font",
			type:"font"
		},
		{
			field:"heading_1_font",
			label:"Heading 1 Font",
			type:"font"
		},
		{
			field:"heading_2_font",
			label:"Heading 2 Font",
			type:"font"
		},
		{
			field:"heading_3_font",
			label:"Heading 3 Font",
			type:"font"
		}
	];
	var spaceFields=[
		{
			field:"text_padding",
			label:"Text Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"list_padding",
			label:"List Padding (UL/OL)",
			type:"marginPaddingBorder"
		},
		{
			field:"heading_1_padding",
			label:"Heading 1 Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"heading_2_padding",
			label:"Heading 2 Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"heading_3_padding",
			label:"Heading 3 Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"button_padding",
			label:"Button Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"padding",
			label:"Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"margin",
			label:"Margin",
			type:"marginPaddingBorder"
		}
	];
 
	var sizeFields=[
		{
			field:"text_size",
			label:"Text Size",
			type:"pixelNumber"
		},
		{
			field:"text_line_height",
			label:"Text Line Height",
			type:"lineHeight"
		},
		{
			field:"heading_1_size",
			label:"Heading 1 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_1_line_height",
			label:"Heading 1 Line Height",
			type:"lineHeight"
		},
		{
			field:"heading_2_size",
			label:"Heading 2 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_2_line_height",
			label:"Heading 2 Line Height",
			type:"lineHeight"
		},
		{
			field:"heading_3_size",
			label:"Heading 3 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_3_line_height",
			label:"Heading 3 Line Height",
			type:"lineHeight"
		},
		{
			field:"button_text_size",
			label:"Button Text Size",
			type:"pixelNumber"
		},
		{
			field:"button_line_height",
			label:"Button Line Height",
			type:"lineHeight"
		}
	];
 
	var colorFields=[
		{
			field:"container_background_color",
			label:"Container BG",
			type:"color"
		},
		{
			field:"background_color",
			label:"BG",
			type:"color"
		},
		{
			field:"text_color",
			label:"Text",
			type:"color"
		},
		{
			field:"heading_1_color",
			label:"Heading 1",
			type:"color"
		},
		{
			field:"heading_2_color",
			label:"Heading 2",
			type:"color"
		},
		{
			field:"heading_3_color",
			label:"Heading 3",
			type:"color"
		},
		{
			field:"link_color",
			label:"Link",
			type:"color"
		},
		{
			field:"link_hover_color",
			label:"Link Hover",
			type:"color"
		},
		{
			field:"button_background_color",
			label:"Button BG",
			type:"color"
		},
		{
			field:"button_color",
			label:"Button",
			type:"color"
		},
		{
			field:"button_hover_background_color",
			label:"Button Hover BG",
			type:"color"
		},
		{
			field:"button_hover_color",
			label:"Button Hover",
			type:"color"
		},
		{
			field:"accent_container_background_color",
			label:"Accent Container BG",
			type:"color"
		},
		{
			field:"accent_background_color",
			label:"Accent BG",
			type:"color"
		},
		{
			field:"accent_text_color",
			label:"Accent Text",
			type:"color"
		},
		{
			field:"accent_heading_1_color",
			label:"Accent Heading 1",
			type:"color"
		},
		{
			field:"accent_heading_2_color",
			label:"Accent Heading 2",
			type:"color"
		},
		{
			field:"accent_heading_3_color",
			label:"Accent Heading 3",
			type:"color"
		},
		{
			field:"accent_link_color",
			label:"Accent Link",
			type:"color"
		},
		{
			field:"accent_link_hover_color",
			label:"Accent Link Hover",
			type:"color"
		},
		{
			field:"accent_button_background_color",
			label:"Accent Button BG",
			type:"color"
		},
		{
			field:"accent_button_color",
			label:"Accent Button",
			type:"color"
		},
		{
			field:"accent_button_hover_background_color",
			label:"Accent Button Hover BG",
			type:"color"
		},
		{
			field:"accent_button_hover_color",
			label:"Accent Button Hover",
			type:"color"
		}
	];
	var breakpointFields=[
		"Default", "1362", "992", "767", "479"
	];
	init();

	return this;
};
window.zStyleEditor=zStyleEditor;


})(jQuery, window, document, "undefined"); 
