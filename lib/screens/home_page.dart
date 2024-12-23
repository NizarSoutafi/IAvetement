import 'profile_page.dart';
import 'package:flutter/material.dart';
import 'shop_content.dart';
import 'cart_screen.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? newClothing;

  const HomePage({Key? key, this.newClothing}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _pages = [
    const ShopContent(),
    const CartScreen(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      ShopContent(newClothing: widget.newClothing), // Pass newClothing here
      const CartScreen(),
      const ProfilePage(),
    ];
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex == 2) {
      return null;
    }
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.teal, // Teal AppBar
      title: Text(
        _selectedIndex == 0 ? 'Home Page' : 'Panier',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Acheter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber, // Active item color
        unselectedItemColor: Colors.teal[200], // Inactive item color
        backgroundColor: Colors.teal[50], // BottomNavigationBar background color
        onTap: _onItemTapped,
      ),
    );
  }
}
