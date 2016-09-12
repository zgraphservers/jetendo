<cfcomponent>
<cffunction name="init" localmode="modern">
	<cfscript>
	application.zcore.template.setTag("pagenav", '<p><a href="/z/admin/video-training/index">Video Training Documentation</a> /</p>	');
	</cfscript>
	<div style="max-width:960px; font-size:18px;">
</cffunction>
<cffunction name="footer" localmode="modern">
	<cfscript>
	</cfscript>
	</div>
</cffunction>


<cffunction name="index" access="remote" localmode="modern" roles="member">
	<cfscript>
	title="Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<div style="max-width:960px; font-size:18px;">
	<p>We've created videos on each of the following topics and also included the corresponding text documentation from the video for quick review.</p>
	<ul>
	<li><a href="/z/admin/video-training/html-editor">HTML Editor</a></li>
	<li><a href="/z/admin/video-training/blog-features">Blog Features</a></li>
	<li><a href="/z/admin/video-training/page-features">Page Features</a></li>
	<li><a href="/z/admin/video-training/files-and-images-features">Files and Images Features</a></li>
	<li><a href="/z/admin/video-training/lead-features">Leads Features</a></li>
	<cfif application.zcore.app.siteHasApp("event")>
		<li><a href="/z/admin/video-training/event-features">Event Features</a></li>
	</cfif>
	<li><a href="/z/admin/video-training/video-library-features">Video Library Features</a></li>
	<li><a href="/z/admin/video-training/user-features">User Features</a></li>
	</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="html-editor" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="HTML Editor - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 8 minutes 1 second</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-html-editor.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<ul>
