import 'package:flutter/material.dart';
import 'package:fyp_retail/app_router.dart';

class POSDrawer extends StatelessWidget {
  const POSDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text('POS System', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),

          // Back to Home Item
          _buildDrawerItem(context, 'Back to Home', AppRouter.home, icon: Icons.home),

          Divider(),

          _buildDrawerItem(context, 'Dashboard', AppRouter.dashboard, icon: Icons.dashboard),
          _buildDrawerItem(context, 'Inventory', AppRouter.inventory, icon: Icons.inventory),
          _buildDrawerItem(context, 'POS', AppRouter.pos, icon: Icons.point_of_sale),
          _buildDrawerItem(context, 'Orders', AppRouter.orders, icon: Icons.shopping_cart),
          _buildDrawerItem(context, 'Customers', AppRouter.customers, icon: Icons.people),
          _buildDrawerItem(context, 'Settings', AppRouter.settings, icon: Icons.settings),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String routeName, {IconData? icon}) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.green) : null,
      title: Text(title),
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
      },
    );
  }
}

