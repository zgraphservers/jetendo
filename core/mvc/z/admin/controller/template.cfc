<cfcomponent>
<cfoutput><!--- 
TODO: make sure "if , elseif, else, endif" order and frequency is enforced.  1 if, many elseif,  1 else,  1 end if
TODO: implement EVEN_ROW and ODD_ROW on zloop
DONE: disable AND / OR and parenthesis on zout plain parse vars so that it is only a variable + json expression
TODO: enable variables to be embedded anywhere with just zout:blog.blog_status: instead of using data-zout escape by doing this "zout::blog.blog_status:" 
	allow these:
	zout:blog.blog_status({dateformat:"m/d/yy"}):
	zout:blog.blog_status({dateformat:&quot;m/d/yy&quot;}):
	zout:blog.blog_status({zout:&quot;m/d/yy&quot;}):
	zout:blog_status:
	

TODO: implement zloop
TODO: implement zvar
TODO: finish zSkinGetVar - like json dateformat etc - widget creation , etc
TODO: inTempBlockElement - this functionality was possibly broken.  Need to test xhtml validation issue related to having text without a div, p, table tag around it.
TODO: change line & column code to count chr(10) and characters instead of passing the value because the system is not showing correct line number in all cases.  put these values in the request scope so other functions can use them without passing an arguments.  remove the hardcoded line number from all error messages.


DONE: add validation that prevents multiple data-z attributes on one tag.  It should be always impossible.
DONE: change the widget functions that have .fail functions into returning an error.  change zRebuildXHTMLFromArray to check for errors and display them instead of ignoring them.

make .html version of .cfm
Put the coldfusion code in a structure of strings in snippets.cfm.  The code does not execute.  It is merely used for string replacing.
	update the snippets.cfm on community partnership to work with default.html

implementing version and preview/rollback
implement <z_if>  <z_else>  <z_elseif>

implement a limiting function on the variable names that can be used in template expressions.

<!--- 
need documentation to automatically generate which variables are available in views.

