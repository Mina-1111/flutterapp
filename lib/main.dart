import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:get/get.dart';
import 'authentication.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Azir App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Colors.blue,
        hintColor: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: const Authentication(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  List<Map<String, dynamic>> _favoriteProducts = [];
  List<Map<String, dynamic>> _cartProducts = [];
  List<Map<String, dynamic>> _orderHistory = [];
  List<Map<String, dynamic>> _productsToCompare = [];
  List<Map<String, dynamic>> _coupons = [
    {
      'code': 'WELCOME10',
      'discount': 10,
      'type': 'percentage',
      'validUntil': DateTime.now().add(Duration(days: 30)),
      'minPurchase': 50,
    },
    {
      'code': 'FREESHIP',
      'discount': 0,
      'type': 'free_shipping',
      'validUntil': DateTime.now().add(Duration(days: 15)),
      'minPurchase': 100,
    },
    {
      'code': 'SAVE20',
      'discount': 20,
      'type': 'percentage',
      'validUntil': DateTime.now().add(Duration(days: 7)),
      'minPurchase': 75,
    },
  ];
  String? _appliedCoupon;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _addToFavorites(Map<String, dynamic> product) {
    if (!_favoriteProducts.any((p) => p["name"] == product["name"])) {
      setState(() {
        _favoriteProducts.add(product);
      });
    }
  }

  void _removeFromFavorites(Map<String, dynamic> product) {
    setState(() {
      _favoriteProducts.removeWhere((p) => p["name"] == product["name"]);
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      if (_cartProducts.any((p) => p["name"] == product["name"])) {
        _cartProducts.firstWhere(
              (p) => p["name"] == product["name"],
            )["quantity"] +=
            1;
      } else {
        product["quantity"] = 1;
        _cartProducts.add(product);
      }
    });
  }

  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      _cartProducts.removeWhere((p) => p["name"] == product["name"]);
    });
  }

  void _updateQuantity(Map<String, dynamic> product, int newQuantity) {
    setState(() {
      _cartProducts.firstWhere(
            (p) => p["name"] == product["name"],
          )["quantity"] =
          newQuantity;
    });
  }

  double _calculateTotal() {
    double subtotal = _cartProducts.fold(
      0,
      (total, product) => total + (product["price"] * product["quantity"]),
    );

    // Apply coupon discount if any
    if (_appliedCoupon != null) {
      final coupon = _coupons.firstWhere((c) => c['code'] == _appliedCoupon);
      if (coupon['type'] == 'percentage') {
        subtotal -= subtotal * (coupon['discount'] / 100);
      } else if (coupon['type'] == 'fixed') {
        subtotal -= coupon['discount'];
      }
      // Free shipping is handled at checkout
    }

    return subtotal;
  }

  void _placeOrder(Map<String, dynamic> orderDetails) {
    setState(() {
      _orderHistory.add({
        ...orderDetails,
        'date': DateTime.now(),
        'items': List.from(_cartProducts),
        'total': _calculateTotal(),
        'status': 'Processing',
        'couponUsed': _appliedCoupon,
      });
      _cartProducts.clear();
      _appliedCoupon = null;
    });
  }

  void _returnItem(Map<String, dynamic> order, Map<String, dynamic> item) {
    setState(() {
      _orderHistory.firstWhere((o) => o['date'] == order['date'])['status'] =
          'Return Requested';
    });
  }

  void _addToComparison(Map<String, dynamic> product) {
    if (!_productsToCompare.any((p) => p["name"] == product["name"]) &&
        _productsToCompare.length < 4) {
      setState(() {
        _productsToCompare.add(product);
      });
    }
  }

  void _removeFromComparison(Map<String, dynamic> product) {
    setState(() {
      _productsToCompare.removeWhere((p) => p["name"] == product["name"]);
    });
  }

  void _applyCoupon(String couponCode) {
    if (_coupons.any((c) => c['code'] == couponCode)) {
      final coupon = _coupons.firstWhere((c) => c['code'] == couponCode);
      if (DateTime.now().isBefore(coupon['validUntil'])) {
        if (_calculateSubtotal() >= coupon['minPurchase']) {
          setState(() {
            _appliedCoupon = couponCode;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coupon applied successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Minimum purchase of \$${coupon['minPurchase']} required for this coupon',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('This coupon has expired')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid coupon code')));
    }
  }

  double _calculateSubtotal() {
    return _cartProducts.fold(
      0,
      (total, product) => total + (product["price"] * product["quantity"]),
    );
  }

  Map<String, dynamic> _getSalesStatistics() {
    Map<String, int> categorySales = {};
    Map<String, int> productSales = {};

    for (var order in _orderHistory) {
      for (var item in order['items']) {
        // Category statistics
        String category = item['category'];
        categorySales[category] =
            (categorySales[category] ?? 0) + (item['quantity'] as int);

        // Product statistics
        String productName = item['name'];
        productSales[productName] =
            (productSales[productName] ?? 0) + (item['quantity'] as int);
      }
    }

    // Get top selling categories
    var sortedCategories =
        categorySales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Get top selling products
    var sortedProducts =
        productSales.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalOrders': _orderHistory.length,
      'totalRevenue': _orderHistory.fold(
        0.0,
        (sum, order) => sum + order['total'],
      ),
      'topCategories':
          sortedCategories
              .take(3)
              .map((e) => {'category': e.key, 'sales': e.value})
              .toList(),
      'topProducts':
          sortedProducts
              .take(5)
              .map((e) => {'product': e.key, 'sales': e.value})
              .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      HomeScreen(
        isDarkMode: _isDarkMode,
        favoriteProducts: _favoriteProducts,
        cartProducts: _cartProducts,
        addToFavorites: _addToFavorites,
        removeFromFavorites: _removeFromFavorites,
        addToCart: _addToCart,
        addToComparison: _addToComparison,
      ),
      FavoritesScreen(
        favoriteProducts: _favoriteProducts,
        removeFromFavorites: _removeFromFavorites,
        isDarkMode: _isDarkMode,
        addToComparison: _addToComparison,
      ),
      CartScreen(
        cartProducts: _cartProducts,
        removeFromCart: _removeFromCart,
        updateQuantity: _updateQuantity,
        total: _calculateTotal(),
        isDarkMode: _isDarkMode,
        appliedCoupon: _appliedCoupon,
        applyCoupon: _applyCoupon,
        coupons: _coupons,
        placeOrder: _placeOrder,
      ),
      ProductsScreen(
        products: products,
        favoriteProducts: _favoriteProducts,
        addToFavorites: _addToFavorites,
        removeFromFavorites: _removeFromFavorites,
        addToCart: _addToCart,
        isDarkMode: _isDarkMode,
        addToComparison: _addToComparison,
      ),
    ];

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.blue,
          selectedItemColor: Color(0xfff60000),
          unselectedItemColor: Color(0xff000000),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Cart",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: "Products",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        drawer: AppDrawer(
          isDarkMode: _isDarkMode,
          toggleDarkMode: _toggleDarkMode,
          orderHistory: _orderHistory,
          returnItem: _returnItem,
          salesStatistics: _getSalesStatistics(),
          productsToCompare: _productsToCompare,
          removeFromComparison: _removeFromComparison,
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      hintColor: Colors.orange,
      fontFamily: 'Roboto',
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xffe1199c),
        titleTextStyle: TextStyle(
          color: Color(0xffffffff),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      hintColor: Colors.orange,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[900],
      cardColor: Color(0xffffffff),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xff000000),
        titleTextStyle: TextStyle(
          color: Color(0xff7d7d7d),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback toggleDarkMode;
  final List<Map<String, dynamic>> orderHistory;
  final Function(Map<String, dynamic>, Map<String, dynamic>) returnItem;
  final Map<String, dynamic> salesStatistics;
  final List<Map<String, dynamic>> productsToCompare;
  final Function(Map<String, dynamic>) removeFromComparison;

  const AppDrawer({
    required this.isDarkMode,
    required this.toggleDarkMode,
    required this.orderHistory,
    required this.returnItem,
    required this.salesStatistics,
    required this.productsToCompare,
    required this.removeFromComparison,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Azir App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _showSettingsDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            onTap: () {
              Navigator.pop(context);
              _showLanguageDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text(isDarkMode ? 'Light Mode' : 'Dark Mode'),
            onTap: () {
              toggleDarkMode();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Order History'),
            onTap: () {
              Navigator.pop(context);
              _showOrderHistory(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Sales Statistics'),
            onTap: () {
              Navigator.pop(context);
              _showSalesStatistics(context);
            },
          ),
          if (productsToCompare.isNotEmpty)
            ListTile(
              leading: Icon(Icons.compare),
              title: Text('Product Comparison (${productsToCompare.length})'),
              onTap: () {
                Navigator.pop(context);
                _showProductComparison(context);
              },
            ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('Notifications'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('English'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('العربية'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showOrderHistory(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Order History'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: orderHistory.length,
                itemBuilder: (context, index) {
                  final order = orderHistory[index];
                  return ExpansionTile(
                    title: Text(
                      'Order #${index + 1} - ${DateFormat('MMM dd, yyyy').format(order['date'])}',
                    ),
                    subtitle: Text(
                      '\$${order['total'].toStringAsFixed(2)} - ${order['status']}',
                    ),
                    children: [
                      ...order['items']
                          .map<Widget>(
                            (item) => ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                'Qty: ${item['quantity']} x \$${item['price']}',
                              ),
                              trailing:
                                  order['status'] == 'Delivered'
                                      ? IconButton(
                                        icon: Icon(Icons.assignment_return),
                                        onPressed:
                                            () => returnItem(order, item),
                                      )
                                      : null,
                            ),
                          )
                          .toList(),
                      if (order['couponUsed'] != null)
                        ListTile(
                          title: Text('Coupon Applied: ${order['couponUsed']}'),
                          trailing: Icon(Icons.discount, color: Colors.green),
                        ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSalesStatistics(BuildContext context) {
    final stats = salesStatistics;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Sales Statistics'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Orders: ${stats['totalOrders']}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Revenue: \$${stats['totalRevenue'].toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 16),
                  Text(
                    'Top Categories:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...stats['topCategories']
                      .map<Widget>(
                        (cat) => ListTile(
                          title: Text(cat['category']),
                          trailing: Text('${cat['sales']} sales'),
                        ),
                      )
                      .toList(),

                  SizedBox(height: 16),
                  Text(
                    'Top Products:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...stats['topProducts']
                      .map<Widget>(
                        (prod) => ListTile(
                          title: Text(prod['product']),
                          trailing: Text('${prod['sales']} sold'),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showProductComparison(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Product Comparison'),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Feature')),
                  ...productsToCompare
                      .map((p) => DataColumn(label: Text(p['name'])))
                      .toList(),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text('Price')),
                      ...productsToCompare
                          .map((p) => DataCell(Text('\$${p['price']}')))
                          .toList(),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Category')),
                      ...productsToCompare
                          .map((p) => DataCell(Text(p['category'])))
                          .toList(),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Rating')),
                      ...productsToCompare
                          .map(
                            (p) => DataCell(
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < (p['rating'] ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductsScreen(
                            products: products,
                            favoriteProducts: [],
                            addToFavorites: (p) {},
                            removeFromFavorites: (p) {},
                            addToCart: (p) {},
                            isDarkMode: isDarkMode,
                            addToComparison: (p) {},
                          ),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('About Azir App'),
            content: Text(
              'Version 1.0.0\n\nAn e-commerce app for all your shopping needs.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> favoriteProducts;
  final List<Map<String, dynamic>> cartProducts;
  final Function(Map<String, dynamic>) addToFavorites;
  final Function(Map<String, dynamic>) removeFromFavorites;
  final Function(Map<String, dynamic>) addToCart;
  final Function(Map<String, dynamic>) addToComparison;

  const HomeScreen({
    required this.isDarkMode,
    required this.favoriteProducts,
    required this.cartProducts,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.addToCart,
    required this.addToComparison,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Azir"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchField(context),
            _buildSpecialOffers(),
            _buildCategories(),
            _buildFeaturedProducts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        ),
        onTap: () => _showSearchDialog(context),
      ),
    );
  }

  Widget _buildSpecialOffers() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Special Offers",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specialOffers.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSsqhfKsh8tdn5YVM-kdIDds_6BQI90pZh-Q&s',
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Text(
                    specialOffers[index]["title"]!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Categories",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder:
                (context, index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categories[index]["icon"]),
                      SizedBox(height: 8),
                      Text(categories[index]["name"]!),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Featured Products",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: featuredProducts.length,
          itemBuilder:
              (context, index) => ProductCard(
                product: featuredProducts[index],
                isFavorite: favoriteProducts.any(
                  (p) => p["name"] == featuredProducts[index]["name"],
                ),
                addToFavorites: addToFavorites,
                removeFromFavorites: removeFromFavorites,
                addToCart: addToCart,
                isDarkMode: isDarkMode,
                addToComparison: addToComparison,
              ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    double minPrice = 0;
    double maxPrice = 1000;
    String selectedCategory = 'All';
    int minRating = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Advanced Search'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by product name...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items:
                          [
                                'All',
                                'Electronics',
                                'Clothing',
                                'Household Appliances',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    SizedBox(height: 16),
                    Text('Price Range:'),
                    RangeSlider(
                      values: RangeValues(minPrice, maxPrice),
                      min: 0,
                      max: 1000,
                      divisions: 10,
                      labels: RangeLabels(
                        '\$${minPrice.toInt()}',
                        '\$${maxPrice.toInt()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          minPrice = values.start;
                          maxPrice = values.end;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text('Minimum Rating:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < minRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              minRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Apply filters and search
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductsScreen(
                              products:
                                  products.where((product) {
                                    bool matchesPrice =
                                        product['price'] >= minPrice &&
                                        product['price'] <= maxPrice;
                                    bool matchesCategory =
                                        selectedCategory == 'All' ||
                                        product['category'] == selectedCategory;
                                    bool matchesRating =
                                        (product['rating'] ?? 0) >= minRating;
                                    return matchesPrice &&
                                        matchesCategory &&
                                        matchesRating;
                                  }).toList(),
                              favoriteProducts: favoriteProducts,
                              addToFavorites: addToFavorites,
                              removeFromFavorites: removeFromFavorites,
                              addToCart: addToCart,
                              isDarkMode: isDarkMode,
                              addToComparison: addToComparison,
                            ),
                      ),
                    );
                  },
                  child: Text('Search'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final Function(Map<String, dynamic>) addToFavorites;
  final Function(Map<String, dynamic>) removeFromFavorites;
  final Function(Map<String, dynamic>) addToCart;
  final bool isDarkMode;
  final Function(Map<String, dynamic>)? addToComparison;

  const ProductCard({
    required this.product,
    required this.isFavorite,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.addToCart,
    required this.isDarkMode,
    this.addToComparison,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetailScreen(
                    product: product,
                    isFavorite: isFavorite,
                    addToFavorites: addToFavorites,
                    removeFromFavorites: removeFromFavorites,
                    addToCart: addToCart,
                    isDarkMode: isDarkMode,
                    addToComparison: addToComparison,
                  ),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  product["image"]!,
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product["name"]!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "\$${product["price"].toString()}",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xfffc0202),
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (isFavorite) {
                      removeFromFavorites(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${product["name"]} removed from favorites!",
                          ),
                        ),
                      );
                    } else {
                      addToFavorites(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${product["name"]} added to favorites!",
                          ),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${product["name"]} added to cart!"),
                      ),
                    );
                  },
                ),
                if (addToComparison != null)
                  IconButton(
                    icon: Icon(Icons.compare),
                    onPressed: () {
                      addToComparison!(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${product["name"]} added to comparison!",
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final Function(Map<String, dynamic>) addToFavorites;
  final Function(Map<String, dynamic>) removeFromFavorites;
  final Function(Map<String, dynamic>) addToCart;
  final bool isDarkMode;
  final Function(Map<String, dynamic>)? addToComparison;

  const ProductDetailScreen({
    required this.product,
    required this.isFavorite,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.addToCart,
    required this.isDarkMode,
    this.addToComparison,
    Key? key,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedColor = "Red";
  String _selectedSize = "M";
  int _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<String> _reviews = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product["name"]),
        actions: [
          IconButton(
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              if (widget.isFavorite) {
                widget.removeFromFavorites(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Removed from favorites")),
                );
              } else {
                widget.addToFavorites(widget.product);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Added to favorites")));
              }
            },
          ),
          if (widget.addToComparison != null)
            IconButton(
              icon: Icon(Icons.compare),
              onPressed: () {
                widget.addToComparison!(widget.product);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Added to comparison")));
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product["name"]!,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "price: \$${widget.product["price"].toString()}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffef0e0e),
                    ),
                  ),
                  SizedBox(height: 19),
                  Text(
                    "Description:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(widget.product["details"]!),
                  SizedBox(height: 16),
                  _buildColorSelector(),
                  SizedBox(height: 16),
                  _buildSizeSelector(),
                  SizedBox(height: 16),
                  _buildQuantitySelector(),
                  SizedBox(height: 16),
                  _buildRatingSection(),
                  SizedBox(height: 16),
                  _buildReviewsSection(),
                  SizedBox(height: 16),
                  _buildFaqSection(),
                  SizedBox(height: 16),
                  _buildAddToCartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 350,
      width: double.infinity,
      child: Image.network(
        widget.product["image"]!,
        fit: BoxFit.fill,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              ["Red", "Blue", "Green", "Black"].map((color) {
                return ChoiceChip(
                  label: Text(color),
                  selected: _selectedColor == color,
                  onSelected: (selected) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Size:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              ["S", "M", "L", "XL"].map((size) {
                return ChoiceChip(
                  label: Text(size),
                  selected: _selectedSize == size,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSize = size;
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          "Quantity:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 16),
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (_quantity > 1) _quantity--;
            });
          },
        ),
        Text(_quantity.toString(), style: TextStyle(fontSize: 18)),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _quantity++;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rate this product:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _userRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _userRating = index + 1;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Reviews:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _reviewController,
          decoration: InputDecoration(
            hintText: "Write your review...",
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_reviewController.text.isNotEmpty) {
                  setState(() {
                    _reviews.add(_reviewController.text);
                    _reviewController.clear();
                  });
                }
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _reviews.length,
          itemBuilder:
              (context, index) => ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text("User ${index + 1}"),
                subtitle: Text(_reviews[index]),
              ),
        ),
      ],
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequently Asked Questions:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ExpansionTile(
          title: Text("What is the return policy?"),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "You can return the product within 30 days of purchase.",
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text("How long does shipping take?"),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Shipping usually takes 3-5 business days."),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          for (int i = 0; i < _quantity; i++) {
            widget.addToCart(widget.product);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Added $_quantity ${widget.product["name"]} to cart",
              ),
              action: SnackBarAction(
                label: "View Cart",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CartScreen(
                            cartProducts: [],
                            removeFromCart: (product) {},
                            updateQuantity: (product, quantity) {},
                            total: 0,
                            isDarkMode: widget.isDarkMode,
                            appliedCoupon: null,
                            applyCoupon: (code) {},
                            coupons: [],
                            placeOrder: (order) {},
                          ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        child: Text(
          "ADD TO CART (\$${(widget.product["price"] * _quantity).toStringAsFixed(2)})",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff0a78f7),
          ),
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteProducts;
  final Function(Map<String, dynamic>) removeFromFavorites;
  final bool isDarkMode;
  final Function(Map<String, dynamic>)? addToComparison;

  const FavoritesScreen({
    required this.favoriteProducts,
    required this.removeFromFavorites,
    required this.isDarkMode,
    this.addToComparison,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorites")),
      body:
          favoriteProducts.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No favorites yet!",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductsScreen(
                                  products: [],
                                  favoriteProducts: [],
                                  addToFavorites: (product) {},
                                  removeFromFavorites: (product) {},
                                  addToCart: (product) {},
                                  isDarkMode: isDarkMode,
                                  addToComparison: addToComparison,
                                ),
                          ),
                        );
                      },
                      child: Text("Browse Products"),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  return ListTile(
                    leading: Image.network(
                      product["image"]!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.fill,
                    ),
                    title: Text(product["name"]!),
                    subtitle: Text("\$${product["price"].toString()}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (addToComparison != null)
                          IconButton(
                            icon: Icon(Icons.compare),
                            onPressed: () {
                              addToComparison!(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${product["name"]} added to comparison!",
                                  ),
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeFromFavorites(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${product["name"]} removed from favorites",
                                ),
                                action: SnackBarAction(
                                  label: "UNDO",
                                  onPressed: () {},
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProductDetailScreen(
                                product: product,
                                isFavorite: true,
                                addToFavorites: (product) {},
                                removeFromFavorites: removeFromFavorites,
                                addToCart: (product) {},
                                isDarkMode: isDarkMode,
                                addToComparison: addToComparison,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartProducts;
  final Function(Map<String, dynamic>) removeFromCart;
  final Function(Map<String, dynamic>, int) updateQuantity;
  final double total;
  final bool isDarkMode;
  final String? appliedCoupon;
  final Function(String) applyCoupon;
  final List<Map<String, dynamic>> coupons;
  final Function(Map<String, dynamic>) placeOrder;

  const CartScreen({
    required this.cartProducts,
    required this.removeFromCart,
    required this.updateQuantity,
    required this.total,
    required this.isDarkMode,
    required this.appliedCoupon,
    required this.applyCoupon,
    required this.coupons,
    required this.placeOrder,
    Key? key,
  }) : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponField = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child:
                widget.cartProducts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Your cart is empty!",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductsScreen(
                                        products: [],
                                        favoriteProducts: [],
                                        addToFavorites: (product) {},
                                        removeFromFavorites: (product) {},
                                        addToCart: (product) {},
                                        isDarkMode: widget.isDarkMode,
                                      ),
                                ),
                              );
                            },
                            child: Text("Browse Products"),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: widget.cartProducts.length,
                      itemBuilder: (context, index) {
                        final product = widget.cartProducts[index];
                        return ListTile(
                          leading: Image.network(
                            product["image"]!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.fill,
                          ),
                          title: Text(product["name"]!),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("\$${product["price"].toString()}"),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      if (product["quantity"] > 1) {
                                        widget.updateQuantity(
                                          product,
                                          product["quantity"] - 1,
                                        );
                                      }
                                    },
                                  ),
                                  Text(product["quantity"].toString()),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      widget.updateQuantity(
                                        product,
                                        product["quantity"] + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              widget.removeFromCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${product["name"]} removed from cart",
                                  ),
                                  action: SnackBarAction(
                                    label: "UNDO",
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailScreen(
                                      product: product,
                                      isFavorite: false,
                                      addToFavorites: (product) {},
                                      removeFromFavorites: (product) {},
                                      addToCart: (product) {},
                                      isDarkMode: widget.isDarkMode,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
          _buildCheckoutSection(context),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    double subtotal = widget.cartProducts.fold(
      0,
      (total, product) => total + (product["price"] * product["quantity"]),
    );
    double discount = 0;
    double shipping = 10.0; // Default shipping cost

    if (widget.appliedCoupon != null) {
      final coupon = widget.coupons.firstWhere(
        (c) => c['code'] == widget.appliedCoupon,
        orElse: () => {},
      );
      if (coupon.isNotEmpty) {
        if (coupon['type'] == 'percentage') {
          discount = subtotal * (coupon['discount'] / 100);
        } else if (coupon['type'] == 'fixed') {
          discount = coupon['discount'].toDouble();
        } else if (coupon['type'] == 'free_shipping') {
          shipping = 0;
        }
      }
    }

    double total = subtotal - discount + shipping;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal:"),
              Text("\$${subtotal.toStringAsFixed(2)}"),
            ],
          ),
          SizedBox(height: 8),
          if (widget.appliedCoupon != null)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Discount (${widget.appliedCoupon}):"),
                    Text("-\$${discount.toStringAsFixed(2)}"),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Shipping:"),
              Text("\$${shipping.toStringAsFixed(2)}"),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (!_showCouponField && widget.appliedCoupon == null)
            TextButton(
              onPressed: () {
                setState(() {
                  _showCouponField = true;
                });
              },
              child: Text("Have a coupon code?"),
            ),
          if (_showCouponField || widget.appliedCoupon != null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: "Enter coupon code",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (widget.appliedCoupon != null) {
                      setState(() {
                        _couponController.clear();
                        widget.applyCoupon('');
                      });
                    } else {
                      widget.applyCoupon(_couponController.text);
                    }
                  },
                  child: Text(
                    widget.appliedCoupon != null ? "Remove" : "Apply",
                  ),
                ),
              ],
            ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _showCheckoutDialog(context, total);
            },
            child: Text(
              "CHECKOUT",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, double total) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    String selectedPaymentMethod = 'Credit Card';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Checkout",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Shipping Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    items:
                        ['Credit Card', 'PayPal', 'Cash on Delivery']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      selectedPaymentMethod = value!;
                    },
                    decoration: InputDecoration(
                      labelText: "Payment Method",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total:", style: TextStyle(fontSize: 18)),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          addressController.text.isNotEmpty) {
                        widget.placeOrder({
                          'name': nameController.text,
                          'address': addressController.text,
                          'paymentMethod': selectedPaymentMethod,
                        });
                        Navigator.pop(context);
                        _showOrderConfirmation(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all fields")),
                        );
                      }
                    },
                    child: Text("PLACE ORDER"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Order Confirmed!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text("Your order has been placed successfully."),
                SizedBox(height: 8),
                Text(
                  "Total: \$${widget.total.toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text("Back to Home"),
              ),
            ],
          ),
    );
  }
}

class ProductsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> favoriteProducts;
  final Function(Map<String, dynamic>) addToFavorites;
  final Function(Map<String, dynamic>) removeFromFavorites;
  final Function(Map<String, dynamic>) addToCart;
  final bool isDarkMode;
  final Function(Map<String, dynamic>)? addToComparison;

  const ProductsScreen({
    required this.products,
    required this.favoriteProducts,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.addToCart,
    required this.isDarkMode,
    this.addToComparison,
    super.key,
  });

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  String _sortOption = "Default";
  double _minPrice = 0;
  double _maxPrice = 1000;
  int _minRating = 0;

  @override
  Widget build(BuildContext context) {
    final filteredProducts =
        widget.products.where((product) {
          final matchesSearch = product["name"].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategory == "All" ||
              product["category"] == _selectedCategory;
          final matchesPrice =
              product["price"] >= _minPrice && product["price"] <= _maxPrice;
          final matchesRating = (product["rating"] ?? 0) >= _minRating;
          return matchesSearch &&
              matchesCategory &&
              matchesPrice &&
              matchesRating;
        }).toList();

    // Apply sorting
    switch (_sortOption) {
      case "Price: Low to High":
        filteredProducts.sort((a, b) => a["price"].compareTo(b["price"]));
        break;
      case "Price: High to Low":
        filteredProducts.sort((a, b) => b["price"].compareTo(a["price"]));
        break;
      case "Name: A-Z":
        filteredProducts.sort((a, b) => a["name"].compareTo(b["name"]));
        break;
      case "Name: Z-A":
        filteredProducts.sort((a, b) => b["name"].compareTo(a["name"]));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showAdvancedSearchDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 8),
                FilterChip(
                  label: Text("All"),
                  selected: _selectedCategory == "All",
                  onSelected: (bool value) {
                    setState(() {
                      _selectedCategory = "All";
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Electronics"),
                  selected: _selectedCategory == "Electronics",
                  onSelected: (bool value) {
                    setState(() {
                      _selectedCategory = "Electronics";
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Clothing"),
                  selected: _selectedCategory == "Clothing",
                  onSelected: (bool value) {
                    setState(() {
                      _selectedCategory = "Clothing";
                    });
                  },
                ),
                SizedBox(width: 8),
                FilterChip(
                  label: Text("Household Appliances"),
                  selected: _selectedCategory == "Household Appliances",
                  onSelected: (bool value) {
                    setState(() {
                      _selectedCategory = "Household Appliances";
                    });
                  },
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child:
                filteredProducts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No products found",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = "";
                                _selectedCategory = "All";
                                _minPrice = 0;
                                _maxPrice = 1000;
                                _minRating = 0;
                              });
                            },
                            child: Text("Reset Filters"),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder:
                          (context, index) => ProductCard(
                            product: filteredProducts[index],
                            isFavorite: widget.favoriteProducts.any(
                              (p) =>
                                  p["name"] == filteredProducts[index]["name"],
                            ),
                            addToFavorites: widget.addToFavorites,
                            removeFromFavorites: widget.removeFromFavorites,
                            addToCart: widget.addToCart,
                            isDarkMode: widget.isDarkMode,
                            addToComparison: widget.addToComparison,
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Advanced Search'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by product name...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items:
                          [
                                'All',
                                'Electronics',
                                'Clothing',
                                'Household Appliances',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    SizedBox(height: 16),
                    Text('Price Range:'),
                    RangeSlider(
                      values: RangeValues(_minPrice, _maxPrice),
                      min: 0,
                      max: 1000,
                      divisions: 10,
                      labels: RangeLabels(
                        '\$${_minPrice.toInt()}',
                        '\$${_maxPrice.toInt()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text('Minimum Rating:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _minRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _minRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Sort By"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: Text("Default"),
                  value: "Default",
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: Text("Price: Low to High"),
                  value: "Price: Low to High",
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: Text("Price: High to Low"),
                  value: "Price: High to Low",
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: Text("Name: A-Z"),
                  value: "Name: A-Z",
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile(
                  title: Text("Name: Z-A"),
                  value: "Name: Z-A",
                  groupValue: _sortOption,
                  onChanged: (value) {
                    setState(() {
                      _sortOption = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileDetails(),
            _buildProfileActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage("https://via.placeholder.com/150"),
          ),
          SizedBox(height: 16),
          Text(
            "John Doe",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "john.doe@example.com",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(leading: Icon(Icons.phone), title: Text("+1 234 567 890")),
          Divider(),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("123 Main St, City, Country"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Member since January 2023"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () {},
            child: Text("Edit Profile"),
          ),
          SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Logout"),
            content: Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // Perform logout
                  Navigator.pop(context);
                },
                child: Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

// البيانات (يمكن نقلها إلى ملفات منفصلة)
final List<Map<String, dynamic>> products = [
  {
    "name": "SAMSUNG 65-Inch",
    "image": "https://m.media-amazon.com/images/I/71T3tmMx2FL._AC_SX466_.jpg",
    "price": 288.99,
    "category": "Household Appliances",
    "details":
        "SAMSUNG 65-Inch Class Crystal UHD 4K DU7200 Series HDR Smart TV w/Object Tracking Sound Lite, PurColor, Motion Xcelerator, Mega Contrast, Q-Symphony (UN65DU7200, 2024 Model)",
    "rating": 4,
  },
  {
    "name": "VIZIO 32-inch",
    "image": "https://m.media-amazon.com/images/I/81qgm6blFrL._AC_SX466_.jpg",
    "price": 118.0,
    "category": "Electronics",
    "details":
        "VIZIO 32-inch HD Smart TV 720p LED w/Alexa Compatibility, Google Cast Built-in, Bluetooth Headphone Capable (VHD32M-08, New)",
    "rating": 3,
  },
  {
    "name": "Dell Latitude 3550",
    "image": "https://m.media-amazon.com/images/I/81l0vIoTsyL._AC_SX466_.jpg",
    "price": 140.50,
    "category": "Electronics",
    "details":
        "Dell Latitude 3550 15 Laptop, 15.6 FHD Computer Intel 12-Core Ultra 7 155U (Beat i7-1355U) 64GB DDR5 RAM 1TB PCIe SSD WiFi 6, USB 4, HDMI, Backlit Keyboard, Fingerprint Reader, Windows 11 Pro",
    "rating": 5,
  },
  {
    "name": "ASUS E410 Intel",
    "image": "https://m.media-amazon.com/images/I/614Jk1dIoGL._AC_SX466_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "ASUS E410 Intel Celeron N4020 4GB 64GB 14-Inch HD LED Win 10 Laptop (Star Black)",
    "rating": 4,
  },
  {
    "name": "jumper 2 in 1 Laptop",
    "image": "https://m.media-amazon.com/images/I/71SEvE6m1kL._AC_SX466_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "jumper 2 in 1 Laptop, 16 inch Convertible Laptop Computer with IPS FHD 360 Degree Touchscreen, 640GB Storage, 16GB RAM, Fingerprint Reader, Backlit Keyboard, Celeron N5095, 53.2WH",
    "rating": 3,
  },
  {
    "name": "EAZZE D1 Smart",
    "image":
        "https://m.media-amazon.com/images/I/819tqX2B-BL._AC_UY327_FMwebp_QL65_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "EAZZE D1 Smart Watch for Men Women, Fitness Tracker with Heart Rate Monitor, Blood Oxygen Monitor, 1.7\" Touch Screen, 100+ Sports Modes, Sleep Monitor, 5ATM Waterproof, for Android iOS",
    "rating": 4,
  },
  {
    "name": "BIGASUO 10.1 Inch",
    "image":
        "https://m.media-amazon.com/images/I/71LDwpH4wLL.__AC_SX300_SY300_QL70_FMwebp_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "BIGASUO 10.1 Inch Android Tablet, 4GB RAM 64GB ROM, Quad-Core Processor, Dual Camera, WiFi, Bluetooth, GPS, HD Display, Google Certified, Kid Mode, Black",
    "rating": 3,
  },
  {
    "name": "Dash Cam",
    "image":
        "https://m.media-amazon.com/images/I/71uNMozN-6L.__AC_SX300_SY300_QL70_FMwebp_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "Dash Cam Front and Rear, 1080P FHD Dashboard Camera Recorder with 3.16\" LCD Screen, 170° Wide Angle, WDR, Night Vision, G-Sensor, Loop Recording, Parking Monitor",
    "rating": 4,
  },
  {
    "name": "Meta Quest 3S",
    "image": "https://m.media-amazon.com/images/I/61OseHapCUL._SX522_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "Meta Quest 3S — Advanced All-In-One Virtual Reality Headset — 128GB — Get Asgard's Wrath 2 Free",
    "rating": 5,
  },
  {
    "name": "Wireless Earbuds",
    "image":
        "https://m.media-amazon.com/images/I/710b3PtMquL.__AC_SX300_SY300_QL70_FMwebp_.jpg",
    "price": 190,
    "category": "Electronics",
    "details":
        "Wireless Earbuds Bluetooth 5.3 Headphones 50H Playtime, IPX7 Waterproof, Deep Bass Stereo Sound, Built-in Mic, LED Display, Bluetooth Earbuds with Earhooks for Sports Running",
    "rating": 4,
  },
  {
    "name": "RockJam 61 Key",
    "image":
        "https://m.media-amazon.com/images/I/61XVXZRHJtL.__AC_SX300_SY300_QL70_FMwebp_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "RockJam 61 Key Keyboard Piano with LCD Display Kit, Stand, Bench, Headphones, Simply Piano App & Keynote Stickers",
    "rating": 3,
  },
  {
    "name": "Keypad Smart Door",
    "image": "https://m.media-amazon.com/images/I/61Q4HAiMfHL._AC_SX679_.jpg",
    "price": 140,
    "category": "Electronics",
    "details":
        "Keypad Smart Door Lock - Fingerprint & Touch Screen Keyless Entry Deadbolt - Electronic Door Lock with Key - Auto Lock - Works with Alexa - BHMA Certified - Satin Nickel",
    "rating": 5,
  },
  {
    "name": "T-Shirt",
    "image": "https://via.placeholder.com/150",
    "price": 19.99,
    "category": "Clothing",
    "details": "A comfortable and stylish T-shirt made from 100% cotton.",
    "rating": 4,
  },
  {
    "name": "Washing Machine",
    "image": "https://menashopeg.com/wp-content/uploads/2024/02/F2T2TYM1S.webp",
    "price": 699.99,
    "category": "Home",
    "details":
        "A front-load washing machine with energy-saving features and multiple wash programs.",
    "rating": 4,
  },
];

final List<Map<String, dynamic>> specialOffers = [
  {
    "title": "50% Off on Electronics",
    "image":
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBKemhHAH0bkJXGiojbWxjLv--3xbugJJn7A&s",
  },
  {
    "title": "Buy 1 Get 1 Free",
    "image": "https://m.media-amazon.com/images/I/61DO3csJh+L._AC_SY500_.jpg",
  },
  {
    "title": "Free Shipping on Orders Over \$100",
    "image": "https://m.media-amazon.com/images/I/61DO3csJh+L._AC_SY500_.jpg",
  },
];

final List<Map<String, dynamic>> categories = [
  {"name": "Home", "icon": Icons.home},
  {"name": "Electronics", "icon": Icons.electrical_services},
  {"name": "Clothes", "icon": Icons.shopping_bag},
  {"name": "Sports", "icon": Icons.sports},
];

final List<Map<String, dynamic>> featuredProducts = [
  {
    "name": "Samsung 50 Inch TV Crystal Processor 4K LED",
    "image": "https://m.media-amazon.com/images/I/61mSsqaxrHL._AC_SX522_.jpg",
    "price": 59.99,
    "category": "Electronics",
    "details": """
Samsung 50 Inches with resolution 3,840 x 2,160 - 
50HZ Refresh Rate
Crystal Processor 4K Picture Engine with High Dynamic Range,
 Mega Contrast, UHD Dimming and LED Clear Motion
Smart Services: Tizen Operation System, Web Browser, SmartThings App Support and Media Home
Smart Features: Mobile to TV - Mirroring, DLNA, Tap View, SmartThings Hub, WiFi Direct, TV Sound to Mobile and Microsoft 365 Web Service
DVB-T2CS2 Digital Broadcasting, with Analog Tuner and TV Key""",
    "rating": 4,
  },
  {
    "name": "Lenovo LOQ 15IRX9 Gaming",
    "image": "https://m.media-amazon.com/images/I/61veW5uEbRL._AC_SX679_.jpg",
    "price": 20.99,
    "category": "Electronics",
    "details": """
    14th i7-14700HX 20 Cores,
    AI Chip: LA1, NVIDIA GeForce RTX 4060 8GB GDDR6 
    Graphics :
    16GB DDR5-5600 RAM, 1TB SSD
    15.6" FHD (1920x1080) IPS 300nits 144Hz 100% sRGB
    """,
    "rating": 5,
  },
  {
    "name": "Bosch Washing machine",
    "image": "https://m.media-amazon.com/images/I/51-6P1rJrVL._AC_SY500_.jpg",
    "price": 355.500,
    "category": "Electronics",
    "details": """
Brand : Bosch
Main colour of product : Cast iron grey
Noise level washing : 54 dB(A) re 1 pW
Noise level spinning : 75 dB(A) re 1 pW
Savety : Balance control - Foam control - Child saftety devices
""",
    "rating": 4,
  },
  {
    "name": "Canon LASER Prinyer MFP I-S MF453DW - White",
    "image": "https://m.media-amazon.com/images/I/41qRURvvP5L._AC_SX679_.jpg",
    "price": 129.99,
    "category": "Electronics",
    "details": """
Print: Monoprint maximum resolution: 1200 x 1200 DPIc
Copy: Monocopy Max Resolution: 600 x 600 DPI
Scanning: Colour scan optical scan resolution: 600 x 600 DPI
Maximum paper size of ISO A series: A4
Product colour: Black white""",
    "rating": 3,
  },
  {
    "name":
        "Top Fit MT 510 Fitness Treadmill (110 Kg) Capacity, Durable Design for Regular Gym and Home Workouts, Foldable, Electric, Motorized Treadmill",
    "image": "https://m.media-amazon.com/images/I/81c1HNUm82L._AC_SX679_.jpg",
    "price": 229.99,
    "category": "Electronics",
    "details": """
Top Fit MT-510
training and exercise
2.25 HP
speed: 1-12 KM
Belt: 40*110
foldable for better storage
heart rate and calories sensor
    """,
    "rating": 4,
  },
  {
    "name": "Canon LASER Prinyer MFP I-S MF453DW - White",
    "image": "https://m.media-amazon.com/images/I/71KH4jIuyCL._AC_SX522_.jpg",
    "price": 188.50,
    "category": "Electronics",
    "details": """
Brand Name SAMSUNG
Screen Size	27 Inches
Resolution	FHD 1080p
Aspect Ratio	16:9
Screen Surface Description	Flat
Image Contrast Ratio	2000:1
Response Time	5 Milliseconds
Refresh Rate	75 Hz
Display Resolution Maximum	1920 x 1080 Pixels
Special Features	3D
    """,
    "rating": 5,
  },
];
