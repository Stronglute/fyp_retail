import 'package:flutter/material.dart';
import 'package:fyp_retail/screens/cart_screen.dart';
import 'package:fyp_retail/screens/dashboard_screen.dart';
import 'package:fyp_retail/screens/inventory_screen.dart';
import 'package:fyp_retail/screens/order_store_screen.dart';
import 'package:fyp_retail/screens/pos_screen.dart';
import 'package:fyp_retail/screens/orders_screen.dart';
import 'package:fyp_retail/screens/customers_screen.dart';
import 'package:fyp_retail/screens/settings_screen.dart';
import 'package:fyp_retail/screens/store_list_screen.dart';
import 'package:fyp_retail/screens/store_list_screen.dart';
import 'package:fyp_retail/screens/main_screen.dart';
import 'package:fyp_retail/screens/store_screen.dart';
//import 'package:fyp_retail/screens/product_detail_screen.dart';

class AppRouter {
  static const String dashboard = '/dashboard';
  static const String home = '/';
  static const String inventory = '/inventory';
  static const String pos = '/pos';
  static const String orders = '/orders';
  static const String customers = '/customers';
  static const String settings = '/settings';
  static const String storeListing = '/store-listing';
  static const String storeList = '/store-list';
  static const String storeDetails = '/store-details';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String order_customer = '/order-customer';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case pos:
        return MaterialPageRoute(builder: (_) => const POSScreen());
      case orders:
        return MaterialPageRoute(builder: (_) =>  OrdersScreen());
      case customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case home:
        return MaterialPageRoute(builder: (_)=> MainScreen());
      case cart:
        return MaterialPageRoute(builder: (_)=> CartScreen());
      case order_customer:
        return MaterialPageRoute(builder: (_)=> OrderStoreScreen());

    // New Routes
    //   case storeListing:
    //     return MaterialPageRoute(builder: (_) => StoreListScreen());
      case storeList:
        return MaterialPageRoute(builder: (_) => StoreListScreen());
      case storeDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => StoreScreen(
            storeName: args['storeName'] ?? 'Unknown Store',
            storeCategory: args['storeCategory'] ?? 'No Category',
          ),
        );
      // case productDetails:
      //   final args = settings.arguments as Map<String, dynamic>? ?? {};
      //   return MaterialPageRoute(
      //     builder: (_) => ProductDetailScreen(
      //       productName: args['productName'] ?? 'Unknown Product',
      //       productPrice: args['productPrice'] ?? '\$0.00',
      //     ),
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text('404 - Page Not Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('The page you are looking for does not exist.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        );
    }
  }
}
