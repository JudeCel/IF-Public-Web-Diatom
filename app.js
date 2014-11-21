"use strict";
var config = require('simpler-config').load(require('./config/master.json'));
var async = require('async');
var log4js = require('log4js');

var joi = require('joi');
joi.settings.skipConversions = true;

setup();

function setup() {
	async.series([
		function (cb) {
			require('if-data').setup(config.mysql, cb);
		}
	], function (err) {
		if (err) throw err;
		require('./server')();
	});
}
