var config = require('simpler-config');
var _ = require('lodash');
var util = require('util');
var joi = require('joi');
var async = require('async');
var ifData = require('if-data'), db = ifData.db;
var ifCommon = require('if-common');
var validator = ifCommon.utils.validationMethods;
var fn = ifCommon.utils.functionHelper;
var emailExists = ifData.repositories.emailExists;
var webFaultHelper = require('../../helpers/webFaultHelper.js');
var sendMail = require('../../helpers/mailer.js');
var ifAuth = require('if-auth');
var getUser = require('if-data').repositories.getUser;
var updateUser = require('if-data').repositories.updateUser;

module.exports = function (req, res, mainCb) {
	var data = _.extend({
		email: ''
	}, req.body, req.query);

	var resData = {
		errors: {},
		errorViewModel: null,
		layoutData: res.locals.layoutData
	};

	if (!_.size(req.body))
		return sendPage();

	async.series({
		validate: validate,
		sendEmail: sendEmail
	}, function (err, results) {
		if (util.isError(err))
			return mainCb(err);

		if (err)
			return sendPage(err);

		sendPage(null, "An e-mail has been sent to confirm your request for a new password");
	});

	function sendPage(err, success) {
		resData.success = null;

		if (err)
			resData.errors = err;

		setupPageData(function (pageDataErr) {
			if (pageDataErr)
				resData.errors = _.extend(resData.errors, pageDataErr);

			if(success) 
				resData.success = success;
				res.locals(data);
		 	  res.locals(resData);
			res.render('forgotpassword');
		});
	}

	function setupPageData(cb) {
		cb();
	}

	function validate(cb) {
		var schema = {
			email: joi.types.String().email().required()
		};

		var err = joi.validate(_.pick(data, _.keys(schema)), schema);
		err = err ? webFaultHelper.joiValidationFault(err) : {};

		if (!validator.any(data, "email")) {
			var msg = 'Please enter a valid e-mail address.';
			err.email = msg;
		}

		if (_.size(err))
			return cb(err);

		async.parallel({
			emailExists: fn.wrapWithCb(emailExists, {
				email: data.email
			})
		}, function (err, results) {
			if (err) return cb(err);
			if (_.size(resData.errorViewModel))
				return cb('There was a problem sending your e-mail. Please contact the administartor')

			if (!results.emailExists) {
				return cb({email: 'No user found that matches that username/email address.'});
			}
			cb();
		});
	}

	function sendEmail(cb) {

		ifAuth.createForgotPasswordRequest(data, function(err, token){

			if (err)
				return cb(err);

				var params = {
		    	from: config.mail.from,
		    	to: data.email,
		    	subject: 'Insiderfocus | A Password Change Has Been Requested'
				};

				var url = "http://"+config.domain+":"+config.port+"/newpassword/"+token;

				var message = "A request was made to change your password for.  Click link to reset:  "+ url;
			  sendMail(message, params, cb);
		});
	};
};
