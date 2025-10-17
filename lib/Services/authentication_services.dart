import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investmentpro/providers/model_provider.dart';
import 'package:provider/provider.dart';

GetStorage getStorage = GetStorage();
AuthService authService = AuthService();

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _fs = FirebaseFirestore.instance;

  // Signup
  static Future<User?> signUp({
    required String fullname,
    required String email,
    required String password,
    required String phone,
    required String country,
    required String address,
    required context,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      // create user doc
      await _fs.collection('users').doc(user.uid).set({
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'country': country,
        'address': address,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'wallet': '0.0',
        'package': "none",
        "password": password,
      });
      getStorage.write('fullname', fullname);
      Provider.of<ModelProvider>(
        context,
        listen: false,
      ).setuserNameData(userName: getStorage.read('fullname'));
    }
    return user;
  }

  // Login
  static Future<User?> signIn({
    required String email,
    required String password,
    required context,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return null;

      // Fetch user details from Firestore
      await _fs.collection('users').doc(user.uid).get().then((v) {
        var data = v.data();
        getStorage.write('photoUrl', data!['photoUrl']);
        getStorage.write('fullname', data['fullname']);
        Provider.of<ModelProvider>(
          context,
          listen: false,
        ).setuserPhotUrlData(photoUrl: getStorage.read('photoUrl'));
        Provider.of<ModelProvider>(
          context,
          listen: false,
        ).setuserNameData(userName: getStorage.read('fullname'));
      });
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login error',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    final doc = await _fs.collection('users').doc(uid).get();
    if (doc.exists) return doc.data();
    return null;
  }

  static Future<void> updatePhotoUrl(
    String uid,
    String photoUrl,
    context,
  ) async {
    await _fs.collection('users').doc(uid).update({'photoUrl': photoUrl});
    getStorage.write('photoUrl', photoUrl);
    Provider.of<ModelProvider>(
      context,
      listen: false,
    ).setuserPhotUrlData(photoUrl: getStorage.read('photoUrl'));
  }
}
