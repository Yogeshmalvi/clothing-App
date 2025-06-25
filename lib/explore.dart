import 'package:flutter/material.dart';
import 'dart:convert'; // Required for JSON decoding
import 'package:http/http.dart' as http; // Required for making HTTP requests
import 'package:provider/provider.dart';
// Import the provider
import 'cart_provider.dart';
import 'models/product.dart'; // Adjust path as needed



// Product Card Widget for displaying products in the grid
class ExploreProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap; // To handle tap on product card

  const ExploreProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8, // Increased elevation for more prominent shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // More rounded corners
        ),
        clipBehavior: Clip.antiAlias, // Ensures content is clipped to rounded corners
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero( // Added Hero for potential future animation
                tag: 'product-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17, // Slightly larger font
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Corrected from TextAxisAlignment.ellipsis
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.indigo[700],
                      fontSize: 15,
                      fontWeight: FontWeight.w700, // Bolder price
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Display a user-friendly category name
                    product.category == "men's clothing" ? "Men's Clothing" :
                    product.category == "women's clothing" ? "Women's Clothing" :
                    product.category, // Fallback for other categories if any
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
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


class ExplorePageContent extends StatefulWidget {
  // Add a searchQuery property
  final String searchQuery;

  const ExplorePageContent({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  State<ExplorePageContent> createState() => _ExplorePageContentState();
}

class _ExplorePageContentState extends State<ExplorePageContent> {
  String _selectedCategory = 'All';
  List<Product> _apiProducts = []; // To store products fetched from the API
  List<String> _categories = ['All']; // Initial categories, 'All' is always present
  bool _isLoading = true; // To manage loading state
  String _errorMessage = ''; // To store error messages

  @override
  void initState() {
    super.initState();
    _fetchProductsAndCategories(); // Fetch products and categories when the widget initializes
  }

  Future<void> _fetchProductsAndCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch products
      final productResponse = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (productResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(productResponse.body);
        _apiProducts = data
            .map((json) => Product.fromJson(json))
            .where((product) =>
        product.category == "men's clothing" ||
            product.category == "women's clothing")
            .toList();
      } else {
        _errorMessage = 'Failed to load products: ${productResponse.statusCode}';
      }

      // Fetch categories (and filter for clothing-related ones)
      final categoryResponse = await http.get(Uri.parse('https://fakestoreapi.com/products/categories'));
      if (categoryResponse.statusCode == 200) {
        final List<dynamic> fetchedCategories = json.decode(categoryResponse.body);
        // Filter categories to only include clothing-related ones
        final List<String> clothingCategories = fetchedCategories
            .where((category) =>
        category == "men's clothing" ||
            category == "women's clothing")
            .cast<String>()
            .toList();

        setState(() {
          _categories = ['All', ...clothingCategories]; // Add 'All' to the front
        });

      } else {
        _errorMessage = 'Failed to load categories: ${categoryResponse.statusCode}';
      }

    } catch (e) {
      _errorMessage = 'Error fetching data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Modified getter to include search filtering and only clothing items
  List<Product> get _filteredProducts {
    List<Product> products = _apiProducts.where((product) {
      final bool matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      return matchesCategory;
    }).toList();

    // Apply search query filter if it's not empty
    if (widget.searchQuery.isNotEmpty) {
      products = products.where((product) {
        final queryLower = widget.searchQuery.toLowerCase();
        return product.name.toLowerCase().contains(queryLower) ||
            product.category.toLowerCase().contains(queryLower);
      }).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display search results text if there's a query
            if (widget.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Showing results for "${widget.searchQuery}"',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),

            // Categories Section (only show if no search query, or adjust logic if categories should also filter search results)
            if (widget.searchQuery.isEmpty) ...[
              Text(
                'Browse Clothing Categories',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            category == "men's clothing" ? "Men's Clothing" :
                            category == "women's clothing" ? "Women's Clothing" :
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blueGrey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.indigo,
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.indigo : Colors.grey[300]!,
                              width: 1.2,
                            ),
                          ),
                          elevation: isSelected ? 4 : 1,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],

            // Products Grid
            Text(
              'Recommended Clothing for You',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 15),
            _isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                : _errorMessage.isNotEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Error: $_errorMessage\nPlease try again later.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ],
                ),
              ),
            )
                : _filteredProducts.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  widget.searchQuery.isEmpty
                      ? 'No clothing items found matching your criteria. Try adjusting filters!'
                      : 'No clothing items found for "${widget.searchQuery}" matching current filters. Try adjusting your search or filters.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.75,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ExploreProductCard(
                  product: product,
                  onTap: () {
                    // Navigate to ProductViewPage when the card is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductViewPage(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// New ProductViewPage Widget
class ProductViewPage extends StatelessWidget {
  final Product product;

  const ProductViewPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Now takes a responsive height and has rounded corners
            ClipRRect( // Added ClipRRect for rounded corners
              borderRadius: BorderRadius.circular(16.0), // Apply rounded corners
              child: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.45, // Responsive height (45% of screen height)
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Product Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.indigo[700],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Product Category
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        product.category == "men's clothing" ? "Men's Clothing" :
                        product.category == "women's clothing" ? "Women's Clothing" :
                        product.category,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Product Description
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 30),
                  // Buy Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add product to cart using the provider
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        cartProvider.addToCart(product);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product was added'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },


                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Buy Now', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo, // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
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
