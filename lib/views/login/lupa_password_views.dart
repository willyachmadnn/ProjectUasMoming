import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanLupaPassword extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();

  TampilanLupaPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Lupa Password",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Masukkan email Anda untuk menerima link reset password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                Obx(
                  () => authCtrl.isLoading.value
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              if (emailCtrl.text.isEmpty) {
                                Get.snackbar(
                                  "Error",
                                  "Email tidak boleh kosong",
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  colorText: Theme.of(
                                    context,
                                  ).colorScheme.onError,
                                );
                                return;
                              }
                              authCtrl.resetPassword(emailCtrl.text);
                            },
                            child: const Text(
                              'Kirim Link Reset',
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
}

class TampilanUbahPassword extends StatelessWidget {
  final String oobCode;
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();

  final TextEditingController newPasswordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  TampilanUbahPassword({super.key, required this.oobCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Reset Password",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Password Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan buat password baru untuk akun Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                Obx(
                  () => _buildFloatingLabelTextField(
                    context,
                    label: 'Password Baru',
                    controller: newPasswordCtrl,
                    isPassword: true,
                    isObscure: !(authCtrl.isRegisterPasswordVisible.value),
                    onToggleVisibility:
                        authCtrl.toggleRegisterPasswordVisibility,
                  ),
                ),

                const SizedBox(height: 20),

                Obx(
                  () => _buildFloatingLabelTextField(
                    context,
                    label: 'Konfirmasi Password',
                    controller: confirmPasswordCtrl,
                    isPassword: true,
                    isObscure: !(authCtrl.isRegisterPasswordVisible.value),
                    onToggleVisibility:
                        authCtrl.toggleRegisterPasswordVisibility,
                  ),
                ),

                const SizedBox(height: 32),

                Obx(
                  () => authCtrl.isLoading.value
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              if (newPasswordCtrl.text.isEmpty) {
                                Get.snackbar(
                                  "Error",
                                  "Password tidak boleh kosong",
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  colorText: Theme.of(
                                    context,
                                  ).colorScheme.onError,
                                );
                                return;
                              }
                              if (newPasswordCtrl.text !=
                                  confirmPasswordCtrl.text) {
                                Get.snackbar(
                                  "Error",
                                  "Password tidak sama",
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                  colorText: Theme.of(
                                    context,
                                  ).colorScheme.onError,
                                );
                                return;
                              }
                              authCtrl.confirmPasswordReset(
                                oobCode,
                                newPasswordCtrl.text,
                              );
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
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        suffixIcon: isPassword
            ? IconButton(
                iconSize: 20,
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
