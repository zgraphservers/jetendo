<cfcomponent> 
<cfoutput>
<!--- 
You can debug the styleEditor more quickly with this URL:
/z/misc/styleEditor/modalStyleEditor?field=styleset&debug=1
 --->
<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	</cfscript>
	<h2>Testing styleset editor</h2>
	<cfscript>
	ts={
		name:"styleset",
		editFonts:true,
		editSizes:true,
		editColors:true,
		editBreakpoints:true,
		externalStylesheet:false
	};
	// application.zcore.functions.
	echo(zStylesetEditor(ts));  
	</cfscript>
</cffunction>

<cffunction name="getDefaultConfig" localmode="modern" access="public">
	<cfscript>
	ts={
		colors:{
			accent_background_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			accent_button_background_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			accent_button_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			accent_container_background_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			accent_link_hover_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			accent_link_text_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			accent_text_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			background_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			button_background_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			button_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			container_background_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			link_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			link_hover_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"},
			text_color:{"479": "FFFFFF", "767": "FFFFFF", "992": "FFFFFF", "1362": "FFFFFF", "Default": "FFFFFF"}
		},
		fonts:{
			heading_1_font:"",
			heading_2_font:"",
			heading_3_font:"",
			text_bold_font:"",
			text_bold_italic_font:"",
			text_font:"",
			text_italic_font:""
		},
		sizes:{
			button_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			button_text_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_1_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_2_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_3_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_line_height:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			margin:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			text_line_height:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			text_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			text_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""}
		}
	}
	return ts;
	</cfscript>
</cffunction>
<!--- 
ts={
	name:"styleset",
	editFonts:true,
	editSizes:true,
	editColors:true,
	editBreakpoints:true,
	externalStylesheet:false
};
echo(application.zcore.functions.zStylesetEditor(ts));  
 --->
<cffunction name="zStylesetEditor" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	if(not structkeyexists(ss, 'value')){
		ss.value=application.zcore.functions.zso(form, ss.name);
	}
	ts={
		editFonts:true,
		editSizes:true,
		editColors:true,
		editBreakpoints:true,
		externalStylesheet:false
	}
	structappend(ss, ts, false);
	if(ss.editFonts){
		ss.editFonts=1;
	}else{
		ss.editFonts=0;
	}
	if(ss.editSizes){
		ss.editSizes=1;
	}else{
		ss.editSizes=0;
	}
	if(ss.editColors){
		ss.editColors=1;
	}else{
		ss.editColors=0;
	}
	if(ss.editBreakpoints){
		ss.editBreakpoints=1;
	}else{
		ss.editBreakpoints=0;
	}
	if(ss.externalStylesheet){
		ss.externalStylesheet=1;
	}else{
		ss.externalStylesheet=0;
	}
	defaultConfig=getDefaultConfig();
	</cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */ 
	if(typeof zStylestyleDefaultConfig == "undefined"){
		var zStylestyleDefaultConfig={};
	} 
	zStylestyleDefaultConfig["#ss.name#"]=#serializeJson(defaultConfig)#;
	zArrDeferredFunctions.push(function(){
		$(".zStyleSetEditorButton").on("click", function(e){
			e.preventDefault();

			var field=$(this).attr("data-style-editor-field"); 
			zShowModalStandard('/z/misc/styleEditor/modalStyleEditor?field='+encodeURIComponent(field), 4000,4000, 10);
		});
	});
	/* ]]> */
	</script>
	<cfsavecontent variable="output"> 
		<h3><input type="hidden" name="#ss.name#" id="#ss.name#" value="#htmleditformat(ss.value)#"
			data-style-editor-fonts="#ss.editFonts#" 
			data-style-editor-sizes="#ss.editSizes#" 
			data-style-editor-colors="#ss.editColors#"
			data-style-editor-breakpoints="#ss.editBreakpoints#"
			data-style-editor-external-stylesheet="#ss.externalStylesheet#"
		 />
		 <a href="##" data-style-editor-field="#ss.name#" class="zStyleSetEditorButton z-manager-search-button">Open Style Editor</a></h3> 
		 <script type="text/javascript">
		 zArrDeferredFunctions.push(function(){
		 	$(".zStyleSetEditorButton").trigger("click");
		 });
		</script>

	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
	
</cffunction>


<cffunction name="modalStyleEditor" localmode="modern" access="remote">
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/zStyleEditor.js");
	application.zcore.functions.zSetModalWindow();
	application.zcore.functions.zIncludeJsColor();
	form.debug=application.zcore.functions.zso(form, 'debug', true, 0);
	form.field=application.zcore.functions.zso(form, 'field');

	application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true); 
	application.zcore.functions.zRequireJquery();
	defaultConfig=getDefaultConfig();
	if(form.debug EQ 1){
		debugConfig=duplicate(defaultConfig);
		debugConfig.sizes.text_size.Default="20";
		debugConfig.sizes.text_padding.1362="1px,5px,10px,15px";
		debugConfig.colors.text_color["Default"]="336699";
		debugConfig.fonts.text_font="font-weight:normal;";
	}
	</cfscript>
	<cfsavecontent variable="scriptOutput">   
	<cfif form.debug EQ 1>
		<input type="hidden" name="#form.field#" id="#form.field#" value="#htmleditformat(serializeJson(debugConfig))#"
			data-style-editor-fonts="1" 
			data-style-editor-sizes="1" 
			data-style-editor-colors="1"
			data-style-editor-breakpoints="1"
			data-style-editor-external-stylesheet="0"
		 />
	</cfif>
	<script type="text/javascript">
	/* <![CDATA[ */
	zArrDeferredFunctions.push(function(){ 
		<cfif form.debug EQ 1>
		if(typeof window.parent.zStylestyleDefaultConfig == "undefined"){
			window.parent.zStylestyleDefaultConfig={};
		} 
		window.parent.zStylestyleDefaultConfig["#form.field#"]=#serializeJson(defaultConfig)#;
		</cfif>
		var field=window.parent.document.getElementById("#form.field#");
		if(field.value != ""){
			config=JSON.parse(field.value);
		}else{
			config='';
		}
		var options={
			formId:"styleEditorForm",
			container:".styleEditorContainer",
			field:"#jsstringformat(form.field)#",
			defaultConfig:window.parent.zStylestyleDefaultConfig["#form.field#"],
			config:config,
			fonts:field.getAttribute("data-style-editor-fonts"),
			sizes:field.getAttribute("data-style-editor-sizes"),
			colors:field.getAttribute("data-style-editor-colors"),
			breakpoints:field.getAttribute("data-style-editor-breakpoints"),
			externalStylesheet:field.getAttribute("data-style-editor-external-stylesheet")
	 	};
	 	var myEditor=new zStyleEditor(options);
	});
	/* ]]> */
	</script> 
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("scripts", local.scriptOutput); 
	</cfscript> 
	<div style="width:100%; float:left;">
		<div style="width:100%; padding-bottom:5px; float:left;">
			<div class="z-float">
				<h2 style="display:inline-block; color:##369; font-weight:normal;">Style Editor</h2> &nbsp;&nbsp;
				<a href="##" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Close</a>
			</div>
			<form class="zFormCheckDirty" action="" name="styleEditorForm" id="styleEditorForm" method="get"> 
				<div class="styleEditorContainer"></div> 
			</form>
			
		</div> 
	</div>
</cffunction>
</cfoutput>
</cfcomponent>