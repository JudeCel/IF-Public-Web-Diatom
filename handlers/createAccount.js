"use strict";
var _ = require('lodash');
var mtypes = require('if-common').mtypes;
var ifData = require('if-data'), db = ifData.db;

function CreateAccount(params, cb) {
	var account = _.defaults(params, {
		Status: mtypes.accountStatus.active,
		StatusModified: db.utcNow(),
		BillingIntervalType: mtypes.billingIntervalType.annual
	});
	db.insert("account", account, function (err, res) {
		if (err) return cb(err);
		cb(null, res[0].insertId);
	});
}
module.exports = CreateAccount;
