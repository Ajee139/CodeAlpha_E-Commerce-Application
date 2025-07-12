const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_key);

admin.initializeApp();

exports.createPaymentIntent2 = functions
  .region('us-central1')
  
  .https.onCall(async (data, context) => {
    const {amount, currency} = data;

    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount,
        currency,
      });

      return {
        clientSecret: paymentIntent.client_secret,
      };
    } catch (error) {
      return {error: error.message};
    }
  });
