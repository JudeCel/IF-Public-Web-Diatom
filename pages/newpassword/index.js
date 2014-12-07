var config = require('simpler-config');
var _ = require('lodash');
var util = require('util');
var joi = require('joi');
var async = require('async');
var ifCommon = require('if-common');
var validator = ifCommon.utils.validationMethods;
var fn = ifCommon.utils.functionHelper;
var webFaultHelper = require('../../helpers/webFaultHelper.js');
var dotNetEncryptionHelper = ifCommon.utils.dotNetEncryptionHelper;
var ifData = require('if-data'), db = ifData.db;
var emailExists = ifData.repositories.emailExists;
var ifAuth = require('if-auth');
var urlHelper = require('../../helpers/urlHelper.js');
var createSess = require('../../repositories/session/createSess.js');

module.exports = function (req, res, mainCb) {

	var data = _.extend({
		password: '',
		passwordConfirm: '',
		token: req.params[0]
	}, req.body, req.query);
	
	var resData = {
		errors: {},
		errorViewModel: null,
		layoutData: res.locals.layoutData
	};

	var sessionId, userId, accountId;

	ifAuth.checkResetPasswordToken(data,function(result){
		if(result == null || !result.tokenValid || result.passwordExpired) 			
			return res.render("newpassword_token_failed");

		// initial load
		if (!_.size(req.body))
			return sendPage();

		data.email = result.email;

		async.series({
			validate: validate,
			updatePassword: updatePassword,
			createSession: createSession
		}, function (err, results) {

			if (util.isError(err))
				return mainCb(err);

			if (err)
				return sendPage(err);

			res.cookie('sess0', dotNetEncryptionHelper.encryptNumberForUrl(sessionId), null);

			redirectToApp();
		});
	});

	function sendPage(err) {
		if (err)
			resData.errors = err;

		setupPageData(function (pageDataErr) {
			if (pageDataErr)
				resData.errors = _.extend(resData.errors, pageDataErr);
			res.locals(data);
			res.locals(resData);
			res.render('newpassword');
		});
	}

	function setupPageData(cb) {
		cb();
	}

	function redirectToApp() {
		var params = {
			req: req,
			sessionId: sessionId
		};
		return res.redirect(urlHelper.getAdminDashboardRedirectUrl(params));
	}

	function validate(cb) {

		var schema = {
			password: joi.types.String().min(6).max(35).required(),
			passwordConfirm: joi.types.String().required(),
			token: joi.types.String().required()
		};

		var err = joi.validate(_.pick(data, _.keys(schema)), schema);
		err = err ? webFaultHelper.joiValidationFault(err) : {};

		if (data.password.length < 6)
			err.password = 'Passwords minimum of 6 characters';
		if (data.password.length > 35)
			err.password = 'Passwords must be 35 characters or less';

		if (data.password !== data.passwordConfirm)
			err.password = 'Passwords do not match';

		if (_.size(err))
			return cb(err);

		async.parallel({
			emailExists: fn.wrapWithCb(emailExists, {
				email: data.email
			})
		}, function (err, results) {
			if (err) return cb(err);
			if (_.size(resData.errorViewModel))
				return cb('general error found')

			if (!results.emailExists) {
				return cb({email: 'Email not exists'});
			}
			cb();
		})

	}

	function updatePassword(cb) {
		ifAuth.resetPassword(data, function (err, result) {	
			console.log("result");			
			console.log(result);

			userId = result.userId;
			accountId = result.accountId;
			if (err) return cb(err);
			cb();
		});
	}

	function createSession(cb) {
		createSess({
			userId: userId,
			accountId: accountId
		}, function (err, sessId) {
			if (err) return cb(err);
			sessionId = sessId;
			cb();
		});
	}
};