"use strict";
var async = require('async');
var util = require('util');
var joi = require('joi');
var config = require('simpler-config');
var _ = require('lodash');
var request = require('request');
var ifAuth = require('if-auth');
var ifCommon = require('if-common');
var ifData = require('if-data');
var mtypes = ifCommon.mtypes;
var dotNetEncryptionHelper = ifCommon.utils.dotNetEncryptionHelper;
var urlHelper = require('../../helpers/urlHelper.js');
var webFaultHelper = require('../../helpers/webFaultHelper.js');
//var accountIsActive = require('../../repositories/account/accountIsActive.js');
//var userIsActive = require('../../repositories/user/userIsActive.js');
var createSess = require('../../repositories/session/createSess.js');

var logout = require('../../helpers/logout.js');

var Q = require('q');

module.exports = function (req, res, mainCb) {
	if (!cookiesEnabled())
		return res.render('cookiesRequired', { refreshUrl: '/CreateCookie.aspx?sessionID=' + req.query.sessionID });

	var userId = urlHelper.getUserIdFromUrl(req);
	var accountId = res.locals.accountId;

	var sessionId;
	var data = _.extend({
		email: '',
		password: '',
		errorMessage: '',
		layoutData: res.locals.layoutData,
		accountId: accountId,
		errorViewModel: null,
		ds: ''
	}, req.body, req.query, req.params);

	var matchedUser;
	var context;

	completeRedirect();

	function completeRedirect() {
		if (res.locals.session && res.locals.session.userId) {
			// userId in session doesn't match userId in url
			if (userId && userId != res.locals.session.userId)
				return logout(res, true);

			userId = res.locals.session.userId;
			sessionId = res.locals.session.sessId;
			//return redirectForExistingSession();          // TODO [Takhir]
		}

		// initial load
		if (!_.size(req.body)) {
			return sendPage();
		}

		async.series({
			validate: validate,
			login: attemptLogin,
			sess: createSession
		}, function (err, results) {
			if (util.isError(err))
				return mainCb(err);

			if (matchedUser)
				if (matchedUser.passwordExpired)
					return redirectToResetPassword(matchedUser);

			if (err) {
				if (results.login) {
					if (_.isArray(results.login))
						results.login = results.login[0];
					handleLoginErrorCode(err, results.login);
				}
				else
					data.errorMessage = err;

				return sendPage();
			}

			res.locals.session = {
				userPermissions: matchedUser.permissions
			};

			sessionId = results.sess;
			res.locals.session.sessId = sessionId;
			var sessEnc = dotNetEncryptionHelper.encryptNumberForUrl(sessionId);
			res.cookie('sess0', sessEnc, { maxAge: config.session.persistMaxAgeMs });

			return redirectToApp();
		});
	}

	function cookiesEnabled() {
		if (req.method != 'GET') return true; // Only GET
		if (!req.query.sessionID) return true; // Only from CreateCookie.aspx
		if (!req.cookies || !req.cookies.ValidationCookie) return false;

		return true;
	}

	function validate(cb) {
		var emailSchema = joi.types.String().email().required();

		var schema = {
			email: emailSchema,
			password: joi.types.String().required()
		};

		var err = joi.validate(_.pick(data, _.keys(schema)), schema);
		if (err)
			return cb(webFaultHelper.joiValidationFault(err));

		cb();
	}

	function handleLoginErrorCode(code, extraInfo) {
		if (!extraInfo) {
			data.errorMessage = code;
			return;
		}

		if (code === 'login_failed') {
			data.errorMessage = 'Login failed.';
			return;
		}

		data.errorViewModel = {
			email: extraInfo.ownerEmail || extraInfo,
			type: {
				user_inactive: 'userInactive',
				account_inactive: 'accountInactive'
			}[code]
		};
	}

	function attemptLogin(cb) {
		ifAuth.login(data, function (err, users) {
			if (err) return cb(err, users);
			matchedUser = users[0];
			userId = matchedUser.userId;
			cb();
		});
	}

	function sendPage() {
		res.render('login', data);
	}

	function createSession(cb) {
		if (!matchedUser) return cb();
		if (matchedUser.passwordExpired) return cb();
		createSess(_.extend(_.pick(matchedUser, 'accountId', 'userId'), {}), cb);
	}

	function redirectForExistingSession() {
		redirectToApp();
	}

	function validateUserContext() {
		if (!context.userActive.active) {
			data.errorViewModel = {
				type: 'userInactive',
				email: context.userActive.ownerEmail
			};
		}
		data.username = context.userActive.username;
	}

	function redirectToApp() {
		var params = {
			req: req,
			sessionId: sessionId,
			permissions: res.locals.session.userPermissions,
			userId: userId,
			host: req.host
		};

		var perms = res.locals.session.userPermissions;

		var queryStringRedirectInvalid = !req.body.redirectUrl || req.body.userId != userId;
		var url;

		if (queryStringRedirectInvalid) {
			if (perms == mtypes.userRole.accountManager)
				url = urlHelper.getAdminDashboardRedirectUrl(params);
			else
				url = urlHelper.getAdminDashboardRedirectUrl(params);       // TODO
		} else {
			//var protocol = perms == mtypes.userPermissions.trainee ? 'http://' : 'https://';
			var protocol = 'http://';
			url = protocol + params.host + req.body.redirectUrl;
		}

		if (req.host != params.host) {
			var redirectUrl = url;
			var sessId = dotNetEncryptionHelper.encryptNumberForUrl(res.locals.session.sessId);

			url = urlHelper.getSessSetUrl({
				req: req,
				host: params.host,
				redirectUrl: redirectUrl,
				sess: sessId
			});
		}

		res.send('<html><body><script>window.location = "' + url + '"</script></body></html>');
	}

	function redirectToResetPassword(user) {
		var url = urlHelper.getPasswordResetUrl({
			userId: user.userId,
			req: req
		});
		res.send('<html><body><script>window.location = "' + url + '&expired=1' + '"</script></body></html>');
	}
};