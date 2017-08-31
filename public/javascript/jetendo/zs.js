/*

Types (see jetendo/statistic_type table):
	1 = Listing
	2 = Profile
	3 = Ad
	4 = Link
	5 = Phone Link

Usage:
	application.zcore.skin.includeJS( '/z/javascript/jetendo/zs.js' );

	_zs.track( {
		'type': 1,
		'event': 'view',
		'label': 'My Listing'
	} );

*/

var _zs = {
	'track': function( options ) {
		if ( ! ( 'type' in options ) ) {
			console.error( '_zs type missing' );
			return;
		}
		if ( ! ( 'event' in options ) ) {
			console.error( '_zs event missing' );
			return;
		}
		if ( ! ( 'label' in options ) ) {
			console.error( '_zs label missing' );
			return;
		}

		var ajaxObj = {
			id: '_zs',
			method: 'post',
			postObj: options,
			url: '/z/_com/app/zs?method=trackAjax',
			cache: false,
			callback: function() {},
			errorCallback: function() {}
		};
		zAjax( ajaxObj );
	}
};
