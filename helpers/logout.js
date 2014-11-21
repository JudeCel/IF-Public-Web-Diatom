"use strict";
var urlHelper = require('./urlHelper');
var ifdata = require('if-data'), db = ifdata.db;

function Logout(res, keepQueryString) {
	res.clearCookie('sess');
	res.clearCookie('sess0');

	if(!res.locals || !res.locals.session || !res.locals.session.sessId)
		return redirect(keepQueryString);

	invalidateSession(res.locals.session.sessId, function() {
		return redirect(keepQueryString);
	});

	function invalidateSession(sessId, cb) {
		if(!sessId) return cb();

		var sql = "UPDATE sess \
			SET status = 123000200 /*Invalid Session*/ \
			WHERE id = ?";
		db.query(sql, [sessId], cb);
	}

	function redirect(keepQueryString) {
		if (keepQueryString){
			res.redirect(urlHelper.getCurrentUrl(res.req));
		} else {
			res.redirect(urlHelper.getCurrentHostUrl(res.req));
		}
	}
}
module.exports = Logout;
