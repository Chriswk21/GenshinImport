import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme/genshin_theme.dart';
import 'admin_page.dart';
import 'cart_page.dart';
import 'detail_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All'; 
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getItems();
      setState(() {
        _items = items;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Teyvat items: $e'),
          backgroundColor: GenshinTheme.accentRed,
        ),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesCategory = _selectedCategory == 'All' || item.type == _selectedCategory;
        final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                              item.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _handleCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _handleSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _handleLogout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GenshinTheme.bgCard,
        elevation: 2,
        title: Text(
          'GENSHIN IMPORT',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: GenshinTheme.primaryGold,
            fontSize: 20,
          ),
        ),
        actions: [
          
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag, color: GenshinTheme.primaryGold, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  ).then((_) => _fetchItems()); 
                },
              ),
              if (cartProvider.totalItemsCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: GenshinTheme.accentCyan,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartProvider.totalItemsCount}',
                      style: GoogleFonts.inter(
                        color: GenshinTheme.bgDark,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: GenshinTheme.accentRed),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Container(
        decoration: GenshinTheme.mysticBackground,
        child: RefreshIndicator(
          color: GenshinTheme.primaryGold,
          onRefresh: _fetchItems,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Container(
                color: const Color(0x331E293B),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?['name'] ?? 'Traveler'}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: GenshinTheme.textParchment,
                          ),
                        ),
                        Text(
                          user?['email'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: GenshinTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: authProvider.isAdmin 
                            ? const Color(0xFFFEE2E2) 
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: authProvider.isAdmin ? Colors.red : Colors.amber, 
                          width: 1
                        ),
                      ),
                      child: Text(
                        authProvider.isAdmin ? '👑 ADMIN' : '⭐ TRAVELER',
                        style: GoogleFonts.cinzel(
                          color: authProvider.isAdmin ? Colors.red[900] : Colors.amber[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'Search Teyvat Weapons & Artifacts...',
                    prefixIcon: const Icon(Icons.search, color: GenshinTheme.primaryGold),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: GenshinTheme.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearchChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildCategoryTab('All', Icons.all_inclusive),
                    const SizedBox(width: 8),
                    _buildCategoryTab('Weapon', Icons.gavel),
                    const SizedBox(width: 8),
                    _buildCategoryTab('Artifact', Icons.auto_awesome_motion),
                  ],
                ),
              ),

              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: GenshinTheme.primaryGold))
                    : _filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 64, color: GenshinTheme.textMuted),
                                const SizedBox(height: 16),
                                Text(
                                  'No items found matching your filters.',
                                  style: GoogleFonts.cinzel(color: GenshinTheme.textMuted, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.70,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return _buildProductCard(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: GenshinTheme.primaryGold,
              foregroundColor: GenshinTheme.bgDark,
              icon: const Icon(Icons.admin_panel_settings, size: 24),
              label: Text(
                'MANAGE ITEMS',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                ).then((_) => _fetchItems()); 
              },
            )
          : null,
    );
  }

  Widget _buildCategoryTab(String categoryName, IconData icon) {
    final isSelected = _selectedCategory == categoryName;
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleCategoryChanged(categoryName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? GenshinTheme.primaryGold : GenshinTheme.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? GenshinTheme.secondaryGold : const Color(0xFF334155),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? GenshinTheme.bgDark : GenshinTheme.primaryGold,
              ),
              const SizedBox(width: 6),
              Text(
                categoryName + 's',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? GenshinTheme.bgDark : GenshinTheme.textParchment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildProductCard(Item item) {
    final isOutOfStock = item.stock == 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPage(item: item)),
          ).then((_) => _fetchItems()); 
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  
                  GenshinTheme.buildItemImage(
                    item.image,
                    fit: BoxFit.cover,
                    iconSize: 48,
                  ),
                  
                  
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: GenshinTheme.primaryGold, width: 0.8),
                      ),
                      child: Text(
                        item.type.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          color: GenshinTheme.primaryGold,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOutOfStock ? GenshinTheme.accentRed : Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOutOfStock ? 'OUT OF STOCK' : 'STOCK: ${item.stock}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: GenshinTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                      Text(
                        '${item.price.toStringAsFixed(0)} Mora',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: GenshinTheme.textParchment,
                        ),
                      ),
                      
                      
                      Row(
                        children: const [
                          Icon(Icons.star, size: 10, color: Colors.amber),
                          Icon(Icons.star, size: 10, color: Colors.amber),
                          Icon(Icons.star, size: 10, color: Colors.amber),
                          Icon(Icons.star, size: 10, color: Colors.amber),
                          Icon(Icons.star, size: 10, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
