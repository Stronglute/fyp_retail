import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Clear any existing cache before Firestore is used:
  //await FirebaseFirestore.instance.clearPersistence();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run this once to import JSON data
  //await uploadJsonToFirestore();

  runApp(
    ProviderScope(
      // ✅ This enables Riverpod providers globally
      child: GroceryHubApp(),
    ),
  );
}
