<cfcomponent>
 <cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
	 <cfscript>
	 var curEmail=0;
	var privacyTextMissing=0;
	var zpagenav=0;
	var r1=0;
	var ts=0;
    form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', true, 0);
    if(form.modalpopforced EQ 1){
		application.zcore.functions.zSetModalWindow();
    }
	</cfscript>
	<cfsavecontent variable="zpagenav">
	<a href="/">Home</a> / <a href="/z/misc/system/legal">Legal Notices</a> /
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title","Terms Of Use Agreement");
	application.zcore.template.setTag("pagetitle","Terms Of Use Agreement");
	if(form.modalpopforced EQ 0){
		application.zcore.template.setTag("pagenav",zpagenav);
	}
	</cfscript>
	<cfset privacyTextMissing=false>
	<cfif application.zcore.app.siteHasApp("content")>
		<cfscript>
		ts=structnew();
		ts.content_unique_name='/z/user/terms-of-use/index';
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
		<p>PLEASE READ THESE TERMS AND CONDITIONS OF USE CAREFULLY BEFORE USING THIS SITE. Your use of this website is 
		expressly conditioned on your acceptance of the following terms of use. By using this website, you signify your 
		assent to these terms of use and the PRIVACY POLICY. If you do not agree with any part of these terms of 
		use, you must not use this website.</p>

<h2>Parties to this agreement:</h2>
<p>Company: The owner(s) of this website.</p>
<p>Customer: Any other person using this website.</p>

<h2>Eligibility</h2>
<p>You agree that you are of legal age in the country you are located or have parent/guardian permission to use the website according to the 
terms of this agreement.</p>

<h2>Electronic Signatures</h2>
<p>The Customer agrees that they have the software & hardware necessary to access the service and make agreements electronically.</p>
<!--- <p>The Customer may request a physical copy of this agreement to be mailed to their physical address for a one time charge of $5.</p> --->
<p>To sign agreements with the Company, the Customer must have access to a regular personal computer or mobile device 
that has the Adobe Reader&reg; or Adobe Acrobat&reg; software installed and one of Supported Software Configurations listed below.</p>
<p>Should the Customer not agree to this agreement now or in the future, they will no longer be able to use the online services and 
any fees already charged will be non-refundable.</p>
<p>The Company may gather certain information such as the Customer's IP Address, User Agent, date, name and email address to record 
electronic signatures. The electronic signature process will be secured through SSL encryption, digital certificates and email verification.</p>
<p>The Customer agrees to keep their email account private and update the Company with their latest contact 
information as time passes to prevent unauthorized signatures.</p>

<h2>Supported Software Configuration</h2>
<p>To use the website, you must have one of the following software configurations.</p>
<p><strong>Software Configuration 1: </strong><br />A desktop / laptop computer with a recent version of one of the following browsers 
released in the past 5 years for desktop computers: Internet Explorer, Chrome, Safari or Firefox 
for the Apple Mac OS X, Microsoft Windows or Linux operating systems.</p>
<p><strong>Software Configuration 2:</strong><br />
A mobile phone or tablet device with one of the following browsers Chrome, Safari, Firefox for the Windows 8+, iOS 6+ or 
Android 4+ mobile operating systems.</p>
<h3>Limited Support For Errors and Omissions</h3>
<p>If you find that the website doesn't function correctly or has incorrect information, please notify the Company.</p>
<p>The Customer acknowledges that the website may not function the same way on all supported software and at all screen sizes.</p>
<p>The Company is not obligated to fix the problem for free, or on a specific schedule, but will use this feedback to 
improve the quality of the website at a later at its sole discretion with or without providing notification to the Customer.</p>
<h3>Upgrading your software</h3>
<p>Your device may be able to be upgraded to be compatible if it is not compatible at this time.  Please visit the following 
URL to select a modern browser for your device: 
<a href="http://www.browsehappy.com/" target="_blank">http://www.browsehappy.com/</a></p>
<p>Please note that software for many mobile devices and very old computers can't be upgraded, and you may need to obtain a 
new device to access the web site in a way that is fully functional.</p>

