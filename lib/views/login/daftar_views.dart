import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanDaftar extends StatelessWidget {
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  TampilanDaftar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
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
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  offset: const Offset(0, 10),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bergabunglah bersama kami',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 30),
                _buildFloatingLabelTextField(
                  context,
                  label: 'Username',
                  controller: usernameCtrl,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildFloatingLabelTextField(
                  context,
                  label: 'Email',
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => _buildFloatingLabelTextField(
                    context,
                    label: 'Password',
                    controller: passwordCtrl,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscure: !authCtrl.isRegisterPasswordVisible.value,
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
                            onPressed: () => authCtrl.register(
                              usernameCtrl.text,
                              emailCtrl.text,
                              passwordCtrl.text,
                            ),
                            child: const Text(
                              'Daftar Sekarang',
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
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: inputType,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,

        prefixIcon: null,

        suffixIcon: isPassword
            ? IconButton(
                iconSize: 20,
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(
                    context,
                  ).iconTheme.color?.withValues(alpha: 0.5),
                ),
                onPressed: onToggleVisibility,
              )
            : null,

        // Styling Border
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
          vertical: 18,
        ),
      ),
    );
  }
}
