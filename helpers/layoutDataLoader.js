"use strict";
var _ = require('lodash');
var util = require('util');
var accountInfoLoader = require('./accountInfoLoader.js');
var webFaultHelper = require('./webFaultHelper.js');
var config = require('simpler-config');

module.exports = function load(req, res, mainCb) {
	if (!res || !res.locals || !res.locals.accountId)
		return mainCb();

	accountInfoLoader({
		accountId: res.locals.accountId,
		req: req
	}, function (err, data) {
		if (util.isError(err))
			return mainCb(webFaultHelper.getFault(err));
		if (err)
			return mainCb(new Error(err));

		res.locals.hasFeature = data.hasFeature;
		res.locals.layoutData = _.omit(data, 'features');
		res.locals.config = config;
		res.locals.ogSettings = {
			enabled: false,
			url: req.protocol + '://' + req.host + req.originalUrl,
			title: '',
			imageUrl: '',
			description: ''
		};
		res.locals.pageTitle = 'Home';
		mainCb();
	})
};