<li>The HTML Editor is able to handle a variety of HTML elements including embedded images, videos, iframes, links and tables.</li>
<li>You can upload and insert images that allow text to wrap around them.</li>
<li>You can upload and insert links to files like pdfs.</li>
<li>You can also organize images and files in directories.</li>
<li>You can make a single line break by press shift + enter instead of enter</li>
<li>You can directly view/edit the HTML by clicking on Tools &gt; Source Code</li>
<li>You should try to set headings with Formats &gt; Headings</li>
<li>If you want to remove formatting like bold/fonts/colors, you should select all the text and then click on Format &gt; Clear formatting.</li>
<li>If you still have trouble with formatting when pasting from something else, it is suggested to paste your information to notepad first, and then paste it in the editor. You&rsquo;ll have to rebuild any links, but this is the easier way to deal with advanced formatting problems.</li>
<li>You can create links by typing and selecting some text, and then clicking on the chain link icon. If you set the target to blank, the link will open in a new window when clicked.</li>
<li>You can insert a video or iframe in a specific location, by clicking Insert &rarr; Insert Video, Click on Embed, and then paste the code. Be careful not to paste &lt;script&gt; tag in the editor, as this is not supported and can break the website.</li>
<li>It is not recommended to add tables in the HTML editor because these don&rsquo;t resize very well on mobile devices and they are more difficult to edit. However, the editor will display tables and allow editing them if you use them anyway.</li>
</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="blog-features" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="Blog Features - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 4 Minutes 54 seconds</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-blog-features.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<p>Categories</p>
<ul>
<li>You must create 1 category before adding articles</li>
<li>Separate blog posts into different landing pages.</li>
</ul>
<p>Tags</p>
<ul>
<li>Optional way to organize the blog.</li>
<li>Separate blog posts into different landing pages. Enables tag cloud on blog article detail pages as an alternate way to navigate the web site.</li>
</ul>
<p>Articles</p>
<ul>
<li>Post articles with optional images</li>
<li>If author is enabled, you must add a user first</li>
<li>If the date is set to the future, the blog post will not appear for the public until that date has passed.</li>
<li>Optionally attach image libraries.</li>
<li>On sites with listing application, you can associate listing searches with the article to allow listings to appear directly below the article.</li>
</ul> 
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="page-features" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="Page Features - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 13 minutes 58 Seconds</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-page-features.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<ul>
<li>The pages feature should be used for all content that is meant to be permanent and which doesn&rsquo;t need a custom layout.</li>
<li>All of the built-in landing pages and custom records are listed at the bottom of manage pages to make it easier to find other content that exists or can be edited.</li>
<li>Several of the built-in inquiry forms, thank you page, privacy policy, mailing list signup, and terms of use pages can be overridden with different text by creating a page that have the exact same URL.</li>
<li>You only need to type a title when adding a page. The summary field is shown when the page is shown as a child in its summary view. The body text field is used for the detail view of the page.</li>
<li>You can sort pages by clicking and dragging the arrow icon.</li>
<li>You can add child pages to a page and it will automate the creation of links from the parent page to the child page(s).</li>
<li>Once you create a child page, you can navigate to view/edit the subpages by clicking on &ldquo;Subpages&rdquo; or the title of the parent page.</li>
<li>You can create unlimited child pages and sort them.</li>
<li>You can attach images to pages and set how they are displayed.</li>
<li>You can create child pages on an existing child page to make a deeper hierarchy.</li>
<li>To help visualize the structure of a site that has many child pages, you can click on &ldquo;Site Map&rdquo; to see all of the pages with their child pages indented and sorting disabled.</li>
<li>If you need to move a page to a different location, you can edit the Parent Page field on the Navigation/Layout tab.</li>
<li>You can change the layout of how the child links appear, or hide them. These child link layouts are automatically mobile responsive.</li>
<li>You can make the child pages appear unlinked, so that this feature allows building layouts that don&rsquo;t need the sub-page feature, but otherwise would look good with pages.</li>
<li>You can restrict a page to only being visible to logged in users of specific user groups. All of the child pages of that page will also be restricted automatically.</li>
<li>If the listing application is enabled on a site, you can set a listing search and the listings will appear directly below the page content.</li>
<li>The import feature allows typing a titles on separate lines to make many pages at once.</li>
</ul>
<p>&nbsp;</p>
<p>Advanced Developer Features:</p>
<ul>
<li>Developers can &ldquo;hide&rdquo; pages so the client can&rsquo;t view or edit them. This avoids confusion for pages that are placeholders to make the site work, or built-in pages like &ldquo;home page&rdquo; which often have a custom way of being edited.</li>
<li>You can create many pages at once by first creating a specially formatted CSV, which can also automate creating subpages if the IDs and URLs are consistent. The import should only be done once. It is not meant to be used for updating.</li>
<li>Developers can create a page that is used on a specific page, but that doesn&rsquo;t have routing enabled. This allows you to create a custom layout for that page. You create a script that works on the same URL to do that. There is a function you can call in order to include the page content where you want in your custom layout.</li>
</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="files-and-images-features" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="Files And Images Features - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 1 minute 25 seconds</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-files-and-images-features.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<ul>
<li>The HTML Editor allows you to upload files and images, which are stored under Content Manager -&gt; Files &amp; Images</li>
<li>You can delete these files here. Be aware that any links you made to these files will break if you delete the file. You&rsquo;d have to manually relink any references to the files.</li>
<li>Also beware replacing files/images, since that can also break the links to them if the file name changes.</li>
<li>You can also view the direct view/download link for images and files, so you can use it anywhere else you want.</li>
</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="lead-features" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="Leads Features - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 6 minutes 4 seconds</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-lead-features.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<ul>
<li>Built-in forms and custom forms usually route all the captured information to email and the database for permanent record.</li>
<li>Once a lead is in the system, it can be viewed, commented on, or re-assigned.</li>
<li>It is possible to search leads, and then export only the search results.</li>
<li>You can add a lead manually to the system to allow you to track and assign it in this system.</li>
<li>You can also export all leads at once.</li>
<li>If you create multiple users with the &ldquo;Agent&rdquo; access rights, they will be able to login to view and comment on their own leads.</li>
<li>There is a mailing list signup feature that is separate from the inquiries table. These can be exported separately for use in other email campaign software.</li>
<li>It is possible to create lead template emails, which can be used to automate common email responses or notes for leads.</li>
<li>Each lead type can be routed differently, which changes who the lead is assigned to when new leads come in.</li>
<li>The lead source report will report where leads came from, such as google.com or another domain.</li>
</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="event-features" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="Event Features - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 7 minutes 6 seconds</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-event-features.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<ul>
<li>Events are added to Event Calendars so you must make at least one Event Calendar.<br />You can have unlimited event calendars with different events on them.</li>
<li>You can also create landing pages called Event Categories. Multiple Event Categories can be on a single calendar, and this allows the user to search events by category.</li>
<li>Calendars and Categories can default to a 30 day calendar or a list view. And Search can be turned on or off.</li>
<li>Events just need a title and date range. The date range should be the start and end date for the single occurrence of that event. Any future occurrences should be created as separate records, or use the recurring rules feature. Events can be assigned to multiple calendars and categories.</li>
<li>Events can be set to recur with the same advanced rules that are allowed in the Icalendar standard used by more popular calendar software including email/calendar solutions from Microsoft, Mozilla, Apple and Google.</li>
<li>You can exclude dates from a recurring event schedule by clicking on them, or adding them manually.</li>
<li>You can limit how long or how many times an event repeats.</li>
<li>You can set a location for an event and map its location so the user sees an embedded Google map when viewing the event details.</li>
<li>You can create featured events, which forces them to appear first in list view even if other non-featured events occur sooner.</li>
<li>Developers can import an Icalendar file to migrate the calendar from another system to this system. Our event system has more features and allows this content to be hosted on this web site, boosting it&rsquo;s search engine presence.</li>
</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="video-library-features" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="Video Library Features - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 2 minutes 31 seconds</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-video-library-features.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<ul>
<li>Set the width and height you want the video to be resized to and then select a video, and click Upload. Videos can take several minutes to upload, be patient.</li>
<li>After the video has finished processing, you can click on the <br />&ldquo;Embed&rdquo; link. Set the options and click &ldquo;Generate Embed Code&rdquo;. This iframe code can be copy and pasted anywhere else that HTML iframes are accepted, including the Jetendo HTML Editor.</li>
<li>Note: If you delete a video from the video library, anywhere it was embedded will stop working.</li>
<li>If you receive any strange status/error, please contact the developer. Their may be something wrong with the format of your video, or our system.</li>
</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>