<h2>Ownership</h2>
<p>This website, and each of its components, is the copyrighted property of the Company, and/or its various third-party
 providers and suppliers and may not be used without the prior written consent of their owners. None of the content or 
 data found on this website may be reproduced, republished, distributed, sold, transferred, or modified without the express 
 written permission of The Company and/or its third-party providers and suppliers. In addition, the trademarks, logos 
 and service marks displayed on this website (collectively, the &quot;Trademarks&quot;) are registered and common law 
 Trademarks of The Company, its affiliates, and various third-parties. Nothing contained on this website should be 
 construed as granting, by implication, estoppel, or otherwise, any license or right to use any of the Trademarks 
 without the written permission of The Company or such other party that may own the Trademarks.</p>

<h2>License Limitations</h2>
<p>Any free or paid software or subscription services provided to you by the Company are provided under a limited license, 
not SOLD unless otherwise stated in writing.</p>

<h2>Links to Third-Party websites</h2>
<p>This website may contain hyperlinks to websites operated by parties other than The Company. Such hyperlinks are provided
 for your reference only. The Company does not control such sites and is not responsible for their contents. The Company's 
 inclusion of hyperlinks to such sites does not imply any endorsement of the material on such sites or any association 
 with their operators. If you decide to access other websites or participate in any offers or programs via such sites, 
 you do so at your own risk.</p>

<h2>General</h2>
<p>This agreement is governed by the laws of the state nearest the Company's headquarters. You hereby consent to granting the Company 
the right to set the exclusive jurisdiction and venue to be the court system nearest the Company's headquarters in all disputes 
arising out of or relating to the use of this website. 
Use of this website is unauthorized in any jurisdiction that does not give effect to all provisions of these terms of use, 
including, without limitation, this paragraph.</p>

<p>You agree that no joint venture, partnership, employment, or agency relationship exists between you and The Company as a 
result of this agreement or use of this website.</p>

<p>Employment inquiries sent to us regarding employment with The Company are handled in accordance with our employment policies. 
Please be aware that submission of your resume or employment application to The Company does not create any obligation to respond 
to such solicitation and The Company cannot guarantee any result. The Company is an equal opportunity employer.</p>

<p>These terms of use and The Company's performance are subject to existing laws and legal process, and nothing contained in this 
agreement is in derogation of The Company's right to comply with law enforcement requests or requirements relating to your use of 
this website or information provided to or gathered by The Company with respect to such use.</p>

<p>This website and the content provided in this website may not be copied, reproduced, republished, uploaded, posted, transmitted 
or distributed without the written permission of The Company, except that you may view using a browser, cache, display and/or print 
one copy of the materials presented on this website on a single computer for your personal use or legitimate business use only. 
'Deep-linking', 'embedding' or using analogous technology is strictly prohibited unless specifically authorized in writing by The 
Company. You may also use the interactive features to discuss topics with other users, make purchases and register for additional 
services provided by the Company. Unauthorized use of this website and/or the materials contained on this website may violate 
applicable copyright, trademark or other intellectual property laws or other laws. You must retain all copyright and trademark 
notices, including any other proprietary notices, contained in the materials.</p>

<p>If any part of this agreement is determined to be invalid or unenforceable pursuant to applicable law including, but not 
limited to, the warranty disclaimers and liability limitations set forth herein, then the invalid or unenforceable provision 
will be deemed superseded by a valid, enforceable provision that most closely matches the intent of the original provision and 
the remainder of the agreement shall continue in effect.</p>

<p>If you submit information to the Company, you agree to the terms of the privacy policy and its future revisions which are 
published at the following URL: 
<a href="#request.zos.globals.domain#/z/user/privacy/index" target="_blank">#request.zos.globals.domain#/z/user/privacy/index</a></p>

