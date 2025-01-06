import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:pos_kasir/deskripsi.dart';
import 'database_helper.dart';
import 'tambahmenu.dart';
import 'checkout.dart';
import 'login_screen.dart';
import 'navbar.dart';

class Home extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutItems;

  const Home({Key? key, required this.checkoutItems}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> menus = [];
  List<Map<String, dynamic>> filteredMenus = [];
  String _activeCategory = 'Semua';
  int _currentIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    final data = await DatabaseHelper.instance.getMenus();
    setState(() {
      menus = data;
      filteredMenus = data;
    });
  }

  void _filterMenus() {
    setState(() {
      filteredMenus = menus.where((menu) {
        final isInCategory =
            _activeCategory == 'Semua' || menu['category'] == _activeCategory;
        final isInSearchQuery =
            menu['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        return isInCategory && isInSearchQuery;
      }).toList();
    });
  }

  void _addToCheckout(Map<String, dynamic> menu) {
    setState(() {
      final existingItem = widget.checkoutItems.firstWhere(
        (item) => item['id'] == menu['id'],
        orElse: () => {},
      );

      if (existingItem.isNotEmpty) {
        existingItem['quantity']++;
      } else {
        widget.checkoutItems.add({
          'id': menu['id'],
          'name': menu['name'],
          'price': menu['price'],
          'quantity': 1,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${menu['name']} berhasil ditambahkan ke keranjang!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.of(context)
          .push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TambahMenu(checkoutItems: widget.checkoutItems),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          )
          .then((_) => _loadMenus());
    } else if (index == 2) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Checkout(checkoutItems: widget.checkoutItems),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LoginScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  String formatCurrency(int value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(value);
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Minuman':
        return Icons.local_cafe;
      case 'Snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, color: Colors.white),
            SizedBox(width: 8),
            Text('Menu Danu Cafe', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.teal.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterMenus();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Makanan', 'Minuman', 'Snack']
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _activeCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _activeCategory = category;
                              _filterMenus();
                            });
                          },
                          selectedColor: Colors.teal,
                          backgroundColor: Colors.teal.shade100,
                          labelStyle: TextStyle(
                            color: _activeCategory == category
                                ? Colors.white
                                : Colors.teal.shade800,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMenus.length,
              itemBuilder: (context, index) {
                final menu = filteredMenus[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade100,
                      child: Icon(
                        getCategoryIcon(menu['category']),
                        color: Colors.teal,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      menu['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(formatCurrency(menu['price'])),
                    trailing: IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.green),
                      onPressed: () => _addToCheckout(menu),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Deskripsi(
                            menu: menu,
                            checkoutItems: widget.checkoutItems,
                          ),
                        ),
                      ).then((_) => _loadMenus());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
