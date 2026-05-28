import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/cart_provider.dart';
import '../theme/genshin_theme.dart';

class DetailPage extends StatefulWidget {
  final Item item;
  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _selectedQuantity = 1;

  void _incrementQuantity() {
    if (_selectedQuantity < widget.item.stock) {
      setState(() => _selectedQuantity++);
    }
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 1) {
      setState(() => _selectedQuantity--);
    }
  }

  void _handleAddToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    
    final error = cartProvider.addItem(widget.item, _selectedQuantity);

    if (error != null) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: GenshinTheme.accentRed,
          content: Text(
            error,
            style: const TextStyle(color: GenshinTheme.bgDark, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: GenshinTheme.primaryGold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: GenshinTheme.bgDark),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Added $_selectedQuantity x "${widget.item.name}" to cart!',
                  style: GoogleFonts.inter(
                    color: GenshinTheme.bgDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: GenshinTheme.bgDark,
            onPressed: () {
              Navigator.pop(context); 
            },
          ),
        ),
      );
      setState(() => _selectedQuantity = 1); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isOutOfStock = item.stock == 0;
    final double totalPrice = item.price * _selectedQuantity;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GenshinTheme.bgCard,
        iconTheme: const IconThemeData(color: GenshinTheme.primaryGold),
        title: Text(
          item.name,
          style: GoogleFonts.cinzel(
            color: GenshinTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: GenshinTheme.mysticBackground,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: GenshinTheme.primaryGold, width: 1.5),
                      ),
                    ),
                    child: GenshinTheme.buildItemImage(
                      item.image,
                      fit: BoxFit.cover,
                      iconSize: 100,
                    ),
                  ),
                  
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: GenshinTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GenshinTheme.primaryGold, width: 1),
                      ),
                      child: Text(
                        '✨ ${item.type.toUpperCase()}',
                        style: GoogleFonts.cinzel(
                          color: GenshinTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Teyvat Serial ID: #${item.id}',
                                style: GoogleFonts.inter(
                                  color: GenshinTheme.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: GenshinTheme.primaryGold, width: 1),
                          ),
                          child: Text(
                            '${item.price.toStringAsFixed(0)} Mora',
                            style: GoogleFonts.cinzel(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: GenshinTheme.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    
                    Text(
                      'Lore & Description',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        color: GenshinTheme.secondaryGold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GenshinTheme.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155), width: 1),
                      ),
                      child: Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 24),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Inventory Stock Status:',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: GenshinTheme.textParchment,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? const Color(0x33EF4444)
                                : const Color(0x3310B981),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOutOfStock ? 'SOLD OUT' : '${item.stock} Items Available',
                            style: GoogleFonts.inter(
                              color: isOutOfStock ? GenshinTheme.accentRed : Colors.green[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40, color: Color(0xFF334155)),

                    
                    if (!isOutOfStock) ...[
                      Text(
                        'Select Purchase Quantity',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          color: GenshinTheme.secondaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: GenshinTheme.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GenshinTheme.primaryGold, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: GenshinTheme.primaryGold),
                                  onPressed: _decrementQuantity,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    '$_selectedQuantity',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: GenshinTheme.textParchment,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: GenshinTheme.primaryGold),
                                  onPressed: _incrementQuantity,
                                ),
                              ],
                            ),
                          ),
                          
                          
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Subtotal Cost:',
                                style: GoogleFonts.inter(fontSize: 12, color: GenshinTheme.textMuted),
                              ),
                              Text(
                                '${totalPrice.toStringAsFixed(0)} Mora',
                                style: GoogleFonts.cinzel(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: GenshinTheme.primaryGold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],

                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOutOfStock ? Colors.grey[700] : GenshinTheme.primaryGold,
                        foregroundColor: isOutOfStock ? Colors.grey[400] : GenshinTheme.bgDark,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: isOutOfStock ? null : _handleAddToCart,
                      child: Text(
                        isOutOfStock ? 'OUT OF STOCK' : 'ADD TO ARMORY CART',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