<p>This agreement constitutes the entire Terms of Use agreement between the Customer and The Company with respect to this website and it 
supersedes all prior or contemporaneous communications and proposals, whether electronic, oral, or written, between the Customer 
and The Company with respect to this website. A printed version of this agreement and of any notice given in electronic form 
shall be admissible in judicial or administrative proceedings based upon or relating to this agreement to the same extent and 
subject to the same conditions as other business documents and records originally generated and maintained in printed form.</p>

<p>The owner(s) of this web site may be under a separate agreement with any third party vendor providing these website services 
in which case, any additional agreements made between the third party vendor and the owner(s) takes precedence over this agreement.</p>

<p>The Company reserves the right to remove any information from the website at any time and to prevent the customer from posting 
further information to the website in the exercise of its sole and complete discretion.</p>

<p>The Company encourages the users of the web site to discuss and share information with the social features provided throughout the website. 
The contents of these postings are the comments of those users; each such user 
by posting those comments, agrees to indemnify, defend and hold The Company harmless from any false or derogatory statements 
contained in such comments or postings. As with any other material posted by third-parties to this site, the Company may, at any 
time, remove any materials posted to this site for any reason or no reason.</p>

<p>None of the information contained in any page on this site is confirmed or warranted by any party. Confirmation of information 
published herein is the sole responsibility of the customer.</p>

<p>Inquires are delivered via Internet e-mail and are not to be considered private. Internet e-mail delivery is not 100% reliable 
and The Company is not responsible for undelivered inquiries or for missed income as a result of undelivered inquiries.  
If you believe your inquiry has not been received, please attempt to contact the entity in question through other means.</p>

<p>Any rights not expressly granted herein are reserved.</p>

<h2>Acceptable Use Policy</h2>

<p>These policies are established to preserve a fair and orderly website and to maintain a &quot;family safe&quot; environment. 
Note that these policies are subject to periodic review and may be updated at any time.</p>

<p>Any attempt to disrupt or alter the normal operation of our online services may lead to your access and/or accounts of the 
web site being blocked, deactivated, modified, terminated or deleted, for no reason, with or without notice, at any time, by the 
Company with no offering of a refund or other compensation.</p>
<p>The Company reserves the right to take further corrective action according to criminal and civil laws for misconduct while 
using the online services.</p>
<p>Examples of behavior that are strictly prohibited when using our online services:</p>
<p>1. Attempting to gain access to another user's account.</p>
<p>2. Excessive login attempts or form entries.</p>
<p>3. The Customer agrees not to engage in sending Unsolicited Commercial Bulk Email (SPAM) anywhere on the Internet whether 
through forums, chat, email, or other means regardless of whether this information is sent through the Company's network or not.</p>
<p>4. Downloading in bulk using manual or automated tools to extract, scrape, crawl data, images, videos, text and other documents 
for any purpose other then to create a freely available public search engine or in the normal course of business with written 
permission from the web site owner.</p>
<p>5. Making too many requests at once or too many connections at once beyond what a normal user would have made when using the service.</p>
<p>6. Impersonating other real people</p>
<p>7. Using vulgar language or imagery that may cause offence to other users</p>
<p>8. Posting illegal, pornographic or copyrighted material of any kind without the Company's written permission to the web site.</p>
<p>9. Being a nuisance by discussing issues that are off-topic or too self-promotional in nature in social features.</p>
<p>10. Personally attacking / harassing other users instead of contributing to the discussion in social features.</p>
<p>11. Failing to obey local law.</p>
<p>12. Posting a disruptive number of messages or being otherwise annoying to other users in chat/comments.</p>
<p>13. Failing to stay on topic after repeated warnings from moderators.</p>
<p>14. Using known exploits, bugs, or features to cause others harm or in any way disrupt the online services.</p>
<p>15. Exceeding the limits of any documented API provided by the Company or its vendors.</p>
<p>16. Attempting to operate a business or provide a free service that the Company morally or ethically objects to.</p>
<p>The Customer is responsible for any fees and damages resulting from civil or criminal ligitation arising from a violation of 
this agreement caused by their use of the website.</p>
<p>The Company is the sole arbiter as to what constitutes a violation of the Acceptable Use Policy.</p>
<p>The Company utilizes a number of third party service providers to offer our services which also require the Company to agree to 
similar terms.  If the Customer is found to have violated the policies of the Company's third party service providers, the Customer 
will be responsible for paying any costs they caused including costs arising from violations caused by the Customer's use of the 
web site and may be denied access to any further use of the Company's online services.</p>
<p>The Company reserves the right to remove the posting of any user that mentions The Company or any of its associated websites, URLs, 
or any associated The Company e-mail address in any SPAM e-mail message or Usenet posting. The Company may exercise its full and 
complete discretion in determining what constitutes SPAM or is worthy of removal.</p>

