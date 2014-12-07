"use strict";
var _ = require('lodash');
var express = require('express');
var config = require('simpler-config');
var log4js = require('log4js');
var http = require('http');
var path = require('path');
var errorHandler = require('./helpers/errorHandler');
//var layoutDataLoader = require('./helpers/layoutDataLoader');

var stdLogger = log4js.getLogger('info');
stdLogger.setLevel('INFO');

var server;
module.exports = function () {
	function mapRoutes(verb, routes) {
		if (_.isArray(routes))
			routes = [routes];

		var handlers = _.rest(arguments, 2);

		_.each(routes, function (route) {
			var applyArgs = [route].concat(handlers);
			app[verb].apply(app, applyArgs);
		});
	}

	var app = express();

    function routes() {
	    mapRoutes('all', ['/register'], require('./pages/register'));
	    mapRoutes('all', ['/login'], require('./pages/login'));
	    mapRoutes('all', ['/forgotpassword'], require('./pages/forgotpassword'));
	    mapRoutes('all', ['/newpassword/:hash'], require('./pages/newpassword'));
    }

	app.set('port', process.env.PORT || config.port);
	app.set('view engine', 'ejs');
	app.set('views', __dirname + '/web');
	app.use('/public', express.static(path.join(__dirname, '/web/public')));

	app.use(express.compress());
	app.use(log4js.connectLogger(stdLogger, {level: log4js.levels.INFO, format: 'express>>:remote-addr|:response-time|:method|:url|:http-version|:status|:referrer|:user-agent'}));
	app.use(express.bodyParser());
	app.use(express.cookieParser());

	app.use(require('./helpers/sessionLoader'));
	app.use(app.router);
	app.use(errorHandler);

	routes();

	server = http.createServer(app).listen(app.get('port'), function () {
		console.log('Listening for HTTP requests on port ' + app.get('port'));
	});
};

module.exports.close = function () {
	server.close();
};
