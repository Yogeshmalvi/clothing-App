import 'package:flutter/material.dart';

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
      if (!_searchFocusNode.hasFocus && _isSearching) {
        setState(() {
          _isSearching = false;

          _searchController.clear();

          _searchText = "";
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    _searchFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        centerTitle: true,

        title: Row(
          children: [
            Expanded(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),

                curve: Curves.easeOutCubic,

                alignment:
                    _isSearching ? Alignment.centerLeft : Alignment.center,

                child: Text(
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

              width: _isSearching ? 8.0 : 0.0,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),

              curve: Curves.easeOutCubic,

              alignment: Alignment.centerRight,

              child:
                  _isSearching
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
          // Search/Cancel Button
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

          // --- NEW: Cart Button ---
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),

            onPressed: () {
              // TODO: Implement navigation to cart page or show cart contents

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart button pressed!')),
              );
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

      body: Center(
        child:
            _searchText.isNotEmpty
                ? Text(
                  'Showing results for: "$_searchText"',

                  style: const TextStyle(fontSize: 20, color: Colors.black),

                  textAlign: TextAlign.center,
                )
                : const Text(
                  'Welcome to PHIL App!',

                  style: TextStyle(fontSize: 20, color: Colors.black),

                  textAlign: TextAlign.center,
                ),
      ),
    );
  }
}
