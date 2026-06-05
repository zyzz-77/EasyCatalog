import 'package:flutter/material.dart';
import 'package:easycatalog/utils/auth_service.dart';
import 'package:easycatalog/utils/api_service.dart';
import 'package:easycatalog/utils/order_service.dart';
import 'package:easycatalog/utils/app_theme.dart';
import 'package:easycatalog/screens/login_screen.dart';
import 'package:easycatalog/screens/beranda_screen.dart';
import 'package:easycatalog/screens/history_screen.dart';
import 'package:easycatalog/screens/menu_screen.dart';
import 'package:easycatalog/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final _auth = AuthService();
  final _api = ApiService();
  final _orderService = OrderService();

  Map<String, dynamic>? _restaurant;
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final resRes = await _api.getMyRestaurant();
      final userRes = await _api.getProfile();
      setState(() {
        if (resRes['status'] == 200) _restaurant = resRes['body']['restaurant'];
        if (userRes['status'] == 200) _user = userRes['body']['user'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Anda akan keluar dari EasyCatalog.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await _auth.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final newOrderCount = _orderService.newOrderCount;

    final screens = [
      BerandaScreen(
        restaurant: _restaurant,
        user: _user,
        onRefresh: _fetchData,
        onOrderChanged: () => setState(() {}),
      ),
      const HistoryScreen(),
      MenuScreen(restaurant: _restaurant, onUpdate: _fetchData),
      ProfileScreen(
        user: _user,
        restaurant: _restaurant,
        onLogout: _logout,
        onRestaurantUpdated: _fetchData,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          if (i == 0) _orderService.clearBadge();
          setState(() => _currentIndex = i);
        },
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: newOrderCount > 0,
              label: Text('$newOrderCount'),
              child: const Icon(Icons.home_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: newOrderCount > 0,
              label: Text('$newOrderCount'),
              child: const Icon(Icons.home_rounded, color: AppTheme.primary),
            ),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded, color: AppTheme.primary),
            label: 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: AppTheme.primary),
            label: 'Menu',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
