import 'package:ecomm/providers/cart_provider.dart';
import 'package:ecomm/services/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      final product = item.product;

                      return ListTile(
                        leading: Image.network(product['image_url'], width: 50),
                        title: Text(product['name']),
                        subtitle: Text("₦${product['price']} x ${item.quantity}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => cart.removeFromCart(product['id']),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Total: ₦${cart.totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton(
onPressed: () async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
 

  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  final success = await StripeService.instance.makePayment(
    amount: cartProvider.totalPrice,
    currency: "usd",
    items: cartProvider.items.values.toList(),
    userId: userId ?? null, 
    onOrderSaved: () {
      cartProvider.clearCart();
      Navigator.pushReplacementNamed(context, '/orders');
    },
    context: context,
  );
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment successful! Order placed.")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment failed. Please try again.")),
    );
  }
},

                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text("Checkout", style: TextStyle(fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
