import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadJsonToFirestore() async {
  try {
    // Load JSON File from assets
    String jsonString = await rootBundle.loadString('assets/stores.json');
    print("📤 Uploading Stores Data...");
    print(jsonString);

    // Decode JSON
    List<dynamic> jsonData = json.decode(jsonString);

    // Get Firestore Reference
    CollectionReference storesRef = FirebaseFirestore.instance.collection('stores');

    // Upload Each Store
    for (var store in jsonData) {
      await storesRef.add(store);
    }

    print("✅ Stores uploaded successfully!");
  } catch (e) {
    print("❌ Error uploading JSON: $e");
  }
}
