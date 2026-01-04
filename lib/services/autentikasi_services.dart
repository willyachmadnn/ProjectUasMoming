import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class LayananAutentikasi {
  Future<void> init();
  Future<User?> signInWithUsername(String username, String password);
  Future<User?> signUpWithUsername(
    String username,
    String email,
    String password,
  );
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  bool get isLoggedIn;
  User? get currentUser;
}

class LayananAutentikasiFirebase implements LayananAutentikasi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> init() async {
    // Firebase already initialized in main.dart
  }

  @override
  bool get isLoggedIn => _auth.currentUser != null;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<User?> signInWithUsername(String username, String password) async {
    try {
      String emailToUse = username;

      // Check if input looks like an email
      final bool isEmail = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(username);

      if (!isEmail) {
        // 1. Find email by username
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (result.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Username/Email tidak ditemukan.',
          );
        }

        emailToUse = result.docs.first.get('email') as String;
      }

      // 2. Sign in with email & password
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: emailToUse, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<User?> signUpWithUsername(
    String username,
    String email,
    String password,
  ) async {
    try {
      // Check if username already exists
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw 'Username sudah digunakan. Silakan pilih yang lain.';
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user to Firestore with username
      if (result.user != null) {
        await _saveUserToFirestore(result.user!, username: username);
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // User canceled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // Save user to Firestore
      if (result.user != null) {
        await _saveUserToFirestore(result.user!);
      }

      return result.user;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      throw 'Gagal masuk dengan Google: $e';
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> _saveUserToFirestore(User user, {String? username}) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();

      // Logic Generate Username (Ambil kata pertama dari displayName)
      String generatedUsername =
          username ??
          (user.displayName?.split(" ")[0] ??
              user.email?.split('@')[0] ??
              'User');

      if (!snapshot.exists) {
        // User Baru: Simpan data lengkap + username
        await userDoc.set({
          'email': user.email,
          'displayName': user.displayName ?? user.email?.split('@')[0],
          'username': generatedUsername,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // User Lama: Update lastLogin & Pastikan field username ada
        Map<String, dynamic> updates = {
          'lastLogin': FieldValue.serverTimestamp(),
        };

        // Cek apakah field username sudah ada, jika belum, tambahkan
        if (snapshot.data() != null &&
            !snapshot.data()!.containsKey('username')) {
          updates['username'] = generatedUsername;
        }

        await userDoc.update(updates);
      }
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      // Non-blocking error, just log it
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Pengguna tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
