"use strict";
var ifData = require('if-data'), db = ifData.db;
var mtypes = require('if-common').mtypes;

function AccountIsActive(params, cb) {
	var accountId = params.accountId;
	var statuses = mtypes.accountStatus;

	var sql = "SELECT \
		a.status, \
		a.deleted, \
		a.ownerEmail \
	FROM account a \
	WHERE a.id = ?";

	db.queryOne(sql, [accountId], function (err, result) {
		if(err) return cb(err);
		if(!result) {
			return cb(null, {
				ownerEmail: '',
				active: false
			});
		}

		var inactiveAccountStatuses = [
			statuses.cancelled,
			statuses.nonPayment,
			statuses.trialExpired
		];

		var active = true;
		if (~inactiveAccountStatuses.indexOf(result.status) || result.deleted)
			active = false;

		cb(null, {
			ownerEmail: result.ownerEmail,
			active: active
		});
	});
}

module.exports = AccountIsActive;