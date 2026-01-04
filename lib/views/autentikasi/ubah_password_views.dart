import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanUbahPassword extends StatelessWidget {
  final String oobCode;
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();

  final TextEditingController newPasswordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  TampilanUbahPassword({super.key, required this.oobCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text("Reset Password", style: TextStyle(color: Color(0xFF2C3E50))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: Get.width > 600 ? 450 : Get.width * 0.9,
            ),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E5EC),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  offset: const Offset(-6, -6),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                  offset: const Offset(6, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Password Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan buat password baru untuk akun Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 30),

                Obx(() => _buildFloatingLabelTextField(
                  context,
                  label: 'Password Baru',
                  controller: newPasswordCtrl,
                  isPassword: true,
                  isObscure: !(authCtrl.isRegisterPasswordVisible.value),
                  onToggleVisibility: authCtrl.toggleRegisterPasswordVisibility,
                )),

                const SizedBox(height: 20),

                Obx(() => _buildFloatingLabelTextField(
                  context,
                  label: 'Konfirmasi Password',
                  controller: confirmPasswordCtrl,
                  isPassword: true,
                  isObscure: !(authCtrl.isRegisterPasswordVisible.value),
                  onToggleVisibility: authCtrl.toggleRegisterPasswordVisibility,
                )),

                const SizedBox(height: 32),

                Obx(() => authCtrl.isLoading.value
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34495E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (newPasswordCtrl.text.isEmpty) {
                        Get.snackbar("Error", "Password tidak boleh kosong", backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                        Get.snackbar("Error", "Password tidak sama", backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      authCtrl.confirmPasswordReset(oobCode, newPasswordCtrl.text);
                    },
                    child: const Text(
                      'Simpan Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingLabelTextField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        bool isPassword = false,
        bool isObscure = false,
        VoidCallback? onToggleVisibility,
      }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF2C3E50),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        floatingLabelStyle: const TextStyle(color: Color(0xFF34495E), fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword
            ? IconButton(
          iconSize: 20,
          // PERBAIKAN: Safe color check
          icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey
          ),
          onPressed: onToggleVisibility,
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF34495E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}