widgets:
real_estate_search_sidebar
real_estate_search_sidebar_short
list_blog_articles
list_content_pages
menu
slideshow
contact_form
search_site
include_content_page
get_global_option
get_template_element (i.e. application.zcore.template.getTagContent("title");
get_global
get_custom_option <!--- because we sometime needs to alter the menus or images that appear on various pages, I should make a global shared system that lets you set options for the detail page of rentals,content,blog articles,blog category,rental category,blog tag and also allow setting custom option for entire features so their landing pages can also be customized.  --->

create a heirarchy based on these parameters
entire site -> current primary application -> current primary page (i.e. site -> blog -> blog article) so you can associate skin changes to specific parts of the site which will be inherited accordingly.
use this heirarchy to give the menus state so that buttons stay on.  Additionally, this requires associating menu buttons with the global sections or pages manually.


allow skin designer to create site options that are associated with each skin file.  When you go to site option, they will be organized by the skin names, and also, on public site, the edit button will jump to the right options to minimize searching.


global template variables always available:
current_script

--->


<!--- zHTMLArrayToObject(arrDoc, index); --->
<!--- <cffunction name="zHTMLArrayToObject" localmode="modern" output="no" returntype="struct" roles="member">
	<cfargument name="arrDoc" type="array" required="yes">
	<cfargument name="index" type="numeric" required="yes">
    <cfscript>
	var i=0;
	var curTag="";
	var c=0;
	var rs=structnew();
	rs.object=structnew();
	rs.object.element=arguments.arrDoc[arguments.index].value;
	rs.object.attributes=structnew();
	for(i=arguments.index;i LTE arraylen(arguments.arrDoc);i++){
		c=arguments.arrDoc[i];
		if(c.type EQ "attributeName"){
			rs.object[c.value]=c.value;
			lastAttribute=c.value;
		}else if(c.type EQ "attributeValue"){
			rs.object.attributes[lastAttribute]=c.value;
		}
	}
	rs.index=i+1;
	return rs;
	</cfscript>
</cffunction> --->


xhtmlInvalidAttrib=[
"body" => ["topmargin","marginwidth","marginheight","leftmargin"],
"td" => ["height","width","background"],
"img" => ["border"],
paragraphs, headings, tables, images, and divs. 
"div" => ["align"],
"script" => ["language"],
"form" => ["name"]
];
height,width,background,border,align,,language
img[hspace,vspace]
name
width only allowed on <table>
cellspacing = "0" cellpadding border on table not allowed

beginnings of designer friendly template engine and in-context layout + content editor

tag language:
${widget}
${loop}
${if}
${var}


${var typeObject varName}

ifurlis
<z_if url="">

Implement jquery resizable on a div or table and verify that i can store it's state within a tinymce box.

capture the drag start event so i can resize the placeholder div to be the same size as the dragged object.

set the height and width of the para1 to the same size are para1parentdiv on doubleclick and then set to auto on close.



The interface for tinymce editors would change.  I wanted to make sure this is possible before making my widget engine. 

With a structure like this, it would be possible for widgets to be inserted on the live site and to have live previews via ajax and still be draggable with live data.  Some may be resizable or editable too depending on what it is.

It will be much more complicated to figure out how to store the layout and widget configuration as well as the interface for editing both templates and pages.

The template language will be like xml or json and will be able to validate as xhtml.  It will support if, loop, widgets and variables with option attributes.   It would be converted to a fast coldfusion script that is cached.  The only reason to do this is to prevent users from using data that they shouldn't.

On iis 7 windows, I am able to remove all scripts from view for my FTP users, this means I can give them access to the site to upload html, js, css and images without opening up a huge security/quality problem.   I plan on giving advanced clients / web developers this kind of access so they can do advanced custom html without having to use their browser to manage it all.   


 <!--- 
 <z_if mystuff EQUAL 'test "'>test</z_if>
 would become this in html 5:
 <div data-zif="mystuff EQUAL 'test &quot;'">test</div> --->


<z_if leftvalue1="" operator1="" rightvalue1=""> <!--- simple expression --->
<z_if leftvalue1="" operator1="" rightvalue1="" combinewith="and" leftvalue2=""> <!--- complex logic --->

vs

	
	
	later, I'll allow output of values in the blog, articles, content, etc.  Must allow database variable syntax.

==, !=, 


I made my skinning parser able to output xhtml that can pass w3c validator, but still have the custom tags for inserting widgets, variables, loops and logic.     --->
<!--- <cfscript>
cf=structnew();
cf["<cftest##>"]="wow##test####";
t1="te";
t2="st##";
t3="t2";
cur=(cf["<cf#t1&evaluate("#t3#")#>"]);
writeoutput("<cfoutput>"&replace(cur,"##","####","ALL")&"</cfoutput>");
application.zcore.functions.zabort();</cfscript> --->
<!--- 
99% working on all scripts too

	the problem is if we have # nested or an attribute with > in it, the tag ends too early and the remaining text could get in without being checked for correctness and allow rogue scripts.

	solution is to escape all the pound signs after rebuilding the document.  However, the intentional pound signs may be lost.  I may have to escape before reaching that point or not use cfoutput on entire document.

 ---><!--- 
<cfsavecontent variable="theHTML">
<!--- THE COLDFUSION / PHP / ASP / XML script parser doesn't check for quotes and escaped quotes yet.

 ---><!--- 
<cfscript>writeoutput('
<cfif mtest EQ true>
stuff1
<cfelse>
stuff2
</cfif>

<cfscript>
test = "my false </cfscript> "" ";
test = '' my second </cfscript> test '''' '';
</cfscript>');
</cfscript>
and php parsing doesn't work yet.
<?php echo 5 " test ?> hopefully ignored ya? \" ?> " ; 

echo 'test ?> \'  ?> ';

?>
<% asp here
%> 
 <?xml test="t1" test2="t2" ?>  

<pastor:zasa name="test" />test</pastor:zasa>

--->
<cfscript>writeoutput('<cfscript> /* </cfscript> must ignore this closing tag */ </cfscript>
<p>&nbsp;</p>
<cfscript> 
test=true;
// </cfscript>
</cfscript>
');
writeoutput('what is this');
// </cfscript>
test=true;
 </cfscript>
 
 <style type="text/css">
 .justanother{ font-size:84px;}
 /* </style> */
 
 </style>
 
 <script type="text/javascript">
 // </script>
 /* 
 </script> must ignore this script closing tag when parsing */
 alert('test');
 </script>
 <br/>
<p http-equiv="Content-Type" content="text/html; charset=utf-8" />
 
<!---
    <!- not a comment, just regular old data characters ->
<p title=" />"></p>

<div d1="t2test"d2="my test" > </div> <!--  <!-- -->  < test > test >
    <textarea name="forreal" id="forreal" cols = "my test" " rows  =   10 test   style="width:500px; height:500px;"  checked ></textarea> --->
</cfsavecontent>
<!--- #theHTML# ---> --->

<!--- --->

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
db=request.zos.queryObject;
request.zScriptName=request.cgi_script_name&'?ztv=1';
</cfscript>

<cfscript>

throw("disabled until code is updated");
</cfscript>
<h2>Design &amp; Layout Editor</h2>


<!--- 

<z_if expression="value == value2">
need an expression parser.  Rules are that the value expression must be a valid coldfusion variable name syntax.  No functions, spaces, arrays, etc.  Make a regular expression that checks each value

allowed operators: EQUAL, DOES NOT EQUAL, CONTAINS, DOES NOT CONTAIN, EMPTY, NOT EMPTY, EXISTS, NOT EXISTS
allowed values:
	snippets.X
	cgi.X
	form.X
	true, false, numbers or strings
	arrExp=listtoarray(expression,".");
	expLength=arraylen(arrExp);
	if(expLength GT 2){
		// Validation Error: Invalid expression. "#expression#", Must be a simple variable name, true, false, numbers or a string. No complex objects / functions can be used.  Only one dot in structure lookups.
	}else if(expLength EQ 2){
		expressionStructName=left(arrExp[1],len(arrExp[1])-1);
		expression=arrExp[2];
	}else{
		expressionStructName="";
	}
	if(refindnocase("[a-zA-Z_][a-zA-Z0-9_]*", expression) NEQ 0){
		// Validation Error: Invalid expression. "#expression#", Must be a simple variable name, true, false, numbers or a string. No complex objects / functions can be used.  Only one dot in structure lookups.
	}
	
	
 --->

<!--- 
TODO:
parenthesis validation - check if works
check for validation errors or missing erors on these strings:
	()
	( )
	(test)
	)test(
DONE:
operator validation works

check for valid variable names?
check for leftvalue operator rightvalue expression format
or leftvalue mathoperator leftvalue2 operator rightvalue
	such as currentrow MODULUS 2 EQUAL 0
	or do this <z_if EVEN_ROW></z_if> or <z_if ODD_ROW></z_if>

detect "and" "or" in correct places
	not at beginning
	not at end
	not by themselves
	
return a tokenized array

convert the tokens into coldfusion code

should i use this syntax:
	<span data-zvar="blog.datetime" data-zdateformat="m/d/yy">Date</span>
or this syntax:
	YES: <span data-zvar="blog.datetime({dateformat:'m/d/yy'})">Date</span>
	

examples:
( ) = true
() = true
(test) = (isdefined('test') and test)
)test( = invalid
snippets. = invalid
snippets.meta IS EMPTY = (structkeyexists(snippets, 'meta') and trim(snippets.meta) EQ "")
snippets.meta EXISTS = structkeyexists(snippets, 'meta')
snippets.meta DOES NOT EXIST = structkeyexists(snippets, 'meta') EQ false
request.cgi_script_name EQUAL 'index.cfm' or blog.blog_status DOES NOT EQUAL 1 = request.cgi_script_name EQ "index.cfm" or (structkeyexists(blog,'blog_status') and blog.blog_status NEQ 1)
snippets.meta IS NOT EMPTY = (structkeyexists(snippets, 'meta') and trim(snippets.meta) NEQ "")
snippets.meta EXISTS and snippets.meta CONTAINS "bruce" = structkeyexists(snippets, 'meta') and snippets.meta CONTAINS "bruce"
(form.content_id EQUAL 5 or form.content_id EQUAL 3) and status EQUAL 1 = ((structkeyexists(form, 'content_id') and form.content_id EQ 5) or (structkeyexists(form, 'content_id') and form.content_id EQ 3)) and (isdefined('status') and status EQ 1)
((form.content_id EQUAL 5 or form.content_id EQUAL 3) and status EQUAL 1) = (((structkeyexists(form, 'content_id') and form.content_id EQ 5) or (structkeyexists(form, 'content_id') and form.content_id EQ 3)) and (isdefined('status') and status EQ 1))
)form.content_id EQ 5 = invalid
form.content_id EQUAL 5 or form.content_id EQUAL 3) and status EQUAL 1 = invalid


when inside a <z_loop>
	convert ROW_EVEN into currentrow MOD 2 EQ 0
	convert ROW_ODD into currentrow MOD 2 EQ 1

 --->
<cfsavecontent variable="invalidexpressions">
1test EQUAL true<!--- DONE: invalid --->
test\'test EQUAL true<!--- DONE: Invalid --->
(test1)test2<!--- DONE: invalid --->
var1 var2<!--- DONE: invalid --->
(var1) (var2)<!--- DONE: invalid --->
)IS EMPTY<!--- DONE: invalid --->
) IS EMPTY<!--- DONE: invalid --->
IS EMPTY<!--- DONE: invalid --->
() EQUAL 5<!--- DONE: invalid --->
(test) EQUAL 5<!--- DONE: invalid --->
(((test)) EQUAL 5<!--- DONE: invalid --->
test EQUAL (5)<!--- DONE: invalid --->
() and (IS EMPTY) test<!--- DONE:invalid --->
(IS EMPTY) test<!--- DONE: invalid --->
(IS EMPTY test)<!--- DONE: invalid --->
test EQUAL<!--- DONE: invalid --->
)test(<!--- DONE: invalid ---> 
snippets.<!--- DONE: invalid --->
)form.content_id EQ 5<!--- DONE: invalid --->
(test1)EQUAL 5<!--- DONE: invalid --->
(snippets.meta IS EMPTY) test EQUAL true<!--- DONE: invalid --->
form.content_id EQUAL 5 or form.content_id EQUAL 3) and status EQUAL 1<!--- DONE: invalid --->
blog.datetime((test))<!--- DONE: invalid --->
blog.datetime(test)<!--- DONE: invalid--->
blog.datetime(())<!--- DONE: invalid --->
blog.datetime({dateformat:'mmmm d, {yy} tt'} { date: true } )<!--- DONE: invalid --->
blog.datetime({dateformat:'mmmm d, {yy} tt'} test)<!--- DONE: invalid --->
blog.datetime({datefor\}mat:'mmmm d, \{yy\}'})<!--- DONE: invalid --->
</cfsavecontent> 
<cfsavecontent variable="validexpressions">
mytest EQUAL "test)test"<!--- TODO: valid | fails to have the correct string value due to replacement --->
<!--- () and ()<!--- DONE: valid --->
( )<!--- DONE: valid --->
()<!--- DONE: valid --->
(test)<!--- DONE: valid --->
snippets.meta IS EMPTY<!--- DONE: valid --->
snippets.meta IS EMPTY test<!--- DONE: valid --->
snippets.meta DOES NOT EXIST<!--- DONE: valid --->
snippets.meta EXISTS<!--- DONE: valid --->
snippets.meta IS NOT EMPTY<!--- DONE: valid --->
test EQUAL 5<!--- DONE: valid --->
test DOES NOT EQUAL 5<!--- DONE: valid --->
form.content_id EQUAL 5<!--- BROKEN: valid --->
form.content_id EQUAL true<!--- BROKEN: valid --->
form.content_id EQUAL false<!--- BROKEN: valid --->
form.content_id EQUAL 0<!--- BROKEN: valid --->
(snippets.meta IS EMPTY)<!--- DONE: valid --->
snippets.meta EXISTS and snippets.meta CONTAINS "bruce"<!--- DONE: valid --->
request.cgi_script_name EQUAL 'index.cfm' or blog.blog_status DOES NOT EQUAL 1<!--- DONE: valid--->
(form.content_id EQUAL 5 or form.content_id EQUAL 3) and status EQUAL 1<!--- DONE: valid --->
((form.content_id EQUAL 5 or form.content_id EQUAL 3) and status EQUAL 1)<!--- DONE: valid --->
snippets.meta EQUAL &quot; my \&quot; string &quot;<!--- DONE: valid | double quote support with &quot; --->
snippets.meta EQUAL '<a onClick="window.location.href=\'do.html\'">test</a>'<!--- DONE: valid | string escaping --->
snippets.meta EQUAL '<meta name="keywords" content="$\'%@PJ^##>@JP!(%*~)@{!-9u0" />'<!--- DONE: valid | There should be no spaces around ( or ) when this string is put into a token. --->
blog.datetime({dateformat:'m/d/yy'}) EQUAL now({dateformat:'m/d/yy'})<!--- DONE: valid --->
blog.datetime()<!--- DONE: valid --->
blog.datetime({dateformat:'mmmm d, \{yy\}'})<!--- DONE: valid  --->
blog.datetime({dateformat:'mmmm d, {yy} tt'})<!--- DONE: valid --->
blog.datetime({dateformat:'mmmm d, \{yy\}'})<!--- DONE: valid --->
blog.status EQUAL " test \\\"\\ what"<!--- DONE: valid --->
blog.status EQUAL ' test \\' and 'what'<!--- DONE: valid ---> --->
</cfsavecontent>
<cfsavecontent variable="invalidjsonexpressions">
blog.status EQUAL ' test \\' 'what'<!--- DONE: invalid --->
{dateformat:'mm\\\'mm', somevalue:3.12.15}<!--- DONE invalid --->
{dateformat:'mm\\\'mm', 1somevalue:3}<!--- DONE: invalid --->
{dateformat:'mm\\\'mm', some value:3}<!--- DONE: invalid --->
{datefor\}mat:'mmmm d, \{yy\}'}<!--- DONE: invalid --->
{dateformat:'mm\\'mm'}<!--- DONE: invalid | the escaping must throw an error that a backslash "\" or single quote "'" is not escaped properly. --->
{ 1somevalue:3.12.145}<!--- DONE: invalid --->
{ somevalue:3as145}<!--- DONE: invalid --->
{ somevalue:3.12.145}<!--- DONE: invalid --->
{ someval:truea}<!--- DONE: invalid --->
{ someval:  true test  }<!--- DONE: invalid --->
{ someval:atrue}<!--- DONE: invalid --->
</cfsavecontent>
<cfsavecontent variable="validjsonexpressions">
{date   :   true    }<!--- DONE: valid --->
{date   :   'test'    }<!--- DONE: valid --->
{date   :   "test"    }<!--- DONE: valid --->
{dateformat:'mm\\\'mm', somevalue:3.12}<!--- DONE: valid --->
{dateformat:'mm\\\'mm', somevalue:3}<!--- DONE: valid --->
{dateformat:'mm\\\'mm'}<!--- DONE: valid | the escaping must be working so that it read the entire line as mm\'mm in the stored string variable --->
{dateformat:'mmmm d, {yy} tt'}<!--- DONE: valid --->
{ someval23_ue:3.1245}<!--- DONE: valid --->
{ someval:true}<!--- DONE: valid --->
{ someval:false}<!--- DONE: valid --->
{ someval:true}<!--- DONE: valid --->
{ someval:  true   }<!--- DONE: valid --->
</cfsavecontent>

<!--- {dateformat:'mmmm d, \{yy\}'}<!--- DONE: valid, but this syntax will break the other parsing function - i need to disable this after finishing the json parser  ---> --->
<cfsavecontent variable="jsonexpressions3">
{date   :   true   
,
test: "te  
sadiuo	ioasnmio	 \" as
st" , 

		ioahas32: 234.23
        
         }
         </cfsavecontent><!--- DONE: valid --->
<!--- <cfsavecontent variable="expressions">
</cfsavecontent> --->
<!--- 
operator definitions
EXISTS = checks for existance
NOT EMPTY = checks for existance and not an empty string
CONTAINS = searches the value on the left for the value on the right and is true if it is successful
DOES NOT CONTAIN = searches the value on the left for the value on the right and is true if it is NOT successful
 --->
 <cfscript>
test=false;
/*
 snippets=structnew();
 snippets["meta"]='<meta id="bruce">';
 
 blog=structnew();
 blog["blog_status"]=1;
 */
if(test){
	failedCount=0;
	 arrE=listtoarray(trim(validjsonexpressions),chr(10));
	 arrayappend(arrE, trim(jsonexpressions3));
	 for(i=1;i LTE arraylen(arrE);i++){
		rs=zParseJsonString(arrE[i],i);
		if(rs.success EQ false){
			writeoutput('<hr />Test Failed: ###i#: '&htmleditformat(arrE[i])&" | ERROR: "&rs.error&" | Column "&rs.column&"<br /><br />");
			failedCount++;
		}else{
				
		}
		//zdump(rs);
	 }
	 arrE=listtoarray(trim(invalidjsonexpressions),chr(10));
	 for(i=1;i LTE arraylen(arrE);i++){
		rs=zParseJsonString(arrE[i],i);
		if(rs.success){
			failedCount++;
			writeoutput('<hr />Test failed: ###i#: '&htmleditformat(arrE[i])&" | Result: "&rs.result&" | Column "&rs.column&"<br /><br />");
		}else{
			//writeoutput('<hr />###i#: '&htmleditformat(arrE[i])&" | ERROR: "&rs.error&" | Column "&rs.column&"<br /><br />");
		}
		//zdump(rs);
	 }
	 
	 arrE=listtoarray(trim(validexpressions),chr(10));
	 for(i=1;i LTE arraylen(arrE);i++){
		rs=zParseSkinExpression(arrE[i],i);
		if(rs.success){
			//writeoutput('<hr />###i#: '&htmleditformat(arrE[i])&" | Result: "&rs.result&"<br /><br />");
		}else{
			failedCount++;
			writeoutput('<hr />Test failed: ###i#: '&htmleditformat(arrE[i])&" | ERROR: "&rs.error&"<br /><br />");
		}
		//zdump(rs);
	 }
	// zabort();
	 arrE=listtoarray(trim(invalidexpressions),chr(10));
	 for(i=1;i LTE arraylen(arrE);i++){
		rs=zParseSkinExpression(arrE[i],i);
		if(rs.success){
			failedCount++;
			writeoutput('<hr />Test failed: ###i#: '&htmleditformat(arrE[i])&" | Result: "&rs.result&"<br /><br />");
		}else{
			//writeoutput('<hr />###i#: '&htmleditformat(arrE[i])&" | ERROR: "&rs.error&"<br /><br />");
		}
		//zdump(rs);
	 }
	 writeoutput(failedCount&" tests failed.");
}
// zabort();
 </cfscript>
 
 

<!--- 
make the snippets.cfm file work with the templatetest.html so that I can enable access for zgraph without having the tag language completely done.  I only have to build <z_snippet> or the HTML 5 equivalent.

also need the z_if tag language to work
	all snippets for communitypartnership default.html:
		meta
		mainmenu
		videoElement1
		videoElement2
		videoElement3
		privacyLink
		visitorTrackingCode

<!--- This is used in <head> --->
<meta data-snippet-name="meta" />

<!--- This is used in <body> --->
<div data-snippet-name="1" />

<!--- This is used in <xml> --->
<zdata data-snippet-name="meta" />

/skins/templates/
/skins/css/
/skins/snippets/
/skins/panels/
 
look into adding color coding
http://codemirror.net/


make a skin inheritance system and make options to override per page, per section (can mean many things) or globally.

this is valid HTML 5, but the old table attributes like on everything is invalid html 5, so i'd have to redo most of the code to use CSS.
<div id="mydiv" data-zif="row EXISTS AND value EQUAL blue">
If I use HTML 5 compatible code for my add-on features, then I can upgrade to html 5 later easier.

--->
<cfscript>
form.action=application.zcore.functions.zso(form, 'action',false,'list');
request.zScriptName=request.cgi_script_name&"?ztv=1";
//zreset="site";
start=gettickcount();
request.zos.skin = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.skin");
</cfscript>
<h1><a href="#request.zscriptname#">Manage Design &amp; Layout</a></h1>
<p>Tools: <a href="#request.zscriptname#&action=testHTMLParser">Test HTML Parser</a> | <a href="#request.zscriptname#&action=incontexteditor">Incontext HTML Editor</a> | <a href="#request.zscriptname#&action=dumpFileStruct">Dump Skin Cache</a> | <a href="#request.zscriptname#&zreset=app">Clear Skin Cache</a></p>

<cfif form.action EQ "dumpFileStruct">
<cfscript>zdump(application.sitestruct[request.zos.globals.id].skinObj.fileStruct);</cfscript>
</cfif>
<!--- <cfscript>
// these are working:
writeoutput(application.zcore.skin.includeJS("/skins/js/script.js"));
writeoutput(application.zcore.skin.includeCSS("/skins/css/styles.css"));
skinHTML=application.zcore.skin.includeSkin("/skins/templates/default.html");
writeoutput(skinHTML);

writeoutput(((getTickcount()-start)/1000)&" seconds<br />");
</cfscript> --->


<cfif form.action EQ 'insert' or form.action EQ 'update'>
	<cfscript>
	form.user_id=request.zsession.user.id;
	form.site_id = request.zos.globals.id;
	ts=StructNew();
	ts.file_name.required = true;
	ts.file_type.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(find(","&form.file_type&",",",html,css,js,") EQ 0){
		application.zcore.status.setStatus(Request.zsid, "Invalid File Type, only HTML, CSS and JS are allowed.",form,true);
		result=true;
	}
	if(left(form.file_path,6) NEQ "/skins" or file_path CONTAINS "/../"){
		application.zcore.status.setStatus(Request.zsid, "File path must be within the /skins/ directory.",form,true);
		result=true;
	}
	if(replacelist(form.file_name,'",##,%,&,*,:,<,>,?,\,/,{,|,},~,)','') NEQ form.file_name){
		application.zcore.status.setStatus(Request.zsid, "File Name cannot contain one of the following characters: "" ## % & * : < > ? \ / { | } ~",form,true);
		result=true;
	}
	if(form.file_type NEQ application.zcore.functions.zgetfileext(form.file_name)){
		if(application.zcore.functions.zgetfileext(form.file_name) EQ ""){
			form.file_name&="."&form.file_type;
		}else{
			application.zcore.status.setStatus(Request.zsid, "File Name must end with .#form.file_type#",form,true);
			result=true;
		}
	}
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.action EQ 'insert'){
			application.zcore.functions.zRedirect(request.zScriptName&'&action=add&zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect(request.zScriptName&'&action=edit&file_id=#form.file_id#&zsid=#request.zsid#');
		}
	}
	versionChanged=false;
	curPath=request.zos.globals.homedir&removechars(form.file_path,1,1);
	application.zcore.functions.zcreatedirectory(curPath);
	form.file_path=form.file_path&"/"&form.file_name;
	filePathChanged=false;	
	</cfscript>
    
    <!--- curPath:#curPath#<br /> --->
	<cfif form.action EQ "update">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("file", request.zos.zcoreDatasource)# file, 
		#request.zos.queryObject.table("file_version", request.zos.zcoreDatasource)# file_version 
		WHERE file.file_id = #db.param(form.file_id)# and 
		file_deleted = #db.param(0)# and 
		file_version_deleted = #db.param(0)# and
		file.file_id = file_version.file_id and 
		file.site_id = #db.param(request.zos.globals.id)#
        </cfsavecontent><cfscript>qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'Invalid file.',false,true);
			application.zcore.functions.zRedirect(request.zScriptName&'&zsid=#request.zsid#');
		}else{
			form.file_version_id=qCheck.file_version_id;
			if(form.file_path NEQ qCheck.file_path){
				filePathChanged=true;	
			}
			curPath=request.zos.globals.homedir&removechars(form.file_path,1,1); // abspath to save file
			if(compare(trim(application.zcore.functions.zso(form,'file_version_data')),trim(qCheck.file_version_data)) NEQ 0){	
				versionChanged=true;
			}
		}
		form.file_id=qCheck.file_id;
		</cfscript>
    <cfelse>
    	<!--- insert validation --->
    	<cfscript>
		curPath=curPath&"/"&form.file_name; // abspath to save file
		form.file_path=replace(curPath,request.zos.globals.homedir,"/");
		versionChanged=true;
		</cfscript>
	</cfif>
    <cfsavecontent variable="db.sql">
    SELECT * FROM #request.zos.queryObject.table("file", request.zos.zcoreDatasource)# file, 
	#request.zos.queryObject.table("file_version", request.zos.zcoreDatasource)# file_version 
	WHERE file.file_path= #db.param(form.file_path)# and 
	file_deleted = #db.param(0)# and 
	file_version_deleted = #db.param(0)# and
	file.file_id = file_version.file_id and 
	file.file_id <> #db.param(form.file_id)# and 
	file.site_id = #db.param(request.zos.globals.id)#
    </cfsavecontent><cfscript>qFile=db.execute("qFile");
    if(qFile.recordcount NEQ 0){
        application.zcore.status.setStatus(request.zsid, 'File name already exists. Please type a different name or go back and edit the existing file.',form,true);
       	application.zcore.functions.zRedirect(request.zScriptName&'&action=add&zsid=#request.zsid#');
    }
	if(versionChanged){
		application.zcore.functions.zwritefile(curPath, form.file_version_data);
		application.zcore.functions.zClearCFMLTemplateCache();
	}
	fileObj=getfileinfo(curPath);
	ts=StructNew();
	ts.table='file';
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.action EQ 'insert'){
		form.file_modified_datetime=dateformat(fileObj.LastModified,"yyyy-mm-dd")&" "&timeformat(fileObj.LastModified,"HH:mm:ss");
		form.file_size=fileObj.size;
		form.file_deleted=0;
		form.site_id=request.zos.globals.id;
		form.file_id = application.zcore.functions.zInsert(ts);
		if(form.file_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save file.',form,true);
			application.zcore.functions.zRedirect(request.zScriptName&'&action=add&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'File saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save file.',form,true);
			application.zcore.functions.zRedirect(request.zScriptName&'&action=edit&file_id=#form.file_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'File updated.');
		}
		
	}
	if(versionChanged){
		ts=structnew();
		ts.table="file_version";
		ts.struct=form;
		ts.datasource=request.zos.zcoreDatasource;
		ts.struct=structnew();
		ts.struct.file_version_data=trim(form.file_version_data);
		ts.struct.file_version_datetime=request.zos.mysqlnow;
		ts.struct.file_version_lastmodifieddate=dateformat(fileObj.LastModified,"yyyy-mm-dd")&" "&timeformat(fileObj.LastModified,"HH:mm:ss");
		ts.struct.file_version_active='1';
		ts.struct.file_version_compiled=0;
		ts.struct.file_id = form.file_id;
		ts.struct.site_id=request.zos.globals.id;
		form.file_version_id=application.zcore.functions.zInsert(ts);
		
		db.sql="update #request.zos.queryObject.table("file_version", request.zos.zcoreDatasource)# file_version 
		set file_version_active=#db.param(0)#,
		file_version_updated_datetime=#db.param(request.zos.mysqlnow)#  
		where file_id=#db.param(form.file_id)# and 
		file_version_deleted = #db.param(0)# and
		file_version_id <> #db.param(form.file_version_id)#";
		r=db.execute("r");
	}
	ts=structnew();
	ts.file_id=form.file_id;
	ts.file_path=form.file_path;
	
	ts.file_id=form.file_id;
	ts.file_path=form.file_path;
	//ts.file_created_datetime=parsedatetime(dateformat(fileObj.LastModified,"yyyy-mm-dd")&" "&timeformat(fileObj.LastModified,"HH:mm:ss"));
	ts.file_modified_datetime=parsedatetime(dateformat(fileObj.LastModified,"yyyy-mm-dd")&" "&timeformat(fileObj.LastModified,"HH:mm:ss"));
	ts.file_deleted_datetime="";
	ts.file_type=form.file_type;
	ts.file_version_id=form.file_version_id;
	ts.file_deleted=0;
	ts.file_version_compiled=0;
	ts.file_version_data=form.file_version_data;
	ts.processed=false;
	ts.file_size=fileObj.size;
	application.sitestruct[request.zos.globals.id].skinObj.fileStruct[form.file_path]=ts;
	application.zcore.skin.compile(application.sitestruct[request.zos.globals.id].skinObj.fileStruct[form.file_path]);
	if(filePathChanged){
		// when file_path changes, the old file_path must be deleted from application scope.
		application.zcore.functions.zdeletefile(request.zos.globals.homedir&removechars(qCheck.file_path,1,1));
		structdelete(application.sitestruct[request.zos.globals.id].skinObj.fileStruct,qCheck.file_path);
	}
	//writeoutput("fpc:"&filePathChanged&"|"&qCheck.file_path);
	//zdump(application.sitestruct[request.zos.globals.id].skinObj.fileStruct);
	application.zcore.functions.zRedirect(request.zScriptName&'&zsid=#request.zsid#');
	</cfscript>
</cfif>
<cfif form.action EQ "edit" or form.action EQ "add">
	<cfscript>
	currentMethod=form.action;
	file_id=application.zcore.functions.zso(form, 'file_id');
	</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT * FROM #request.zos.queryObject.table("file", request.zos.zcoreDatasource)# file, 
	#request.zos.queryObject.table("file_version", request.zos.zcoreDatasource)# file_version 
	WHERE file.file_id = #db.param(file_id)# and 
	file.file_id = file_version.file_id and 
	file_deleted = #db.param(0)# and 
	file_version_deleted = #db.param(0)# and
	file_version_active=#db.param(1)# and 
	file.site_id = #db.param(request.zos.globals.id)#
    </cfsavecontent><cfscript>qFile=db.execute("qFile");</cfscript>
    <h2>Skin Editor</h2>
    
	<cfscript>
	application.zcore.functions.zQueryToStruct(qFile);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2><cfif currentMethod EQ "add">Add File<cfelse>Edit #form.file_path#</cfif></h2>
<form class="zFormCheckDirty" action="#request.zScriptName#&action=<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>&file_id=#file_id#" method="post">
<table style="width:100%;" class="table-list">
	
<cfdirectory name="qDir" directory="#request.zos.globals.homedir#skins/" action="list" recurse="yes" type="dir">
<cfscript>
arrVal=arraynew(1);
arrayappend(arrVal,"/skins");
</cfscript>
<cfloop query="qDir">
<cfscript>
arrayappend(arrVal,replace(replace(directory,"\","/","ALL")&"/"&name,request.zos.globals.homedir,"/"));
</cfscript>
</cfloop>
<tr>
<th>File Path</th>
<td>
	<cfscript>
	if(form.file_path NEQ "" and directoryexists(request.zos.globals.homedir&removechars(form.file_path,1,1)) EQ false){
		form.file_path=listdeleteat(form.file_path,listlen(form.file_path,"/"),"/");
	}
    selectStruct = StructNew();
    selectStruct.name = "file_path";
    selectStruct.hideSelect=true;
    selectStruct.listLabels = arraytolist(arrVal,chr(9));
    selectStruct.listValues = arraytolist(arrVal,chr(9));
    selectStruct.listLabelsDelimiter = chr(9); // tab delimiter
    selectStruct.listValuesDelimiter = chr(9);
    application.zcore.functions.zInputSelectBox(selectStruct);
    </cfscript></td></tr>
<tr>
<th>File Type</th>
<td>
<cfif currentMethod EQ "edit">
	<cfscript>
	ts=StructNew();
	ts.name="file_type";
	application.zcore.functions.zInput_hidden(ts);
	</cfscript> #file_type#
<cfelse>
	<cfscript>
    selectStruct = StructNew();
    selectStruct.name = "file_type";
    selectStruct.hideSelect=true;
    selectStruct.listLabels = "html|css|js";
    selectStruct.listValues = "html|css|js";
    selectStruct.listLabelsDelimiter = "|"; // tab delimiter
    selectStruct.listValuesDelimiter = "|";
    application.zcore.functions.zInputSelectBox(selectStruct);
    </cfscript>
</cfif>
</td>
</tr>
<tr>
<th>File Name</th>
<td>
<input type="text" name="file_name" value="#htmleditformat(file_name)#" />
</td>
</tr>

    <tr>
	<th style="width:1%;">File Contents</th>
	<td>
    
	<cfscript>
	
ts=StructNew();
ts.name="file_version_data";
ts.multiline=true;
ts.style="width:100%; height:600px;";
ts.size=80;
application.zcore.functions.zInput_Text(ts);
    </cfscript></td>
	</tr>
	<tr>
	<th style="width:1%;">&nbsp;</th>
	<td>
	<button type="submit" name="submitForm">Save</button>  <button type="button" name="cancel" onClick="window.location.href = '#request.zScriptName#';">Cancel</button></td>
	</tr>
</table>
	</form>
	

</cfif>

<cfif form.action EQ "list">
	<cfscript>
    application.zcore.functions.zStatusHandler(request.zsid);
    </cfscript>
    <h2 style="display:inline;">Skin Files Browser | </h2> <a href="#request.cgi_script_name#?action=add">Add File</a><br /><br />
    <p>Click a skin file to open the editor.</p>
    <cfscript>
    for(i in application.sitestruct[request.zos.globals.id].skinObj.fileStruct){
        cur=application.sitestruct[request.zos.globals.id].skinObj.fileStruct[i];
        writeoutput('<p><a href="#request.cgi_script_name#?action=edit&file_id=#cur.file_id#">#i#</a> #cur.file_deleted#</p>');	
    }
    </cfscript>
</cfif>



<cfif form.action EQ "incontexteditor">
    
    <script src="/z/a/member/htmlparser.js"></script>
    <textarea name="forreal" id="forreal" style="width:500px; height:500px;"></textarea>
<script>
/*
http://ejohn.org/blog/pure-javascript-html-parser/
convert the input html to valid xhtml attributes and elements.  may want to support HTML 5 instead or allow the user to load the collection they want.
convert the rest of zcore to xhtml syntax.

converting to xhtml steps:
http://expression.microsoft.com/en-us/dd439540.aspx
*/


function forceit(){ 
	var h1=document.createElement("body");
	var value = "<p>hello <b style='test foo' disabled align=\"b\\\"ar\">john <a href='http://ejohn.org/'>resig</b><!-- <img border=\"0\" src=test.jpg></img> <!-- another one  --> test <div>test</div><p>hello world";
	HTMLtoDOM(value, h1);
	a1=[];
	var level=0;
	HTMLParser(value, {
		start: function( tag, attrs, unary ) {
			indent="";
			for(var i=0;i<level;i++){
				indent+="  ";
			}
			a1.push(indent+tag);
			level++;
			indent="";
			for(var i=0;i<level;i++){
				indent+="  ";
			}
			for ( var i = 0; i < attrs.length; i++ ){
				a1.push(indent+ " " + attrs[i].name + '="' + attrs[i].escaped + '"');
			}
		},
		end: function( tag ) {
			level--;
			indent="";
			for(var i=0;i<level;i++){
				indent+="  ";
			}
			a1.push(indent+"end:"+tag);
		},
		chars: function( text ) {
			indent="";
			for(var i=0;i<level;i++){
				indent+="  ";
			}
			a1.push(indent+"CDATA: "+text);
		},
		comment: function( text ) {
			indent="";
			for(var i=0;i<level;i++){
				indent+="  ";
			}
			a1.push(indent+"Comment: "+text);
		}
	});
	/*
	function putTreeInArray(node,level){
		var indent="";
		for(var i=0;i<level;i++){
			indent+="&nbsp;";
		}
		for( var y = 0; y < node.childNodes.length; y++ ) {
			var curNode=node.childNodes[y];
			a1.push(indent+curNode.nodeName);
			if(typeof curNode.attributes != "undefined"){
			alert(typeof curNode.attributes);
			return;
				for( var x = 0; x < curNode.attributes.length; x++ ) {
					a1.push(indent+"|"+curNode.attributes[x].nodeName+"="+curNode.attributes[x].nodeValue); 
				}
			}
			if(curNode.childNodes.length != 0){
				putTreeInArray(curNode, level+1);	
			}
		}
	} 
	//putTreeInArray(h1,0);
	putTreeInArray(window.document,0);
	 */
	var d1=document.getElementById("forreal");
	d1.value=a1.join("\n");
};
forceit();
</script>

<cfscript>
zRequireJquery();
zRequireJqueryUI();

</cfscript> 
	
	<style>
	
	##gallery { float: left; width: 65%; min-height: 12em; } * html ##gallery { height: 12em; } /* IE6 */
	.gallery.custom-state-active { background: ##eee; }
	.gallery li { float: left; width: 96px; padding: 0.4em; margin: 0 0.4em 0.4em 0; text-align: center; }
	.gallery li h5 { margin: 0 0 0.4em; cursor: move; }
	.gallery li a { float: right; }
	.gallery li a.ui-icon-zoomin { float: left; }
	.gallery li img { width: 100%; cursor: move; }

	##trash { float: right; width: 32%; min-height: 18em; padding: 1%;} * html ##trash { height: 18em; } /* IE6 */
	##trash h4 { line-height: 16px; margin: 0 0 0.4em; }
	##trash h4 .ui-icon { float: left; }
	##trash .gallery h5 { display: none; }
	
	.ui-state-highlight{ background-color:##EEE; background-image:none; border:1px solid ##CCC; width:25px; height:25px; margin-bottom:20px; }
	.ui-resizable-helper{ border:2px dotted ##666;}
	.mceExternalToolbar {     position: absolute !important;  left:0px !important;  top:-130px  !important; }; 
	
	.parasizer{ padding-top:5px; padding-bottom:5px; }
	.parasorter{margin-right:20px; margin-bottom:20px; cursor:move !important;}
	</style>
    <cfsilent>
			<cfscript>
            
            htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "content_text";
            htmlEditor.value			= '';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
            htmlEditor.height		= 100;
			htmlEditor.config.theme_advanced_toolbar_location ="external";
            htmlEditor.create();
            </cfscript>  
            </cfsilent>  


<script type="text/javascript">
curParaIs=0;//$('##para'+curParaIs).className='';$('##para'+curParaIs).resizable();
var configArray = [{content_css:"#request.zos.globals.editorStylesheet#",theme : "advanced",mode : "none",language : "en",height:"200",width:"100%",theme_advanced_layout_manager : "SimpleLayout",theme_advanced_toolbar_location : "bottom",theme_advanced_toolbar_align : "left",theme_advanced_buttons1 : "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull",theme_advanced_buttons2 : "",theme_advanced_buttons3 : ""},{content_css:"#request.zos.globals.editorStylesheet#",theme : "advanced",mode : "none",language : "en",width:"100%",theme_advanced_layout_manager : "SimpleLayout",theme_advanced_toolbar_location : "bottom",theme_advanced_toolbar_align : "left"}];
</script>
<h1>Below is a demonstration of how an in-context layout and content manager could work</h1>

<div id="demodescription" style="width:#request.zos.globals.maximagewidth#px; border:2px solid ##ccc; padding:20px;">
<div id="para4divparent" class="parasizer"  style=" width:200px; float:left; z-index:1000; margin-right:20px; margin-bottom:20px; position:relative; background-color:##CCC;"><div id="para4" class="parasorter" onDblClick="tinyMCE.execCommand('mceAddControl', false,'para4');curParaIs=4;">Floating Left</div></div>
<div id="para1divparent" class="parasizer" style="float:none;"><div id="para1" class="parasorter"  onDblClick="tinyMCE.settings.theme_advanced_resizing=false;tinyMCE.settings.theme_advanced_statusbar_location=false;tinyMCE.settings.theme_advanced_path=false;
tinyMCE.execCommand('mceAddControl', true,'para1');curParaIs=1;tinyMCE.settings.theme_advanced_path=true;tinyMCE.settings.theme_advanced_resizing=true;">This is long section of text.  Double click the text to edit it. <br /> <br />
When the text has more line breaks<br />
<br />
It will wrap around <br />
<br />the floating object.
</div></div>
<div id="para2divparent" class="parasizer" style="float:none;"><div id="para2" class="parasorter"  onDblClick="tinyMCE.settings=configArray[0];tinyMCE.execCommand('mceAddControl', false,'para2');curParaIs=2;">When the editor is closed, you can drag the text up and down to change its position.</div></div>

<div id="para5divparent" class="parasizer"  style=" width:200px; float:right; z-index:1000; margin-left:20px; margin-bottom:20px; position:relative; background-color:##CCC;"><div id="para5" class="parasorter" onDblClick="tinyMCE.execCommand('mceAddControl', false,'para5');curParaIs=5;">Floating Right</div></div>
<div id="para33divparent" class="parasizer" style="float:none;"><div id="para33" class="parasorter"  onDblClick="tinyMCE.execCommand('mceAddControl', false,'para33');curParaIs=33;">You can drag the handle in bottom right corner to resize the width of the content block.</div></div>
<div id="para3divparent" class="parasizer" style="float:none;"><div id="para3" class="parasorter"  onDblClick="tinyMCE.execCommand('mceAddControl', false,'para3');curParaIs=3;">This is all possible by a combination of sortable and resizable from the Jquery UI library.</div></div>
<br style="clear:both;" />
</div><!-- End demo-description -->

<script type="text/javascript"> 
tinyMCE.execCommand("mceAddControl", true, "myeditbox");
</script> 
	<script>  
	zArrDeferredFunctions.push(function(){
		$("##demodescription").sortable({items:'.parasizer',cancel:'.ui-resizable-handle',placeholder: "ui-state-highlight",
		start:function(event,ui){
			var d=ui.item[0]; 
			var f=(typeof d.style.cssFloat != "undefined") ? d.style.cssFloat : d.style.styleFloat;
			if(f=="left"){
				$('.ui-state-highlight').css({float:"left",width:($(d).width()-2)+"px",height:($(d).height()-2)+"px",marginLeft:"0px",marginRight:"20px"});
			}else if(f=="right"){
				$('.ui-state-highlight').css({float:"right",width:($(d).width()-2)+"px",height:($(d).height()-2)+"px",marginLeft:"20px",marginRight:"0px"});
			}else{
				$('.ui-state-highlight').css({float:"none",width:($(d).width()-2)+"px",height:($(d).height()-2)+"px",marginLeft:"0px",marginRight:"0px"});
			}
			}});
		$( "##demodescription").disableSelection();
		$("##demodescription .parasizer").resizable({
			maxHeight: 50000,
			maxWidth: parseInt("#request.zos.globals.maximagewidth#"),
			minHeight: 50,
			minWidth: 50,
			grid: 50,
			helper:"ui-resizable-helper",
			handles: 'se',
			stop:function(event, ui){this.style.height="auto";}
		}); 
	});
	</script>
<br style="clear:both;" />
<a href="##" onclick=" tinyMCE.execCommand('mceRemoveControl', true,'para'+curParaIs); return false;">Remove Control</a>
</cfif>

<cfif form.action EQ "testHTMLParser">
<cfsavecontent variable="theHTML">
#application.zcore.functions.zHTMLDoctype()#
<!--- <head>
<meta charset="UTF-8" />
<title>HTML 5 Template Language</title>
</head>
 --->
<body>
<!--- 
<!--- zout tests --->
zout::ignoreme:start|zout:blog1:|end

start|zout:blog2   :|end

start|zout:blog3(    {   dateformat    :   'zout:   test test  ' } ) :|end

start|zout:blog4:|end 


start|zout:blog5({dateformat:'zout:test test'}) :|end
start|zout:blog6   (   {  dateformat    :   234.54   } )    :|end
start|zout:   blog6   (   {  dateformat    :   true   } )    :|end

start|zout:blog7({dateformat:'zout:test\\\' test'}) :|end

start|zout:blog8({dateformat:"zout:test\\\" test"}) :|end

---> <!--- <br data-zif="page.date({dateformat:'m/yy/dd'}) EQUAL news({dateformat:'m/yy/dd'})" />
test
<br data-zendif="" />
<div style="width:800px; margin:0 auto;"> 
<span style="color:##FFF;" class="blogAuthorClass"><a href="zout$blog.authordate({dateformat:'m/yy'})$" data-zout="blog.author">Author</a></span> --->
<!--- <!-- for blog2 in blog -->
<!-- if blog1.enabled --> --->
<!-- for myWidget in zwidget.widget1 -->
$$1000 $myWidget.heading$ at $myWidget.date1({dateformat:"m \" $$ yy"})$<br />
$=myWidget.htmltext$
<!-- endfor -->
<!--- <!-- else -->
<!-- endif -->
<!-- endfor --> --->
<!--- <table style="border-spacing:0px; padding:10px; width:250px; float:right; border-left:1px solid ##CCC; margin-left:20px; margin-bottom:20px;padding-top:0px;">
<tr>
<td><h2>10 Most Popular Blog Articles</h2></td>
</tr>
<!-- Looping over several rows is very simple using any element, such as <tr> or <div> -->
<tr data-zloop="blog.populararticles({count:10,name:'blog1'})" class="trrow">
<td><h3 data-zout="blog1.title">Title</h3>
Posted by <span data-zout="blog1.author">Author</span> on <span data-zout="blog1.datetime({dateformat:'m/d/yy'})">Date/Time</span></td>
</tr>
</table>

</div> ---> <!--- 
<!--- Even this is working, which is very complex: --->
<p>I am in a p</p>
testing some text out of a block
<script type="text/javascript">
var test1=true;
test=true;
</script> 
<!-- Testing a comment -->
<p><span><span><input type="text" id="name1" value="more & more" /> test1 </span>  </span></p><div>test2</div> 
<br data-zif="page.name EQUAL 'contact us'" />
 test
<br data-zendif="" /> 

<br data-zif="(page.name EQUAL 'contact us' and true EQUAL true)" />
<div>test1</div>
<br data-zelseif="page.name EQUAL 'news'" />
test2
<br data-zelse="" />
<div>test3</div>
<br data-zendif="" /> 
<span>wh</span><span>at</span><span> i </span><span>f they are tightly spaced - you learn more & more everyday</span>
<br data-zif="page.name EQUAL 'contact us'" /><div><img src="/z/a/fancy-header.jpg" alt="Fancy Header" /><br data-zendif="" />
<br data-zif="page.name EQUAL 'contact us'" /></div><br data-zendif="" />

<script type="text/javascript">
document.write('<script type="text/javascript"> '+
'alert(\'test1\'); '+
'</script>');
document.write('test2');
</script>
test3

<script type="text/javascript">
document.write('<script type="text/javascript"> '+
'alert(\'test1\'); '+
'</script>');
document.write('test2');
</script>
<p>Another p
</p> --->
<!--- need all unclosed tags to be closed before display errors about body or html tags --->
</body></html>
</cfsavecontent>



<cfscript>
request.zos.viewData=structnew();
request.zos.viewData.zwidget=structnew();
request.zos.viewData.zwidget.widget1=structnew();
request.zos.viewData.zwidget.widget1[1].heading="test";
request.zos.viewData.zwidget.widget1[1].htmltext="<strong>testing bold1</strong>";
request.zos.viewData.zwidget.widget1[1].date1="2012-01-04";
request.zos.viewData.zwidget.widget1[2].heading="test2";
request.zos.viewData.zwidget.widget1[2].htmltext="<strong>testing bold2</strong>";
request.zos.viewData.zwidget.widget1[2].date1="2012-04-04";
request.zos.viewData.zwidget.widget1[3].heading="test3";
request.zos.viewData.zwidget.widget1[3].htmltext="<strong>testing bold3</strong>";
request.zos.viewData.zwidget.widget1[3].date1="2012-09-04";


writeoutput('<h3>Original</h3>'&'<textarea name="c49" style="width:700px; height:300px; ">'&htmleditformat(theHTML)&'</textarea>'&'<br /><br /><hr />');
zHTMLSetupGlobals();
ts=structnew();
ts.theHTML=theHTML;
ts.allowColdfusion=false;
rs=zParseHTMLIntoArray(ts);
if(rs.success EQ false){
	writeoutput(rs.errorMessage);
	//zdump(rs);
}else{

	//zdump(rs);application.zcore.functions.zabort();
	rs.arrHTML=zHtmlRemoveServerSideScriptsFromArray(rs.arrHTML,true);
	
	//zdump(rs.arrHTML);
	rs=zAnalyzeXHTMLNestingFromArray(rs.arrHTML);
	//zdump(rs);
	if(rs.success EQ false){
		for(i=1;i LTE arraylen(rs.arrErrorMessage);i++){
			writeoutput(rs.arrErrorMessage[i]&'<br />');
		}
		writeoutput('<h3>Error Output</h3>'&'<textarea name="c49" style="width:700px; height:300px; ">'&htmleditformat(theHTML)&'</textarea>');
		//zdump(rs);
	}else{
		
		//zdump(rs);
		//xmlDoc=zHTMLArrayToXMLObject(rs.arrHTML);
		//zdump(xmlDoc);
		ts=structnew();
		ts.arrHTML=rs.arrHTML;
		ts.enableIndenting=true;
		ts.enableXHTMLStrictOutput=true;
		ts.enableUTF8=true;
		ts.html5=true;
		rs=zRebuildXHTMLFromArray(ts);
		//zdump(rs);
		if(rs.success EQ false){
			writeoutput("ERROR on line ###rs.line#: "&rs.error&'<br />');
			writeoutput(application.zcore.functions.zGetLineFromVariable(theHTML, rs.line));
		}else{
			application.zcore.functions.zwritefile("ram://tempCompiledSkin.cfc", '<cfcomponent output="no">
<cffunction name="render" localmode="modern" output="yes" access="remote" returntype="any">
<cfscript>
var viewdata=request.zos.viewdata;
page=structnew();
page.date=now();
news=now();
blog=structnew();
author="Auth";
blog.author="Author";
blog.authordate=now();
blog.authorlink="Test link";
</cfscript>
	'&rs.result&'
</cffunction>
</cfcomponent>');
			application.zcore.functions.zClearCFMLTemplateCache();


			r=application.zcore.functions.zreadfile("ram://tempCompiledSkin.cfc");
			writeoutput('<h3>Compiled</h3>'&'<textarea name="c49" style="width:700px; height:300px; ">'&htmleditformat(r)&'</textarea><br /><br /><hr /><h3>Rendered</h3>');
			
			c=application.zcore.functions.zcreateobject("component", "inmemory.tempCompiledSkin", true);
			c.render();
		}
		
	}
}
</cfscript>


</cfif>
</cffunction> 

</cfoutput>
</cfcomponent>