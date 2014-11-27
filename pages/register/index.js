var config = require('simpler-config');
var _ = require('lodash');
var util = require('util');
var joi = require('joi');
var async = require('async');
var request = require('request');

var ifCommon = require('if-common');
var mtypes = ifCommon.mtypes;
var validator = ifCommon.utils.validationMethods;
var fn = ifCommon.utils.functionHelper;
var dotNetEncryptionHelper = ifCommon.utils.dotNetEncryptionHelper;
var webFaultHelper = require('../../helpers/webFaultHelper.js');
var createSess = require('../../repositories/session/createSess.js');
var createAccount = require('../../repositories/account/createAccount.js');
var ifData = require('if-data'), db = ifData.db;
var emailExists = ifData.repositories.emailExists;
var addUsers = ifData.repositories.addUsers;
var urlHelper = require('../../helpers/urlHelper.js');

var userFields = ['email', 'name_first', 'name_last', 'password'];

module.exports = function (req, res, mainCb) {
	var accountId;

	var data = _.extend({
		name_first: '',
		name_last: '',
		email: '',
		password: '',
		ds: '',
		passwordConfirm: ''
	}, req.body, req.query);

	var resData = {
		errors: {},
		errorViewModel: null,
		layoutData: res.locals.layoutData
	};

	var newUser, sessionId;

	// initial load
	if (!_.size(req.body))
		return sendPage();

	async.series({
		validate: validate,
		createAccount: createNewAccount,
		addUser: addUser,
		createSession: createSession
	}, function (err, results) {
		if (util.isError(err))
			return mainCb(err);

		if (err)
			return sendPage(err);

		res.cookie('sess0', dotNetEncryptionHelper.encryptNumberForUrl(sessionId), null);

		redirectToApp();
	});

	function sendPage(err) {
		if (err)
			resData.errors = err;

		setupPageData(function (pageDataErr) {
			if (pageDataErr)
				resData.errors = _.extend(resData.errors, pageDataErr);
			res.locals(data);
			res.locals(resData);
			res.render('register');
		});
	}

	function setupPageData(cb) {
		cb();
	}

//	function setupPageData(cb) {
//		async.parallel({
//			checkCourseAndAccount: checkCourseAndAccount
//		}, function (err, result) {
//			if (err) return mainCb(err);
//			if (_.size(data.errorViewModel))
//				return cb('general error found')
//
//			cb();
//		});
//	}

	function redirectToApp() {
		var params = {
			req: req,
			sessionId: sessionId
		};
		return res.redirect(urlHelper.getAdminDashboardRedirectUrl(params));
	}

	function validate(cb) {
		if (newUser) return cb();

		var schema = {
			name_first: joi.types.String().required(),
			name_last: joi.types.String().required(),
			email: joi.types.String().nullOk().emptyOk().email().max(254).optional(),
			password: joi.types.String().min(6).max(35).required(),
			passwordConfirm: joi.types.String().required()
		};

		var err = joi.validate(_.pick(data, _.keys(schema)), schema);
		err = err ? webFaultHelper.joiValidationFault(err) : {};

		if (!validator.any(data, "email")) {
			var msg = 'Email required';
			err.email = msg;
		}

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

			if (results.emailExists) {
				return cb({email: 'Email already exists'});
			}

			cb();
		})
	}

	function addUser(cb) {
		if (newUser) return cb();

		var userToAdd = _.pick(data, userFields);
		userToAdd.accountId = accountId;
		userToAdd.status = mtypes.userStatus.active;
		//userToAdd.permissions = mtypes.userType.accountManager;

		addUsers({
			users: [userToAdd]
		}, function (err, newUsers) {
			if (err) return cb(err);
			newUser = newUsers.shift();
			cb();
		});
	}

	function createNewAccount(cb) {
		createAccount({
			OwnerEmail: data.email
		}, function (err, accId) {
			if (err) return cb(err);
			accountId = accId;
			cb();
		});
	}

	function createSession(cb) {
		if (!newUser) return cb();

		createSess({
			userId: newUser.id,
			accountId: accountId
		}, function (err, sessId) {
			if (err) return cb(err);
			sessionId = sessId;
			cb();
		});
	}
};