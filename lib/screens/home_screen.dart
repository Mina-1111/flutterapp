import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Product> products;
  final List<Product> cartProducts;
  final List<Product> favoriteProducts;
  final bool isDarkMode;
  final Function(Product) addToCart;
  final Function(Product) addToComparison;
  final bool isSmallScreen;
  final bool isMediumScreen;

  const HomeScreen({
    required this.products,
    required this.cartProducts,
    required this.favoriteProducts,
    required this.isDarkMode,
    required this.addToCart,
    required this.addToComparison,
    required this.isSmallScreen,
    required this.isMediumScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Featured Products'),
              background: Image.network(
                'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 2 : (isMediumScreen ? 3 : 4),
                childAspectRatio: isSmallScreen ? 0.7 : 0.8,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  final isFavorite = favoriteProducts.contains(product);
                  return ProductCard(
                    product: product,
                    isFavorite: isFavorite,
                    addToFavorites: (p) =>
                        {}, // These will be implemented in MainApp
                    removeFromFavorites: (p) => {},
                    addToCart: addToCart,
                    isDarkMode: isDarkMode,
                    addToComparison: addToComparison,
                    isSmallScreen: isSmallScreen,
                    isMediumScreen: isMediumScreen,
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
