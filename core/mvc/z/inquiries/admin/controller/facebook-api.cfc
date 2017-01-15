<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="public">
	<cfargument name="facebookConfig" type="struct" required="yes">
	<cfscript>
		facebookConfig = arguments.facebookConfig;

		variables.apiEndpoint   = 'https://graph.facebook.com/v2.8';
		variables.environment   = this.determineEnvironment();
		variables.batchRequests = [];
		variables.appId         = facebookConfig.appId;
		variables.appSecret     = facebookConfig.appSecret;

		this.setAccessToken( facebookConfig.accessToken );
	</cfscript>
</cffunction>

<cffunction name="setAccessToken" localmode="modern" access="public">
	<cfargument name="accessToken" type="string" required="yes">
	<cfscript>
		variables.accessToken = arguments.accessToken;
	</cfscript>
</cffunction>

<cffunction name="getAccessToken" localmode="modern" access="public">
	<cfscript>
		return variables.accessToken;
	</cfscript>
</cffunction>

<cffunction name="addBatchRequest" localmode="modern" access="public">
	<cfargument name="method" type="string" required="yes">
	<cfargument name="relativeURL" type="string" required="yes">
	<cfscript>
		batchRequest = {
			'method':       arguments.method,
			'relative_url': arguments.relativeURL
		};

		arrayAppend( variables.batchRequests, batchRequest );
	</cfscript>
</cffunction>

<cffunction name="sendBatchRequests" localmode="modern" access="public">
	<cfscript>
		if ( arrayLen( variables.batchRequests ) GT 0 ) {
			if ( arrayLen( variables.batchRequests ) GT 50 ) {
				throw( 'Too many batch requests at once. Maximum of 50 per API call (found ' & arrayLen( variables.batchRequests ) & ').' );
			}

			requestParams = {
				'access_token':    this.getAccessToken(),
				'batch':           serializeJSON( variables.batchRequests ),
				'include_headers': false
			};

			variables.batchRequests = [];

			return this.sendRequest( '/', requestParams, 'POST' );
		} else {
			throw( 'No batch requests found to send.' );
		}
	</cfscript>
</cffunction>


<!--- #################################################################### --->


<cffunction name="getPageLikes" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageLikes" type="struct" required="no" default="#{}#">
	<cfscript>
		pageId    = arguments.pageId;
		pageLikes = arguments.pageLikes;

		pageLikes.access_token = this.getAccessToken();

		return this.sendRequest( '/' & pageId & '/insights/page_fans', pageLikes, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="getPageEngagements" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageEngagements" type="struct" required="no" default="#{}#">
	<cfscript>
		pageId          = arguments.pageId;
		pageEngagements = arguments.pageEngagements;

		pageEngagements.access_token = this.getAccessToken();

		return this.sendRequest( '/' & pageId & '/insights/page_engaged_users', pageEngagements, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="getPageReach" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageReach" type="struct" required="no" default="#{}#">
	<cfscript>
		pageId    = arguments.pageId;
		pageReach = arguments.pageReach;

		pageReach.access_token = this.getAccessToken();

		return this.sendRequest( '/' & pageId & '/insights/page_impressions', pageReach, 'GET' );
	</cfscript>
</cffunction>

<cffunction name="getAllPages" localmode="modern" access="public">
	<cfscript>
		allPages = {
			'access_token': this.getAccessToken()
		};

		return this.sendRequest( '/me/accounts', allPages, 'GET' );
	</cfscript>
</cffunction>

<!--- INSIGHTS --->
<!--- https://developers.facebook.com/docs/graph-api/reference/v2.8/insights --->

<cffunction name="getPageImpressions" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageImpressions" type="struct" required="no" default="#{}#">
	<cfscript>
		pageId          = arguments.pageId;
		pageImpressions = arguments.pageImpressions;

		pageImpressions.access_token = this.getAccessToken();

		response = this.sendRequest( '/' & pageId & '/insights', pageImpressions, 'GET' );

		writeDump( response );
		abort;
	</cfscript>
</cffunction>

<!--- API REQUEST & HELPERS --->

<cffunction name="sendRequest" localmode="modern" access="public">
	<cfargument name="requestURL" type="string" required="yes">
	<cfargument name="params" type="struct" required="no" default="#{}#">
	<cfargument name="method" type="string" required="no" default="POST">
	<cfargument name="timeout" type="numeric" required="no" default="10">
	<cfscript>
		requestURL = arguments.requestURL;
		params     = arguments.params;
		method     = arguments.method;
		timeout    = arguments.timeout;

		requestURL = variables.apiEndpoint & requestURL;

		try{
			http method=method, charset="utf-8", timeout=arguments.timeout, url=requestURL, result="result" {
				httpparam name="appsecret_proof", type="url", value=this.getAppSecretProof();

				if ( isStruct( params ) AND NOT structIsEmpty( params ) ) {
					for ( param in params ) {
						if ( method EQ 'GET' ) {
							httpparam name=param, type="url", value=params[ param ] ;
						} else {
							httpparam name=param, type="formfield", value=params[ param ] ;
						}
					}
				}
			}
		}catch(Any e){
			savecontent variable="out"{
				writedump(arguments);
				writedump(e);
			}
			throw( 'Facebook error<br /><br />'&out );
		}
		if ( result.status_code NEQ 200 ) {
			savecontent variable="out"{
				writedump(arguments);
				writedump(cfhttp);
			}
			throw( 'Facebook error<br /><br />'&out );
		}

		response = this.getResponse( result );

		return response;
	</cfscript>
</cffunction>

<cffunction name="getResponse" localmode="modern" access="private">
	<cfargument name="result" type="struct" required="yes">
	<cfscript>
		return deserializeJSON( arguments.result.filecontent );
	</cfscript>
</cffunction>

<cffunction name="determineEnvironment" localmode="modern" access="private">
	<cfscript>
		var environment = 'development';

		if ( request.zos.isTestServer ) {
			environment = 'development';
		} else {
			environment = 'production';
		}

		if ( structKeyExists( form, 'debug' ) ) {
			environment = 'development';
		}

		return environment;
	</cfscript>
</cffunction>

<cffunction name="inDevelopment" localmode="modern" access="public">
	<cfscript>
		if ( variables.environment EQ 'development' ) {
			return true;
		}

		return false;
	</cfscript>
</cffunction>

<cffunction name="inProduction" localmode="modern" access="public">
	<cfscript>
		if ( variables.environment EQ 'production' ) {
			return true;
		}

		return false;
	</cfscript>
</cffunction>

<cffunction name="getAppSecretProof" localmode="modern" access="private">
	<cfscript>
		return lCase( hmac( variables.accessToken, variables.appSecret, 'HMACSHA256' ) );
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>