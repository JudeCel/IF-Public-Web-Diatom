"use strict";
var ifData = require('if-data'), db = ifData.db;
var mtypes = require('if-common').mtypes;

function UserIsActive(params, cb) {
	var accountId = params.accountId;
	var userId = params.userId;

	var sql = "SELECT \
		u.email, \
		u.status, \
		u.deleted, \
		u.permissions, \
		u.passwordCrypt, \
		a.ownerEmail \
	FROM account a \
	LEFT JOIN users u ON u.ID = ? \
	WHERE a.id = ? ";

	db.queryOne(sql, [userId, accountId], function (err, result) {
		if(err) return cb(err);
		if(!result || !result.status) { // user not found
			cb(null, {
				ownerEmail: result.ownerEmail,
				active: false
			});
		}

		cb(null, {
			ownerEmail: result.ownerEmail,
			active: result.status == mtypes.userStatus.active && !result.deleted,
			email: result.email,
			permissions: result.permissions,
			hasPassword: result.passwordCrypt != null
		});
	});
}

module.exports = UserIsActive;