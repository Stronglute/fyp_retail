import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'app_router.dart';

// class POSApp extends StatelessWidget {
//   const POSApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: ThemeMode.dark,
//       initialRoute: AppRouter.dashboard,
//       onGenerateRoute: AppRouter.generateRoute,
//       home: StoreListingPage(),
//     );
//   }
// }

class GroceryHubApp extends StatelessWidget {
  const GroceryHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
      //home: MainScreen(),
    );
  }
}
