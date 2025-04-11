import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadJsonToFirestore() async {
  try {
    // Load JSON File from assets
    String jsonString = await rootBundle.loadString('assets/inventory.json');
    print("in upload");
    print(jsonString);

    // Decode JSON
    List<dynamic> jsonData = json.decode(jsonString);

    // Get Firestore Reference
    CollectionReference inventoryRef = FirebaseFirestore.instance.collection('inventory');

    // Upload Each Product
    for (var product in jsonData) {
      await inventoryRef.add(product);
    }

    print("✅ Data uploaded successfully!");
  } catch (e) {
    print("❌ Error uploading JSON: $e");
  }
}