<h2>Copyright Law Policy</h2>

<p>The Customer agrees to cooperate with the Company and any third party in a timely manner regarding any claim of copyright infringement 
or other illegal activity related to removal or modification of content provided by the Customer.</p>
<p>If the Customer fails to respond to such a claim within 5 business days, the Company may attempt to resolve the claim in any way it sees fit.</p>
<p>The Company is entitled to be reimbursed by the Customer for any costs associated with resolving a claim that was caused by the Customer.</p>
<p>The Customer agrees that it is responsible for any and all damages resulting from litigation or settlements regarding copyright 
infringement directly caused by the Customer's use of the web site.</p>
<p>The Customer agrees to not submit copyrighted materials that it doesn't have permission to use for this purpose.</p>
<p>The Customer agrees to notify the Company of any associated licenses attached to the copyrighted materials the Customer provides 
to the Company which may limit the purposes the materials can be used for.</p>
<p>The Customer agrees it doesn't have the permission to reproduce, copy, distribute, modify partial or full copies of other 
copyrighted works including other web sites, images, videos, music, text and other data unless allowed by law.</p>
<p>If you wish to report a potential abuse of copyright on our web site, please read the information related to reporting copyright abuse 
at the following url and submit the form at the bottom of the page. 
<a href="#request.zos.globals.domain#/z/misc/system/legal" target="_blank">#request.zos.globals.domain#/z/misc/system/legal</a> 
and submit the form we provide or contact us through other means.</p>

<h2>User Generated Content Policy</h2>

<p>Any content you submit to the web site's social/wiki features may be permanently and publicly displayed on the web site. </p>
<p>You assign the rights to that publicly listed information to the Company. </p>
<p>The Customer and Company reserves the right to add, change or delete user generated content at any time with or without notice. </p>
<p>You are not assigned any ownership rights to your account or data that is provided while using the Company's services to the 
maximum extent allowed by law. </p>
<p>The information you provide is for the sole benefit of the Company.</p>

<h2>Non Solicitation</h2>

<p>The user acknowledges that The Company has expended significant time and money in developing the information contained within 
the website including client and advertiser relationships.  Use of the website to solicit the Company's clients and advertisers or 
to create a list of prospects is strictly forbidden.</p>

<h2>Exclusion Of Warranty</h2>
<p>THE COMPANY AND ANY THIRD-PARTY PROVIDERS AND SUPPLIERS MAKE NO WARRANTY OF ANY KIND REGARDING THIS SITE AND/OR ANY PRODUCT, 
SERVICE OR CONTENT PROVIDED ON THIS WEBSITE, ALL OF WHICH ARE PROVIDED ON AN &quot;AS IS&quot; &quot;AS AVAILABLE&quot; BASIS. 
THE COMPANY AND ANY THIRD-PARTY PROVIDERS AND SUPPLIERS DO NOT WARRANT THE ACCURACY, COMPLETENESS, CURRENCY OR RELIABILITY OF 
ANY OF THE CONTENT OR DATA FOUND ON THIS SITE AND SUCH PARTIES EXPRESSLY DISCLAIM ALL WARRANTIES AND CONDITIONS, INCLUDING 
IMPLIED WARRANTIES AND CONDITIONS OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT, AND THOSE ARISING 
BY STATUTE OR OTHERWISE IN LAW OR FROM A COURSE OF DEALING OR USAGE OF TRADE.</p>

