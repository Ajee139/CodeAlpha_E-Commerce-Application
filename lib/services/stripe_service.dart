import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomm/providers/cart_provider.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<bool> makePayment({
    required double amount,
    required String currency,
    required List<CartItem> items,
    required String? userId,
    required Function()? onOrderSaved,
    required BuildContext context,
  }) async {
    try {
      String? paymentIntentClientSecret = await createPaymentIntent(amount, currency);
      if (paymentIntentClientSecret == null) {
        print('❌ Failed to create payment intent');
        return false;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'codeAlpha Ecommerce app',
        ),
      );

      bool paymentSuccess = await _processPayment();

      if (!paymentSuccess) {
        print('❌ Payment was cancelled or failed.');
        return false;
      }

      await saveOrder(items, amount, paymentIntentClientSecret, userId);
      if (onOrderSaved != null) onOrderSaved();

      print('✅ Payment and order saving successful.');
      return true;
    } catch (e) {
      print('❌ Error during payment flow: $e');
      return false;
    }
  }

  Future<void> saveOrder(
    List<CartItem> items,
    double total,
    String paymentIntentId,
    String? userId,
  ) async {
    if (userId == null) {
      print('⚠️ User ID is null. Cannot save order.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'user_id': userId,
        'items': items.map((item) => {
          'productId': item.product['id'],
          'name': item.product['name'],
          'quantity': item.quantity,
          'price': item.product['price'],
        }).toList(),
        'total': total,
        'payment_intent_id': paymentIntentId,
        'status': 'Processing',
        'created_at': FieldValue.serverTimestamp(),
      });

      print('✅ Order saved successfully to Firestore.');
    } catch (e) {
      print('❌ Error saving order to Firestore: $e');
    }
  }

  Future<String?> createPaymentIntent(double amount, String currency) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent2');
      final response = await callable.call({
        'amount': (amount * 100).toInt(), // Stripe expects amount in cents
        'currency': currency,
      });

      final data = response.data;
      if (data != null && data['clientSecret'] != null) {
        return data['clientSecret'];
      } else if (data != null && data['error'] != null) {
        print('❌ Stripe error: ${data['error']}');
      }
    } catch (e) {
      print('❌ Error creating payment intent: $e');
    }

    return null;
  }

  Future<bool> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      print('❌ Error presenting payment sheet: $e');
      return false;
    }
  }
}
