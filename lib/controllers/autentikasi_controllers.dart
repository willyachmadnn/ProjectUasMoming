import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_links/app_links.dart';
import '../services/autentikasi_services.dart';
import '../views/widgets/snackbar_kustom.dart';

// Import View Ubah Password
import '../views/autentikasi/ubah_password_views.dart';

import '../controllers/beranda_controllers.dart';
import '../controllers/transaksi_controllers.dart';
import '../controllers/jadwal_pembayaran_controllers.dart';
// Jika Anda punya controller tabungan, sebaiknya import juga, atau biarkan kode cleanup generik
// import '../controllers/tabungan_controllers.dart';

class KontrolerAutentikasi extends GetxController {
  final LayananAutentikasi _authService;
  final _appLinks = AppLinks();
  final _box = GetStorage();

  KontrolerAutentikasi(this._authService);

  final RxBool isLoggedIn = false.obs;
  final RxString userName = 'User'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isRegisterPasswordVisible = false.obs;
  final RxBool isRememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    _initDeepLinkListener();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    isRememberMe.value = _box.read('remember_me') ?? false;
  }

  Map<String, String> getSavedCredentials() {
    if (_box.read('remember_me') == true) {
      return {
        'username': _box.read('username') ?? '',
        'password': _box.read('password') ?? '',
      };
    }
    return {'username': '', 'password': ''};
  }

  // --- LOGIKA MENANGKAP LINK (DEEP LINK LISTENER) ---
  void _initDeepLinkListener() {
    // 1. Tangkap link saat aplikasi dibuka dari mati
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });

    // 2. Tangkap link saat aplikasi berjalan di background
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    print("Link Diterima: $uri");

    final mode = uri.queryParameters['mode'];
    final oobCode = uri.queryParameters['oobCode'];

    if (mode == 'resetPassword' && oobCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Tutup dialog atau bottom sheet jika sedang terbuka agar tidak menumpuk
        if (Get.isDialogOpen ?? false) Get.back();
        if (Get.isBottomSheetOpen ?? false) Get.back();

        // Navigasi ke halaman ubah password
        Get.to(() => TampilanUbahPassword(oobCode: oobCode));
      });
    }
  }
  // ----------------------------------------------------

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.toggle();
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.toggle();
  }

  void checkLoginStatus() {
    isLoggedIn.value = _authService.isLoggedIn;
    if (isLoggedIn.value) {
      final user = _authService.currentUser;
      userName.value =
          user?.displayName?.split(' ')[0] ??
          user?.email?.split('@')[0] ??
          'User';
    }
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      SnackbarKustom.error(
        'Login Gagal',
        'Username dan password tidak boleh kosong',
      );
      return;
    }
    try {
      isLoading.value = true;
      await _authService.signInWithUsername(username, password);

      // Simpan kredensial jika Remember Me dicentang
      if (isRememberMe.value) {
        _box.write('remember_me', true);
        _box.write('username', username);
        _box.write('password', password);
      } else {
        _box.remove('remember_me');
        _box.remove('username');
        _box.remove('password');
      }

      _onAuthSuccess();
      SnackbarKustom.sukses('Login Berhasil', 'Selamat datang kembali!');
    } catch (e) {
      SnackbarKustom.error('Login Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      SnackbarKustom.error('Register Gagal', 'Semua kolom harus diisi');
      return;
    }
    try {
      isLoading.value = true;
      await _authService.signUpWithUsername(username, email, password);
      SnackbarKustom.sukses(
        'Registrasi Berhasil',
        'Akun Anda telah berhasil dibuat. Silakan login.',
      );
      // Pastikan '/login' sesuai dengan yang ada di main.dart
      Get.offNamed('/login', arguments: {'username': username});
    } catch (e) {
      SnackbarKustom.error('Registrasi Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _onAuthSuccess();
        SnackbarKustom.sukses('Login Berhasil', 'Masuk dengan Google berhasil');
      }
    } catch (e) {
      SnackbarKustom.error('Login Google Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- FITUR RESET PASSWORD (Kirim Link) ---
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      SnackbarKustom.error('Gagal', 'Email tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;

      var actionCodeSettings = ActionCodeSettings(
        url: 'https://financial-app-af0b6.firebaseapp.com/?email=$email',
        handleCodeInApp: true,
        androidPackageName: 'com.example.financial',
        androidInstallApp: true,
        androidMinimumVersion: '12',
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      Get.back();

      SnackbarKustom.sukses(
        'Link Terkirim',
        'Cek email Anda. Klik link untuk mereset password di dalam aplikasi.',
      );
    } catch (e) {
      SnackbarKustom.error('Gagal Kirim Link', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- FITUR KONFIRMASI PASSWORD BARU ---
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      isLoading.value = true;
      await FirebaseAuth.instance.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );

      isLoading.value = false;

      // Navigasi balik ke Login dan hapus semua history
      Get.offAllNamed('/login');

      SnackbarKustom.sukses(
        "Sukses",
        "Password berhasil diubah. Silakan login.",
      );
    } catch (e) {
      isLoading.value = false;
      SnackbarKustom.error("Gagal", "Link kadaluarsa atau error: $e");
    }
  }

  // --- FIX LOGOUT (ANTI MACET) ---
  Future<void> logout() async {
    // 1. Coba Sign Out Firebase
    // Kita bungkus try-catch agar jika gagal, kode bawah tetap jalan
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint("Error Firebase SignOut: $e");
    }

    // 2. Bersihkan Controller dari Memori
    // Bungkus try-catch agar jika ada error "Null check operator" di controller lain,
    // proses logout TIDAK BERHENTI.
    try {
      if (Get.isRegistered<KontrolerBeranda>())
        Get.delete<KontrolerBeranda>(force: true);
      if (Get.isRegistered<KontrolerTransaksi>())
        Get.delete<KontrolerTransaksi>(force: true);
      if (Get.isRegistered<KontrolerJadwalPembayaran>())
        Get.delete<KontrolerJadwalPembayaran>(force: true);

      // Hapus controller tabungan juga jika ada (tanpa perlu import file)
      // Menggunakan delete generic untuk safety
      Get.delete(tag: 'KontrolerTabungan', force: true);
    } catch (e) {
      debugPrint("Error Cleanup Controller: $e");
    }

    // 3. BAGIAN WAJIB: Reset State & Navigasi
    // Kode ini ditaruh DI LUAR try-catch manapun untuk menjamin eksekusi.

    isLoggedIn.value = false;
    userName.value = 'User';

    // Pastikan nama route ini '/login' sesuai dengan main.dart Anda
    Get.offAllNamed('/login');

    SnackbarKustom.info('Logout', 'Anda telah keluar dari aplikasi');
  }

  void _onAuthSuccess() {
    checkLoginStatus();
    Get.offAllNamed('/dashboard');
  }
}
