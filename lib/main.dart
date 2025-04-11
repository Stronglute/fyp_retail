
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fyp_retail/services/product_repository.dart';
///import 'package:fyp_retail/utils//upload_service.dart';
import 'package:fyp_retail/utils/addinventory.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run this once to import JSON data
  //await uploadJsonToFirestore();

  runApp(
    ProviderScope( // ✅ This enables Riverpod providers globally
        child: GroceryHubApp(),
    ),
  );
}