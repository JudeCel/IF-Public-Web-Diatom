"use strict";
var querystring = require('querystring');
var _ = require('lodash');
var async = require('async');
var config = require('simpler-config');
var ifCommon = require('if-common');
var dotNetEncryptionHelper = ifCommon.utils.dotNetEncryptionHelper;
var mtypes = ifCommon.mtypes;

function UrlHelper() {
	var appUrls = config.appUrls;

//	function lowercaseQueryString(req) {
//		return _.zipObject(_.map(req.query, function (value, key) {
//			return [key.toLowerCase(), value];
//		}));
//	}

	function getAdminDashboardRedirectUrl(params) {
		var req = params.req;
		var host = params.host || req.host;
		var sessionId = params.sessionId;
		if (parseInt(sessionId) == sessionId)
			sessionId = dotNetEncryptionHelper.encryptNumberForUrl(sessionId);

		return 'http://' + host + appUrls.adminDashboard + '&sessId=' + sessionId;
		//return 'https://' + host + appUrls.adminDashboard;        TBD change to https
	}

	function getUserIdFromUrl(req) {
		req.query = req.query || {};

		var userId;
		if(req.query.utoken2) {
			userId = dotNetEncryptionHelper.decryptFromUrlOld(req.query.utoken2);
			if(!userId) return null;
			userId = parseInt(userId, 10);
		}

		if(req.query.u)
			userId = dotNetEncryptionHelper.decryptNumberFromUrl(req.query.u);

		return userId;
	}

	function getPasswordResetUrl(params){
		var userId = params.userId;
		var req = params.req;
		return getCurrentHostUrl(req) + '/resetPassword?' +
			'userId=' + dotNetEncryptionHelper.encryptNumberForUrl(userId) + '&' +
			'url=' + encodeURIComponent(getCurrentUrl(req));
	}

	function getDefaultUrl(params) {
		var userId = params.userId;
		var req = params.req;

		var url = getCurrentHostUrl(req) + '/';
		var queryParams = [];
		if (userId)
			queryParams = queryParams.concat({key: 'u', value: dotNetEncryptionHelper.encryptNumberForUrl(userId)});

		for (var i = 0; i<queryParams.length; i++) {
			url = url + (i == 0 ? '?' : '&') + queryParams[i].key + '=' + queryParams[i].value;
		}
		return url;
	}

	function getCurrentHostUrl(req) {
		return req.protocol + '://' + req.host;
	}

	function getCurrentUrl(req){
		return req.protocol + "://" + req.host + req.url;
	}

	function getSessSetUrl(params) {
		var host = params.host;
		var req = params.req;

		return req.protocol + "://" + host + "/sess?" + querystring.stringify({
			redirectUrl: params.redirectUrl,
			sess: params.sess
		});
	}

	return {
		getUserIdFromUrl: getUserIdFromUrl,
		getCurrentHostUrl: getCurrentHostUrl,
		getCurrentUrl: getCurrentUrl,
		getAdminDashboardRedirectUrl: getAdminDashboardRedirectUrl,
		getPasswordResetUrl: getPasswordResetUrl,
		getDefaultUrl: getDefaultUrl,
		getSessSetUrl: getSessSetUrl
	};
}
module.exports = UrlHelper();