<cfcomponent>
 <cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	var curEmail=0;
	var privacyTextMissing=0;
	var zpagenav=0;
	var r1=0;
	var ts=0;
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zSetModalWindow();
	}
	</cfscript>
	<cfsavecontent variable="zpagenav">
	<a href="/">Home</a> / <a href="/z/misc/system/legal">Legal Notices</a> /
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title","Privacy Policy Statement");
	application.zcore.template.setTag("pagetitle","Privacy Policy Statement");
	application.zcore.template.setTag("pagenav",zpagenav);
	</cfscript>
	<cfset privacyTextMissing=false>
	<cfif application.zcore.app.siteHasApp("content")>
		<cfscript>
		ts=structnew();
		ts.content_unique_name='/z/user/privacy/index';
		//ts.disableContentMeta=false;
		ts.disableLinks=true;
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(r1 EQ false){
			privacyTextMissing=true;
		}
		</cfscript>
	<cfelse>
		<cfset privacyTextMissing=true>
	</cfif>
<cfif privacyTextMissing>

<div class="zprivacy-quicklinks">

<h2>Quick Links</h2>
<ul><li><a href="#request.zos.currentHostName#/z/user/preference/index">Update Your Communication Preferences</a></li>
<li><a href="#request.zos.currentHostName#/z/user/out/index">Unsubscribe from our mailing list</a></li></ul>

</div>

<p><strong>Company contact information:</strong><br />
<cfscript>
curEmail=application.zcore.functions.zvarso('zofficeemail');
if(curEmail EQ ""){
	writeoutput('Please call us using the number above.');
}else{
	writeoutput(application.zcore.functions.zEncodeEmail(listgetat(curEmail,1,","),true));
}
</cfscript></p>

<p>
For each visitor to our Web page, our Web server automatically recognizes the consumer's domain name and e-mail address (where possible).</p>
<h2>Information Collection</h2>
<p>We collect only the domain name, but not the e-mail address of visitors to our Web page, the domain name and e-mail address (where possible) of visitors to our Web page, the e-mail addresses of those who post messages to our bulletin board, the e-mail addresses of those who communicate with us via e-mail, the e-mail addresses of those who make postings to our chat areas, aggregate information on what pages consumers access or visit, user-specific information on what pages consumers access or visit, information volunteered by the consumer, such as survey information and/or site registrations, name and address, telephone number, fax number.</p>
<p>The information we collect is used for internal review and is then discarded, used to improve the content of our Web page, used to customize the content and/or layout of our page for each individual visitor, used to notify consumers about updates to our Web site, used by us to contact consumers for marketing purposes.</p>
<h2>Information sharing</h2>
<cfif application.zcore.functions.zso(request.zos.globals, 'privacyShareWithPartners', true, 0) EQ 1>
	<p>We may share your contact information with our business partners for marketing purposes.</p>
<cfelse><!---  --->
	<p>At this time, we don't share information with other companies except for our business partners so you will only receive e-mails from our company.  If this changes in the future, our privacy policy will be updated and a clear notice will be given before the user signs up regarding how the information will be shared.</p>
</cfif>
<h2>Cookies &amp; Tracking</h2>
<p>With respect to cookies: We use cookies to store visitors preferences, record session information, such as items that consumers add to their shopping cart, record user-specific information on what pages users access or visit, alert visitors to new areas that we think might be of interest to them when they return to our site, record past activity at a site in order to provide better service when visitors return to our site , ensure that visitors are not repeatedly sent the same banner ads, customize Web page content based on visitors' browser type or other information that the visitor sends.</p>
<h2>Updating your communication preferences</h2>
<p>If you do not want to receive e-mail from us in the future, please let us know by visiting us at <a href="#request.zos.currentHostName#/z/user/out/index">#request.zos.currentHostName#/z/user/out/index</a>.</p>
<p>If you should change your mind and want to receive our e-mails, please let us know by visiting us at <a href="#request.zos.currentHostName#/z/user/preference/index">#request.zos.currentHostName#/z/user/preference/index</a>.</p>
<p>If you supply us with your postal address on-line you may receive periodic mailings from us with information on new products and services or upcoming events.   If you do not wish to receive such mailings, please let us know by visiting us at <a href="#request.zos.currentHostName#/z/user/preference/index">#request.zos.currentHostName#/z/user/preference/index</a>.</p>
<p>Please provide us with your exact name and address. We will be sure your name is removed from the list we share with other organizations  </p><p>Persons who supply us with their telephone numbers on-line may receive telephone contact from us with information regarding new products and services or upcoming events. If you do not wish to receive such telephone calls, please let us know by visiting us at <a href="#request.zos.currentHostName#/z/user/preference/index">#request.zos.currentHostName#/z/user/preference/index</a>.</p>
<p>Please provide us with your name and phone number. We will be sure your name is removed from the list we share with other organizations</p>
<p>Upon request we provide site visitors with access to a description of information that we maintain about them.</p>

<h2>Tracking for advertising purposes</h2>
<p>With respect to Ad Servers: To try and bring you offers that are of interest to you, we have relationships with other companies that we allow to place ads on our Web pages. As a result of your visit to our site, ad server companies may collect information such as your domain type, your IP address and clickstream information.  For further information, consult the privacy policies of:</p>
<h2>This privacy policy is subject to change</h2>
<p>From time to time, we may use customer information for new, unanticipated uses not previously disclosed in our privacy notice. If our information practices change at some time in the future we will post the policy changes to our Web site to notify you of these changes and provide you with the ability to opt out of these new uses.  If you are concerned about how your information is used, you should check back at our Web site periodically, we will post the policy changes to our Web site to notify you of these changes and we will use for these new purposes only data collected from the time of the policy change forward. If you are concerned about how your information is used, you should check back at our Web site periodically.</p>
<h2>Security</h2>
<p>We have appropriate security measures in place in our physical facilities and software to protect against the loss, misuse or alteration of information that we have collected from you at our site.</p>
<h2>Complaints</h2>
<p>If you feel that this website is not following its stated privacy policy, you may contact us at the above contact information.</p>
<h2>Additional Legal Information</h2>
<p>For more information regarding the terms &amp; conditions of using this web site, please refer to the legal notices page on our web site at the following url: 
<a href="#request.zos.currentHostName#/z/misc/system/legal">#request.zos.currentHostName#/z/misc/system/legal</a>
</p>
</cfif>
</cffunction>
</cfoutput>
</cfcomponent>