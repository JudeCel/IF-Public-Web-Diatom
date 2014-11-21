"use strict";
var log4js = require('log4js');
var util = require('util');
var errLogger = log4js.getLogger('error');
var ifcommon = require('if-common');
var queueWriter = ifcommon.utils.queueWriter;
var os = require('os');
var _ = require('lodash');
var loggingHelper = ifcommon.utils.loggingHelper;

module.exports = function (err, req, res, next) {
	errLogger.error(req.headers, req.url, loggingHelper.scrubParams(req.params), loggingHelper.scrubParams(req.body),
		req.query, req.method, err);

	err = _.defaults(err || {}, {
		statusCode: 500,
		message: 'Internal Server Error',
		logLevel: 'ERROR'
	});

	if (!_.isString(err.message))
		err.message = JSON.stringify(err.message);

	// don't log access-denied errors
	if (err.statusCode === 401) {
		res.send(err.statusCode, err.message);
		return;
	}

	var logMessage = loggingHelper.messageFromExpressJSReq({
		req: req,
		overrides: {
			priority: err.logLevel,
			exception: util.inspect(err.stack || err, {depth: 5}),
			message: err.message
		}
	});

	res.send(err.statusCode, err.message);
};

module.exports.logError = function (params) {
	var err = params.err;
	var req = params.req;

	errLogger.error(req.headers, req.url, loggingHelper.scrubParams(req.params), loggingHelper.scrubParams(req.body),
		req.query, req.method, err);

	var logMessage = loggingHelper.messageFromExpressJSReq({
		req: req,
		overrides: {
			priority: err.logLevel,
			exception: util.inspect(err.stack || err, {depth: 5}),
			message: err.message
		}
	});
	queueWriter.writeMessage(logMessage);
};