<h2>Limitation Of Liability</h2>
<p>THE COMPANY ASSUMES NO RESPONSIBILITY, AND SHALL NOT BE LIABLE FOR, ANY DAMAGES TO, OR VIRUSES THAT MAY INFECT YOUR COMPUTER 
EQUIPMENT OR OTHER PROPERTY ON ACCOUNT OF YOUR ACCESS TO, USE OF, OR BROWSING IN THIS SITE OR YOUR DOWNLOADING OF ANY MATERIALS, 
DATA, TEXT, IMAGES, VIDEO, AUDIO OR OTHER MATERIAL FROM THE SITE. IN NO EVENT SHALL THE COMPANY OR ANY THIRD-PARTY PROVIDERS OR 
SUPPLIERS BE LIABLE FOR ANY INJURY, LOSS, CLAIM, DAMAGE, OR ANY SPECIAL, EXEMPLARY, PUNITIVE, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
DAMAGES OF ANY KIND (INCLUDING, BUT NOT LIMITED TO LOST PROFITS OR LOST SAVINGS), WHETHER BASED IN CONTRACT, TORT, STRICT LIABILITY, 
OR OTHERWISE, WHICH ARISES OUT OF OR IS IN ANY WAY CONNECTED WITH (I) ANY USE OF THIS SITE OR CONTENT FOUND HEREIN, (II) ANY 
FAILURE OR DELAY (INCLUDING, BUT NOT LIMITED TO THE USE OF OR INABILITY TO USE ANY COMPONENT OF THIS SITE FOR RESERVATIONS OR 
	TICKETING), OR ( III) THE PERFORMANCE OR NON PERFORMANCE BY THE COMPANY OR ANY THIRD-PARTY PROVIDERS OR SUPPLIERS, EVEN IF 
SUCH PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF DAMAGES TO SUCH PARTIES OR ANY OTHER PARTY. THE COMPANY SHALL NOT BE RESPONSIBLE 
FOR ANY INJURIES, DAMAGES, OR LOSSES CAUSED TO ANY CUSTOMER IN CONNECTION WITH TERRORIST ACTIVITIES, SOCIAL OR LABOR UNREST, 
MECHANICAL OR CONSTRUCTION FAILURES OR DIFFICULTIES, DISEASES, LOCAL LAWS, CLIMATIC CONDITIONS, ABNORMAL CONDITIONS OR DEVELOPMENTS, 
OR ANY OTHER ACTIONS, OMISSIONS, OR CONDITIONS OUTSIDE THE COMPANY'S CONTROL.</p>
<p>IN THE EVENT THE COMPANY IS FOUND LIABLE FOR CLAIMS OR DAMAGES RELATED TO THIS AGREEMENT, THE COMPANY'S TOTAL LIABILITY WILL BE 
LIMITED TO 1) THE TOTAL FEES PAID BY THE CUSTOMER DURING THE 3 MONTHS IMMEDIATELY PRIOR TO THE CLAIM OR 
2) NOTHING IF THE SERVICES WERE PROVIDED FOR FREE.</p>

<h2>Modification</h2>
<p>The Company may at any time modify these terms of use and your continued use of this website will be conditioned upon the 
terms of use under which this website is offered at the time of your use.</p>

<p>The Company may add, change or delete availability and functionality of the data, the software, the hardware and physical location 
of the hosting environment related to the online services at our sole discretion in any way.</p>
<p>If the web site has a login feature, you may be prompted to electronically accept any revised agreements since the last time you 
logged in to the website. You agree that if you don't accept the changes, you will be denied access to further use of the website 
and related services described in the agreement.</p>
<p>You agree that these changes will occur at the Company's time of choice and you won't be given the option to delay, 
refuse or prevent these changes to the service if you wish to continue using the services provided by the Company.</p>

	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>