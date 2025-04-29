import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For currency formatting
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'authentication.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'map_location_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
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
      home: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Initialize after first frame
            SharedPreferences.getInstance().then((prefs) {
              print('SharedPreferences initialized successfully');
            }).catchError((error) {
              print('Error initializing SharedPreferences: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Error loading preferences. Some features may not work.'),
                ),
              );
            });
          });
          return const Authentication();
        },
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

// Add new ChatSupportScreen
class ChatSupportScreen extends StatefulWidget {
  @override
  _ChatSupportScreenState createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I\'m Azir AI assistant. How can I help you today?',
      'isUser': false,
      'time': DateTime.now().subtract(Duration(minutes: 2)),
    }
  ];

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    
    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isUser': true,
        'time': DateTime.now(),
      });
    });
    
    // Simulate AI response after a delay
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'text': _getAIResponse(_messageController.text),
          'isUser': false,
          'time': DateTime.now(),
        });
      });
    });
    
    _messageController.clear();
  }

  String _getAIResponse(String message) {
    // In a real app, this would call your AI chat API
    // Simple keyword-based responses for demo
    message = message.toLowerCase();
    
    if (message.contains('order') || message.contains('track')) {
      return 'You can track your orders in the "Order History" section of the app.';
    } else if (message.contains('return') || message.contains('refund')) {
      return 'To initiate a return, go to your order history, select the item, and tap "Return Item".';
    } else if (message.contains('price') || message.contains('cost')) {
      return 'Product prices are listed on each product page. We also offer price matching on select items.';
    } else if (message.contains('delivery') || message.contains('shipping')) {
      return 'Standard delivery takes 3-5 business days. Express options are available at checkout.';
    } else {
      return 'I understand you\'re asking about "$message". For more specific help, please contact our support team.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Support Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                return ChatBubble(
                  text: msg['text'],
                  isUser: msg['isUser'],
                  time: msg['time'],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add ChatBubble widget
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime time;

  const ChatBubble({
    required this.text,
    required this.isUser,
    required this.time,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser 
            ? Theme.of(context).primaryColor 
            : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(time),
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MainAppState extends State<MainApp> {
  
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
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
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Delay initialization to avoid channel errors
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _initPrefs();
      }
    });
  }

  Future<void> _initPrefs() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      if (mounted) {
        await _loadPreferences();
        _isInitialized = true;
      }
    } catch (e) {
      print('Error initializing preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading preferences. Using default settings.'),
          ),
        );
      }
    }
  }

  Future<void> _loadPreferences() async {
    if (_prefs == null) return;

    try {
      setState(() {
        _isDarkMode = _prefs!.getBool('isDarkMode') ?? false;
        _selectedLanguage = _prefs!.getString('language') ?? 'English';

        final favoritesJson = _prefs!.getStringList('favorites') ?? [];
        _favoriteProducts = favoritesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();

        final cartJson = _prefs!.getStringList('cart') ?? [];
        _cartProducts = cartJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();

        final historyJson = _prefs!.getStringList('orderHistory') ?? [];
        _orderHistory = historyJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();
      });
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    if (_prefs == null) return;

    try {
      await _prefs!.setBool('isDarkMode', _isDarkMode);
      await _prefs!.setString('language', _selectedLanguage);

      final favoritesJson =
          _favoriteProducts.map((product) => jsonEncode(product)).toList();
      await _prefs!.setStringList('favorites', favoritesJson);

      final cartJson =
          _cartProducts.map((product) => jsonEncode(product)).toList();
      await _prefs!.setStringList('cart', cartJson);

      final historyJson =
          _orderHistory.map((order) => jsonEncode(order)).toList();
      await _prefs!.setStringList('orderHistory', historyJson);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _savePreferences();
  }

  void _setLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    _savePreferences();
  }

  void _addToFavorites(Map<String, dynamic> product) {
    if (!_favoriteProducts.any((p) => p["name"] == product["name"])) {
      setState(() {
        _favoriteProducts.add(product);
      });
      _savePreferences();
    }
  }

  void _removeFromFavorites(Map<String, dynamic> product) {
    setState(() {
      _favoriteProducts.removeWhere((p) => p["name"] == product["name"]);
    });
    _savePreferences();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      if (_cartProducts.any((p) => p["name"] == product["name"])) {
        _cartProducts.firstWhere(
          (p) => p["name"] == product["name"],
        )["quantity"] += 1;
      } else {
        product["quantity"] = 1;
        _cartProducts.add(product);
      }
    });
    _savePreferences();
  }

  void _removeFromCart(Map<String, dynamic> product) {
    setState(() {
      _cartProducts.removeWhere((p) => p["name"] == product["name"]);
    });
    _savePreferences();
  }

  void _updateQuantity(Map<String, dynamic> product, int newQuantity) {
    setState(() {
      _cartProducts.firstWhere(
        (p) => p["name"] == product["name"],
      )["quantity"] = newQuantity;
    });
    _savePreferences();
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
        'date': DateTime.now().toIso8601String(),
        'items': List.from(_cartProducts),
        'total': _calculateTotal(),
        'status': 'Processing',
      });
      _cartProducts.clear();
      _appliedCoupon = null;
    });
    _savePreferences();
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
    var sortedCategories = categorySales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get top selling products
    var sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalOrders': _orderHistory.length,
      'totalRevenue': _orderHistory.fold(
        0.0,
        (sum, order) => sum + order['total'],
      ),
      'topCategories': sortedCategories
          .take(3)
          .map((e) => {'category': e.key, 'sales': e.value})
          .toList(),
      'topProducts': sortedProducts
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
          setLanguage: _setLanguage,
          selectedLanguage: _selectedLanguage,
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
class ShoppingAssistantScreen extends StatefulWidget {
  @override
  _ShoppingAssistantScreenState createState() => _ShoppingAssistantScreenState();
}

