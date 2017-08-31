<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
		variables.storedArray = [];
	</cfscript>
</cffunction>

<cffunction name="trackAjax" localmode="modern" access="remote">
	<cfscript>
		this.init();

		application.zcore.functions.zheader( 'x_ajax_id', application.zcore.functions.zso( form, 'x_ajax_id' ) );

		var trackStruct = {
			'type':  application.zcore.functions.zso( form, 'type' ),
			'event': application.zcore.functions.zso( form, 'event' ),
			'label': application.zcore.functions.zso( form, 'label' )
		};

		this.track( trackStruct );
	</cfscript>
</cffunction>

<!---
Types (see jetendo/statistic_type table):
	1 = Listing
	2 = Profile
	3 = Ad
	4 = Link
	5 = Phone Link

CFML Usage:

	_zs = application.zcore.functions.zCreateObject( 'component', 'zcorerootmapping.com.app.zs' );
	_zs.init();

	_zs.track( {
		'type': 1,
		'event': 'view',
		'label': 'My Listing'
	} );
--->
<cffunction name="track" localmode="modern" access="public">
	<cfargument name="trackStruct" type="struct" required="yes">
	<cfscript>
		var db = request.zos.queryObject;

		var trackStruct = arguments.trackStruct;

		// Validate that all keys are provided.

		db.sql = 'SELECT *
			FROM #db.table( 'statistic', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND statistic_session_id = #db.param( application.zcore.session.getSessionId() )#
				AND statistic_type_id = #db.param( trackStruct.type )#
				AND statistic_event = #db.param( trackStruct.event )#
				AND statistic_label = #db.param( trackStruct.label )#
			LIMIT #db.param( 1 )#';
		qStatistic = db.execute( 'qStatistic' );

		if ( qStatistic.recordcount EQ 0 ) {
			var statisticStruct = {
				'site_id': request.zos.globals.id,
				'statistic_datetime': request.zos.mysqlnow,
				'statistic_type_id': trackStruct.type,
				'statistic_event': trackStruct.event,
				'statistic_label': trackStruct.label,
				'statistic_count': 1,
				'statistic_session_id': application.zcore.session.getSessionId()
			};

			var ts = {
				struct:     statisticStruct,
				datasource: request.zos.zcoreDatasource,
				table:      'statistic'
			};

			var statisticId = application.zcore.functions.zInsert( ts );
		} else {
			db.sql = 'UPDATE #db.table( 'statistic', request.zos.zcoreDatasource )#
				SET statistic_count = statistic_count + #db.param( 1 )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND statistic_session_id = #db.param( application.zcore.session.getSessionId() )#
					AND statistic_type_id = #db.param( trackStruct.type )#
					AND statistic_event = #db.param( trackStruct.event )#
					AND statistic_label = #db.param( trackStruct.label )#';
			qStatistic = db.execute( 'qStatistic' );
		}
	</cfscript>
</cffunction>

<!---

var _zs = application.zcore.functions.zCreateObject( 'component', 'zcorerootmapping.com.app.zs' );
_zs.init();

for ( row in qListing ) {
	_zs.store( {
		'type': 1,
		'event': '...',
		'label': '...'
	} );
}

_zs.commit();

--->
<cffunction name="store" localmode="modern" access="public">
	<cfargument name="trackStruct" type="struct" required="yes">
	<cfscript>
		var trackStruct = arguments.trackStruct;
		arrayAppend( variables.storedArray, trackStruct );
	</cfscript>
</cffunction>

<cffunction name="commit" localmode="modern" access="public">
	<cfscript>
		if ( arrayLen( variables.storedArray ) EQ 0 ) {
			return;
		}

		var db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'statistic', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zos.globals.id )#
				AND statistic_session_id = #db.param( application.zcore.session.getSessionId() )#
				AND ( #db.param( 0 )# = #db.param( 1 )#';

		for ( stored in variables.storedArray ) {
			db.sql &= ' OR ( statistic_type_id = #db.param( stored.type )#
				AND statistic_event = #db.param( stored.event )#
				AND statistic_label = #db.param( stored.label )#
			)';
		}

		db.sql &= ' )';
		qStatistic = db.execute( 'qStatistic' );

		if ( qStatistic.recordcount EQ 0 ) {
			// Insert all
			db.sql = 'INSERT INTO #db.table( 'statistic', request.zos.zcoreDatasource )#
				( site_id, statistic_datetime, statistic_type_id, statistic_event, statistic_label, statistic_count, statistic_session_id )
				VALUES ';

			for ( stored in variables.storedArray ) {
				db.sql &= ' ( #db.param( request.zos.globals.id )#,
					#db.param( request.zos.mysqlNow )#,
					#db.param( stored.type )#,
					#db.param( stored.event )#,
					#db.param( stored.label )#,
					#db.param( 1 )#,
					#db.param( application.zcore.session.getSessionId() )# ), ';
			}
			// remove last 2 chars ", "
			db.sql = left( db.sql, ( len( db.sql ) - 2 ) );
			qStatisticInsert = db.execute( 'qStatisticInsert' );
		} else {
			var alreadyExistsArray = [];

			// Update existing
			db.sql = 'UPDATE #db.table( 'statistic', request.zos.zcoreDatasource )#
				SET statistic_count = statistic_count + #db.param( 1 )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND statistic_session_id = #db.param( application.zcore.session.getSEssionId() )#
					AND ( #db.param( 0 )# = #db.param( 1 )#';

			for ( row in qStatistic ) {
				db.sql &= ' OR ( statistic_type_id = #db.param( row.statistic_type_id )#
					AND statistic_event = #db.param( row.statistic_event )#
					AND statistic_label = #db.param( row.statistic_label )#
				)';

				arrayAppend( alreadyExistsArray, row.statistic_type_id & '|' & row.statistic_event & '|' & row.statistic_label );
			}

			db.sql &= ')';

			qStatisticUpdate = db.execute( 'qStatisticUpdate' );

			// We found the same number in the database that is stored, don't continue.
			if ( qStatistic.recordcount EQ arrayLen( variables.storedArray ) ) {
				return;
			}

			// Insert new
			insertSQL = '';

			for ( stored in variables.storedArray ) {
				if ( ! arrayContains( alreadyExistsArray, stored.type & '|' & stored.event & '|' & stored.label ) ) {
					insertSQL &= ' ( #db.param( request.zos.globals.id )#,
						#db.param( request.zos.mysqlNow )#,
						#db.param( stored.type )#,
						#db.param( stored.event )#,
						#db.param( stored.label )#,
						#db.param( 1 )#,
						#db.param( application.zcore.session.getSessionId() )# ), ';
				}
			}

			if ( insertSQL NEQ '' ) {
				db.sql = 'INSERT INTO #db.table( 'statistic', request.zos.zcoreDatasource )#
					( site_id, statistic_datetime, statistic_type_id, statistic_event, statistic_label, statistic_count, statistic_session_id )
					VALUES ';
				db.sql &= insertSQL;

				// remove last 2 chars ", "
				db.sql = left( db.sql, ( len( db.sql ) - 2 ) );
				qStatisticInsert = db.execute( 'qStatisticInsert' );
			}
		}

		variables.storedArray = [];
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
