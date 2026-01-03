import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/autentikasi_controllers.dart';

class TampilanMasuk extends StatelessWidget {
  final KontrolerAutentikasi authCtrl = Get.find<KontrolerAutentikasi>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  TampilanMasuk({super.key}) {
    // Auto-fill username if passed from registration
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('username')) {
        usernameCtrl.text = args['username'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E5EC), // Soft gray background like image
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: Get.width > 600 ? 450 : Get.width * 0.9,
            ),
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Color(0xFFE0E5EC), // Neumorphic base color
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  offset: Offset(-6, -6),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: Color(0xFFA3B1C6).withValues(alpha: 0.5),
                  offset: Offset(6, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Title
                Container(
                  height: Get.height * 0.25, // Responsive height
                  constraints: BoxConstraints(maxHeight: 200, minHeight: 150),
                  width: double.infinity,
                  child: Image.asset(
                    'assets/sakuku.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_balance_wallet,
                      size: 90,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Masa Depan Cerah Dimulai dari Catatan Kecil',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 24),

                // Forms
                _buildTextField(
                  context,
                  label: 'Username',
                  hint: 'Masukan username anda',
                  controller: usernameCtrl,
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 20),

                // Password Field with Visibility Toggle
                Obx(
                  () => _buildTextField(
                    context,
                    label: 'Password',
                    hint: 'Masukan password',
                    controller: passwordCtrl,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscure: !authCtrl.isLoginPasswordVisible.value,
                    onToggleVisibility: authCtrl.toggleLoginPasswordVisibility,
                  ),
                ),

                SizedBox(height: 16),

                // Links
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed('/daftar'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                          children: [
                            TextSpan(
                              text: 'Daftar',
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/lupa_password'),
                      child: Text(
                        'Lupa password?',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Login Button
                Obx(
                  () => authCtrl.isLoading.value
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF34495E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              authCtrl.login(
                                usernameCtrl.text,
                                passwordCtrl.text,
                              );
                            },
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                ),

                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 20),

                // Google Sign In
                Obx(
                  () => authCtrl.isLoading.value
                      ? SizedBox.shrink()
                      : OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            side: BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.login),
                          ),
                          label: Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => authCtrl.loginWithGoogle(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ), // Added border
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