class _ShoppingAssistantScreenState extends State<ShoppingAssistantScreen> {
  int _currentStep = 0;
  double _budget = 500;
  String _usage = '';
  List<String> _preferences = [];
  List<Map<String, dynamic>> _recommendedProducts = [];

  final List<String> _usageOptions = [
    'Daily Usage',
    'Professional Usage',
    'Gaming and Entertainment',
    'Office Work',
    'Graphic Design',
  ];

  final List<String> _preferenceOptions = [
    'Popular Brand',
    'Best Performance',
    'Lowest Price',
    'Highest Rating',
    'High Specifications',
  ];

  void _getRecommendations() {
    // هنا سيتم تحليل المدخلات وعرض المنتجات المناسبة
    setState(() {
      _recommendedProducts = products.where((product) {
        bool matchesBudget = product['price'] <= _budget;
        bool matchesUsage = _usage.isEmpty || 
            (product['description']?.contains(_usage) ?? false);
        bool matchesPreferences = _preferences.isEmpty || 
            _preferences.any((pref) => product['description']?.contains(pref) ?? false);
        
        return matchesBudget && matchesUsage && matchesPreferences;
      }).toList();
      
      _currentStep = 3; // انتقل لخطوة النتائج
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Assistant')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else if (_currentStep == 2) {
            _getRecommendations();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: Text('Budget'),
            content: Column(
              children: [
                Text('Set your budget: ${_budget.round()}'),
                Slider(
                  value: _budget,
                  min: 100,
                  max: 5000,
                  divisions: 49,
                  label: _budget.round().toString(),
                  onChanged: (value) => setState(() => _budget = value),
                ),
              ],
            ),
          ),
          Step(
            title: Text('Required Usage'),
            content: Column(
              children: _usageOptions.map((usage) => RadioListTile(
                title: Text(usage),
                value: usage,
                groupValue: _usage,
                onChanged: (value) => setState(() => _usage = value.toString()),
              )).toList(),
            ),
          ),
          Step(
            title: Text('Preferences'),
            content: Column(
              children: _preferenceOptions.map((pref) => CheckboxListTile(
                title: Text(pref),
                value: _preferences.contains(pref),
                onChanged: (checked) => setState(() {
                  if (checked!) {
                    _preferences.add(pref);
                  } else {
                    _preferences.remove(pref);
                  }
                }),
              )).toList(),
            ),
          ),
          Step(
              title: Text('Results'),
            content: _recommendedProducts.isEmpty
                ? Text('No products match your choices')
                : Column(
                    children: _recommendedProducts.take(5).map((product) => ProductCard(
                      product: product,
                      isFavorite: false,
                      addToFavorites: (p) {},
                      removeFromFavorites: (p) {},
                      addToCart: (p) {},
                      isDarkMode: false,
                    )).toList(),
                  ),
          ),
        ],
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
  final Function(String) setLanguage;
  final String selectedLanguage;

  AppDrawer({
    required this.isDarkMode,
    required this.toggleDarkMode,
    required this.orderHistory,
    required this.returnItem,
    required this.salesStatistics,
    required this.productsToCompare,
    required this.removeFromComparison,
    required this.setLanguage,
    required this.selectedLanguage,
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
  leading: Icon(Icons.chat),
  title: Text('AI Support'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatSupportScreen()),
    );
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
  leading: Icon(Icons.shopping_basket),
  title: Text('Shopping Assistant'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingAssistantScreen()),
    );
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
      builder: (context) => AlertDialog(
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
    String tempLanguage = selectedLanguage;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Language'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text('English'),
                    value: 'English',
                    groupValue: tempLanguage,
                    onChanged: (value) {
                      setState(() {
                        tempLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('العربية'),
                    value: 'Arabic',
                    groupValue: tempLanguage,
                    onChanged: (value) {
                      setState(() {
                        tempLanguage = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setLanguage(tempLanguage);
                    _applyLanguage(context);
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyLanguage(BuildContext context) {
    if (selectedLanguage == 'Arabic') {
      print('تم تغيير اللغة إلى العربية');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تغيير اللغة إلى العربية')),
      );
    } else {
      print('Language changed to English');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language changed to English')),
      );
    }
  }

  void _showOrderHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  'Order #${index + 1} - ${DateFormat('MMM dd, yyyy').format(DateTime.parse(order['date']))}',
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
                          trailing: order['status'] == 'Delivered'
                              ? IconButton(
                                  icon: Icon(Icons.assignment_return),
                                  onPressed: () => returnItem(order, item),
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
      builder: (context) => AlertDialog(
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('product comparison'),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                tooltip: 'add product to comparison',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsScreen(
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
            ],
          ),
          body: _buildComparisonTable(),
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Product Images Row
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: productsToCompare.length,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemBuilder: (context, index) {
                final product = productsToCompare[index];
                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(product['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, size: 18),
                            color: Colors.red,
                            onPressed: () => removeFromComparison(product),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      product['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 20),

          // Comparison Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 24,
                  dataRowHeight: 60,
                  headingRowHeight: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'specifications',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...productsToCompare
                        .map((p) => DataColumn(
                              label: SizedBox(
                                width: 120,
                                child: Text(
                                  p['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                  rows: [
                    // Price Row
                    _buildComparisonRow(
                      title: 'price',
                      values: productsToCompare
                          .map((p) => '\$${p['price']}')
                          .toList(),
                      icon: Icons.attach_money,
                    ),

                    // Category Row
                    _buildComparisonRow(
                      title: 'category',
                      values: productsToCompare
                          .map((p) => p['category'].toString())
                          .toList(),
                      icon: Icons.category,
                    ),

                    // Rating Row
                    DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber),
                              SizedBox(width: 8),
                              Text('rating'),
                            ],
                          ),
                        ),
                        ...productsToCompare
                            .map((p) => DataCell(
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < (p['rating'] ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 20,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ],
                    ),

                    // Warranty Row
                    _buildComparisonRow(
                      title: 'warranty',
                      values: productsToCompare
                          .map((p) => '${p['warranty'] ?? 0} years')
                          .toList(),
                      icon: Icons.verified_user,
                    ),

                    // Color Row
                    DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Icon(Icons.color_lens, color: Colors.blue),
                              SizedBox(width: 8),
                              Text("colors available"),
                            ],
                          ),
                        ),
                        ...productsToCompare
                            .map((p) => DataCell(
                                  Wrap(
                                    spacing: 4,
                                    children: (p['colors'] as List<dynamic>?)
                                            ?.map((color) => Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: _parseColor(color),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                  ),
                                                ))
                                            .toList() ??
                                        [Text('-')],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('أضف الكل للسلة'),
                  onPressed: () {
                    // Add all to cart logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text('مسح المقارنة'),
                  onPressed: () {
                    // Clear comparison logic
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildComparisonRow({
    required String title,
    required List<String> values,
    required IconData icon,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Icon(icon, size: 20),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
        ),
        ...values
            .map((value) => DataCell(
                  Text(value, style: TextStyle(fontSize: 14)),
                ))
            .toList(),
      ],
    );
  }

  Color _parseColor(dynamic color) {
    if (color is String) {
      switch (color.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        default:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            "Special Offers",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 180, // زيادة الارتفاع قليلاً
          child: ListView.separated(
            // استخدام ListView.separated بدلاً من builder للتحكم في المسافات
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: specialOffers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final offer = specialOffers[index];
              return GestureDetector(
                // إضافة إمكانية النقر
                onTap: () {
                  // يمكنك إضافة action هنا عند النقر على العرض
                  print('Offer tapped: ${offer["title"]}');
                },
                child: Container(
                  width: 280, // زيادة العرض قليلاً
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(
                        offer["imageUrl"] ?? _getDefaultImageUrl(),
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer["title"] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (offer["subtitle"] !=
                            null) // إضافة subtitle إذا كان متوفراً
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              offer["subtitle"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
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

  String _getDefaultImageUrl() {
    return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBKemhHAH0bkJXGiojbWxjLv--3xbugJJn7A&s';
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
            itemBuilder: (context, index) => Container(
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
          itemBuilder: (context, index) => ProductCard(
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
                      items: [
                        'All',
                        'Electronics',
                        'Clothing',
                        'Household Appliances',
                      ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
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
                        builder: (context) => ProductsScreen(
                          products: products.where((product) {
                            bool matchesPrice = product['price'] >= minPrice &&
                                product['price'] <= maxPrice;
                            bool matchesCategory = selectedCategory == 'All' ||
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
              builder: (context) => ProductDetailScreen(
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
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error),
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
  final List<Map<String, dynamic>> _reviews = [];
  PageController _imageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // إضافة بعض التقييمات الوهمية للعرض
    _reviews.addAll([
      {
        "userName": "Ahmed Mohamed",
        "userImage": "https://randomuser.me/api/portraits/men/1.jpg",
        "rating": 5,
        "text": "Great product! Very satisfied with the quality.",
        "date": DateTime.now().subtract(Duration(days: 2)),
      },
      {
        "userName": "Sara Ali",
        "userImage": "https://randomuser.me/api/portraits/women/1.jpg",
        "rating": 4,
        "text": "Good product but delivery took longer than expected.",
        "date": DateTime.now().subtract(Duration(days: 5)),
      },
    ]);
  }

  @override
  void dispose() {
    _imageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product["name"]),
        actions: [
          IconButton(
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          if (widget.addToComparison != null)
            IconButton(
              icon: Icon(Icons.compare),
              onPressed: _addToCompare,
            ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareProduct,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildProductImages(),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProductHeader(),
                SizedBox(height: 16),
                _buildPriceSection(),
                SizedBox(height: 16),
                _buildRatingSection(),
                SizedBox(height: 16),
                _buildColorSizeSelector(),
                SizedBox(height: 16),
                _buildQuantitySelector(),
                SizedBox(height: 24),
                _buildDescriptionSection(),
                SizedBox(height: 24),
                _buildReviewsSection(),
                SizedBox(height: 24),
                _buildFaqSection(),
                SizedBox(height: 32),
                _buildAddToCartButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImages() {
    final List<String> productImages = [
      widget.product["image"],
      "https://via.placeholder.com/500?text=Product+Image+2",
      "https://via.placeholder.com/500?text=Product+Image+3",
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _imageController,
            itemCount: productImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _showFullScreenImage,
                child: Image.network(
                  productImages[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error, size: 50),
                ),
              );
            },
          ),
        ),
        if (productImages.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                productImages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product["name"],
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.category, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              widget.product["category"],
              style: TextStyle(color: Colors.grey),
            ),
            Spacer(),
            Icon(Icons.inventory, size: 16, color: Colors.green),
            SizedBox(width: 4),
            Text(
              "In Stock",
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Text(
          "\$${widget.product["price"].toString()}",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(width: 16),
        if (widget.product["originalPrice"] != null)
          Text(
            "\$${widget.product["originalPrice"].toString()}",
            style: TextStyle(
              fontSize: 20,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        if (widget.product["discount"] != null)
          Container(
            margin: EdgeInsets.only(left: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "${widget.product["discount"]}% OFF",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final rating = widget.product["rating"] ?? 0;
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 24,
            );
          }),
        ),
        SizedBox(width: 8),
        Text(
          "$rating/5",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Text(
          "(12 reviews)",
          style: TextStyle(color: Colors.grey),
        ),
        Spacer(),
        TextButton(
          onPressed: _rateProduct,
          child: Text("Rate Product"),
        ),
      ],
    );
  }

  Widget _buildColorSizeSelector() {
    return Column(
      children: [
        _buildColorSelector(),
        SizedBox(height: 16),
        _buildSizeSelector(),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colors = ["Red", "Blue", "Green", "Black", "White"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _selectedColor == color
                        ? Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getColorFromString(color),
                    ),
                    child: _selectedColor == color
                        ? Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final sizes = ["S", "M", "L", "XL", "XXL"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Size:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sizes.length,
            itemBuilder: (context, index) {
              final size = sizes[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSize = size;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedSize == size
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    size,
                    style: TextStyle(
                      color:
                          _selectedSize == size ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
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

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          "Quantity:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (_quantity > 1) _quantity--;
                  });
                },
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  _quantity.toString(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.product["details"] ?? "No description available",
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      "High-quality materials",
      "Durable construction",
      "Easy to use",
      "1-year warranty",
      "Free shipping on orders over \$100",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Key Features:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Reviews",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: _showAllReviews,
              child: Text("See All (${_reviews.length})"),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (_reviews.isEmpty)
          Text(
            "No reviews yet. Be the first to review!",
            style: TextStyle(color: Colors.grey),
          )
        else
          Column(
            children: [
              ..._reviews.take(2).map((review) => _buildReviewItem(review)),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: _addReview,
                child: Text("Write a Review"),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(review["userImage"] ??
                    "https://via.placeholder.com/150?text=User"),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review["userName"] ?? "Anonymous",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (review["rating"] as int)
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              Spacer(),
              Text(
                DateFormat('MMM dd, yyyy').format(review["date"] as DateTime),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(review["text"] as String),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    final faqs = [
      {
        "question": "What is the return policy?",
        "answer":
            "You can return this product within 30 days of purchase for a full refund. The product must be in its original condition and packaging.",
      },
      {
        "question": "How long does shipping take?",
        "answer":
            "Standard shipping takes 3-5 business days. Express shipping is available for an additional fee and delivers within 1-2 business days.",
      },
      {
        "question": "Is international shipping available?",
        "answer":
            "Yes, we ship to most countries worldwide. Additional customs fees may apply depending on your country's regulations.",
      },
      {
        "question": "What payment methods do you accept?",
        "answer":
            "We accept all major credit cards (Visa, MasterCard, American Express), PayPal, and bank transfers.",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequently Asked Questions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...faqs.map((faq) => _buildFaqItem(faq)),
      ],
    );
  }

  Widget _buildFaqItem(Map<String, String> faq) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          faq["question"]!,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(faq["answer"]!),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _addToCart,
        child: Text(
          "ADD TO CART - \$${(widget.product["price"] * _quantity).toStringAsFixed(2)}",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "black":
        return Colors.black;
      case "white":
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  void _toggleFavorite() {
    if (widget.isFavorite) {
      widget.removeFromFavorites(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Removed from favorites"),
          action: SnackBarAction(
            label: "UNDO",
            onPressed: () {
              widget.addToFavorites(widget.product);
            },
          ),
        ),
      );
    } else {
      widget.addToFavorites(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to favorites")),
      );
    }
  }

  void _addToCompare() {
    if (widget.addToComparison != null) {
      widget.addToComparison!(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added to comparison")),
      );
    }
  }

  void _shareProduct() {
    Share.share(
      'Check out this amazing product: ${widget.product["name"]} for \$${widget.product["price"]}\n${widget.product["image"]}',
    );
  }

  void _rateProduct() {
    showDialog(
      context: context,
      builder: (context) {
        int tempRating = _userRating;
        final reviewController = TextEditingController();

        return AlertDialog(
          title: Text("Rate this product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < tempRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        tempRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: "Write your review (optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (tempRating > 0) {
                  setState(() {
                    _userRating = tempRating;
                    if (reviewController.text.isNotEmpty) {
                      _reviews.insert(0, {
                        "userName": "You",
                        "userImage": "https://via.placeholder.com/150?text=You",
                        "rating": tempRating,
                        "text": reviewController.text,
                        "date": DateTime.now(),
                      });
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Thanks for your rating!")),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _addReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        int tempRating = 0;
        final reviewController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Write a Review",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < tempRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          tempRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                    hintText: "Share your thoughts about this product...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (tempRating > 0) {
                        setState(() {
                          _reviews.insert(0, {
                            "userName": "You",
                            "userImage":
                                "https://via.placeholder.com/150?text=You",
                            "rating": tempRating,
                            "text": reviewController.text,
                            "date": DateTime.now(),
                          });
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Review submitted!")),
                        );
                      }
                    },
                    child: Text("Submit Review"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllReviews() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("All Reviews"),
        content: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: _reviews.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildReviewItem(_reviews[index]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    final productWithOptions = {
      ...widget.product,
      "selectedColor": _selectedColor,
      "selectedSize": _selectedSize,
      "quantity": _quantity,
    };

    widget.addToCart(productWithOptions);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added to cart successfully!"),
        action: SnackBarAction(
          label: "VIEW CART",
          onPressed: () {
            // يمكنك إضافة التنقل إلى سلة التسوق هنا
          },
        ),
      ),
    );
  }

  void _showFullScreenImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(widget.product["image"]),
            ),
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
      body: favoriteProducts.isEmpty
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
                          builder: (context) => ProductsScreen(
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
                    fit: BoxFit.cover,
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
                        builder: (context) => ProductDetailScreen(
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

  Future<String> _getAddressFromLatLng(LatLng position) async {
    // هنا يتم استدعاء API لتحويل الإحداثيات إلى عنوان
    // مثال باستخدام Google Geocoding API
    try {
      // Implementation here
      return "Address"; // Placeholder return
    } catch (e) {
      return "Error getting address";
    }
  }

  final TextEditingController addressController = TextEditingController();
  String selectedPaymentMethod = 'بطاقة ائتمان';
  LatLng? selectedLocation;

  Future<void> _selectLocationOnMap(BuildContext context) async {
    try {
      final Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location services are disabled')),
          );
          return;
        }
      }

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission == PermissionStatus.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      LocationData locationData = await location.getLocation();
      final LatLng initialPosition = LatLng(
        locationData.latitude ?? 30.0444,
        locationData.longitude ?? 31.2357,
      );

      final LatLng? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapLocationPicker(
            initialPosition: initialPosition,
          ),
        ),
      );

      if (result != null) {
        setState(() {
          selectedLocation = result;
          _getAddressFromLatLng(result).then((address) {
            addressController.text = address;
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child: widget.cartProducts.isEmpty
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
                                builder: (context) => ProductsScreen(
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
                          fit: BoxFit.cover,
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
                              builder: (context) => ProductDetailScreen(
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
    String selectedPaymentMethod = 'credit card';
    LatLng? selectedLocation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "complete order",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "full name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "delivery address",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.map),
                    onPressed: () => _selectLocationOnMap(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectLocationOnMap(context),
              ),
              SizedBox(height: 8),
              Text(
                "click on the map icon to choose the location",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                items: ['credit card', 'paypal', 'cash on delivery']
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedPaymentMethod = value!;
                },
                decoration: InputDecoration(
                  labelText: "payment method",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("total:", style: TextStyle(fontSize: 18)),
                  Text(
                    "${total.toStringAsFixed(2)}",
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
                      'location': selectedLocation?.toJson(),
                    });
                    Navigator.pop(context);
                    _showOrderConfirmation(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("please fill all fields")),
                    );
                  }
                },
                child: Text("confirm order"),
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
      builder: (context) => AlertDialog(
        title: Text("order confirmed!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text("your order has been placed successfully."),
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
            child: Text("back to home"),
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
    final filteredProducts = widget.products.where((product) {
      final matchesSearch = product["name"].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesCategory = _selectedCategory == "All" ||
          product["category"] == _selectedCategory;
      final matchesPrice =
          product["price"] >= _minPrice && product["price"] <= _maxPrice;
      final matchesRating = (product["rating"] ?? 0) >= _minRating;
      return matchesSearch && matchesCategory && matchesPrice && matchesRating;
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
        title: Text("products"),
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
                hintText: "search products...",
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
            child: filteredProducts.isEmpty
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
                    itemBuilder: (context, index) => ProductCard(
                      product: filteredProducts[index],
                      isFavorite: widget.favoriteProducts.any(
                        (p) => p["name"] == filteredProducts[index]["name"],
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
                      items: [
                        'All',
                        'Electronics',
                        'Clothing',
                        'Household Appliances',
                      ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
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
      builder: (context) => AlertDialog(
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

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  File? _profileImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data (replace with actual user data)
    _nameController = TextEditingController(text: "John Doe");
    _emailController = TextEditingController(text: "john.doe@example.com");
    _phoneController = TextEditingController(text: "+1 234 567 890");
    _addressController =
        TextEditingController(text: "123 Main St, City, Country");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  // Save changes logic here
                  setState(() {
                    _isEditing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profile updated successfully")),
                  );
                }
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildProfileDetails(),
              _buildProfileActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : NetworkImage("https://via.placeholder.com/150")
                          as ImageProvider,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.camera_alt, size: 20, color: Colors.blue),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            _isEditing
                ? TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  )
                : Text(
                    _nameController.text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            SizedBox(height: 8),
            _isEditing
                ? TextFormField(
                    controller: _emailController,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  )
                : Text(
                    _emailController.text,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildEditableListTile(
            icon: Icons.phone,
            controller: _phoneController,
            label: "Phone",
            isEditing: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          Divider(),
          _buildEditableListTile(
            icon: Icons.location_on,
            controller: _addressController,
            label: "Address",
            isEditing: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
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

  Widget _buildEditableListTile({
    required IconData icon,
    required TextEditingController controller,
    required String label,
    required bool isEditing,
    required String? Function(String?) validator,
  }) {
    return isEditing
        ? TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(),
              errorText: validator(controller.text) != null
                  ? validator(controller.text)
                  : null,
            ),
            validator: validator,
          )
        : ListTile(
            leading: Icon(icon),
            title: Text(controller.text),
          );
  }

  Widget _buildProfileActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (!_isEditing)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context); // Return to previous screen
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
    "image":
        "https://encrypted-tbn0.gstatc.com/images?q=tbn:ANd9GcQBKemhHAH0bkJXGiojbWxjLv--3xbugJJn7A&s",
  },
  {
    "title": "Free Shipping on Orders Over \$100",
    "image":
        "data:image/jpeg;base64,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",
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
    "name": "SAMSUNG 50 Inch TV Crystal Processor 4K LED",
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
