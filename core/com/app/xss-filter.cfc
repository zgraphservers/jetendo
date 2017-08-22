<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>

	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
		this.init();
		var db = request.zos.queryObject;

		var poorlyFormattedHTML = '
<a href="javascript:alert(""XSS"");">XSS</a>
<a href="jav	ascript:alert(""XSS"");">XSS</a>
<a href="##okay">Okay</a>
<a href="jav
ascript:alert(""XSS"");">XSS</a>
';

	</cfscript>
</cffunction>

<cffunction name="filterXSSHTML" localmode="modern" access="public">
	<cfargument name="theHTML" type="string" required="yes">
	<cfscript>
		var theHTML = arguments.theHTML;

		// List of HTML tags that we allow.
		var whitelistTags = [
			'a',
			'abbr',
			'b',
			'blockquote',
			'br',
			'cite',
			'code',
			'dl',
			'dd',
			'div',
			'dt',
			'em',
			'h1',
			'h2',
			'h3',
			'h4',
			'h5',
			'h6',
			'hr',
			'i',
			'img',
			'li',
			'ol',
			'p',
			'pre',
			's',
			'small',
			'strong',
			'sub',
			'sup',
			'table',
			'thead',
			'tbody',
			'tr',
			'th',
			'td',
			'tfoot',
			'u',
			'ul'
		];

		for ( tag in whitelistTags ) {

		}

		var filteredHTML = theHTML;

		return filteredHTML;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
