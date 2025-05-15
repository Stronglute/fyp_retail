import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fyp_retail/app_router.dart';
import 'package:fyp_retail/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
        iconTheme: IconThemeData(color: Colors.green.shade800),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                const SizedBox(height: 8),
                _buildUserCard(
                  currentUser?.name ?? 'Guest User',
                  currentUser?.email ?? 'guest@example.com',
                ),
                const SizedBox(height: 24),
                _buildSettingsItem(
                  icon: Icons.person_outline,
                  title: "Profile",
                  onTap: () {},
                  delay: 100,
                ),
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: "Notifications",
                  isSwitch: true,
                  delay: 150,
                ),
                _buildSettingsItem(
                  icon: Icons.lock_outline,
                  title: "Privacy & Security",
                  onTap: () {},
                  delay: 200,
                ),
                _buildSettingsItem(
                  icon: Icons.handshake_outlined,
                  title: "Seller Negotiations",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/negotiation-seller',
                      arguments: {'storeId': 'storeId'},
                    );
                  },
                  delay: 250,
                ),
                _buildSettingsItem(
                  icon: Icons.shopping_cart_outlined,
                  title: "Cart",
                  onTap: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                  delay: 300,
                ),
                _buildSettingsItem(
                  icon: Icons.history_outlined,
                  title: "Order History",
                  onTap: () {
                    Navigator.pushNamed(context, '/order-history');
                  },
                  delay: 350,
                ),
                _buildSettingsItem(
                  icon: Icons.store_outlined,
                  title: "Add Store",
                  onTap: () {
                    Navigator.pushNamed(context, '/addstore');
                  },
                  delay: 400,
                ),
                _buildSettingsItem(
                  icon: Icons.help_outline,
                  title: "Negotiation Help",
                  onTap: () {
                    if (currentUser == null) return;
                    Navigator.pushNamed(
                      context,
                      AppRouter.customernegotiation,
                      arguments: {'buyerId': currentUser.email},
                    );
                  },
                  delay: 450,
                ),
                const SizedBox(height: 24),
                _buildSettingsItem(
                  icon: Icons.exit_to_app,
                  title: "Logout",
                  color: Colors.red,
                  onTap: () {
                    _showLogoutDialog(context, ref);
                  },
                  delay: 500,
                ),
              ],
            ),
          ),
          // POS Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.pos);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: Colors.green.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "POS System",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(String name, String email) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.shade100,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, color: Colors.green.shade800),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    bool isSwitch = false,
    Color color = Colors.green,
    VoidCallback? onTap,
    required int delay,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color == Colors.red ? Colors.red : Colors.grey.shade800,
            ),
          ),
          trailing:
              isSwitch
                  ? Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Colors.green.shade800,
                  )
                  : Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        Divider(height: 1, color: Colors.grey.shade200, indent: 56),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade800,
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).logout();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Logged out successfully'),
                                backgroundColor: Colors.green.shade800,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
