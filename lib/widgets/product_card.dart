import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final Function(Product) addToFavorites;
  final Function(Product) removeFromFavorites;
  final Function(Product) addToCart;
  final bool isDarkMode;
  final Function(Product)? addToComparison;
  final bool isSmallScreen;
  final bool isMediumScreen;

  const ProductCard({
    required this.product,
    required this.isFavorite,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.addToCart,
    required this.isDarkMode,
    this.addToComparison,
    required this.isSmallScreen,
    required this.isMediumScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              height: isSmallScreen
                  ? 120
                  : isMediumScreen
                      ? 140
                      : 160,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (product.originalPrice != null)
                  Text(
                    '\$${product.originalPrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                if (product.discount != null)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.discount}% OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          removeFromFavorites(product);
                        } else {
                          addToFavorites(product);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () => addToCart(product),
                    ),
                    if (addToComparison != null)
                      IconButton(
                        icon: Icon(Icons.compare_arrows),
                        onPressed: () => addToComparison!(product),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
