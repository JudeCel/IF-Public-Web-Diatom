"use strict";

var nodemailer = require('nodemailer');

function sendMail(message, params, callback) {

		//In this case all e-mails are sent directly to the recipients MX server (using port 25)

		var transporter = nodemailer.createTransport();

		transporter.sendMail({
		    from:  params.from,
		    to:  params.to,
		    subject: params.subject,
		    text: message
		}, callback);
	
}
module.exports = sendMail;
