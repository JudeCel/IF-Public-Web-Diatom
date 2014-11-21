"use strict";
var ifData = require('if-data'), db = ifData.db;
var webFaultHelper = require('./webFaultHelper');
//var logout = require('./logout');
var ifCommon = require('if-common');
var dotNetEncryptionHelper = ifCommon.utils.dotNetEncryptionHelper;

function SessionLoader(req, res, mainCb) {
	if (!req || !req.headers || !req.cookies)
		return mainCb();

//	if (!res.locals.accountId)
//		return mainCb('res.locals.accountId is required, try subDomainParser.');

	var sessCookieValue = req.cookies.sess || req.cookies.sess0;

	if (!req || !sessCookieValue)
		return mainCb();

	var sessId = 0;

	if(dotNetEncryptionHelper.isNewEncryption(sessCookieValue)) {
		sessId = dotNetEncryptionHelper.decryptNumberFromUrl(sessCookieValue);
	} else {
		try {
			var decryptedSessId = dotNetEncryptionHelper.decryptFromUrlOld(sessCookieValue);
			if(decryptedSessId)
				sessId = parseInt(decryptedSessId, 10);
		}
		catch (e) {
			sessId = 0;
		}
	}

	if(!sessId) {
		//return logout(res);
	}

	var sql = "SELECT \
		s.id sessId, \
		s.type, \
		u.id userId, \
		u.accountId \
	FROM sess s \
	JOIN users u ON s.userId = u.id \
	WHERE s.id = ? \
	AND s.deleted IS NULL";
	//AND s.status = 123000100 /*Valid*/";
	//u.permissions userPermissions \

	db.queryOne(sql, [sessId, res.locals.accountId], function (err, result) {
		if (err || !result) {
			res.locals.session = null;
			if(err)
				err = webFaultHelper.getFault(err);
			return mainCb(err);
		}

		res.locals.session = result;
		mainCb();
	});

}
module.exports = SessionLoader;
