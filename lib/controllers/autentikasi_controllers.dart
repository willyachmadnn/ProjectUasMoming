import 'package:get/get.dart';
import '../services/autentikasi_services.dart';
import '../views/widgets/snackbar_kustom.dart';

import '../controllers/beranda_controllers.dart';
import '../controllers/transaksi_controllers.dart';
import '../controllers/jadwal_pembayaran_controllers.dart';

class KontrolerAutentikasi extends GetxController {
  final LayananAutentikasi _authService;

  KontrolerAutentikasi(this._authService);

  final RxBool isLoggedIn = false.obs;
  final RxString userName = 'User'.obs;
  final RxBool isLoading = false.obs;

  // State untuk visibility password
  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isRegisterPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

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
      // Ambil nama depan saja (split spasi pertama)
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
      // _onAuthSuccess(); // Don't auto login, go to login page

      SnackbarKustom.sukses(
        'Registrasi Berhasil',
        'Akun Anda telah berhasil dibuat. Silakan login.',
      );

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

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      SnackbarKustom.error('Gagal', 'Email tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;
      await _authService.resetPassword(email);
      SnackbarKustom.info(
        'Email Terkirim',
        'Silakan cek email Anda untuk mereset password',
      );
      Get.back(); // Close dialog or page
    } catch (e) {
      SnackbarKustom.error('Gagal Reset Password', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();

      // Hapus controller data agar data user sebelumnya tidak muncul
      if (Get.isRegistered<KontrolerBeranda>())
        Get.delete<KontrolerBeranda>(force: true);
      if (Get.isRegistered<KontrolerTransaksi>())
        Get.delete<KontrolerTransaksi>(force: true);
      if (Get.isRegistered<KontrolerJadwalPembayaran>())
        Get.delete<KontrolerJadwalPembayaran>(force: true);

      isLoggedIn.value = false;
      userName.value = 'User';
      Get.offAllNamed('/login');
      SnackbarKustom.info('Logout', 'Anda telah keluar dari aplikasi');
    } catch (e) {
      SnackbarKustom.error('Logout Gagal', e.toString());
    }
  }

  void _onAuthSuccess() {
    checkLoginStatus();
    Get.offAllNamed('/dashboard');
  }
}
