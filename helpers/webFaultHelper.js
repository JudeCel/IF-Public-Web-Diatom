"use strict";
var util = require('util');
var _ = require('lodash');

function WebFaultHelper() {
	function joiValidationFault(error) {
		if (!error || !error._errors || error._errors.length === 0) return;
		error._errors = _.map(error._errors, function (err) {
			err.path = err.path.replace('.', '');
			err.message = error._object[err.path] === '' ? 'Required' : 'Invalid';
			return err;
		});

		return _.zipObject(_.pluck(error._errors, 'path'), _.pluck(error._errors, 'message'));
	}

	function getFault(error) {
		error = error || {};
		var statusCode = error.statusCode || 500;
		var message = getErrorMessage(error);
		var logLevel = error.logLevel || 'ERROR';

		if (util.isError(error)) {
			error.statusCode = statusCode;
			error.message = message;
			return error;
		}

		var newError = new Error();
		newError.statusCode = statusCode;
		newError.message = message;
		newError.logLevel = logLevel;
		return newError;
	}

	function getErrorMessage(error) {
		var defaultErrorMessage = 'An error has occurred';
		if (!error)
			return defaultErrorMessage;

		if (_.isString(error))
			return error;

		if (_.isArray(error))
			return error.join(', ');

		if (error.message)
			return error.message;

		if (error.body && error.body.Message)
			return error.body.Message;

		return defaultErrorMessage;
	}

	function getNotFoundError(message) {
		return {
			statusCode: 404,
			message: message || 'Not Found',
			logLevel: 'WARN'
		};
	}

	function getBadInputError(message) {
		return {
			statusCode: 400,
			message: message || 'Bad input received',
			logLevel: 'WARN'
		};
	}

	return {
		joiValidationFault: joiValidationFault,
		getFault: getFault,
		getNotFoundError: getNotFoundError,
		getBadInputError: getBadInputError
	};
};
module.exports = new WebFaultHelper();
