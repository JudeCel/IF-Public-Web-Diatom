"use strict";
var _ = require('lodash');
var mtypes = require('if-common').mtypes;
var ifData = require('if-data'), db = ifData.db;

function CreateSess(params, cb) {
	if(!params.userId)
		return cb(new Error('required parameters not passed to CreateSess'));

	var sess = _.defaults(params, {
		lastActivity: db.utcNow(),
		iPAddress: null,
		status: mtypes.sessStatus.valid,
		expires: null
	});
	db.insert("sess", sess, function (err, res) {
		if (err) return cb(err);
		cb(null, res[0].insertId);
	});
}
module.exports = CreateSess;
