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
  }

  @override
  bool get isLoggedIn => _auth.currentUser != null;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<User?> signInWithUsername(String username, String password) async {
    try {
      String emailToUse = username;

      final bool isEmail = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(username);

      if (!isEmail) {
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

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

      String generatedUsername =
          username ??
          (user.displayName?.split(" ")[0] ??
              user.email?.split('@')[0] ??
              'User');

      if (!snapshot.exists) {
        await userDoc.set({
          'email': user.email,
          'displayName': user.displayName ?? user.email?.split('@')[0],
          'username': generatedUsername,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        Map<String, dynamic> updates = {
          'lastLogin': FieldValue.serverTimestamp(),
        };
        if (snapshot.data() != null &&
            !snapshot.data()!.containsKey('username')) {
          updates['username'] = generatedUsername;
        }

        await userDoc.update(updates);
      }
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
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