<cffunction name="user-features" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	title="User Features - Jetendo CMS Video Training Documentation";
	application.zcore.template.setTag("title", title);
	application.zcore.template.setTag("pagetitle", title);
	</cfscript>
	<p>Length: 5 minutes 9 seconds</p>
	<p>Note: This video has no audio</p>
<h2><a href="https://www.jetendo.com/zupload/user/video-training/jetendo-user-features.mp4" target="_blank">Watch Video</a></h2>
<p>Feature outline as shown in the video:</p>
<ul>
<li>Jetendo has several built-in user groups. Sometimes a site will have its own custom user groups as well to allow a custom membership feature to work.</li>
<li>When adding a user, it is important to set the &ldquo;Access Rights&rdquo; field to the correct value.</li>
<li>Administrator will have access to view/edit everything in the site manager.</li>
<li>Agent will have access to view/edit their own user profile and their leads.</li>
<li>User will not have access to the site manager, but they will be able to login to a user dashboard and view any content that is accessible to logged in users.</li>
<li>A user can have a &ldquo;public profile&rdquo;, which creates a formatted biography page for them on the front of the web site.</li>
<li>On sites with the listing application enabled, each user can enter their MLS Agent ID so that their public profile information will show on their listings.</li>
<li>Public users who create an account are not initially visible when you click on manage users. You have to click on &ldquo;show public users&rdquo; or search for Access Rights = User.</li>
<li>If you want to create an administrator that has access to edit only certain parts of the site, you can use the Limit Manager Features field to do this. It is recommended to consult the developer on how to use this field to ensure the correct access is set.</li>
<li>You can send a password reset email to any user. This is better then changing their password, since it lets them choose their own password and keep it private.</li>
<li>The information shown on the public user home page can be customized by the developer upon request.</li>
<li>Developers can import users with the Import Users feature, which requires custom programming.</li>
</ul>
	<cfscript>
	footer();
	</cfscript>
</cffunction>
 
</cfcomponent>