import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/genshin_theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _showFeedbackSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? GenshinTheme.accentRed : GenshinTheme.primaryGold,
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : GenshinTheme.bgDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSuccessReceiptDialog(double subtotal, double tax, double grandTotal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              '📜 ADVENTURER\'S RECEIPT',
              style: GoogleFonts.cinzel(
                color: GenshinTheme.primaryGold,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.verified, size: 64, color: Colors.greenAccent),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'TRANSACTION SUCCESSFUL!',
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: GenshinTheme.primaryGold, thickness: 1),
              _buildReceiptRow('Subtotal Mora', subtotal.toStringAsFixed(0)),
              _buildReceiptRow('Teyvat VAT (10%)', tax.toStringAsFixed(0)),
              const Divider(color: Color(0xFF334155)),
              _buildReceiptRow(
                'Grand Total Cost', 
                '${grandTotal.toStringAsFixed(0)} Mora', 
                isBold: true,
                color: GenshinTheme.primaryGold
              ),
              const Divider(color: GenshinTheme.primaryGold, thickness: 1),
              const SizedBox(height: 16),
              Text(
                'Thank you for buying from Genshin Import store! May the Archons bless your upcoming travels.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: GenshinTheme.textMuted),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('SAFE TRAVELS!'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? color}) {
    final style = GoogleFonts.inter(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: color ?? GenshinTheme.textParchment,
      fontSize: isBold ? 14 : 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  Future<void> _handleCheckout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    final token = authProvider.token;
    if (token == null) {
      _showFeedbackSnackBar('Authentication Failure: Please login again to checkout.', isError: true);
      return;
    }

    
    final subtotal = cartProvider.totalAmount;
    final tax = subtotal * 0.10;
    final grandTotal = subtotal + tax;

    final success = await cartProvider.checkout(token);

    if (success && mounted) {
      _showSuccessReceiptDialog(subtotal, tax, grandTotal);
    } else if (mounted) {
      _showFeedbackSnackBar(
        cartProvider.checkoutError ?? 'Checkout failed. Please verify stock bounds.', 
        isError: true
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();

    final subtotal = cartProvider.totalAmount;
    final tax = subtotal * 0.10;
    final grandTotal = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GenshinTheme.bgCard,
        iconTheme: const IconThemeData(color: GenshinTheme.primaryGold),
        title: Text(
          'ARMORY CART',
          style: GoogleFonts.cinzel(
            color: GenshinTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: GenshinTheme.accentRed),
              tooltip: 'Clear Cart',
              onPressed: () => cartProvider.clearCart(),
            ),
        ],
      ),
      body: Container(
        decoration: GenshinTheme.mysticBackground,
        child: cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 64, color: GenshinTheme.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is currently empty.',
                      style: GoogleFonts.cinzel(color: GenshinTheme.textMuted, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('BACK TO ARMORY'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final item = cartItem.item;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: GenshinTheme.buildItemImage(
                                    item.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    iconSize: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: GoogleFonts.cinzel(
                                          fontWeight: FontWeight.bold,
                                          color: GenshinTheme.primaryGold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Price: ${item.price.toStringAsFixed(0)} Mora',
                                        style: GoogleFonts.inter(color: GenshinTheme.textMuted, fontSize: 12),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Total: ${(item.price * cartItem.quantity).toStringAsFixed(0)} Mora',
                                        style: GoogleFonts.inter(
                                          color: GenshinTheme.textParchment,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: GenshinTheme.primaryGold, size: 22),
                                      onPressed: () {
                                        final err = cartProvider.updateQuantity(item.id, cartItem.quantity - 1);
                                        if (err != null) _showFeedbackSnackBar(err, isError: true);
                                      },
                                    ),
                                    Text(
                                      '${cartItem.quantity}',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: GenshinTheme.textParchment,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: GenshinTheme.primaryGold, size: 22),
                                      onPressed: () {
                                        final err = cartProvider.updateQuantity(item.id, cartItem.quantity + 1);
                                        if (err != null) _showFeedbackSnackBar(err, isError: true);
                                      },
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: GenshinTheme.accentRed, size: 22),
                                  onPressed: () => cartProvider.removeItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'TRANSACTION RECEIPT SUMMARY',
                            style: GoogleFonts.cinzel(
                              color: GenshinTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildReceiptRow('Subtotal Items Mora', subtotal.toStringAsFixed(2)),
                          _buildReceiptRow('Teyvat Trade Tax (10% VAT)', tax.toStringAsFixed(2)),
                          _buildReceiptRow('Shipping Fee (Mondstadt Express)', 'FREE (0.00)'),
                          const Divider(color: Color(0xFF334155), thickness: 1),
                          _buildReceiptRow(
                            'Grand Total Price', 
                            '${grandTotal.toStringAsFixed(2)} Mora',
                            isBold: true,
                            color: GenshinTheme.primaryGold
                          ),
                          const SizedBox(height: 16),
                          cartProvider.isCheckingOut
                              ? const Center(child: CircularProgressIndicator(color: GenshinTheme.primaryGold))
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: GenshinTheme.primaryGold,
                                    foregroundColor: GenshinTheme.bgDark,
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                  onPressed: _handleCheckout,
                                  child: const Text('CONFIRM CHECKOUT'),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
