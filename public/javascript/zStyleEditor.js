
(function($, window, document, undefined){
	"use strict";
	
var zStyleEditor=function(options){
	var self=this;

 
	var config=options.config;
	if(config == ""){
		config={
			fonts:{},
			sizes:{},
			colors:{}
		};
	}
	if(typeof config.fonts == "undefined"){
		config.fonts={};
	}
	if(typeof config.sizes == "undefined"){
		config.sizes={};
	}
	if(typeof config.colors == "undefined"){
		config.colors={};
	}
	if(typeof options === undefined){
		options={};
	} 
	options.newWidth=zso(options, 'newWidth', false, 960); 

	function executeParentCallback(){ 
		var f=window.parent.document.getElementById(options.field);
		if(typeof f != "undefined" && f){
			f.value=JSON.stringify(config);
		}
	}    
	function bindEvents(){
		$("#"+options.formId+" input").on("keyup paste", function(e){
			editorChanged();
		});
	}
	function editorChanged(){
		// read form state and store changes in config
		var obj=zGetFormDataByFormId(options.formId);
		for(var i in fontFields){
			var field=fontFields[i];
			var defaultValue=options.defaultConfig.fonts[field.field];
			var newValue=obj[field.field]; 
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
		//console.log('editorChanged');
		//console.log(config);
		executeParentCallback();
	} 
	function getInputElement(fc, suffix){
		var arrHTML=[]; 
		if(fc.type == "text"){ 
			var style='width:'+fc.width+'; min-width:'+fc.width+';"; ';
			arrHTML.push('<input type="text" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" style="'+style+'" value="'+htmlEntities.encode(fc.value)+'">');
		}else if(fc.type == "pixelNumber"){ 
			width="60px";
			var style='width:'+width+'; min-width:'+width+';"; ';
			arrHTML.push('<input type="text" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" style="'+style+'" value="'+htmlEntities.encode(fc.value)+'"> px');
		}else if(fc.type == "color"){
			var style='width:'+fc.width+'; min-width:'+fc.width+';"; ';
			arrHTML.push('<input type="text" class="zColorInput" onkeyup="this.value.replace(\'#\', \'\');" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" style="'+style+'" value="'+htmlEntities.encode(fc.value)+'">'); 
		}else if(fc.type == "marginPaddingBorder"){
			var arrValue=fc.value.split(",");
			if(arrValue.length != 4){
				arrValue=["", "", "", ""];
			}
			var width="35px";
			var margin="5px";
			var style='margin-right:'+margin+'; margin-bottom:'+margin+'; width:'+width+'; min-width:'+width+';"; ';
			var styleBottom='margin-right:'+margin+'; margin-bottom:'+margin+'; width:50px; min-width:50px;"; ';
			arrHTML.push('<div style="width:100%; text-align:center;"><input type="text" placeholder="top" name="'+fc.name+suffix+'_top" id="'+fc.name+suffix+'_left" style="'+styleBottom+'" value="'+htmlEntities.encode(arrValue[0])+'"></div>');
			arrHTML.push('<div style="width:100%; "><div style="width:50%; text-align:left; float:left;"><input type="text" placeholder="left" name="'+fc.name+suffix+'_left" id="'+fc.name+suffix+'_left" style="'+style+'" value="'+htmlEntities.encode(arrValue[3])+'"></div>');
			arrHTML.push('<div style="width:50%; text-align:right; float:right;"><input type="text" placeholder="right" name="'+fc.name+suffix+'_right" id="'+fc.name+suffix+'_right" style="'+style+'" value="'+htmlEntities.encode(arrValue[1])+'"></div></div>');
			arrHTML.push('<div style="width:100%; text-align:center;"><input type="text" placeholder="bottom" name="'+fc.name+suffix+'_bottom" id="'+fc.name+suffix+'_bottom" style="'+styleBottom+'" value="'+htmlEntities.encode(arrValue[2])+'"></div>');
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

		zArrScrollFunctions.push({functionName:scrollStyleEditor});
		scrollStyleEditor();
	}
	function buildStyleEditor(){
		var arrHTML=[];
		var labelWidth="190px";
		var breakWidth="100px";
		arrHTML.push('<div class="zStyleEditorFixed" style=" font-weight:bold; float:left; display:none; position:fixed; background-color:#FFF; color:#000;"><div style="float:left; padding: 8px; padding-left: 3px;  width:'+labelWidth+';">&nbsp;</div>');
		if(!options.breakpoints){
			breakpointFields=["Default"];
		}
		var fullColspan=(breakpointFields.length+1);
		for(var i in breakpointFields){
			arrHTML.push('<div style="float:left; width:'+breakWidth+'; padding: 8px; padding-left: 3px;  ">'+breakpointFields[i]+'</div>');
		}
		arrHTML.push('</div>');
		arrHTML.push('<table class="table-list">');
		arrHTML.push('<tr style=" background-color:#FFF; color:#000;"><th style="width:'+labelWidth+';">&nbsp;</th>');
		if(!options.breakpoints){
			breakpointFields=["Default"];
		}
		var fullColspan=(breakpointFields.length+1);
		for(var i in breakpointFields){
			arrHTML.push('<th style="width:'+breakWidth+';">'+breakpointFields[i]+'</th>');
		}
		arrHTML.push('</tr>');
		if(options.sizes){
			arrHTML.push('<tr><td colspan="'+fullColspan+'"><h3>Adjust sizes</h3></td></tr>');
			for(var field in sizeFields){
				var fd=sizeFields[field];
				if(typeof config.sizes[fd.field] == "undefined"){
					config.sizes[fd.field]={};
					for(var i in breakpointFields){
						config.sizes[fd.field][breakpointFields[i]]="";
					}
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th style="white-space:nowrap; width:'+labelWidth+';">'+fd.label+'</th>');
				for(var i in breakpointFields){
					var value=config.sizes[fd.field][breakpointFields[i]];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						width:"200px"
					};
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td>'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
		}
		if(options.colors){
			arrHTML.push('<tr><td colspan="'+fullColspan+'"><h3>Adjust colors</h3></td></tr>');
			for(var field in colorFields){
				var fd=colorFields[field];
				if(typeof config.colors[fd.field] == "undefined"){
					config.colors[fd.field]={};
					for(var i in breakpointFields){
						config.colors[fd.field][breakpointFields[i]]="";
					}
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th style="white-space:nowrap; width:'+labelWidth+';">'+fd.label+'</th>');
				for(var i in breakpointFields){
					var value=config.colors[fd.field][breakpointFields[i]];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						width:"60px"
					};
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td>'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
		}
		if(options.fonts){
			arrHTML.push('<tr><td colspan="'+fullColspan+'"><h3>Adjust fonts</h3><p>Please type in the font-family, font-weight, font-style CSS combination that will trigger the font to be applied.</p></td></tr>');
			for(var index in fontFields){
				var fd=fontFields[index]; 
				if(typeof config.fonts[fd.field] == "undefined"){
					config.fonts[fd.field]="";
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th style="white-space:nowrap; width:'+labelWidth+';">'+fd.label+'</th>');
				for(var i in breakpointFields){ 
					var value=config.fonts[fd.field];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						width:"100%"
					};
					var suffix="";
					arrHTML.push('<td colspan="'+fullColspan+'">'+getInputElement(fc, suffix)+'</td>');
					break;
				}
				arrHTML.push('</tr>');
			}
		}
		
		arrHTML.push('</table>');
		arrHTML.push('<div class="z-float z-p-10"><a href="##" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Close</a></div>'); 
		var c=$(options.container);
		c.html(arrHTML.join(""));
		jscolor.bind();
		bindEvents();
	} 
	
	var fontFields=[
		{
			field:"text_font",
			label:"Text Font",
			type:"text"
		},
		{
			field:"text_bold_font",
			label:"Text Bold Font",
			type:"text"
		},
		{
			field:"text_bold_italic_font",
			label:"Text Bold Italic Font",
			type:"text"
		}, 
		{
			field:"text_italic_font",
			label:"Text Italic Font",
			type:"text"
		},
		{
			field:"heading_1_font",
			label:"Heading 1 Font",
			type:"text"
		},
		{
			field:"heading_2_font",
			label:"Heading 2 Font",
			type:"text"
		},
		{
			field:"heading_3_font",
			label:"Heading 3 Font",
			type:"text"
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
			type:"pixelNumber"
		},
		{
			field:"heading_1_size",
			label:"Heading 1 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_2_size",
			label:"Heading 2 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_3_size",
			label:"Heading 3 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_line_height",
			label:"Heading Line Height",
			type:"pixelNumber"
		},
		{
			field:"text_padding",
			label:"Text Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"heading_padding",
			label:"Heading Padding",
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
		},
		{
			field:"button_padding",
			label:"Button Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"button_text_size",
			label:"Button Text Size",
			type:"pixelNumber"
		}
	];
 
	var colorFields=[
		{
			field:"container_background_color",
			label:"Container BG Color",
			type:"color"
		},
		{
			field:"background_color",
			label:"BG Color",
			type:"color"
		},
		{
			field:"text_color",
			label:"Text Color",
			type:"color"
		},
		{
			field:"link_color",
			label:"Link Color",
			type:"color"
		},
		{
			field:"link_hover_color",
			label:"Link Hover Color",
			type:"color"
		},
		{
			field:"button_background_color",
			label:"Button BG Color",
			type:"color"
		},
		{
			field:"button_color",
			label:"Button Color",
			type:"color"
		},
		{
			field:"accent_container_background_color",
			label:"Accent Container BG Color",
			type:"color"
		},
		{
			field:"accent_background_color",
			label:"Accent BG Color",
			type:"color"
		},
		{
			field:"accent_text_color",
			label:"Accent Text Color",
			type:"color"
		},
		{
			field:"accent_link_text_color",
			label:"Accent Link Text Color",
			type:"color"
		},
		{
			field:"accent_link_hover_color",
			label:"Accent Link Hover Color",
			type:"color"
		},
		{
			field:"accent_button_background_color",
			label:"Accent Button BG Color",
			type:"color"
		},
		{
			field:"accent_button_color",
			label:"Accent Button Color",
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
