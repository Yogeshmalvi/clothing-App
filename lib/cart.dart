import 'package:flutter/material.dart';

// Product Model
class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

// Cart Item Model
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Calculate total price for this cart item
  double get total => product.price * quantity;
}

// Widget for displaying a single product in the product list
// (This class is kept as it might be used elsewhere or for future additions)
class ProductCard extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.indigo),
                    onPressed: () => onAddToCart(product),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying a single item in the cart
class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int, int) onUpdateQuantity;
  final Function(int) onRemove;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('\$${item.product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (item.quantity > 1) {
                            onUpdateQuantity(item.product.id, item.quantity - 1);
                          } else {
                            onRemove(item.product.id);
                          }
                        },
                      ),
                      Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => onUpdateQuantity(item.product.id, item.quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '\$${item.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemove(item.product.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Main Cart Page Content Widget
class CartPageContent extends StatefulWidget {
  const CartPageContent({Key? key}) : super(key: key);

  @override
  State<CartPageContent> createState() => _CartPageContentState();
}

class _CartPageContentState extends State<CartPageContent> {
  // List of items currently in the cart
  final List<CartItem> _cartItems = [];
  // No longer need a list of available products since suggestions are removed

  // Calculate the total price of all items in the cart
  double get _totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  // NOTE: _addToCart functionality is removed from here as there are no product suggestions
  // to add items from. Items would typically be added to the cart from other pages (e.g., product detail pages).

  // Remove an item from the cart
  void _removeFromCart(int productIdToRemove) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: const Text('Are you sure you want to remove this item from your cart?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  _cartItems.removeWhere((item) => item.product.id == productIdToRemove);
                });
                Navigator.of(context).pop(); // Dismiss the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item removed from cart.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Update the quantity of a specific cart item
  void _updateQuantity(int productIdToUpdate, int newQuantity) {
    setState(() {
      final itemIndex = _cartItems.indexWhere((item) => item.product.id == productIdToUpdate);
      if (itemIndex != -1) {
        // Ensure quantity is at least 1
        _cartItems[itemIndex].quantity = newQuantity > 0 ? newQuantity : 1;
      }
    });
  }

  // Handle checkout process
  void _handleCheckout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty. Nothing to checkout!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout Complete!'),
          content: Text('Your order for \$${_totalPrice.toStringAsFixed(2)} has been placed.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _cartItems.clear(); // Clear cart after checkout
                });
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
    // In a real app, you would send this to a payment gateway or backend.
    print('Proceeding to checkout with items: ${_cartItems.map((e) => '${e.product.name} x ${e.quantity}').join(', ')}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Allows content to scroll if it exceeds screen height
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed the "Products" section including the Text and GridView.builder
          // that displayed product suggestions.

          // Your Cart Section
          Text(
            'Your Cart',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          const SizedBox(height: 16),
          _cartItems.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                'Your cart is empty. Add some products!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: CartItemWidget(
                  item: item,
                  onUpdateQuantity: _updateQuantity,
                  onRemove: _removeFromCart,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          if (_cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '\$${_totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _handleCheckout,
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
