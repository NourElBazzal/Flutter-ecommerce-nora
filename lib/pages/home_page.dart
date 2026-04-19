import 'package:flutter/material.dart';
import '../modeles/user.dart';
import 'clothes_list_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    _fadeController.reset();
    setState(() => _currentIndex = index);
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ClothesListPage(user: widget.user),
      CartPage(user: widget.user),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Logo in AppBar
        title: Image.asset(
          'assets/images/logo.png',
          height: 65,
          fit: BoxFit.contain,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF0F0F0),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFF0F0F0)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded, size: 24),
              activeIcon: Icon(Icons.grid_view_rounded,
                  size: 24, color: Color(0xFF1A1A1A)),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined, size: 24),
              activeIcon:
                  Icon(Icons.shopping_bag, size: 24, color: Color(0xFF1A1A1A)),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon:
                  Icon(Icons.person, size: 24, color: Color(0xFF1A1A1A)),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}
