import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import 'package:custom_navigation_bar/custom_navigation_bar.dart';

import 'cart.dart'; // Import the CartPageContent from cart.dart
import 'explore.dart'; // Import the new ExplorePageContent
import 'profile.dart'; // <--- ADD THIS IMPORT for ProfilePageContent

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PHIL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: Colors.blueAccent,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  final FocusNode _searchFocusNode = FocusNode();

  final PageController _mainPageController = PageController(initialPage: 0);

  final PageController _imageSliderPageController =
  PageController(initialPage: 0);
  int _currentImageSliderIndex = 0;

  Timer? _sliderTimer; // Declare the Timer for auto-sliding

  int _selectedIndex = 0; // 0: Home, 1: Cart, 2: Explore, 3: Me

  // For CustomNavigationBar badges - Adjusted for 4 items (Home, Cart, Explore, Me)
  final List<int> _badgeCounts = [0, 0, 0, 0];
  final List<bool> _badgeShows = [false, false, false, false];

  final List<String> _bannerImages = [
    'assets/image/banner.jpg',
    'assets/image/banner.jpg',
    'assets/image/banner.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        print("Search text: $_searchText");
      });
    });

    _searchFocusNode.addListener(() {
      // Only set _isSearching to false if we lose focus and are currently searching,
      // and we are on the explore page. This prevents it from closing if you navigate away.
      if (!_searchFocusNode.hasFocus && _isSearching && _selectedIndex == 2) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
          _searchText = "";
        });
      }
    });

    // Listener for manual page changes on the image slider
    _imageSliderPageController.addListener(() {
      int nextIndex = _imageSliderPageController.page?.round() ?? 0;
      if (_currentImageSliderIndex != nextIndex) {
        setState(() {
          _currentImageSliderIndex = nextIndex;
        });
      }
    });

    // Initialize the slider timer for automatic sliding
    _sliderTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        timer.cancel(); // Stop the timer if the widget is not mounted
        return;
      }
      if (_imageSliderPageController.hasClients) {
        int nextPage = (_currentImageSliderIndex + 1) % _bannerImages.length;
        _imageSliderPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeIn,
        );
      }
    });

    // Example: Update badge counts or show badges after some time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _badgeCounts[1] = 5; // Example: 5 items in cart (index 1 for cart)
          _badgeShows[1] = true;
          _badgeCounts[2] = 2; // Example: 2 new explores (index 2 for explore)
          _badgeShows[2] = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mainPageController.dispose();
    _imageSliderPageController.dispose();
    _sliderTimer?.cancel(); // **CRUCIAL: Cancel the timer to prevent memory leaks**
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Use animateToPage for a smoother transition
      _mainPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // If we navigate away from Explore, close search and clear text
      if (index != 2) {
        _isSearching = false;
        _searchController.clear();
        _searchText = "";
        _searchFocusNode.unfocus();
      }

      switch (index) {
        case 0:
          print('Home tapped');
          break;
        case 1:
          print('Cart tapped');
          break;
        case 2:
          print('Explore tapped');
          break;
        case 3: // This is now "Me"
          print('Me tapped');
          break;
      }
    });
  }

  Widget _buildProductCard({
    required String imagePath,
    required String title,
    String subtitle = '',
    Color backgroundColor = Colors.white,
    double height = 200,
    double width = double.infinity,
    BoxFit fit = BoxFit.cover,
    bool showShopNow = false,
    bool showRating = false,
    String? ratingText,
  }) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, color: Colors.red, size: 40),
                      Text(
                        'Error loading: \n$imagePath',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  if (showRating && ratingText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          ratingText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (showShopNow)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          print('Shop Now for $title tapped!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        ),
                        child: const Text('SHOP NOW'),
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

  @override
  Widget build(BuildContext context) {
    // Determine if the search bar should be visible based on the selected index
    final bool showSearchBar = _selectedIndex == 2; // Only for Explore page

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false, // Set to false to allow Expanded/Align to control
        title: Row(
          children: [
            // Always align 'PHIL' to the left, unless actively searching on the explore page
            Expanded(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: (_isSearching && showSearchBar)
                    ? Alignment.centerLeft // Align left when searching on explore
                    : Alignment.centerLeft, // Always align left otherwise
                child: const Text(
                  'PHIL',
                  style: TextStyle(
                    fontFamily: 'Mycoustomfont',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              // Only show the padding if searching AND on the Explore page
              width: (_isSearching && showSearchBar) ? 8.0 : 0.0,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerRight,
              child: (_isSearching && showSearchBar)
                  ? Container(
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  cursorColor: Colors.black,
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          // Only show search actions if on the Explore page
          if (showSearchBar)
            _isSearching
                ? IconButton(
              icon: const Icon(Icons.cancel, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchText = "";
                  _searchFocusNode.unfocus();
                });
              },
            )
                : IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                  _searchFocusNode.requestFocus();
                });
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            Padding(padding: EdgeInsets.zero),
            DrawerHeader(
              child: Center(
                child: Text(
                  'PHIL',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: PageView(
        controller: _mainPageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            // When page changes, if not on explore, reset search state
            if (index != 2) {
              _isSearching = false;
              _searchController.clear();
              _searchText = "";
              _searchFocusNode.unfocus();
            }
          });
        },
        children: [
          // Page 0: Home Page Content
          SingleChildScrollView(
            child: Column(
              children: [
                if (_searchText.isNotEmpty && _selectedIndex == 0)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Showing results for: "$_searchText"',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(0.05)
                            ..rotateY(0.05),
                          child: Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 15,
                                  offset: const Offset(5, 5),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: PageView.builder(
                                controller: _imageSliderPageController,
                                itemCount: _bannerImages.length,
                                itemBuilder: (context, index) {
                                  return Image.asset(
                                    _bannerImages[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          'Error loading image: ${_bannerImages[index]}\nPlease check asset path and pubspec.yaml',
                                          textAlign: TextAlign.center,
                                          style:
                                          const TextStyle(color: Colors.red),
                                        ),
                                      );
                                    },
                                  );
                                },
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageSliderIndex = index;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_bannerImages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8.0,
                            width:
                            _currentImageSliderIndex == index ? 24.0 : 8.0,
                            decoration: BoxDecoration(
                              color: _currentImageSliderIndex == index
                                  ? Colors.blueAccent
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildProductCard(
                            imagePath: 'assets/image/banner.jpg',
                            title: 'Sleeveless Tees',
                            subtitle: 'Nanna Me For Mank',
                            height: 220,
                            showShopNow: true,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildProductCard(
                            imagePath: 'assets/image/banner.jpg',
                            title: 'Henley Neck T-shirt',
                            subtitle: '₹999 ₹272 | Rs. 727 OFF',
                            height: 200,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildProductCard(
                            imagePath: 'assets/image/banner.jpg',
                            title: 'Socks',
                            subtitle: 'Multi-pack options',
                            height: 220,
                            showRating: true,
                            ratingText: '4 ⭐ 211',
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildProductCard(
                            imagePath: 'assets/image/banner.jpg',
                            title: 'Loafers',
                            subtitle: 'Classic Footwear',
                            height: 220,
                            showShopNow: true,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            print('Explore More Products button tapped!');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Explore More Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Page 1: Cart Page Content
          const CartPageContent(),
          // Page 2: Explore Page Content - Pass the search query here
          ExplorePageContent(searchQuery: _searchText),
          // Page 3: Me Page Content (Profile) - THIS IS THE CHANGE
          const ProfilePageContent(), // <--- CHANGE THIS LINE
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        iconSize: 30.0,
        selectedColor: const Color(0xff040307),
        strokeColor: const Color(0x30040307),
        unSelectedColor: const Color(0xffacacac),
        backgroundColor: Colors.white,
        items: [
          CustomNavigationBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
          ),
          CustomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            title: const Text("Cart"),
            badgeCount: _badgeCounts[1],
            showBadge: _badgeShows[1],
          ),
          CustomNavigationBarItem(
            icon: const Icon(Icons.lightbulb_outline),
            title: const Text("Explore"),
            badgeCount: _badgeCounts[2],
            showBadge: _badgeShows[2],
          ),
          CustomNavigationBarItem(
            icon: const Icon(Icons.account_circle),
            title: const Text("Me"),
            badgeCount:
            _badgeCounts[3],
            showBadge:
            _badgeShows[3],
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
    );
  }
}