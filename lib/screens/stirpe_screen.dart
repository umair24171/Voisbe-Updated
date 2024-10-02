import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // static const String backendUrl = 'http://192.168.18.236:3000';
  static const String backendUrl = 'https://api-yqekgrov4a-uc.a.run.app';
  String? paymentIntentClientSecret;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = 'pk_live_VQmRjrzGsFLF6U2yE0bXdThg';
    fetchPaymentIntent();
  }

  Future<void> fetchPaymentIntent() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$backendUrl/create-payment-intent');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'price': 20}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          paymentIntentClientSecret = json['clientSecret'];
          isLoading = false;
        });
      } else {
        print('Server responded with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch payment intent');
      }
    } catch (e) {
      print('Error fetching payment intent: $e');
      setState(() {
        isLoading = false;
      });
      showAlert('Error loading page', 'Failed to fetch payment intent: $e');
    }
  }

  Future<void> pay() async {
    if (paymentIntentClientSecret == null) return;

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret!,
          merchantDisplayName: 'Example, Inc.',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      showAlert('Payment complete!');
    } catch (e) {
      if (e is StripeException) {
        showAlert('Payment failed', e.error.localizedMessage);
      } else {
        showAlert('Payment failed', 'An unexpected error occurred.');
      }
    }
  }

  void showAlert(String title, [String? message]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                child: const Text('Pay now'),
                onPressed: paymentIntentClientSecret != null ? pay : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
      ),
    );
  }
}
