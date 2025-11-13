const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();


//  --------------- Import notification functions ---------------
const { sendNotifications } = require('./notifications/order_notifications');
const { onPrescriptionVerified } = require('./notifications/prescription_notifications');

//  --------------- Import email functions ---------------
const { sendOTPEmail } = require('./email/send_otp_email');

exports.sendNotification = sendNotifications;
exports.onPrescriptionVerified = onPrescriptionVerified;
exports.sendOTPEmail = sendOTPEmail;