import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'provider/cart_provider.dart';
import 'provider/order_provider.dart';
import 'provider/product_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'provider/wishlist_provider.dart';
import 'provider/category_provider.dart';
import 'provider/payment_provider.dart';
import 'provider/admin_product_provider.dart';
import 'provider/admin_order_provider.dart';
import 'provider/admin_dashboard_provider.dart';

void main() {
  runApp(const GiaDungShopApp());
}

class GiaDungShopApp extends StatelessWidget {
  const GiaDungShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
      ],
      child: const _AppLoader(),
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<AuthProvider>().loadUserFromStorage();
      setState(() => isReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!isReady) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gia Dụng Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: auth.isLoggedIn
          ? const MainNavigationScreen()
          : const LoginScreen(),
    );
  }
}