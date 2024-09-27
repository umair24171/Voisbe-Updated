const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const stripe = require('stripe')('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');

const app = express();

app.use(cors({ origin: true }));
app.use(express.json());

app.post("/create-payment-intent", async (req, res) => {
  try {
    const { price } = req.body;
    
    // Convert price to cents
    const amount = Math.round(price * 100);
    
    // Create a PaymentIntent with the order amount and currency
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: "usd",
      automatic_payment_methods: {
        enabled: true,
      },
    });
    
    res.send({
      clientSecret: paymentIntent.client_secret,
      dpmCheckerLink: `https://dashboard.stripe.com/settings/payment_methods/review?transaction_id=${paymentIntent.id}`,
    });
  } catch (error) {
    console.error("Error creating payment intent:", error);
    res.status(500).send({ error: "Failed to create payment intent" });
  }
});

exports.stripeServer = functions.https.onRequest(app);

// const express = require("express");
// const cors = require("cors");
// const stripe = require("stripe")("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");

// const app = express();
// const PORT = 3000;

// app.use(cors());
// app.use(express.json());

// app.post("/create-payment-intent", async (req, res) => {
//   try {
//     const { price } = req.body;
    
//     // Convert price to cents
//     const amount = Math.round(price * 100);
    
//     // Create a PaymentIntent with the order amount and currency
//     const paymentIntent = await stripe.paymentIntents.create({
//       amount: amount,
//       currency: "usd",
//       automatic_payment_methods: {
//         enabled: true,
//       },
//     });
    
//     res.send({
//       clientSecret: paymentIntent.client_secret,
//       dpmCheckerLink: `https://dashboard.stripe.com/settings/payment_methods/review?transaction_id=${paymentIntent.id}`,
//     });
//   } catch (error) {
//     console.error("Error creating payment intent:", error);
//     res.status(500).send({ error: "Failed to create payment intent" });
//   }
// });

// app.listen(PORT, "0.0.0.0", () => {
//   console.log(`Server connected at port ${PORT}`);
// });