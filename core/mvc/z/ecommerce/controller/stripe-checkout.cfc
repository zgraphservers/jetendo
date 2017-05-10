<cfcomponent>
<cfoutput>
<cffunction name="process" localmode="modern" access="remote">
	<cfscript>
		if ( NOT structKeyExists( form, 'stripeToken' ) ) {
			throw( 'Invalid request' );
		}

		stripeToken = form.stripeToken;

		writeDump( form );
		abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
