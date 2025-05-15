import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Alias firebase_auth
import '../models/user.dart'; // Import your custom User model
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthNotifier extends StateNotifier<User?> {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthNotifier() : super(null) {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      state = User.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> _removeUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  void setUser(User user) {
    state = user;
    _saveUserToPrefs(user);
  }

  void logout() async {
    await _firebaseAuth.signOut();
    state = null;
    await _removeUserFromPrefs();
  }

  Future<void> login(String email, String password) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = cred.user!;
    final data =
        (await _firestore.collection('users').doc(fbUser.uid).get()).data()!;
    print(data);
    final user = User(
      id: fbUser.uid,
      name: data['name'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      address: data['address'] as String,
      city: data['city'] as String,
      country: data['country'] as String,
      phoneNumber: data['phoneNumber'] as String, // ← new
    );
    state = user;
    await _saveUserToPrefs(user);
  }

  Future<void> signup(
    String name,
    String email,
    String password,
    String role,
    String address,
    String city,
    String country,
    String phoneNumber, // ← new
  ) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);

    await _firestore.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
      'address': address,
      'city': city,
      'country': country,
      'phoneNumber': phoneNumber, // ← new
    });

    final user = User(
      id: cred.user!.uid,
      name: name,
      email: email,
      role: role,
      address: address,
      city: city,
      country: country,
      phoneNumber: phoneNumber, // ← new
    );
    state = user;
    await _saveUserToPrefs(user);
  }
}
// Remove extra closing brace as it's redundant

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider);
});
